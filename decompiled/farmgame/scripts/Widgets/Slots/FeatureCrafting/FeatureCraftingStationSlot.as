package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.FeatureCrafting.FeatureCraftingStationUpgrade;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.TemplateUIUtility;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingRecipesWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FeatureCraftingStationSlot extends ZwSlotFrame
   {
      
      private static const UNLOCKED_ALPHA:Number = 1;
      
      private static const LOCKED_ALPHA:Number = 0.6;
      
      private static const ICON_SIZE:int = 40;
      
      protected var m_data:FeatureCraftingStation;
      
      private var m_previewFrame:ResourcePreviewFrame;
      
      private var m_activeRecipeIcon:FarmIcon;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_lockWidget:ZwWidget;
      
      private var m_readyWidget:ZwWidget;
      
      private var m_emptyWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_timeTextField:ZwTextField;
      
      private var m_progressFrame:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_upgradeButton:FarmAnimatedTextButton;
      
      private var m_harvestTimer:Timer;
      
      private var m_actionTooltip:WidgetTooltip;
      
      private var m_screenWidget:ZwWidget;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","wait for region to unlock");
      
      private var m_location:String = "";
      
      public function FeatureCraftingStationSlot(element:DisplayObject, location:String = "")
      {
         super(element);
         this.m_location = location;
         this.m_previewFrame = addWidget(new ResourcePreviewFrame(m_element.icon_mc)) as ResourcePreviewFrame;
         this.m_activeRecipeIcon = addWidget(new FarmIcon(m_element.craftingIcon_mc)) as FarmIcon;
         this.m_activeRecipeIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_activeRecipeIcon.setSmoothing(true);
         this.m_lockWidget = addWidget(new ZwWidget(m_element.lock_mc),false) as ZwWidget;
         this.m_readyWidget = addWidget(new ZwWidget(m_element.ready_mc),false) as ZwWidget;
         this.m_emptyWidget = addWidget(new ZwWidget(m_element.empty_mc),false) as ZwWidget;
         if(m_element.screen_mc)
         {
            this.m_screenWidget = addWidget(new ZwWidget(m_element.screen_mc),false) as ZwWidget;
         }
         if(m_element.hit_bt)
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (this.m_hitWidget.element as SimpleButton).addEventListener(MouseEvent.CLICK,this.onClick);
            (this.m_hitWidget.element as SimpleButton).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hitWidget.element as SimpleButton).useHandCursor = true;
         }
         var tooltipFrame:ZwFrame = new ZwFrame(m_element.tooltip_mc) as ZwFrame;
         this.m_nameTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.header_tf," ")) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.tooltip_mc.header_tf);
         }
         this.m_timeTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.subheader_tf," ")) as ZwTextField;
         this.m_progressFrame = addWidget(new ZwFrame(m_element.progressBar_mc)) as ZwFrame;
         this.m_progressBar = this.m_progressFrame.addWidget(new ZwWidget(m_element.progressBar_mc.bar_mc)) as ZwWidget;
         this.m_buyButton = tooltipFrame.addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.buyAll_bt,"","",this.onBuyButtonClick)) as FarmAnimatedCashButton;
         if(m_element.tooltip_mc.upgrade_bt)
         {
            this.m_upgradeButton = tooltipFrame.addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.upgrade_bt,"",this.onUpgradeButtonClick)) as FarmAnimatedTextButton;
         }
         this.m_actionTooltip = new WidgetTooltip(tooltipFrame);
         this.m_actionTooltip.fixed = true;
         this.m_actionTooltip.interactive = true;
         attachTooltip(this.m_actionTooltip);
      }
      
      override public function release() : void
      {
         if(this.m_hitWidget)
         {
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.CLICK,this.onClick);
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         this.m_hitWidget = null;
         this.m_previewFrame = null;
         this.m_activeRecipeIcon = null;
         this.m_lockWidget = null;
         this.m_readyWidget = null;
         this.m_emptyWidget = null;
         this.m_nameTextField = null;
         this.m_timeTextField = null;
         this.m_progressBar = null;
         this.m_progressFrame = null;
         this.m_buyButton = null;
         this.m_upgradeButton = null;
         this.m_actionTooltip = null;
         if(this.m_harvestTimer)
         {
            this.m_harvestTimer.removeEventListener(TimerEvent.TIMER,this.onHarvestTimer);
            this.m_harvestTimer.stop();
            this.m_harvestTimer = null;
         }
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingStation;
         this.refresh(true);
      }
      
      public function refresh(reloadIcon:Boolean = false) : void
      {
         var WorldType:String = null;
         var seasons:int = 0;
         var playerNextSeason:int = 0;
         var currentSeason:int = 0;
         var accessType:String = null;
         var unlockDate:Object = null;
         if(this.m_data)
         {
            if(reloadIcon)
            {
               this.m_previewFrame.scale = this.m_data.assetScale;
               this.m_previewFrame.x = this.m_data.assetX;
               this.m_previewFrame.y = this.m_data.assetY;
               this.m_previewFrame.load(this.m_data.assetUrl,this.m_data.getFullExportName(FeatureCraftingStation.ASSET_STATE_IDLE));
            }
            this.m_previewFrame.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            this.m_hitWidget.visible = true;
            this.m_lockWidget.visible = true;
            this.refreshHarvestState();
            if(this.m_screenWidget)
            {
               WorldType = WorldsConstants.WORLD_ID_JAPAN;
               if(WorldType != "" && this.m_data.prereqName != "" && !PrerequisiteUtility.checkPrereqByName(this.m_data.prereqName))
               {
                  this.m_screenWidget.visible = true;
                  m_element.screen_mc.unlockInfo_tf.visible = true;
                  seasons = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(WorldType);
                  playerNextSeason = WorldSeasonsManager.getInstance().getNextPlayerSeason(WorldType);
                  currentSeason = WorldSeasonsManager.getInstance().getCurrentSeason(WorldType);
                  accessType = WorldSeasonsManager.getInstance().getAccessType(WorldType);
                  unlockDate = WorldSeasonsManager.getInstance().getSeasonUnlockETA(WorldType,playerNextSeason,accessType);
                  if(unlockDate.days > 0)
                  {
                     m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.days + " days";
                  }
                  else if(unlockDate.hours > 0)
                  {
                     m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.hours + " hours";
                  }
                  else if(unlockDate.minutes > 0)
                  {
                     m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.minutes + " minutes";
                  }
                  else if(unlockDate.seconds > 0)
                  {
                     m_element.screen_mc.unlockInfo_tf.text = "Unlocks in " + unlockDate.seconds + " seconds";
                  }
                  else
                  {
                     m_element.screen_mc.unlockInfo_tf.text = "Reload the game!";
                  }
                  if(m_element.hit_bt)
                  {
                     (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.CLICK,this.onClick);
                     (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
                     (this.m_hitWidget.element as SimpleButton).useHandCursor = false;
                     this.m_actionTooltip.detach();
                  }
               }
            }
         }
      }
      
      public function refreshHarvestState() : void
      {
         var recipe:FeatureCraftingRecipe = null;
         var timeLeft:int = 0;
         var timeLeftText:String = null;
         var progressPercentage:Number = NaN;
         var nextUpgrade:FeatureCraftingStationUpgrade = null;
         var upgradeButtonTooltipText:String = null;
         if(Boolean(m_element) && Boolean(this.m_data))
         {
            if(this.m_data.unlocked)
            {
               this.m_lockWidget.visible = false;
               this.m_emptyWidget.visible = false;
               if(this.m_data.active)
               {
                  recipe = this.m_data.system.getRecipe(this.m_data.currentRecipeName());
                  if(this.m_data.isReady())
                  {
                     this.m_previewFrame.alpha = UNLOCKED_ALPHA;
                     this.m_previewFrame.exportName = this.m_data.getFullExportName(FeatureCraftingStation.ASSET_STATE_READY);
                     (this.m_previewFrame.element as MovieClip).buttonMode = true;
                     this.m_activeRecipeIcon.loadIcon(Global.getAssetURL(recipe.iconUrl));
                     this.m_activeRecipeIcon.visible = true;
                     this.m_readyWidget.visible = true;
                     this.m_timeTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_Ready");
                     this.m_timeTextField.visible = true;
                     (this.m_progressBar.element as MovieClip).scaleX = 1;
                     this.m_progressFrame.visible = true;
                     this.m_buyButton.enabled = this.m_buyButton.visible = false;
                     if(this.m_harvestTimer)
                     {
                        this.m_harvestTimer.stop();
                        this.m_harvestTimer.removeEventListener(TimerEvent.TIMER,this.onHarvestTimer);
                        this.m_harvestTimer = null;
                     }
                  }
                  else
                  {
                     this.m_previewFrame.alpha = UNLOCKED_ALPHA;
                     this.m_previewFrame.exportName = this.m_data.getFullExportName(FeatureCraftingStation.ASSET_STATE_ACTIVE);
                     (this.m_previewFrame.element as MovieClip).buttonMode = false;
                     this.m_buyButton.visible = true;
                     this.m_buyButton.enabled = true;
                     this.m_buyButton.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_FinishButton");
                     this.m_buyButton.setAmountText(this.m_data.getCompleteNowCost().toString());
                     this.m_readyWidget.visible = false;
                     this.m_activeRecipeIcon.loadIcon(Global.getAssetURL(recipe.iconUrl));
                     this.m_activeRecipeIcon.visible = true;
                     timeLeft = this.m_data.getEndTime() - GlobalEngine.serverTime / 1000;
                     timeLeftText = FarmGameUtil.toFriendlyTime(timeLeft);
                     this.m_timeTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_TimeRemaining",{"time":timeLeftText});
                     this.m_timeTextField.visible = true;
                     progressPercentage = 1 - timeLeft / recipe.finishTime;
                     (this.m_progressBar.element as MovieClip).scaleX = Math.max(Math.min(progressPercentage,1),0);
                     this.m_progressFrame.visible = true;
                     if(!this.m_harvestTimer)
                     {
                        this.m_harvestTimer = new Timer(1000);
                        this.m_harvestTimer.addEventListener(TimerEvent.TIMER,this.onHarvestTimer);
                        this.m_harvestTimer.start();
                     }
                  }
               }
               else
               {
                  this.m_previewFrame.alpha = UNLOCKED_ALPHA;
                  this.m_previewFrame.exportName = this.m_data.getFullExportName(FeatureCraftingStation.ASSET_STATE_IDLE);
                  (this.m_previewFrame.element as MovieClip).buttonMode = true;
                  this.m_activeRecipeIcon.visible = false;
                  this.m_readyWidget.visible = false;
                  this.m_timeTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_Start");
                  this.m_timeTextField.visible = true;
                  this.m_buyButton.visible = false;
                  this.m_buyButton.enabled = false;
                  this.m_progressFrame.visible = false;
               }
               if(this.m_upgradeButton)
               {
                  nextUpgrade = this.m_data.getNextUpgrade();
                  if(nextUpgrade)
                  {
                     this.m_upgradeButton.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_UpgradeButton");
                     this.m_upgradeButton.enabled = this.m_upgradeButton.visible = true;
                     upgradeButtonTooltipText = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_UpgradeButton_Confirmation",{
                        "cost":nextUpgrade.unlockCost,
                        "output":nextUpgrade.outputCount,
                        "stationName":this.m_data.friendlyTitle
                     });
                     if(this.m_upgradeButton.tooltip)
                     {
                        (this.m_upgradeButton.tooltip as FarmTextTooltip).setText(upgradeButtonTooltipText);
                     }
                     else
                     {
                        this.m_upgradeButton.attachTooltip(new FarmTextTooltip(upgradeButtonTooltipText));
                     }
                  }
                  else
                  {
                     this.m_upgradeButton.enabled = this.m_upgradeButton.visible = false;
                  }
               }
            }
            else
            {
               if(this.m_data.isNextStationToUnlock)
               {
                  this.m_lockWidget.visible = true;
                  this.m_previewFrame.alpha = LOCKED_ALPHA;
                  this.m_previewFrame.exportName = this.m_data.getFullExportName(FeatureCraftingStation.ASSET_STATE_IDLE);
                  (this.m_previewFrame.element as MovieClip).buttonMode = false;
                  this.m_previewFrame.visible = true;
                  this.m_emptyWidget.visible = false;
                  this.m_buyButton.visible = this.m_data.canUnlock();
                  this.m_buyButton.enabled = true;
                  this.m_buyButton.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_UnlockButton");
                  this.m_buyButton.setAmountText(String(this.m_data.unlockNowCost));
               }
               else
               {
                  this.m_emptyWidget.visible = false;
                  this.m_lockWidget.visible = false;
                  this.m_previewFrame.visible = false;
                  this.m_buyButton.visible = false;
               }
               this.m_timeTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_Unlock",{"level":this.m_data.unlockLevel});
               this.m_timeTextField.visible = true;
               this.m_activeRecipeIcon.visible = false;
               this.m_readyWidget.visible = false;
               if(this.m_upgradeButton)
               {
                  this.m_upgradeButton.enabled = this.m_upgradeButton.visible = false;
               }
            }
         }
      }
      
      private function onHarvestTimer(event:TimerEvent) : void
      {
         this.refreshHarvestState();
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_data.unlocked)
         {
            if(this.m_data.isReady())
            {
               if(this.m_data.harvest())
               {
                  this.refresh();
                  this.updateOpenWindows();
               }
            }
            else if(!this.m_data.autoStart)
            {
               FeatureCraftingRecipesWindow.display(this.m_data,this.recipeWindowCloseCallback);
            }
         }
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         if(m_element.parent)
         {
            m_element.parent.addChild(m_element);
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var message:String = null;
         if(this.m_buyButton.enabled)
         {
            if(this.m_data.unlocked)
            {
               this.m_data.completeNow();
            }
            else
            {
               message = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_UnlockButton_Confirmation",{
                  "cost":this.m_data.unlockNowCost,
                  "stationName":this.m_data.friendlyTitle
               });
               UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"FeatureCraftingUnlockStation",true);
            }
            this.updateOpenWindows();
         }
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.m_data.buyUnlock();
            this.updateOpenWindows();
         }
      }
      
      private function onUpgradeButtonClick(event:MouseEvent) : void
      {
         var nextUpgrade:FeatureCraftingStationUpgrade = null;
         var message:String = null;
         if(this.m_upgradeButton.enabled)
         {
            nextUpgrade = this.m_data.getNextUpgrade();
            if(nextUpgrade)
            {
               message = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationTooltip_UpgradeButton_Confirmation",{
                  "cost":nextUpgrade.unlockCost,
                  "output":nextUpgrade.outputCount,
                  "stationName":this.m_data.friendlyTitle
               });
               UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUpgradeMessageClose,"FeatureCraftingUpgradeStation",true);
            }
         }
      }
      
      private function onUpgradeMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            if(this.m_data.buyUpgrade())
            {
               this.refresh(true);
               this.updateOpenWindows();
            }
         }
      }
      
      private function recipeWindowCloseCallback(forceRefresh:Boolean = false) : void
      {
         if(forceRefresh)
         {
            this.refresh();
         }
      }
      
      public function toggleTooltip(toggle:Boolean) : void
      {
         if(this.m_actionTooltip)
         {
            this.m_actionTooltip.onToggleVisible(toggle);
         }
      }
      
      public function get data() : FeatureCraftingStation
      {
         var result:FeatureCraftingStation = null;
         if(this.m_data)
         {
            result = this.m_data as FeatureCraftingStation;
         }
         return result;
      }
      
      private function updateOpenWindows() : void
      {
         if(this.m_data.system.currentNPCWindow)
         {
            if(this.m_data.system.currentNPCWindow.isSingleRecipeWindowOpen)
            {
               this.m_data.system.currentNPCWindow.singleRecipeWindow.refresh();
            }
            this.m_data.system.currentNPCWindow.refresh();
         }
      }
   }
}

