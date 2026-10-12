package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.HalloweenUSAInnovationRewardsFrame;
   import Widgets.Frames.HalloweenUSAInnovationRewardsListFrame;
   import Widgets.Frames.HalloweenUSAInnovationTaskFrame;
   import Widgets.Frames.TabMenu;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HalloweenUSAInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      public static var TAB_NAMES_ARRAY:Array = [" Graveyard Fort"," Weepy Hollow"," Grimville"," Pumpkintown"];
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      private var m_featureName:String;
      
      private var m_bodyText:ZwTextField;
      
      private var m_tm:TabMenu;
      
      private var m_tasksFrame:HalloweenUSAInnovationTaskFrame;
      
      private var m_rewardsFrame:HalloweenUSAInnovationRewardsFrame;
      
      private var m_rewardsListFrame:HalloweenUSAInnovationRewardsListFrame;
      
      private var m_collectConsumable:FarmAnimatedTextButton;
      
      private var m_buyConsumable:FarmAnimatedTextButton;
      
      private var m_askConsumable:FarmAnimatedTextButton;
      
      private var m_bonusRewardIcon:FarmIcon;
      
      private var m_rewardsFrameMc:MovieClip;
      
      private var m_rewardsListFrameMc:MovieClip;
      
      private var m_taskFrameMc:MovieClip;
      
      private var m_consumableMc:MovieClip;
      
      private var travelMc:MovieClip;
      
      private var consumable_mc:MovieClip;
      
      private var m_tutorial_bt:FarmAnimatedTextButton;
      
      private var m_taskTf:ZwTextField;
      
      private var m_consumableCount:ZwTextField;
      
      private var m_remainingTimeTf:ZwTextField;
      
      private const TUTORIAL_BT:String = "tutorial_bt";
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_currentTaskTierIndex:int;
      
      private var m_currentTab:int;
      
      private var m_rewardListBodyTf:ZwTextField;
      
      private var m_showTutorialWithEAPage:Boolean;
      
      private var m_isTutorialActive:Boolean = false;
      
      private var m_onlyEAPage:Boolean = false;
      
      private var m_collectMc:MovieClip;
      
      public function HalloweenUSAInnovationMainWindow(featureName:String, assetPath:String, showTutorialWithEAPage:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showTutorialWithEAPage;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(this.m_featureName,assetPath,numOfTutorialPages,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["whatisthis_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"whatisthis_mc"),this.onHowDoesThisWorkClick));
         }
         addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title")));
         addWidget(this.m_rewardListBodyTf = new ZwTextField(m_window["rewards_mc"]["body1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_rewardList_subtitle")),true);
         addWidget(this.m_remainingTimeTf = new ZwTextField(m_window["timer_tf"],HalloweenInnovationManager.getInstance().getFeatureEndDaysLeftText()));
         addWidget(this.m_bodyText = new ZwTextField(m_window["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_rewards_subtitle")));
         this.m_rewardsFrame = new HalloweenUSAInnovationRewardsFrame(m_window["slots_mc"],this.m_featureName);
         this.m_rewardsFrame.visible = false;
         this.m_rewardsListFrame = new HalloweenUSAInnovationRewardsListFrame(m_window["rewards_mc"],this.m_featureName);
         this.m_rewardsListFrame.visible = false;
         this.m_tasksFrame = new HalloweenUSAInnovationTaskFrame(m_window["tasks_mc"],this.m_featureName);
         this.m_tasksFrame.visible = false;
         this.m_rewardListBodyTf.visible = true;
         addWidget(this.m_taskTf = new ZwTextField(m_window["locked_mc"]["tasks_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_locked_tier_message")),false);
         this.m_bonusRewardIcon = new FarmIcon(m_window["bonus_mc"]);
         this.m_bonusRewardIcon.visible = true;
         if(this.manager.isBonusClaimed() == true)
         {
            this.m_bonusRewardIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BonusToolTipText2")));
            (m_window["checkmark_mc"] as MovieClip).gotoAndStop(2);
         }
         else
         {
            (m_window["checkmark_mc"] as MovieClip).gotoAndStop(1);
            this.m_bonusRewardIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BonusToolTipText1")));
         }
         this.m_collectMc = m_window["collect_mc"] as MovieClip;
         this.m_collectMc.visible = false;
         this.populateConsumables();
         if(m_window.hasOwnProperty(this.TUTORIAL_BT))
         {
            addWidget(this.m_tutorial_bt = new FarmAnimatedTextButton(m_window[this.TUTORIAL_BT],"",this.openGameTutorial));
         }
         this.travelMc = m_window["travel_mc"] as MovieClip;
         this.travelMc.visible = false;
         addWidget(new ZwTextField(m_window["travel_mc"]["travel_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_travel_message")));
         addWidget(new FarmAnimatedTextButton(m_window["travel_mc"]["travel_bt"],"Travel",this.travelBtCallback));
         addWidget(new FarmAnimatedTextButton(m_window["harvest_bt"],"Know More",this.onKnowMoreClicked));
         this.m_tm = new TabMenu(m_window["tabs_mc"],4,0,this.processTravelMc,"tab_","_mc");
         this.m_currentTab = 0;
         this.refreshAskButton();
         this.refreshCollectButton();
         if(this.m_showTutorialWithEAPage)
         {
            this.showTutorialWithEAPage();
         }
      }
      
      public function processTravelMc(tabNumber:int) : void
      {
         this.m_currentTab = tabNumber;
         this.updateSlots();
      }
      
      public function updateSlots() : void
      {
         var prevTab:String = null;
         this.m_currentTaskTierIndex = HalloweenInnovationManager.getInstance().getCurrentTier();
         var worldUnlockFlag:Boolean = Global.worldManager.hasUnlockedWorld(WorldsConstants.WORLD_ID_HALLOWEENUSA);
         this.m_rewardListBodyTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_rewardList_subtitle") + TAB_NAMES_ARRAY[this.m_currentTab];
         this.m_rewardListBodyTf.visible = false;
         if(this.m_currentTab < this.m_currentTaskTierIndex)
         {
            this.m_bodyText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_rewards_subtitle");
            this.m_rewardsFrame.visible = true;
            this.m_rewardsListFrame.visible = false;
            this.m_tasksFrame.visible = false;
            this.m_tutorial_bt.visible = true;
            this.travelMc.visible = false;
            this.m_consumableMc.visible = true;
            this.m_rewardsFrame.setupSlotData(HalloweenInnovationManager.getInstance().getRewardsOfTier(this.m_currentTab));
            this.m_rewardsFrame.refresh();
            this.m_taskTf.visible = false;
            (m_window["locked_mc"] as MovieClip).visible = false;
         }
         else if(this.m_currentTab > this.m_currentTaskTierIndex)
         {
            prevTab = this.m_currentTab > 0 ? TAB_NAMES_ARRAY[this.m_currentTab - 1] : "";
            this.m_bodyText.text = "";
            this.m_rewardsFrame.visible = false;
            this.m_rewardsListFrame.visible = true;
            this.m_tasksFrame.visible = false;
            this.m_tutorial_bt.visible = false;
            this.travelMc.visible = false;
            this.m_consumableMc.visible = false;
            this.m_taskTf.visible = true;
            (m_window["locked_mc"] as MovieClip).visible = true;
            this.m_rewardsListFrame.setupSlotData(HalloweenInnovationManager.getInstance().getRewardsOfTier(this.m_currentTab));
            this.m_rewardsListFrame.refresh();
         }
         else if(worldUnlockFlag == true)
         {
            this.m_bodyText.text = "Complete all the tasks to play for the amazing rewards below!";
            this.m_rewardsFrame.visible = false;
            this.m_rewardsListFrame.visible = true;
            this.m_tasksFrame.visible = true;
            this.m_tasksFrame.pageNumber = 0;
            this.m_tutorial_bt.visible = false;
            this.travelMc.visible = false;
            this.m_consumableMc.visible = false;
            this.m_taskTf.visible = false;
            (m_window["locked_mc"] as MovieClip).visible = false;
            this.m_rewardsListFrame.setupSlotData(HalloweenInnovationManager.getInstance().getRewardsOfTier(this.m_currentTab));
            this.m_rewardsListFrame.refresh();
            this.m_tasksFrame.setupSlotData(HalloweenInnovationManager.getInstance().getTasksofTier(this.m_currentTab));
            this.m_tasksFrame.refresh();
         }
         else
         {
            this.m_bodyText.text = "";
            this.travelMc.visible = true;
            this.m_rewardsFrame.visible = false;
            this.m_rewardsListFrame.visible = true;
            this.m_tasksFrame.visible = false;
            this.m_tutorial_bt.visible = false;
            this.m_rewardsListFrame.setupSlotData(HalloweenInnovationManager.getInstance().getRewardsOfTier(this.m_currentTab));
            this.m_rewardsListFrame.refresh();
            this.m_consumableMc.visible = false;
            this.m_taskTf.visible = false;
            (m_window["locked_mc"] as MovieClip).visible = false;
         }
      }
      
      private function travelBtCallback(event:MouseEvent) : void
      {
         this.close();
         Global.hud.travelNameDisplay.showNewTravelWindow();
      }
      
      private function onKnowMoreClicked(event:MouseEvent) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","view_bonus");
         this.tintWindow();
         this.enableInput = false;
         this.manager.openKnowMoreBonusWindow();
      }
      
      private function populateConsumables() : void
      {
         var consumableCount:int = this.manager.consumableCount;
         var ConsumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.ConsumableCode);
         this.m_consumableMc = m_window["consumable_mc"] as MovieClip;
         (m_window["consumable_mc"] as MovieClip).visible = true;
         addWidget(new ZwTextField(m_window["consumable_mc"]["name_tf"],ConsumableItem.friendlyTitle));
         addWidget(new ZwTextField(m_window["consumable_mc"]["subtext_tf"],"Spend 4 Tricky Treats to play a game"));
         addWidget(this.m_collectConsumable = new FarmAnimatedTextButton(m_window["consumable_mc"]["collect_bt"],"Collect",this.collectConsumableCallback));
         addWidget(this.m_consumableCount = new ZwTextField(m_window["consumable_mc"]["count_tf"],"x" + consumableCount.toString()));
         addWidget(this.m_buyConsumable = new FarmAnimatedTextButton(m_window["consumable_mc"]["buy_bt"],"Buy",this.buyCallback));
         addWidget(this.m_askConsumable = new FarmAnimatedTextButton(m_window["consumable_mc"]["ask_bt"],"Ask",this.askCallback));
         addWidget(this.m_tileUnlock_bt = new FarmAnimatedTextButton(m_window["consumable_mc"]["unlock_bt"],"View Tile",this.openTileDialog));
         if(this.manager.lockedTilesArray.length <= 0)
         {
            this.m_tileUnlock_bt.enabled = false;
            this.m_tileUnlock_bt.callback = null;
            this.m_tileUnlock_bt.applyGrayOut = true;
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HALLOWEENUSA)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText2"));
            }
            else
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText3"));
            }
         }
      }
      
      public function showTutorialWithEAPage() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         tutorialSceneNumber = 6;
         this.m_onlyEAPage = true;
         if(m_tutorial != null)
         {
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(6);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.tutorial_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            m_tutorial.visible = true;
         }
      }
      
      private function openTileDialog(e:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","unlock_tiles");
         this.close();
         UI.displayPopup(new HalloweenUSATileWindow(this.m_featureName));
      }
      
      public function collectConsumableCallback(e:MouseEvent) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","collect_treats");
         if(this.m_isTutorialActive)
         {
            this.m_isTutorialActive = false;
            this.m_collectMc.visible = false;
         }
         this.manager.collectConsumables();
         this.refreshWindow();
      }
      
      private function buyCallback(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","buy_treats");
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      private function askCallback(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","ask_treats");
         if(this.m_askConsumable.enabled)
         {
            this.m_askConsumable.enabled = false;
            this.manager.askForConsumable();
            this.refreshAskButton();
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function tabClickCallback(tabNumber:int) : void
      {
         UI.displayMessage("tab number is " + tabNumber);
      }
      
      override public function refreshWindow() : void
      {
         this.refreshAskButton();
         this.refreshCollectButton();
         this.m_rewardsFrame.refresh();
      }
      
      public function openGameTutorial(event:MouseEvent) : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","how_to_play");
         tintWindow();
         enableInput = false;
         this.manager.openGameTutorial();
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_askConsumable)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(HalloweenInnovationManager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askConsumable,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askConsumable,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_askConsumable.enabled = true;
               this.m_askConsumable.detachTooltip();
            }
         }
      }
      
      public function refreshCollectButton() : void
      {
         var key:String = null;
         if(this.manager.canCollectConsumables() == false)
         {
            this.m_collectConsumable.enabled = false;
            this.m_collectConsumable.callback = null;
            key = HalloweenInnovationManager.HALLOWEEN_COLLECT_CONSUMABLE_KEY;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_collectConsumable,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CollectHoverText",{"time":HUD.getformattedTimeLeft(this.manager.getTimeLeft(key,HalloweenInnovationManager.DEFAULT_COLLECT_THROTTLE_TIME))}));
         }
         else
         {
            this.m_collectConsumable.enabled = true;
            this.m_collectConsumable.callback = this.collectConsumableCallback;
            this.m_collectConsumable.detachTooltip();
         }
         this.m_consumableCount.text = "x" + this.manager.getConsumableItemCount(this.manager.ConsumableCode).toString();
      }
      
      private function get manager() : HalloweenInnovationManager
      {
         return HalloweenInnovationManager.getInstance();
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
      }
      
      protected function postSwitchChanges(sceneNumber:int) : void
      {
         if(!WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HALLOWEENUSA))
         {
            if(sceneNumber == 5)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes && this.m_onlyEAPage == false)
         {
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
            this.postSwitchChanges(tutorialSceneNumber);
         }
         else
         {
            this.m_onlyEAPage = false;
            if(hasSeenTutorial)
            {
               FarmStatsManager.count(m_tutorialFeatureName,"FTUE","completed","click");
            }
            else
            {
               FarmStatsManager.count(m_tutorialFeatureName,"FTUE","completed","autopop");
            }
            hideTutorial();
            if(!Global.player.getSeenFlag(this.manager.COLLECT_TUTORIAL_FLAG))
            {
               Global.player.setSeenFlag(this.manager.COLLECT_TUTORIAL_FLAG);
               this.m_isTutorialActive = true;
               this.m_collectMc.visible = true;
            }
            Global.world.dispatchEvent(new DynamicObjectEvent(m_tutorialFeatureName));
         }
      }
      
      public function currentTabName() : String
      {
         var tabName:String = "";
         if(Boolean(this.m_currentTab) && Boolean(this.m_currentTab < 4) && this.m_currentTab >= 0)
         {
            tabName = TAB_NAMES_ARRAY[this.m_currentTab];
         }
         return tabName;
      }
      
      override public function close() : void
      {
         FarmStatsManager.count("RockPaperShivers","Main_UI","close_window");
         this.manager.mainWindow = null;
         super.close();
      }
   }
}

