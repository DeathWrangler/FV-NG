package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.WatchToEarnManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.InGamePaymentsManager;
   import Managers.SubscriptionsManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BuyMoneyWindow_v2 extends BuyMoneyWindow
   {
      
      public static const BUTTON_PACKAGE_MAPPINGS:Array = [[4,2,0],[4,2,0],[3,2,1],[1,2,3]];
      
      public static const BUTTON_PACKAGE_MAPPINGS_DYNAMIC_TYPEA:Object = {
         "outofcash_lowpayer":[4,3,2],
         "outofcash_midlowpayer":[3,2,1],
         "outofcash_midhighpayer":[2,1,0],
         "outofcash_highpayer":[2,1,0]
      };
      
      public static const BUTTON_PACKAGE_MAPPINGS_DYNAMIC_TYPEB:Object = {
         "outofcash_lowpayer":[4,3,2,1],
         "outofcash_midlowpayer":[4,3,2,1],
         "outofcash_midhighpayer":[3,2,1,0],
         "outofcash_highpayer":[2,1,0,6]
      };
      
      protected static const GOLD_FRAME_BUTTON_BACKGROUND:int = 2;
      
      protected static const CONTAINER_HORIZONTAL_3_BUTTONS:int = 0;
      
      protected static const CONTAINER_HORIZONTAL_4_BUTTONS:int = 1;
      
      protected static const CONTAINER_VERTICAL_3_BUTTONS:int = 2;
      
      protected static const CONTAINER_VERTICAL_4_BUTTONS:int = 3;
      
      protected static const CONTAINER_BDDD_SLOT:int = 4;
      
      protected static const CONTAINER_BDDD_BURST:int = 5;
      
      protected static const CONTAINER_VERTICAL_3_BUTTONS_VIP:int = 6;
      
      protected static const CONTAINER_VERTICAL_4_BUTTONS_VIP:int = 7;
      
      protected static const VARIANT_DYNAMIC_PACKAGE:int = 4;
      
      protected static const NUM_SLOT_CONTAINERS:int = 8;
      
      public static const W2E_SLOT_ID_OUT_OF_CASH:String = "WEB_FARM_INC_PP_CASH";
      
      protected static const BDDD_FEATURE_NAME:String = "BuyDialogDailyDrip";
      
      protected static const BDDD_LAST_OPENED_DATE_KEY:String = "lastOpenedDate";
      
      protected static const BDDD_REWARD_ITEM_NAME_KEY:String = "rewardItemName";
      
      protected static const BDDD_LAST_CLAIMED_DATE_KEY:String = "lastClaimedDate";
      
      private static const BDDD_REFRESH_NUM_SECS_DELAY:int = 10;
      
      protected var m_slotContainers:Array = [];
      
      protected var m_activeSlotContainer:ZwFrame = null;
      
      protected var m_purchaseName:String = "";
      
      protected var m_dailyDripRewardItemName:String = "";
      
      protected var m_midnightTimer:Timer = null;
      
      protected var m_dailyDripFrame:ZwFrame = null;
      
      public function BuyMoneyWindow_v2(purchaseName:String, attemptedSpend:int = -1, featureName:String = "payment_interstitial", dialogAsset:String = "assets/dialogs/FV_OutOfCash_social_3.swf")
      {
         this.m_purchaseName = purchaseName;
         super(featureName,dialogAsset,null,attemptedSpend);
      }
      
      override protected function postLoadComplete() : void
      {
         if(canUseBDDD())
         {
            if(!isBDDDFullBurstMode())
            {
               m_window.tutorial_mc = m_window.tutorial2_mc;
            }
            else
            {
               m_window.tutorial_mc = m_window.tutorial1_mc;
            }
         }
         super.postLoadComplete();
      }
      
      override protected function setupPaymentButtons() : void
      {
         var dynamicTypeA:int = 0;
         var dynamicTypeB:int = 0;
         var dynamicPackages:Object = null;
         var resultMapping:Array = null;
         var key:String = null;
         var runtimePrereq:Object = null;
         var highestPriceIndex:int = 0;
         var vipButtonObj:DisplayObject = null;
         var buttonObj:DisplayObject = null;
         var priceSelectBt:FarmAnimatedTextButton = null;
         var ableToSeeAds:Boolean = false;
         var packageObj:Object = null;
         var dailyDripButton:DisplayObject = null;
         var rewardItemName:Object = null;
         var millisecondsUntilMidnight:Number = NaN;
         var slotsMc:ZwFrame = addWidget(new ZwFrame(m_window["slots_mc"])) as ZwFrame;
         var useBDDD:Boolean = canUseBDDD();
         for(var i:int = 0; i < NUM_SLOT_CONTAINERS; i++)
         {
            if(slotsMc.element["slots_" + i.toString() + "_mc"])
            {
               this.m_slotContainers.push(slotsMc.addWidget(new ZwFrame(slotsMc.element["slots_" + i.toString() + "_mc"]),false) as ZwFrame);
            }
         }
         var expGateVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OUTOFCASH_NEW);
         var expPackVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OUTOFCASH_NEW_PACKAGES);
         m_buttonPaymentMapping = null;
         if(expPackVariant < VARIANT_DYNAMIC_PACKAGE)
         {
            m_buttonPaymentMapping = BUTTON_PACKAGE_MAPPINGS[expPackVariant];
         }
         else if(expPackVariant >= VARIANT_DYNAMIC_PACKAGE)
         {
            dynamicTypeA = VARIANT_DYNAMIC_PACKAGE;
            dynamicTypeB = VARIANT_DYNAMIC_PACKAGE + 1;
            if(expPackVariant == dynamicTypeA && !useBDDD)
            {
               dynamicPackages = BUTTON_PACKAGE_MAPPINGS_DYNAMIC_TYPEA;
            }
            else
            {
               dynamicPackages = BUTTON_PACKAGE_MAPPINGS_DYNAMIC_TYPEB;
            }
            resultMapping = null;
            for(key in dynamicPackages)
            {
               runtimePrereq = Global.farmGameSettingsManager.getPrereqByName(key);
               if(Boolean(runtimePrereq) && PrerequisiteUtility.isPrerequisiteMet(runtimePrereq))
               {
                  resultMapping = dynamicPackages[key];
                  break;
               }
            }
            m_buttonPaymentMapping = resultMapping;
         }
         var vertical:Boolean = expGateVariant == 4 || expGateVariant == 5;
         var numButtons:int = int(m_buttonPaymentMapping.length);
         var goldButtonIndex:int = 0;
         if(expGateVariant % 2 == 1)
         {
            highestPriceIndex = 0;
            for(i = 0; i < m_buttonPaymentMapping.length; i++)
            {
               if(m_buttonPaymentMapping[i] < m_buttonPaymentMapping[highestPriceIndex])
               {
                  highestPriceIndex = i;
               }
            }
            goldButtonIndex = highestPriceIndex;
         }
         else
         {
            goldButtonIndex = int(Math.floor(numButtons / 2));
         }
         var containerIndex:int = 0;
         if(!useBDDD)
         {
            if(vertical == false)
            {
               if(numButtons == 3)
               {
                  containerIndex = CONTAINER_HORIZONTAL_3_BUTTONS;
               }
               else
               {
                  containerIndex = CONTAINER_HORIZONTAL_4_BUTTONS;
               }
            }
            else if(this.shouldShowVIPSignup())
            {
               if(numButtons == 3)
               {
                  containerIndex = CONTAINER_VERTICAL_3_BUTTONS_VIP;
               }
               else
               {
                  containerIndex = CONTAINER_VERTICAL_4_BUTTONS_VIP;
               }
            }
            else if(numButtons == 3)
            {
               containerIndex = CONTAINER_VERTICAL_3_BUTTONS;
            }
            else
            {
               containerIndex = CONTAINER_VERTICAL_4_BUTTONS;
            }
         }
         else if(!isBDDDFullBurstMode())
         {
            containerIndex = CONTAINER_BDDD_SLOT;
         }
         else
         {
            containerIndex = CONTAINER_BDDD_BURST;
         }
         this.m_activeSlotContainer = this.m_slotContainers[containerIndex];
         if(Boolean(m_buttonPaymentMapping) && Boolean(this.m_activeSlotContainer))
         {
            this.m_activeSlotContainer.visible = true;
            for(i = 0; i < numButtons; i++)
            {
               buttonObj = this.getPaymentButtonObject(i);
               if(buttonObj)
               {
                  priceSelectBt = null;
                  ableToSeeAds = false;
                  ableToSeeAds = false;
                  if(ableToSeeAds)
                  {
                     FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_OUT_OF_CASH,"view");
                  }
                  else
                  {
                     packageObj = InGamePaymentsManager.getPaymentByIndex(m_buttonPaymentMapping[i]);
                     if(packageObj)
                     {
                        priceSelectBt = this.setupDefaultButton(packageObj,buttonObj,i == goldButtonIndex);
                     }
                  }
                  if(priceSelectBt)
                  {
                     priceSelectBt.id = i.toString();
                  }
               }
            }
            vipButtonObj = this.getVIPButtonObject();
            if(vipButtonObj)
            {
               this.setupVIPButton(vipButtonObj);
            }
         }
         if(useBDDD)
         {
            if(Boolean(this.m_activeSlotContainer) && this.m_activeSlotContainer.element.hasOwnProperty("slot_4_mc"))
            {
               dailyDripButton = this.m_activeSlotContainer.element["slot_4_mc"];
               if(dailyDripButton)
               {
                  rewardItemName = FeatureOptionsManager.getInstance().getFeatureOption(BDDD_FEATURE_NAME,BDDD_REWARD_ITEM_NAME_KEY);
                  this.m_dailyDripRewardItemName = rewardItemName as String;
                  if(this.m_dailyDripRewardItemName)
                  {
                     this.setupDailyDripFrame(dailyDripButton);
                     millisecondsUntilMidnight = FarmGameUtil.getMidnightTimestamp() + FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime + BDDD_REFRESH_NUM_SECS_DELAY * FarmGameUtil.NUM_MSECS_IN_SECOND;
                     this.m_midnightTimer = new Timer(millisecondsUntilMidnight,1);
                     this.m_midnightTimer.addEventListener(TimerEvent.TIMER,this.refreshDailyDrip);
                     this.m_midnightTimer.start();
                  }
               }
            }
         }
      }
      
      protected function setupDailyDripFrame(buttonObj:DisplayObject) : void
      {
         var rewardItemAssetURL:String = null;
         var frameElement:Object = null;
         var claimBt:FarmAnimatedTextButton = null;
         var itemNameTf:ZwTextField = null;
         var claimedTf:ZwTextField = null;
         var dailyRewardTf:ZwTextField = null;
         var itemIcon:FarmIcon = null;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyDripRewardItemName);
         if(rewardItem)
         {
            rewardItemAssetURL = rewardItem.icon;
            this.m_dailyDripFrame = addWidget(new ZwFrame(buttonObj)) as ZwFrame;
            frameElement = this.m_dailyDripFrame.element;
            claimBt = null;
            if(frameElement.buy_mc)
            {
               claimBt = this.m_dailyDripFrame.addWidget(new FarmAnimatedTextButton(frameElement.buy_mc,ZLocUtils.t("Dialogs","Claim"),this.onClickClaimDailyDrip)) as FarmAnimatedTextButton;
               claimBt.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","bddd_claim_button_tooltip_text")));
            }
            if(frameElement.slotBG_mc)
            {
               this.m_dailyDripFrame.addWidget(new ZwFrame(frameElement.slotBG_mc));
            }
            itemNameTf = null;
            if(frameElement.generic_tf)
            {
               itemNameTf = this.m_dailyDripFrame.addWidget(new ZwTextField(frameElement.generic_tf,rewardItem.friendlyTitle)) as ZwTextField;
            }
            claimedTf = null;
            if(frameElement.claimed_tf)
            {
               claimedTf = this.m_dailyDripFrame.addWidget(new ZwTextField(frameElement.claimed_tf,ZLocUtils.t("Dialogs","bddd_claimed"))) as ZwTextField;
            }
            dailyRewardTf = null;
            if(!isBDDDFullBurstMode() && Boolean(frameElement.cost_tf))
            {
               dailyRewardTf = this.m_dailyDripFrame.addWidget(new ZwTextField(frameElement.cost_tf,ZLocUtils.t("Dialogs","bddd_daily_reward"))) as ZwTextField;
            }
            if(frameElement.icon_mc)
            {
               itemIcon = this.m_dailyDripFrame.addWidget(new FarmIcon(frameElement.icon_mc)) as FarmIcon;
               itemIcon.loadIcon(rewardItemAssetURL);
            }
            if(frameElement.giftbox_mc)
            {
               this.m_dailyDripFrame.addWidget(new ZwFrame(frameElement.giftbox_mc)) as ZwFrame;
            }
            if(!this.bdddIsOpened())
            {
               this.refreshDailyDrip(null);
            }
            else if(!this.bdddIsClaimed())
            {
               if(claimedTf)
               {
                  claimedTf.visible = false;
               }
               if(claimBt)
               {
                  claimBt.visible = true;
               }
               if(itemNameTf)
               {
                  itemNameTf.visible = true;
               }
               if(!isBDDDFullBurstMode() && Boolean(dailyRewardTf))
               {
                  dailyRewardTf.visible = true;
               }
            }
            else
            {
               if(claimedTf)
               {
                  claimedTf.visible = true;
               }
               if(claimBt)
               {
                  claimBt.visible = false;
               }
               if(itemNameTf)
               {
                  itemNameTf.visible = false;
               }
               if(!isBDDDFullBurstMode() && Boolean(dailyRewardTf))
               {
                  dailyRewardTf.visible = false;
               }
            }
            this.m_dailyDripFrame.visible = true;
            FarmStatsManager.count("daily_drip","impression",this.m_dailyDripRewardItemName);
         }
      }
      
      private function bdddIsOpened() : Boolean
      {
         var lastOpened:Object = FeatureOptionsManager.getInstance().getFeatureOption(BDDD_FEATURE_NAME,BDDD_LAST_OPENED_DATE_KEY);
         var midnight:Number = FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var lastOpenedNum:Number = lastOpened as Number;
         return lastOpened != null && lastOpenedNum > midnight;
      }
      
      private function bdddIsClaimed() : Boolean
      {
         var lastClaimed:Object = FeatureOptionsManager.getInstance().getFeatureOption(BDDD_FEATURE_NAME,BDDD_LAST_CLAIMED_DATE_KEY);
         var midnight:Number = FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var lastClaimedNum:Number = lastClaimed as Number;
         return lastClaimed != null && lastClaimedNum > midnight;
      }
      
      protected function refreshDailyDrip(event:TimerEvent) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("BuyDialogDailyDripService","refreshReward",this.refreshDailyDripCallback),true);
      }
      
      private function refreshDailyDripCallback(result:Object) : void
      {
         var rewardItem:FarmItem = null;
         var rewardItemAssetURL:String = null;
         var frameElement:Object = null;
         var itemIcon:FarmIcon = null;
         var claimBt:FarmAnimatedTextButton = null;
         var claimedTf:ZwTextField = null;
         var itemNameTf:ZwTextField = null;
         var dailyRewardTf:ZwTextField = null;
         if(result.error == null && result.itemName != null)
         {
            this.m_dailyDripRewardItemName = result.itemName;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyDripRewardItemName);
            if(rewardItem)
            {
               rewardItemAssetURL = rewardItem.icon;
               frameElement = this.m_dailyDripFrame.element;
               if(frameElement.icon_mc)
               {
                  itemIcon = this.m_dailyDripFrame.getWidget(frameElement.icon_mc) as FarmIcon;
                  itemIcon.loadIcon(rewardItemAssetURL);
               }
               if(frameElement.buy_mc)
               {
                  claimBt = this.m_dailyDripFrame.getWidget(frameElement.buy_mc) as FarmAnimatedTextButton;
                  claimBt.visible = true;
               }
               if(frameElement.claimed_tf)
               {
                  claimedTf = this.m_dailyDripFrame.getWidget(frameElement.claimed_tf) as ZwTextField;
                  claimedTf.visible = false;
               }
               if(frameElement.generic_tf)
               {
                  itemNameTf = this.m_dailyDripFrame.getWidget(frameElement.generic_tf) as ZwTextField;
                  itemNameTf.text = rewardItem.friendlyTitle;
                  itemNameTf.visible = true;
               }
               if(!isBDDDFullBurstMode() && Boolean(frameElement.cost_tf))
               {
                  dailyRewardTf = this.m_dailyDripFrame.getWidget(frameElement.cost_tf) as ZwTextField;
                  dailyRewardTf.visible = true;
               }
            }
         }
      }
      
      protected function onClickClaimDailyDrip(event:Event) : void
      {
         var claimTimestamp:uint = 0;
         var frame:ZwFrame = null;
         var frameElement:Object = null;
         var claimBt:FarmAnimatedTextButton = null;
         var claimedTf:ZwTextField = null;
         var itemNameTf:ZwTextField = null;
         var dailyRewardTf:ZwTextField = null;
         if(!this.bdddIsClaimed())
         {
            Global.player.addGift(this.m_dailyDripRewardItemName);
            claimTimestamp = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            FeatureOptionsManager.getInstance().setFeatureOption(BDDD_FEATURE_NAME,BDDD_LAST_CLAIMED_DATE_KEY,claimTimestamp);
            frame = getWidget(event.currentTarget.parent) as ZwFrame;
            frameElement = frame.element;
            if(frameElement.buy_mc)
            {
               claimBt = frame.getWidget(frameElement.buy_mc) as FarmAnimatedTextButton;
               claimBt.visible = false;
            }
            if(frameElement.claimed_tf)
            {
               claimedTf = frame.getWidget(frameElement.claimed_tf) as ZwTextField;
               claimedTf.visible = true;
            }
            if(frameElement.generic_tf)
            {
               itemNameTf = frame.getWidget(frameElement.generic_tf) as ZwTextField;
               itemNameTf.visible = false;
            }
            if(!isBDDDFullBurstMode() && Boolean(frameElement.cost_tf))
            {
               dailyRewardTf = frame.getWidget(frameElement.cost_tf) as ZwTextField;
               dailyRewardTf.visible = false;
            }
            if(frameElement.giftbox_mc)
            {
               frameElement.giftbox_mc.gotoAndPlay(2);
            }
            TransactionManager.addTransaction(new TGenericTransaction("BuyDialogDailyDripService","claimReward"));
         }
      }
      
      protected function setupW2EButton(amount:int, buttonObj:DisplayObject, isGold:Boolean) : FarmAnimatedTextButton
      {
         var frame:ZwFrame = addWidget(new ZwFrame(buttonObj)) as ZwFrame;
         var frameElement:Object = frame.element;
         var farmCashAmountTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.amount_tf,amount.toString())) as ZwTextField;
         var farmCashTextTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.generic_tf,ZLocUtils.t("Farmville","CashTitle"))) as ZwTextField;
         var realCashAmountTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.cost_tf,ZLocUtils.t("Dialogs","Free"))) as ZwTextField;
         var background:ZwFrame = frame.addWidget(new ZwFrame(frameElement.slotBG_mc)) as ZwFrame;
         if(isGold)
         {
            background.element.gotoAndStop(GOLD_FRAME_BUTTON_BACKGROUND);
         }
         var priceSelectBt:FarmAnimatedTextButton = frame.addWidget(new FarmAnimatedTextButton(frameElement["buy_mc"],ZLocUtils.t("Dialogs","WatchAd"),this.onClickWatchAd)) as FarmAnimatedTextButton;
         frame.visible = true;
         return priceSelectBt;
      }
      
      protected function onClickWatchAd(event:Event) : void
      {
         var clickedId:int = 0;
         var frame:ZwFrame = getWidget(event.currentTarget.parent) as ZwFrame;
         var clicked:FarmAnimatedTextButton = frame.getWidget(event.currentTarget) as FarmAnimatedTextButton;
         if(clicked)
         {
            clickedId = parseInt(clicked.id);
            clicked.applyGrayOut = true;
            clicked.enabled = false;
            this.trackButtonClick(clickedId);
            FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_OUT_OF_CASH,"click");
         }
      }
      
      protected function setupDefaultButton(packageObj:Object, buttonObj:DisplayObject, isGold:Boolean) : FarmAnimatedTextButton
      {
         var frame:ZwFrame = addWidget(new ZwFrame(buttonObj)) as ZwFrame;
         var frameElement:Object = frame.element;
         var farmCashAmountTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.amount_tf,packageObj["amount"])) as ZwTextField;
         var farmCashTextTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.generic_tf,ZLocUtils.t("Farmville","CashTitle"))) as ZwTextField;
         var realCashAmountTf:ZwTextField = frame.addWidget(new ZwTextField(frameElement.cost_tf,ZLocUtils.t("Dialogs","InGamePaymentsCost",{"quantity":packageObj["cost"]}))) as ZwTextField;
         var background:ZwFrame = frame.addWidget(new ZwFrame(frameElement.slotBG_mc)) as ZwFrame;
         if(isGold)
         {
            background.element.gotoAndStop(GOLD_FRAME_BUTTON_BACKGROUND);
         }
         var priceSelectBt:FarmAnimatedTextButton = frame.addWidget(new FarmAnimatedTextButton(frameElement["buy_mc"],getPaymentButtonText(),onClickBuyNow)) as FarmAnimatedTextButton;
         frame.visible = true;
         return priceSelectBt;
      }
      
      override protected function getPaymentButtonObject(index:int) : DisplayObject
      {
         var result:DisplayObject = null;
         if(Boolean(this.m_activeSlotContainer) && this.m_activeSlotContainer.element.hasOwnProperty("slot_" + index + "_mc"))
         {
            result = this.m_activeSlotContainer.element["slot_" + index + "_mc"];
         }
         return result;
      }
      
      override protected function setupHeaders() : void
      {
         if(canUseBDDD())
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","bddd_title")));
            }
            if(m_window.generic_1_tf)
            {
               addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","bddd_generic_1")));
            }
            if(m_window.generic_2_tf)
            {
               addWidget(new ZwTextField(m_window.generic_2_tf,ZLocUtils.t("Dialogs","bddd_generic_2")));
            }
         }
         else if(m_attemptedSpend == 0)
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","bddd_title")));
            }
            if(m_window.generic_1_tf)
            {
               addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","bddd_generic_3")));
            }
            if(m_window.generic_2_tf)
            {
               addWidget(new ZwTextField(m_window.generic_2_tf,ZLocUtils.t("Dialogs","MOTD_bddd_Blank")));
            }
         }
         else
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","OutOfCashTwo_Title")));
            }
            if(m_window.generic_1_tf)
            {
               addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","OutOfCashTwo_Subtitle")));
            }
            if(m_window.generic_2_tf)
            {
               addWidget(new ZwTextField(m_window.generic_2_tf,ZLocUtils.t("Dialogs","OutOfCashTwo_Subtitletwo")));
            }
         }
      }
      
      override protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         FarmStatsManager.count("payment","in_app","out_of_cash",this.m_purchaseName,orderId,Global.worldManager.currentWorldType,m_attemptedPurchaseAmount);
         TransactionManager.addTransaction(new TRefreshBalance(),true);
         close();
      }
      
      override protected function trackButtonClick(buttonId:int) : void
      {
         var sourceString:String = m_attemptedSpend > 0 ? "not_enough_cash" : "fc_hud";
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,m_featureName,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM + "_pkg" + buttonId.toString(),this.m_purchaseName,sourceString);
         var bdddString:String = canUseBDDD() ? "BDDDon" : "BDDDoff";
         FarmStatsManager.count("daily_drip","click_button",buttonId.toString(),this.m_purchaseName,bdddString);
      }
      
      override protected function release() : void
      {
         if(Boolean(this.m_midnightTimer) && this.m_midnightTimer.running)
         {
            this.m_midnightTimer.removeEventListener(TimerEvent.TIMER,this.refreshDailyDrip);
            this.m_midnightTimer.stop();
            this.m_midnightTimer = null;
         }
         super.release();
      }
      
      private function getVIPButtonObject() : DisplayObject
      {
         var result:DisplayObject = null;
         if(Boolean(this.m_activeSlotContainer) && this.m_activeSlotContainer.element.hasOwnProperty("slot_vip_mc"))
         {
            result = this.m_activeSlotContainer.element["slot_vip_mc"];
         }
         return result;
      }
      
      private function setupVIPButton(buttonObj:DisplayObject) : void
      {
         var farmCashAmountTf:ZwTextField = null;
         var farmDollarAmountTf:ZwTextField = null;
         var priceSelectBt:FarmAnimatedTextButton = null;
         var frame:ZwFrame = addWidget(new ZwFrame(buttonObj)) as ZwFrame;
         var frameElement:Object = frame.element;
         if(frameElement.hasOwnProperty("amount_tf") && Boolean(frameElement["amount_tf"]))
         {
            farmCashAmountTf = frame.addWidget(new ZwTextField(frameElement.amount_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Subscriptions_BuyPage_Amount"))) as ZwTextField;
         }
         if(frameElement.hasOwnProperty("cost_tf") && Boolean(frameElement["cost_tf"]))
         {
            farmDollarAmountTf = frame.addWidget(new ZwTextField(frameElement.cost_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Subscriptions_BuyPage_Cost"))) as ZwTextField;
         }
         if(frameElement.hasOwnProperty("buy_mc") && Boolean(frameElement["buy_mc"]))
         {
            priceSelectBt = frame.addWidget(new FarmAnimatedTextButton(frameElement["buy_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Subscriptions_MOTD_Inactive_Signup"),this.onClickSignUp)) as FarmAnimatedTextButton;
         }
      }
      
      private function shouldShowVIPSignup() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_SUBSCRIPTIONS_V2_SURFACING) == Experiments.VARIANT_SUBSCRIPTIONS_V2_SURFACING)
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_SUBSCRIPTIONS_V2_SURFACING_BUYPAGE) == Experiments.VARIANT_SUBSCRIPTIONS_V2_SURFACING_BUYPAGE)
            {
               if(!SubscriptionsManager.instance.isSubscriber())
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      private function onClickSignUp(event:Event) : void
      {
         close();
         SubscriptionsManager.triggerSignUpFlow("impulse_buy");
      }
   }
}

