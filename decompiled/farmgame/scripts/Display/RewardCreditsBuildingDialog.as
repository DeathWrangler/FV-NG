package Display
{
   import Classes.Constants.MFSConstants;
   import Classes.CreditCostInfo;
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TRedeemCreditsItem;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class RewardCreditsBuildingDialog extends SlotDialog
   {
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      protected static const PROGRESS_BT:String = "ProgressBt";
      
      protected static const COMPARISON_BT:String = "ComparisonBt";
      
      private static const HOW_DOES_THIS_WORK_BT:String = "howDoesThisWorkBt";
      
      private static const ASK_FOR_CREDITS_BT:String = "askForBt";
      
      private static const REDEEM_BT:String = "redeemBt";
      
      private static const WHAT_IS_THIS_BT:String = "whatBt";
      
      private static const ASK_FOR_CREDITS_SHEEN_INTERVAL_MS:uint = 5000;
      
      private static const ANIMATE_METER_INTERVAL_MS:uint = 60;
      
      private static const LOCKED_ITEM_REDEEM_BUTTON_FRAME:uint = 4;
      
      private static const LEADERBOARD_SLOT_ICON_HEIGHT:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_WIDTH:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_X:Number = 1;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_Y:Number = 1;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_WIDTH:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X:Number = 1.5;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y:Number = 2;
      
      protected static const MODE_PROGRESS:uint = 0;
      
      protected static const MODE_COMPARISON:uint = 1;
      
      private static const NUM_METER_ANIM_FRAMES:uint = 17;
      
      private static const CENTER_ICON_VERTICAL_DISPLACE:Number = -50;
      
      private static const ALLOW_REDEEM_ITEM_ON_LOAD:Boolean = false;
      
      private const NUM_PROGRESS_SLOTS:int = 6;
      
      private const NUM_COMPARISON_SLOTS:int = 3;
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_buildingClassName:String;
      
      protected var m_currentMode:uint = 0;
      
      protected var m_howDoesThisWorkPopup:Dialog = null;
      
      protected var m_buttons:Object = new Object();
      
      protected var m_currentCredits:uint = 0;
      
      protected var m_totalCreditsReceived:uint = 0;
      
      private var m_creditsMeterBarFullHeight:Number = 0;
      
      private var m_showWhatIsThisDialogOnLoad:Boolean = false;
      
      private var m_showRedeemableItemOnLoad:Object = null;
      
      private var m_friends:Array = new Array();
      
      private var m_friendsRanking:uint = 0;
      
      private var m_levelTitles:Array = new Array();
      
      private var m_askForCreditsSheenTimer:Timer = null;
      
      private var m_animateMeterTimer:Timer = null;
      
      private var m_currentMeterFrame:uint = 1;
      
      private var m_maxMeterFrame:uint = 1;
      
      private var m_redeemItemIndex:Number = 0;
      
      private var m_creditFriendlyName:String;
      
      private var m_alwaysUnlock:Boolean = false;
      
      private var m_itemToBuyCostInfo:CreditCostInfo;
      
      public function RewardCreditsBuildingDialog(building:RewardCreditsBuilding, buildingClassName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, alwaysUnlock:Boolean = false, showRedeemableItemOnLoad:Object = null)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_buildingClassName = buildingClassName;
         this.m_showWhatIsThisDialogOnLoad = showWhatIsThisOnLoad;
         this.m_showRedeemableItemOnLoad = showRedeemableItemOnLoad;
         if(!ALLOW_REDEEM_ITEM_ON_LOAD)
         {
            this.m_showRedeemableItemOnLoad = false;
         }
         m_dialogAsset = dialogAssetUrl;
         this.m_currentCredits = this.m_rewardCreditsBuilding.getCurrentCredits();
         this.m_totalCreditsReceived = this.m_rewardCreditsBuilding.getTotalCreditsReceived();
         this.m_askForCreditsSheenTimer = new Timer(ASK_FOR_CREDITS_SHEEN_INTERVAL_MS);
         this.m_animateMeterTimer = new Timer(ANIMATE_METER_INTERVAL_MS);
         this.m_alwaysUnlock = alwaysUnlock;
         if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Item"))
         {
            this.m_creditFriendlyName = LOC_BUNDLE + ":" + this.m_buildingClassName + "_Item";
         }
         super();
      }
      
      override protected function onLoadComplete() : void
      {
         var itemIndex:Number = NaN;
         super.onLoadComplete();
         this.addEventListeners();
         this.populateLevelTitles();
         this.setupStaticUI();
         this.setupButtons();
         this.setupCreditMeter();
         this.setupLeaderboard();
         this.switchMode(this.getDefaultMode());
         if(this.m_showRedeemableItemOnLoad)
         {
            itemIndex = this.getItemIndexByName(this.m_showRedeemableItemOnLoad.name);
            if(itemIndex >= 0)
            {
               this.openAreYouSureRedeemDialog(itemIndex);
            }
         }
         else if(this.m_showWhatIsThisDialogOnLoad)
         {
            this.onHowDoesThisWorkClick();
         }
      }
      
      override protected function getNumSlots() : int
      {
         var numSlots:int = 0;
         if(this.m_currentMode == MODE_PROGRESS)
         {
            numSlots = this.NUM_PROGRESS_SLOTS;
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            numSlots = this.NUM_COMPARISON_SLOTS;
         }
         return numSlots;
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         if(Boolean(m_tiles && m_tiles[compId]) && Boolean(m_data) && Boolean(m_data[index + compId]))
         {
            if(this.m_currentMode == MODE_PROGRESS)
            {
               this.addProgressComponent(compId,index);
            }
            else if(this.m_currentMode == MODE_COMPARISON)
            {
               this.addComparisonComponent(compId,index);
            }
         }
      }
      
      private function addProgressComponent(compId:int, index:int) : void
      {
         var redeemButtonIndex:String = null;
         var whatButton:GenericButton = null;
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var redeemItemData:Object = m_data[index + compId];
         var alwaysUnlock:Boolean = this.m_alwaysUnlock;
         if(Boolean(redeemItemData.cost) && Boolean(!redeemItemData.locked) || alwaysUnlock)
         {
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_ItemCost") || !this.m_creditFriendlyName)
            {
               mc.costs_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_ItemCost",{"quantity":redeemItemData.cost["feature"]});
            }
            else
            {
               mc.costs_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_ItemCost",{
                  "quantity":redeemItemData.cost["feature"],
                  "item":ZLocUtils.tk_pk(this.m_creditFriendlyName,"",redeemItemData.cost)
               });
            }
         }
         else if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_ComingSoon"))
         {
            mc.costs_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_ComingSoon");
         }
         else
         {
            mc.costs_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_ComingSoon");
         }
         mc.costs_tf.visible = true;
         if(redeemItemData.cost["feature"] <= this.m_totalCreditsReceived && !redeemItemData.locked || alwaysUnlock)
         {
            redeemButtonIndex = REDEEM_BT + compId;
            if(!this.m_buttons[redeemButtonIndex])
            {
               this.m_buttons[redeemButtonIndex] = new GenericButton(mc.redeem_bt,this.onRedeem);
               if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Redeem"))
               {
                  this.m_buttons[redeemButtonIndex].text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Redeem");
               }
               else
               {
                  this.m_buttons[redeemButtonIndex].text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Redeem");
               }
            }
         }
         else
         {
            mc.redeem_bt.gotoAndStop(LOCKED_ITEM_REDEEM_BUTTON_FRAME);
         }
         if(mc.redeemGray_bt)
         {
            mc.redeemGray_bt.visible = false;
            mc.redeemGray_bt.enabled = false;
         }
         var showItemInfo:Boolean = Boolean(redeemItemData.showInfo) && !redeemItemData.locked || alwaysUnlock;
         if(mc.whatisthis_mc)
         {
            if(showItemInfo && Boolean(redeemItemData.hasWhatIsThis))
            {
               whatButton = new GenericButton(mc.whatisthis_mc,this.onClickWhatIsThisItem);
               whatButton.text = ZLocUtils.t("Dialogs","WhatIsThis");
               this.m_buttons[WHAT_IS_THIS_BT + compId] = whatButton;
            }
            else
            {
               mc.whatisthis_mc.visible = false;
               mc.whatisthis_mc.enabled = false;
            }
         }
         var iconItemName:String = "";
         var itemNameText:String = "";
         if(showItemInfo)
         {
            this.addItemIcon(redeemItemData.name,"icon",mc,mc.icon);
            itemNameText = ZLocUtils.tk_pk_asTitle(redeemItemData.friendlyName);
         }
         else
         {
            this.addIcon(Global.getAssetURL(this.getLockedItemIconUrl()),mc,mc.icon);
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_LockedItemName"))
            {
               itemNameText = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_LockedItemName");
            }
            else
            {
               itemNameText = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_LockedItemName");
            }
         }
         mc.itemTitle_tf.visible = true;
         mc.itemTitle_tf.text = itemNameText;
         mc.visible = true;
      }
      
      protected function getLockedItemIconUrl() : String
      {
         return "";
      }
      
      private function addComparisonComponent(compId:int, index:int) : void
      {
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var friendData:Object = m_data[index + compId];
         if(friendData.name)
         {
            mc.name_tf.text = friendData.name;
         }
         if(friendData.title)
         {
            mc.title_tf.text = friendData.title;
         }
         if(friendData.creditsReceived != null)
         {
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Score") || !this.m_creditFriendlyName)
            {
               mc.points_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Score",{"quantity":friendData.creditsReceived});
            }
            else
            {
               mc.points_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Score",{
                  "quantity":friendData.creditsReceived,
                  "creditName":ZLocUtils.tk_pk(this.m_creditFriendlyName,"",friendData.creditsReceived)
               });
            }
         }
         if(friendData.uid)
         {
            this.addProfileIcon(friendData.uid,mc,mc.icon,LEADERBOARD_SLOT_ICON_WIDTH,LEADERBOARD_SLOT_ICON_HEIGHT,LEADERBOARD_SLOT_ICON_OFFSET_X,LEADERBOARD_SLOT_ICON_OFFSET_Y);
         }
         var rankNumber:uint = index + compId + 1;
         if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_LeaderboardRank"))
         {
            mc.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_LeaderboardRank",{"rankNum":rankNumber});
         }
         else
         {
            mc.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_LeaderboardRank",{"rankNum":rankNumber});
         }
         mc.visible = true;
      }
      
      protected function pushNewData() : void
      {
         m_data = [];
         m_tileSet = 0;
         if(this.m_currentMode == MODE_PROGRESS)
         {
            this.pushNewProgressData();
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            this.pushNewComparisonData();
         }
      }
      
      private function pushNewProgressData() : void
      {
         var redeemItem:Object = null;
         var redeemItemData:Object = null;
         var canAffordData:CreditCostInfo = null;
         var redeemFarmItem:FarmItem = null;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_rewardCreditsBuilding.getCreditsFeatureName());
         var eligibleForLastItem:Boolean = true;
         var index:uint = 0;
         while(index < this.getNumSlots() && index < redeemItems.length)
         {
            redeemItem = redeemItems[index];
            redeemItemData = new Object();
            redeemItemData.locked = redeemItem.locked && redeemItem.locked == "true";
            redeemItemData.cost = redeemItem.cost;
            redeemItemData.showInfo = eligibleForLastItem;
            canAffordData = this.m_rewardCreditsBuilding.getRedeemItemCostInfo(redeemItemData.cost);
            eligibleForLastItem = canAffordData.canAfford;
            redeemFarmItem = Global.farmGameSettingsManager.getFarmItemByName(redeemItem.name);
            if(redeemFarmItem)
            {
               redeemItemData.name = redeemFarmItem.name;
               redeemItemData.friendlyName = redeemFarmItem.friendlyName;
               redeemItemData.icon = redeemFarmItem.icon;
            }
            m_data.push(redeemItemData);
            index++;
         }
      }
      
      private function pushNewComparisonData() : void
      {
         var friend:Object = null;
         var fullName:String = null;
         var featureName:String = null;
         var title:String = null;
         var friendData:Object = null;
         var friendPlayer:Friend = null;
         for(var index:int = 0; index < this.m_friends.length; index++)
         {
            friend = this.m_friends[index];
            if(friend)
            {
               fullName = "";
               if(friend.uid == Global.player.snUser.uid)
               {
                  fullName = Global.player.snUser.name;
               }
               else
               {
                  friendPlayer = Global.friendManager.getFriendData(friend.uid);
                  if(friendPlayer)
                  {
                     fullName = friendPlayer.name;
                  }
               }
               featureName = this.getCreditsFeatureName();
               title = this.getLevelTitle(friend.getFeatureCreditsReceived(featureName));
               if(title)
               {
                  title = this.quoteTitle(title);
               }
               friendData = new Object();
               friendData.name = fullName;
               friendData.creditsReceived = friend.getFeatureCreditsReceived(featureName);
               friendData.title = title;
               friendData.uid = friend.uid;
               m_data.push(friendData);
            }
         }
      }
      
      protected function onClose(event:MouseEvent = null) : void
      {
         if(this.m_howDoesThisWorkPopup)
         {
            this.m_howDoesThisWorkPopup.close();
         }
         for(var index:uint = 0; index < this.m_buttons.length; index++)
         {
            if(this.m_buttons[index])
            {
               this.m_buttons[index].turnOff();
            }
         }
         removeTiles(false);
         this.removeEventListeners();
         if(event != null)
         {
            event.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      private function addEventListeners() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         }
         if(this.m_askForCreditsSheenTimer)
         {
            this.m_askForCreditsSheenTimer.addEventListener(TimerEvent.TIMER,this.onPlayAskForCreditsSheen);
         }
         if(this.m_animateMeterTimer)
         {
            this.m_animateMeterTimer.addEventListener(TimerEvent.TIMER,this.onAnimateMeter);
         }
         m_window.leaderBoard_mc.arrowUp_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.leaderBoard_mc.arrowDown_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      private function removeEventListeners() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         }
         if(this.m_askForCreditsSheenTimer)
         {
            this.m_askForCreditsSheenTimer.removeEventListener(TimerEvent.TIMER,this.onPlayAskForCreditsSheen);
         }
         if(this.m_animateMeterTimer)
         {
            this.m_animateMeterTimer.removeEventListener(TimerEvent.TIMER,this.onAnimateMeter);
         }
         m_window.leaderBoard_mc.arrowUp_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.leaderBoard_mc.arrowDown_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      protected function setupTiles() : void
      {
         var tile:String = null;
         m_tiles = new Array();
         for(var index:uint = 0; index < this.getNumSlots(); index++)
         {
            tile = "slot_" + index;
            if(this.m_currentMode == MODE_PROGRESS)
            {
               if(m_window.progress_mc.hasOwnProperty(tile))
               {
                  m_tiles[index] = m_window.progress_mc.getChildByName(tile);
                  m_tiles[index].visible = false;
               }
            }
            else if(this.m_currentMode == MODE_COMPARISON)
            {
               if(m_window.leaderBoard_mc.hasOwnProperty(tile))
               {
                  m_tiles[index] = m_window.leaderBoard_mc.getChildByName(tile);
                  this.initializeComparisonTile(m_tiles[index]);
               }
            }
         }
      }
      
      private function initializeComparisonTile(tile:MovieClip) : void
      {
         tile.name_tf.text = "";
         tile.title_tf.text = "";
         tile.points_tf.text = "";
         tile.rank_tf.text = "";
      }
      
      protected function setupButtons() : void
      {
         var askForCreditsButton:GenericButton = null;
         var howDoesThisWorkButton:GenericButton = new GenericButton(m_window.whatisthis_mc,this.onHowDoesThisWorkClick);
         howDoesThisWorkButton.text = ZLocUtils.t(LOC_BUNDLE,"HowDoesThisWork");
         this.m_buttons[HOW_DOES_THIS_WORK_BT] = howDoesThisWorkButton;
         if(this.isAskSendEnabled())
         {
            askForCreditsButton = new GenericButton(this.getAskForCreditsButton(),this.onAskForCreditsClick);
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_AskForCredits") || !this.m_creditFriendlyName)
            {
               askForCreditsButton.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_AskForCredits");
            }
            else
            {
               askForCreditsButton.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_AskForCredits",{"creditName":ZLocUtils.tk_pk(this.m_creditFriendlyName)});
            }
            this.m_buttons[ASK_FOR_CREDITS_BT] = askForCreditsButton;
         }
         else
         {
            this.disableAskForCreditsButton();
         }
         var progressButton:GenericButton = new GenericButton(m_window.progress_bt,this.onProgressClick);
         if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Progress"))
         {
            progressButton.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Progress");
         }
         else
         {
            progressButton.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Progress");
         }
         progressButton.enableHitState(true);
         this.m_buttons[PROGRESS_BT] = progressButton;
         var comparisonButton:GenericButton = new GenericButton(m_window.comparison_bt,this.onComparisonClick);
         if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Comparison"))
         {
            comparisonButton.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Comparison");
         }
         else
         {
            comparisonButton.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Comparison");
         }
         comparisonButton.enableHitState(true);
         this.m_buttons[COMPARISON_BT] = comparisonButton;
      }
      
      protected function getAskForCreditsButton() : MovieClip
      {
         return m_window.askFor_mc;
      }
      
      protected function isAskSendEnabled() : Boolean
      {
         var disableDate:String = this.getAskSendDisableDate();
         var endTime:Number = FarmGameUtil.synchronizedDateToNumber(disableDate);
         return GlobalEngine.serverTime < endTime;
      }
      
      protected function getAskSendDisableDate() : String
      {
         return "";
      }
      
      protected function disableAskForCreditsButton() : void
      {
         if(m_window.askFor_mc)
         {
            m_window.askFor_mc.visible = false;
            m_window.askFor_mc.enabled = false;
         }
         if(m_window.askForExtras_mc)
         {
            m_window.askForExtras_mc.visible = false;
         }
         if(m_window.sheen_mc)
         {
            m_window.sheen_mc.visible = false;
         }
      }
      
      private function setupStaticUI() : void
      {
         m_window.title_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Title");
         this.m_askForCreditsSheenTimer.start();
         this.m_animateMeterTimer.start();
      }
      
      protected function setupCreditMeter() : void
      {
         var buildingImage:MovieClip = null;
         var creditMeter:MovieClip = this.getCreditMeter();
         if(creditMeter)
         {
            this.setupCreditMeterIntervals(creditMeter);
            this.setupCreditsText();
            buildingImage = this.getBuidingStateImage();
            if(buildingImage)
            {
               buildingImage.gotoAndStop(this.getLevelNumber(this.m_totalCreditsReceived));
            }
         }
      }
      
      protected function setupCreditMeterIntervals(creditMeter:MovieClip) : void
      {
         var incrementTextFieldName:String = null;
         var increment_tf:TextField = null;
         var levels:Array = this.m_rewardCreditsBuilding.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            incrementTextFieldName = "increment" + (index + 1) + "_tf";
            if(creditMeter.hasOwnProperty(incrementTextFieldName))
            {
               increment_tf = creditMeter.getChildByName(incrementTextFieldName) as TextField;
               increment_tf.text = levels[index];
            }
         }
      }
      
      protected function setupCreditsText() : void
      {
         var creditMeter:MovieClip = this.getCreditMeter();
         if(creditMeter)
         {
            if(creditMeter.spendAmount_tf)
            {
               creditMeter.spendAmount_tf.text = this.m_currentCredits.toString();
            }
            if(creditMeter.receivedAmount_tf)
            {
               creditMeter.receivedAmount_tf.text = this.m_totalCreditsReceived.toString();
            }
            if(creditMeter.spendLabel_tf)
            {
               if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_NumCreditsLabel") || !this.m_creditFriendlyName)
               {
                  creditMeter.spendLabel_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_NumCreditsLabel");
               }
               else
               {
                  creditMeter.spendLabel_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_NumCreditsLabel",{"creditName":ZLocUtils.tk_pk(this.m_creditFriendlyName)});
               }
            }
            if(creditMeter.receivedLabel_tf)
            {
               if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_TotalCreditsReceivedLabel") || !this.m_creditFriendlyName)
               {
                  creditMeter.receivedLabel_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_TotalCreditsReceivedLabel");
               }
               else
               {
                  creditMeter.receivedLabel_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_TotalCreditsReceivedLabel",{"creditName":ZLocUtils.tk_pk(this.m_creditFriendlyName)});
               }
            }
         }
      }
      
      protected function getCreditMeter() : MovieClip
      {
         return m_window.progress_mc.meter_mc as MovieClip;
      }
      
      protected function getMeterStack() : MovieClip
      {
         return m_window.progress_mc.meter_mc.stack_mc as MovieClip;
      }
      
      protected function getBuidingStateImage() : MovieClip
      {
         return null;
      }
      
      protected function addItemIcon(itemName:String, imageName:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var url:String = Global.farmGameSettingsManager.getImageByName(itemName,imageName);
         this.addIcon(url,tile,movieClip,width,height,offsetX,offsetY);
      }
      
      private function addProfileIcon(uid:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var friend:Friend = null;
         var iconUrl:String = "";
         if(uid == Global.player.snUser.uid.toString())
         {
            iconUrl = Global.player.snUser.picture;
         }
         else
         {
            friend = Global.friendManager.getFriendData(uid);
            if(friend)
            {
               iconUrl = friend.picture;
            }
         }
         var defaultIcon:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
         this.addIcon(iconUrl,tile,movieClip,width,height,offsetX,offsetY,defaultIcon);
      }
      
      private function addIcon(url:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0, defaultIcon:DisplayObject = null) : void
      {
         var icon:Loader = null;
         if(url)
         {
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = null;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  if(tile)
                  {
                     Utilities.removeAllChildren(movieClip);
                  }
                  dispObj.width = width;
                  dispObj.height = height;
                  dispObj.x += offsetX;
                  dispObj.y += offsetY;
                  movieClip.addChild(dispObj);
               }
            });
         }
         else if(defaultIcon)
         {
            defaultIcon.width = width;
            defaultIcon.height = height;
            defaultIcon.x += offsetX;
            defaultIcon.y += offsetY;
            movieClip.addChild(defaultIcon);
         }
      }
      
      protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var imageSize:Number = NaN;
         if(!this.m_howDoesThisWorkPopup)
         {
            imageSize = 100;
            this.m_howDoesThisWorkPopup = new GenericXMLDialog("","",null,this.m_rewardCreditsBuilding.getHowDoesThisWorkImageRelUrl(),imageSize,imageSize,ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_HowDoesThisWork"),this.onHowDoesThisWorkClose,false,ZLocUtils.t("Dialogs","Accept"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(this.m_howDoesThisWorkPopup,false,this.m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      private function onAskForCreditsClick(event:Event) : void
      {
         MFSRequestManager.getInstance().makeAskCreditsRequest(this.getAskForCreditsFeatureName(),MFSConstants.SOURCE_DIALOG_CLICKED,this.getAskForCreditsCounter(),this.getAskForCreditsCounterKingdom(),"accept");
      }
      
      protected function getDialogSideIconUrl() : String
      {
         return "";
      }
      
      protected function getAskForCreditsFeatureName() : String
      {
         return "";
      }
      
      protected function getAskForCreditsUrl() : String
      {
         return "";
      }
      
      protected function getAskForCreditsCounter() : String
      {
         return "RewardCreditsBuilding";
      }
      
      protected function getAskForCreditsCounterKingdom() : String
      {
         return "AskForCredits";
      }
      
      private function onProgressClick(event:Event) : void
      {
         this.switchMode(MODE_PROGRESS);
      }
      
      private function onComparisonClick(event:Event) : void
      {
         this.switchMode(MODE_COMPARISON);
      }
      
      protected function getDefaultMode() : uint
      {
         return MODE_PROGRESS;
      }
      
      protected function switchMode(mode:uint) : void
      {
         this.m_currentMode = mode;
         this.setupTiles();
         this.pushNewData();
         addAllComponents(0);
         this.adjustFrameAppearance();
      }
      
      protected function adjustFrameAppearance() : void
      {
         var progressButton:GenericButton = this.m_buttons[PROGRESS_BT] as GenericButton;
         var comparisonButton:GenericButton = this.m_buttons[COMPARISON_BT] as GenericButton;
         if(this.m_currentMode == MODE_PROGRESS)
         {
            FarmStatsManager.count(this.m_buildingClassName,"open_rewards");
            this.setProgressVisibility(true);
            this.setComparisonVisibility(false);
            progressButton.state = GenericButton.HITSTATE;
            comparisonButton.state = GenericButton.UPSTATE;
            this.refreshCreditMeter();
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            FarmStatsManager.count(this.m_buildingClassName,"open_comparison");
            this.setProgressVisibility(false);
            this.setComparisonVisibility(true);
            progressButton.state = GenericButton.UPSTATE;
            comparisonButton.state = GenericButton.HITSTATE;
            this.fixArrows();
         }
      }
      
      protected function setProgressVisibility(isVisible:Boolean) : void
      {
         m_window.progress_mc.visible = isVisible;
      }
      
      protected function setComparisonVisibility(isVisible:Boolean) : void
      {
         m_window.leaderBoard_mc.visible = isVisible;
      }
      
      private function onRedeem(event:Event) : void
      {
         var index:uint = 0;
         var button:GenericButton = null;
         if(!Global.player.hasGiftBoxCapacity())
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","InventoryCellar_GiftBoxFull"),0,null,"",true);
         }
         else
         {
            for(index = 0; index < this.getNumSlots(); index++)
            {
               button = this.m_buttons[REDEEM_BT + index] as GenericButton;
               if(Boolean(button) && event.currentTarget.buttonPointer === button)
               {
                  this.openAreYouSureRedeemDialog(m_tileSet + index);
               }
            }
         }
      }
      
      private function getItemIndexByName(name:String) : Number
      {
         var res:Number = -1;
         for(var index:uint = 0; index < m_data.length; index++)
         {
            if(m_data[index].name == name)
            {
               res = index;
               break;
            }
         }
         return res;
      }
      
      private function openAreYouSureRedeemDialog(itemIndex:Number) : void
      {
         var message:String = null;
         this.m_redeemItemIndex = itemIndex;
         var redeemItemData:Object = m_data[this.m_redeemItemIndex];
         this.m_itemToBuyCostInfo = this.m_rewardCreditsBuilding.getRedeemItemCostInfo(redeemItemData.cost);
         if(this.m_itemToBuyCostInfo.canAfford)
         {
            message = ZLocUtils.t("RewardCreditsBuilding","RedeemConfirm",{
               "item":ZLocUtils.tk_pk(redeemItemData.friendlyName),
               "quantity":this.m_itemToBuyCostInfo.totalCreditCost,
               "creditword":ZLocUtils.tk("RewardCreditsBuilding","Credit_word","",this.m_itemToBuyCostInfo.totalCreditCost)
            });
         }
         else
         {
            message = ZLocUtils.t("Dialogs","RewardCredits_RedeemConfirmFarmCash",{
               "item":ZLocUtils.tk_pk(redeemItemData.friendlyName),
               "cashQuantity":this.m_itemToBuyCostInfo.costToComplete
            });
         }
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmRedeem,"",true);
      }
      
      private function onConfirmRedeem(event:GenericPopupEvent) : void
      {
         var canRedeem:Boolean = false;
         var redeemItemData:Object = null;
         var creditType:String = null;
         var transaction:TRedeemCreditsItem = null;
         var missingCredits:Object = null;
         var featureCreditName:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            canRedeem = false;
            redeemItemData = m_data[this.m_redeemItemIndex];
            if(this.m_itemToBuyCostInfo.canAfford)
            {
               canRedeem = true;
            }
            else if(Global.player.cash >= this.m_itemToBuyCostInfo.costToComplete)
            {
               canRedeem = true;
            }
            if(canRedeem)
            {
               transaction = new TRedeemCreditsItem(this.m_rewardCreditsBuilding,redeemItemData.name,this.m_itemToBuyCostInfo.totalCreditCost,false,null,this.m_itemToBuyCostInfo.costToComplete);
               transaction.setCenterIconVerticalDisplace(CENTER_ICON_VERTICAL_DISPLACE);
               TransactionManager.addTransaction(transaction,true);
               if(this.m_itemToBuyCostInfo.costToComplete)
               {
                  Global.player.cash -= this.m_itemToBuyCostInfo.costToComplete;
                  missingCredits = this.m_itemToBuyCostInfo.missingCredits;
                  for(creditType in missingCredits)
                  {
                     this.m_rewardCreditsBuilding.addCredits(missingCredits[creditType],creditType);
                  }
                  this.m_rewardCreditsBuilding.setDisplayObjectDirty(true);
                  this.m_rewardCreditsBuilding.reloadImage();
               }
               if(this.m_itemToBuyCostInfo.totalCreditCost)
               {
                  for(creditType in redeemItemData.cost)
                  {
                     featureCreditName = creditType == "feature" ? this.m_rewardCreditsBuilding.getCreditsFeatureName() : creditType;
                     this.m_rewardCreditsBuilding.useCredits(redeemItemData.cost[creditType],featureCreditName);
                  }
               }
               Global.player.addGift(redeemItemData.name);
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",this.m_itemToBuyCostInfo.totalCreditCost,redeemItemData.type);
            }
            this.onClose();
         }
      }
      
      private function onClickWhatIsThisItem(event:Event) : void
      {
         var button:GenericButton = null;
         var redeemItemData:Object = null;
         var dialog:GenericPopupTitle = null;
         for(var index:uint = 0; index < this.getNumSlots(); index++)
         {
            button = this.m_buttons[WHAT_IS_THIS_BT + index] as GenericButton;
            if(Boolean(button) && event.currentTarget.buttonPointer === button)
            {
               redeemItemData = m_data[m_tileSet + index];
               dialog = new GenericPopupTitle(redeemItemData.name + "Title",redeemItemData.name + "Message");
               dialog.setAcceptTextName("Okay");
               UI.displayPopup(dialog,false);
            }
         }
      }
      
      protected function getMeterMaxCredits() : uint
      {
         var result:uint = 0;
         var creditsXml:XML = this.getBuildingCreditsXml();
         if(creditsXml)
         {
            result = uint(creditsXml.@meterMaxCredits);
         }
         return result;
      }
      
      protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_buildingClassName);
      }
      
      protected function refreshCreditMeter() : void
      {
         this.refreshMeterTitle();
         this.animateMeter();
      }
      
      protected function refreshMeterTitle() : void
      {
         var creditMeter:MovieClip = this.getCreditMeter();
         if(Boolean(creditMeter) && Boolean(creditMeter.status_tf))
         {
            creditMeter.status_tf.text = this.getLevelTitle(this.m_totalCreditsReceived);
         }
      }
      
      protected function animateMeter() : void
      {
         var meterStack:MovieClip = this.getMeterStack();
         if(meterStack)
         {
            this.m_currentMeterFrame = 1;
            this.m_maxMeterFrame = this.calcMaxMeterFrame();
            meterStack.gotoAndStop(this.m_currentMeterFrame);
         }
      }
      
      private function onAnimateMeter(event:TimerEvent) : void
      {
         var meterStack:MovieClip = null;
         if(this.m_currentMeterFrame < this.m_maxMeterFrame)
         {
            meterStack = this.getMeterStack();
            if(meterStack)
            {
               meterStack.gotoAndStop(this.m_currentMeterFrame);
            }
            ++this.m_currentMeterFrame;
         }
      }
      
      protected function getNumMeterFrames() : Number
      {
         return NUM_METER_ANIM_FRAMES;
      }
      
      private function calcMaxMeterFrame() : uint
      {
         var requiredAmount:Number = NaN;
         var maxMeterFrame:uint = 1;
         var levels:Array = this.m_rewardCreditsBuilding.getLevelCredits();
         var meterFrameInterval:uint = Math.round(this.getNumMeterFrames() / levels.length);
         var prevRequiredAmount:Number = 0;
         for(var levelIndex:uint = 0; levelIndex < levels.length; levelIndex++)
         {
            requiredAmount = Number(levels[levelIndex]);
            if(this.m_totalCreditsReceived <= requiredAmount)
            {
               maxMeterFrame += Math.floor((this.m_totalCreditsReceived - prevRequiredAmount) / (requiredAmount - prevRequiredAmount) * meterFrameInterval);
               break;
            }
            maxMeterFrame += meterFrameInterval;
            prevRequiredAmount = requiredAmount;
         }
         return maxMeterFrame;
      }
      
      private function setupLeaderboard() : void
      {
         this.populateFriends();
         this.setupPlayerPanel();
      }
      
      private function setupPlayerPanel() : void
      {
         var playerPanel:MovieClip = null;
         if(Boolean(m_window.leaderBoard_mc) && Boolean(m_window.leaderBoard_mc.playerPanel_mc))
         {
            playerPanel = m_window.leaderBoard_mc.playerPanel_mc as MovieClip;
            playerPanel.name_tf.text = Global.player.snUser.name;
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Score") || !this.m_creditFriendlyName)
            {
               playerPanel.points_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Score",{"quantity":this.m_totalCreditsReceived});
            }
            else
            {
               playerPanel.points_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Score",{
                  "quantity":this.m_totalCreditsReceived,
                  "creditName":ZLocUtils.tk_pk(this.m_creditFriendlyName,"",this.m_totalCreditsReceived)
               });
            }
            playerPanel.title_tf.text = this.quoteTitle(this.getLevelTitle(this.m_totalCreditsReceived));
            if(ZLocUtils.hasString(LOC_BUNDLE,this.m_buildingClassName + "_Ranking"))
            {
               playerPanel.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Ranking",{
                  "rank":this.m_friendsRanking,
                  "total":this.m_friends.length
               });
            }
            else
            {
               playerPanel.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_Ranking",{
                  "rank":this.m_friendsRanking,
                  "total":this.m_friends.length
               });
            }
            this.addProfileIcon(Global.player.snUser.uid.toString(),playerPanel,playerPanel.icon,LEADERBOARD_PLAYER_PANEL_ICON_WIDTH,LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y);
         }
      }
      
      private function populateFriends() : void
      {
         var curFriend:Object = null;
         var friends:Array = Global.friendManager.neighbors.concat();
         friends.push(Global.player);
         friends.sort(this.sortFriendsByCreditsReceived);
         for(var sortedIndex:uint = 0; sortedIndex < friends.length; sortedIndex++)
         {
            curFriend = friends[sortedIndex];
            if(curFriend.uid == Global.player.snUser.uid)
            {
               this.m_friendsRanking = sortedIndex + 1;
               break;
            }
         }
         this.m_friends = friends;
      }
      
      private function sortFriendsByCreditsReceived(friend1:IUser, friend2:IUser) : int
      {
         var result:int = 0;
         var featureName:String = this.getCreditsFeatureName();
         var credits1:int = friend1.getFeatureCreditsReceived(featureName);
         var credits2:int = friend2.getFeatureCreditsReceived(featureName);
         if(credits1 > credits2)
         {
            result = -1;
         }
         else if(credits2 > credits1)
         {
            result = 1;
         }
         return result;
      }
      
      private function getCreditsFeatureName() : String
      {
         var name:String = "";
         var creditsXml:XML = this.getBuildingCreditsXml();
         if(creditsXml)
         {
            name = creditsXml.@name;
         }
         return name;
      }
      
      private function populateLevelTitles() : void
      {
         var levels:Array = this.m_rewardCreditsBuilding.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            this.m_levelTitles[index] = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Level_" + (index + 1));
         }
      }
      
      protected function getLevelTitle(numCreditsReceived:uint) : String
      {
         var title:String = "";
         var levels:Array = this.m_rewardCreditsBuilding.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            if(numCreditsReceived >= levels[index])
            {
               title = this.m_levelTitles[index];
            }
         }
         if(!title)
         {
            title = ZLocUtils.t(LOC_BUNDLE,this.m_buildingClassName + "_Level_0");
         }
         return title;
      }
      
      private function quoteTitle(title:String) : String
      {
         return "\"" + title + "\"";
      }
      
      private function onPlayAskForCreditsSheen(event:TimerEvent) : void
      {
         var sheen_mc:MovieClip = null;
         if(m_window.sheen_mc)
         {
            sheen_mc = m_window.sheen_mc as MovieClip;
            sheen_mc.play();
         }
      }
      
      override protected function fixArrows() : void
      {
         m_window.leaderBoard_mc.arrowUp_bt.visible = m_tileSet > 0 ? true : false;
         m_window.leaderBoard_mc.arrowDown_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
      }
      
      private function getLevelNumber(numCreditsReceived:uint) : uint
      {
         var levelNumber:uint = 1;
         var levels:Array = this.m_rewardCreditsBuilding.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            if(numCreditsReceived >= levels[index])
            {
               levelNumber++;
            }
         }
         return levelNumber;
      }
   }
}

