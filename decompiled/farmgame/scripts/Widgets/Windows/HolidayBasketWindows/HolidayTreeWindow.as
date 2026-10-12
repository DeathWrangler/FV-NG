package Widgets.Windows.HolidayBasketWindows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TAwardHolidayGifts;
   import Transactions.TCancelFriendReward;
   import Transactions.THolidayTreeAwardGifts;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.SummaryItemSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenLite;
   import com.greensock.easing.*;
   import com.greensock.plugins.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class HolidayTreeWindow extends RewardCreditsWindow
   {
      
      private static var DIALOG_WIDTH:Number = 740;
      
      private static var DIALOG_HEIGHT:Number = 593;
      
      private static var m_currentlyShowing:Boolean = false;
      
      protected static const TOKEN_OPEN_GIFT:String = "OpenGifts";
      
      protected static const TOKEN_FILLED_METER:String = "FilledMeter";
      
      protected static const TOKEN_HAS_OFFBOARDED:String = "Offboarded";
      
      protected static const TOKEN_UNWRAP:String = "unwrap";
      
      private static const DEFAULT_OFFBOARD_DATE:String = "01/08/2012";
      
      private const MAX_UNIQUE_ITEMS:int = 46;
      
      private const OPEN_ALL_GIFTS_BUTTON_COUNT:int = 5;
      
      private var m_giftsRemainingArray:Array = null;
      
      private var m_openingComplete:Boolean = false;
      
      private var m_openGiftMode:Boolean = false;
      
      private var m_openAllButton:FarmAnimatedTextButton;
      
      private var m_buyAllButton:FarmAnimatedTextButton;
      
      private var m_giftsLeftToAddToTree:int = 0;
      
      private var m_unopenedGifts:int = 0;
      
      private var m_openedGifts:int = 0;
      
      private var m_goldGift:ZwFrame;
      
      private var m_openAll:Boolean = false;
      
      private var m_isOffboarding:Boolean = false;
      
      private var m_giftOpeningStage:int = 1;
      
      private var m_unopenedText:ZwTextField;
      
      private var m_previouslyOpenedGifts:int;
      
      private var m_openedText:ZwTextField;
      
      protected var m_cutscenePlaying:Boolean = false;
      
      private var m_farmCashText:ZwTextField = null;
      
      private var m_configuration:FeatureConfigManager;
      
      public const TOKEN_AWARDED_SPECIAL_GIFT:String = "SpecialGiftsRewarded";
      
      public const TOKEN_AWARDED_GOLD_GIFT:String = "GoldGiftRewarded";
      
      private const CUT_SCENE_FRAME:int = 2;
      
      private const SUMMARY_SCRIPT_FRAME:int = 206;
      
      private const SUMMARY_SCREEN_FRAME:int = 207;
      
      private var m_latestReward:String;
      
      private var m_rewardLink:String;
      
      private var m_cutsceneFrame:int = 2;
      
      private var m_summaryFrame:int = 207;
      
      public function HolidayTreeWindow(building:RewardCreditsBuilding, buildingClassName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showRedeemableItemOnLoad:Object = null, useMultiFriendSelector:Boolean = true)
      {
         super(building,buildingClassName,dialogAssetUrl,showWhatIsThisOnLoad,showRedeemableItemOnLoad);
         this.m_configuration = FeatureConfigManager.getFeatureConfiguration(buildingClassName);
      }
      
      override protected function postLoadComplete() : void
      {
         var skipCutScene:Boolean = false;
         m_window.cutscene_mc.visible = false;
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_building.getCreditsFeatureName());
         var openDate:String = rawXML.elements("giftOpen").toString();
         this.m_openGiftMode = FarmGameUtil.checkStartDateGate(openDate);
         var cutsceneFrame:String = rawXML.elements("cutsceneFrame");
         if(cutsceneFrame != null && cutsceneFrame != "")
         {
            this.m_cutsceneFrame = int(cutsceneFrame);
         }
         var summaryFrame:String = rawXML.elements("summaryFrame");
         if(summaryFrame != null && summaryFrame != "")
         {
            this.m_summaryFrame = int(summaryFrame);
         }
         var offboardData:Array = this.m_building.getOffBoardingData();
         var offboardDate:String = offboardData != null && offboardData["date"] != null ? offboardData["date"] : DEFAULT_OFFBOARD_DATE;
         this.m_isOffboarding = FarmGameUtil.checkStartDateGate(offboardDate);
         this.m_goldGift = addWidget(new ZwFrame(m_window.goldGift_mc)) as ZwFrame;
         super.postLoadComplete();
         this.updateMeterImage();
         this.m_buyAllButton = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","FeatureBuildingCompleteNow"),this.onBuyAll),true) as FarmAnimatedTextButton;
         if(this.m_openGiftMode)
         {
            this.m_unopenedGifts = m_building.getCurrentCredits();
            this.m_previouslyOpenedGifts = int(FeatureOptionsManager.getInstance().getFeatureOption(m_building.getCreditsFeatureName(),"opencount"));
            this.m_unopenedGifts -= this.m_previouslyOpenedGifts;
            if(this.m_isOffboarding)
            {
               skipCutScene = Global.player.getSeenFlag(m_building.getCreditsFeatureName() + TOKEN_HAS_OFFBOARDED) || Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_SPECIAL_GIFT);
               m_window.expiretimer_mc.visible = false;
               TweenLite.delayedCall(1,this.playCutscene,[skipCutScene],true);
            }
            else if(this.m_unopenedGifts == 0)
            {
               skipCutScene = m_building.getCurrentCredits() > 0 || Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_SPECIAL_GIFT);
               TweenLite.delayedCall(1,this.playCutscene,[skipCutScene],true);
            }
            this.loadGiftArray();
            m_window.openPresents_mc.visible = true;
            this.m_unopenedText = addWidget(new ZwTextField(m_window.openPresents_mc.unopened_tf,this.m_unopenedGifts.toString()),true) as ZwTextField;
            this.m_openedText = addWidget(new ZwTextField(m_window.openPresents_mc.giftbox_tf,"0"),true) as ZwTextField;
            addWidget(new ZwTextField(m_window.openPresents_mc.instructions_tf,"Move mouse over\rGifts to open"),true);
            this.m_openAllButton = addWidget(new FarmAnimatedTextButton(m_window.openPresents_mc.open_bt,"Open all gifts",this.onOpenAll),false) as FarmAnimatedTextButton;
            this.updateGiftCounters();
            if(this.hasFilledMeter())
            {
               this.m_goldGift.element.play();
               this.m_goldGift.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",m_building.getCreditsFeatureName() + "_GoldGift")));
            }
            else
            {
               this.m_buyAllButton.visible = true;
            }
            this.awardSpecialGifts();
         }
         else
         {
            addWidget(new ZwTextField(m_window.description_tf,"Fill your holiday tree with over 300 gifts!"),true);
            addWidget(new ZwWidget(m_window.sign_mc),true);
            addWidget(new ZwTextField(m_window.meter_mc.numberOfGifts_tf,"Number\rof Gifts"));
            m_window.tag_mc.visible = true;
            this.m_buyAllButton.visible = true;
            if(this.m_building.isAtFeatureCreditLimit())
            {
               m_buyButton.enabled = false;
               m_askForButton.enabled = false;
            }
         }
         if(this.m_buyAllButton.visible)
         {
            this.m_farmCashText = addWidget(new ZwTextField(m_window.buy_bt.cost_tf),true) as ZwTextField;
            this.m_farmCashText.text = String(this.getAmountToMax());
            if(this.hasFilledMeter())
            {
               this.m_buyAllButton.enabled = false;
            }
         }
         if(this.hasFilledMeter())
         {
            m_window.goldGift_mc.lock_mc.visible = false;
         }
         this.setupAllGifts(m_window["decorationStage" + m_currentMeterState + "_mc"]);
      }
      
      private function loadGiftArray() : void
      {
         var index:int = 0;
         if(this.m_giftsRemainingArray == null)
         {
            this.m_giftsRemainingArray = new Array();
         }
         var itemsToAward:Array = this.getAwardedItems(this.m_unopenedGifts,this.m_previouslyOpenedGifts);
         for(index = 0; index < this.m_unopenedGifts; index++)
         {
            this.m_giftsRemainingArray.push(itemsToAward[index]);
         }
         this.m_giftsRemainingArray.reverse();
         this.m_giftsLeftToAddToTree = this.m_giftsRemainingArray.length;
      }
      
      override public function show() : void
      {
         if(!m_currentlyShowing)
         {
            super.show();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_currentlyShowing = true;
      }
      
      private function setupGift(mc:MovieClip) : void
      {
         mc.count_tf.visible = false;
         if(!mc.defaultScale)
         {
            mc.defaultScale = mc.scaleX;
         }
         var randomScale:Number = Math.random() * mc.defaultScale / 2 + mc.defaultScale / 2;
         mc.visible = true;
         mc.alpha = 1;
         mc.scaleX = randomScale;
         mc.scaleY = randomScale;
         mc.rotation = Math.random() * 15 - Math.random() * 15;
         mc.reward_mc.visible = false;
         mc.effect_mc.visible = false;
         mc.effect_mc.scaleX = 1;
         mc.effect_mc.scaleY = 1;
         mc.image_mc.scaleX = 1;
         mc.image_mc.scaleY = 1;
         mc.image_mc.rotation = 0;
         mc.image_mc.gotoAndStop(Math.floor(Math.random() * 16 + 1));
         mc.image_mc.visible = true;
         mc.image_mc.alpha = 1;
         TweenLite.from(mc.image_mc,2,{
            "scaleX":0.2,
            "scaleY":0.2,
            "ease":Elastic.easeOut,
            "delay":Math.random() * 1,
            "alpha":0
         });
         if(this.m_giftsLeftToAddToTree > 0)
         {
            mc.addEventListener(MouseEvent.ROLL_OVER,this.onRolloverGift);
            --this.m_giftsLeftToAddToTree;
            mc.image_mc.gotoAndStop(Math.floor(Math.random() * mc.image_mc.totalFrames + 1));
         }
         else
         {
            mc.visible = false;
         }
      }
      
      private function setupAllGifts(giftContainer:MovieClip, firstTime:Boolean = true) : void
      {
         var index:int = 0;
         var gift_mc:MovieClip = null;
         for(index = 0; index < giftContainer.gifts_mc.numChildren; index++)
         {
            gift_mc = (giftContainer.gifts_mc as MovieClip).getChildAt(index) as MovieClip;
            if(gift_mc.visible == false || firstTime)
            {
               this.setupGift(gift_mc);
            }
         }
      }
      
      private function tweenAllGifts(giftContainer:MovieClip) : void
      {
         var index:int = 0;
         var gift_mc:MovieClip = null;
         for(index = 0; index < giftContainer.gifts_mc.numChildren; index++)
         {
            gift_mc = giftContainer.gifts_mc["gift" + index] as MovieClip;
            if(gift_mc.visible)
            {
               this.tweenGift(gift_mc,this.onTweenAllGiftsComplete);
            }
         }
      }
      
      private function onTweenAllGiftsComplete(gift_mc:MovieClip) : void
      {
         TweenLite.delayedCall(6,this.playCutscene);
      }
      
      private function tweenGift(gift_mc:MovieClip, callback:Function = null) : void
      {
         var giftItem:FarmItem = null;
         var friendlyName:String = null;
         var giftObject:Object = this.m_giftsRemainingArray.pop();
         if(giftObject)
         {
            gift_mc.reward_mc.gotoAndStop(giftObject.frame);
            gift_mc.parent.setChildIndex(gift_mc,gift_mc.parent.numChildren - 1);
            gift_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onRolloverGift);
            TweenLite.to(gift_mc,1.5,{
               "scaleX":gift_mc.defaultScale,
               "scaleY":gift_mc.defaultScale,
               "rotation":0,
               "ease":Elastic.easeOut
            });
            if(m_building.getCreditsFeatureName() == "holidaytreebasket2011")
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByCode(giftObject.itemCode);
            }
            else
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByName(giftObject.name);
            }
            friendlyName = giftItem.friendlyTitle;
            friendlyName = "+1 " + friendlyName;
            gift_mc.count_tf.visible = true;
            gift_mc.count_tf.text = friendlyName;
            gift_mc.reward_mc.visible = true;
            gift_mc.reward_mc.alpha = 1;
            gift_mc.reward_mc.scaleX = 1;
            gift_mc.reward_mc.scaleY = 1;
            gift_mc.reward_mc.rotation = 0;
            gift_mc.reward_mc.y = -20;
            gift_mc.effect_mc.visible = true;
            gift_mc.effect_mc.alpha = 1;
            TweenLite.from(gift_mc.effect_mc,0.5,{
               "scaleX":0.2,
               "scaleY":0.2,
               "ease":Back.easeOut
            });
            TweenLite.to(gift_mc.image_mc,1,{
               "rotation":Math.random() * 500 - Math.random() * 500,
               "scaleX":0.2,
               "scaleY":0.2,
               "alpha":0,
               "ease":Elastic.easeIn
            });
            TweenLite.delayedCall(0.2,this.hideGift,[gift_mc]);
            if(callback != null)
            {
               TweenLite.delayedCall(4,callback,[gift_mc]);
            }
         }
         else
         {
            this.hideGift(gift_mc);
            callback(gift_mc);
         }
      }
      
      private function checkGiftOpenMode() : void
      {
         var giftOpenPercentage:Number = this.m_unopenedGifts / this.m_building.getCurrentCredits();
         var newStageNum:int = 11 - Math.ceil(giftOpenPercentage * 10);
         if(newStageNum != this.m_giftOpeningStage)
         {
            this.m_giftOpeningStage = newStageNum;
            m_window.openPresents_mc.effects_mc.gotoAndStop(newStageNum);
         }
      }
      
      private function openGift(gift:MovieClip, reset:Boolean = true) : void
      {
         if(int(FeatureOptionsManager.getInstance().getFeatureOption(m_building.getCreditsFeatureName(),"opencount")) + this.m_openedGifts == 0)
         {
            FarmStatsManager.count(m_building.getCreditsFeatureName(),"Openpresent_first_time");
         }
         --this.m_unopenedGifts;
         ++this.m_openedGifts;
         this.updateGiftCounters();
         this.checkGiftOpenMode();
         if(this.m_openedGifts >= this.OPEN_ALL_GIFTS_BUTTON_COUNT)
         {
            this.m_openAllButton.visible = true;
         }
         if(reset)
         {
            this.tweenGift(gift,this.resetGift);
         }
      }
      
      private function onRolloverGift(e:MouseEvent) : void
      {
         this.openGift(e.target as MovieClip);
      }
      
      private function openAllActiveGifts(giftContainer:MovieClip) : void
      {
         var index:int = 0;
         var gift_mc:MovieClip = null;
         for(index = 0; index < giftContainer.gifts_mc.numChildren; index++)
         {
            gift_mc = giftContainer.gifts_mc["gift" + index] as MovieClip;
            if(gift_mc.visible && gift_mc.reward_mc.visible == false)
            {
               this.openGift(gift_mc,false);
            }
         }
      }
      
      private function hideGift(gift_mc:MovieClip) : void
      {
         TweenLite.to(gift_mc.effect_mc,0.5,{
            "scaleX":0.2,
            "scaleY":0.2,
            "alpha":0,
            "ease":Back.easeIn
         });
         TweenLite.to(gift_mc.reward_mc,0.5,{
            "scaleX":0.2,
            "scaleY":0.2,
            "alpha":0,
            "ease":Back.easeIn,
            "delay":1
         });
         TweenLite.to(gift_mc.count_tf,0.1,{
            "visible":0,
            "delay":1
         });
      }
      
      private function resetGift(gift_mc:MovieClip) : void
      {
         if(!this.m_openAll)
         {
            if(this.m_giftsLeftToAddToTree > 0)
            {
               this.setupGift(gift_mc);
            }
            if(this.m_unopenedGifts == 0)
            {
               this.playCutscene();
            }
         }
      }
      
      private function playCutscene(skip:Boolean = false) : void
      {
         if(this.m_cutscenePlaying == false)
         {
            FarmStatsManager.count(m_building.getCreditsFeatureName(),"Santaanimation_impressions");
            this.m_cutscenePlaying = true;
            m_window.summary_mc.visible = false;
            m_window.expiretimer_mc.visible = false;
            m_window.openPresents_mc.visible = false;
            m_window.summary_mc.visible = false;
            m_window.whatisthis_mc.visible = false;
            m_window.cutscene_mc.visible = true;
            if(skip)
            {
               m_window.cutscene_mc.addFrameScript(this.m_summaryFrame,this.loadSummaryScreen);
               m_window.cutscene_mc.gotoAndPlay(this.m_summaryFrame);
            }
            else
            {
               m_window.cutscene_mc.addFrameScript(this.m_summaryFrame - 1,this.loadSummaryScreen);
               m_window.cutscene_mc.gotoAndPlay(this.m_cutsceneFrame);
               m_window.cutscene_mc.addFrameScript(m_window.cutscene_mc.totalFrames - 1,function():void
               {
                  m_window.cutscene_mc.stop();
               });
            }
         }
      }
      
      private function hideAllTrees() : void
      {
         var index:uint = 0;
         var length:uint = 0;
         index = 1;
         length = m_building.stateChangeLevels.length;
         while(index <= length)
         {
            m_window["decorationStage" + index + "_mc"].visible = false;
            index++;
         }
      }
      
      private function removeEventListenersFromTree(giftContainer:MovieClip) : void
      {
         var index:int = 0;
         var gift_mc:MovieClip = null;
         if(giftContainer != null)
         {
            for(index = 0; index < giftContainer.numChildren; index++)
            {
               gift_mc = giftContainer.gifts_mc["gift" + index] as MovieClip;
               if(gift_mc != null)
               {
                  if(gift_mc.hasEventListener(MouseEvent.ROLL_OVER))
                  {
                     gift_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onRolloverGift);
                  }
                  TweenLite.killTweensOf(gift_mc);
               }
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         var index:uint = 0;
         var length:uint = 0;
         index = 1;
         length = m_building.stateChangeLevels.length;
         while(index <= length)
         {
            this.removeEventListenersFromTree(m_window["decorationStage" + index + "_mc"]);
            index++;
         }
      }
      
      override protected function updateMeterImage() : Boolean
      {
         var stateChangeLevel:Number = NaN;
         var toReturn:Boolean = false;
         if(m_window)
         {
            stateChangeLevel = this.m_building.getLevelStateChange();
            if(stateChangeLevel + 1 > m_currentMeterState)
            {
               m_currentMeterState = stateChangeLevel + 1;
               this.hideAllTrees();
               this.setupAllGifts(m_window["decorationStage" + m_currentMeterState + "_mc"]);
               m_window["decorationStage" + m_currentMeterState + "_mc"].visible = true;
               toReturn = true;
            }
         }
         if(this.m_farmCashText != null)
         {
            this.m_farmCashText.text = String(this.getAmountToMax());
         }
         return toReturn;
      }
      
      override public function close() : void
      {
         m_currentlyShowing = false;
         if(m_window)
         {
            m_window.cutscene_mc.stop();
         }
         TweenLite.killDelayedCallsTo(this.loadSummaryScreen);
         TweenLite.killDelayedCallsTo(this.hideGift);
         TweenLite.killDelayedCallsTo(this.onTweenAllGiftsComplete);
         TweenLite.killDelayedCallsTo(this.playCutscene);
         if(Boolean(this.m_openGiftMode) && Boolean(this.m_openedGifts) && !this.m_openAll)
         {
            TransactionManager.addTransaction(new TAwardHolidayGifts(this.m_building,this.m_openedGifts,this.onOpenGiftsCallback),true);
            this.awardGifts(this.m_openedGifts,this.m_previouslyOpenedGifts);
         }
         var totalOpenedGifts:int = m_building.getCurrentCredits() - this.m_unopenedGifts;
         FeatureOptionsManager.getInstance().setFeatureOption(m_building.getCreditsFeatureName(),"opencount",Object(totalOpenedGifts));
         super.close();
      }
      
      override protected function buildBuyAskForButtons() : void
      {
         if(!this.m_openGiftMode)
         {
            super.buildBuyAskForButtons();
         }
      }
      
      private function openAllPresents() : void
      {
         var numGifts:uint = uint(this.m_unopenedGifts);
         if(numGifts > 0)
         {
            this.m_openedGifts += numGifts;
            this.m_unopenedGifts = 0;
            this.updateGiftCounters();
            m_window.openPresents_mc.effects_mc.gotoAndPlay(11);
            FarmStatsManager.count(m_building.getCreditsFeatureName(),"Openallpresents_clicks");
            TransactionManager.addTransaction(new TAwardHolidayGifts(this.m_building,this.m_openedGifts,this.onOpenGiftsCallback),true);
            this.awardGifts(this.m_openedGifts,this.m_previouslyOpenedGifts);
            this.tweenAllGifts(m_window["decorationStage" + m_currentMeterState + "_mc"]);
            this.m_openAllButton.enabled = false;
            this.m_openAll = true;
         }
      }
      
      private function onOpenAll(event:Event) : void
      {
         this.openAllPresents();
      }
      
      private function onBuyAll(event:Event) : void
      {
         var rewardCreditNames:Array = Global.storageSettings.getStorageItems(m_buildingClassName.toLowerCase());
         var numCreditsToBuy:int = this.getMeterMaxCredits() - m_building.getCurrentCredits();
         if(numCreditsToBuy > 0)
         {
            m_creditsToBuy = Global.farmGameSettingsManager.getFarmItemByName(rewardCreditNames[0].name + "_1pack");
            if(Global.player.canBuyCash(m_creditsToBuy.cash * numCreditsToBuy,false))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(m_creditsToBuy.name,false,true,true,numCreditsToBuy),false);
               if(this.m_openGiftMode && this.updateMeterImage())
               {
                  this.openAllActiveGifts(m_window["decorationStage" + m_currentMeterState + "_mc"]);
               }
               this.refreshCreditsMeterAndText();
               this.showBuyCheckMark();
               this.m_unopenedGifts += numCreditsToBuy;
               this.m_goldGift.element.lock_mc.visible = false;
               FarmStatsManager.count(m_building.getCreditsFeatureName(),"complete_now","click");
               if(this.m_openGiftMode)
               {
                  this.loadGiftArray();
                  this.setupAllGifts(m_window["decorationStage" + m_currentMeterState + "_mc"],false);
                  this.awardSpecialGifts();
                  this.m_goldGift.element.play();
                  this.updateGiftCounters();
               }
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",m_creditsToBuy.cash);
            }
         }
         this.m_buyAllButton.enabled = false;
      }
      
      private function updateGiftCounters() : void
      {
         this.m_unopenedText.text = this.m_unopenedGifts.toString();
         this.m_openedText.text = this.m_openedGifts.toString();
      }
      
      private function setupGiftOpeningTimer() : void
      {
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_building.getCreditsFeatureName());
         var openDate:String = rawXML.elements("giftOpen").toString();
         var time:Number = FarmGameUtil.synchronizedDateToNumber(openDate) / 1000;
         var timeLeft:String = FarmGameUtil.getTimeLeftText(time);
         var expire:ZwFrame = addWidget(new ZwFrame(m_window.expiretimer_mc)) as ZwFrame;
         expire.addWidget(new ZwTextField(m_window.expiretimer_mc.timer_tf,timeLeft));
         expire.addWidget(new ZwTextField(m_window.expiretimer_mc.timerlabel_tf,"Only"));
      }
      
      override protected function setupTimer() : void
      {
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_building.getCreditsFeatureName());
         var offBoard:Array = this.m_building.getOffBoardingData();
         var openDate:String = rawXML.elements("giftOpen").toString();
         var time:Number = FarmGameUtil.synchronizedDateToNumber(openDate) / 1000;
         var timeLeft:Number = (time - GlobalEngine.serverTime / 1000) / 3600;
         if(timeLeft >= 0 && timeLeft <= 24 || !setupPreOffBoarding(offBoard))
         {
            this.setupGiftOpeningTimer();
         }
      }
      
      override protected function release() : void
      {
         this.removeEventListeners();
         super.release();
         this.m_giftsRemainingArray = null;
         this.m_openAllButton = null;
         this.m_buyAllButton = null;
         this.m_goldGift = null;
         this.m_unopenedText = null;
         this.m_openedText = null;
         this.m_farmCashText = null;
         this.m_configuration = null;
      }
      
      private function getLootArray(rawList:XMLList, type:String) : Array
      {
         var index:uint = 0;
         var length:uint = 0;
         var lootObject:Object = null;
         var toReturn:Array = new Array();
         index = 0;
         length = uint(rawList.length());
         while(index < length)
         {
            lootObject = this.createLootObjectFromXML(rawList[index] as XML);
            lootObject.awarded = 0;
            toReturn.push(lootObject);
            index++;
         }
         return toReturn;
      }
      
      private function createLootObjectFromXML(xmlItem:XML) : Object
      {
         var lootObject:Object = new Object();
         lootObject.itemCode = xmlItem.attribute("itemCode").toString();
         lootObject.frame = int(xmlItem.attribute("frame").toString());
         lootObject.max = int(xmlItem.attribute("max").toString());
         lootObject.name = xmlItem.attribute("name").toString();
         lootObject.awarded = 0;
         return lootObject;
      }
      
      private function getFinalLootArray() : Array
      {
         var index:uint = 0;
         var length:uint = 0;
         var rawList:XMLList = null;
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_building.getCreditsFeatureName());
         var order:String = rawXML.elements("order").toString();
         var orderArray:Array = order.split(" ");
         var rawDictionary:Dictionary = new Dictionary();
         var finalOrderedLootArray:Array = new Array();
         index = 0;
         length = orderArray.length;
         while(index < length)
         {
            if(!rawDictionary[orderArray[index]])
            {
               rawList = rawXML.descendants(orderArray[index]);
               rawDictionary[orderArray[index]] = this.getLootArray(rawList,orderArray[index]);
            }
            finalOrderedLootArray.push(rawDictionary[orderArray[index]]);
            index++;
         }
         return finalOrderedLootArray;
      }
      
      private function getFeedItems() : Dictionary
      {
         var index:int = 0;
         var length:int = 0;
         var giftNumber:int = 0;
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_building.getCreditsFeatureName());
         var feedTest:XMLList = rawXML.child("feedGift");
         var feedGiftsXMLList:XMLList = rawXML.elements("feedGift");
         var toReturn:Dictionary = new Dictionary();
         index = 0;
         length = feedGiftsXMLList.length();
         while(index < length)
         {
            giftNumber = int((feedGiftsXMLList[index] as XML).attribute("giftNumber").toString());
            toReturn[giftNumber] = this.createLootObjectFromXML(feedGiftsXMLList[index] as XML);
            index++;
         }
         return toReturn;
      }
      
      private function getAwardedItems(toAward:int, alreadyAwarded:int = 0) : Array
      {
         var index:int = 0;
         var singleTypeArray:Array = null;
         var itemIndex:int = 0;
         var singleGift:Object = null;
         var add:Boolean = false;
         var totalItemCount:int = toAward + alreadyAwarded;
         var awardedItems:Array = new Array();
         var indexDictionary:Dictionary = new Dictionary();
         var numCycles:int = 0;
         var finalLootArray:Array = this.getFinalLootArray();
         var finalLootArrayLength:uint = finalLootArray.length;
         for(index = 0; index < finalLootArrayLength; index++)
         {
            singleTypeArray = finalLootArray[index];
            indexDictionary[singleTypeArray] = 0;
         }
         var feedItems:Dictionary = this.getFeedItems();
         var awarded:int = 0;
         var loopCounter:int = 0;
         for(index = 0; awarded < totalItemCount; index++)
         {
            singleTypeArray = finalLootArray[index % finalLootArrayLength];
            itemIndex = int(indexDictionary[singleTypeArray]);
            add = true;
            while(singleTypeArray[itemIndex].awarded >= singleTypeArray[itemIndex].max)
            {
               itemIndex = (itemIndex + 1) % singleTypeArray.length;
               if(itemIndex == indexDictionary[singleTypeArray])
               {
                  add = false;
                  break;
               }
            }
            if(feedItems[awarded + 1])
            {
               if(awarded >= alreadyAwarded)
               {
                  awardedItems.push(feedItems[awarded + 1]);
               }
               awarded++;
            }
            if(add)
            {
               loopCounter = 0;
               if(Boolean(singleTypeArray[itemIndex].name) && Boolean(singleTypeArray[itemIndex].itemCode) && Boolean(singleTypeArray[itemIndex].frame))
               {
                  if(awarded >= alreadyAwarded)
                  {
                     singleGift = new Object();
                     singleGift.name = singleTypeArray[itemIndex].name;
                     singleGift.itemCode = singleTypeArray[itemIndex].itemCode;
                     singleGift.frame = singleTypeArray[itemIndex].frame;
                     awardedItems.push(singleGift);
                  }
                  awarded++;
               }
               ++singleTypeArray[itemIndex].awarded;
               indexDictionary[singleTypeArray] = (itemIndex + 1) % singleTypeArray.length;
            }
            if(++loopCounter > 100)
            {
               break;
            }
         }
         return awardedItems;
      }
      
      private function awardSpecialGifts() : void
      {
         var openedGifts:uint = 0;
         var numGifts:uint = 0;
         if(this.m_configuration.isFeatureVisible())
         {
            if(!Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_SPECIAL_GIFT) || !Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_GOLD_GIFT) || !Global.player.getSeenFlag(m_building.getCreditsFeatureName() + TOKEN_HAS_OFFBOARDED))
            {
               TransactionManager.addTransaction(new THolidayTreeAwardGifts(m_building));
               if(!Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_SPECIAL_GIFT))
               {
                  Global.player.setSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_SPECIAL_GIFT);
               }
               if(!Global.player.getSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_GOLD_GIFT) && this.hasFilledMeter())
               {
                  Global.player.setSeenFlag(m_building.getCreditsFeatureName() + this.TOKEN_AWARDED_GOLD_GIFT);
               }
               if(this.m_isOffboarding && !Global.player.getSeenFlag(m_building.getCreditsFeatureName() + TOKEN_HAS_OFFBOARDED))
               {
                  Global.player.setSeenFlag(m_building.getCreditsFeatureName() + TOKEN_HAS_OFFBOARDED);
                  openedGifts = uint(int(FeatureOptionsManager.getInstance().getFeatureOption(m_building.getCreditsFeatureName(),"opencount")));
                  numGifts = m_building.getCurrentCredits() - openedGifts;
                  this.awardGifts(numGifts,openedGifts);
                  FeatureOptionsManager.getInstance().setFeatureOption(m_building.getCreditsFeatureName(),"opencount",Object(m_building.getCurrentCredits()));
               }
            }
         }
      }
      
      private function awardGifts(numGifts:int, giftsAlreadyAwarded:int) : void
      {
         var awardedItems:Array = this.getAwardedItems(numGifts,giftsAlreadyAwarded);
         this.addGiftsToGiftBox(awardedItems);
      }
      
      private function addGiftsToGiftBox(gifts:Array) : void
      {
         var index:uint = 0;
         var length:uint = 0;
         index = 0;
         length = gifts.length;
         while(index < length)
         {
            if(m_building.getCreditsFeatureName() == "holidaytreebasket2011")
            {
               this.addGiftToGiftBox(gifts[index].itemCode);
            }
            else
            {
               Global.player.addGift(gifts[index].name,"0",1);
            }
            index++;
         }
      }
      
      private function addGiftToGiftBox(itemCode:String) : void
      {
         var giftName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         Global.player.addGift(giftName,"0",1);
      }
      
      protected function showOpenGiftFeedPrompt() : void
      {
         var farmItem:FarmItem = null;
         var message:String = null;
         var popup:GenericIconPopup = null;
         if(this.m_latestReward != null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_latestReward);
            message = ZLocUtils.t("Dialogs",m_building.getCreditsFeatureName() + TOKEN_OPEN_GIFT);
            popup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,farmItem.icon);
            UI.displayPopup(popup,false);
            FarmStatsManager.count("dialog",m_building.getCreditsFeatureName() + "-" + TOKEN_UNWRAP,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
      }
      
      private function onOpenGiftsCallback(result:Object) : void
      {
         if(result != null && Boolean(result.rewardUrl))
         {
            this.m_latestReward = result.rewardCode;
            this.m_rewardLink = result.rewardUrl;
            this.showOpenGiftFeedPrompt();
         }
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var farmItem:FarmItem = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT && this.m_latestReward != null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_latestReward);
            bundleData = {
               "reward_link":this.m_rewardLink,
               "rewardItem":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
               "prize":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardLink,
                  "src":farmItem.icon
               }]
            };
            FarmStatsManager.count("dialog",m_building.getCreditsFeatureName() + "-" + TOKEN_UNWRAP,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            GlobalEngine.socialNetwork.publishFeedStory(m_building.getCreditsFeatureName() + TOKEN_OPEN_GIFT,bundleData,[],false);
         }
         else
         {
            FarmStatsManager.count("dialog",m_building.getCreditsFeatureName() + "-" + TOKEN_UNWRAP,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
         }
      }
      
      protected function hasFilledMeter() : Boolean
      {
         return m_building.getCurrentCredits() >= this.getMeterMaxCredits();
      }
      
      protected function getAmountToMax() : int
      {
         return Math.max(0,this.getMeterMaxCredits() - m_building.getCurrentCredits());
      }
      
      private function addPegacornRollover() : void
      {
         var pegacornFrame:ZwFrame = null;
         if(m_window.cutscene_mc.pegacorn_mc)
         {
            pegacornFrame = addWidget(new ZwFrame(m_window.cutscene_mc.pegacorn_mc)) as ZwFrame;
            pegacornFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",m_building.getCreditsFeatureName() + "_Pegacorn")));
         }
      }
      
      private function loadSummaryScreen() : void
      {
         var index:uint = 0;
         var length:uint = 0;
         var itemSlot:SummaryItemSlot = null;
         var itemFrame:uint = 0;
         var goldGift:ZwFrame = null;
         if(m_building.getCreditsFeatureName() == "holidaytreebasket2011")
         {
            m_window.cutscene_mc.addFrameScript(this.SUMMARY_SCRIPT_FRAME,null);
            m_window.cutscene_mc.gotoAndPlay(this.m_summaryFrame);
         }
         var summary_mc:MovieClip = m_window.summary_mc;
         this.hideAllTrees();
         m_window.openPresents_mc.visible = false;
         summary_mc.goldGift_mc.lock_mc.visible = false;
         m_window.meter_mc.visible = false;
         summary_mc.visible = true;
         FarmStatsManager.count(m_building.getCreditsFeatureName(),"Summaryscreen_impressions");
         if(this.hasFilledMeter())
         {
            removeWidget(m_window.goldGift_mc);
            goldGift = addWidget(new ZwFrame(summary_mc.goldGift_mc)) as ZwFrame;
            goldGift.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",m_building.getCreditsFeatureName() + "_GoldGift")));
            goldGift.element.play();
         }
         else
         {
            summary_mc.goldGift_mc.visible = false;
         }
         index = 0;
         length = uint(this.MAX_UNIQUE_ITEMS);
         while(index < length)
         {
            summary_mc["gift" + index].visible = false;
            index++;
         }
         var totalAwardedItems:Array = this.getAwardedItems(m_building.getCurrentCredits(),0);
         var itemSlots:Dictionary = new Dictionary();
         var uniqueItemCounter:uint = 0;
         index = 0;
         length = totalAwardedItems.length;
         while(index < length)
         {
            itemFrame = uint(totalAwardedItems[index].frame);
            itemSlot = itemSlots[itemFrame];
            if(itemSlot)
            {
               itemSlot.incrementQuantity();
            }
            else
            {
               if(m_building.getCreditsFeatureName() == "holidaytreebasket2011")
               {
                  itemSlot = addWidget(new SummaryItemSlot(summary_mc["gift" + uniqueItemCounter],itemFrame,totalAwardedItems[index].itemCode,"code")) as SummaryItemSlot;
               }
               else
               {
                  itemSlot = addWidget(new SummaryItemSlot(summary_mc["gift" + uniqueItemCounter],itemFrame,totalAwardedItems[index].name,"name")) as SummaryItemSlot;
               }
               itemSlots[itemFrame] = itemSlot;
               uniqueItemCounter++;
            }
            index++;
         }
      }
   }
}

import com.greensock.plugins.FramePlugin;
import com.greensock.plugins.TweenPlugin;

TweenPlugin.activate([FramePlugin]);

