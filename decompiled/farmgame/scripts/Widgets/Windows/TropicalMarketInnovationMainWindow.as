package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.utils.Timer;
   
   public class TropicalMarketInnovationMainWindow extends TropicalMarketInnovationGenericOrderboardWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      private static const FEATURE_TRACKING:String = "TropicalMarketInnovation";
      
      private static const FEATURE_NAME:String = "TropicalMarketInnovation";
      
      private static const TROPIC_INTRO_SEEN:String = "tropic_intro_seen";
      
      private static const TROPIC_MIGRATION_POPUP_SEEN:String = "tropic_migration_popup_seen";
      
      private static const TOTAL_INTRO_BUTTONS:Number = 4;
      
      private static const INTRODUCTION_CTA_TEXTS:* = ["Great!","Amazing!","Sweet!","Okay!"];
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private static const BOOST_POPUP_MC:String = "boospopup_mc";
      
      private static const BOOST_END_POPUP_MC:String = "boosendpopup_mc";
      
      private static const BOOST_END_TITLE_TF:String = "boostendpopuptittle_tf";
      
      private static const BOOST_END_BRIEF_TF:String = "boostendbrief_tf";
      
      private static const BOOST_END_ICON_MC:String = "boosticon_mc";
      
      private static const BOOST_ACTIVE_POPUP_MC:String = "boostactivatedpopup_mc";
      
      private static const BOOST_ACTIVE_TITLE_TF:String = "boostactivatedtittle_tf";
      
      private static const BOOST_ACTIVE_BRIEF_TF:String = "activatedboostbrief_tf";
      
      private static const BOOST_ACTIVE_ICON_MC:String = "boosticon_mc";
      
      private static const BOOST_MC:String = "boost_mc";
      
      private static const BOOST_ACTIVATE_BT:String = "activate_bt";
      
      private static const BOOST_ACTIVE_INFO_TF:String = "activeboostinfo_tf";
      
      private static const BOOST_ACTIVE_STAGE_TF:String = "activestage_tf";
      
      private static const BOOST_ICON_MC:String = "boosticon_mc";
      
      private static const BOOST_NON_ACTIVE_INFO_TF:String = "beforeboostactivebrief_mc";
      
      private static const BOOST_SF_COUNT_TF:String = "sfcount_tf";
      
      private static const BOOST_NON_ACTIVE_MC:String = "beforeboostactivebrief_mc";
      
      private static const BOOST_PRODUCE_ICON_MC:String = "produce_icon_mc";
      
      private static const BOOST_ACTIVE_GLOW1_MC:String = "boostactiveglow1_mc";
      
      private static const BOOST_ACTIVE_GLOW_MC:String = "boostactiveglow_mc";
      
      private static const TRAVEL_CONFIRMATION_MC:String = "confirmation_mc";
      
      private static const TRAVEL_LATER_BT:String = "later_btv";
      
      private static const TRAVEL_NOW_BT:String = "okay_btv";
      
      private static const MIGRATION_MC:String = "migration_mc";
      
      private static const MIGRATION_SCENARIO_MC:String = "migrationsenario_mc";
      
      private static const MIGRATION_ARROW_MC:String = "arrow_mc";
      
      private static const MIGRATION_OKAY_BT:String = "okay_bt";
      
      private static const MIGRATION_CLOSE_BT:String = "close_bt";
      
      private static const TE_REWARD_PANE_MC:String = "tereward_pane";
      
      private static const TE_SF_BRIEF_TF:String = "sfbrief_tf";
      
      private static const TE_SF_COUNT_TF:String = "sfcount_tf";
      
      private static const TE_REWARD_ICON_MC:String = "tereward_icon";
      
      private static const TE_VIEW_BT:String = "viewter_bt";
      
      private static const TE_TASK_CARD_MC:String = "tetaskcard_mc";
      
      private static const TE_TASK_OKAY_BT:String = "okay_bt";
      
      private static const TE_TASK_ESCAPE_BT:String = "tropicescape_bt";
      
      private static const TE_TASK_HELP_BT:String = "tetravelcardhelp_bt";
      
      private static const TE_TASK_TEXT_TF:String = "tetravelpane_tf";
      
      private static const WELCOME_BACK_POPUP_MC:String = "welcomebackpopup_mc";
      
      private static const WELCOME_BACK_SF_ICON_MC:String = "specialfertilizer_icon";
      
      private static const WELCOME_BACK_BRIEF_TF:String = "welcomebackbrief_tf";
      
      private static const WELCOME_BACK_HEADER_TF:String = "welcomebackheader_tf";
      
      private static const WELCOME_BACK_OKAY_BT:String = "welcomebackok_bt";
      
      private static const BOOST_REMINDER_POPUP_MC:String = "taskcompletionwithotboost_mc";
      
      private static const BOOST_REMINDER_ICON_MC:String = "boosticon_mc";
      
      private static const BOOST_REMINDER_TITLE_TF:String = "getescapetokensbrief_tf";
      
      private static const BOOST_REMINDER_BRIEF_TF:String = "getescapetokensheader_tf";
      
      private static const BOOST_REMINDER_OKAY_BT:String = "getescapetokensok_bt";
      
      private static const ESCAPE_TUTORIAL_MC:String = "escapetutorial_mc";
      
      private var m_featureName:String = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 186;
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 86;
      
      private const MAX_DAILY_LIMIT:int = 10000;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const TROPICAL_MARKET_MAIN_FTUE_SEEN:String = "tropical_market_main_ftue_seen";
      
      private const TROPICAL_MARKET_WELCOME_SEEN:String = "tropical_market_welcome_seen";
      
      private const FLAG_FIRST_STARTNEWDAY:String = "tropical_market_first_newday";
      
      private var TOTAL_INTRO_STEPS:Number = 4;
      
      private var m_current_tutorial_step:Number = 0;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_timer:Timer;
      
      private var m_migration_popup_step:int = 0;
      
      private var m_leaderboardpane_mc:MovieClip;
      
      private var m_storage_mc:MovieClip;
      
      private var m_storage_progress_mc:MovieClip;
      
      private var m_storage_progressbar:MovieClip;
      
      private var m_daily_progressbar:MovieClip;
      
      private var m_bar_fill_mc:MovieClip;
      
      private var m_gold_fill_mc:MovieClip;
      
      private var m_produce_icon:FarmIcon;
      
      private var m_daily_gold_icon:FarmIcon;
      
      private var m_market_mc:MovieClip;
      
      private var m_dailyrewards_mc:MovieClip;
      
      private var m_daily_progressbar_mc:MovieClip;
      
      private var m_daily_score_tf:ZwTextField;
      
      private var m_day_timer_tf:ZwTextField;
      
      private var m_finalrewards_mc:MovieClip;
      
      private var m_produce_count_tf:ZwTextField;
      
      private var m_upgrade_bt:FarmAnimatedCashButton;
      
      private var m_total_score_tf:ZwTextField;
      
      private var m_startnewday_mc:MovieClip;
      
      private var m_startweek_mc:MovieClip;
      
      private var m_rewardBonusIcon:FarmIcon;
      
      private var m_players_mc:Object = new Array(3);
      
      private var m_dailyReward_icon:FarmIcon;
      
      private var m_newdailyreward_icon:FarmIcon;
      
      private var m_newweeklyproduce_icon:FarmIcon;
      
      private var m_featuretime_tf:ZwTextField;
      
      private var m_checkmark_mc:MovieClip;
      
      private var m_newweektitle_tf:ZwTextField;
      
      private var m_newweekbody_tf:ZwTextField;
      
      private var m_storagefull_tf:ZwTextField;
      
      private var m_norank_tf:ZwTextField;
      
      private var m_conversion_mc:MovieClip;
      
      private var m_storagefull_mc:MovieClip;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      private var m_escape_minitutorial_frame:ZwFrame;
      
      private var m_escape_mini_tutorial_mc:MovieClip;
      
      private var m_welcome_EA_mc:MovieClip;
      
      private var m_welcome_GA_mc:MovieClip;
      
      private var m_storage_title_tf:ZwTextField;
      
      private var m_boost_popup_mc:MovieClip;
      
      private var m_boost_end_popup_mc:MovieClip;
      
      private var m_boost_end_title_tf:ZwTextField;
      
      private var m_boost_end_brief_tf:ZwTextField;
      
      private var m_boost_end_icon_mc:MovieClip;
      
      private var m_boost_end_okay_bt:FarmAnimatedTextButton;
      
      private var m_boost_active_popup_mc:MovieClip;
      
      private var m_boost_active_title_tf:ZwTextField;
      
      private var m_boost_active_brief_tf:ZwTextField;
      
      private var m_boost_active_icon_mc:MovieClip;
      
      private var m_boost_active_okay_bt:FarmAnimatedTextButton;
      
      private var m_boost_active_share_bt:FarmAnimatedTextButton;
      
      private var m_boost_active_close_bt:FarmButton;
      
      private var m_boost_mc:MovieClip;
      
      private var m_boost_activate_bt:FarmAnimatedTextButton;
      
      private var m_boost_active_info_tf:ZwTextField;
      
      private var m_boost_active_stage_tf:ZwTextField;
      
      private var m_boost_icon_mc:MovieClip;
      
      private var m_boost_non_active_info_tf:ZwTextField;
      
      private var m_boost_sf_count_tf:ZwTextField;
      
      private var m_boost_non_active_mc:MovieClip;
      
      private var m_boost_produce_icon_mc:FarmIcon;
      
      private var m_boost_active_glow1_mc:MovieClip;
      
      private var m_boost_active_glow_mc:MovieClip;
      
      private var m_travel_confirmation_mc:MovieClip;
      
      private var m_travel_later_bt:FarmAnimatedTextButton;
      
      private var m_travel_confirmation_tf:ZwTextField;
      
      private var m_travel_now_bt:FarmAnimatedTextButton;
      
      private var m_migration_mc:MovieClip;
      
      private var m_migration_scenario_mc:MovieClip;
      
      private var m_migration_arrow_mc:MovieClip;
      
      private var m_migration_okay_bt:FarmAnimatedTextButton;
      
      private var m_migration_close_bt:FarmButton;
      
      private var m_te_reward_pane_mc:MovieClip;
      
      private var m_te_sf_brief_tf:ZwTextField;
      
      private var m_te_sf_count_tf:ZwTextField;
      
      private var m_te_reward_icon_mc:FarmIcon;
      
      private var m_te_view_bt:FarmAnimatedTextButton;
      
      private var m_te_task_card_mc:MovieClip;
      
      private var m_te_task_okay_bt:FarmAnimatedTextButton;
      
      private var m_te_task_escape_bt:FarmAnimatedTextButton;
      
      private var m_te_task_help_bt:FarmAnimatedButton;
      
      private var m_te_task_text_tf:ZwTextField;
      
      private var m_welcome_back_popup_mc:MovieClip;
      
      private var m_welcome_back_sf_icon_mc:FarmIcon;
      
      private var m_welcome_back_brief_tf:ZwTextField;
      
      private var m_welcome_back_header_tf:ZwTextField;
      
      private var m_welcome_back_okay_bt:FarmAnimatedTextButton;
      
      private var m_boost_reminder_popup_mc:MovieClip;
      
      private var m_boost_reminder_icon_mc:MovieClip;
      
      private var m_boost_reminder_title_tf:ZwTextField;
      
      private var m_boost_reminder_brief_tf:ZwTextField;
      
      private var m_boost_reminder_okay_bt:FarmAnimatedTextButton;
      
      private var m_intro_mc:MovieClip;
      
      private var m_intro_okay_bt:Array = [];
      
      private var m_tropic_reward_popup_mc:MovieClip;
      
      private var m_tropic_reward_okay_bt:FarmAnimatedTextButton;
      
      private var FLAG_BOOST_POPUP_SEEN:String = "TropicalMarketInnovation_boost_popup";
      
      private const MAX_TILE_LEVEL:int = 5;
      
      private const TRAVEL_DIALOG_PHYLUM:Array = ["Dialog1","Dialog2"];
      
      private const TRAVEL_DIALOG_CLASS:Array = ["Next","Close"];
      
      public function TropicalMarketInnovationMainWindow(featureName:String = "TropicalMarketInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,this.manager,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var player_mc_key:String = null;
         var index:int = 0;
         var amount:int = 0;
         var rewarditem:FarmItem = null;
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         var i:int = 0;
         var buttonName:String = null;
         var boostActivatePromptText:String = null;
         var boostActivateInfoText:String = null;
         var boostActiveStageText:String = null;
         var boostNonActiveInfoText:String = null;
         var boostCounterTf:String = null;
         var confirmationText:String = null;
         var landRewardsText:String = null;
         var message:String = null;
         var boostReminderTitle:String = null;
         var boostReminderBrief:String = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"TROPICAL MARKET"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Do tasks to get produce, which can be sold in the tropical shop to earn coins and progress!"));
         }
         if(m_taskFrame)
         {
            m_taskFrame.visible = true;
         }
         if(m_window.hasOwnProperty("leaderboard_pane"))
         {
            this.m_leaderboardpane_mc = m_window["leaderboard_pane"] as MovieClip;
            this.m_leaderboardpane_mc.visible = true;
            if(this.m_leaderboardpane_mc.hasOwnProperty("view_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_leaderboardpane_mc["view_bt"],"View!",this.onViewLeaderboardClick));
            }
            if(this.m_leaderboardpane_mc.hasOwnProperty("norank_tf"))
            {
               addWidget(this.m_norank_tf = new ZwTextField(this.m_leaderboardpane_mc["norank_tf"],"You need to earn Market Coins to appear on this week\'s leaderboard!"));
               this.m_norank_tf.visible = false;
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
         if(m_window.hasOwnProperty("tranjaction_tab"))
         {
            this.m_conversion_mc = m_window["tranjaction_tab"] as MovieClip;
            this.m_conversion_mc.visible = false;
         }
         if(m_window.hasOwnProperty("storage_tab"))
         {
            this.m_storage_mc = m_window["storage_tab"] as MovieClip;
            this.m_storage_mc.visible = true;
            if(this.m_storage_mc.hasOwnProperty("upgrade_bt"))
            {
               amount = this.manager.getCostToUpgradeLevel();
               addWidget(this.m_upgrade_bt = new FarmAnimatedCashButton(this.m_storage_mc["upgrade_bt"],"Upgrade",amount.toString(),this.onStorageUpgradeClick));
               if(amount == 0)
               {
                  this.m_upgrade_bt.enabled = false;
                  this.m_upgrade_bt.text = "at max";
                  this.m_upgrade_bt.attachTooltip(new FarmTextTooltip("Maximum capacity reached!"));
               }
               else
               {
                  this.m_upgrade_bt.enabled = true;
                  this.m_upgrade_bt.text = "Upgrade";
                  this.m_upgrade_bt.detachTooltip();
               }
            }
            if(this.m_storage_mc.hasOwnProperty("storagelevel_tf"))
            {
               addWidget(this.m_storage_title_tf = new ZwTextField(this.m_storage_mc["storagelevel_tf"]));
               this.m_storage_title_tf.text = "STORAGE LEVEL " + this.manager.currentStorageLevel.toString();
            }
            if(this.m_storage_mc.hasOwnProperty("storagecount_tf"))
            {
               addWidget(this.m_produce_count_tf = new ZwTextField(this.m_storage_mc["storagecount_tf"]));
            }
            if(this.m_storage_mc.hasOwnProperty("storage_progressbar"))
            {
               this.m_storage_progress_mc = this.m_storage_mc["storage_progressbar"] as MovieClip;
               this.m_storage_progress_mc.visible = true;
               if(this.m_storage_progress_mc.hasOwnProperty("produce_icon"))
               {
                  this.m_produce_icon = new FarmIcon(this.m_storage_progress_mc["produce_icon"]);
                  this.m_produce_icon.visible = true;
               }
               if(this.m_storage_progress_mc.hasOwnProperty("slotmc_progressbar"))
               {
                  this.m_storage_progressbar = this.m_storage_progress_mc["slotmc_progressbar"] as MovieClip;
                  this.m_storage_progressbar.visible = true;
                  if(this.m_storage_progressbar.hasOwnProperty("bar_fill_mc"))
                  {
                     this.m_bar_fill_mc = this.m_storage_progressbar["bar_fill_mc"] as MovieClip;
                     this.m_bar_fill_mc.visible = true;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("market_tab"))
         {
            this.m_market_mc = m_window["market_tab"] as MovieClip;
            this.m_market_mc.visible = true;
            if(this.m_market_mc.hasOwnProperty("market_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_market_mc["market_bt"],"Enter Shop",this.onViewMarketClick));
            }
         }
         if(m_window.hasOwnProperty("dailyreward_pane"))
         {
            this.m_dailyrewards_mc = m_window["dailyreward_pane"] as MovieClip;
            this.m_dailyrewards_mc.visible = true;
            if(this.m_dailyrewards_mc.hasOwnProperty("daily_progressbar"))
            {
               this.m_daily_progressbar_mc = this.m_dailyrewards_mc["daily_progressbar"] as MovieClip;
               this.m_daily_progressbar_mc.visible = true;
               if(this.m_daily_progressbar_mc.hasOwnProperty("produce_icon"))
               {
                  this.m_daily_gold_icon = new FarmIcon(this.m_daily_progressbar_mc["produce_icon"]);
               }
               if(this.m_daily_progressbar_mc.hasOwnProperty("slotmc1_progressbar"))
               {
                  this.m_daily_progressbar = this.m_daily_progressbar_mc["slotmc1_progressbar"] as MovieClip;
                  this.m_daily_progressbar.visible = true;
                  if(this.m_daily_progressbar.hasOwnProperty("bar_fillr_mc"))
                  {
                     this.m_gold_fill_mc = this.m_daily_progressbar["bar_fillr_mc"] as MovieClip;
                     this.m_gold_fill_mc.visible = true;
                  }
               }
            }
            if(this.m_dailyrewards_mc.hasOwnProperty("dailyreward_icon"))
            {
               this.m_dailyReward_icon = new FarmIcon(this.m_dailyrewards_mc["dailyreward_icon"]);
               rewarditem = this.manager.getNewDailyReward();
               if(rewarditem)
               {
                  this.m_dailyReward_icon.loadIcon(rewarditem.iconUrl);
                  this.m_dailyReward_icon.setIconSize(50,50);
                  this.m_dailyReward_icon.attachTooltip(new FarmTextTooltip(rewarditem.friendlyTitle));
               }
            }
            if(this.m_dailyrewards_mc.hasOwnProperty("checkmark1_mc"))
            {
               this.m_checkmark_mc = this.m_dailyrewards_mc["checkmark1_mc"] as MovieClip;
               this.m_checkmark_mc.visible = false;
            }
            if(this.m_dailyrewards_mc.hasOwnProperty("dailyscore_tf"))
            {
               addWidget(this.m_daily_score_tf = new ZwTextField(this.m_dailyrewards_mc["dailyscore_tf"]));
               if(this.manager.getDayPoints() < 10000)
               {
                  this.m_daily_score_tf.text = this.manager.getDayPoints().toString() + "/10000";
               }
               else
               {
                  this.m_daily_score_tf.text = "10000/10000";
               }
            }
            if(this.m_dailyrewards_mc.hasOwnProperty("rewardchangein_tf"))
            {
               addWidget(this.m_day_timer_tf = new ZwTextField(this.m_dailyrewards_mc["rewardchangein_tf"]));
            }
         }
         if(m_window.hasOwnProperty("featurereward_pane"))
         {
            this.m_finalrewards_mc = m_window["featurereward_pane"] as MovieClip;
            this.m_finalrewards_mc.visible = true;
            if(this.m_finalrewards_mc.hasOwnProperty("fearurereward_icon"))
            {
               this.m_rewardBonusIcon = new FarmIcon(this.m_finalrewards_mc["fearurereward_icon"]);
               rewardName = this.manager.getNextBonusReward();
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               this.m_rewardBonusIcon.loadIcon(rewardItem.iconUrl);
               this.m_rewardBonusIcon.visible = true;
            }
            if(this.m_finalrewards_mc.hasOwnProperty("view1_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_finalrewards_mc["view1_bt"],"View",this.openRewardsWindow));
            }
            if(this.m_finalrewards_mc.hasOwnProperty("score_tf"))
            {
               addWidget(this.m_total_score_tf = new ZwTextField(this.m_finalrewards_mc["score_tf"],this.manager.getTotalGoldCoins().toString()));
            }
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
               addWidget(new ZwTextField(this.m_startnewday_mc["newreward_brief"],"Here\'s your new daily reward. Score a minimum of 10000 to earn this at the end of the day!"));
            }
            if(this.m_startnewday_mc.hasOwnProperty("nextreward_icon"))
            {
               this.m_newdailyreward_icon = new FarmIcon(this.m_startnewday_mc["nextreward_icon"]);
            }
         }
         if(m_window.hasOwnProperty("newproduce_tab"))
         {
            this.m_startweek_mc = m_window["newproduce_tab"] as MovieClip;
            this.m_startweek_mc.visible = false;
            if(this.m_startweek_mc.hasOwnProperty("wnewrewardtitle_tf"))
            {
               addWidget(this.m_newweektitle_tf = new ZwTextField(this.m_startweek_mc["wnewrewardtitle_tf"]));
            }
            if(this.m_startweek_mc.hasOwnProperty("wok_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_startweek_mc["wok_bt"],"Great!",this.onStartNewWeekClick));
            }
            if(this.m_startweek_mc.hasOwnProperty("wnewreward_brief"))
            {
               addWidget(this.m_newweekbody_tf = new ZwTextField(this.m_startweek_mc["wnewreward_brief"]));
            }
            if(this.m_startweek_mc.hasOwnProperty("wnextreward_icon"))
            {
               this.m_newweeklyproduce_icon = new FarmIcon(this.m_startweek_mc["wnextreward_icon"]);
            }
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            addWidget(this.m_featuretime_tf = new ZwTextField(m_window["timeremains_tf"],""));
            this.m_featuretime_tf.visible = true;
         }
         if(m_window.hasOwnProperty("silooutofspace_mc"))
         {
            this.m_storagefull_mc = m_window["silooutofspace_mc"] as MovieClip;
            if(this.m_storagefull_mc.hasOwnProperty("silofullbrief_tf"))
            {
               addWidget(this.m_storagefull_tf = new ZwTextField(this.m_storagefull_mc["silofullbrief_tf"],""));
            }
            this.m_storagefull_mc.visible = false;
         }
         if(m_window.hasOwnProperty("earlyaccessbenifit_mc"))
         {
            this.m_welcome_EA_mc = m_window["earlyaccessbenifit_mc"] as MovieClip;
            if(this.m_welcome_EA_mc.hasOwnProperty("welcome_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_welcome_EA_mc["welcome_bt"],"Claim!",this.onClickWelcomeOverlay));
            }
            this.m_welcome_EA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("generalaccess_mc"))
         {
            this.m_welcome_GA_mc = m_window["generalaccess_mc"] as MovieClip;
            if(this.m_welcome_GA_mc.hasOwnProperty("welcome1_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_welcome_GA_mc["welcome1_bt"],"Alright!",this.onClickWelcomeOverlay));
            }
            this.m_welcome_GA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            if(m_window["tutorial_mc"])
            {
               for(i = 0; i <= 5; i++)
               {
                  buttonName = "okay" + i.toString() + "_bt";
                  if(m_window["tutorial_mc"].hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[i] = new FarmAnimatedTextButton(m_window["tutorial_mc"][buttonName]);
                     this.m_tutorialButtons[i].visible = false;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("mini_tutorial_mc"))
         {
            this.m_mini_tutorial_mc = m_window["mini_tutorial_mc"] as MovieClip;
            this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
            if(this.m_mini_tutorial_mc.hasOwnProperty("okay_bt"))
            {
               this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_mini_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_mini_tutorial_mc["okay_bt"].visible = true;
            }
            this.m_mini_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("escapetutorial_mini_mc"))
         {
            this.m_escape_mini_tutorial_mc = m_window["escapetutorial_mini_mc"] as MovieClip;
            this.m_escape_minitutorial_frame = addWidget(new ZwFrame(this.m_escape_mini_tutorial_mc),false) as ZwFrame;
            if(this.m_escape_mini_tutorial_mc.hasOwnProperty("okay6_bt"))
            {
               this.m_escape_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_escape_mini_tutorial_mc["okay6_bt"],"Great!",this.howDoesThisEscapeWorkFrameSwitch));
               this.m_escape_mini_tutorial_mc["okay6_bt"].visible = true;
            }
            this.m_escape_mini_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty(BOOST_POPUP_MC))
         {
            this.m_boost_popup_mc = m_window[BOOST_POPUP_MC] as MovieClip;
            this.m_boost_popup_mc.visible = false;
            if(this.m_boost_popup_mc.hasOwnProperty(BOOST_END_POPUP_MC))
            {
               this.m_boost_end_popup_mc = this.m_boost_popup_mc[BOOST_END_POPUP_MC] as MovieClip;
               this.m_boost_end_popup_mc.visible = false;
               if(this.m_boost_end_popup_mc.hasOwnProperty(BOOST_END_TITLE_TF))
               {
                  this.m_boost_end_title_tf = new ZwTextField(this.m_boost_end_popup_mc[BOOST_END_TITLE_TF],"boost_end_title");
                  this.m_boost_end_title_tf.visible = false;
               }
               if(this.m_boost_end_popup_mc.hasOwnProperty(BOOST_END_BRIEF_TF))
               {
                  this.m_boost_end_brief_tf = new ZwTextField(this.m_boost_end_popup_mc[BOOST_END_BRIEF_TF],"boost_end_brief");
                  this.m_boost_end_brief_tf.visible = false;
               }
               if(this.m_boost_end_popup_mc.hasOwnProperty(BOOST_END_ICON_MC))
               {
                  this.m_boost_end_icon_mc = this.m_boost_end_popup_mc[BOOST_END_ICON_MC] as MovieClip;
                  this.m_boost_end_icon_mc.visible = false;
               }
               if(this.m_boost_end_popup_mc.hasOwnProperty("ok_bt"))
               {
                  this.m_boost_end_okay_bt = new FarmAnimatedTextButton(this.m_boost_end_popup_mc["ok_bt"],"Okay!",this.onClickBoostEndedOkayButton);
               }
            }
            if(this.m_boost_popup_mc.hasOwnProperty(BOOST_ACTIVE_POPUP_MC))
            {
               this.m_boost_active_popup_mc = this.m_boost_popup_mc[BOOST_ACTIVE_POPUP_MC] as MovieClip;
               this.m_boost_active_popup_mc.visible = true;
               if(this.m_boost_active_popup_mc.hasOwnProperty(BOOST_ACTIVE_TITLE_TF))
               {
                  this.m_boost_active_title_tf = new ZwTextField(this.m_boost_active_popup_mc[BOOST_ACTIVE_TITLE_TF],"boost_active_title");
                  this.m_boost_active_title_tf.visible = false;
               }
               if(this.m_boost_active_popup_mc.hasOwnProperty(BOOST_ACTIVE_BRIEF_TF))
               {
                  this.m_boost_active_brief_tf = new ZwTextField(this.m_boost_active_popup_mc[BOOST_ACTIVE_BRIEF_TF],"boost_active_brief");
                  this.m_boost_active_brief_tf.visible = false;
               }
               if(this.m_boost_active_popup_mc.hasOwnProperty(BOOST_ACTIVE_ICON_MC))
               {
                  this.m_boost_active_icon_mc = this.m_boost_active_popup_mc[BOOST_ACTIVE_ICON_MC] as MovieClip;
                  this.m_boost_active_icon_mc.visible = false;
               }
               if(this.m_boost_active_popup_mc.hasOwnProperty("ok_bt"))
               {
                  this.m_boost_active_okay_bt = new FarmAnimatedTextButton(this.m_boost_active_popup_mc["ok_bt"],"Okay!",this.onClickBoostActivatedOkayButton);
               }
               if(this.m_boost_active_popup_mc.hasOwnProperty("share_bt"))
               {
                  this.m_boost_active_share_bt = new FarmAnimatedTextButton(this.m_boost_active_popup_mc["share_bt"],"Share",this.onBoostActiveShareButtonClick);
               }
               if(this.m_boost_active_popup_mc.hasOwnProperty("close_bt"))
               {
                  this.m_boost_active_close_bt = new FarmButton(this.m_boost_active_popup_mc["close_bt"],this.onClickBoostActivatedOkayButton);
               }
            }
         }
         if(m_window.hasOwnProperty(BOOST_MC))
         {
            this.m_boost_mc = m_window[BOOST_MC] as MovieClip;
            this.m_boost_mc.visible = true;
            if(this.m_boost_mc.hasOwnProperty(BOOST_ACTIVATE_BT))
            {
               boostActivatePromptText = "Activate";
               this.m_boost_activate_bt = new FarmAnimatedTextButton(this.m_boost_mc[BOOST_ACTIVATE_BT],boostActivatePromptText,this.onClickActivateBoostButton);
               this.m_boost_activate_bt.attachTooltip(new FarmTextTooltip("Get 2x Produce on your tasks using Escape Tokens"));
               this.m_boost_activate_bt.visible = false;
            }
            if(this.m_boost_mc.hasOwnProperty(BOOST_ACTIVE_INFO_TF))
            {
               boostActivateInfoText = this.getBoostActiveInfoText();
               this.m_boost_active_info_tf = new ZwTextField(this.m_boost_mc[BOOST_ACTIVE_INFO_TF],boostActivateInfoText);
               this.m_boost_active_info_tf.visible = false;
            }
            if(this.m_boost_mc.hasOwnProperty(BOOST_ACTIVE_STAGE_TF))
            {
               boostActiveStageText = "Active!";
               this.m_boost_active_stage_tf = new ZwTextField(this.m_boost_mc[BOOST_ACTIVE_STAGE_TF],boostActiveStageText);
               this.m_boost_active_stage_tf.visible = false;
            }
            if(this.m_boost_mc.hasOwnProperty(BOOST_ICON_MC))
            {
               this.m_boost_icon_mc = this.m_boost_mc[BOOST_ICON_MC] as MovieClip;
               this.m_boost_icon_mc.visible = true;
            }
            if(this.m_boost_mc.hasOwnProperty(BOOST_NON_ACTIVE_INFO_TF))
            {
               boostNonActiveInfoText = "Get 2X Produce on your tasks using Escape Tokens!";
               this.m_boost_non_active_info_tf = new ZwTextField(this.m_boost_mc[BOOST_NON_ACTIVE_INFO_TF],boostNonActiveInfoText);
               this.m_boost_non_active_info_tf.visible = true;
            }
            if(this.m_boost_mc.hasOwnProperty(BOOST_SF_COUNT_TF))
            {
               boostCounterTf = this.getEscapeTokensTextForBoostPanel();
               this.m_boost_sf_count_tf = new ZwTextField(this.m_boost_mc[BOOST_SF_COUNT_TF],boostCounterTf);
               this.m_boost_sf_count_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty(BOOST_ACTIVE_GLOW1_MC))
         {
            this.m_boost_active_glow1_mc = m_window[BOOST_ACTIVE_GLOW1_MC] as MovieClip;
            this.m_boost_active_glow1_mc.visible = false;
            if(this.m_boost_active_glow1_mc.hasOwnProperty(BOOST_ACTIVE_GLOW_MC))
            {
               this.m_boost_active_glow_mc = this.m_boost_active_glow1_mc[BOOST_ACTIVE_GLOW_MC] as MovieClip;
               this.m_boost_active_glow_mc.visible = false;
            }
         }
         if(m_window.hasOwnProperty(TRAVEL_CONFIRMATION_MC))
         {
            this.m_travel_confirmation_mc = m_window[TRAVEL_CONFIRMATION_MC] as MovieClip;
            this.m_travel_confirmation_mc.visible = false;
            if(this.m_travel_confirmation_mc.hasOwnProperty(TRAVEL_NOW_BT))
            {
               this.m_travel_now_bt = new FarmAnimatedTextButton(this.m_travel_confirmation_mc[TRAVEL_NOW_BT],"Yes!",this.onClickTravelNowButton);
               this.m_travel_now_bt.visible = false;
            }
            if(this.m_travel_confirmation_mc.hasOwnProperty(TRAVEL_LATER_BT))
            {
               this.m_travel_later_bt = new FarmAnimatedTextButton(this.m_travel_confirmation_mc[TRAVEL_LATER_BT],"Later!",this.onClickTravelLaterButton);
               this.m_travel_later_bt.visible = false;
            }
            if(this.m_travel_confirmation_mc.hasOwnProperty("confirm_tf"))
            {
               confirmationText = "This will open Tropic Escape in a new tab. Do you want to continue?";
               this.m_travel_confirmation_tf = new ZwTextField(this.m_travel_confirmation_mc["confirm_tf"],confirmationText);
               this.m_travel_confirmation_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty(MIGRATION_MC))
         {
            this.m_migration_mc = m_window[MIGRATION_MC] as MovieClip;
            this.m_migration_mc.visible = false;
            if(this.m_migration_mc.hasOwnProperty(MIGRATION_SCENARIO_MC))
            {
               this.m_migration_scenario_mc = this.m_migration_mc[MIGRATION_SCENARIO_MC] as MovieClip;
               this.m_migration_scenario_mc.visible = false;
               if(this.m_migration_scenario_mc.hasOwnProperty(MIGRATION_ARROW_MC))
               {
                  this.m_migration_arrow_mc = this.m_migration_scenario_mc[MIGRATION_ARROW_MC] as MovieClip;
                  this.m_migration_arrow_mc.visible = false;
               }
            }
            if(this.m_migration_mc.hasOwnProperty(MIGRATION_OKAY_BT))
            {
               this.m_migration_okay_bt = new FarmAnimatedTextButton(this.m_migration_mc[MIGRATION_OKAY_BT],"Okay!",this.onClickMigrationScenarioButton);
               this.m_migration_okay_bt.visible = false;
            }
            if(this.m_migration_mc.hasOwnProperty(MIGRATION_CLOSE_BT))
            {
               this.m_migration_close_bt = new FarmButton(this.m_migration_mc[MIGRATION_CLOSE_BT],this.onClickMigrationScenarionClose);
               this.m_migration_close_bt.visible = Global.player.getSeenFlag(TROPIC_MIGRATION_POPUP_SEEN);
            }
         }
         if(m_window.hasOwnProperty(TE_REWARD_PANE_MC))
         {
            this.m_te_reward_pane_mc = m_window[TE_REWARD_PANE_MC] as MovieClip;
            this.m_te_reward_pane_mc.visible = true;
            if(this.m_te_reward_pane_mc.hasOwnProperty(TE_SF_BRIEF_TF))
            {
               landRewardsText = this.getLandRewardsText();
               this.m_te_sf_brief_tf = new ZwTextField(this.m_te_reward_pane_mc[TE_SF_BRIEF_TF],landRewardsText);
               this.m_te_sf_brief_tf.visible = true;
            }
            if(this.m_te_reward_pane_mc.hasOwnProperty(TE_SF_COUNT_TF))
            {
               this.m_te_sf_count_tf = new ZwTextField(this.m_te_reward_pane_mc[TE_SF_COUNT_TF],String(this.manager.getEscapeTokensCollected()));
               this.m_te_sf_count_tf.visible = true;
            }
            if(this.m_te_reward_pane_mc.hasOwnProperty(TE_REWARD_ICON_MC))
            {
               this.m_te_reward_icon_mc = new FarmIcon(this.m_te_reward_pane_mc[TE_REWARD_ICON_MC]);
               this.m_te_reward_icon_mc.visible = true;
            }
            if(this.m_te_reward_pane_mc.hasOwnProperty(TE_VIEW_BT))
            {
               this.m_te_view_bt = new FarmAnimatedTextButton(this.m_te_reward_pane_mc[TE_VIEW_BT],"View!",this.onClickViewTileRewards);
               this.m_te_view_bt.visible = true;
            }
         }
         if(m_window.hasOwnProperty(TE_TASK_CARD_MC))
         {
            this.m_te_task_card_mc = m_window[TE_TASK_CARD_MC] as MovieClip;
            this.m_te_task_card_mc.visible = true;
            if(this.m_te_task_card_mc.hasOwnProperty(TE_TASK_OKAY_BT))
            {
               this.m_te_task_okay_bt = new FarmAnimatedTextButton(this.m_te_task_card_mc[TE_TASK_OKAY_BT],"te_task_okay_bt");
               this.m_te_task_okay_bt.visible = false;
            }
            if(this.m_te_task_card_mc.hasOwnProperty(TE_TASK_ESCAPE_BT))
            {
               this.m_te_task_escape_bt = new FarmAnimatedTextButton(this.m_te_task_card_mc[TE_TASK_ESCAPE_BT],"Travel",this.showTravelConfirmationPopup);
               this.m_te_task_escape_bt.visible = true;
            }
            if(this.m_te_task_card_mc.hasOwnProperty(TE_TASK_HELP_BT))
            {
               this.m_te_task_help_bt = new FarmAnimatedButton(this.m_te_task_card_mc[TE_TASK_HELP_BT],this.howDoesThisEscapeWorkClick);
               this.m_te_task_help_bt.visible = true;
            }
            if(this.m_te_task_card_mc.hasOwnProperty(TE_TASK_TEXT_TF))
            {
               message = "Click below to start earning \'Escape Tokens\' in Tropic Escape";
               if(this.manager.getEscapeTokensCollected() > 0)
               {
                  message = "Travel to earn more \'Escape Tokens\' in Tropic Escape";
               }
               this.m_te_task_text_tf = new ZwTextField(this.m_te_task_card_mc[TE_TASK_TEXT_TF],message);
               this.m_te_task_text_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty(WELCOME_BACK_POPUP_MC))
         {
            this.m_welcome_back_popup_mc = m_window[WELCOME_BACK_POPUP_MC] as MovieClip;
            this.m_welcome_back_popup_mc.visible = false;
            if(this.m_welcome_back_popup_mc.hasOwnProperty(WELCOME_BACK_HEADER_TF))
            {
               this.m_welcome_back_header_tf = new ZwTextField(this.m_welcome_back_popup_mc[WELCOME_BACK_HEADER_TF],"welcome_back_header_tf");
               this.m_welcome_back_header_tf.visible = false;
            }
            if(this.m_welcome_back_popup_mc.hasOwnProperty(WELCOME_BACK_BRIEF_TF))
            {
               this.m_welcome_back_brief_tf = new ZwTextField(this.m_welcome_back_popup_mc[WELCOME_BACK_BRIEF_TF],"welcome_back_brief_tf");
               this.m_welcome_back_brief_tf.visible = false;
            }
            if(this.m_welcome_back_popup_mc.hasOwnProperty(WELCOME_BACK_OKAY_BT))
            {
               this.m_welcome_back_okay_bt = new FarmAnimatedTextButton(this.m_welcome_back_popup_mc[WELCOME_BACK_OKAY_BT],"welcome_back_okay_bt",this.onWelcomeBackOkayButton);
               this.m_welcome_back_okay_bt.visible = false;
            }
            if(this.m_welcome_back_popup_mc.hasOwnProperty(WELCOME_BACK_SF_ICON_MC))
            {
               this.m_welcome_back_sf_icon_mc = new FarmIcon(this.m_welcome_back_popup_mc[WELCOME_BACK_SF_ICON_MC]);
               this.m_welcome_back_sf_icon_mc.visible = false;
            }
         }
         if(m_window.hasOwnProperty(BOOST_REMINDER_POPUP_MC))
         {
            this.m_boost_reminder_popup_mc = m_window[BOOST_REMINDER_POPUP_MC] as MovieClip;
            this.m_boost_reminder_popup_mc.visible = false;
            if(this.m_boost_reminder_popup_mc.hasOwnProperty(BOOST_REMINDER_ICON_MC))
            {
               this.m_boost_reminder_icon_mc = this.m_boost_reminder_popup_mc[BOOST_REMINDER_ICON_MC] as MovieClip;
               this.m_boost_reminder_icon_mc.visible = false;
            }
            if(this.m_boost_reminder_popup_mc.hasOwnProperty(BOOST_REMINDER_TITLE_TF))
            {
               boostReminderTitle = "You could have earned 2X fruits from last 5 tasks by using boost.\n" + "\n" + " Get Escape Tokens and activate boost to double your earnings!\n";
               this.m_boost_reminder_title_tf = new ZwTextField(this.m_boost_reminder_popup_mc[BOOST_REMINDER_TITLE_TF],boostReminderTitle);
               this.m_boost_reminder_title_tf.visible = false;
            }
            if(this.m_boost_reminder_popup_mc.hasOwnProperty(BOOST_REMINDER_BRIEF_TF))
            {
               boostReminderBrief = "Get Escape Tokens!";
               this.m_boost_reminder_brief_tf = new ZwTextField(this.m_boost_reminder_popup_mc[BOOST_REMINDER_BRIEF_TF],boostReminderBrief);
               this.m_boost_reminder_brief_tf.visible = false;
            }
            if(this.m_boost_reminder_popup_mc.hasOwnProperty(BOOST_REMINDER_OKAY_BT))
            {
               this.m_boost_reminder_okay_bt = new FarmAnimatedTextButton(this.m_boost_reminder_popup_mc[BOOST_REMINDER_OKAY_BT],"Okay",this.onClickBoostReminderOkayButton);
            }
            if(m_window.hasOwnProperty(ESCAPE_TUTORIAL_MC))
            {
               this.m_intro_mc = m_window[ESCAPE_TUTORIAL_MC] as MovieClip;
               for(i = 0; i < TOTAL_INTRO_BUTTONS; i++)
               {
                  if(this.m_intro_mc.hasOwnProperty("okay" + String(i + 6) + "_bt"))
                  {
                     this.m_intro_okay_bt.push(new FarmAnimatedTextButton(this.m_intro_mc["okay" + String(i + 6) + "_bt"],"Next!",this.onClickIntroButton));
                     this.m_intro_okay_bt[i].text = INTRODUCTION_CTA_TEXTS[i];
                  }
               }
            }
            if(m_window.hasOwnProperty("earntropicalrewards_mc"))
            {
               this.m_tropic_reward_popup_mc = m_window["earntropicalrewards_mc"] as MovieClip;
               this.m_tropic_reward_popup_mc.visible = false;
               if(this.m_tropic_reward_popup_mc.hasOwnProperty("earntropicalrewards_bt"))
               {
                  this.m_tropic_reward_okay_bt = new FarmAnimatedTextButton(this.m_tropic_reward_popup_mc["earntropicalrewards_bt"],"Okay",this.onTropicRewardOkayButtonClick);
                  this.m_tropic_reward_popup_mc.visible = false;
               }
            }
         }
         this.updateStorageBar(true);
         this.updateDailyProgressBar(true);
         this.startTimer();
         if(this.manager.isStorageCapacityFull())
         {
            this.showStorageFullPopup();
         }
         if(this.shouldShowMigrationScenarioPopup())
         {
            this.m_migration_popup_step = 0;
            this.showMigrationScenarioPopup();
         }
         this.refreshBoostComponents();
         if(this.m_checkmark_mc)
         {
            this.m_checkmark_mc.visible = this.manager.isDailyRewardGranted() ? true : false;
         }
         if(this.manager.getWeeklyLeaderboardPoints() > 0)
         {
            this.manager.initializeLeaderBoardProgress(true);
         }
         else if(this.m_norank_tf)
         {
            this.m_norank_tf.visible = true;
         }
         if(!Global.player.getSeenFlag(this.TROPICAL_MARKET_MAIN_FTUE_SEEN) && !Global.player.getSeenFlag(this.FLAG_FIRST_STARTNEWDAY))
         {
            this.manager.updateActiveDayForTutorial();
            this.showMainTutorial();
         }
         else if(!Global.player.getSeenFlag(this.FLAG_FIRST_STARTNEWDAY))
         {
            this.updateNewDayData(true);
         }
         else
         {
            this.updateNewDayData(false);
         }
      }
      
      private function onBoostActiveShareButtonClick(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"BoostActivate_Dialog","Share");
         var windowName:String = "TropicalMarketInnovation";
         var bundleId:String = windowName + "ShareBoostActivation";
         var imageUrl:String = Global.getAssetURL(this.manager.currentWeekBoostIcon);
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":imageUrl
            }],
            "user":Global.player.name,
            "first_name":Global.player.firstName,
            "item":"None"
         };
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
         this.closeBoostActivatedPopup();
      }
      
      public function showTropicRewardPopup(visibility:Boolean) : void
      {
         if(this.m_tropic_reward_popup_mc)
         {
            this.m_tropic_reward_popup_mc.visible = visibility;
            if(this.m_tropic_reward_okay_bt)
            {
               this.m_tropic_reward_okay_bt.visible = visibility;
            }
         }
      }
      
      private function onTropicRewardOkayButtonClick(event:MouseEvent) : void
      {
         this.showTropicRewardPopup(false);
      }
      
      public function triggerTropicIntro() : void
      {
         if(!Global.player.getSeenFlag(TROPIC_INTRO_SEEN))
         {
            this.showTropicIntro();
         }
      }
      
      private function showTropicIntro() : void
      {
         if(this.m_intro_mc)
         {
            this.m_current_tutorial_step = 0;
            this.refreshIntroFrame();
         }
      }
      
      private function onClickIntroButton(event:MouseEvent) : void
      {
         ++this.m_current_tutorial_step;
         this.refreshIntroFrame();
      }
      
      private function refreshIntroFrame() : void
      {
         var i:int = 0;
         if(this.m_intro_mc)
         {
            this.m_intro_mc.visible = this.m_current_tutorial_step < this.TOTAL_INTRO_STEPS;
            this.m_intro_mc.gotoAndStop(this.m_current_tutorial_step + 1);
         }
         if(Boolean(this.m_intro_okay_bt) && this.m_intro_okay_bt.length == TOTAL_INTRO_BUTTONS)
         {
            for(i = 0; i < TOTAL_INTRO_BUTTONS; i++)
            {
               this.m_intro_okay_bt[i].visible = i == this.m_current_tutorial_step;
            }
         }
         if(this.m_current_tutorial_step == this.TOTAL_INTRO_STEPS)
         {
            if(!Global.player.getSeenFlag(TROPIC_INTRO_SEEN))
            {
               Global.player.setSeenFlag(TROPIC_INTRO_SEEN);
               this.updateNewDayData(true);
            }
         }
      }
      
      private function onClickBoostReminderOkayButton(event:MouseEvent) : void
      {
         this.closeBoostReminderPopup();
         this.manager.resetTasksWithoutBoostCount();
      }
      
      private function onClickTravelHelpButton(event:MouseEvent) : void
      {
      }
      
      private function setTropicIntroSteps() : void
      {
         this.TOTAL_INTRO_STEPS = 3;
      }
      
      private function shouldShowMigrationScenarioPopup() : Boolean
      {
         var tokensCollected:int = this.manager.getEscapeTokensCollected();
         return tokensCollected <= 0;
      }
      
      private function getLandRewardsText() : String
      {
         var briefText:String = null;
         var tokensRequired:int = this.manager.getEscapeTokensRequiredForNextTile() - this.manager.getEscapeTokensCollected();
         if(tokensRequired < 0)
         {
            tokensRequired = 0;
         }
         if(tokensRequired == 0)
         {
            briefText = "You can now unlock " + this.manager.getCurrentTileFriendlyName();
         }
         else if(this.manager.getCurrentTileLevel() >= 5)
         {
            briefText = "Congrats! You have got 5 land expansions free!";
         }
         else
         {
            briefText = "Collect " + String(tokensRequired) + " more Escape Tokens to unlock " + this.manager.getCurrentTileFriendlyName();
         }
         return briefText;
      }
      
      private function getBoostActiveInfoText() : String
      {
         return "You will get 2X Produce on your next " + String(this.manager.getOrderboardBoostsAvailable()) + " tasks!";
      }
      
      private function onClickBoostEndedOkayButton(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"BoostExpire_Dialog","Okay");
         this.closeBoostEndedPopup();
      }
      
      private function onClickBoostActivatedOkayButton(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"BoostActivate_Dialog","Close");
         this.closeBoostActivatedPopup();
      }
      
      private function onClickActivateBoostButton(event:MouseEvent) : void
      {
         this.manager.activateOrderboardBoost();
      }
      
      private function getEscapeTokensTextForBoostPanel() : String
      {
         return " " + String(this.manager.getEscapeTokensAvailable()) + "/" + String(this.manager.getEscapeTokensRequiredForABoost());
      }
      
      public function refreshBoostComponents() : void
      {
         this.refreshBoostPanel();
         this.refreshBoostActiveGlow();
         this.refreshTERewardsPanel();
         this.refreshTETaskText();
         if(Global.player.getSeenFlag(this.FLAG_BOOST_POPUP_SEEN) && this.manager.getOrderboardBoostsAvailable() == 0)
         {
            Global.player.resetSeenFlag(this.FLAG_BOOST_POPUP_SEEN);
            this.closeBoostActivatedPopup();
            this.showBoostEndedPopup();
         }
         if(this.shouldShowBoostReminderPopup())
         {
            this.showBoostReminderPopup();
         }
      }
      
      private function refreshTETaskText() : void
      {
         var message:String = null;
         if(this.m_te_task_text_tf)
         {
            message = "Click below to start earning \'Escape Tokens\' in Tropic Escape";
            if(this.manager.getEscapeTokensCollected() > 0)
            {
               message = "Travel to earn more \'Escape Tokens\' in Tropic Escape";
            }
            this.m_te_task_text_tf.text = message;
         }
      }
      
      private function shouldShowBoostReminderPopup() : Boolean
      {
         var tasksDoneWithoutOrderboardBoosts:int = this.manager.getTasksDoneWithoutOrderboardBoost();
         return tasksDoneWithoutOrderboardBoosts >= 5;
      }
      
      private function refreshTERewardsPanel() : void
      {
         if(this.m_te_reward_pane_mc)
         {
            this.m_te_reward_pane_mc.visible = true;
            if(this.m_te_sf_brief_tf)
            {
               this.m_te_sf_brief_tf.text = this.getLandRewardsText();
               this.m_te_sf_brief_tf.visible = true;
            }
            if(this.m_te_sf_count_tf)
            {
               this.m_te_sf_count_tf.text = String(this.manager.getEscapeTokensCollected()) + "/" + String(this.manager.getEscapeTokensRequiredForNextTile());
               if(this.manager.getCurrentTileLevel() >= this.MAX_TILE_LEVEL)
               {
                  this.m_te_sf_count_tf.text = String(this.manager.getEscapeTokensCollected());
               }
               this.m_te_sf_count_tf.visible = true;
            }
         }
      }
      
      private function refreshBoostActiveGlow() : void
      {
         var isBoostActivated:Boolean = this.manager.isOrderboardBoostAvailable();
         if(this.m_boost_active_glow1_mc)
         {
            this.m_boost_active_glow1_mc.visible = isBoostActivated;
            if(this.m_boost_active_glow_mc)
            {
               this.m_boost_active_glow_mc.visible = isBoostActivated;
            }
         }
      }
      
      private function refreshBoostPanel() : void
      {
         var currentWeek:int = 0;
         var isBoostActivated:Boolean = this.manager.isOrderboardBoostAvailable();
         var escapeTokensAvailable:int = this.manager.getEscapeTokensAvailable();
         if(this.m_boost_mc)
         {
            this.m_boost_mc.visible = true;
            if(this.m_boost_activate_bt)
            {
               this.m_boost_activate_bt.visible = !isBoostActivated;
               this.m_boost_activate_bt.enabled = escapeTokensAvailable >= this.manager.getEscapeTokensRequiredForABoost();
            }
            if(this.m_boost_active_info_tf)
            {
               this.m_boost_active_info_tf.text = this.getBoostActiveInfoText();
               this.m_boost_active_info_tf.visible = isBoostActivated;
            }
            if(this.m_boost_active_stage_tf)
            {
               this.m_boost_active_stage_tf.visible = isBoostActivated;
            }
            if(this.m_boost_non_active_info_tf)
            {
               this.m_boost_non_active_info_tf.visible = !isBoostActivated;
            }
            if(this.m_boost_sf_count_tf)
            {
               this.m_boost_sf_count_tf.text = this.getEscapeTokensTextForBoostPanel();
               this.m_boost_sf_count_tf.visible = true;
            }
            if(this.m_boost_icon_mc)
            {
               currentWeek = int(this.manager.getCurrentWeek().count);
               this.m_boost_icon_mc.gotoAndStop(currentWeek);
            }
         }
      }
      
      private function onClickViewTileRewards(event:MouseEvent) : void
      {
         var currentTileNumber:String = String(this.manager.getCurrentTileLevel() + 1);
         StatsManager.count(this.m_featureName,"mainui","LandReward","View_Click",currentTileNumber);
         this.manager.showTileRewardsWindow();
      }
      
      public function preSwitchChangesMain(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Great!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(0);
               m_tutorial.visible = true;
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Redeem";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Cool!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "Enter Shop";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "Cool!";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClickMain;
               m_tutorial.visible = true;
               tutorialSceneNumber = 5;
               this.hideOtherTutorialButtonsExpect(4);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "View";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(5);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
         }
      }
      
      protected function onTutorialOkayButtonClickMain(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes - 1)
         {
            if(tutorialSceneNumber == 4)
            {
               hideTutorial();
               this.manager.showMarketUI();
            }
            else
            {
               this.preSwitchChangesMain(tutorialSceneNumber);
               ++tutorialSceneNumber;
            }
         }
         else
         {
            hideTutorial();
            this.openRewardsWindow();
         }
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_minitutorial_frame.visible = false;
         }
      }
      
      private function howDoesThisEscapeWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_escape_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_escape_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_escape_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_escape_minitutorial_frame.visible = false;
         }
      }
      
      private function hideOtherTutorialButtonsExpect(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      public function showConversionPopup(goldCoins:int = 0) : void
      {
         var prod_icon:FarmIcon = null;
         if(this.m_conversion_mc)
         {
            if(this.m_conversion_mc.hasOwnProperty("produce1_icon"))
            {
               prod_icon = new FarmIcon(this.m_conversion_mc["produce1_icon"]);
               prod_icon.loadIcon(this.manager.previousWeekIcon);
            }
            if(this.m_conversion_mc.hasOwnProperty("tranjaction_brief"))
            {
               addWidget(new ZwTextField(this.m_conversion_mc["tranjaction_brief"],"Your previous week\'s produce has been converted to " + goldCoins.toString() + " Market Coins!"));
            }
            if(this.m_conversion_mc.hasOwnProperty("ok1_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_conversion_mc["ok1_bt"],"Great!",this.onClickConversionOverlay));
            }
            this.m_conversion_mc.visible = true;
         }
      }
      
      private function onClickConversionOverlay(e:Event = null) : void
      {
         if(Boolean(m_window) && Boolean(this.m_conversion_mc))
         {
            this.m_conversion_mc.visible = false;
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
      
      private function setPlayerHiglight(index:int, visibility:Boolean) : void
      {
         if(Boolean(this.m_players_mc[index]) && Boolean(this.m_players_mc[index].hasOwnProperty("playerslotglow_mc")))
         {
            this.m_players_mc[index]["playerslotglow_mc"].visible = visibility;
         }
      }
      
      public function updateStorageBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getCurrentProduceQty();
         var maxCapacity:int = this.manager.currentStorageCapacity;
         if(this.m_produce_count_tf)
         {
            this.m_produce_count_tf.text = dayPoints.toString() + "/" + maxCapacity.toString();
         }
         if(this.m_produce_icon)
         {
            this.m_produce_icon.loadIcon(this.manager.currentWeekSmallIcon);
            this.m_produce_icon.setIconSize(50,50);
         }
         var barLength:Number = dayPoints * this.PROGRESS_BAR_FULL_WIDTH / maxCapacity;
         if(this.m_bar_fill_mc)
         {
            if(dayPoints < 0)
            {
               this.m_bar_fill_mc.x = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_bar_fill_mc,2,{"x":barLength});
            }
            else
            {
               this.m_bar_fill_mc.x = barLength;
            }
         }
      }
      
      public function updateDailyProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dailyPoints:int = this.manager.getDayPoints();
         var maxCapacity:int = this.MAX_DAILY_LIMIT;
         if(this.m_daily_score_tf)
         {
            if(dailyPoints < 10000)
            {
               this.m_daily_score_tf.text = dailyPoints.toString() + "/10000";
            }
            else
            {
               this.m_daily_score_tf.text = "10000/10000";
            }
         }
         if(dailyPoints > maxCapacity)
         {
            dailyPoints = maxCapacity;
         }
         var barLength:Number = dailyPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / maxCapacity;
         if(this.m_gold_fill_mc)
         {
            if(dailyPoints < 0)
            {
               this.m_gold_fill_mc.x = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_gold_fill_mc,2,{"x":barLength});
            }
            else
            {
               this.m_gold_fill_mc.x = barLength;
            }
         }
      }
      
      private function onViewLeaderboardClick(e:Event = null) : void
      {
         this.manager.showLeaderboardUI();
      }
      
      private function onViewMarketClick(e:Event = null) : void
      {
         this.manager.showMarketUI();
      }
      
      private function onStorageUpgradeClick(e:Event = null) : void
      {
         var confirmationMessage:String = "Do you want to spend " + this.manager.getCostToUpgradeLevel().toString() + " FC to upgrade the storage capacity to " + this.manager.nextStorageCapacity.toString();
         UI.displayMessage(confirmationMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteAccept,"",true);
      }
      
      private function onStartNewDayClick(e:Event = null) : void
      {
         if(this.m_startnewday_mc)
         {
            this.m_startnewday_mc.visible = false;
         }
         this.tintWindow();
         this.enableInput = false;
         this.manager.startNewDay();
      }
      
      public function showWelcomeEAOverlay() : void
      {
         if(this.manager.isPlayerEA() && this.manager.currentWeekIndex == 0)
         {
            if(this.m_welcome_EA_mc)
            {
               this.m_welcome_EA_mc.visible = true;
            }
         }
      }
      
      public function showWelcomeGAOverlay() : void
      {
         if(!this.manager.isPlayerEA())
         {
            if(!Global.player.getSeenFlag(this.TROPICAL_MARKET_WELCOME_SEEN))
            {
               Global.player.setSeenFlag(this.TROPICAL_MARKET_WELCOME_SEEN);
               if(this.m_welcome_GA_mc)
               {
                  this.m_welcome_GA_mc.visible = true;
               }
            }
         }
      }
      
      public function onClickWelcomeOverlay(e:Event = null) : void
      {
         if(this.m_welcome_EA_mc)
         {
            this.m_welcome_EA_mc.visible = false;
         }
         if(this.m_welcome_GA_mc)
         {
            this.m_welcome_GA_mc.visible = false;
         }
      }
      
      private function onStartNewWeekClick(e:Event = null) : void
      {
         if(this.m_startweek_mc)
         {
            this.m_startweek_mc.visible = false;
         }
      }
      
      private function onConfirmCompleteAccept(event:GenericPopupEvent) : void
      {
         var amount:int = 0;
         if(event.button == GenericPopup.YES)
         {
            this.manager.upgradeStorageCapacity();
            if(this.m_upgrade_bt)
            {
               amount = this.manager.getCostToUpgradeLevel();
               this.m_upgrade_bt.setAmountText(amount.toString());
               if(amount == 0)
               {
                  this.m_upgrade_bt.enabled = false;
                  this.m_upgrade_bt.text = "at max";
                  this.m_upgrade_bt.attachTooltip(new FarmTextTooltip("Maximum capacity reached!"));
               }
               else
               {
                  this.m_upgrade_bt.enabled = true;
                  this.m_upgrade_bt.text = "Upgrade";
                  this.m_upgrade_bt.detachTooltip();
               }
            }
            if(this.m_storage_title_tf)
            {
               this.m_storage_title_tf.text = "STORAGE LEVEL " + this.manager.currentStorageLevel.toString();
            }
         }
         else
         {
            FarmStatsManager.count(FEATURE_NAME,"CancelPurchase");
         }
      }
      
      private function showStorageFullPopup() : void
      {
         if(this.m_storagefull_mc)
         {
            if(this.m_storagefull_tf)
            {
               if(this.manager.currentStorageCapacity == 400)
               {
                  this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage!\n Sell your produce in the TROPICAL SHOP to continue doing tasks.";
               }
               else
               {
                  this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage!\n Sell your produce in the TROPICAL SHOP or upgrade the Storage to continue doing tasks.";
               }
            }
            this.m_storagefull_mc.visible = true;
         }
      }
      
      private function closeStorageFullPopup() : void
      {
         if(this.m_storagefull_mc)
         {
            this.m_storagefull_mc.visible = false;
         }
      }
      
      private function get manager() : TropicalMarketInnovationManager
      {
         return TropicalMarketInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function showMainTutorial() : void
      {
         this.preSwitchChangesMain(0);
      }
      
      public function updateNewDayData(forced:Boolean = false) : void
      {
         var rewardItem:FarmItem = null;
         if(this.manager.hasActiveDayExpired() || forced)
         {
            rewardItem = this.manager.getNewDailyReward();
            if(rewardItem)
            {
               if(this.m_newdailyreward_icon)
               {
                  this.m_newdailyreward_icon.loadIcon(rewardItem.iconUrl);
               }
               if(this.m_dailyReward_icon)
               {
                  this.m_dailyReward_icon.loadIcon(rewardItem.iconUrl);
                  this.m_dailyReward_icon.setIconSize(50,50);
                  this.m_dailyReward_icon.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
               }
            }
            if(this.m_startnewday_mc)
            {
               this.m_startnewday_mc.visible = true;
               if(Boolean(m_window) && Boolean(this.m_checkmark_mc))
               {
                  this.m_checkmark_mc.visible = false;
               }
            }
            this.showWelcomeEAOverlay();
            this.showWelcomeGAOverlay();
            if(this.manager.hasActiveWeekExpired() && this.manager.currentWeekIndex != 0)
            {
               if(this.m_newweeklyproduce_icon)
               {
                  this.m_newweeklyproduce_icon.loadIcon(this.manager.currentWeekSmallIcon);
               }
               if(this.m_newweektitle_tf)
               {
                  this.m_newweektitle_tf.text = this.manager.getWeekProduceName(1) + " is here!";
               }
               if(this.m_newweekbody_tf)
               {
                  this.m_newweekbody_tf.text = this.manager.getWeekProduceName(1) + " is the new produce for this week! Leaderboard has been reset for the week.";
               }
               if(this.m_startweek_mc)
               {
                  this.m_startweek_mc.visible = true;
               }
            }
            if(this.manager.m_marketWindow)
            {
               this.manager.m_marketWindow.close();
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         var amount:int = 0;
         var dailyPoints:int = 0;
         this.updateStorageBar(false);
         this.updateDailyProgressBar(false);
         if(Boolean(m_window) && Boolean(this.m_upgrade_bt))
         {
            amount = this.manager.getCostToUpgradeLevel();
            if(amount == 0)
            {
               this.m_upgrade_bt.enabled = false;
               this.m_upgrade_bt.text = "at max";
               this.m_upgrade_bt.attachTooltip(new FarmTextTooltip("Maximum capacity reached!"));
            }
            else
            {
               this.m_upgrade_bt.enabled = true;
               this.m_upgrade_bt.text = "Upgrade";
               this.m_upgrade_bt.detachTooltip();
            }
         }
         if(Boolean(m_window) && Boolean(this.m_storage_title_tf))
         {
            this.m_storage_title_tf.text = "STORAGE LEVEL " + this.manager.currentStorageLevel.toString();
         }
         if(Boolean(m_window) && Boolean(this.m_storagefull_tf))
         {
            if(this.manager.currentStorageCapacity == 400)
            {
               this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage! Sell your produce in the TROPICAL SHOP to continue doing tasks.";
            }
            else
            {
               this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage! Sell your produce in the TROPICAL SHOP or upgrade the Storage to continue doing tasks.";
            }
         }
         if(!this.manager.isStorageCapacityFull())
         {
            this.untintWindow();
            this.enableInput = true;
            this.closeStorageFullPopup();
            this.manager.closeStoragePopups();
         }
         else
         {
            this.manager.closeStoragePopups();
            this.closeStorageFullPopup();
            this.showStorageFullPopup();
         }
         if(Boolean(m_window) && Boolean(this.m_daily_score_tf))
         {
            dailyPoints = this.manager.getDayPoints();
            if(dailyPoints < 10000)
            {
               this.m_daily_score_tf.text = dailyPoints.toString() + "/10000";
            }
            else
            {
               this.m_daily_score_tf.text = "10000/10000";
            }
         }
         if(Boolean(m_window) && Boolean(this.m_total_score_tf))
         {
            this.m_total_score_tf.text = this.manager.getTotalGoldCoins().toString();
         }
         var rewardItem:FarmItem = this.manager.getNewDailyReward();
         if(Boolean(rewardItem) && Boolean(this.m_dailyReward_icon) && Boolean(m_window))
         {
            this.m_dailyReward_icon.loadIcon(rewardItem.iconUrl);
            this.m_dailyReward_icon.setIconSize(50,50);
            this.m_dailyReward_icon.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
         }
         if(this.m_checkmark_mc)
         {
            this.m_checkmark_mc.visible = this.manager.isDailyRewardGranted() ? true : false;
         }
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.updateNewDayData();
         this.refreshDailyTimerText();
      }
      
      private function refreshDailyTimerText() : void
      {
         if(this.m_day_timer_tf)
         {
            this.m_day_timer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         }
         if(this.m_featuretime_tf)
         {
            this.m_featuretime_tf.text = this.manager.getFeatureEndDaysLeftText();
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
      
      private function openRewardsWindow(e:Event = null) : void
      {
         this.tintWindow();
         UI.displayPopup(new TropicalMarketInnovationRewardWindow(FEATURE_NAME,"assets/dialogs/FV_AugustInnovation_2020/FV_RewardScreen_AugustInnovation.swf"),false);
      }
      
      override public function close() : void
      {
         this.stopTimer();
         super.close();
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow = null;
         }
         FarmStatsManager.count("TropicalMarketMainWindow","Main_UI","close_window");
      }
      
      private function populateLeaderboardPaneData() : void
      {
         var index:int = 0;
         var playerData:Object = null;
         var zid:String = null;
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
               this.setPlayerHiglight(index,false);
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
                  zid = this.manager.getUserZid();
                  this.setPlayerHiglight(index,playerData["zid"] == zid);
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
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      private function howDoesThisEscapeWorkClick(event:Event) : void
      {
         if(this.m_escape_minitutorial_frame)
         {
            (this.m_escape_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_escape_minitutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE_TROPIC","START");
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
      
      override public function tintWindow() : void
      {
         if(m_window)
         {
            m_window.transform.colorTransform = new ColorTransform(0.2,0.2,0.2,1,0,0,0,0);
         }
      }
      
      public function showLeaderboardPaneData() : void
      {
         this.populateLeaderboardPaneData();
         this.showPlayersPane();
      }
      
      public function shouldShowWelcomeBackPopup() : Boolean
      {
         var tokensProgress:int = this.manager.getEscapeTokenProgress();
         return tokensProgress > 0;
      }
      
      public function showWelcomeBackPopup(progress:int) : void
      {
         if(Boolean(this.m_welcome_back_popup_mc) && this.hasSeenTropicalMarketFTUE())
         {
            this.m_welcome_back_popup_mc.visible = true;
            if(this.m_welcome_back_sf_icon_mc)
            {
               this.m_welcome_back_sf_icon_mc.visible = true;
            }
            if(this.m_welcome_back_header_tf)
            {
               this.m_welcome_back_header_tf.text = "Escape Tokens Earned!";
               this.m_welcome_back_header_tf.visible = true;
            }
            if(this.m_welcome_back_brief_tf)
            {
               this.m_welcome_back_brief_tf.text = "Welcome Back! You have earned " + progress + " Escape Tokens from Tropic Escape!";
               this.m_welcome_back_brief_tf.visible = true;
            }
            if(this.m_welcome_back_okay_bt)
            {
               this.m_welcome_back_okay_bt.text = "Cool!";
               this.m_welcome_back_okay_bt.visible = true;
            }
         }
      }
      
      public function closeWelcomeBackPopup() : void
      {
         if(this.m_welcome_back_popup_mc)
         {
            this.m_welcome_back_popup_mc.visible = false;
            if(this.m_welcome_back_sf_icon_mc)
            {
               this.m_welcome_back_sf_icon_mc.visible = false;
            }
            if(this.m_welcome_back_header_tf)
            {
               this.m_welcome_back_header_tf.visible = false;
            }
            if(this.m_welcome_back_brief_tf)
            {
               this.m_welcome_back_brief_tf.visible = false;
            }
            if(this.m_welcome_back_okay_bt)
            {
               this.m_welcome_back_okay_bt.visible = false;
            }
         }
      }
      
      public function showMigrationScenarioPopup() : void
      {
         if(Boolean(this.m_migration_mc) && this.hasSeenTropicalMarketFTUE())
         {
            this.m_migration_mc.visible = this.m_migration_popup_step < 2;
            if(this.m_migration_scenario_mc)
            {
               this.m_migration_scenario_mc.visible = this.m_migration_popup_step < 2;
               if(this.m_migration_arrow_mc)
               {
                  this.m_migration_arrow_mc.visible = this.m_migration_popup_step < 2;
               }
               this.m_migration_scenario_mc.gotoAndStop(this.m_migration_popup_step + 1);
            }
            if(this.m_migration_okay_bt)
            {
               this.m_migration_okay_bt.text = this.m_migration_popup_step == 0 ? "Next" : "Okay";
               this.m_migration_okay_bt.visible = this.m_migration_popup_step < 2;
            }
            if(this.m_migration_close_bt)
            {
               this.m_migration_close_bt.visible = this.m_migration_popup_step < 2 && Global.player.getSeenFlag(TROPIC_MIGRATION_POPUP_SEEN);
            }
         }
      }
      
      public function closeMigrationScenarioPopup() : void
      {
         if(this.m_migration_mc)
         {
            this.m_migration_mc.visible = false;
            if(this.m_migration_scenario_mc)
            {
               this.m_migration_scenario_mc.visible = false;
               if(this.m_migration_arrow_mc)
               {
                  this.m_migration_arrow_mc.visible = false;
               }
            }
            if(this.m_migration_okay_bt)
            {
               this.m_migration_okay_bt.visible = false;
            }
            if(this.m_migration_close_bt)
            {
               this.m_migration_close_bt.visible = false;
            }
         }
      }
      
      public function showTravelConfirmationPopup(event:MouseEvent) : void
      {
         if(Boolean(this.m_travel_confirmation_mc) && this.hasSeenTropicalMarketFTUE())
         {
            this.m_travel_confirmation_mc.visible = true;
            if(this.m_travel_now_bt)
            {
               this.m_travel_now_bt.visible = true;
            }
            if(this.m_travel_later_bt)
            {
               this.m_travel_later_bt.visible = true;
            }
            StatsManager.count(this.m_featureName,"mainui","Travel","Click");
         }
      }
      
      public function closeTravelConfirmationPopup() : void
      {
         if(this.m_travel_confirmation_mc)
         {
            this.m_travel_confirmation_mc.visible = false;
            if(this.m_travel_now_bt)
            {
               this.m_travel_now_bt.visible = false;
            }
            if(this.m_travel_later_bt)
            {
               this.m_travel_later_bt.visible = false;
            }
         }
      }
      
      public function showBoostEndedPopup() : void
      {
         var currentWeek:int = 0;
         if(Boolean(this.m_boost_popup_mc) && this.hasSeenTropicalMarketFTUE())
         {
            this.m_boost_popup_mc.visible = true;
            if(this.m_boost_end_popup_mc)
            {
               this.m_boost_end_popup_mc.visible = true;
               if(this.m_boost_end_icon_mc)
               {
                  currentWeek = int(this.manager.getCurrentWeek().count);
                  this.m_boost_end_icon_mc.gotoAndStop(currentWeek);
                  this.m_boost_end_icon_mc.visible = true;
               }
               if(this.m_boost_end_brief_tf)
               {
                  this.m_boost_end_brief_tf.text = "Looks like you made the most out of it! Collect more Escape Tokens to get more boost!\n";
                  this.m_boost_end_brief_tf.visible = true;
               }
               if(this.m_boost_end_title_tf)
               {
                  this.m_boost_end_title_tf.text = "Boost Expired!";
                  this.m_boost_end_title_tf.visible = true;
               }
               if(this.m_boost_end_okay_bt)
               {
                  this.m_boost_end_okay_bt.visible = true;
               }
            }
         }
      }
      
      public function closeBoostEndedPopup() : void
      {
         if(this.m_boost_popup_mc)
         {
            this.m_boost_popup_mc.visible = false;
            if(this.m_boost_end_popup_mc)
            {
               this.m_boost_end_popup_mc.visible = false;
               if(this.m_boost_end_icon_mc)
               {
                  this.m_boost_end_icon_mc.visible = false;
               }
               if(this.m_boost_end_brief_tf)
               {
                  this.m_boost_end_brief_tf.visible = false;
               }
               if(this.m_boost_end_title_tf)
               {
                  this.m_boost_end_title_tf.visible = false;
               }
               if(this.m_boost_end_okay_bt)
               {
                  this.m_boost_end_okay_bt.visible = true;
               }
            }
         }
      }
      
      public function showBoostActivatedPopup() : void
      {
         var currentWeek:int = 0;
         if(Boolean(this.m_boost_popup_mc) && this.hasSeenTropicalMarketFTUE())
         {
            this.m_boost_popup_mc.visible = true;
            if(this.m_boost_active_popup_mc)
            {
               this.m_boost_active_popup_mc.visible = true;
               if(this.m_boost_active_icon_mc)
               {
                  currentWeek = int(this.manager.getCurrentWeek().count);
                  this.m_boost_active_icon_mc.gotoAndStop(currentWeek);
                  this.m_boost_active_icon_mc.visible = true;
               }
               if(this.m_boost_active_brief_tf)
               {
                  this.m_boost_active_brief_tf.text = "The Boost has been activated! You will now get 2X Produce for the next 5 tasks!\n";
                  this.m_boost_active_brief_tf.visible = true;
               }
               if(this.m_boost_active_title_tf)
               {
                  this.m_boost_active_title_tf.text = "Boost Activated!";
                  this.m_boost_active_title_tf.visible = true;
               }
               if(this.m_boost_active_okay_bt)
               {
                  this.m_boost_active_okay_bt.visible = true;
               }
               if(this.m_boost_active_share_bt)
               {
                  this.m_boost_active_share_bt.visible = true;
               }
               if(this.m_boost_active_close_bt)
               {
                  this.m_boost_active_close_bt.visible = true;
               }
            }
         }
      }
      
      public function closeBoostActivatedPopup() : void
      {
         if(this.m_boost_popup_mc)
         {
            this.m_boost_popup_mc.visible = false;
            if(this.m_boost_active_popup_mc)
            {
               this.m_boost_active_popup_mc.visible = false;
               if(this.m_boost_active_icon_mc)
               {
                  this.m_boost_active_icon_mc.visible = false;
               }
               if(this.m_boost_active_brief_tf)
               {
                  this.m_boost_active_brief_tf.visible = false;
               }
               if(this.m_boost_active_title_tf)
               {
                  this.m_boost_active_title_tf.visible = false;
               }
               if(this.m_boost_active_okay_bt)
               {
                  this.m_boost_active_okay_bt.visible = false;
               }
               if(this.m_boost_active_share_bt)
               {
                  this.m_boost_active_share_bt.visible = false;
               }
               if(this.m_boost_active_close_bt)
               {
                  this.m_boost_active_close_bt.visible = false;
               }
            }
         }
      }
      
      public function showBoostReminderPopup() : void
      {
         var currentWeek:int = 0;
         if(this.m_boost_reminder_popup_mc)
         {
            this.m_boost_reminder_popup_mc.visible = true;
            if(this.m_boost_reminder_icon_mc)
            {
               currentWeek = int(this.manager.getCurrentWeek().count);
               this.m_boost_reminder_icon_mc.gotoAndStop(currentWeek);
               this.m_boost_reminder_icon_mc.visible = true;
            }
            if(this.m_boost_reminder_title_tf)
            {
               this.m_boost_reminder_title_tf.visible = true;
            }
            if(this.m_boost_reminder_brief_tf)
            {
               this.m_boost_reminder_brief_tf.visible = true;
            }
            if(this.m_boost_reminder_okay_bt)
            {
               this.m_boost_reminder_okay_bt.visible = true;
            }
         }
      }
      
      public function closeBoostReminderPopup() : void
      {
         if(this.m_boost_reminder_popup_mc)
         {
            this.m_boost_reminder_popup_mc.visible = false;
            if(this.m_boost_reminder_icon_mc)
            {
               this.m_boost_reminder_icon_mc.visible = false;
            }
            if(this.m_boost_reminder_title_tf)
            {
               this.m_boost_reminder_title_tf.visible = false;
            }
            if(this.m_boost_reminder_brief_tf)
            {
               this.m_boost_reminder_brief_tf.visible = false;
            }
            if(this.m_boost_reminder_okay_bt)
            {
               this.m_boost_reminder_okay_bt.visible = false;
            }
         }
      }
      
      public function onWelcomeBackOkayButton(event:MouseEvent) : void
      {
         this.closeWelcomeBackPopup();
      }
      
      private function trackMigrationScenarioClicks(hasClosed:Boolean) : void
      {
         var classVariable:String = null;
         if(this.m_migration_popup_step >= 0 && this.m_migration_popup_step < 2)
         {
            classVariable = this.TRAVEL_DIALOG_CLASS[this.m_migration_popup_step];
            if(hasClosed)
            {
               classVariable = "Close";
            }
            StatsManager.count(this.m_featureName,"Travel_Dialog_FirstTime",this.TRAVEL_DIALOG_PHYLUM[this.m_migration_popup_step],classVariable);
         }
      }
      
      public function onClickMigrationScenarioButton(event:MouseEvent) : void
      {
         this.trackMigrationScenarioClicks(false);
         ++this.m_migration_popup_step;
         if(this.m_migration_popup_step >= 2)
         {
            Global.player.setSeenFlag(TROPIC_MIGRATION_POPUP_SEEN);
         }
         this.showMigrationScenarioPopup();
      }
      
      public function onClickMigrationScenarionClose(event:MouseEvent) : void
      {
         this.trackMigrationScenarioClicks(true);
         this.closeMigrationScenarioPopup();
      }
      
      public function onClickTravelLaterButton(event:MouseEvent) : void
      {
         this.closeTravelConfirmationPopup();
         StatsManager.count(this.m_featureName,"Travel_Dialog","Later");
      }
      
      public function onClickTravelNowButton(event:MouseEvent) : void
      {
         this.closeTravelConfirmationPopup();
         this.manager.travelToTropicEscape();
         this.close();
         StatsManager.count(this.m_featureName,"Travel_Dialog","Yes");
      }
      
      public function hasSeenTropicalMarketFTUE() : Boolean
      {
         return Global.player.getSeenFlag(this.manager.TROPICAL_MARKET_MARKET_FTUE_SEEN);
      }
      
      public function refreshTERewardPane() : void
      {
         if(this.m_te_sf_brief_tf)
         {
            this.m_te_sf_brief_tf.text = this.getLandRewardsText();
            this.m_te_sf_brief_tf.visible = true;
         }
      }
   }
}

