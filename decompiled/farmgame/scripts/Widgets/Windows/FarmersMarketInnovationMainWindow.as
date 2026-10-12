package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
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
   
   public class FarmersMarketInnovationMainWindow extends FarmersMarketInnovationGenericOrderboardWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      private static const FEATURE_TRACKING:String = "FarmersMarket2020Innovation";
      
      private static const FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_featureName:String = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 146;
      
      private const MAX_DAILY_LIMIT:int = 10000;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const FARMERS_MARKET_MAIN_FTUE_SEEN:String = "farmersmarket2020_main_ftue_seen";
      
      private const FARMERS_MARKET_WELCOME_SEEN:String = "farmersmarket2020_welcome_seen";
      
      private const FLAG_FIRST_STARTNEWDAY:String = "farmersmarket2020_first_newday";
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_timer:Timer;
      
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
      
      private var m_welcome_EA_mc:MovieClip;
      
      private var m_welcome_GA_mc:MovieClip;
      
      private var m_storage_title_tf:ZwTextField;
      
      public function FarmersMarketInnovationMainWindow(featureName:String = "FarmersMarket2020Innovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
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
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"FARMERS MARKET"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Do tasks to get produce, which can be sold in the market to earn coins and progress!"));
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
               addWidget(new FarmAnimatedTextButton(this.m_market_mc["market_bt"],"ENTER SHOP",this.onViewMarketClick));
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
                  this.m_dailyReward_icon.setIconSize(90,90);
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
         this.updateStorageBar(true);
         this.updateDailyProgressBar(true);
         this.startTimer();
         if(this.manager.isStorageCapacityFull())
         {
            this.showStorageFullPopup();
         }
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
         if(!Global.player.getSeenFlag(this.FARMERS_MARKET_MAIN_FTUE_SEEN) && !Global.player.getSeenFlag(this.FLAG_FIRST_STARTNEWDAY))
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
               button3.text = "ENTER SHOP";
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
            this.updateNewDayData(true);
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
         var barLength:Number = dailyPoints * this.PROGRESS_BAR_FULL_WIDTH / maxCapacity;
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
            if(!Global.player.getSeenFlag(this.FARMERS_MARKET_WELCOME_SEEN))
            {
               Global.player.setSeenFlag(this.FARMERS_MARKET_WELCOME_SEEN);
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
                  this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage!\n Sell your produce in the FARM SHOP to continue doing tasks.";
               }
               else
               {
                  this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage!\n Sell your produce in the FARM SHOP or upgrade the Storage to continue doing tasks.";
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
      
      private function get manager() : FarmersMarketInnovationManager
      {
         return FarmersMarketInnovationManager.getInstance(FEATURE_NAME);
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
                  this.m_dailyReward_icon.setIconSize(90,90);
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
               this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage! Sell your produce in the FARM SHOP to continue doing tasks.";
            }
            else
            {
               this.m_storagefull_tf.text = "You have reached the maximum capacity of your Storage! Sell your produce in the FARM SHOP or upgrade the Storage to continue doing tasks.";
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
            this.m_dailyReward_icon.setIconSize(90,90);
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
         UI.displayPopup(new FarmersMarketInnovationRewardWindow(FEATURE_NAME,"assets/dialogs/FV_Jan_innovation/FV_RewardScreen_FarmersMarket.swf"),false);
      }
      
      override public function close() : void
      {
         this.stopTimer();
         super.close();
         FarmStatsManager.count("FarmersMarketMainWindow","Main_UI","close_window");
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
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
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
   }
}

