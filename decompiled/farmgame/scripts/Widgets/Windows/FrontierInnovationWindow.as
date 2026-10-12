package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.ItemFinderManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FrontierInnovationCraftingSlotFrame;
   import Widgets.Frames.FrontierInnovationForageFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FrontierInnovationWindow extends GenericOrderBoardWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
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
      
      private const METER_MC:String = "meter_mc";
      
      private const DAILYMETER_MC:String = "dailymeter_mc";
      
      private const AXE_MC:String = "axe_mc";
      
      private const BARN_BT:String = "barn_bt";
      
      private const NOTIF_MC:String = "notif_mc";
      
      private const BOOST_BT:String = "boost_bt";
      
      private const FORAGE_BT:String = "forage_bt";
      
      private const MAIN_BG_MC:String = "main_bg_mc";
      
      private const CRAFTS_MC:String = "crafts_mc";
      
      private const DAILY_MC:String = "daily_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const METER3_MC:String = "meter3_mc";
      
      private const METER4_MC:String = "meter4_mc";
      
      private const DAILY_TF:String = "daily_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FLOAT_MC:String = "float_mc";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const REWARDS_BT:String = "rewards_bt";
      
      private const FORAGE_MC:String = "forage_mc";
      
      private const TILEUNLOCK_MC:String = "tileUnlock_mc";
      
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
      
      private var m_forage_overlayMc:MovieClip;
      
      private const FORAGE_OVERLAY_MC:String = "frageoverlay_mc";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_POSTFINISH_TITLE:String = "_postfinish_title";
      
      private const TEXT_POSTFINISH_BODY:String = "_postfinish_description";
      
      private const TEXT_REWARDS_BT:String = "_rewards_button";
      
      private const TEXT_BOOST_BT:String = "_boost_button";
      
      private const TEXT_BARN_BT:String = "_barn_button";
      
      private const TEXT_FORAGE_BT:String = "_forage_button";
      
      private const TEXT_ACHIEVEMENT_BT:String = "_achievement_button";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      public var m_meter_mc:MovieClip;
      
      private var m_dailyMeter_mc:MovieClip;
      
      private var m_meter1_mc:MovieClip;
      
      private var m_meter2_mc:MovieClip;
      
      private var m_meter3_mc:MovieClip;
      
      private var m_meter4_mc:MovieClip;
      
      private var m_profile_mc:MovieClip;
      
      private var m_player_icon:FarmIcon;
      
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
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      protected var m_tileUnlock:ZwFrame = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 600;
      
      private const NPC_WIDTH_X:int = 250;
      
      private const MAX_POINT:int = 3000;
      
      private const MAX_DAILYPOINT:int = 50;
      
      private var m_isEA:Boolean;
      
      private var m_boostBt:FarmAnimatedButton;
      
      private var m_barnBt:FarmAnimatedButton;
      
      private var m_forageBt:FarmAnimatedButton;
      
      public var m_notifMc:MovieClip;
      
      private const TEXT_REWARD1_HOVER:String = "Earn 300 Points";
      
      private const TEXT_REWARD2_HOVER:String = "Earn 900 Points";
      
      private const TEXT_REWARD3_HOVER:String = "Earn 1800 Points";
      
      private const TEXT_NPC1_NAME:String = "Catalina";
      
      private const TEXT_NPC2_NAME:String = "Matias";
      
      private const TEXT_NPC3_NAME:String = "Santiago";
      
      private const TEXT_PLAYER_NAME:String = "You";
      
      private const MAX_FRANCHISE_COUNT:int = 8;
      
      private var m_franchiseMc:MovieClip;
      
      private var m_boardMc:MovieClip;
      
      private var m_axeMc:MovieClip;
      
      private var m_tileUnlockMc:MovieClip;
      
      private var m_main_bg_Mc:MovieClip;
      
      private var m_crafts_Mc:MovieClip;
      
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
      
      public var m_pointerMc:MovieClip;
      
      private const BAR_INITIAL_POSTION:Number = 532;
      
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
      
      private var m_pageTf:ZwTextField;
      
      private var m_slot0_Mc:MovieClip;
      
      private var m_slot1_Mc:MovieClip;
      
      private var m_slot2_Mc:MovieClip;
      
      private var m_slot3_Mc:MovieClip;
      
      private var m_backBt:ZwButton;
      
      private var m_nextBt:ZwButton;
      
      public var managerObject:Object;
      
      private var m_craftsFrame:FrontierInnovationCraftingSlotFrame;
      
      private var m_forageFrame:FrontierInnovationForageFrame;
      
      private const SERVICE_NAME:String = "FrontierInnovationService";
      
      private var allSpecialRecipes:Object;
      
      private var m_axePoints:ZwTextField;
      
      private var m_FtueMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["I’m Ready!","Okay!","Okay!","Okay!","Awesome!","Awesome!","Awesome!"];
      
      private var m_pointsanim:MovieClip;
      
      public function FrontierInnovationWindow(featureBuiilding:FeatureBuilding = null)
      {
         this.managerObject = this.manager;
         var dialogURL:String = this.manager.getDialogUrl();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_NEWFRONTIER);
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"getRecipes",this.gotRecipes,[this.m_featureName]),true);
         super(FEATURE_NAME,dialogURL,this.managerObject,totalScenes);
      }
      
      public function gotRecipes(result:Object) : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
         var count:int = 0;
         var showTileUnlockMc:Number = NaN;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_NEWFRONTIER);
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            this.m_descriptionTf = addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.FINISH_TF))
         {
            addWidget(this.m_finishTitle = new ZwTextField(m_window[this.FINISH_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_TITLE)));
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty(this.TILEUNLOCK_MC))
         {
            this.m_tileUnlockMc = m_window[this.TILEUNLOCK_MC] as MovieClip;
            this.m_tileUnlockMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.AXE_MC))
         {
            this.m_axeMc = m_window.axe_mc as MovieClip;
            if(this.m_axeMc.hasOwnProperty("points_tf"))
            {
               addWidget(this.m_axePoints = new ZwTextField(this.m_axeMc["points_tf"]));
               this.m_axePoints.text = "x" + this.manager.getOrderboardProgress().toString();
            }
            this.m_axeMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
            this.m_finishMc.visible = false;
            if(this.m_finishMc.hasOwnProperty("fintitle_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["fintitle_tf"],"Strike it Rich!"),false);
            }
            if(this.m_finishMc.hasOwnProperty("finish1_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish1_tf"],"Great Work!"));
            }
            if(this.m_finishMc.hasOwnProperty("finish2_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish2_tf"],"You’ve struck it rich at the Frontier Trail! Go harvest the Hardy Home everyday until August 27th for awesome rewards!"));
            }
            if(this.m_finishMc.hasOwnProperty("visit_bt"))
            {
               addWidget(this.m_dailyoverlayBt = new FarmAnimatedTextButton(this.m_finishMc.visit_bt,"Show me!",this.visitCafe));
            }
         }
         if(m_window.hasOwnProperty(this.MAIN_BG_MC))
         {
            this.m_main_bg_Mc = m_window.main_bg_mc as MovieClip;
            this.m_main_bg_Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.CRAFTS_MC))
         {
            this.m_craftsFrame = new FrontierInnovationCraftingSlotFrame(m_window[this.CRAFTS_MC],this.m_featureName,this.managerObject);
            this.m_craftsFrame.setPagination();
            this.m_craftsFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.BOOST_BT))
         {
            addWidget(this.m_boostBt = new FarmAnimatedTextButton(m_window[this.BOOST_BT],"Get Frontier Coinage!",this.onClickBoostButton));
            this.m_boostBt.visible = true;
         }
         if(m_window.hasOwnProperty(this.BARN_BT))
         {
            addWidget(this.m_barnBt = new FarmAnimatedTextButton(m_window[this.BARN_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BARN_BT),this.onBarnButton));
            this.m_barnBt.visible = true;
            this.m_notifMc = m_window[this.BARN_BT][this.NOTIF_MC] as MovieClip;
            this.m_notifMc.visible = this.manager.isTradePostNotifyShow();
         }
         if(m_window.hasOwnProperty(this.FORAGE_BT))
         {
            addWidget(this.m_forageBt = new FarmAnimatedTextButton(m_window[this.FORAGE_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FORAGE_BT),this.onForageClick));
            this.m_forageBt.visible = true;
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_FtueMc = m_window.ftue_mc as MovieClip;
            this.m_FtueMc.visible = false;
         }
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timerMc = m_window.timer_mc as MovieClip;
            if(this.m_timerMc.hasOwnProperty(this.TIMER_TF))
            {
               addWidget(new ZwTextField(this.m_timerMc[this.TIMER_TF],this.getTimeLeft()));
            }
            this.m_timerMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.REWARD1_MC))
         {
            this.m_reward1_mc = m_window[this.REWARD1_MC] as MovieClip;
            this.m_reward1_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.REWARD2_MC))
         {
            this.m_reward2_mc = m_window[this.REWARD2_MC] as MovieClip;
            this.m_reward2_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.REWARD3_MC))
         {
            this.m_reward3_mc = m_window[this.REWARD3_MC] as MovieClip;
            this.m_reward3_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.PREVIEW1_MC))
         {
            addWidget(this.m_preview1_mc = new ZwFrame(m_window[this.PREVIEW1_MC]),true);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1);
            if(!this.manager.isFirstMilestoneAchieved())
            {
               this.m_preview1_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD1_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW2_MC))
         {
            addWidget(this.m_preview2_mc = new ZwFrame(m_window[this.PREVIEW2_MC]),true);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver2);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut2);
            if(!this.manager.isSecondMilestoneAchieved())
            {
               this.m_preview2_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD2_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW3_MC))
         {
            addWidget(this.m_preview3_mc = new ZwFrame(m_window[this.PREVIEW3_MC]),true);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver3);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut3);
            if(!this.manager.isThirdMilestoneAchieved())
            {
               this.m_preview3_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD3_HOVER));
            }
         }
         var percentValue:Number = this.manager.getNPCProgress();
         if(m_window.hasOwnProperty("pointer_mc"))
         {
            this.m_pointerMc = m_window.pointer_mc;
            this.m_pointerMc.visible = true;
            if(this.m_pointerMc.hasOwnProperty("pointsanim_mc"))
            {
               this.m_pointsanim = this.m_pointerMc.pointsanim_mc as MovieClip;
               this.m_pointsanim.visible = false;
            }
            this.updatePointerPosition(percentValue,this.m_pointerMc);
         }
         if(m_window.hasOwnProperty("level2_mc"))
         {
            this.m_level2Mc = m_window.level2_mc as MovieClip;
            this.m_level2Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.METER_MC))
         {
            this.m_meter_mc = m_window[this.METER_MC];
            this.initializeMeterMC(this.m_meter_mc);
            this.updateProgressBar(this.manager.getNPCProgress(),this.m_meter_mc);
         }
         if(m_window.hasOwnProperty(this.FORAGE_OVERLAY_MC))
         {
            this.m_forage_overlayMc = m_window[this.FORAGE_OVERLAY_MC] as MovieClip;
            this.m_forage_overlayMc.visible = false;
         }
         if(this.m_level2Mc.hasOwnProperty("rewards_bt"))
         {
            if(this.manager.getRewardBuildingName() != null && this.manager.getRewardBuildingName() != "0")
            {
               addWidget(new FarmAnimatedTextButton(this.m_level2Mc[this.REWARDS_BT],"Go To Float",this.onClickRewardsButton));
               this.m_finishBody.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_BODY);
               this.m_finishTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_TITLE);
            }
            else
            {
               addWidget(new FarmAnimatedTextButton(this.m_level2Mc[this.REWARDS_BT],"View Rewards",this.onClickRewardsButton));
            }
         }
         if(m_window.hasOwnProperty(this.FORAGE_MC))
         {
            this.m_forageFrame = new FrontierInnovationForageFrame(m_window[this.FORAGE_MC],this.m_featureName,this);
            this.m_forageFrame.visible = false;
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_window.overlay_mc as MovieClip;
            this.m_overlayMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TILE_UNLCOK_MC))
         {
            showTileUnlockMc = 0;
            showTileUnlockMc = this.manager.showTileUnlockCountMc();
            this.m_tileUnlock = addWidget(new ZwFrame(m_window[this.TILE_UNLCOK_MC]),true) as ZwFrame;
            this.m_tileUnlock.visible = false;
         }
         this.refreshWindow();
      }
      
      private function onOver1(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward1_mc.visible = true;
         this.m_reward1_mc.gotoAndStop(gotoFrame);
         this.m_reward1_mc.tick_mc.visible = this.manager.isFirstMilestoneAchieved();
      }
      
      private function onOut1(evt:MouseEvent) : void
      {
         this.m_reward1_mc.visible = false;
      }
      
      private function onOver2(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward2_mc.visible = true;
         this.m_reward2_mc.gotoAndStop(gotoFrame);
         this.m_reward2_mc.tick_mc.visible = this.manager.isSecondMilestoneAchieved();
      }
      
      private function onOut2(evt:MouseEvent) : void
      {
         this.m_reward2_mc.visible = false;
      }
      
      private function onOver3(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward3_mc.visible = true;
         this.m_reward3_mc.gotoAndStop(gotoFrame);
         this.m_reward3_mc.tick_mc.visible = this.manager.isThirdMilestoneAchieved();
      }
      
      private function onOut3(evt:MouseEvent) : void
      {
         this.m_reward3_mc.visible = false;
      }
      
      public function updatePointerPosition(percentValue:Number, meter_mc:MovieClip) : void
      {
         var barWidth:Number = NaN;
         if(meter_mc.hasOwnProperty("points_tf"))
         {
            meter_mc.points_tf.text = percentValue;
            barWidth = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT * (340 / 600);
            meter_mc.y = this.BAR_INITIAL_POSTION - barWidth;
         }
      }
      
      private function initializeMeterMC(meter_mc:MovieClip) : void
      {
         if(meter_mc)
         {
            meter_mc.visible = true;
            this.updateProgressBar(0,meter_mc);
            if(meter_mc[this.POINTS_TF])
            {
               (meter_mc[this.POINTS_TF] as TextField).visible = true;
               (meter_mc[this.POINTS_TF] as TextField).text = "000";
            }
         }
      }
      
      public function updateProgressBar(percentValue:Number, meter_mc:MovieClip) : void
      {
         if(percentValue > this.MAX_POINT)
         {
            percentValue = this.MAX_POINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(meter_mc.bar_fill_mc)
         {
            if(percentValue == 0)
            {
               (meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(meter_mc[this.POINTS_TF])
         {
            (meter_mc[this.POINTS_TF] as TextField).text = int(percentValue).toString();
         }
      }
      
      private function openBarnUI(evt:Event) : void
      {
         this.manager.showBarnUI();
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      public function setForageFrameOverlay() : *
      {
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
      
      public function refreshCraftFrame() : void
      {
         this.m_craftsFrame.refresh();
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
         close();
         ItemFinderManager.getInstance().highlightWorldItems("xnf_hardyhome");
      }
      
      private function onBarnButton(event:Event) : void
      {
         var barnCapacity:int = this.manager.getTotalBarnCapacity();
         var barnInventoryCapacity:int = this.manager.getBarnInventoryCount();
         FarmStatsManager.count(this.m_featureName,"BarnHouse",barnCapacity.toString(),barnInventoryCapacity.toString());
         this.manager.showBarnUI();
      }
      
      public function onForageClick(event:Event) : void
      {
         this.m_overlayMc.visible = true;
         this.m_forageFrame.visible = true;
         this.m_whatIsThisBt.visible = false;
         this.m_forageFrame.refresh();
         StatsManager.count(this.m_featureName,"ForageClick");
         if(Boolean(!Global.player.getSeenFlag(FrontierInnovationManager.FEATURE_FORCED_TUT_SECOND_STEP)) && Boolean(this.m_FtueMc) && this.manager.getOrderboardProgress() >= 5)
         {
            this.m_FtueMc.visible = true;
            this.m_FtueMc.gotoAndStop(2);
            Global.player.setSeenFlag(FrontierInnovationManager.FEATURE_FORCED_TUT_SECOND_STEP);
         }
      }
      
      public function disableForageWindow() : void
      {
         this.m_overlayMc.visible = false;
         this.m_forageFrame.visible = false;
         this.m_whatIsThisBt.visible = true;
      }
      
      public function enableForageWindow() : void
      {
         this.m_overlayMc.visible = true;
         this.m_forageFrame.visible = true;
         this.m_whatIsThisBt.visible = false;
      }
      
      public function refreshForage() : void
      {
         this.m_forageFrame.refresh();
         this.refreshCraftFrame();
      }
      
      override public function refreshWindow() : void
      {
         var progress:Number = this.manager.getNPCProgress();
         if(!this.manager.isFinalRewardGranted())
         {
            if(progress < this.MAX_POINT)
            {
               if(this.m_axePoints)
               {
                  this.m_axePoints.text = "x" + this.manager.getOrderboardProgress().toString();
               }
               refreshTaskFrame();
               this.refreshForage();
               this.refreshCraftFrame();
               this.manager.grantMilestoneReward();
            }
            else
            {
               this.manager.grantFinalReward();
            }
         }
         else if(this.m_finishMc)
         {
            this.m_finishMc.visible = true;
         }
         this.m_notifMc.visible = this.manager.isTradePostNotifyShow();
      }
      
      private function onClickRewardsButton(evt:Event) : void
      {
         this.manager.showRewardsUI();
         tintWindow();
         enableInput = false;
      }
      
      private function onClickBoostButton(evt:Event) : void
      {
         this.manager.showBoostUI();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function get manager() : FrontierInnovationManager
      {
         return FrontierInnovationManager.getInstance(FEATURE_NAME);
      }
      
      public function setForcedTut() : void
      {
         if(this.m_FtueMc)
         {
            this.m_FtueMc.visible = true;
         }
      }
      
      public function unsetForcedTut() : void
      {
         if(this.m_FtueMc)
         {
            this.m_FtueMc.visible = false;
         }
      }
      
      public function enableForage() : void
      {
         this.m_overlayMc.enabled = true;
         this.m_forageFrame.enabledCloseBT();
         this.m_forageFrame.enabled = true;
      }
      
      public function disabledForage() : void
      {
         this.m_overlayMc.enabled = false;
         this.m_forageFrame.disabledCloseBT();
         this.m_forageFrame.enabled = false;
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            this.preSwitchChanges(tutorialSceneNumber);
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
      
      public function setForageOverlayMc(flag:Boolean) : void
      {
         if(this.m_forage_overlayMc)
         {
            this.m_forage_overlayMc.visible = flag;
         }
      }
      
      public function playPointsAnimationMc() : void
      {
         if(this.m_pointsanim)
         {
            this.m_pointsanim.visible = true;
            this.m_pointsanim.play();
         }
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(this.m_isEA)
         {
            if(sceneNumber == 4)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
         else if(sceneNumber == 5)
         {
            tutorialSceneNumber = sceneNumber + 1;
         }
      }
   }
}

