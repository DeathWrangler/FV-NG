package Widgets.Windows.LootTicketBooth
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.LootTicketBoothFeatureConfig;
   import Classes.FeatureDataObjects.LootTicketBoothStageConfig;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.LootTicketBoothManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.LootTicketBooth.LootTicketBoothInfoFrame;
   import Widgets.Frames.LootTicketBooth.LootTicketBoothPartFrame;
   import Widgets.Frames.LootTicketBooth.LootTicketBoothSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LootTicketBoothWindow extends FarmWindow
   {
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_tutorial:MovieClip;
      
      private var m_showTutorialPartTwo:Boolean;
      
      private var m_tutorialAcceptButton:FarmAnimatedButton;
      
      private var m_building:FeatureBuilding;
      
      private var m_stages:Array;
      
      private var m_gameSettings:Object;
      
      private var m_isActionEnabled:Boolean;
      
      private var m_currentStageIndex:int;
      
      private var m_currentStageName:String;
      
      private var m_currentStageConfig:LootTicketBoothStageConfig;
      
      private var m_howDoesThisWorkButton:FarmAnimatedTextButton;
      
      private var m_stageBackground:FarmIcon;
      
      private var m_stageTitleTextField:FarmTextField;
      
      private var m_stageTabButtons:Array;
      
      private var m_stageItemSlots:LootTicketBoothSlotContainerFrame;
      
      private var m_hudFrame:ZwFrame;
      
      private var m_ticketInfoFrame:LootTicketBoothInfoFrame;
      
      private var m_actionButton:FarmAnimatedTextButton;
      
      private var m_actionAnimation:ZwWidget;
      
      private var m_partFrame:LootTicketBoothPartFrame;
      
      private var m_homeButton:FarmAnimatedTextButton;
      
      public function LootTicketBoothWindow(building:FeatureBuilding, currentStageName:String = "")
      {
         var dialogAssetUrl:String = null;
         LootTicketBoothManager.currentContentsWindow = this;
         this.m_building = building;
         this.m_currentStageName = currentStageName;
         var dialogConfig:Object = this.m_building.getItem().getDialogConfig("storage");
         if(Boolean(dialogConfig) && Boolean(dialogConfig["path"]))
         {
            dialogAssetUrl = dialogConfig["path"];
         }
         if(dialogAssetUrl)
         {
            super(dialogAssetUrl);
         }
         else
         {
            GlobalEngine.assert(false,"Building item xml is missing dialog config information.");
         }
      }
      
      public static function display(building:FeatureBuilding) : LootTicketBoothWindow
      {
         var window:LootTicketBoothWindow = null;
         if(building)
         {
            window = new LootTicketBoothWindow(building);
            UI.displayPopup(window,true,"LootTicketBoothWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         var stage:LootTicketBoothStageConfig = null;
         var tabElementName:String = null;
         this.m_loadingWidget = addWidget(new ZwWidget(m_window.loading_mc),false) as ZwWidget;
         this.m_actionAnimation = addWidget(new ZwWidget(m_window.actionAnimation_mc),false) as ZwWidget;
         this.m_howDoesThisWorkButton = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onHowDoesThisWorkClick)) as FarmAnimatedTextButton;
         addWidget(new FarmTextField(m_window.title_mc,this.m_building.getItem().friendlyTitle));
         if(m_window.bg_mc)
         {
            this.m_stageBackground = addWidget(new FarmIcon(m_window.bg_mc)) as FarmIcon;
            this.m_stageBackground.setIconSize(m_window.bg_mc.width,m_window.bg_mc.height);
         }
         this.m_stageTitleTextField = addWidget(new FarmTextField(m_window.stageTitle_tf,"")) as FarmTextField;
         this.m_stageItemSlots = addWidget(new LootTicketBoothSlotContainerFrame(m_window.lootItems_mc)) as LootTicketBoothSlotContainerFrame;
         var hudElement:MovieClip = m_window.defaultHUD_mc as MovieClip;
         this.m_hudFrame = addWidget(new ZwFrame(hudElement)) as ZwFrame;
         this.m_ticketInfoFrame = this.m_hudFrame.addWidget(new LootTicketBoothInfoFrame(hudElement.ticketInfo_mc)) as LootTicketBoothInfoFrame;
         this.m_actionButton = this.m_hudFrame.addWidget(new FarmAnimatedTextButton(hudElement.action_bt,"",this.onActionButtonClick)) as FarmAnimatedTextButton;
         this.m_partFrame = this.m_hudFrame.addWidget(new LootTicketBoothPartFrame(hudElement.partModule_mc)) as LootTicketBoothPartFrame;
         this.m_homeButton = addWidget(new FarmAnimatedTextButton(m_window.home_bt,"",this.onHomeButtonClick),false) as FarmAnimatedTextButton;
         var actionButtonKey:String = this.featureName + "_ActionButton";
         var actionButtonText:String = ZLocUtils.hasString("Dialogs",actionButtonKey) ? ZLocUtils.t("Dialogs",actionButtonKey) : ZLocUtils.t("Dialogs","LootTicketBooth_ActionButton");
         this.m_actionButton.text = actionButtonText;
         var homeButtonKey:String = this.featureName + "_HomeButton";
         var homeButtonText:String = ZLocUtils.hasString("Dialogs",homeButtonKey) ? ZLocUtils.t("Dialogs",homeButtonKey) : ZLocUtils.t("Dialogs","LootTicketBooth_HomeButton");
         this.m_homeButton.text = homeButtonText;
         this.m_stages = LootTicketBoothManager.getStages(this.featureName);
         if(!this.m_stages || this.m_stages.length == 0)
         {
            GlobalEngine.assert(false,"No stages configured for " + this.featureName);
         }
         this.m_stageTabButtons = new Array();
         var stageIndex:int = 0;
         for each(stage in this.m_stages)
         {
            tabElementName = "tab_" + stageIndex + "_mc";
            if(m_window.hasOwnProperty(tabElementName))
            {
               this.m_stageTabButtons.push(addWidget(new FarmTabButton(m_window[tabElementName] as MovieClip,LootTicketBoothManager.getStageTitle(this.featureName,stage.name),this.onStageTabButtonClick)));
            }
            stageIndex++;
         }
         this.m_gameSettings = LootTicketBoothManager.getGameSettings(this.featureName);
         if(this.m_gameSettings)
         {
            this.refresh();
            this.refreshStageTabs();
         }
         else
         {
            this.showLoadingWidget();
         }
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_gameSettings = null;
         this.m_homeButton = null;
         this.m_actionButton = null;
         this.m_hudFrame = null;
         this.m_ticketInfoFrame = null;
         this.m_partFrame = null;
         this.m_stageBackground = null;
         this.m_stageItemSlots = null;
         this.m_stages = null;
         this.m_stageTabButtons = null;
         this.m_stageTitleTextField = null;
         this.m_tutorial = null;
         this.m_tutorialAcceptButton = null;
         if(LootTicketBoothManager.currentContentsWindow == this)
         {
            LootTicketBoothManager.currentContentsWindow = null;
         }
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      public function get building() : FeatureBuilding
      {
         return this.m_building;
      }
      
      public function get currentStageName() : String
      {
         return this.m_currentStageName;
      }
      
      public function get featureName() : String
      {
         return this.m_building ? this.m_building.getItemName() : "";
      }
      
      public function set gameSettings(value:Object) : void
      {
         this.m_gameSettings = value;
         this.refresh();
         this.refreshStageTabs();
      }
      
      public function get gameSettings() : Object
      {
         return this.m_gameSettings;
      }
      
      public function refresh() : void
      {
         var tutorialSeenFlag:String = null;
         var stage:LootTicketBoothStageConfig = null;
         var isStageUnlocked:Boolean = false;
         var featureConfig:LootTicketBoothFeatureConfig = null;
         var ticketItemName:String = null;
         var ticketItemNeeded:int = 0;
         var ticketItem:FarmItem = null;
         var isPreviousStageUnlocked:Boolean = false;
         var previousStageIndex:int = 0;
         var partItemName:String = null;
         var partItemNeeded:int = 0;
         var previousStage:LootTicketBoothStageConfig = null;
         var partItem:FarmItem = null;
         var lootItems:Array = null;
         var nextStageIndex:int = 0;
         var nextStage:LootTicketBoothStageConfig = null;
         var lootItem:Object = null;
         var itemsVisible:Boolean = false;
         if(m_window)
         {
            this.hideLoadingWidget();
            tutorialSeenFlag = this.featureName + "_Tutorial";
            if(!Global.player.getSeenFlag(tutorialSeenFlag))
            {
               Global.player.setSeenFlag(tutorialSeenFlag);
               this.m_tutorial = m_window.tutorial_mc as MovieClip;
               this.m_tutorial.visible = true;
               this.m_tutorial.gotoAndPlay(2);
            }
            if(!this.m_currentStageName)
            {
               stage = LootTicketBoothManager.getLastStageUnlocked(this.featureName);
               this.m_currentStageName = stage.name;
            }
            this.m_currentStageIndex = 0;
            for each(stage in this.m_stages)
            {
               if(stage.name == this.m_currentStageName)
               {
                  this.m_currentStageConfig = stage;
                  break;
               }
               ++this.m_currentStageIndex;
            }
            if(this.m_currentStageConfig)
            {
               if(this.m_isActionEnabled)
               {
                  if(this.m_stageBackground)
                  {
                     if(this.m_currentStageConfig.dialogBackgroundUrl)
                     {
                        this.m_stageBackground.loadIcon(Global.getAssetURL(this.m_currentStageConfig.dialogBackgroundUrl));
                     }
                     else
                     {
                        GlobalEngine.assert(false,"Background is not defined for stage " + this.m_currentStageName);
                     }
                  }
                  this.m_stageTitleTextField.text = ZLocUtils.t("Dialogs",this.featureName + "_StageMessage",{"stage":LootTicketBoothManager.getStageTitle(this.featureName,this.m_currentStageName)});
                  this.m_stageTitleTextField.visible = true;
                  this.m_homeButton.visible = true;
                  if(m_closeButton)
                  {
                     m_closeButton.visible = false;
                  }
                  this.m_howDoesThisWorkButton.visible = false;
                  this.m_hudFrame.visible = false;
                  this.setStageTabsVisible(false);
               }
               else
               {
                  if(this.m_stageBackground)
                  {
                     featureConfig = LootTicketBoothManager.getFeatureConfig(this.featureName);
                     if(featureConfig.dialogBackgroundUrl)
                     {
                        this.m_stageBackground.loadIcon(Global.getAssetURL(featureConfig.dialogBackgroundUrl));
                     }
                     else
                     {
                        GlobalEngine.assert(false,"Default background is not defined " + this.featureName);
                     }
                  }
                  this.m_stageTitleTextField.text = ZLocUtils.t("Dialogs",this.featureName + "_HomeMessage",{"stage":LootTicketBoothManager.getStageTitle(this.featureName,this.m_currentStageName)});
                  this.m_stageTitleTextField.visible = true;
                  isStageUnlocked = LootTicketBoothManager.isStageUnlocked(this.featureName,this.m_currentStageName);
                  if(isStageUnlocked)
                  {
                     ticketItemName = this.m_currentStageConfig.ticketItemName;
                     ticketItemNeeded = this.m_currentStageConfig.ticketItemNeeded as int;
                     ticketItem = Global.farmGameSettingsManager.getFarmItemByName(ticketItemName);
                     if(ticketItem)
                     {
                        this.m_ticketInfoFrame.populate(ticketItem,ticketItemNeeded);
                     }
                     else
                     {
                        GlobalEngine.assert(false,"Loot ticket item is not defined " + ticketItemName);
                     }
                     this.refreshActionButton();
                     this.m_actionButton.visible = true;
                     this.m_ticketInfoFrame.visible = true;
                     this.m_partFrame.visible = false;
                  }
                  else
                  {
                     previousStageIndex = this.m_currentStageIndex - 1;
                     if(Boolean(this.m_stages) && previousStageIndex >= 0)
                     {
                        previousStage = this.m_stages[previousStageIndex];
                        isPreviousStageUnlocked = LootTicketBoothManager.isStageUnlocked(this.featureName,previousStage.name);
                     }
                     else
                     {
                        isPreviousStageUnlocked = true;
                     }
                     partItemName = this.m_currentStageConfig.partItemName;
                     partItemNeeded = this.m_currentStageConfig.partItemNeeded as int;
                     if(Boolean(partItemName) && partItemNeeded > 0)
                     {
                        partItem = Global.farmGameSettingsManager.getFarmItemByName(partItemName);
                        if(partItem)
                        {
                           this.m_partFrame.populate(partItem,partItemNeeded,isPreviousStageUnlocked);
                           this.m_partFrame.visible = true;
                        }
                        else
                        {
                           GlobalEngine.assert(false,"Part item is not defined " + partItemName);
                        }
                     }
                     else
                     {
                        this.m_partFrame.visible = false;
                     }
                     this.m_partFrame.visible = true;
                     this.m_actionButton.visible = false;
                     this.m_ticketInfoFrame.visible = false;
                  }
                  if(m_closeButton)
                  {
                     m_closeButton.visible = true;
                  }
                  this.m_howDoesThisWorkButton.visible = true;
                  this.m_hudFrame.visible = true;
                  this.setStageTabsVisible(true);
                  this.m_homeButton.visible = false;
               }
               if(Boolean(this.m_gameSettings[LootTicketBoothManager.KEY_LOOT_TABLES]) && Boolean(this.m_gameSettings[LootTicketBoothManager.KEY_LOOT_TABLES][this.m_currentStageConfig.lootTableName]))
               {
                  lootItems = this.m_gameSettings[LootTicketBoothManager.KEY_LOOT_TABLES][this.m_currentStageConfig.lootTableName] as Array;
                  if(this.m_currentStageConfig.lootPartReplacement)
                  {
                     nextStageIndex = this.m_currentStageIndex + 1;
                     if(Boolean(this.m_stages) && this.m_stages.length > nextStageIndex)
                     {
                        nextStage = this.m_stages[nextStageIndex];
                        if(LootTicketBoothManager.isStageUnlocked(this.featureName,nextStage.name))
                        {
                           for each(lootItem in lootItems)
                           {
                              if(lootItem["itemName"] == nextStage.partItemName)
                              {
                                 lootItem["itemName"] = this.m_currentStageConfig.lootPartReplacement;
                                 break;
                              }
                           }
                        }
                     }
                  }
                  if(this.m_isActionEnabled)
                  {
                     this.m_stageItemSlots.visible = false;
                  }
                  else
                  {
                     itemsVisible = isStageUnlocked || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_TIME_MACHINE_SHOW_PRIZES) >= 3;
                     this.m_stageItemSlots.setSlotState(itemsVisible,isStageUnlocked,false);
                     this.m_stageItemSlots.items = lootItems;
                     this.m_stageItemSlots.visible = true;
                  }
               }
               else
               {
                  GlobalEngine.assert(false,"Loot table is not defined for stage " + this.m_currentStageName);
               }
            }
            else
            {
               GlobalEngine.assert(false,"Stage definition missing for " + this.m_currentStageName);
            }
         }
      }
      
      public function refreshActionButton() : void
      {
         if(this.m_actionButton)
         {
            this.m_actionButton.enabled = this.m_ticketInfoFrame.hasEnoughTickets;
         }
      }
      
      public function refreshStageTabs() : void
      {
         var tabIndex:int = 0;
         var tabButton:FarmTabButton = null;
         var tabStage:LootTicketBoothStageConfig = null;
         if(this.m_stageTabButtons)
         {
            for(tabIndex = 0; tabIndex < this.m_stageTabButtons.length; tabIndex++)
            {
               tabButton = this.m_stageTabButtons[tabIndex] as FarmTabButton;
               if(tabIndex == this.m_currentStageIndex)
               {
                  tabButton.setToggleState(ZwToggleState.SELECTED);
               }
               else
               {
                  tabButton.setToggleState(ZwToggleState.DESELECTED);
               }
               tabStage = this.m_stages[tabIndex];
               ((tabButton.element as MovieClip)["lock_mc"] as MovieClip).visible = !LootTicketBoothManager.isStageUnlocked(this.featureName,tabStage.name);
            }
         }
      }
      
      private function setStageTabsVisible(visible:Boolean) : void
      {
         var tabButton:FarmTabButton = null;
         for(var tabIndex:int = 0; tabIndex < this.m_stageTabButtons.length; tabIndex++)
         {
            tabButton = this.m_stageTabButtons[tabIndex] as FarmTabButton;
            tabButton.visible = visible;
         }
      }
      
      private function showLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(!this.m_loadingWidget.visible)
         {
            this.m_loadingWidget.visible = true;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.gotoAndPlay(1);
               }
            }
         }
      }
      
      private function hideLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(this.m_loadingWidget.visible)
         {
            this.m_loadingWidget.visible = false;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.stop();
               }
            }
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"what_is_this");
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(this.m_building,prefixUrl,false,null);
      }
      
      private function onActionButtonClick(event:MouseEvent) : void
      {
         if(this.m_actionButton.enabled)
         {
            this.m_actionButton.enabled = false;
            enableInput = false;
            if(Boolean(this.m_tutorial) && this.m_tutorial.visible)
            {
               this.m_tutorial.visible = false;
               this.m_showTutorialPartTwo = true;
            }
            this.m_isActionEnabled = true;
            this.playActionAnimation();
            LootTicketBoothManager.redeemTickets(this.featureName,this.m_currentStageName);
         }
      }
      
      public function handleRedemptionResult(result:Object) : void
      {
         if(m_window)
         {
            this.refresh();
            this.stopActionAnimation();
         }
      }
      
      public function onRedeemTicketsResultWindowClose(checked:Boolean, extraData:Object) : void
      {
         if(m_window)
         {
            enableInput = true;
            this.refreshActionButton();
         }
      }
      
      private function playActionAnimation() : void
      {
         (this.m_actionAnimation.element as MovieClip).gotoAndPlay(1);
         this.m_actionAnimation.visible = true;
      }
      
      private function stopActionAnimation() : void
      {
         this.m_actionAnimation.visible = false;
         (this.m_actionAnimation.element as MovieClip).stop();
      }
      
      private function onHomeButtonClick(event:MouseEvent) : void
      {
         if(this.m_homeButton.enabled)
         {
            this.m_isActionEnabled = false;
            this.refresh();
            if(this.m_showTutorialPartTwo)
            {
               this.m_showTutorialPartTwo = false;
               this.m_tutorial = m_window.tutorial2_mc as MovieClip;
               this.m_tutorial.visible = true;
               this.m_tutorial.gotoAndPlay(2);
            }
         }
      }
      
      private function onStageTabButtonClick(event:MouseEvent) : void
      {
         var tabButton:FarmTabButton = null;
         var tabStage:LootTicketBoothStageConfig = null;
         for(var tabIndex:int = 0; tabIndex < this.m_stageTabButtons.length; tabIndex++)
         {
            tabButton = this.m_stageTabButtons[tabIndex] as FarmTabButton;
            if(tabButton.element == event.currentTarget)
            {
               if(this.m_currentStageIndex != tabIndex)
               {
                  tabStage = this.m_stages[tabIndex];
                  this.m_currentStageIndex = tabIndex;
                  this.m_currentStageName = tabStage.name;
                  this.refresh();
                  this.refreshStageTabs();
               }
            }
         }
      }
      
      private function showPreviousStage() : void
      {
         var previousStage:LootTicketBoothStageConfig = null;
         var previousStageIndex:int = this.m_currentStageIndex - 1;
         if(Boolean(this.m_stages) && previousStageIndex >= 0)
         {
            previousStage = this.m_stages[previousStageIndex];
            this.m_currentStageIndex = previousStageIndex;
            this.m_currentStageName = previousStage.name;
            this.refresh();
         }
      }
      
      private function showNextStage() : void
      {
         var nextStage:LootTicketBoothStageConfig = null;
         var nextStageIndex:int = this.m_currentStageIndex + 1;
         if(Boolean(this.m_stages) && this.m_stages.length > nextStageIndex)
         {
            nextStage = this.m_stages[nextStageIndex];
            this.m_currentStageIndex = nextStageIndex;
            this.m_currentStageName = nextStage.name;
            this.refresh();
         }
      }
   }
}

