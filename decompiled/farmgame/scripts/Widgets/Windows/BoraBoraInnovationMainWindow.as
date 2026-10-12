package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BoraboraInnovationBasicDecoFrame;
   import Widgets.Frames.BoraboraInnovationDecorDecoFrame;
   import Widgets.Frames.BoraboraInnovationSpecialDecoFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BoraBoraInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      private static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const FLAG_FIRST_STARTNEWDAY:String = "borabora_first_newday";
      
      private const BORABORA_MAIN_FTUE1_FLAG:String = "borabora_main_ftue1_flag";
      
      private const BORABORA_MAIN_FTUE2_FLAG:String = "borabora_main_ftue2_flag";
      
      private const BORABORA_MAIN_FTUE3_FLAG:String = "borabora_main_ftue3_flag";
      
      private var m_timer:Timer;
      
      private var m_cycleTimer:Timer;
      
      private const MAX_STARS_EA:int = 7;
      
      private const MAX_STARS_GA:int = 5;
      
      private const STAR_SLOT_WIDTH_EA:int = 70;
      
      private const STAR_SLOT_WIDTH_GA:int = 80;
      
      private var m_boramoney_mc:MovieClip;
      
      private var m_boramoney_count_tf:ZwTextField;
      
      private var m_earn_bt:FarmAnimatedTextButton;
      
      private var m_leaderboardpane_mc:MovieClip;
      
      private var m_norank_tf:ZwTextField;
      
      private var m_players_mc:Object = new Array(3);
      
      private var m_allTabsMc:MovieClip;
      
      private var m_basicDecoPanel:MovieClip;
      
      public var m_basicPanelFrame:BoraboraInnovationBasicDecoFrame;
      
      private var m_decorDecoPanel:MovieClip;
      
      private var m_decorLockMc:MovieClip;
      
      private var m_decorLockIconMc:MovieClip;
      
      private var m_specialDecoPanel:MovieClip;
      
      private var m_specialLockMc:MovieClip;
      
      private var m_specialLockIconMc:MovieClip;
      
      public var m_decorPanelFrame:BoraboraInnovationDecorDecoFrame;
      
      public var m_specialPanelFrame:BoraboraInnovationSpecialDecoFrame;
      
      private var m_basicTabButton:FarmAnimatedTextButton;
      
      private var m_decorTabButton:FarmAnimatedTextButton;
      
      private var m_specialTabButton:FarmAnimatedTextButton;
      
      private var m_rewardspane_mc:MovieClip;
      
      private var m_dailyreward_icon:FarmIcon;
      
      private var m_dailycount_tf:ZwTextField;
      
      private var m_dailyhover_mc:MovieClip;
      
      private var m_hovereward_icon:FarmIcon;
      
      private var m_rewardtimer_tf:ZwTextField;
      
      private var m_dailyreward_name_tf:ZwTextField;
      
      private var m_startnewday_mc:MovieClip;
      
      private var m_startweek_mc:MovieClip;
      
      private var m_newreward_icon:FarmIcon;
      
      private var m_featuretime_tf:ZwTextField;
      
      private var m_newweekbody_tf:ZwTextField;
      
      private var m_newweeklyproduce_icon:FarmIcon;
      
      private var m_starProgressEA_mc:MovieClip;
      
      private var m_starProgressGA_mc:MovieClip;
      
      private var m_meterEA_mc:MovieClip;
      
      private var m_meterGA_mc:MovieClip;
      
      private var m_barfillEA_mc:MovieClip;
      
      private var m_barfillGA_mc:MovieClip;
      
      private var m_starfills_EA:Array = [];
      
      private var m_starfills_GA:Array = [];
      
      private var m_thumbsCountEA_mc:MovieClip;
      
      private var m_thumbsCountGA_mc:MovieClip;
      
      private var m_starhoverEA_mc:MovieClip;
      
      private var m_starhoverGA_mc:MovieClip;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_BORABORA);
      
      private var m_hovercompete_mc:MovieClip;
      
      private var m_weeklycompete_mc:MovieClip;
      
      private var m_staticFtue:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_loadCycleLoadAnimation:MovieClip;
      
      private var m_nextreward_icon:FarmIcon;
      
      private var m_nextreward_tf:ZwTextField;
      
      private var m_npcIcon:FarmIcon;
      
      private var m_decowhatIsThisBt:FarmAnimatedTextButton;
      
      private var m_panelFTUE:MovieClip;
      
      private var m_weddingTimer:ZwTextField;
      
      private var m_npcNames:ZwTextField;
      
      private var m_ddLockIconMc:MovieClip;
      
      private var m_dsLockIconMc:MovieClip;
      
      private var m_sdLockIconMc:MovieClip;
      
      private var m_ssLockIconMc:MovieClip;
      
      private var m_bdLockIconMc:MovieClip;
      
      private var m_bsLockIconMc:MovieClip;
      
      private var m_toggleScreen:FarmAnimatedTextButton;
      
      private var m_dailyRewardNameTf:ZwTextField;
      
      private var m_staticFtueStep1:MovieClip;
      
      private var m_staticFtueStep2:MovieClip;
      
      private var m_staticFtueStep3:MovieClip;
      
      private var m_staticFtueStep4:MovieClip;
      
      private var m_m_staticFtueHitarea1_mc:MovieClip;
      
      private var m_m_staticFtueHitarea2_mc:MovieClip;
      
      private var m_m_staticFtueHitarea3_mc:MovieClip;
      
      private var m_m_staticFtueHitarea4_mc:MovieClip;
      
      private var m_weddingThemeNameTf:ZwTextField;
      
      private var m_npcCompetitionMc:MovieClip;
      
      private var m_npcLeaderboardMc:MovieClip;
      
      private var m_npcOBTLockMc:MovieClip;
      
      private var m_npcRemainigMc:MovieClip;
      
      private var m_npcStreakMc:MovieClip;
      
      private var m_npcDecoMc:MovieClip;
      
      private var m_dailCheckmarkMc:MovieClip;
      
      private var m_rewardLockout:MovieClip;
      
      private var m_npcRemainigNewMc:MovieClip;
      
      private var m_npcWarningMc:MovieClip;
      
      private var m_timerNPC1:Timer;
      
      private var m_timerNPC2:Timer;
      
      private var m_timerNPC3:Timer;
      
      private var m_timerNPC4:Timer;
      
      private var m_timerNPC5:Timer;
      
      private var m_timerNPC6:Timer;
      
      private var m_timerNPC7:Timer;
      
      private var m_specialDecoTf:ZwTextField;
      
      private var m_basicDecoTf:ZwTextField;
      
      private var m_bestDecoTf:ZwTextField;
      
      public function BoraBoraInnovationMainWindow(featureName:String = "BoraBoraInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var player_mc_key:String = null;
         var index:int = 0;
         var m_decoPanelMc:MovieClip = null;
         var weddingTimer:MovieClip = null;
         var currentStarCount:int = 0;
         var milestoneData:Object = null;
         var totalStar:int = 0;
         var dailyreward_mc:MovieClip = null;
         var i:int = 0;
         var starNameEA:String = null;
         var starNameGA:String = null;
         var ftueIndex:int = 0;
         var buttonName:String = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
         }
         if(m_window.hasOwnProperty("feature_timer_tf"))
         {
            addWidget(this.m_featuretime_tf = new ZwTextField(m_window["feature_timer_tf"],""));
            this.m_featuretime_tf.visible = true;
         }
         if(m_window.hasOwnProperty("bora_money_mc"))
         {
            this.m_boramoney_mc = m_window["bora_money_mc"] as MovieClip;
            if(this.m_boramoney_mc.hasOwnProperty("bora_money_count_tf"))
            {
               addWidget(this.m_boramoney_count_tf = new ZwTextField(this.m_boramoney_mc["bora_money_count_tf"],this.manager.getOrderboardProgress().toString()));
            }
            if(this.m_boramoney_mc.hasOwnProperty("earn_bt"))
            {
               addWidget(this.m_earn_bt = new FarmAnimatedTextButton(this.m_boramoney_mc["earn_bt"],"Earn More!",this.onViewOrderboardClick));
            }
            this.m_boramoney_mc.visible = true;
            this.refreshBoraboraMoney();
         }
         if(m_window.hasOwnProperty("leader_board_mc"))
         {
            this.m_leaderboardpane_mc = m_window["leader_board_mc"] as MovieClip;
            this.m_leaderboardpane_mc.visible = true;
            if(this.m_leaderboardpane_mc.hasOwnProperty("view_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_leaderboardpane_mc["view_bt"],"View!",this.onViewLeaderboardClick));
            }
            if(this.m_leaderboardpane_mc.hasOwnProperty("norank_tf"))
            {
               addWidget(this.m_norank_tf = new ZwTextField(this.m_leaderboardpane_mc["norank_tf"],"Earn Thumbs Up Points this week to compete! Click view to see your current standing."));
               this.m_norank_tf.visible = true;
            }
            for(index = 0; index < 3; index++)
            {
               player_mc_key = "player" + index.toString() + "_mc";
               if(this.m_leaderboardpane_mc.hasOwnProperty(player_mc_key))
               {
                  this.m_players_mc[index] = this.m_leaderboardpane_mc[player_mc_key] as MovieClip;
                  this.m_players_mc[index].visible = false;
               }
            }
            if(this.manager.m_leaderboardpane_data)
            {
               this.showLeaderboardPaneData();
            }
         }
         if(m_window.hasOwnProperty("deco_panel_mc"))
         {
            m_decoPanelMc = m_window["deco_panel_mc"] as MovieClip;
            m_decoPanelMc.visible = true;
            if(m_decoPanelMc.hasOwnProperty("client_name_tf"))
            {
               addWidget(this.m_npcNames = new ZwTextField(m_decoPanelMc["client_name_tf"],this.manager.getCycleNPCNames() + "\'s Wedding"));
               this.m_npcNames.visible = true;
            }
            if(m_decoPanelMc.hasOwnProperty("client_pic_mc"))
            {
               if(m_decoPanelMc.hasOwnProperty("client_pic_mc"))
               {
                  addWidget(this.m_npcIcon = new FarmIcon(m_decoPanelMc["client_pic_mc"]));
                  this.m_npcIcon.loadIcon(this.manager.getCycleNPCImage());
                  this.m_npcIcon.visible = true;
               }
            }
            if(m_decoPanelMc.hasOwnProperty("decohowDoesThisWork_mc"))
            {
               addWidget(this.m_decowhatIsThisBt = new FarmAnimatedTextButton(m_decoPanelMc["decohowDoesThisWork_mc"],"",this.onDecoHowDoesThisWorkClick));
               this.m_decowhatIsThisBt.visible = true;
            }
            if(m_decoPanelMc.hasOwnProperty("wedding_timer_mc"))
            {
               weddingTimer = m_decoPanelMc["wedding_timer_mc"] as MovieClip;
               weddingTimer.visible = true;
               if(weddingTimer.hasOwnProperty("time_left_tf"))
               {
                  addWidget(this.m_weddingTimer = new ZwTextField(weddingTimer["time_left_tf"],""));
                  this.m_weddingTimer.visible = true;
                  this.m_weddingTimer.attachTooltip(new FarmTextTooltip("Their wedding will start in a few days! Let’s make sure to get all the decor in by then."));
               }
               if(weddingTimer.hasOwnProperty("theme_name_tf"))
               {
                  addWidget(this.m_weddingThemeNameTf = new ZwTextField(weddingTimer["theme_name_tf"],this.manager.getCycleNames()));
                  this.m_weddingThemeNameTf.visible = true;
               }
            }
            if(m_decoPanelMc.hasOwnProperty("all_tabs_mc"))
            {
               this.m_allTabsMc = m_decoPanelMc["all_tabs_mc"] as MovieClip;
               this.m_allTabsMc.visible = true;
               currentStarCount = this.manager.getCurrentStarCount();
               if(this.m_allTabsMc.hasOwnProperty("basic_mc"))
               {
                  this.m_basicDecoPanel = this.m_allTabsMc["basic_mc"] as MovieClip;
                  this.m_basicPanelFrame = new BoraboraInnovationBasicDecoFrame(this.m_basicDecoPanel["all_deco_items_mc"],this.m_featureName);
                  this.m_basicPanelFrame.visible = true;
                  this.m_basicDecoPanel.visible = true;
               }
               if(this.m_basicDecoPanel.hasOwnProperty("basic_tf"))
               {
                  addWidget(this.m_basicDecoTf = new ZwTextField(this.m_basicDecoPanel["basic_tf"],""));
                  this.m_basicDecoTf.visible = true;
                  if(currentStarCount < 1)
                  {
                     this.m_basicDecoTf.text = "Get 1 Star and unlock more assets!";
                  }
                  else if(currentStarCount >= 1 && currentStarCount < 2)
                  {
                     this.m_basicDecoTf.text = "Get 1 more star and unlock all the assets!";
                  }
                  else
                  {
                     this.m_basicDecoTf.text = "Design the best wedding with all these decorations!";
                  }
               }
               if(this.m_basicDecoPanel.hasOwnProperty("basic_decor_lock_icon_mc"))
               {
                  this.m_bdLockIconMc = this.m_basicDecoPanel["basic_decor_lock_icon_mc"] as MovieClip;
                  this.m_bdLockIconMc.visible = false;
               }
               if(this.m_basicDecoPanel.hasOwnProperty("basic_special_lock_icon_mc"))
               {
                  this.m_bsLockIconMc = this.m_basicDecoPanel["basic_special_lock_icon_mc"] as MovieClip;
                  this.m_bsLockIconMc.visible = false;
               }
               if(this.m_allTabsMc.hasOwnProperty("basic_tab_button_mc"))
               {
                  addWidget(this.m_basicTabButton = new FarmAnimatedTextButton(this.m_allTabsMc["basic_tab_button_mc"],"Basic",this.onBasicPanelClick));
                  this.m_basicTabButton.visible = true;
               }
               if(this.m_allTabsMc.hasOwnProperty("decor_mc"))
               {
                  this.m_decorDecoPanel = this.m_allTabsMc["decor_mc"] as MovieClip;
                  this.m_decorPanelFrame = new BoraboraInnovationDecorDecoFrame(this.m_decorDecoPanel["all_deco_items_mc"],this.m_featureName);
                  this.m_decorPanelFrame.visible = false;
                  this.m_decorDecoPanel.visible = false;
               }
               if(this.m_decorDecoPanel.hasOwnProperty("special_tf"))
               {
                  addWidget(this.m_specialDecoTf = new ZwTextField(this.m_decorDecoPanel["special_tf"],""));
                  this.m_specialDecoTf.visible = true;
                  if(currentStarCount < 1)
                  {
                     this.m_specialDecoTf.text = "Get 1 Star and unlock these assets!";
                  }
                  else if(currentStarCount >= 1 && currentStarCount < 2)
                  {
                     this.m_specialDecoTf.text = "Every wedding needs a custom aisle and tables!";
                  }
                  else
                  {
                     this.m_specialDecoTf.text = "Every wedding needs a custom aisle and tables!";
                  }
               }
               if(this.m_decorDecoPanel.hasOwnProperty("decor_decor_lock_icon_mc"))
               {
                  this.m_ddLockIconMc = this.m_decorDecoPanel["decor_decor_lock_icon_mc"] as MovieClip;
                  this.m_ddLockIconMc.visible = false;
               }
               if(this.m_decorDecoPanel.hasOwnProperty("decor_special_lock_icon_mc"))
               {
                  this.m_dsLockIconMc = this.m_decorDecoPanel["decor_special_lock_icon_mc"] as MovieClip;
                  this.m_dsLockIconMc.visible = false;
               }
               if(this.m_decorDecoPanel.hasOwnProperty("decor_lock_mc"))
               {
                  this.m_decorLockMc = this.m_decorDecoPanel["decor_lock_mc"] as MovieClip;
                  this.m_decorLockMc.visible = false;
               }
               if(this.m_decorDecoPanel.hasOwnProperty("decor_lock_icon_mc"))
               {
                  this.m_decorLockIconMc = this.m_decorDecoPanel["decor_lock_icon_mc"] as MovieClip;
                  this.m_decorLockIconMc.visible = false;
               }
               if(this.m_allTabsMc.hasOwnProperty("decor_tab_button_mc"))
               {
                  addWidget(this.m_decorTabButton = new FarmAnimatedTextButton(this.m_allTabsMc["decor_tab_button_mc"],"Decor",this.onDecorPanelClick));
                  this.m_decorTabButton.visible = true;
                  this.m_decorTabButton.attachTooltip(new FarmTextTooltip("Click here to see more decor and how to get them."));
               }
               if(this.m_allTabsMc.hasOwnProperty("special_mc"))
               {
                  this.m_specialDecoPanel = this.m_allTabsMc["special_mc"] as MovieClip;
                  this.m_specialPanelFrame = new BoraboraInnovationSpecialDecoFrame(this.m_specialDecoPanel["all_deco_items_mc"],this.m_featureName);
                  this.m_specialPanelFrame.visible = false;
                  this.m_specialDecoPanel.visible = false;
               }
               if(this.m_specialDecoPanel.hasOwnProperty("best_tf"))
               {
                  addWidget(this.m_bestDecoTf = new ZwTextField(this.m_specialDecoPanel["best_tf"],""));
                  this.m_bestDecoTf.visible = true;
                  if(currentStarCount < 1)
                  {
                     this.m_bestDecoTf.text = "Get 2 Star and unlock these assets!";
                  }
                  else if(currentStarCount >= 1 && currentStarCount < 2)
                  {
                     this.m_bestDecoTf.text = "Get 2 Star and unlock these assets!";
                  }
                  else
                  {
                     this.m_bestDecoTf.text = "This wedding calls for the best of the best!";
                  }
               }
               if(this.m_specialDecoPanel.hasOwnProperty("special_lock_mc"))
               {
                  this.m_specialLockMc = this.m_specialDecoPanel["special_lock_mc"] as MovieClip;
                  this.m_specialLockMc.visible = false;
               }
               if(this.m_specialDecoPanel.hasOwnProperty("special_lock_icon_mc"))
               {
                  this.m_specialLockIconMc = this.m_specialDecoPanel["special_lock_icon_mc"] as MovieClip;
                  this.m_specialLockIconMc.visible = false;
               }
               if(this.m_specialDecoPanel.hasOwnProperty("special_decor_lock_icon_mc"))
               {
                  this.m_sdLockIconMc = this.m_specialDecoPanel["special_decor_lock_icon_mc"] as MovieClip;
                  this.m_sdLockIconMc.visible = false;
               }
               if(this.m_specialDecoPanel.hasOwnProperty("special_special_lock_icon_mc"))
               {
                  this.m_ssLockIconMc = this.m_specialDecoPanel["special_special_lock_icon_mc"] as MovieClip;
                  this.m_ssLockIconMc.visible = false;
               }
               if(this.m_allTabsMc.hasOwnProperty("special_tab_button_mc"))
               {
                  addWidget(this.m_specialTabButton = new FarmAnimatedTextButton(this.m_allTabsMc["special_tab_button_mc"],"Special",this.onSpecialPanelClick));
                  this.m_specialTabButton.visible = true;
                  this.m_specialTabButton.attachTooltip(new FarmTextTooltip("Click here to see more decor and how to get them"));
               }
            }
         }
         if(m_window.hasOwnProperty("reward_panel_mc"))
         {
            this.m_rewardspane_mc = m_window["reward_panel_mc"] as MovieClip;
            milestoneData = this.manager.getNextMilestoneData();
            if(this.m_rewardspane_mc.hasOwnProperty("share_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_rewardspane_mc["share_bt"],"View!",this.onViewRewardsClick));
            }
            if(this.m_rewardspane_mc.hasOwnProperty("next_reward_icon_mc"))
            {
               addWidget(this.m_nextreward_icon = new FarmIcon(this.m_rewardspane_mc["next_reward_icon_mc"]));
               if(milestoneData.hasOwnProperty("icon"))
               {
                  this.m_nextreward_icon.loadIcon(milestoneData["icon"]);
                  this.m_nextreward_icon.setIconSize(50,50);
                  this.m_nextreward_icon.attachTooltip(new FarmTextTooltip(milestoneData["rewardName"]));
                  this.m_nextreward_icon.visible = true;
               }
            }
            totalStar = this.manager.getTotalStars();
            totalStar = totalStar >= 170 ? 170 : totalStar;
            if(this.m_rewardspane_mc.hasOwnProperty("next_reward_count_tf"))
            {
               addWidget(this.m_nextreward_tf = new ZwTextField(this.m_rewardspane_mc["next_reward_count_tf"]));
               if(milestoneData.hasOwnProperty("starCount"))
               {
                  this.m_nextreward_tf.text = totalStar.toString() + "/" + milestoneData["starCount"];
               }
            }
            if(this.m_rewardspane_mc.hasOwnProperty("reward_lockout_mc"))
            {
               this.m_rewardLockout = this.m_rewardspane_mc["reward_lockout_mc"] as MovieClip;
               this.m_rewardLockout.visible = totalStar >= 170;
            }
            if(totalStar >= 170)
            {
               this.m_nextreward_icon.visible = false;
               this.m_nextreward_tf.visible = false;
               this.m_rewardLockout.visible = true;
            }
            else
            {
               this.m_nextreward_icon.visible = true;
               this.m_nextreward_tf.visible = true;
               this.m_rewardLockout.visible = false;
            }
            this.m_rewardspane_mc.visible = true;
         }
         if(m_window.hasOwnProperty("hover_daily_reward_mc"))
         {
            this.m_dailyhover_mc = m_window["hover_daily_reward_mc"] as MovieClip;
            this.m_dailyhover_mc.visible = false;
            if(this.m_dailyhover_mc.hasOwnProperty("daily_reward_icon_popup_mc"))
            {
               addWidget(this.m_hovereward_icon = new FarmIcon(this.m_dailyhover_mc["daily_reward_icon_popup_mc"]));
            }
            if(this.m_dailyhover_mc.hasOwnProperty("daily_timer_tf"))
            {
               addWidget(this.m_rewardtimer_tf = new ZwTextField(this.m_dailyhover_mc["daily_timer_tf"]));
            }
            if(this.m_dailyhover_mc.hasOwnProperty("reward_name_tf"))
            {
               addWidget(this.m_dailyreward_name_tf = new ZwTextField(this.m_dailyhover_mc["reward_name_tf"]));
            }
         }
         if(m_window.hasOwnProperty("daily_reward_mc"))
         {
            dailyreward_mc = m_window["daily_reward_mc"] as MovieClip;
            if(dailyreward_mc.hasOwnProperty("daily_reward_icon_mc"))
            {
               addWidget(this.m_dailyreward_icon = new FarmIcon(dailyreward_mc["daily_reward_icon_mc"]));
            }
            if(dailyreward_mc.hasOwnProperty("daily_reward_count_tf"))
            {
               addWidget(this.m_dailycount_tf = new ZwTextField(dailyreward_mc["daily_reward_count_tf"]));
            }
            if(dailyreward_mc.hasOwnProperty("checkmark_mc"))
            {
               this.m_dailCheckmarkMc = dailyreward_mc["checkmark_mc"] as MovieClip;
               this.m_dailCheckmarkMc.visible = false;
            }
            dailyreward_mc.visible = true;
            dailyreward_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardMouseOver);
            dailyreward_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onRewardMouseOut);
         }
         if(m_window.hasOwnProperty("newdailyreward_tabv"))
         {
            this.m_startnewday_mc = m_window["newdailyreward_tabv"] as MovieClip;
            this.m_startnewday_mc.visible = false;
            if(this.m_startnewday_mc.hasOwnProperty("ok_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_startnewday_mc["ok_bt"],"Great!",this.onStartNewDayClick));
            }
            if(this.m_startnewday_mc.hasOwnProperty("newreward_brief"))
            {
               addWidget(new ZwTextField(this.m_startnewday_mc["newreward_brief"],"New day a new reward! \n Collect a minimum of 175 thumbs up points by the end of the day to earn this."));
            }
            if(this.m_startnewday_mc.hasOwnProperty("newrewardtitle_tf"))
            {
               addWidget(this.m_dailyRewardNameTf = new ZwTextField(this.m_startnewday_mc["newrewardtitle_tf"],""));
            }
            if(this.m_startnewday_mc.hasOwnProperty("nextreward_icon"))
            {
               this.m_newreward_icon = new FarmIcon(this.m_startnewday_mc["nextreward_icon"]);
            }
         }
         if(m_window.hasOwnProperty("newproduce_tab"))
         {
            this.m_startweek_mc = m_window["newproduce_tab"] as MovieClip;
            this.m_startweek_mc.visible = false;
            if(this.m_startweek_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_startweek_mc["okay_bt"],"Great!",this.onStartNewWeekClick));
            }
            if(this.m_startweek_mc.hasOwnProperty("wnewreward_brief"))
            {
               addWidget(this.m_newweekbody_tf = new ZwTextField(this.m_startweek_mc["wnewreward_brief"],"It\'s a new week with new rewards! \n The leaderboards have been reset, all the best!"));
            }
            if(this.m_startweek_mc.hasOwnProperty("wnextreward_icon"))
            {
               this.m_newweeklyproduce_icon = new FarmIcon(this.m_startweek_mc["wnextreward_icon"]);
            }
         }
         if(m_window.hasOwnProperty("tranjaction_tab"))
         {
            m_window["tranjaction_tab"].visible = false;
         }
         if(m_window.hasOwnProperty("ea_hover_streak_mc"))
         {
            this.m_starhoverEA_mc = m_window["ea_hover_streak_mc"] as MovieClip;
            this.m_starhoverEA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("ga_hover_streak_mc"))
         {
            this.m_starhoverGA_mc = m_window["ga_hover_streak_mc"] as MovieClip;
            this.m_starhoverGA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("ea_meter_mc"))
         {
            this.m_starProgressEA_mc = m_window["ea_meter_mc"] as MovieClip;
            this.m_starProgressEA_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStarsMouseOver);
            this.m_starProgressEA_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStarsMouseOut);
            if(this.m_starProgressEA_mc.hasOwnProperty("ea_fill_meter_mc"))
            {
               this.m_meterEA_mc = this.m_starProgressEA_mc["ea_fill_meter_mc"] as MovieClip;
               if(this.m_meterEA_mc.hasOwnProperty("ea_bar_fill_mc"))
               {
                  this.m_barfillEA_mc = this.m_meterEA_mc["ea_bar_fill_mc"] as MovieClip;
               }
            }
            for(i = 0; i <= 6; i++)
            {
               starNameEA = "ea_filled_" + i.toString() + "_mc";
               if(this.m_starProgressEA_mc.hasOwnProperty(starNameEA))
               {
                  this.m_starfills_EA[i] = this.m_starProgressEA_mc[starNameEA] as MovieClip;
                  this.m_starfills_EA[i].visible = false;
               }
            }
            if(this.m_starProgressEA_mc.hasOwnProperty("ea_thumbs_up_count_0_mc"))
            {
               this.m_thumbsCountEA_mc = this.m_starProgressEA_mc["ea_thumbs_up_count_0_mc"] as MovieClip;
            }
            this.m_starProgressEA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("ga_meter_mc"))
         {
            this.m_starProgressGA_mc = m_window["ga_meter_mc"] as MovieClip;
            this.m_starProgressGA_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStarsMouseOver);
            this.m_starProgressGA_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStarsMouseOut);
            if(this.m_starProgressGA_mc.hasOwnProperty("ga_fill_meter_mc"))
            {
               this.m_meterGA_mc = this.m_starProgressGA_mc["ga_fill_meter_mc"] as MovieClip;
               if(this.m_meterGA_mc.hasOwnProperty("ga_bar_fill_mc"))
               {
                  this.m_barfillGA_mc = this.m_meterGA_mc["ga_bar_fill_mc"] as MovieClip;
               }
            }
            for(i = 0; i <= 4; i++)
            {
               starNameGA = "ga_filled_" + i.toString() + "_mc";
               if(this.m_starProgressGA_mc.hasOwnProperty(starNameGA))
               {
                  this.m_starfills_GA[i] = this.m_starProgressGA_mc[starNameGA] as MovieClip;
                  this.m_starfills_GA[i].visible = false;
               }
            }
            if(this.m_starProgressGA_mc.hasOwnProperty("ga_thumbs_up_count_0_mc"))
            {
               this.m_thumbsCountGA_mc = this.m_starProgressGA_mc["ga_thumbs_up_count_0_mc"] as MovieClip;
            }
            this.m_starProgressGA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("hover_competition_mc"))
         {
            this.m_hovercompete_mc = m_window["hover_competition_mc"] as MovieClip;
            this.m_hovercompete_mc.visible = false;
         }
         if(m_window.hasOwnProperty("weekly_competition_mc"))
         {
            this.m_weeklycompete_mc = m_window["weekly_competition_mc"] as MovieClip;
            this.m_weeklycompete_mc.visible = true;
            this.m_weeklycompete_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onCompetitionMouseOver);
            this.m_weeklycompete_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onCompetitionMouseOut);
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            (m_window["ftue_mc"] as MovieClip).visible = false;
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_tutorialMc = m_window["ftue_mc"] as MovieClip;
            m_tutorial = addWidget(new ZwFrame(this.m_tutorialMc),false) as ZwFrame;
            if(this.m_tutorialMc)
            {
               for(ftueIndex = 0; ftueIndex < 12; ftueIndex++)
               {
                  buttonName = "okay_" + ftueIndex.toString() + "_bt";
                  if(this.m_tutorialMc.hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[ftueIndex] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName]);
                     this.m_tutorialButtons[ftueIndex].visible = false;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],"",this.onHowDoesThisWorkClick));
            this.m_whatIsThisBt.visible = true;
         }
         if(m_window.hasOwnProperty("panel_tutorial_mc"))
         {
            this.m_staticFtue = m_window["panel_tutorial_mc"] as MovieClip;
            this.m_staticFtue.visible = false;
            if(this.m_staticFtue.hasOwnProperty("header_tf"))
            {
               addWidget(new ZwTextField(this.m_staticFtue["header_tf"],"BORA BORA"));
            }
            if(this.m_staticFtue.hasOwnProperty("okay_ft_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_staticFtue["okay_ft_bt"],"Okay!",this.onStaticFtueClose));
            }
            if(this.m_staticFtue.hasOwnProperty("step_1_desc_mc"))
            {
               this.m_staticFtueStep1 = this.m_staticFtue["step_1_desc_mc"] as MovieClip;
               this.m_staticFtueStep1.visible = false;
            }
            if(this.m_staticFtue.hasOwnProperty("step_1_hitarea_mc"))
            {
               this.m_m_staticFtueHitarea1_mc = this.m_staticFtue["step_1_hitarea_mc"] as MovieClip;
               this.m_m_staticFtueHitarea1_mc.visible = true;
               this.m_m_staticFtueHitarea1_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStaticFtueStep1MouseOver);
               this.m_m_staticFtueHitarea1_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStaticFtueStep1MouseOut);
            }
            if(this.m_staticFtue.hasOwnProperty("step_2_desc_mc"))
            {
               this.m_staticFtueStep2 = this.m_staticFtue["step_2_desc_mc"] as MovieClip;
               this.m_staticFtueStep2.visible = false;
            }
            if(this.m_staticFtue.hasOwnProperty("step_2_hitarea_mc"))
            {
               this.m_m_staticFtueHitarea2_mc = this.m_staticFtue["step_2_hitarea_mc"] as MovieClip;
               this.m_m_staticFtueHitarea2_mc.visible = true;
               this.m_m_staticFtueHitarea2_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStaticFtueStep2MouseOver);
               this.m_m_staticFtueHitarea2_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStaticFtueStep2MouseOut);
            }
            if(this.m_staticFtue.hasOwnProperty("step_3_desc_mc"))
            {
               this.m_staticFtueStep3 = this.m_staticFtue["step_3_desc_mc"] as MovieClip;
               this.m_staticFtueStep3.visible = false;
            }
            if(this.m_staticFtue.hasOwnProperty("step_3_hitarea_mc"))
            {
               this.m_m_staticFtueHitarea3_mc = this.m_staticFtue["step_3_hitarea_mc"] as MovieClip;
               this.m_m_staticFtueHitarea3_mc.visible = true;
               this.m_m_staticFtueHitarea3_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStaticFtueStep3MouseOver);
               this.m_m_staticFtueHitarea3_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStaticFtueStep3MouseOut);
            }
            if(this.m_staticFtue.hasOwnProperty("step_4_desc_mc"))
            {
               this.m_staticFtueStep4 = this.m_staticFtue["step_4_desc_mc"] as MovieClip;
               this.m_staticFtueStep4.visible = false;
            }
            if(this.m_staticFtue.hasOwnProperty("step_4_hitarea_mc"))
            {
               this.m_m_staticFtueHitarea4_mc = this.m_staticFtue["step_4_hitarea_mc"] as MovieClip;
               this.m_m_staticFtueHitarea4_mc.visible = true;
               this.m_m_staticFtueHitarea4_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onStaticFtueStep4MouseOver);
               this.m_m_staticFtueHitarea4_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onStaticFtueStep4MouseOut);
            }
         }
         if(m_window.hasOwnProperty("deco_tutorial_mc"))
         {
            this.m_panelFTUE = m_window["deco_tutorial_mc"] as MovieClip;
            this.m_panelFTUE.visible = false;
            if(this.m_panelFTUE.hasOwnProperty("okay_tutorial_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_panelFTUE["okay_tutorial_bt"],"Okay!",this.onPanelFtueClose));
            }
         }
         if(m_window.hasOwnProperty("load_animation_mc"))
         {
            this.m_loadCycleLoadAnimation = m_window["load_animation_mc"] as MovieClip;
            this.m_loadCycleLoadAnimation.visible = false;
         }
         if(m_window.hasOwnProperty("toggle_full_bt"))
         {
            addWidget(this.m_toggleScreen = new FarmAnimatedTextButton(m_window["toggle_full_bt"],"Okay!",null));
            this.m_toggleScreen.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_competition_mc"))
         {
            this.m_npcCompetitionMc = m_window["npc_callout_competition_mc"] as MovieClip;
            if(this.m_npcCompetitionMc.hasOwnProperty("competition_callout_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcCompetitionMc["competition_callout_okay_bt"],"Okay!",this.onNpcCompetition));
               this.m_npcCompetitionMc["competition_callout_okay_bt"].visible = false;
            }
            if(this.m_npcCompetitionMc.hasOwnProperty("competition_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcCompetitionMc["competition_callout_tf"],"The wedding is coming out great, why don\'t try entering the wedding decoration competition!"));
            }
            this.m_npcCompetitionMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_leaderboard_mc"))
         {
            this.m_npcLeaderboardMc = m_window["npc_callout_leaderboard_mc"] as MovieClip;
            if(this.m_npcLeaderboardMc.hasOwnProperty("leaderboard_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcLeaderboardMc["leaderboard_okay_bt"],"Okay!",this.onNpcLeaderboard));
               this.m_npcLeaderboardMc["leaderboard_okay_bt"].visible = false;
            }
            if(this.m_npcLeaderboardMc.hasOwnProperty("leaderboard_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcLeaderboardMc["leaderboard_callout_tf"],"The thumbs up you earn each week are counted towards leaderboard. Compete to win rewards!"));
            }
            this.m_npcLeaderboardMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_obt_lock_mc"))
         {
            this.m_npcOBTLockMc = m_window["npc_callout_obt_lock_mc"] as MovieClip;
            if(this.m_npcOBTLockMc.hasOwnProperty("obtlockout_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcOBTLockMc["obtlockout_okay_bt"],"Okay!",this.onNpcOBTLock));
               this.m_npcOBTLockMc["obtlockout_okay_bt"].visible = false;
            }
            if(this.m_npcOBTLockMc.hasOwnProperty("obt_lock_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcOBTLockMc["obt_lock_callout_tf"],"Now that we have enough borabora money, let\'s buy more items and finish decorating the wedding!"));
            }
            this.m_npcOBTLockMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_remaining_mc"))
         {
            this.m_npcRemainigMc = m_window["npc_callout_remaining_mc"] as MovieClip;
            if(this.m_npcRemainigMc.hasOwnProperty("remaining_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcRemainigMc["remaining_okay_bt"],"Okay!",this.onNpcRemainig));
               this.m_npcRemainigMc["remaining_okay_bt"].visible = false;
            }
            if(this.m_npcRemainigMc.hasOwnProperty("remaining_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcRemainigMc["remaining_callout_tf"],"There are only 2 days before the wedding! \n We better hurry up get a better star rating\n"));
            }
            this.m_npcRemainigMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_remaining_new_mc"))
         {
            this.m_npcRemainigNewMc = m_window["npc_callout_remaining_new_mc"] as MovieClip;
            if(this.m_npcRemainigNewMc.hasOwnProperty("remaining_new_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcRemainigNewMc["remaining_new_okay_bt"],"Okay!",this.onNpcRemainig));
               this.m_npcRemainigNewMc["remaining_new_okay_bt"].visible = false;
            }
            if(this.m_npcRemainigNewMc.hasOwnProperty("remaining_new_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcRemainigNewMc["remaining_new_callout_tf"],"It\'s the last day before the wedding! Let\'s make sure we do our best!"));
            }
            this.m_npcRemainigNewMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_streak_mc"))
         {
            this.m_npcStreakMc = m_window["npc_callout_streak_mc"] as MovieClip;
            if(this.m_npcStreakMc.hasOwnProperty("streak_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcStreakMc["streak_okay_bt"],"Okay!",this.onNpcStreak));
               this.m_npcStreakMc["streak_okay_bt"].visible = false;
            }
            if(this.m_npcStreakMc.hasOwnProperty("streak_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcStreakMc["streak_callout_tf"],"We are almost there! Just 1 more star and you\'ll get a bonus star."));
            }
            this.m_npcStreakMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_deco_mc"))
         {
            this.m_npcDecoMc = m_window["npc_callout_deco_mc"] as MovieClip;
            if(this.m_npcDecoMc.hasOwnProperty("deco_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcDecoMc["deco_okay_bt"],"Okay!",this.onNpcDeco));
               this.m_npcDecoMc["deco_okay_bt"].visible = false;
            }
            if(this.m_npcDecoMc.hasOwnProperty("obt_lock_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcDecoMc["obt_lock_callout_tf"],"Remember, you\'ll find all the decor you buy in your gift box at the end of the wedding!"));
            }
            this.m_npcDecoMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_callout_warning_mc"))
         {
            this.m_npcWarningMc = m_window["npc_callout_warning_mc"] as MovieClip;
            if(this.m_npcWarningMc.hasOwnProperty("warning_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_npcWarningMc["warning_okay_bt"],"Okay!",this.onNpcWarning));
            }
            if(this.m_npcWarningMc.hasOwnProperty("warning_callout_tf"))
            {
               addWidget(new ZwTextField(this.m_npcWarningMc["warning_callout_tf"],"These decorations are big! Remember there is limited space on the island, Design the wedding so that you don\'t run out of space!"));
            }
            this.m_npcWarningMc.visible = false;
         }
         this.handlePanelDisplay();
         this.handleDecoLockIcons();
         this.updateStarProgress(true);
         this.startTimer();
         if(!Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE1_FLAG) || !Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE2_FLAG) || !Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE3_FLAG))
         {
            this.showTutorial1();
         }
         if(!this.manager.isNPCFlagSet("npcLeaderboard") && this.manager.getCurrentThumbsUp() >= 40)
         {
            this.m_npcLeaderboardMc.visible = true;
            this.startTimerNPC1();
            this.manager.setNPCFlag("npcLeaderboard");
         }
         var starCount:int = this.manager.getCurrentStarCount();
         if(this.m_isEA)
         {
            if(!this.manager.isNPCFlagSet("npcStreakMc") && starCount == 6)
            {
               this.m_npcStreakMc.visible = true;
               this.startTimerNPC2();
               this.manager.setNPCFlag("npcStreakMc");
            }
         }
         else if(!this.manager.isNPCFlagSet("npcStreakMc") && starCount == 4)
         {
            this.m_npcStreakMc.visible = true;
            this.startTimerNPC2();
            this.manager.setNPCFlag("npcStreakMc");
         }
         if(!this.manager.isNPCFlagSet("npcRemainigMc") && HUD.getformattedTimeLeft(this.manager.getCycleTimeLeftUtil()) == "2 Days")
         {
            this.m_npcRemainigMc.visible = true;
            this.startTimerNPC3();
            this.manager.setNPCFlag("npcRemainigMc");
         }
         if(!this.manager.isNPCFlagSet("npcRemainigNewMc") && HUD.getformattedTimeLeft(this.manager.getCycleTimeLeftUtil()) == "1 Days")
         {
            this.m_npcRemainigNewMc.visible = true;
            this.startTimerNPC4();
            this.manager.setNPCFlag("npcRemainigNewMc");
         }
         if(this.manager.isNPCWaringActive())
         {
            this.m_npcWarningMc.visible = true;
         }
         this.manager.setNPCWarning();
         this.updateDailyRewardData();
         this.manager.grantDailyReward();
         if(this.manager.getCurrentStarCount() == 1 && !this.manager.isDecorStageLocked())
         {
            this.manager.setDecorStage();
            this.manager.showStageCompleteWindow(1);
         }
         else if(this.manager.getCurrentStarCount() == 2 && !this.manager.isSpecialrStageLocked())
         {
            this.manager.setSpecialStage();
            this.manager.showStageCompleteWindow(2);
         }
         var thumbs:int = this.manager.thumbsUps;
         if(thumbs >= this.manager.MAX_THUMBSUP)
         {
            if(this.manager.isCycleStartPopUp())
            {
               this.manager.showNewCycleStartWindow();
            }
            else
            {
               this.manager.cycleEndWindow();
            }
         }
         else
         {
            this.startCycleTimer();
         }
         if(this.manager.isShowMilestonePopup())
         {
            this.manager.showMilestoneRewardPopup();
         }
      }
      
      public function updateNewDayData(forced:Boolean = false) : void
      {
         var rewardItem:FarmItem = null;
         if(this.manager.hasActiveDayExpired() || forced)
         {
            this.stopTimer();
            rewardItem = this.manager.getNewDailyReward();
            if(rewardItem)
            {
               if(this.m_newreward_icon)
               {
                  this.m_newreward_icon.loadIcon(rewardItem.iconUrl);
               }
               if(this.m_dailyreward_icon)
               {
                  this.m_dailyreward_icon.loadIcon(rewardItem.iconUrl);
                  this.m_dailyreward_icon.setIconSize(50,50);
                  this.m_dailyreward_icon.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
               }
               if(this.m_dailyRewardNameTf)
               {
                  this.m_dailyRewardNameTf.text = rewardItem.friendlyTitle;
                  this.m_dailyRewardNameTf.visible = true;
               }
            }
            if(this.m_startnewday_mc)
            {
               this.m_startnewday_mc.visible = true;
            }
            if(this.manager.hasActiveWeekExpired() && this.manager.currentWeekIndex != 0)
            {
               if(this.m_newweeklyproduce_icon)
               {
                  this.m_newweeklyproduce_icon.loadIcon(rewardItem.iconUrl);
                  this.m_newweeklyproduce_icon.visible = true;
               }
               if(this.m_newweekbody_tf)
               {
                  this.m_newweekbody_tf.visible = true;
               }
               if(this.m_startweek_mc)
               {
                  this.m_startweek_mc.visible = true;
                  this.m_startnewday_mc.visible = false;
               }
            }
         }
      }
      
      public function updateStarProgress(onOpenWindow:Boolean = false) : void
      {
         var baseBarLength:int = 0;
         var pointsDelta:int = 0;
         var starWidth:int = 0;
         var thumbsPerStar:Array = null;
         var index:int = 0;
         var frameNum:int = 0;
         var currThumbs:int = this.manager.getCurrentThumbsUp();
         var currStars:int = this.manager.getCurrentStarCount();
         var totalBarLength:int = 0;
         if(this.manager.isUserEA)
         {
            if(Boolean(this.m_starProgressEA_mc) && Boolean(this.m_starProgressGA_mc))
            {
               this.m_starProgressGA_mc.visible = false;
               this.m_starProgressEA_mc.visible = true;
            }
            baseBarLength = this.STAR_SLOT_WIDTH_EA * currStars;
            thumbsPerStar = this.manager.m_thumbsPerStarEA;
            if(currStars >= this.MAX_STARS_EA)
            {
               totalBarLength = baseBarLength;
            }
            else
            {
               starWidth = thumbsPerStar[currStars + 1] - thumbsPerStar[currStars];
               pointsDelta = currThumbs - thumbsPerStar[currStars];
               totalBarLength = baseBarLength + this.STAR_SLOT_WIDTH_EA * pointsDelta / starWidth;
            }
            if(this.m_barfillEA_mc)
            {
               if(onOpenWindow == false)
               {
                  TweenMax.to(this.m_barfillEA_mc,2,{"x":totalBarLength});
               }
               else
               {
                  this.m_barfillEA_mc.x = totalBarLength;
               }
            }
            for(index = 0; index < currStars; index++)
            {
               if(this.m_starfills_EA[index])
               {
                  this.m_starfills_EA[index].visible = true;
               }
            }
            if(this.m_thumbsCountEA_mc)
            {
               frameNum = currStars == this.MAX_STARS_EA ? this.MAX_STARS_EA : int(currStars + 1);
               this.m_thumbsCountEA_mc.gotoAndStop(frameNum);
               this.m_thumbsCountEA_mc["ea_thumbs_up_count_tf"].text = currThumbs.toString() + "/" + thumbsPerStar[frameNum].toString();
            }
         }
         else
         {
            if(Boolean(this.m_starProgressGA_mc) && Boolean(this.m_starProgressEA_mc))
            {
               this.m_starProgressEA_mc.visible = false;
               this.m_starProgressGA_mc.visible = true;
            }
            baseBarLength = this.STAR_SLOT_WIDTH_GA * currStars;
            thumbsPerStar = this.manager.m_thumbsPerStarGA;
            if(currStars >= this.MAX_STARS_GA)
            {
               totalBarLength = baseBarLength;
            }
            else
            {
               starWidth = thumbsPerStar[currStars + 1] - thumbsPerStar[currStars];
               pointsDelta = currThumbs - thumbsPerStar[currStars];
               totalBarLength = baseBarLength + this.STAR_SLOT_WIDTH_GA * pointsDelta / starWidth;
            }
            if(this.m_barfillGA_mc)
            {
               if(onOpenWindow == false)
               {
                  TweenMax.to(this.m_barfillGA_mc,2,{"x":totalBarLength});
               }
               else
               {
                  this.m_barfillGA_mc.x = totalBarLength;
               }
            }
            for(index = 0; index < currStars; index++)
            {
               if(this.m_starfills_GA[index])
               {
                  this.m_starfills_GA[index].visible = true;
               }
            }
            if(this.m_thumbsCountGA_mc)
            {
               frameNum = currStars == this.MAX_STARS_GA ? this.MAX_STARS_GA : int(currStars + 1);
               this.m_thumbsCountGA_mc.gotoAndStop(frameNum);
               this.m_thumbsCountGA_mc["ga_thumbs_up_count_tf"].text = currThumbs.toString() + "/" + thumbsPerStar[frameNum].toString();
            }
         }
      }
      
      private function updateDailyRewardData() : void
      {
         var rewardItem:FarmItem = this.manager.getNewDailyReward();
         if(rewardItem)
         {
            if(this.m_dailyreward_icon)
            {
               this.m_dailyreward_icon.loadIcon(rewardItem.iconUrl);
               this.m_dailyreward_icon.setIconSize(50,50);
               this.m_dailyreward_icon.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
               this.m_dailyreward_icon.visible = true;
            }
            if(this.m_dailycount_tf)
            {
               this.m_dailycount_tf.text = Math.min(this.manager.getDayPoints(),175).toString() + "/175";
               this.m_dailycount_tf.visible = true;
            }
            if(this.m_dailyreward_name_tf)
            {
               this.m_dailyreward_name_tf.text = rewardItem.friendlyTitle;
            }
            if(this.m_hovereward_icon)
            {
               this.m_hovereward_icon.loadIcon(rewardItem.iconUrl);
               this.m_hovereward_icon.setIconSize(100,100);
               this.m_hovereward_icon.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
            }
            if(this.m_dailCheckmarkMc)
            {
               this.m_dailCheckmarkMc.visible = this.manager.getDayPoints() >= 175;
            }
         }
      }
      
      private function onViewOrderboardClick(e:Event = null) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
            this.manager.showOrderboardWindow();
         }
      }
      
      private function onViewLeaderboardClick(e:Event = null) : void
      {
         this.manager.showLeaderboardUI();
      }
      
      private function onViewRewardsClick(e:Event = null) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
            this.manager.showRewardsWindow();
         }
      }
      
      private function onStartNewDayClick(e:Event = null) : void
      {
         if(this.m_startnewday_mc)
         {
            this.m_startnewday_mc.visible = false;
         }
         if(!Global.player.getSeenFlag(this.FLAG_FIRST_STARTNEWDAY))
         {
            Global.player.setSeenFlag(this.FLAG_FIRST_STARTNEWDAY);
            this.startTimer();
         }
         else
         {
            this.tintWindow();
            this.enableInput = false;
            this.manager.startNewDay();
         }
      }
      
      private function onStartNewWeekClick(e:Event = null) : void
      {
         if(this.m_startweek_mc)
         {
            this.m_startweek_mc.visible = false;
         }
         this.tintWindow();
         this.enableInput = false;
         this.manager.startNewDay();
      }
      
      private function onRewardMouseOver(e:Event = null) : void
      {
         if(this.m_dailyhover_mc)
         {
            this.m_dailyhover_mc.visible = true;
         }
      }
      
      private function onCompetitionMouseOver(e:Event = null) : void
      {
         if(this.m_hovercompete_mc)
         {
            this.m_hovercompete_mc.visible = true;
         }
      }
      
      private function onCompetitionMouseOut(e:Event = null) : void
      {
         if(this.m_hovercompete_mc)
         {
            this.m_hovercompete_mc.visible = false;
         }
      }
      
      private function onStaticFtueStep1MouseOver(e:Event = null) : void
      {
         if(this.m_staticFtueStep1)
         {
            this.m_staticFtueStep1.visible = true;
         }
      }
      
      private function onStaticFtueStep1MouseOut(e:Event = null) : void
      {
         if(this.m_staticFtueStep1)
         {
            this.m_staticFtueStep1.visible = false;
         }
      }
      
      private function onStaticFtueStep2MouseOver(e:Event = null) : void
      {
         if(this.m_staticFtueStep2)
         {
            this.m_staticFtueStep2.visible = true;
         }
      }
      
      private function onStaticFtueStep2MouseOut(e:Event = null) : void
      {
         if(this.m_staticFtueStep2)
         {
            this.m_staticFtueStep2.visible = false;
         }
      }
      
      private function onStaticFtueStep3MouseOver(e:Event = null) : void
      {
         if(this.m_staticFtueStep3)
         {
            this.m_staticFtueStep3.visible = true;
         }
      }
      
      private function onStaticFtueStep3MouseOut(e:Event = null) : void
      {
         if(this.m_staticFtueStep3)
         {
            this.m_staticFtueStep3.visible = false;
         }
      }
      
      private function onStaticFtueStep4MouseOver(e:Event = null) : void
      {
         if(this.m_staticFtueStep4)
         {
            this.m_staticFtueStep4.visible = true;
         }
      }
      
      private function onStaticFtueStep4MouseOut(e:Event = null) : void
      {
         if(this.m_staticFtueStep4)
         {
            this.m_staticFtueStep4.visible = false;
         }
      }
      
      private function onRewardMouseOut(e:Event = null) : void
      {
         if(this.m_dailyhover_mc)
         {
            this.m_dailyhover_mc.visible = false;
         }
      }
      
      private function onStarsMouseOver(e:Event = null) : void
      {
         if(this.manager.isUserEA)
         {
            if(this.m_starhoverEA_mc)
            {
               this.m_starhoverEA_mc.visible = true;
            }
         }
         else if(this.m_starhoverGA_mc)
         {
            this.m_starhoverGA_mc.visible = true;
         }
      }
      
      private function onStarsMouseOut(e:Event = null) : void
      {
         if(Boolean(this.m_starhoverEA_mc) && Boolean(this.m_starhoverGA_mc))
         {
            this.m_starhoverEA_mc.visible = false;
            this.m_starhoverGA_mc.visible = false;
         }
      }
      
      private function populateLeaderboardPaneData() : void
      {
         var index:int = 0;
         var playerData:Object = null;
         if(Boolean(m_window) && Boolean(this.m_leaderboardpane_mc) && Boolean(this.manager.m_leaderboardpane_data))
         {
            index = 0;
            if(this.m_norank_tf)
            {
               this.m_norank_tf.visible = false;
            }
            if(this.m_players_mc)
            {
               this.m_players_mc.visible = true;
            }
            for each(playerData in this.manager.m_leaderboardpane_data)
            {
               if(playerData)
               {
                  if(playerData["name"])
                  {
                     this.setPlayerNameTf(index,playerData["name"]);
                  }
                  else if(playerData["value"])
                  {
                     this.setPlayerNameTf(index,playerData["value"]);
                  }
                  else
                  {
                     this.setPlayerNameTf(index,"---");
                  }
                  if(playerData["rank"])
                  {
                     this.setPlayerRankTf(index,playerData["rank"]);
                  }
                  else
                  {
                     this.setPlayerRankTf(index,"-");
                  }
               }
               index++;
            }
         }
         else
         {
            if(Boolean(m_window) && Boolean(this.m_players_mc))
            {
               this.m_players_mc.visible = false;
            }
            if(Boolean(m_window) && Boolean(this.m_norank_tf))
            {
               this.m_norank_tf.visible = true;
            }
         }
      }
      
      private function setPlayerNameTf(index:int, name:String) : void
      {
         if(Boolean(this.m_players_mc[index]) && Boolean(this.m_players_mc[index].hasOwnProperty("playername_tf")))
         {
            this.m_players_mc[index]["playername_tf"].text = name;
         }
      }
      
      private function setPlayerRankTf(index:int, rank:String) : void
      {
         if(Boolean(this.m_players_mc[index]) && Boolean(this.m_players_mc[index].hasOwnProperty("player_rank_tf")))
         {
            this.m_players_mc[index]["player_rank_tf"].text = rank;
         }
      }
      
      private function showPlayersPane() : void
      {
         var index:int = 0;
         if(this.m_players_mc)
         {
            for(index = 0; index < 3; index++)
            {
               if(this.m_players_mc[index])
               {
                  this.m_players_mc[index].visible = true;
               }
            }
         }
      }
      
      public function showLeaderboardPaneData() : void
      {
         this.populateLeaderboardPaneData();
         this.showPlayersPane();
      }
      
      override public function refreshWindow() : void
      {
         this.updateStarProgress(false);
         this.updateDailyRewardData();
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(FEATURE_NAME);
      }
      
      public function handleDecoLockIcons() : void
      {
         if(this.m_decorLockIconMc)
         {
            this.m_decorLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
         }
         if(this.m_specialLockIconMc)
         {
            this.m_specialLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
         }
         if(this.m_bsLockIconMc)
         {
            this.m_bdLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
         }
         if(this.m_bsLockIconMc)
         {
            this.m_bsLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
         }
      }
      
      public function handleDecorLock() : void
      {
         if(this.m_decorLockMc)
         {
            this.m_decorLockMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
            if(this.m_decorLockMc.visible)
            {
               this.m_decorLockMc["ea_lock_icon_mc"].visible = this.manager.isUserEA;
            }
         }
         if(this.m_specialLockMc)
         {
            this.m_specialLockMc.visible = false;
         }
      }
      
      public function handleSpecialLock() : void
      {
         if(this.m_specialLockMc)
         {
            this.m_specialLockMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
            if(this.m_specialLockMc.visible)
            {
               this.m_specialLockMc["ea_special_lock_icon_mc"].visible = this.manager.isUserEA;
            }
         }
         if(this.m_decorLockMc)
         {
            this.m_decorLockMc.visible = false;
         }
      }
      
      public function handlePanelDisplay() : void
      {
         var panelVal:int = this.manager.getPanelDisplayValue();
         if(panelVal == 0)
         {
            if(Boolean(this.m_basicDecoPanel) && Boolean(this.m_basicPanelFrame))
            {
               this.m_basicDecoPanel.visible = true;
               this.m_basicPanelFrame.visible = true;
            }
            if(Boolean(this.m_specialLockMc) && Boolean(this.m_decorLockMc))
            {
               this.m_specialLockMc.visible = false;
               this.m_decorLockMc.visible = false;
            }
            if(this.m_bdLockIconMc)
            {
               this.m_bdLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
            }
            if(this.m_bsLockIconMc)
            {
               this.m_bsLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
            }
            this.disableDecorPanle();
            this.disableSpecialPanle();
         }
         else if(panelVal == 1)
         {
            if(Boolean(this.m_decorDecoPanel) && Boolean(this.m_decorPanelFrame))
            {
               this.m_decorDecoPanel.visible = true;
               this.m_decorPanelFrame.visible = true;
            }
            if(this.m_ddLockIconMc)
            {
               this.m_ddLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
            }
            if(this.m_dsLockIconMc)
            {
               this.m_dsLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
            }
            this.disableBasicPanle();
            this.disableSpecialPanle();
            this.handleDecorLock();
         }
         else
         {
            if(Boolean(this.m_specialDecoPanel) && Boolean(this.m_specialPanelFrame))
            {
               this.m_specialDecoPanel.visible = true;
               this.m_specialPanelFrame.visible = true;
            }
            if(this.m_sdLockIconMc)
            {
               this.m_sdLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
            }
            if(this.m_ssLockIconMc)
            {
               this.m_ssLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
            }
            this.disableBasicPanle();
            this.disableDecorPanle();
            this.handleSpecialLock();
         }
      }
      
      protected function onBasicPanelClick(e:Event = null) : void
      {
         if(Boolean(this.m_basicDecoPanel) && Boolean(this.m_basicPanelFrame))
         {
            this.m_basicDecoPanel.visible = true;
            this.m_basicPanelFrame.visible = true;
         }
         if(Boolean(this.m_specialLockMc) && Boolean(this.m_decorLockMc))
         {
            this.m_specialLockMc.visible = false;
            this.m_decorLockMc.visible = false;
         }
         if(this.m_bdLockIconMc)
         {
            this.m_bdLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
         }
         if(this.m_bsLockIconMc)
         {
            this.m_bsLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
         }
         this.disableDecorPanle();
         this.disableSpecialPanle();
      }
      
      protected function onDecorPanelClick(e:Event = null) : void
      {
         if(Boolean(this.m_decorDecoPanel) && Boolean(this.m_decorPanelFrame))
         {
            this.m_decorDecoPanel.visible = true;
            this.m_decorPanelFrame.visible = true;
         }
         if(this.m_ddLockIconMc)
         {
            this.m_ddLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
         }
         if(this.m_dsLockIconMc)
         {
            this.m_dsLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
         }
         this.disableBasicPanle();
         this.disableSpecialPanle();
         this.handleDecorLock();
      }
      
      protected function onSpecialPanelClick(e:Event = null) : void
      {
         if(Boolean(this.m_specialDecoPanel) && Boolean(this.m_specialPanelFrame))
         {
            this.m_specialDecoPanel.visible = true;
            this.m_specialPanelFrame.visible = true;
         }
         if(this.m_sdLockIconMc)
         {
            this.m_sdLockIconMc.visible = this.manager.getCurrentStarCount() < 1 ? true : false;
         }
         if(this.m_ssLockIconMc)
         {
            this.m_ssLockIconMc.visible = this.manager.getCurrentStarCount() < 2 ? true : false;
         }
         this.disableBasicPanle();
         this.disableDecorPanle();
         this.handleSpecialLock();
      }
      
      private function disableBasicPanle() : void
      {
         if(Boolean(this.m_basicDecoPanel) && Boolean(this.m_basicPanelFrame))
         {
            this.m_basicDecoPanel.visible = false;
            this.m_basicPanelFrame.visible = false;
            this.m_bdLockIconMc.visible = false;
            this.m_bsLockIconMc.visible = false;
         }
      }
      
      private function disableDecorPanle() : void
      {
         if(Boolean(this.m_decorDecoPanel) && Boolean(this.m_decorPanelFrame))
         {
            this.m_decorDecoPanel.visible = false;
            this.m_decorPanelFrame.visible = false;
            this.m_ddLockIconMc.visible = false;
            this.m_dsLockIconMc.visible = false;
         }
      }
      
      private function disableSpecialPanle() : void
      {
         if(Boolean(this.m_specialDecoPanel) && Boolean(this.m_specialPanelFrame))
         {
            this.m_specialDecoPanel.visible = false;
            this.m_specialPanelFrame.visible = false;
            this.m_sdLockIconMc.visible = true;
            this.m_ssLockIconMc.visible = true;
         }
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(!this.manager.isFeatureEnd())
         {
            this.updateNewDayData();
            this.refreshDailyTimerText();
         }
         else
         {
            this.manager.removeHud();
            this.manager.featureEndDeco();
            this.close();
         }
      }
      
      private function startCycleTimer() : void
      {
         this.m_cycleTimer = new Timer(1000);
         this.m_cycleTimer.addEventListener(TimerEvent.TIMER,this.onCycleTimer);
         this.m_cycleTimer.start();
      }
      
      private function onCycleTimer(event:TimerEvent) : void
      {
         if(!this.manager.hasActiveCycleExpired())
         {
            if(this.manager.isCycleTimerMaxToEndCycle())
            {
               this.m_weddingTimer.text = HUD.getformattedTimeLeft(this.manager.cycleEndTimerWithFeature());
            }
            else
            {
               this.m_weddingTimer.text = HUD.getformattedTimeLeft(this.manager.getCycleTimeLeftUtil());
            }
         }
         else
         {
            this.stopCycleTimer();
            if(this.manager.isCycleStartPopUp())
            {
               this.manager.showNewCycleStartWindow();
            }
            else
            {
               this.manager.cycleEndWindow();
            }
         }
      }
      
      private function refreshDailyTimerText() : void
      {
         if(this.m_rewardtimer_tf)
         {
            this.m_rewardtimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         }
         if(this.m_featuretime_tf)
         {
            this.m_featuretime_tf.text = this.manager.getFeatureTimeLeft();
            this.m_featuretime_tf.attachTooltip(new FarmTextTooltip("Conduct as many wedding and collect all stars you can before the end of Topical Ever After"));
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function stopCycleTimer() : void
      {
         if(this.m_cycleTimer)
         {
            this.m_cycleTimer.stop();
            this.m_cycleTimer.removeEventListener(TimerEvent.TIMER,this.onCycleTimer);
            this.m_cycleTimer = null;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.stopCycleTimer();
         this.manager.stopDecoMode();
         this.manager.setBoraboraInnovationMainWindowActive(false);
         super.close();
         FarmStatsManager.count("FarmersMarketMainWindow","Main_UI","close_window");
      }
      
      public function refreshBoraboraMoney() : void
      {
         var isEnoughBoraboraMoney:Boolean = false;
         if(this.m_boramoney_count_tf)
         {
            this.m_boramoney_count_tf.text = this.manager.getOrderboardProgress().toString();
         }
         if(this.m_earn_bt)
         {
            isEnoughBoraboraMoney = this.manager.isEnoughBoraboraMoney();
            if(isEnoughBoraboraMoney)
            {
               this.m_earn_bt.detachTooltip();
               this.m_earn_bt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_earn_bt,"You have enough Bora Money to get all the stars. \n Buy more decor and finish the wedding with the best rating!");
               if(!this.manager.isNPCFlagSet("npcOBTLockMc"))
               {
                  if(this.m_npcOBTLockMc)
                  {
                     this.m_npcOBTLockMc.visible = true;
                  }
                  this.startTimerNPC7();
                  this.manager.setNPCFlag("npcOBTLockMc");
               }
            }
            else
            {
               this.m_earn_bt.enabled = true;
               this.m_earn_bt.detachTooltip();
            }
         }
      }
      
      public function showTutorial1() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            m_tutorial.visible = true;
         }
         if(!Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE1_FLAG))
         {
            Global.player.setSeenFlag(this.BORABORA_MAIN_FTUE1_FLAG);
            this.preSwitchChanges1(0);
         }
         else if(!Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE2_FLAG))
         {
            Global.player.setSeenFlag(this.BORABORA_MAIN_FTUE2_FLAG);
            tutorialSceneNumber = 1;
            this.preSwitchChanges1(1);
         }
         else if(!Global.player.getSeenFlag(this.BORABORA_MAIN_FTUE3_FLAG))
         {
            Global.player.setSeenFlag(this.BORABORA_MAIN_FTUE3_FLAG);
            tutorialSceneNumber = 4;
            this.preSwitchChanges1(4);
         }
      }
      
      protected function preSwitchChanges1(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         var button6:FarmAnimatedTextButton = null;
         var button7:FarmAnimatedTextButton = null;
         var button8:FarmAnimatedTextButton = null;
         var button9:FarmAnimatedTextButton = null;
         var button10:FarmAnimatedTextButton = null;
         var button11:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "OK!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "OK!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "OK!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "Buy";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "OK!";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(4);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "OK!";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(5);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
               break;
            case 6:
               button6 = this.m_tutorialButtons[6] as FarmAnimatedTextButton;
               button6.text = "OK!";
               button6.visible = true;
               button6.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(6);
               (m_tutorial.element as MovieClip).gotoAndStop(7);
               break;
            case 7:
               button7 = this.m_tutorialButtons[7] as FarmAnimatedTextButton;
               button7.text = "OK!";
               button7.visible = true;
               button7.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(7);
               (m_tutorial.element as MovieClip).gotoAndStop(8);
               break;
            case 8:
               button8 = this.m_tutorialButtons[8] as FarmAnimatedTextButton;
               button8.text = "OK!";
               button8.visible = true;
               button8.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(8);
               (m_tutorial.element as MovieClip).gotoAndStop(9);
               break;
            case 9:
               button9 = this.m_tutorialButtons[9] as FarmAnimatedTextButton;
               button9.text = "OK!";
               button9.visible = true;
               button9.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(9);
               (m_tutorial.element as MovieClip).gotoAndStop(10);
               break;
            case 10:
               button10 = this.m_tutorialButtons[10] as FarmAnimatedTextButton;
               button10.text = "OK!";
               button10.visible = true;
               button10.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(10);
               (m_tutorial.element as MovieClip).gotoAndStop(11);
               break;
            case 11:
               button11 = this.m_tutorialButtons[11] as FarmAnimatedTextButton;
               button11.text = "OK!";
               button11.visible = true;
               button11.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(11);
               (m_tutorial.element as MovieClip).gotoAndStop(12);
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < 11)
         {
            ++tutorialSceneNumber;
            if(tutorialSceneNumber == 1)
            {
               hideTutorial();
               this.manager.showNewCycleStartWindow();
            }
            else if(tutorialSceneNumber == 4)
            {
               hideTutorial();
               this.placeFtueDeco();
               this.manager.initializeLeaderBoardProgress();
            }
            else
            {
               if(tutorialSceneNumber == 6)
               {
                  if(!this.m_isEA)
                  {
                     ++tutorialSceneNumber;
                     ++tutorialSceneNumber;
                  }
               }
               this.preSwitchChanges1(tutorialSceneNumber);
            }
         }
         else
         {
            hideTutorial();
            this.updateNewDayData(true);
         }
      }
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      public function placeFtueDeco() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode("2m7c");
         this.manager.onBuyDecoUtil(item);
      }
      
      public function refreshDecoPlanel() : void
      {
         if(this.m_basicPanelFrame)
         {
            this.m_basicPanelFrame.refresh();
         }
         if(this.m_decorPanelFrame)
         {
            this.m_decorPanelFrame.refresh();
         }
         if(this.m_specialPanelFrame)
         {
            this.m_specialPanelFrame.refresh();
         }
         this.handleDecoLockIcons();
      }
      
      public function refreshNPCNamesImages() : void
      {
         if(this.m_npcNames)
         {
            this.m_npcNames.text = this.manager.getCycleNPCNames() + "\'s Wedding";
            this.m_npcNames.visible = true;
         }
         if(this.m_npcIcon)
         {
            this.m_npcIcon.loadIcon(this.manager.getCycleNPCImage());
            this.m_npcIcon.visible = true;
         }
      }
      
      public function weddingCycleRefresh() : void
      {
         if(this.m_weddingTimer)
         {
            this.stopCycleTimer();
            this.startCycleTimer();
         }
      }
      
      private function onStaticFtueClose(e:Event = null) : void
      {
         if(this.m_staticFtue)
         {
            this.m_staticFtue.visible = false;
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_staticFtue)
         {
            this.m_staticFtue.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      private function onDecoHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_panelFTUE)
         {
            this.m_panelFTUE.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      private function onPanelFtueClose(e:Event = null) : void
      {
         if(this.m_panelFTUE)
         {
            this.m_panelFTUE.visible = false;
         }
      }
      
      private function onNpcCompetition(e:Event = null) : void
      {
         if(this.m_npcCompetitionMc)
         {
            this.m_npcCompetitionMc.visible = false;
         }
      }
      
      private function onNpcLeaderboard(e:Event = null) : void
      {
         if(this.m_npcLeaderboardMc)
         {
            this.m_npcLeaderboardMc.visible = false;
         }
      }
      
      private function onNpcOBTLock(e:Event = null) : void
      {
         if(this.m_npcOBTLockMc)
         {
            this.m_npcOBTLockMc.visible = false;
         }
      }
      
      private function onNpcRemainig(e:Event = null) : void
      {
         if(this.m_npcRemainigMc)
         {
            this.m_npcRemainigMc.visible = false;
         }
      }
      
      private function onNpcStreak(e:Event = null) : void
      {
         if(this.m_npcStreakMc)
         {
            this.m_npcStreakMc.visible = false;
            this.m_npcCompetitionMc.visible = true;
         }
      }
      
      private function onNpcDeco(e:Event = null) : void
      {
         if(this.m_npcDecoMc)
         {
            this.m_npcDecoMc.visible = false;
         }
      }
      
      private function onNpcWarning(e:Event = null) : void
      {
         if(this.m_npcWarningMc)
         {
            this.m_npcWarningMc.visible = false;
         }
      }
      
      public function NpcCalloutDeco() : void
      {
         if(!this.manager.isNPCFlagSet("npcCalloutDeco"))
         {
            this.m_npcDecoMc.visible = true;
            this.startTimerNPC5();
            this.manager.setNPCFlag("npcCalloutDeco");
         }
      }
      
      public function startTimerNPC1() : void
      {
         this.m_timerNPC1 = new Timer(5000);
         this.m_timerNPC1.addEventListener(TimerEvent.TIMER,this.onTimerNPC1);
         this.m_timerNPC1.start();
      }
      
      private function onTimerNPC1(event:TimerEvent) : void
      {
         this.stopTimerNPC1();
         this.m_npcLeaderboardMc.visible = false;
      }
      
      private function stopTimerNPC1() : void
      {
         if(this.m_timerNPC1)
         {
            this.m_timerNPC1.stop();
            this.m_timerNPC1.removeEventListener(TimerEvent.TIMER,this.onTimerNPC1);
            this.m_timerNPC1 = null;
         }
      }
      
      public function startTimerNPC2() : void
      {
         this.m_timerNPC2 = new Timer(5000);
         this.m_timerNPC2.addEventListener(TimerEvent.TIMER,this.onTimerNPC2);
         this.m_timerNPC2.start();
      }
      
      private function onTimerNPC2(event:TimerEvent) : void
      {
         this.stopTimerNPC2();
         this.m_npcStreakMc.visible = false;
         this.m_npcCompetitionMc.visible = true;
         this.startTimerNPC6();
      }
      
      private function stopTimerNPC2() : void
      {
         if(this.m_timerNPC2)
         {
            this.m_timerNPC2.stop();
            this.m_timerNPC2.removeEventListener(TimerEvent.TIMER,this.onTimerNPC2);
            this.m_timerNPC2 = null;
         }
      }
      
      public function startTimerNPC3() : void
      {
         this.m_timerNPC3 = new Timer(5000);
         this.m_timerNPC3.addEventListener(TimerEvent.TIMER,this.onTimerNPC3);
         this.m_timerNPC3.start();
      }
      
      private function onTimerNPC3(event:TimerEvent) : void
      {
         this.stopTimerNPC3();
         this.m_npcRemainigMc.visible = false;
      }
      
      private function stopTimerNPC3() : void
      {
         if(this.m_timerNPC3)
         {
            this.m_timerNPC3.stop();
            this.m_timerNPC3.removeEventListener(TimerEvent.TIMER,this.onTimerNPC3);
            this.m_timerNPC3 = null;
         }
      }
      
      public function startTimerNPC4() : void
      {
         this.m_timerNPC4 = new Timer(5000);
         this.m_timerNPC4.addEventListener(TimerEvent.TIMER,this.onTimerNPC4);
         this.m_timerNPC4.start();
      }
      
      private function onTimerNPC4(event:TimerEvent) : void
      {
         this.stopTimerNPC4();
         this.m_npcRemainigNewMc.visible = false;
      }
      
      private function stopTimerNPC4() : void
      {
         if(this.m_timerNPC4)
         {
            this.m_timerNPC4.stop();
            this.m_timerNPC4.removeEventListener(TimerEvent.TIMER,this.onTimerNPC4);
            this.m_timerNPC4 = null;
         }
      }
      
      public function startTimerNPC5() : void
      {
         this.m_timerNPC5 = new Timer(5000);
         this.m_timerNPC5.addEventListener(TimerEvent.TIMER,this.onTimerNPC5);
         this.m_timerNPC5.start();
      }
      
      private function onTimerNPC5(event:TimerEvent) : void
      {
         this.stopTimerNPC5();
         this.m_npcDecoMc.visible = false;
      }
      
      private function stopTimerNPC5() : void
      {
         if(this.m_timerNPC5)
         {
            this.m_timerNPC5.stop();
            this.m_timerNPC5.removeEventListener(TimerEvent.TIMER,this.onTimerNPC5);
            this.m_timerNPC5 = null;
         }
      }
      
      public function startTimerNPC6() : void
      {
         this.m_timerNPC6 = new Timer(5000);
         this.m_timerNPC6.addEventListener(TimerEvent.TIMER,this.onTimerNPC6);
         this.m_timerNPC6.start();
      }
      
      private function onTimerNPC6(event:TimerEvent) : void
      {
         this.stopTimerNPC6();
         this.m_npcCompetitionMc.visible = false;
      }
      
      private function stopTimerNPC6() : void
      {
         if(this.m_timerNPC6)
         {
            this.m_timerNPC6.stop();
            this.m_timerNPC6.removeEventListener(TimerEvent.TIMER,this.onTimerNPC6);
            this.m_timerNPC6 = null;
         }
      }
      
      public function startTimerNPC7() : void
      {
         this.m_timerNPC7 = new Timer(5000);
         this.m_timerNPC7.addEventListener(TimerEvent.TIMER,this.onTimerNPC7);
         this.m_timerNPC7.start();
      }
      
      private function onTimerNPC7(event:TimerEvent) : void
      {
         this.stopTimerNPC7();
         if(this.m_npcOBTLockMc)
         {
            this.m_npcOBTLockMc.visible = false;
         }
      }
      
      private function stopTimerNPC7() : void
      {
         if(this.m_timerNPC7)
         {
            this.m_timerNPC7.stop();
            this.m_timerNPC7.removeEventListener(TimerEvent.TIMER,this.onTimerNPC7);
            this.m_timerNPC7 = null;
         }
      }
   }
}

