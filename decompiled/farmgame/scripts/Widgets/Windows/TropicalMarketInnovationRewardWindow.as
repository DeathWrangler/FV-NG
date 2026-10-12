package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TropicalMarketInnovationRewardWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_NAME:String = "TropicalMarketInnovation";
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const TROPICAL_MARKET_REWARDS_FTUE_SEEN:String = "tropical_market_rewards_ftue_seen";
      
      private const TROPICAL_MARKET_MAIN_FTUE_SEEN:String = "tropical_market_main_ftue_seen";
      
      private const TROPICAL_MARKET_MARKET_FTUE_SEEN:String = "tropical_market_market_ftue_seen";
      
      private var m_bodyTf:ZwTextField;
      
      private var m_rewardslotPane:MovieClip;
      
      private var m_reward0Cell:MovieClip;
      
      private var m_reward0BadgeIcon:FarmIcon;
      
      private var m_coinscount0_tf:ZwTextField;
      
      private var m_reward0RewardIcon:FarmIcon;
      
      private var m_reward1Cell:MovieClip;
      
      private var m_reward1BadgeIcon:FarmIcon;
      
      private var m_reward1RewardIcon:FarmIcon;
      
      private var m_reward2Cell:MovieClip;
      
      private var m_reward2BadgeIcon:FarmIcon;
      
      private var m_reward2RewardIcon:FarmIcon;
      
      private var m_reward3Cell:MovieClip;
      
      private var m_reward3BadgeIcon:FarmIcon;
      
      private var m_reward3RewardIcon:FarmIcon;
      
      private var m_coinscount1_tf:ZwTextField;
      
      private var requiredcoins1_tf:ZwTextField;
      
      private var rewardname1_tf:ZwTextField;
      
      private var m_coinscount2_tf:ZwTextField;
      
      private var requiredcoins2_tf:ZwTextField;
      
      private var rewardname2_tf:ZwTextField;
      
      private var m_coinscount3_tf:ZwTextField;
      
      private var requiredcoins3_tf:ZwTextField;
      
      private var rewardname3_tf:ZwTextField;
      
      private var m_progressbar:MovieClip;
      
      private var m_slotProgressbar:MovieClip;
      
      private var m_barFillMc:MovieClip;
      
      private var m_points_tf:ZwTextField;
      
      private var m_milestone0Mc:ZwFrame;
      
      private var m_milestone1Mc:ZwFrame;
      
      private var m_milestone2Mc:ZwFrame;
      
      private var m_milestone3Mc:ZwFrame;
      
      private var m_milestone4Mc:ZwFrame;
      
      private var m_milestone5Mc:ZwFrame;
      
      private var m_milestone6Mc:ZwFrame;
      
      private var m_checkmark0:MovieClip;
      
      private var m_checkmark1:MovieClip;
      
      private var m_checkmark2:MovieClip;
      
      private var m_checkmark3:MovieClip;
      
      private var m_checkmark4:MovieClip;
      
      private var m_checkmark5:MovieClip;
      
      private var m_checkmark6:MovieClip;
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      public function TropicalMarketInnovationRewardWindow(featureName:String = "TropicalMarketInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardItem0:FarmItem = null;
         var rewardItem1:FarmItem = null;
         var rewardItem2:FarmItem = null;
         var rewardItem3:FarmItem = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"BONUS REWARDS"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window["body_tf"]));
         }
         if(m_window.hasOwnProperty("rewardslot_pane"))
         {
            this.m_rewardslotPane = m_window["rewardslot_pane"] as MovieClip;
            this.m_rewardslotPane.visible = true;
            if(this.m_rewardslotPane.hasOwnProperty("reward0_cell"))
            {
               this.m_reward0Cell = this.m_rewardslotPane["reward0_cell"] as MovieClip;
               this.m_reward0Cell.visible = true;
               rewardItem0 = Global.farmGameSettingsManager.getFarmItemByName("xah_pineappledrinkhut");
               if(this.m_reward0Cell.hasOwnProperty("reward_icon"))
               {
                  this.m_reward0RewardIcon = new FarmIcon(this.m_reward0Cell["reward_icon"]);
                  this.m_reward0RewardIcon.loadIcon("assets/buildings/xah_pineappledrinkhut_icon_200.png");
                  this.m_reward0RewardIcon.setIconSize(130,130);
                  this.m_reward0RewardIcon.visible = true;
                  this.m_reward0RewardIcon.attachTooltip(new FarmTextTooltip(this.getAverageTooltipText(0)));
               }
               if(this.m_reward0Cell.hasOwnProperty("coinscount_tf"))
               {
                  this.m_coinscount0_tf = new ZwTextField(this.m_reward0Cell["coinscount_tf"]);
                  this.m_coinscount0_tf.text = "50,000";
                  this.m_coinscount0_tf.visible = true;
               }
               if(this.m_reward0Cell.hasOwnProperty("requiredcoins_tf"))
               {
                  addWidget(new ZwTextField(this.m_reward0Cell["requiredcoins_tf"],"Coins required:"));
               }
               if(this.m_reward0Cell.hasOwnProperty("rewardname_tf"))
               {
                  addWidget(new ZwTextField(this.m_reward0Cell["rewardname_tf"],rewardItem0.friendlyTitle));
               }
            }
            if(this.m_rewardslotPane.hasOwnProperty("reward1_cell"))
            {
               this.m_reward1Cell = this.m_rewardslotPane["reward1_cell"] as MovieClip;
               this.m_reward1Cell.visible = true;
               rewardItem1 = Global.farmGameSettingsManager.getFarmItemByName("xah_fruitdrinkshop");
               if(this.m_reward1Cell.hasOwnProperty("reward_icon"))
               {
                  this.m_reward1RewardIcon = new FarmIcon(this.m_reward1Cell["reward_icon"]);
                  this.m_reward1RewardIcon.loadIcon("assets/buildings/xah_fruitdrinkshop_icon_200.png");
                  this.m_reward1RewardIcon.setIconSize(130,130);
                  this.m_reward1RewardIcon.visible = true;
                  this.m_reward1RewardIcon.attachTooltip(new FarmTextTooltip(this.getAverageTooltipText(1)));
               }
               if(this.m_reward1Cell.hasOwnProperty("coinscount_tf"))
               {
                  this.m_coinscount1_tf = new ZwTextField(this.m_reward1Cell["coinscount_tf"]);
                  this.m_coinscount1_tf.text = "300,000";
                  this.m_coinscount1_tf.visible = true;
               }
               if(this.m_reward1Cell.hasOwnProperty("requiredcoins_tf"))
               {
                  this.requiredcoins1_tf = new ZwTextField(this.m_reward1Cell["requiredcoins_tf"]);
                  this.requiredcoins1_tf.text = "Coins required:";
                  this.requiredcoins1_tf.visible = true;
               }
               if(this.m_reward1Cell.hasOwnProperty("rewardname_tf"))
               {
                  this.rewardname1_tf = new ZwTextField(this.m_reward1Cell["rewardname_tf"],rewardItem1.friendlyTitle);
                  this.rewardname1_tf.visible = true;
               }
            }
            if(this.m_rewardslotPane.hasOwnProperty("reward2_cell"))
            {
               this.m_reward2Cell = this.m_rewardslotPane["reward2_cell"] as MovieClip;
               this.m_reward2Cell.visible = true;
               rewardItem2 = Global.farmGameSettingsManager.getFarmItemByName("xah_freshsummerbar");
               if(this.m_reward2Cell.hasOwnProperty("reward_icon"))
               {
                  this.m_reward2RewardIcon = new FarmIcon(this.m_reward2Cell["reward_icon"]);
                  this.m_reward2RewardIcon.loadIcon("assets/buildings/xah_freshsummerbar_icon_200.png");
                  this.m_reward2RewardIcon.setIconSize(130,130);
                  this.m_reward2RewardIcon.visible = true;
                  this.m_reward2RewardIcon.attachTooltip(new FarmTextTooltip(this.getAverageTooltipText(2)));
               }
               if(this.m_reward2Cell.hasOwnProperty("coinscount_tf"))
               {
                  this.m_coinscount2_tf = new ZwTextField(this.m_reward2Cell["coinscount_tf"]);
                  this.m_coinscount2_tf.text = "800,000";
                  this.m_coinscount2_tf.visible = true;
               }
               if(this.m_reward2Cell.hasOwnProperty("requiredcoins_tf"))
               {
                  this.requiredcoins2_tf = new ZwTextField(this.m_reward2Cell["requiredcoins_tf"]);
                  this.requiredcoins2_tf.text = "Coins required:";
                  this.requiredcoins2_tf.visible = true;
               }
               if(this.m_reward2Cell.hasOwnProperty("rewardname_tf"))
               {
                  this.rewardname2_tf = new ZwTextField(this.m_reward2Cell["rewardname_tf"],rewardItem2.friendlyTitle);
                  this.rewardname2_tf.visible = true;
               }
            }
            if(this.m_rewardslotPane.hasOwnProperty("reward3_cell"))
            {
               this.m_reward3Cell = this.m_rewardslotPane["reward3_cell"] as MovieClip;
               this.m_reward3Cell.visible = true;
               rewardItem3 = Global.farmGameSettingsManager.getFarmItemByName("xah_islandjuicemarket");
               if(this.m_reward3Cell.hasOwnProperty("reward_icon"))
               {
                  this.m_reward3RewardIcon = new FarmIcon(this.m_reward3Cell["reward_icon"]);
                  this.m_reward3RewardIcon.loadIcon("assets/buildings/xah_islandjuicemarket_icon_200.png");
                  this.m_reward3RewardIcon.setIconSize(130,130);
                  this.m_reward3RewardIcon.visible = true;
                  this.m_reward3RewardIcon.attachTooltip(new FarmTextTooltip(this.getAverageTooltipText(3)));
               }
               if(this.m_reward3Cell.hasOwnProperty("coinscount_tf"))
               {
                  this.m_coinscount3_tf = new ZwTextField(this.m_reward3Cell["coinscount_tf"]);
                  this.m_coinscount3_tf.text = "1,500,000";
                  this.m_coinscount3_tf.visible = true;
               }
               if(this.m_reward3Cell.hasOwnProperty("requiredcoins_tf"))
               {
                  this.requiredcoins3_tf = new ZwTextField(this.m_reward3Cell["requiredcoins_tf"]);
                  this.requiredcoins3_tf.text = "Coins required:";
                  this.requiredcoins3_tf.visible = true;
               }
               if(this.m_reward3Cell.hasOwnProperty("rewardname_tf"))
               {
                  this.rewardname3_tf = new ZwTextField(this.m_reward3Cell["rewardname_tf"],rewardItem3.friendlyTitle);
                  this.rewardname3_tf.visible = true;
               }
            }
            if(m_window.hasOwnProperty("progressbar"))
            {
               this.m_progressbar = m_window["progressbar"] as MovieClip;
               this.m_progressbar.visible = true;
               if(this.m_progressbar.hasOwnProperty("tcoincount_tf"))
               {
                  addWidget(this.m_points_tf = new ZwTextField(this.m_progressbar["tcoincount_tf"],this.manager.getTotalGoldCoins().toString()));
               }
               if(this.m_progressbar.hasOwnProperty("slotmc_progressbar"))
               {
                  this.m_slotProgressbar = this.m_progressbar["slotmc_progressbar"] as MovieClip;
                  this.m_slotProgressbar.visible = true;
                  if(this.m_slotProgressbar.hasOwnProperty("bar_fill_mc"))
                  {
                     this.m_barFillMc = this.m_slotProgressbar["bar_fill_mc"] as MovieClip;
                     this.m_barFillMc.visible = true;
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward0_cell"))
                  {
                     this.m_milestone0Mc = new ZwFrame(this.m_slotProgressbar["milestonereward0_cell"]);
                     this.m_milestone0Mc.visible = true;
                     this.m_milestone0Mc.attachTooltip(new FarmTextTooltip("50,000 Tropical Drink Horse"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward1_cell"))
                  {
                     this.m_milestone1Mc = new ZwFrame(this.m_slotProgressbar["milestonereward1_cell"]);
                     this.m_milestone1Mc.visible = true;
                     this.m_milestone1Mc.attachTooltip(new FarmTextTooltip("100,000 Pineapple Unicorn"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward2_cell"))
                  {
                     this.m_milestone2Mc = new ZwFrame(this.m_slotProgressbar["milestonereward2_cell"]);
                     this.m_milestone2Mc.visible = true;
                     this.m_milestone2Mc.attachTooltip(new FarmTextTooltip("250,000 Beach Resort Unicorn"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward3_cell"))
                  {
                     this.m_milestone3Mc = new ZwFrame(this.m_slotProgressbar["milestonereward3_cell"]);
                     this.m_milestone3Mc.visible = true;
                     this.m_milestone3Mc.attachTooltip(new FarmTextTooltip("500,000 Tropical Tourist Pegasus"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward4_cell"))
                  {
                     this.m_milestone4Mc = new ZwFrame(this.m_slotProgressbar["milestonereward4_cell"]);
                     this.m_milestone4Mc.visible = true;
                     this.m_milestone4Mc.attachTooltip(new FarmTextTooltip("800,000 Aloha Blue Pegasus"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward5_cell"))
                  {
                     this.m_milestone5Mc = new ZwFrame(this.m_slotProgressbar["milestonereward5_cell"]);
                     this.m_milestone5Mc.visible = true;
                     this.m_milestone5Mc.attachTooltip(new FarmTextTooltip("1,200,000 Island Adventure Pegacorn"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("milestonereward6_cell"))
                  {
                     this.m_milestone6Mc = new ZwFrame(this.m_slotProgressbar["milestonereward6_cell"]);
                     this.m_milestone6Mc.visible = true;
                     this.m_milestone6Mc.attachTooltip(new FarmTextTooltip("1,500,000 Tiki Pegacorn"));
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark0"))
                  {
                     this.m_checkmark0 = this.m_slotProgressbar["checkmark0"] as MovieClip;
                     this.m_checkmark0.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[0];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark1"))
                  {
                     this.m_checkmark1 = this.m_slotProgressbar["checkmark1"] as MovieClip;
                     this.m_checkmark1.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[1];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark2"))
                  {
                     this.m_checkmark2 = this.m_slotProgressbar["checkmark2"] as MovieClip;
                     this.m_checkmark2.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[2];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark3"))
                  {
                     this.m_checkmark3 = this.m_slotProgressbar["checkmark3"] as MovieClip;
                     this.m_checkmark3.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[3];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark4"))
                  {
                     this.m_checkmark4 = this.m_slotProgressbar["checkmark4"] as MovieClip;
                     this.m_checkmark4.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[4];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark5"))
                  {
                     this.m_checkmark5 = this.m_slotProgressbar["checkmark5"] as MovieClip;
                     this.m_checkmark5.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[5];
                  }
                  if(this.m_slotProgressbar.hasOwnProperty("checkmark6"))
                  {
                     this.m_checkmark6 = this.m_slotProgressbar["checkmark6"] as MovieClip;
                     this.m_checkmark6.visible = this.manager.getTotalGoldCoins() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[6];
                  }
               }
            }
            this.updateEarnedPoints();
            if(m_window.hasOwnProperty("howDoesThisWork_mc"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,TEXT_WHATISTHIS),this.howDoesThisWorkClick));
            }
            if(m_window.hasOwnProperty("tutorial2_mc"))
            {
               this.m_mini_tutorial_mc = m_window["tutorial2_mc"] as MovieClip;
               this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
               if(this.m_mini_tutorial_mc.hasOwnProperty("okay_bt"))
               {
                  this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_mini_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
                  this.m_mini_tutorial_mc["okay_bt"].visible = true;
               }
               this.m_mini_tutorial_mc.visible = false;
            }
            if(!Global.player.getSeenFlag(this.TROPICAL_MARKET_REWARDS_FTUE_SEEN))
            {
               if(this.m_minitutorial_frame)
               {
                  (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
                  this.m_minitutorial_frame.visible = true;
                  FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
               }
            }
         }
      }
      
      private function getAverageTooltipText(id:int) : *
      {
         var averages:Array = [["1429","8571","22857","42857"],["1190","7143","19048","35714"]];
         var totalGoldCoins:int = this.manager.getTotalGoldCoins();
         var daysToCountForAverage:int = this.manager.currentDayIndex + 1;
         var average:int = totalGoldCoins / daysToCountForAverage;
         var isEAPlayer:Boolean = WorldSeasonsManager.getInstance().isEAUser("aloha");
         if(!isEAPlayer && daysToCountForAverage > 7)
         {
            average = totalGoldCoins / (daysToCountForAverage - 7);
         }
         return "Earn an average of " + averages[int(isEAPlayer)][id] + " coins daily to win this reward. Your current average is " + average.toString();
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
            if(!Global.player.getSeenFlag(this.TROPICAL_MARKET_REWARDS_FTUE_SEEN))
            {
               Global.player.setSeenFlag(this.TROPICAL_MARKET_REWARDS_FTUE_SEEN);
               Global.player.setSeenFlag(this.TROPICAL_MARKET_MAIN_FTUE_SEEN);
               Global.player.setSeenFlag(this.TROPICAL_MARKET_MARKET_FTUE_SEEN);
               this.close();
               if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
               {
                  this.manager.mainWindow.triggerTropicIntro();
               }
            }
         }
      }
      
      public function updateEarnedPoints(onOpenWindow:* = false) : void
      {
         var progressPoints:int = 0;
         var barWidth:Number = NaN;
         if(this.m_barFillMc)
         {
            progressPoints = this.manager.getTotalGoldCoins();
            barWidth = Math.min(progressPoints,1500000) * 700 / 1500000;
            this.m_points_tf.visible = true;
            this.m_barFillMc.visible;
            if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barFillMc,2,{"x":barWidth});
            }
            else
            {
               this.m_barFillMc.x = barWidth;
            }
         }
      }
      
      private function get manager() : TropicalMarketInnovationManager
      {
         return TropicalMarketInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         super.close();
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
         }
         FarmStatsManager.count("TropicalMarketInnovation","Main_UI","close_window");
      }
   }
}

