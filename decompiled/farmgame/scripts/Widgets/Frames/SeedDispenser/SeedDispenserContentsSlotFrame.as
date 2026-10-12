package Widgets.Frames.SeedDispenser
{
   import Classes.FeatureDataObjects.SeedDispenserSeedConfig;
   import Classes.Mastery;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Managers.SeedDispenserManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.SeedDispenser.SeedDispenserContentsWindow;
   import Widgets.Windows.StorageContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SeedDispenserContentsSlotFrame extends StorageContentsSlotFrame
   {
      
      private static const PREVIEW_WIDTH:int = 200;
      
      private var m_initialized:Boolean;
      
      private var m_activeSeed:SeedDispenserSeedConfig;
      
      private var m_previewFrame:ObjectPreviewFrame;
      
      private var m_headerTextField:ZwTextField;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_masteryFrame:MarketSlotMasteryFrame;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_harvestFrame:SeedDispenserContentsHarvestFrame;
      
      private var m_expandTextField:ZwTextField;
      
      private var m_expandButton:FarmAnimatedTextButton;
      
      public function SeedDispenserContentsSlotFrame(element:DisplayObject, contents:Array, mainWindow:StorageContentsWindow, slotClass:Class)
      {
         super(element,contents,mainWindow,slotClass);
         this.m_headerTextField = addWidget(new ZwTextField(m_element.generic_1_tf," ")) as ZwTextField;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","SeedDispenser_UseSeeds"),this.onUseButtonClick)) as FarmAnimatedTextButton;
         this.m_harvestFrame = addWidget(new SeedDispenserContentsHarvestFrame(m_element.harvest_mc,mainWindow as SeedDispenserContentsWindow)) as SeedDispenserContentsHarvestFrame;
         this.m_expandTextField = addWidget(new ZwTextField(m_element.generic_2_tf," ")) as ZwTextField;
         this.m_expandButton = addWidget(new FarmAnimatedTextButton(m_element.expand_bt,"Expand",this.onExpandButtonClick)) as FarmAnimatedTextButton;
         var butterflyWidget:ZwWidget = addWidget(new ZwWidget(m_element.butterfly_mc)) as ZwWidget;
         (butterflyWidget.element as MovieClip).play();
         this.m_initialized = true;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_countTextField = null;
         this.m_expandButton = null;
         this.m_expandTextField = null;
         this.m_harvestFrame = null;
         this.m_headerTextField = null;
         this.m_nameTextField = null;
         this.m_previewFrame = null;
         this.m_useButton = null;
         super.release();
      }
      
      override public function refresh() : void
      {
         var parentWindow:SeedDispenserContentsWindow = null;
         var featureName:String = null;
         var headerTextKey:String = null;
         var activeSeed:SeedDispenserSeedConfig = null;
         var hasReachedMaxExpansionLevel:Boolean = false;
         var seedItem:SeedItem = null;
         var seedCount:int = 0;
         var mastery:Mastery = null;
         if(this.m_initialized)
         {
            super.refresh();
            parentWindow = m_mainWindow as SeedDispenserContentsWindow;
            featureName = parentWindow.featureName;
            headerTextKey = parentWindow.featureName + "_HeaderText";
            this.m_headerTextField.text = ZLocUtils.hasString("Dialogs",headerTextKey) ? ZLocUtils.t("Dialogs",headerTextKey) : "";
            activeSeed = SeedDispenserManager.getActiveSeed(featureName);
            if(activeSeed)
            {
               seedItem = Global.farmGameSettingsManager.getFarmItemByName(activeSeed.name) as SeedItem;
               if(seedItem)
               {
                  if(activeSeed != this.m_activeSeed)
                  {
                     this.m_activeSeed = activeSeed;
                     this.m_nameTextField.text = seedItem.friendlyTitle;
                     if(this.m_previewFrame != null)
                     {
                        removeWidget(this.m_previewFrame);
                     }
                     this.m_previewFrame = addWidget(new ObjectPreviewFrame(m_element.preview_mc,seedItem,null,null,[PREVIEW_WIDTH],"","",null,activeSeed.previewOffset)) as ObjectPreviewFrame;
                  }
                  seedCount = Global.player.countSeeds(seedItem.name);
                  this.m_countTextField.text = String(seedCount);
                  this.m_useButton.enabled = seedCount > 0;
                  if(seedItem.isMasterable())
                  {
                     mastery = seedItem.mastery;
                     this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
                     this.m_masteryFrame.visible = true;
                  }
                  else
                  {
                     this.m_masteryFrame.visible = false;
                  }
                  this.m_harvestFrame.populate(seedItem);
               }
            }
            hasReachedMaxExpansionLevel = parentWindow.building.hasReachedMaxExpansionLevel();
            if(hasReachedMaxExpansionLevel)
            {
               this.m_expandTextField.visible = false;
               this.m_expandButton.visible = false;
            }
            else
            {
               this.m_expandTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_ExpandMessage",{"item":m_mainWindow.building.getItem().friendlyTitle});
               this.m_expandTextField.visible = true;
               this.m_expandButton.visible = true;
            }
         }
      }
      
      private function onExpandButtonClick(event:MouseEvent) : void
      {
         if(this.m_expandButton.enabled)
         {
            m_mainWindow.showExpandView();
         }
      }
      
      private function onUseButtonClick(event:MouseEvent) : void
      {
         var seedItem:SeedItem = null;
         if(this.m_activeSeed)
         {
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_activeSeed.name) as SeedItem;
            if(seedItem)
            {
               (m_mainWindow as SeedDispenserContentsWindow).useSeed(seedItem);
            }
         }
      }
   }
}

