package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ItemFinderManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FrontierInnovationBasicLuxuryTaskFrame;
   import Widgets.Frames.FrontierInnovationBasicLuxuryTradeFrame;
   import Widgets.Frames.FrontierInnovationTradeFrame;
   import Widgets.Frames.FrontierInnovationUpgradeFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.FrontierInnovationBasicLuxuryTaskSlot;
   import Widgets.Slots.FrontierInnovationUpgradeSlot;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.*;
   
   public class FrontierInnovationBarnWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_WELCOME_SEEN_FLAG:String = "Carribean_Welcome_flag";
      
      private static const FEATURE_DAILYPLAY_SEEN_FLAG:String = "Carribean_DailyPlayWelcome_flag";
      
      private static const FEATURE_NAME:String = "FrontierInnovation";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const FOOTER_TF:String = "footer_tf";
      
      private const CLOSE_BT:String = "close_bt";
      
      private const METER_MC:String = "meter_mc";
      
      private const DAILYMETER_MC:String = "dailymeter_mc";
      
      private const DAILY_MC:String = "daily_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const METER3_MC:String = "meter3_mc";
      
      private const METER4_MC:String = "meter4_mc";
      
      private const UPGRADETASK_MC:String = "upgrade_mc";
      
      private const UPGRADE_TRADE_MC:String = "upgrade_trade_mc";
      
      private const TRADE_MC:String = "trade_mc";
      
      private const BASICTASK_MC:String = "basic_mc";
      
      private const BASICTASK_TRADE_MC:String = "basic_trade_mc";
      
      private const LUXURYTASK_MC:String = "luxury_mc";
      
      private const LUXURYTASK_TRADE_MC:String = "luxury_trade_mc";
      
      private const DAILY_TF:String = "daily_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FLOAT_MC:String = "float_mc";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const REWARDS_BT:String = "rewards_bt";
      
      private const BOOST_BT:String = "boost_bt";
      
      private const ACHIEVEMENT_BT:String = "achieve_bt";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const TILE_UNLCOK_MC:String = "tileUnlock_mc";
      
      private const NPC1:String = "npc1";
      
      private const NPC2:String = "npc2";
      
      private const NPC3:String = "npc3";
      
      private const NPC4:String = "npc4";
      
      private const PROFILE_MC:String = "profile_mc";
      
      private const PREVIEW1_MC:String = "preview1_mc";
      
      private const PREVIEW2_MC:String = "preview2_mc";
      
      private const PREVIEW3_MC:String = "preview3_mc";
      
      private const REWARD1_MC:String = "reward1_mc";
      
      private const REWARD2_MC:String = "reward2_mc";
      
      private const REWARD3_MC:String = "reward3_mc";
      
      private const ACHIEVE_REDEEM_MC:String = "achieve_redeem";
      
      private const POINTS_TF:String = "points_tf";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_POSTFINISH_TITLE:String = "_postfinish_title";
      
      private const TEXT_POSTFINISH_BODY:String = "_postfinish_description";
      
      private const TEXT_REWARDS_BT:String = "_rewards_button";
      
      private const TEXT_BOOST_BT:String = "_boost_button";
      
      private const TEXT_ACHIEVEMENT_BT:String = "_achievement_button";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_upgradeFrame:FrontierInnovationUpgradeFrame;
      
      private var m_upgradeTradeFrame:FrontierInnovationTradeFrame;
      
      private var m_tradeFrame:FrontierInnovationTradeFrame;
      
      private var m_basicFrame:FrontierInnovationBasicLuxuryTaskFrame;
      
      private var m_basicTradeFrame:FrontierInnovationBasicLuxuryTradeFrame;
      
      private var m_luxuryFrame:FrontierInnovationBasicLuxuryTaskFrame;
      
      private var m_luxuryTradeFrame:FrontierInnovationBasicLuxuryTradeFrame;
      
      private var m_meter_mc:MovieClip;
      
      private var m_dailyMeter_mc:MovieClip;
      
      private var m_meter1_mc:MovieClip;
      
      private var m_meter2_mc:MovieClip;
      
      private var m_meter3_mc:MovieClip;
      
      private var m_meter4_mc:MovieClip;
      
      private var m_profile_mc:MovieClip;
      
      private var m_player_icon:FarmIcon;
      
      private var m_FtueMc:MovieClip;
      
      public var m_notify:MovieClip;
      
      public var m_notifyFull:MovieClip;
      
      private var m_npc1:ZwFrame;
      
      private var m_npc2:ZwFrame;
      
      private var m_npc3:ZwFrame;
      
      private var m_npc4:ZwFrame;
      
      private var m_preview1_mc:ZwFrame;
      
      private var m_preview2_mc:ZwFrame;
      
      private var m_preview3_mc:ZwFrame;
      
      private var m_reward1_mc:MovieClip;
      
      private var m_reward2_mc:MovieClip;
      
      private var m_reward3_mc:MovieClip;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_footerTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_barnCapacity:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      protected var m_tileUnlock:ZwFrame = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 600;
      
      private const NPC_WIDTH_X:int = 250;
      
      private const MAX_POINT:int = 1000;
      
      private const MAX_DAILYPOINT:int = 50;
      
      private var m_isEA:Boolean;
      
      private var m_boostBt:FarmAnimatedButton;
      
      private const TEXT_REWARD1_HOVER:String = "Earn 100 Points";
      
      private const TEXT_REWARD2_HOVER:String = "Earn 300 Points";
      
      private const TEXT_REWARD3_HOVER:String = "Earn 600 Points";
      
      private const TEXT_NPC1_NAME:String = "Catalina";
      
      private const TEXT_NPC2_NAME:String = "Matias";
      
      private const TEXT_NPC3_NAME:String = "Santiago";
      
      private const TEXT_PLAYER_NAME:String = "You";
      
      private const MAX_FRANCHISE_COUNT:int = 8;
      
      private var m_franchiseMc:MovieClip;
      
      private var m_boardMc:MovieClip;
      
      private var m_collectConsumable:FarmAnimatedTextButton;
      
      private var m_consumableCount:ZwTextField;
      
      private var m_achievementBt:FarmAnimatedTextButton;
      
      private var m_npcMc:MovieClip;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_hitWidget1:ZwFrame;
      
      private var m_level0Mc:MovieClip;
      
      private var m_level1Mc:MovieClip;
      
      private var m_level2Mc:MovieClip;
      
      private var m_rewardsBt:FarmAnimatedTextButton;
      
      private var m_pointerMc:MovieClip;
      
      private const BAR_INITIAL_POSTION:Number = 325;
      
      private var m_level1HitWidget:ZwFrame;
      
      private var m_level2HitWidget:ZwFrame;
      
      private var m_npcHitWidget:ZwFrame;
      
      private var m_overlayMc:MovieClip;
      
      private var m_overlay2Mc:MovieClip;
      
      private var m_overlay1Tf:ZwTextField;
      
      private var m_overlay2Tf:ZwTextField;
      
      private var m_boardFrameNumber:Number = 1;
      
      private var m_timerMc:MovieClip;
      
      private var m_achieveMc:MovieClip;
      
      private var m_boardTf:ZwTextField;
      
      private var m_unlockTf:ZwTextField;
      
      private var m_daily_mc:MovieClip;
      
      private var m_dailyIcon_mc:MovieClip;
      
      private var m_dailyCheckmark_mc:MovieClip;
      
      private var m_dailyTf:ZwTextField;
      
      private var m_dailyIcon:FarmIcon;
      
      private var m_overlayBt:FarmAnimatedTextButton;
      
      private var m_dailyoverlay1Tf:ZwTextField;
      
      private var m_dailyoverlay2Tf:ZwTextField;
      
      private var m_dailyoverlayBt:FarmAnimatedTextButton;
      
      private var m_achievementIconMc:MovieClip;
      
      private var m_achievementCount:ZwTextField;
      
      private var m_dooberMc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_hitWidget2:ZwFrame;
      
      private var m_achieve_redeem_mc:MovieClip;
      
      private var m_basicMc:MovieClip;
      
      private var m_basicTradeMc:MovieClip;
      
      private var m_luxuryMc:MovieClip;
      
      private var m_luxuryTradeMc:MovieClip;
      
      private var m_mainBgMc:MovieClip;
      
      private var m_sizeMc:MovieClip;
      
      private var m_upgradeMc:MovieClip;
      
      private var m_upgradeTradeMc:MovieClip;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_tradeFullBt:FarmAnimatedTextButton;
      
      private var m_closeBt:FarmButton;
      
      private const TRADE_BT:String = "trade_bt";
      
      private const NOTIF_MC:String = "notif_mc";
      
      private const TRADE_FULL_BT:String = "trade_full_bt";
      
      private var patternSlot:RegExp = /\d/;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Great!","Okay!","Okay!"];
      
      internal var managerObject:Object;
      
      public function FrontierInnovationBarnWindow(featureBuiilding:FeatureBuilding = null)
      {
         this.managerObject = this.manager;
         var dialogURL:String = this.manager.getBarnDialogUrl();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_DRAGONVALLEY);
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         var tutorailFeatureName:String = FEATURE_NAME + "Barn";
         super(tutorailFeatureName,dialogURL,totalScenes);
      }
      
      protected function onClick() : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
         var capacity:String = null;
         var showTileUnlockMc:Number = NaN;
         var boostPoints:Number = NaN;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CARIBBEAN);
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Barnhouse"));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            this.m_descriptionTf = addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.FOOTER_TF))
         {
            this.m_footerTf = addWidget(new ZwTextField(m_window[this.FOOTER_TF],"Move the Mouse Pointer over a Resource to Trade or Discard it")) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.FINISH_TF))
         {
            addWidget(this.m_finishTitle = new ZwTextField(m_window[this.FINISH_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_TITLE)));
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty("capacity_tf"))
         {
            capacity = this.manager.getBarnCapacity() as String;
            this.m_barnCapacity = new ZwTextField(m_window["capacity_tf"],"Barnhouse Capacity: " + capacity);
            this.m_barnCapacity.visible = true;
         }
         if(m_window.hasOwnProperty("main_bg_mc"))
         {
            this.m_mainBgMc = m_window.main_bg_mc as MovieClip;
            this.m_mainBgMc.visible = true;
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_window.overlay_mc as MovieClip;
            this.m_overlayMc.visible = false;
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = m_window.size_mc as MovieClip;
            this.m_sizeMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.TRADE_BT))
         {
            capacity = this.manager.getTradePostSlotCount();
            addWidget(this.m_tradeBt = new FarmAnimatedTextButton(m_window[this.TRADE_BT],capacity + "\nTrade Post",this.onClickTradeButton));
            this.m_tradeBt.visible = false;
            this.m_notify = m_window[this.TRADE_BT][this.NOTIF_MC] as MovieClip;
            this.m_notify.visible = this.manager.isTradePostNotifyShow();
         }
         if(m_window.hasOwnProperty(this.TRADE_FULL_BT))
         {
            addWidget(this.m_tradeFullBt = new FarmAnimatedTextButton(m_window[this.TRADE_FULL_BT],"Trade \n Post Full",this.onClickTradeButton));
            this.m_tradeFullBt.visible = false;
            this.m_notifyFull = m_window[this.TRADE_FULL_BT][this.NOTIF_MC] as MovieClip;
            this.m_notifyFull.visible = this.manager.isTradePostNotifyShow();
         }
         if(m_window.hasOwnProperty(this.UPGRADETASK_MC))
         {
            this.m_upgradeFrame = new FrontierInnovationUpgradeFrame(m_window[this.UPGRADETASK_MC],this.m_featureName,this);
            this.m_upgradeFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.BASICTASK_MC))
         {
            this.m_basicFrame = new FrontierInnovationBasicLuxuryTaskFrame(m_window[this.BASICTASK_MC],this.m_featureName,this);
            this.m_basicFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.LUXURYTASK_MC))
         {
            this.m_luxuryFrame = new FrontierInnovationBasicLuxuryTaskFrame(m_window[this.LUXURYTASK_MC],this.m_featureName,this);
            this.m_luxuryFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.TRADE_MC))
         {
            this.m_tradeFrame = new FrontierInnovationTradeFrame(m_window[this.TRADE_MC],this.m_featureName,this);
            this.m_tradeFrame.visible = false;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],this.TEXT_WHATISTHIS,this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_FtueMc = m_window.ftue_mc as MovieClip;
            this.m_FtueMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.TILE_UNLCOK_MC))
         {
            showTileUnlockMc = this.manager.showTileUnlockCountMc();
            this.m_tileUnlock = addWidget(new ZwFrame(m_window[this.TILE_UNLCOK_MC]),true) as ZwFrame;
            if(m_window[this.TILE_UNLCOK_MC].okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.tileUnlock_mc.okay_bt,"Awesome!",this.onTileUnlockOkayButtonClick));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF])
            {
               addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF],"Congratulations!"));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF])
            {
               boostPoints = this.manager.TUNING_BARN_CAPACITY * showTileUnlockMc;
               if(showTileUnlockMc > 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"Your barn now has " + boostPoints + " extra spaces for unlocking " + showTileUnlockMc + " tiles! Use it well!"));
               }
               else if(showTileUnlockMc == 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"Your barn now has " + boostPoints + " extra spaces for unlocking " + showTileUnlockMc + " tile! Use it well!"));
               }
            }
            if(!showTileUnlockMc)
            {
               this.m_tileUnlock.visible = false;
            }
         }
         this.tradePostButtonVisibility();
      }
      
      private function onTileUnlockOkayButtonClick(event:MouseEvent) : void
      {
         this.m_tileUnlock.visible = false;
         this.manager.addTileFeatureOptions();
         this.refreshWindow();
      }
      
      private function onCloseButton(event:Event) : void
      {
         this.manager.openMainWindow();
      }
      
      public function getSlotNumber(slotName:String) : int
      {
         var result:Object = this.patternSlot.exec(slotName);
         return int(result[0]);
      }
      
      public function makeOtherSlotInactive(frameName:String) : void
      {
         this.m_tradeFrame.makeOtherSlotsInactive(frameName);
      }
      
      public function otherSlotActive(frameName:String) : Boolean
      {
         return this.m_tradeFrame.otherSlotsActive(frameName);
      }
      
      public function setR1SlotActive(R1Slot:int, slotResource:String, frameName:String) : void
      {
         this.m_tradeFrame.setR1SlotActive(R1Slot,slotResource,frameName);
      }
      
      public function disableTradeSlotsButton(frameName:String) : void
      {
         this.m_tradeFrame.disableTradeSlotsButton(frameName);
      }
      
      public function closeTradeFrame() : void
      {
         this.m_overlayMc.visible = false;
         this.m_tradeFrame.visible = false;
      }
      
      public function clearTradeSlots(frameName:String) : void
      {
         this.m_tradeFrame.clearTradeSlots(frameName);
      }
      
      public function clearFrameSlot(frameName:String, slotNumber:int) : void
      {
         if(frameName == this.UPGRADE_TRADE_MC || frameName == this.UPGRADETASK_MC)
         {
            (this.m_upgradeFrame["slots"][slotNumber] as FrontierInnovationUpgradeSlot).clearSlotData();
         }
         else if(frameName == this.BASICTASK_TRADE_MC || frameName == this.BASICTASK_MC)
         {
            (this.m_basicFrame["slots"][slotNumber] as FrontierInnovationBasicLuxuryTaskSlot).clearSlotData();
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC || frameName == this.LUXURYTASK_MC)
         {
            (this.m_luxuryFrame["slots"][slotNumber] as FrontierInnovationBasicLuxuryTaskSlot).clearSlotData();
         }
      }
      
      public function triggerTadeFrameInWindow(slotNumber:int, slotResource:String, resourceType:String, emptySlot:int) : void
      {
         this.m_overlayMc.visible = true;
         this.m_tradeFrame.visible = true;
         this.m_tradeFrame.clearTradeSlots(resourceType);
         this.m_tradeFrame.setTradeTitle(resourceType);
         this.m_tradeFrame.setupFrame(slotNumber,slotResource,resourceType,emptySlot);
      }
      
      public function getR1(frameName:String) : int
      {
         return this.m_tradeFrame.getR1(frameName);
      }
      
      public function getR2(frameName:String) : int
      {
         return this.m_tradeFrame.getR2(frameName);
      }
      
      public function activeConformTrade(frameName:String) : void
      {
         this.m_tradeFrame.activeConformTradeButton(frameName);
      }
      
      public function closeTradeFrameInWindow(resourceType:String) : void
      {
         this.m_overlayMc.visible = false;
         this.m_tradeFrame.visible = false;
         this.m_tradeFrame.disableFrame(resourceType);
      }
      
      private function tradePostButtonVisibility() : void
      {
         var count:String = this.manager.getTradePostSlotCount();
         var value:Array = count.split("/");
         if(value[0] == value[1])
         {
            this.m_tradeBt.visible = false;
            this.m_tradeFullBt.visible = true;
            this.m_notifyFull.visible = this.manager.isTradePostNotifyShow();
         }
         else
         {
            this.m_tradeBt.text = count + "\nTrade Post";
            this.m_tradeFullBt.visible = false;
            this.m_tradeBt.visible = true;
            this.m_notify.visible = this.manager.isTradePostNotifyShow();
         }
      }
      
      private function onClickTradeButton(event:Event) : void
      {
         FarmStatsManager.count(this.m_featureName,"BarnHouse","TradePostClick");
         this.manager.openTradePostWindow();
      }
      
      private function getFrameNumber() : Number
      {
         return this.m_boardFrameNumber;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(FEATURE_WELCOME_SEEN_FLAG);
      }
      
      public function onUnlockClick(e:MouseEvent) : void
      {
         this.manager.showFranchiseUI();
      }
      
      public function hideOverLay(e:MouseEvent) : void
      {
         if(this.m_overlay2Mc)
         {
            this.m_overlay2Mc.visible = false;
         }
      }
      
      public function visitCafe(e:MouseEvent) : void
      {
         this.close();
         ItemFinderManager.getInstance().highlightWorldItems("xcb_thecafe");
      }
      
      public function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override public function refreshWindow() : void
      {
         var count:String = this.manager.getBarnCapacity() as String;
         this.m_barnCapacity.text = "Barnhouse Capacity: " + count;
         this.tradePostButtonVisibility();
         this.m_upgradeFrame.refresh();
         this.m_basicFrame.refresh();
         this.m_luxuryFrame.refresh();
         this.m_tradeFrame.allTradeFrameRefresh();
      }
      
      override public function close() : void
      {
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
            this.manager.m_window.enableInput = true;
            this.manager.m_window.refreshWindow();
         }
         super.close();
      }
      
      private function get manager() : FrontierInnovationManager
      {
         return FrontierInnovationManager.getInstance(FEATURE_NAME);
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
   }
}

