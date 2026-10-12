package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Managers.ItemFinderManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CarribeanInnovationTaskFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class CarribeanInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_WELCOME_SEEN_FLAG:String = "Carribean_Welcome_flag";
      
      private static const FEATURE_DAILYPLAY_SEEN_FLAG:String = "Carribean_DailyPlayWelcome_flag";
      
      private static const FEATURE_NAME:String = "CarribeanInnovation";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const METER_MC:String = "meter_mc";
      
      private const DAILYMETER_MC:String = "dailymeter_mc";
      
      private const DAILY_MC:String = "daily_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const METER3_MC:String = "meter3_mc";
      
      private const METER4_MC:String = "meter4_mc";
      
      private const LOADING_TF:String = "loading_tf";
      
      private const DAILY_TF:String = "daily_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FLOAT_MC:String = "float_mc";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const REWARDS_BT:String = "rewards_bt";
      
      private const BOOST_BT:String = "boost_bt";
      
      private const ACHIEVEMENT_BT:String = "achieve_bt";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
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
      
      private var m_taskFrame:CarribeanInnovationTaskFrame;
      
      private var m_meter_mc:MovieClip;
      
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
      
      private var m_loadingTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected var m_tileUnlock:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
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
      
      public function CarribeanInnovationWindow(featureBuiilding:FeatureBuilding = null)
      {
         var dialogURL:String = this.manager.getDialogUrl();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CARIBBEAN);
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,dialogURL,totalScenes);
         this.m_boardFrameNumber = this.manager.getBoardFrameNumber();
      }
      
      override protected function postLoadComplete() : void
      {
         var count:Number = NaN;
         var showTileUnlockMc:Number = NaN;
         var boostPoints:Number = NaN;
         var showLoadingTf:Boolean = false;
         var iconUrl:String = null;
         var floatBuildingIcon:FarmIcon = null;
         var Url:String = null;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CARIBBEAN);
         super.postLoadComplete();
         var percentValue:Number = this.manager.getNPCProgress();
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
         if(m_window.hasOwnProperty(this.REWARDS_BT))
         {
            if(this.manager.getRewardBuildingName() != null && this.manager.getRewardBuildingName() != "0")
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.REWARDS_BT],"Go To Float",this.onClickRewardsButton));
               this.m_finishBody.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_BODY);
               this.m_finishTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_TITLE);
            }
            else
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.REWARDS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_REWARDS_BT),this.onClickRewardsButton));
            }
         }
         if(m_window.hasOwnProperty(this.BOOST_BT))
         {
            addWidget(this.m_boostBt = new FarmAnimatedTextButton(m_window[this.BOOST_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BOOST_BT),this.onClickBoostButton));
            if(this.manager.isAllTilesUnlocked() || this.manager.isFinalRewardChosen())
            {
               this.m_boostBt.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.ACHIEVEMENT_BT))
         {
            addWidget(this.m_achievementBt = new FarmAnimatedTextButton(m_window[this.ACHIEVEMENT_BT],"My Awards",this.onClickAchievementButton));
            this.m_achievementBt.visible = true;
            this.m_hitWidget2 = new ZwFrame(m_window[this.ACHIEVEMENT_BT] as MovieClip);
            if(this.manager.getLatestRedeemedAchievement() == 1)
            {
               this.m_hitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Win Awards","Hey, there are awards to be won for outstanding culinary service. It’ll bring us exclusive rewards and a neat trophy to show off!"));
               this.m_hitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
            if(m_window[this.ACHIEVEMENT_BT].hasOwnProperty("icon_mc"))
            {
               this.m_achievementIconMc = m_window[this.ACHIEVEMENT_BT]["icon_mc"] as MovieClip;
               this.m_achievementIconMc.gotoAndStop(this.manager.getLatestRedeemedAchievement());
            }
            if(m_window[this.ACHIEVEMENT_BT].hasOwnProperty("count_tf"))
            {
               count = this.manager.getAchievementRedeemedCount();
               this.m_achievementCount = new ZwTextField(m_window[this.ACHIEVEMENT_BT]["count_tf"],count.toString() + "/4");
            }
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
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.DUMPFTUE_MC))
         {
            this.m_DumpTutorial = addWidget(new ZwFrame(m_window[this.DUMPFTUE_MC]),false) as ZwFrame;
            if(m_window[this.DUMPFTUE_MC].okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.dumpFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onDumpTutorialOkayButtonClick));
            }
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = true;
            if(this.manager.getNPCProgress() == 0)
            {
               addWidget(this.m_npcHitWidget = new ZwFrame(this.m_npcMc),true);
               this.m_npcHitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Fabiana Here...","We\'re going to open a cafe! The best in town. We start with a cart, fill orders, open franchises and grow our fame to live the dream."));
               this.m_npcHitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("achieve_mc"))
         {
            this.m_achieveMc = m_window.achieve_mc as MovieClip;
            this.m_achieveMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.TILE_UNLCOK_MC))
         {
            showTileUnlockMc = 0;
            showTileUnlockMc = this.manager.showTileUnlockCountMc();
            this.m_tileUnlock = addWidget(new ZwFrame(m_window[this.TILE_UNLCOK_MC]),true) as ZwFrame;
            if(m_window[this.TILE_UNLCOK_MC].unlock_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.tileUnlock_mc.unlock_bt,"Thanks!",this.onTileUnlockOkayButtonClick));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF])
            {
               addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF],"Congratulations!"));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF])
            {
               boostPoints = this.manager.TILE_UNLOCK_POINTS * showTileUnlockMc;
               if(showTileUnlockMc > 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"You have been granted " + boostPoints + " boost points for purchasing " + showTileUnlockMc + " tiles!"));
               }
               else if(showTileUnlockMc == 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"You have been granted " + boostPoints + " boost points for purchasing " + showTileUnlockMc + " tile!"));
               }
            }
            if(!showTileUnlockMc)
            {
               this.m_tileUnlock.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.TASKS_MC))
         {
            this.m_taskFrame = new CarribeanInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.LOADING_TF))
         {
            showLoadingTf = this.manager.getTasks().length == 0;
            this.m_loadingTf = new ZwTextField(m_window[this.LOADING_TF],"Loading task...");
            this.m_loadingTf.visible = showLoadingTf;
         }
         if(m_window.hasOwnProperty("pointer_mc"))
         {
            this.m_pointerMc = m_window.pointer_mc;
            this.m_pointerMc.visible = true;
            this.updatePointerPosition(percentValue,this.m_pointerMc);
         }
         if(m_window.hasOwnProperty(this.METER_MC))
         {
            this.m_meter_mc = m_window[this.METER_MC];
            this.initializeMeterMC(this.m_meter_mc);
         }
         if(m_window.hasOwnProperty(this.DAILYMETER_MC))
         {
            this.m_dailyMeter_mc = m_window[this.DAILYMETER_MC];
            this.initializeDailyMeterMC(this.m_dailyMeter_mc);
         }
         if(m_window.hasOwnProperty(this.DAILY_MC))
         {
            this.m_daily_mc = m_window[this.DAILY_MC];
            this.m_daily_mc.visible = false;
            if(this.m_daily_mc.hasOwnProperty(this.ICON_MC))
            {
               this.m_dailyIcon_mc = this.m_daily_mc.icon_mc as MovieClip;
               addWidget(this.m_dailyIcon = new FarmIcon(this.m_dailyIcon_mc));
            }
            if(this.m_daily_mc.hasOwnProperty(this.CHECKMARK_MC))
            {
               this.m_dailyCheckmark_mc = this.m_daily_mc.checkmark_mc as MovieClip;
            }
         }
         if(m_window.hasOwnProperty(this.DAILY_TF))
         {
            this.m_dailyTf = new ZwTextField(m_window[this.DAILY_TF],"Daily Gameplay default Text");
            this.m_dailyTf.visible = false;
         }
         if(m_window.hasOwnProperty(this.METER1_MC))
         {
            this.m_meter1_mc = m_window[this.METER1_MC];
            this.initializeMeterMC(this.m_meter1_mc);
         }
         if(m_window.hasOwnProperty(this.METER2_MC))
         {
            this.m_meter2_mc = m_window[this.METER2_MC];
            this.initializeMeterMC(this.m_meter2_mc);
         }
         if(m_window.hasOwnProperty(this.METER3_MC))
         {
            this.m_meter3_mc = m_window[this.METER3_MC];
            this.initializeMeterMC(this.m_meter3_mc);
         }
         if(m_window.hasOwnProperty(this.METER4_MC))
         {
            this.m_meter4_mc = m_window[this.METER4_MC];
            this.initializeMeterMC(this.m_meter4_mc);
         }
         if(m_window.hasOwnProperty(this.NPC1))
         {
            addWidget(this.m_npc1 = new ZwFrame(m_window[this.NPC1]),true);
            this.m_npc1.visible = true;
            this.m_npc1.attachTooltip(new FarmTextTooltip(this.TEXT_PLAYER_NAME));
            m_window[this.NPC1].visible = true;
            if(m_window[this.NPC1].hasOwnProperty(this.PROFILE_MC))
            {
               this.m_player_icon = addWidget(new FarmIcon(m_window[this.NPC1].profile_mc)) as FarmIcon;
               this.m_player_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player_icon.setSmoothing(true);
               iconUrl = Global.player.picture;
               this.m_player_icon.loadIcon(iconUrl);
               this.m_player_icon.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.NPC2))
         {
            addWidget(this.m_npc2 = new ZwFrame(m_window[this.NPC2]),true);
            this.m_npc2.attachTooltip(new FarmTextTooltip(this.TEXT_NPC1_NAME));
         }
         if(m_window.hasOwnProperty(this.NPC3))
         {
            addWidget(this.m_npc3 = new ZwFrame(m_window[this.NPC3]),true);
            this.m_npc3.attachTooltip(new FarmTextTooltip(this.TEXT_NPC2_NAME));
         }
         if(m_window.hasOwnProperty(this.NPC4))
         {
            addWidget(this.m_npc4 = new ZwFrame(m_window[this.NPC4]),true);
            this.m_npc4.attachTooltip(new FarmTextTooltip(this.TEXT_NPC3_NAME));
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
         if(m_window.hasOwnProperty(this.REWARD1_MC))
         {
            this.m_reward1_mc = m_window[this.REWARD1_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.REWARD2_MC))
         {
            this.m_reward2_mc = m_window[this.REWARD2_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.REWARD3_MC))
         {
            this.m_reward3_mc = m_window[this.REWARD3_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.ACHIEVE_REDEEM_MC))
         {
            this.m_achieve_redeem_mc = m_window[this.ACHIEVE_REDEEM_MC] as MovieClip;
            this.m_achieve_redeem_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
            if(this.m_finishMc.hasOwnProperty("finish1_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish1_tf"],"Hurray!"));
            }
            if(this.m_finishMc.hasOwnProperty("finish2_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish2_tf"],"We are now living the dream!We have our very own gourmet Cafe! Great job! You can harvest the cafe for rewards till 11th Jun"));
            }
            if(this.m_finishMc.hasOwnProperty("visit_bt"))
            {
               addWidget(this.m_dailyoverlayBt = new FarmAnimatedTextButton(this.m_finishMc.visit_bt,"Visit Cafe",this.visitCafe));
            }
         }
         this.manager.npcmovements();
         if(Boolean(this.m_tileUnlock) && !this.m_tileUnlock.visible)
         {
            this.NPCMovement();
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_window.overlay_mc as MovieClip;
            if(this.m_overlayMc.hasOwnProperty("overlay1_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_overlayMc["overlay1_tf"],"Collect Fame"));
            }
            if(this.m_overlayMc.hasOwnProperty("overlay2_tf"))
            {
               addWidget(this.m_overlay2Tf = new ZwTextField(this.m_overlayMc["overlay2_tf"],"Your franchises will generate fame every 6 hours. Make sure you collect it to add to your score"));
            }
            this.m_overlayMc.visible = false;
         }
         if(m_window.hasOwnProperty("overlay2_mc"))
         {
            this.m_overlay2Mc = m_window.overlay2_mc as MovieClip;
            this.m_overlay2Mc.visible = false;
            if(this.m_overlay2Mc.hasOwnProperty("dailytitle_tf"))
            {
               addWidget(this.m_dailyoverlay1Tf = new ZwTextField(this.m_overlay2Mc["dailytitle_tf"],"Daily Challenge"));
            }
            if(this.m_overlay2Mc.hasOwnProperty("dailybody_tf"))
            {
               addWidget(this.m_dailyoverlay2Tf = new ZwTextField(this.m_overlay2Mc["dailybody_tf"],"We’ve got the cafe! Do you want to see how well we can run it? Come back tomorrow for the challenge!"));
            }
            if(this.m_overlay2Mc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_dailyoverlayBt = new FarmAnimatedTextButton(this.m_overlay2Mc.okay_bt,"Okay",this.hideOverLay));
            }
         }
         if(m_window.hasOwnProperty(this.FLOAT_MC))
         {
            floatBuildingIcon = addWidget(new FarmIcon(m_window[this.FLOAT_MC])) as FarmIcon;
            floatBuildingIcon.setIconSize(200,200);
            floatBuildingIcon.setSmoothing(true);
            Url = this.manager.getBuildingCurrentAsset();
            floatBuildingIcon.loadIcon(Url);
            floatBuildingIcon.visible = true;
         }
         if(m_window.hasOwnProperty("franchise_mc"))
         {
            this.m_franchiseMc = m_window.franchise_mc;
            this.m_franchiseMc.visible = true;
            addWidget(this.m_collectConsumable = new FarmAnimatedTextButton(this.m_franchiseMc.collect_bt,"Collect Fame",this.collectConsumableCallback));
            if(this.m_franchiseMc.hasOwnProperty("name_tf"))
            {
               addWidget(new ZwTextField(this.m_franchiseMc["name_tf"],"My Franchises"));
            }
            addWidget(this.m_consumableCount = new ZwTextField(this.m_franchiseMc["count_tf"],"COUNT TF!"));
            addWidget(this.m_unlockTf = new ZwTextField(this.m_franchiseMc["unlock_tf"],"Unlock TF!"));
            addWidget(new FarmAnimatedTextButton(this.m_franchiseMc.unlock_bt,"Add Franchise",this.onUnlockClick));
            if(this.manager.getTileUnlockCount() == 0 && this.m_franchiseMc.hasOwnProperty("hit_area_mc"))
            {
               this.m_hitWidget1 = new ZwFrame(this.m_franchiseMc["hit_area_mc"]);
               this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Franchise for Fame!"," Unlock land to open Franchises. They generate Fame which you can collect every 12 hours!"));
               this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(Boolean(this.m_franchiseMc) && this.m_franchiseMc.hasOwnProperty("doober_mc"))
         {
            this.m_dooberMc = this.m_franchiseMc.doober_mc as MovieClip;
            if(this.m_dooberMc.hasOwnProperty("dooberIcon_mc"))
            {
               this.m_dooberIconMc = this.m_dooberMc.dooberIcon_mc;
               if(this.m_dooberIconMc.hasOwnProperty("dooberCount_tf"))
               {
                  addWidget(this.m_dooberCountTf = new ZwTextField(this.m_dooberIconMc["dooberCount_tf"]));
               }
            }
         }
         if(m_window.hasOwnProperty("bundle_bt") && this.manager.isLandbundleActive() && !this.manager.isLandBundleUnlocked())
         {
            addWidget(new FarmAnimatedTextButton(m_window.bundle_bt,"bundle_bt!",this.onClick));
         }
         if(m_window.hasOwnProperty("board_mc"))
         {
            this.m_boardMc = m_window.board_mc as MovieClip;
            this.m_boardMc.visible = true;
            if(this.m_boardMc.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_boardTf = new ZwTextField(this.m_boardMc["title_tf"],"Fans’ Say…"));
            }
            this.m_boardMc.gotoAndStop(this.getFrameNumber());
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(FEATURE_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Fabiana Here...","We\'re going to open a cafe! The best in town. We start small, fill orders, open franchises and grow our fame to live the dream.");
         }
         if(m_window.hasOwnProperty("level0_mc"))
         {
            this.m_level0Mc = m_window.level0_mc as MovieClip;
            this.m_level0Mc.visible = true;
         }
         if(m_window.hasOwnProperty("level1_mc"))
         {
            this.m_level1Mc = m_window.level1_mc as MovieClip;
            this.m_level1Mc.visible = true;
            if(percentValue < 300)
            {
               addWidget(this.m_level1HitWidget = new ZwFrame(this.m_level1Mc),true);
               this.m_level1HitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Upgrade to Stall","If we reach 300 Fame, we can open a pretty stall. Call it a halfway cafe, hahaha!"));
               this.m_level1HitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("level2_mc"))
         {
            this.m_level2Mc = m_window.level2_mc as MovieClip;
            this.m_level2Mc.visible = true;
            if(this.m_level2Mc.hasOwnProperty("hit_area_mc") && percentValue < 1000)
            {
               addWidget(this.m_level2HitWidget = new ZwFrame(this.m_level2Mc.hit_area_mc),true);
               this.m_level2HitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Our dream cafe","Hit 1000 Fame and we will get our very own Cafe! Put in the hard work and reap rewards everyday."));
               this.m_level2HitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
            if(this.m_level2Mc.hasOwnProperty("rewards_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_level2Mc[this.REWARDS_BT],"Know More",this.onClickRewardsButton));
            }
         }
         if(this.manager.getNPCProgress() >= 1000)
         {
            this.manager.setFinalRewardGrantFlag();
         }
         this.refreshCollectButton();
      }
      
      private function getFrameNumber() : Number
      {
         return this.m_boardFrameNumber;
      }
      
      public function onMouseOver(title:String = "", text:String = "") : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.showNPCCallouts(title,text);
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.hideNPCCallout();
         };
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(FEATURE_WELCOME_SEEN_FLAG);
      }
      
      public function onUnlockClick(e:MouseEvent) : void
      {
         this.manager.showFranchiseUI();
      }
      
      public function onClick(e:MouseEvent) : void
      {
         this.m_overlayMc.visible = false;
         close();
         StatsManager.count(this.m_featureName,"ShowBundle");
         UI.displayPopup(new CaribbeanLandBundleWindow(this.m_featureName),false);
         this.disableCollectOverlay();
      }
      
      public function collectConsumableCallback(e:MouseEvent) : void
      {
         if(this.m_dooberMc)
         {
            this.m_dooberMc.gotoAndPlay(2);
         }
         this.manager.collectConsumables();
         this.refreshWindow();
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
         ItemFinderManager.getInstance().highlightWorldItems("xcb_thecafe");
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
      }
      
      public function refreshCollectButton() : void
      {
         var key:String = null;
         var timeLeft:String = null;
         if(this.manager.canCollectConsumables())
         {
            this.showNPCCallouts("Get your fame","Your franchises have added to your fame. Collect it now!");
         }
         else if(this.manager.getTileUnlockCount() != 0)
         {
            this.hideNPCCallout();
         }
         if(this.manager.canCollectConsumables() == false || Boolean(this.manager.getTileUnlockCount() == 0) && Boolean(this.m_collectConsumable))
         {
            this.m_collectConsumable.enabled = false;
            this.m_collectConsumable.callback = null;
            key = CarribeanInnovationManager.CARIBBEAN_TASK_POINTS_ITEM_CODE;
            timeLeft = HUD.getformattedTimeLeft(this.manager.getTimeLeft(key,CarribeanInnovationManager.DEFAULT_COLLECT_THROTTLE_TIME / 2));
            FarmGameUtil.disableButtonAndShowTooltip(this.m_collectConsumable,timeLeft);
         }
         else
         {
            this.m_collectConsumable.enabled = true;
            this.m_collectConsumable.callback = this.collectConsumableCallback;
            this.m_collectConsumable.detachTooltip();
         }
         this.NPCMovement();
      }
      
      public function forcedNPCCallouts(calloutTitle:String = null, calloutText:String = null, landBundleCallout:Boolean = false) : void
      {
         this.m_overlay1Tf.text = calloutTitle;
         this.m_overlay2Tf.text = calloutText;
         this.m_overlayMc.visible = true;
         if(landBundleCallout)
         {
            this.m_overlayMc.gotoAndStop(2);
         }
         else
         {
            this.m_overlayMc.gotoAndStop(1);
         }
      }
      
      public function disableCollectOverlay() : void
      {
         this.m_overlayMc.gotoAndStop(1);
         this.m_overlayMc.visible = false;
      }
      
      override public function refreshWindow() : void
      {
         this.refreshCollectButton();
         this.refreshTaskFrame();
         this.refreshAwards();
         this.NPCMovement();
      }
      
      private function refreshAwards() : void
      {
         if(this.m_achievementBt)
         {
            this.m_achievementIconMc.gotoAndStop(this.manager.getLatestRedeemedAchievement());
            this.m_achievementCount.text = this.manager.getAchievementRedeemedCount().toString() + "/4";
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(this.m_isEA)
         {
            if(sceneNumber == 3)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
         else if(sceneNumber == 4)
         {
            tutorialSceneNumber = sceneNumber + 1;
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         tutorialButtonText = "Next";
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
      
      private function initializeDailyMeterMC(meter_mc:MovieClip) : void
      {
         if(meter_mc)
         {
            meter_mc.visible = false;
            if(this.manager.isDailyPlayActive())
            {
               this.updateDailyProgressBar(0,meter_mc);
            }
            else
            {
               this.updateProgressBar(0,meter_mc);
            }
            if(meter_mc[this.POINTS_TF])
            {
               (meter_mc[this.POINTS_TF] as TextField).visible = true;
               (meter_mc[this.POINTS_TF] as TextField).text = "000";
            }
         }
      }
      
      private function updateProgressBar(percentValue:Number, meter_mc:MovieClip) : void
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
      
      public function updatePointerPosition(percentValue:Number, meter_mc:MovieClip) : void
      {
         var barWidth:Number = NaN;
         if(meter_mc.hasOwnProperty("points_tf"))
         {
            meter_mc.points_tf.text = percentValue;
            barWidth = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
            meter_mc.x = this.BAR_INITIAL_POSTION + barWidth;
         }
      }
      
      private function moveNPCByProgress(percentValue:Number, npc:ZwFrame) : void
      {
         if(percentValue > this.MAX_POINT)
         {
            percentValue = this.MAX_POINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         npc.x = this.NPC_WIDTH_X + barWidth;
      }
      
      private function updateDailyProgressBar(percentValue:Number, meter_mc:MovieClip) : void
      {
         if(percentValue > this.MAX_DAILYPOINT)
         {
            percentValue = this.MAX_DAILYPOINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_DAILYPOINT;
         if(meter_mc.bar_fill2_mc)
         {
            if(percentValue == 0)
            {
               (meter_mc.bar_fill2_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill2_mc,2,{"width":barWidth});
            }
         }
         if(meter_mc[this.POINTS_TF])
         {
            (meter_mc[this.POINTS_TF] as TextField).text = int(percentValue).toString();
         }
      }
      
      public function updateDailyPointerPosition(percentValue:Number, meter_mc:MovieClip) : void
      {
         var barWidth:Number = NaN;
         if(meter_mc.hasOwnProperty("points_tf"))
         {
            if(percentValue > this.MAX_DAILYPOINT)
            {
               percentValue = this.MAX_DAILYPOINT;
            }
            meter_mc.points_tf.text = percentValue;
            barWidth = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_DAILYPOINT;
            meter_mc.x = this.BAR_INITIAL_POSTION + barWidth;
         }
      }
      
      private function moveDailyNPCByProgress(percentValue:Number, npc:ZwFrame) : void
      {
         if(percentValue > this.MAX_DAILYPOINT)
         {
            percentValue = this.MAX_DAILYPOINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_DAILYPOINT;
         npc.x = this.NPC_WIDTH_X + barWidth;
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
            this.m_taskFrame.refresh();
            this.NPCMovement();
            this.updateBoardFrame();
         }
      }
      
      private function updateBoardFrame() : void
      {
         this.m_boardMc.gotoAndStop(this.manager.getBoardFrameNumber());
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      public function NPCMovement() : void
      {
         var tileUnlockCount:int = 0;
         var franchiseUnlockCount:int = 0;
         var franchiseFamePoints:int = 0;
         var achievementName:String = null;
         var AchievementClosetoExpiry:int = 0;
         var AchievementReadytoRedeem:int = 0;
         var iconUrl:String = null;
         var rewardItem:FarmItem = null;
         if(this.manager.getRedeemCallout())
         {
            this.showNPCCallouts("Order Complete!","Click ‘Redeem’ on the orderboard and collect your well-deserved Fame!");
            this.manager.setRedeemCallout(false);
         }
         if(!this.manager.isFinalRewardGranted())
         {
            tileUnlockCount = this.manager.getTileUnlockCount();
            if(tileUnlockCount == 0)
            {
               this.m_collectConsumable.detachTooltip();
            }
            franchiseUnlockCount = tileUnlockCount < this.MAX_FRANCHISE_COUNT ? tileUnlockCount : this.MAX_FRANCHISE_COUNT;
            this.updateProgressBar(this.manager.getNPCProgress(),this.m_meter_mc);
            this.updatePointerPosition(this.manager.getNPCProgress(),this.m_pointerMc);
            franchiseFamePoints = this.manager.getTileUnlockCount();
            if(this.manager.getNPCProgress() < this.MAX_POINT)
            {
               this.manager.showOtherNPCFinalRewardTaken();
               this.manager.grantMilestoneReward();
               this.manager.checkandUpdateAchievementCompletedState();
            }
            else
            {
               this.manager.grantFinalReward();
            }
            if(this.manager.getFranchiseUnlockPoints() == 0)
            {
               this.m_consumableCount.text = "";
            }
            else
            {
               this.m_consumableCount.text = "+" + this.manager.getFranchiseUnlockPoints().toString();
            }
            this.m_dooberCountTf.text = "+" + this.manager.getFranchiseUnlockPoints().toString();
            this.manager.showTileUnlockCallout();
            achievementName = null;
            AchievementClosetoExpiry = this.manager.isAnyAchievementClosetoExpire();
            if(AchievementClosetoExpiry)
            {
               achievementName = this.manager.getAchievementName(AchievementClosetoExpiry - 1);
               this.showNPCCallouts("Award expires soon","The " + achievementName + " we’re gunning for will expire soon. Let’s buck up and win it!");
            }
            AchievementReadytoRedeem = this.manager.isAnyAchievementReadyToRedeem();
            if(AchievementReadytoRedeem)
            {
               achievementName = this.manager.getAchievementName(AchievementReadytoRedeem - 1);
               this.showNPCCallouts("You’ve won an Award!","Go redeem your " + achievementName + " and get an exclusive reward.");
               this.m_achieve_redeem_mc.visible = true;
            }
            this.m_unlockTf.text = franchiseUnlockCount.toString() + "/" + this.MAX_FRANCHISE_COUNT.toString();
         }
         else if(this.manager.isDailyPlayActive())
         {
            tileUnlockCount = this.manager.getTileUnlockCount();
            franchiseUnlockCount = tileUnlockCount < this.MAX_FRANCHISE_COUNT ? tileUnlockCount : this.MAX_FRANCHISE_COUNT;
            franchiseFamePoints = this.manager.getTileUnlockCount();
            this.m_consumableCount.text = "+" + this.manager.getFranchiseUnlockPoints().toString();
            this.m_unlockTf.text = franchiseUnlockCount.toString() + "/" + this.MAX_FRANCHISE_COUNT.toString();
            if(!Global.player.getSeenFlag(FEATURE_DAILYPLAY_SEEN_FLAG))
            {
               Global.player.setSeenFlag(FEATURE_DAILYPLAY_SEEN_FLAG);
               this.m_overlay2Mc.visible = true;
               FarmStatsManager.count(this.m_featureName,"ElderFeature","Begin",this.manager.getTotalDayIndex().toString());
            }
            this.m_meter_mc.visible = false;
            this.m_timerMc.visible = false;
            this.m_dailyMeter_mc.visible = true;
            this.m_preview1_mc.visible = false;
            this.m_preview2_mc.visible = false;
            this.m_preview3_mc.visible = false;
            this.m_level0Mc.visible = false;
            this.m_level1Mc.visible = false;
            this.m_level2Mc.visible = false;
            this.m_daily_mc.visible = true;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(CarribeanInnovationManager.DAILY_REWARDS[this.manager.getActiveDayIndex()]);
            this.m_dailyIcon.loadIcon(rewardItem.iconUrl);
            this.m_dailyCheckmark_mc.visible = false;
            this.m_dailyIcon_mc.visible = true;
            this.m_dailyTf.visible = true;
            this.m_dailyTf.text = this.getDailyText(rewardItem.friendlyTitle);
            if(this.manager.hasGrantedDayReward())
            {
               this.m_dailyCheckmark_mc.visible = true;
            }
            if(this.manager.hasActiveDayExpired())
            {
               this.resetDailyMeter();
            }
            else
            {
               this.updateDailyPointerPosition(this.manager.getDailyNPCProgress(),this.m_pointerMc);
               this.updateDailyProgressBar(this.manager.getDailyNPCProgress(),this.m_dailyMeter_mc);
            }
         }
         else
         {
            this.m_taskFrame.visible = false;
            this.m_finishMc.visible = true;
         }
      }
      
      private function getDailyText(itemName:String) : String
      {
         var result:String = "";
         var dailyScore:int = this.manager.getDailyNPCProgress();
         var hours:String = this.manager.getNumberOfDailyHours();
         var currentDayIndex:String = (this.manager.getActiveDayIndex() + 1).toString();
         var totalDay:String = this.manager.getTotalDayIndex().toString();
         if(dailyScore < this.MAX_DAILYPOINT)
         {
            result = "Challenge " + currentDayIndex + " of " + totalDay + ": Get 50 Fame today and win an exclusive " + itemName + ". " + hours + " remain.";
         }
         else if(dailyScore >= this.MAX_DAILYPOINT)
         {
            result = "Challenge complete. Come back tomorrow to see if there are more challenges!";
         }
         return result;
      }
      
      private function resetDailyMeter() : void
      {
         this.updateDailyPointerPosition(0,this.m_pointerMc);
         this.updateDailyProgressBar(0,this.m_dailyMeter_mc);
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
      
      private function onClickRewardsButton(evt:Event) : void
      {
         this.manager.showRewardsUI();
         tintWindow();
         enableInput = false;
      }
      
      private function onClickBoostButton(evt:Event) : void
      {
         this.manager.showBoostUI();
         tintWindow();
         enableInput = false;
      }
      
      private function onClickAchievementButton(evt:Event) : void
      {
         this.manager.showAchievementUI();
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
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(FEATURE_NAME);
      }
      
      public function showDumpTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_DumptutorialScene = 1;
         if(this.m_DumpTutorial)
         {
            element = this.m_DumpTutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window[this.DUMPFTUE_MC].okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_DumpTutorial.visible = true;
         }
      }
      
      private function onDumpTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_DumptutorialScene < 2)
         {
            ++this.m_DumptutorialScene;
            (this.m_DumpTutorial.element as MovieClip).gotoAndStop(this.m_DumptutorialScene);
         }
         else
         {
            this.hideDumpTutorial();
         }
      }
      
      private function onTileUnlockOkayButtonClick(event:MouseEvent) : void
      {
         this.m_tileUnlock.visible = false;
         this.manager.addTileFeatureOptions();
         this.NPCMovement();
      }
      
      private function hideDumpTutorial() : void
      {
         (this.m_DumpTutorial.element as MovieClip).stop();
         this.m_DumpTutorial.visible = false;
      }
   }
}

