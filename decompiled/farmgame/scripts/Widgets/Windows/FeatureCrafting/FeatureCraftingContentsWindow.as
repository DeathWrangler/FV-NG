package Widgets.Windows.FeatureCrafting
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingGood;
   import Classes.FeatureCrafting.FeatureCraftingInventory;
   import Classes.FeatureCrafting.FeatureCraftingOrderBoard;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ImageLoader;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingNPCSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingOrderRewardFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingOrderSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingStationSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingStorageButtonSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindowWithTutorial;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class FeatureCraftingContentsWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const NUM_TUTORIAL_SCENES_4:int = 4;
      
      private static const INVENTORY_BARN:String = "barn";
      
      private static const INVENTORY_SILO:String = "silo";
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_barnWidget:ZwWidget;
      
      private var m_barnCountTextField:ZwTextField;
      
      private var m_siloWidget:ZwWidget;
      
      private var m_siloCountTextField:ZwTextField;
      
      private var m_levelTextField:ZwTextField;
      
      private var m_levelProgressBar:ZwWidget;
      
      private var m_storageSlots:FeatureCraftingStorageButtonSlotContainerFrame;
      
      private var m_ingredientStationSlots:FeatureCraftingStationSlotContainerFrame;
      
      private var m_npcSlots:FeatureCraftingNPCSlotContainerFrame;
      
      private var m_recipeStationSlots:FeatureCraftingStationSlotContainerFrame;
      
      private const HOVER_MC:String = "hover_mc";
      
      private const SHOW_MC:String = "show_mc";
      
      private var m_ordersLoading:Boolean;
      
      private var m_orderLoadingWidget:ZwWidget;
      
      private var m_orderSlots:FeatureCraftingOrderSlotContainerFrame;
      
      private var m_orderRewardsFrame:FeatureCraftingOrderRewardFrame;
      
      private var m_tutorial1:ZwFrame = null;
      
      private var m_tutorialButton1:FarmAnimatedTextButton;
      
      private var m_closeAfterTut1:Boolean = false;
      
      private var m_location:String = "";
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_bonusAnimalName:String = "";
      
      private var m_hover_mc:ZwFrame;
      
      private var m_show_mc:MovieClip;
      
      private var m_whatisThisPrefix:String = "";
      
      public function FeatureCraftingContentsWindow(system:FeatureCraftingSystem)
      {
         system.currentContentsWindow = this;
         this.m_system = system;
         if(this.m_system.location != "")
         {
            this.m_location = this.m_system.location;
         }
         if(this.m_system.whatisThisPrefix != "")
         {
            this.m_whatisThisPrefix = this.m_system.whatisThisPrefix;
         }
         if(this.m_system.bonusAnimal != "")
         {
            this.m_bonusAnimalName = this.m_system.bonusAnimal;
         }
         var tutorialPageCount:int = NUM_TUTORIAL_SCENES;
         if(this.m_system.name == FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES || this.m_system.name == FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS)
         {
            tutorialPageCount = NUM_TUTORIAL_SCENES_4;
         }
         if(this.m_system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_BACKGROUND_FRAME))
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_BACKGROUND_FRAME)));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         super(this.m_system.name,this.m_system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_CONTENTS),tutorialPageCount);
      }
      
      public static function display(system:FeatureCraftingSystem) : FeatureCraftingContentsWindow
      {
         var window:FeatureCraftingContentsWindow = null;
         var stations:Array = null;
         var isReady:int = 0;
         if(system)
         {
            window = new FeatureCraftingContentsWindow(system);
            UI.displayPopup(window,true,"FeatureCraftingContentsWindow",true);
            stations = system.getStationsThatAreReady();
            isReady = Boolean(stations) && stations.length > 0 ? 1 : 0;
            StatsManager.count(system.name,"open_UI",String(system.getPointLevel()),String(isReady));
         }
         return window;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         if(m_window.innovation_mc)
         {
            m_window.innovation_mc.visible = false;
         }
         if(JMInnovationManager.getInstance().isActive())
         {
            if(m_window.innovation_mc)
            {
               m_window.innovation_mc.visible = true;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var station:FeatureCraftingStation = null;
         var tutorialSeenFlag:String = null;
         var levelFrame:ZwFrame = null;
         var progressBarFrame:ZwFrame = null;
         var bonusAnimalItem:FarmItem = null;
         var bonusTextField:ZwTextField = null;
         var bonusNameTextField:ZwTextField = null;
         var sizeScaleNumber:Number = NaN;
         var objectPreview:ObjectPreviewFrame = null;
         if(Boolean(m_tutorialFeatureName) && Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_DISABLE_AUTOPOP_FTUE) > 0)
         {
            tutorialSeenFlag = m_tutorialFeatureName + "_Tutorial";
            Global.player.setSeenFlag(tutorialSeenFlag);
         }
         super.postLoadComplete();
         this.conditionallyDisplayJungleInnovationCard();
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onHowDoesThisWorkClick)) as FarmAnimatedTextButton;
         addWidget(new ZwTextField(m_window.title_tf,this.m_system.friendlyTitle)) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
         if(m_window.subtitle_tf)
         {
            addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t("Dialogs",this.m_system.name + "_subTitle")));
            if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.subtitle_tf);
            }
         }
         if(m_window.stage_mc)
         {
            levelFrame = addWidget(new ZwFrame(m_window.stage_mc)) as ZwFrame;
            levelFrame.attachTooltip(new FarmTextTooltip("",this.getLevelTooltipText));
            this.m_levelTextField = levelFrame.addWidget(new ZwTextField(m_window.stage_mc.stage_mc,"")) as ZwTextField;
            progressBarFrame = levelFrame.addWidget(new ZwFrame(m_window.stage_mc.progressBar_mc)) as ZwFrame;
            this.m_levelProgressBar = progressBarFrame.addWidget(new ZwWidget(m_window.stage_mc.progressBar_mc.bar_mc)) as ZwWidget;
         }
         if(m_window.storages_mc)
         {
            this.m_storageSlots = addWidget(new FeatureCraftingStorageButtonSlotContainerFrame(m_window.storages_mc,this.m_location)) as FeatureCraftingStorageButtonSlotContainerFrame;
            this.m_storageSlots.currentContentWindow = this;
            this.m_storageSlots.items = this.m_system.getInventories();
         }
         else
         {
            this.m_barnWidget = addWidget(new ZwWidget(m_window.barn_mc)) as ZwWidget;
            (this.m_barnWidget.element as MovieClip).buttonMode = true;
            (this.m_barnWidget.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onBarnClick);
            this.m_barnCountTextField = addWidget(new ZwTextField(m_window.countBarn_tf,"")) as ZwTextField;
            this.m_siloWidget = addWidget(new ZwWidget(m_window.silo_mc)) as ZwWidget;
            (this.m_siloWidget.element as MovieClip).buttonMode = true;
            (this.m_siloWidget.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onSiloClick);
            this.m_siloCountTextField = addWidget(new ZwTextField(m_window.countSilo_tf,"")) as ZwTextField;
         }
         var ingredientStations:Array = [];
         var recipeStations:Array = [];
         var stations:Array = this.m_system.getStations();
         for each(station in stations)
         {
            if(station.autoStart)
            {
               ingredientStations.push(station);
            }
            else
            {
               recipeStations.push(station);
            }
         }
         this.m_ingredientStationSlots = addWidget(new FeatureCraftingStationSlotContainerFrame(m_window.inputs_mc,this.m_location)) as FeatureCraftingStationSlotContainerFrame;
         this.m_ingredientStationSlots.items = ingredientStations;
         this.m_recipeStationSlots = addWidget(new FeatureCraftingStationSlotContainerFrame(m_window.workstations_mc,this.m_location)) as FeatureCraftingStationSlotContainerFrame;
         this.m_recipeStationSlots.items = recipeStations;
         if(m_window.hasOwnProperty("mc_EliteHorsesFrame") && Boolean(this.m_bgIcon))
         {
            m_window.mc_EliteHorsesFrame.addChild(this.m_bgIcon);
            m_window.mc_EliteHorsesFrame.visible = true;
         }
         var npcs:Array = this.m_system.getNPCs();
         if(Boolean(npcs) && Boolean(m_window.npcs_mc))
         {
            this.m_npcSlots = addWidget(new FeatureCraftingNPCSlotContainerFrame(m_window.npcs_mc,this.m_location)) as FeatureCraftingNPCSlotContainerFrame;
            this.m_npcSlots.items = npcs;
         }
         if(m_window.orders_mc)
         {
            this.m_orderSlots = addWidget(new FeatureCraftingOrderSlotContainerFrame(m_window.orders_mc)) as FeatureCraftingOrderSlotContainerFrame;
            this.m_orderLoadingWidget = addWidget(new ZwWidget(m_window.loading_mc),false) as ZwWidget;
            this.m_orderRewardsFrame = addWidget(new FeatureCraftingOrderRewardFrame(m_window.board_mc)) as FeatureCraftingOrderRewardFrame;
         }
         if(m_window.hasOwnProperty(this.SHOW_MC) && m_window.hasOwnProperty(this.HOVER_MC) && Boolean(this.m_bonusAnimalName))
         {
            this.m_show_mc = m_window[this.SHOW_MC] as MovieClip;
            this.m_show_mc.visible = false;
            if(Boolean(m_window[this.SHOW_MC].hasOwnProperty("bonus_tf")) && Boolean(m_window[this.SHOW_MC].hasOwnProperty("bonusname_tf")) && Boolean(m_window[this.SHOW_MC].hasOwnProperty("mc_EliteHorsesBonus")))
            {
               bonusAnimalItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusAnimalName);
               if(bonusAnimalItem)
               {
                  bonusTextField = new FarmTextField(m_window[this.SHOW_MC]["bonus_tf"],"BONUS ANIMAL!");
                  addWidget(bonusTextField);
                  bonusNameTextField = new FarmTextField(m_window[this.SHOW_MC]["bonusname_tf"],bonusAnimalItem.friendlyTitle);
                  addWidget(bonusNameTextField);
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
                  {
                     TemplateUIUtility.applyExpansionTextColor(m_window[this.SHOW_MC]["bonus_tf"]);
                     TemplateUIUtility.applyExpansionBevelFilter(m_window[this.SHOW_MC]["bonus_tf"]);
                     TemplateUIUtility.applyExpansionDropShadowFilter(m_window[this.SHOW_MC]["bonus_tf"]);
                     TemplateUIUtility.applyExpansionSubTextColor(m_window[this.SHOW_MC]["bonusname_tf"]);
                  }
               }
               if(bonusAnimalItem.getImageByName("frt_idle") != null)
               {
                  sizeScaleNumber = Math.min(2,7 / (bonusAnimalItem.sizeX + bonusAnimalItem.sizeY) / bonusAnimalItem.imageScale);
                  objectPreview = new ObjectPreviewFrame(m_window[this.SHOW_MC].mc_EliteHorsesBonus,bonusAnimalItem,null,null,[200],Animal.STATE_FRONT_IDLE);
                  (objectPreview.element as MovieClip).filters = [];
                  addWidget(objectPreview,true);
               }
            }
         }
         if(m_window.hasOwnProperty(this.HOVER_MC))
         {
            addWidget(this.m_hover_mc = new ZwFrame(m_window[this.HOVER_MC]),true);
            this.m_hover_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.m_hover_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         }
         var prereqName:String = ZLocUtils.t("Dialogs",this.m_system.name + "prereqForNextRegion");
         var prereqObject:Object = Global.farmGameSettingsManager.getPrereqByName(prereqName);
         var tutorial1ToShow:String = this.m_system.name + "_Tutorial1_ToShow";
         var tutorial1Seen:String = this.m_system.name + "_Tutorial1Seen";
         if(prereqObject != null && !PrerequisiteUtility.checkPrereqByName(prereqName) && !Global.player.getSeenFlag(tutorial1ToShow))
         {
            Global.player.setSeenFlag(tutorial1ToShow,true);
         }
         if(m_window.tutorial1_mc)
         {
            this.m_tutorial1 = addWidget(new ZwFrame(m_window.tutorial1_mc),false) as ZwFrame;
            if(m_window.tutorial1_mc.okay_bt)
            {
               removeWidget(m_window.tutorial1_mc.okay_bt);
               this.m_tutorial1.addWidget(this.m_tutorialButton1 = new FarmAnimatedTextButton(m_window.tutorial1_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onTutorial1OkayButtonClick),false) as FarmAnimatedTextButton;
            }
         }
         if(prereqObject != null && PrerequisiteUtility.checkPrereqByName(prereqName) && Global.player.getSeenFlag(tutorial1ToShow) && !Global.player.getSeenFlag(tutorial1Seen))
         {
            if(m_window.tutorial1_mc)
            {
               this.m_tutorial1.visible = true;
               if(m_window.tutorial1_mc.okay_bt)
               {
                  this.m_tutorialButton1.visible = true;
                  Global.player.setSeenFlag(tutorial1Seen);
               }
            }
         }
         this.refresh();
      }
      
      private function onTutorial1OkayButtonClick(event:MouseEvent) : void
      {
         this.m_tutorial1.visible = false;
      }
      
      override protected function release() : void
      {
         this.m_levelTextField = null;
         this.m_levelProgressBar = null;
         if(this.m_barnWidget)
         {
            (this.m_barnWidget.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onBarnClick);
            this.m_barnWidget = null;
         }
         if(this.m_siloWidget)
         {
            (this.m_siloWidget.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onSiloClick);
            this.m_siloWidget = null;
         }
         this.m_barnCountTextField = null;
         this.m_siloCountTextField = null;
         this.m_storageSlots = null;
         this.m_ingredientStationSlots = null;
         this.m_recipeStationSlots = null;
         this.m_npcSlots = null;
         this.m_orderRewardsFrame = null;
         this.m_orderSlots = null;
         if(this.m_system.currentContentsWindow == this)
         {
            this.m_system.currentContentsWindow = null;
         }
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            this.closeCurrentNPCWindow();
            super.onClose(event);
         }
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function refresh() : void
      {
         if(m_window)
         {
            this.refreshInventoryCounts();
            this.refreshOrders();
            this.refreshNPCs();
            this.refreshPoints();
            this.refreshStations();
         }
      }
      
      public function refreshStations() : void
      {
         this.m_ingredientStationSlots.refresh();
         this.m_recipeStationSlots.refresh();
      }
      
      public function refreshInventoryCounts() : void
      {
         var inventory:FeatureCraftingInventory = null;
         if(this.m_storageSlots)
         {
            this.m_storageSlots.refreshCounts();
         }
         else
         {
            inventory = this.m_system.getInventory(INVENTORY_BARN);
            this.m_barnCountTextField.text = inventory.currentCount + "/" + inventory.currentLimit;
            inventory = this.m_system.getInventory(INVENTORY_SILO);
            this.m_siloCountTextField.text = inventory.currentCount + "/" + inventory.currentLimit;
         }
      }
      
      public function refreshNPCs(getNewOrders:Boolean = true) : void
      {
         if(this.m_npcSlots)
         {
            this.m_npcSlots.refresh();
         }
      }
      
      public function refreshOrders(getNewOrders:Boolean = true) : void
      {
         var orderBoard:FeatureCraftingOrderBoard = null;
         var orders:Array = null;
         if(this.m_orderSlots)
         {
            orderBoard = this.m_system.getOrderBoard();
            if(orderBoard.checkAllOrdersComplete())
            {
               this.showLoadingWidget();
            }
            else
            {
               this.m_orderRewardsFrame.refresh();
               if(getNewOrders)
               {
                  orders = orderBoard.orders;
                  if(orders)
                  {
                     orders = orders.concat();
                     orders.sortOn("isComplete");
                     this.m_orderSlots.items = orders;
                  }
                  else
                  {
                     this.m_orderSlots.items = [];
                  }
               }
               else
               {
                  this.m_orderSlots.refresh();
               }
            }
         }
      }
      
      public function refreshPoints() : void
      {
         var pointsLevel:int = 0;
         var points:int = 0;
         var pointsForCurrentLevel:int = 0;
         var pointsForNextLevel:int = 0;
         var progressPercentage:Number = NaN;
         if(m_window)
         {
            pointsLevel = this.m_system.getPointLevel();
            points = this.m_system.points;
            pointsForCurrentLevel = this.m_system.getPointsNeededForGivenLevel(pointsLevel);
            pointsForNextLevel = this.m_system.getPointsNeededForGivenLevel(pointsLevel + 1);
            progressPercentage = (points - pointsForCurrentLevel) / (pointsForNextLevel - pointsForCurrentLevel);
            if(this.m_levelTextField)
            {
               this.m_levelTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"LevelLabel",{"level":pointsLevel});
            }
            if(this.m_levelProgressBar)
            {
               (this.m_levelProgressBar.element as MovieClip).scaleX = Math.min(progressPercentage,1);
            }
         }
      }
      
      private function getLevelTooltipText() : String
      {
         var result:String = null;
         var pointsLevel:int = this.m_system.getPointLevel();
         var points:int = this.m_system.points;
         var pointsForNextLevel:int = this.m_system.getPointsNeededForGivenLevel(pointsLevel + 1);
         var pointsToNextLevel:int = pointsForNextLevel - points;
         var pointsTitle:String = this.m_system.getPointsFriendlyTitle();
         return ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"LevelTooltip",{
            "points":pointsToNextLevel,
            "pointsTitle":pointsTitle,
            "level":pointsLevel + 1
         });
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_whatisThisPrefix != "")
         {
            this.onClickHowDoesThisWork();
         }
         else
         {
            this.showTutorial();
         }
         this.closeCurrentNPCWindow();
      }
      
      override protected function showTutorial() : void
      {
         if(this.m_whatisThisPrefix != "")
         {
            this.onClickHowDoesThisWork();
         }
         else
         {
            super.showTutorial();
         }
      }
      
      protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         TutorialUI.displayTutorialWindowForItem(this.m_system.friendlyTitle,this.m_system.m_buildingName,this.m_whatisThisPrefix);
      }
      
      private function onBarnClick(event:MouseEvent) : void
      {
         var inventory:FeatureCraftingInventory = null;
         if(enableInput)
         {
            inventory = this.m_system.getInventory(INVENTORY_BARN);
            FeatureCraftingStorageWindow.display(inventory);
            this.closeCurrentNPCWindow();
         }
      }
      
      private function onSiloClick(event:MouseEvent) : void
      {
         var inventory:FeatureCraftingInventory = null;
         if(enableInput)
         {
            inventory = this.m_system.getInventory(INVENTORY_SILO);
            FeatureCraftingStorageWindow.display(inventory);
            this.closeCurrentNPCWindow();
         }
      }
      
      public function showLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_orderLoadingWidget) && !this.m_orderLoadingWidget.visible)
         {
            element = this.m_orderLoadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.gotoAndPlay(1);
               }
            }
            element.gotoAndPlay(1);
            this.m_orderLoadingWidget.visible = true;
            this.m_orderRewardsFrame.visible = false;
            this.m_orderSlots.visible = false;
         }
      }
      
      private function onOver(evt:MouseEvent) : void
      {
         this.m_show_mc.visible = true;
      }
      
      private function onOut(evt:MouseEvent) : void
      {
         this.m_show_mc.visible = false;
      }
      
      public function hideLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_orderLoadingWidget) && this.m_orderLoadingWidget.visible)
         {
            this.m_orderLoadingWidget.visible = false;
            element = this.m_orderLoadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.stop();
               }
            }
            element.stop();
            this.m_orderRewardsFrame.visible = true;
            this.m_orderSlots.visible = true;
         }
      }
      
      public function showGoodOverlay(good:FeatureCraftingGood, quantity:int = 1) : void
      {
         var windowPosition:Point = null;
         var screenPosition:Point = null;
         var storageElement:DisplayObject = null;
         var bounds:Rectangle = null;
         var message:String = quantity > 1 ? ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":quantity,
            "item":good.friendlyTitle
         }) : " ";
         var iconUrl:String = Global.getAssetURL(good.iconUrl());
         var iconFilters:Array = [new GlowFilter(16776960,1,8,8,20)];
         if(this.m_storageSlots)
         {
            storageElement = this.m_storageSlots.getElement(good.storageName);
            bounds = storageElement.getBounds(m_window);
            windowPosition = new Point(bounds.x + bounds.width / 2,bounds.y + bounds.height / 2);
            screenPosition = (this.m_storageSlots.element as MovieClip).localToGlobal(windowPosition);
         }
         else
         {
            switch(good.storageName)
            {
               case INVENTORY_BARN:
                  storageElement = this.m_barnWidget.element as DisplayObject;
                  break;
               case INVENTORY_SILO:
                  storageElement = this.m_siloWidget.element as DisplayObject;
            }
            windowPosition = new Point(storageElement.x,storageElement.y);
            screenPosition = m_window.localToGlobal(windowPosition);
         }
         UI.displayStatus(message,screenPosition.x,screenPosition.y,iconUrl,iconFilters);
      }
      
      public function get ingredientStationSlots() : FeatureCraftingStationSlotContainerFrame
      {
         var result:FeatureCraftingStationSlotContainerFrame = null;
         if(this.m_ingredientStationSlots)
         {
            result = this.m_ingredientStationSlots;
         }
         return result;
      }
      
      public function get recipeStationSlots() : FeatureCraftingStationSlotContainerFrame
      {
         var result:FeatureCraftingStationSlotContainerFrame = null;
         if(this.m_recipeStationSlots)
         {
            result = this.m_recipeStationSlots;
         }
         return result;
      }
      
      public function closeCurrentNPCWindow() : void
      {
         if(Boolean(this.m_system) && Boolean(this.m_system.currentNPCWindow))
         {
            if(this.m_system.currentNPCWindow.isSingleRecipeWindowOpen)
            {
               this.m_system.currentNPCWindow.singleRecipeWindow.toggleSingleRecipeFrame(false);
            }
            this.m_system.currentNPCWindow.close();
         }
      }
      
      public function get location() : String
      {
         return this.m_location;
      }
   }
}

