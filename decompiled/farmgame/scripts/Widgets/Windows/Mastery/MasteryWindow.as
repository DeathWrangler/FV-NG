package Widgets.Windows.Mastery
{
   import Classes.Constants.Experiments;
   import Classes.CraftConfigSettings;
   import Classes.HarvestableStorageBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.TreeItem;
   import Classes.crafting.RecipeItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Mastery.MasterySlotContainerFrame;
   import Widgets.Frames.Mastery.RecipeMasterySlotContainerFrame;
   import Widgets.Frames.Mastery.TreeMasterySlotContainerFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Promotions.PostMasteryReductionWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MasteryWindow extends FarmWindow
   {
      
      public static const TYPE_TREE:String = "tree";
      
      public static const TYPE_SEED:String = "seed";
      
      public static const SUBTYPE_SEEDS:String = "seeds";
      
      public static const TYPE_ANIMAL:String = "animal";
      
      public static const TYPE_RECIPE:String = "recipe";
      
      public static const TYPE_BLOOM:String = "blooms";
      
      public static const SUBTYPE_BLOOMS:String = "blooms";
      
      protected static const DIALOG_ASSET_V3:String = "assets/dialogs/FV_ViewMastery.swf";
      
      protected static const DIALOG_ASSET_V4:String = "assets/dialogs/FV_ViewMasteryV4.swf";
      
      protected static const DIALOG_ASSET_V5:String = "assets/dialogs/FV_ViewMasteryV5.swf";
      
      protected static var m_itemSlotIndex:Array = null;
      
      protected static var m_itemDataIndex:Object = new Object();
      
      protected var m_currentType:String = "";
      
      protected var m_currentItem:FarmItem = null;
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_slotContainerFrames:Object;
      
      protected var m_searchFrame:SearchFrame = null;
      
      private var m_searchString:String = "";
      
      protected var m_noResultsTextField:ZwTextField = null;
      
      protected var m_tutorial_mc:ZwFrame = null;
      
      private var m_cachedPurchasableMasterySigns:Array;
      
      private var m_isInBloomsExperiment:Boolean;
      
      private var m_isInVersion3Experiment:Boolean;
      
      private var m_isInRecipeExperiment:Boolean;
      
      private var m_isInBuyBackExperiment:Boolean;
      
      private var m_regionExcludeMarketPreq:Array;
      
      public function MasteryWindow(openedType:String = "seed", openedItem:FarmItem = null)
      {
         var asset:String = null;
         this.m_slotContainerFrames = new Object();
         this.m_regionExcludeMarketPreq = new Array("XmasR2MarketPrereq","TurtleislandR2MarketPrereq");
         this.m_isInBloomsExperiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BLOOMS) > 0;
         this.m_isInVersion3Experiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MASTERY_WINDOW_V3) == 1 || this.m_isInBloomsExperiment;
         this.m_isInRecipeExperiment = this.m_isInVersion3Experiment && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MASTERY_WINDOW_V3_RECIPE) == 1;
         this.m_isInBuyBackExperiment = this.m_isInVersion3Experiment;
         if(Global.player.masterySignCleaned)
         {
            asset = DIALOG_ASSET_V5;
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_SURFACE) == 1)
         {
            asset = DIALOG_ASSET_V4;
         }
         else
         {
            asset = DIALOG_ASSET_V3;
         }
         super(asset);
         this.m_currentType = openedType;
         this.m_currentItem = openedItem;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleField:ZwTextField = null;
         var seedsTitle:String = null;
         var cropTab:FarmTabButton = null;
         var treesTitle:String = null;
         var treeTab:FarmTabButton = null;
         var animalsTitle:String = null;
         var animalTab:FarmTabButton = null;
         var cropSlotFrame:MasterySlotContainerFrame = null;
         var treeSlotFrame:TreeMasterySlotContainerFrame = null;
         var animalSlotFrame:MasterySlotContainerFrame = null;
         var bloomsTitle:String = null;
         var bloomsTab:FarmTabButton = null;
         var recipeSlotFrame:RecipeMasterySlotContainerFrame = null;
         var bloomSlotFrame:MasterySlotContainerFrame = null;
         var recipeTab:FarmTabButton = null;
         var startTimer:Date = new Date();
         super.postLoadComplete();
         if(Global.player.masterySignCleaned)
         {
            this.addTutMC();
            if(!Global.player.getSeenFlag(PostMasteryReductionWindow.PostMasteryReductionWindow_Seen))
            {
               this.showTut();
               Global.player.setSeenFlag(PostMasteryReductionWindow.PostMasteryReductionWindow_Seen,true);
            }
         }
         var flowStat:String = "oldFlow";
         if(Global.flashHotParams["OPTIMIZED_MASTERYWINDOW"])
         {
            flowStat = "newFlow";
            this.optimizedPostLoadComplete();
         }
         else
         {
            if(m_window.inset_mc)
            {
               addWidget(new ZwFrame(m_window.inset_mc));
            }
            titleField = new ZwTextField(m_window.title_tf);
            titleField.text = ZLocUtils.t("Dialogs","Mastery_Dialog_Title");
            addWidget(titleField);
            this.m_noResultsTextField = new ZwTextField(m_window.noResults_tf,ZLocUtils.t("Dialogs","NoMatchingResults"));
            addWidget(this.m_noResultsTextField);
            this.m_noResultsTextField.visible = false;
            seedsTitle = ZLocUtils.t("Dialogs","Seed");
            cropTab = addWidget(new FarmTabButton(m_window.tab0_mc,seedsTitle)) as FarmTabButton;
            treesTitle = ZLocUtils.t("Dialogs","Tree");
            treeTab = addWidget(new FarmTabButton(m_window.tab1_mc,treesTitle)) as FarmTabButton;
            animalsTitle = ZLocUtils.t("Dialogs","Animal");
            animalTab = addWidget(new FarmTabButton(m_window.tab2_mc,animalsTitle)) as FarmTabButton;
            if(this.m_isInBloomsExperiment)
            {
               bloomsTitle = ZLocUtils.t("Dialogs","Bloom");
               bloomsTab = addWidget(new FarmTabButton(m_window.tab4_mc,bloomsTitle)) as FarmTabButton;
            }
            if(m_itemDataIndex[TYPE_SEED] == null)
            {
               m_itemDataIndex[TYPE_SEED] = this.getMasteryData(TYPE_SEED);
            }
            cropSlotFrame = new MasterySlotContainerFrame(m_window.cropMasterySlotContainer,m_itemDataIndex[TYPE_SEED],this);
            cropSlotFrame.masteryType = TYPE_SEED;
            addWidget(cropSlotFrame,false);
            this.m_slotContainerFrames[TYPE_SEED] = cropSlotFrame;
            if(m_itemDataIndex[TYPE_TREE] == null)
            {
               m_itemDataIndex[TYPE_TREE] = this.getMasteryData(TYPE_TREE);
            }
            treeSlotFrame = new TreeMasterySlotContainerFrame(m_window.treeMasterySlotContainer,m_itemDataIndex[TYPE_TREE],this);
            addWidget(treeSlotFrame,false);
            this.m_slotContainerFrames[TYPE_TREE] = treeSlotFrame;
            if(m_itemDataIndex[TYPE_ANIMAL] == null)
            {
               m_itemDataIndex[TYPE_ANIMAL] = this.getMasteryData(TYPE_ANIMAL);
            }
            animalSlotFrame = new MasterySlotContainerFrame(m_window.animalMasterySlotContainer,m_itemDataIndex[TYPE_ANIMAL],this);
            addWidget(animalSlotFrame,false);
            this.m_slotContainerFrames[TYPE_ANIMAL] = animalSlotFrame;
            if(this.m_isInRecipeExperiment)
            {
               if(m_itemDataIndex[TYPE_RECIPE] == null)
               {
                  m_itemDataIndex[TYPE_RECIPE] = this.getRecipeData();
               }
               recipeSlotFrame = new RecipeMasterySlotContainerFrame(m_window.recipesMasterySlotContainer,m_itemDataIndex[TYPE_RECIPE],this);
               addWidget(recipeSlotFrame,false);
               this.m_slotContainerFrames[TYPE_RECIPE] = recipeSlotFrame;
            }
            if(this.m_isInBloomsExperiment)
            {
               if(m_itemDataIndex[TYPE_BLOOM] == null)
               {
                  m_itemDataIndex[TYPE_BLOOM] = this.getMasteryData(TYPE_BLOOM);
               }
               bloomSlotFrame = new MasterySlotContainerFrame(m_window.flowerMasterySlotContainer,m_itemDataIndex[TYPE_BLOOM],this);
               bloomSlotFrame.masteryType = TYPE_BLOOM;
               addWidget(bloomSlotFrame,false);
               this.m_slotContainerFrames[TYPE_BLOOM] = bloomSlotFrame;
            }
            this.m_toggleManager = new ZwToggleManager();
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(cropTab,cropSlotFrame,this.selectedSeedFrame),this.m_currentType == TYPE_SEED);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(treeTab,treeSlotFrame,this.selectedTreeFrame),this.m_currentType == TYPE_TREE);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(animalTab,animalSlotFrame,this.selectedAnimalFrame),this.m_currentType == TYPE_ANIMAL);
            if(this.m_isInRecipeExperiment)
            {
               recipeTab = addWidget(new FarmTabButton(m_window.tab3_mc,ZLocUtils.t("Dialogs","Mastery_RecipeTab"))) as FarmTabButton;
               this.m_toggleManager.addToggle(new ZwVisibilityToggle(recipeTab,recipeSlotFrame,this.selectedRecipeFrame),this.m_currentType == TYPE_RECIPE);
            }
            if(this.m_isInBloomsExperiment)
            {
               this.m_toggleManager.addToggle(new ZwVisibilityToggle(bloomsTab,bloomSlotFrame,this.selectedBloomFrame),this.m_currentType == TYPE_BLOOM);
            }
            if(this.m_currentItem != null)
            {
               switch(this.m_currentType)
               {
                  case TYPE_SEED:
                     this.setPageNumberByCurrentItem(cropSlotFrame,m_itemDataIndex[TYPE_SEED]);
                     break;
                  case TYPE_TREE:
                     this.setPageNumberByCurrentItem(treeSlotFrame,m_itemDataIndex[TYPE_TREE]);
                     break;
                  case TYPE_ANIMAL:
                     this.setPageNumberByCurrentItem(animalSlotFrame,m_itemDataIndex[TYPE_ANIMAL]);
                     break;
                  case TYPE_RECIPE:
                     this.setPageNumberByCurrentItem(recipeSlotFrame,m_itemDataIndex[TYPE_RECIPE]);
                     break;
                  case TYPE_BLOOM:
                     this.setPageNumberByCurrentItem(bloomSlotFrame,m_itemDataIndex[TYPE_BLOOM]);
               }
            }
            this.m_searchFrame = new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate);
            addWidget(this.m_searchFrame);
         }
         var endTimer:Date = new Date();
         var sampleRate:int = Global.flashHotParams["OPTIMIZED_MASTERYWINDOW_SAMPLE"] ? int(parseInt(Global.flashHotParams["OPTIMIZED_MASTERYWINDOW_SAMPLE"])) : 1;
         FarmStatsManager.sample(sampleRate,"masterywindow","postInitLoadTime",flowStat,"","","",endTimer.time - startTimer.time);
      }
      
      protected function optimizedPostLoadComplete() : void
      {
         var currentFrame:MasterySlotContainerFrame = null;
         var bloomsTitle:String = null;
         var bloomsTab:FarmTabButton = null;
         var recipeSlotFrame:RecipeMasterySlotContainerFrame = null;
         var bloomSlotFrame:MasterySlotContainerFrame = null;
         var recipeTab:FarmTabButton = null;
         if(m_window.inset_mc)
         {
            addWidget(new ZwFrame(m_window.inset_mc));
         }
         var titleField:ZwTextField = new ZwTextField(m_window.title_tf);
         titleField.text = ZLocUtils.t("Dialogs","Mastery_Dialog_Title");
         addWidget(titleField);
         this.m_noResultsTextField = new ZwTextField(m_window.noResults_tf,ZLocUtils.t("Dialogs","NoMatchingResults"));
         addWidget(this.m_noResultsTextField);
         this.m_noResultsTextField.visible = false;
         var seedsTitle:String = ZLocUtils.t("Dialogs","Seed");
         var cropTab:FarmTabButton = addWidget(new FarmTabButton(m_window.tab0_mc,seedsTitle)) as FarmTabButton;
         var treesTitle:String = ZLocUtils.t("Dialogs","Tree");
         var treeTab:FarmTabButton = addWidget(new FarmTabButton(m_window.tab1_mc,treesTitle)) as FarmTabButton;
         var animalsTitle:String = ZLocUtils.t("Dialogs","Animal");
         var animalTab:FarmTabButton = addWidget(new FarmTabButton(m_window.tab2_mc,animalsTitle)) as FarmTabButton;
         if(this.m_isInBloomsExperiment)
         {
            bloomsTitle = ZLocUtils.t("Dialogs","Bloom");
            bloomsTab = addWidget(new FarmTabButton(m_window.tab4_mc,bloomsTitle)) as FarmTabButton;
         }
         var cropSlotFrame:MasterySlotContainerFrame = new MasterySlotContainerFrame(m_window.cropMasterySlotContainer,[],this);
         cropSlotFrame.masteryType = TYPE_SEED;
         addWidget(cropSlotFrame,false);
         this.m_slotContainerFrames[TYPE_SEED] = cropSlotFrame;
         var treeSlotFrame:TreeMasterySlotContainerFrame = new TreeMasterySlotContainerFrame(m_window.treeMasterySlotContainer,[],this);
         addWidget(treeSlotFrame,false);
         this.m_slotContainerFrames[TYPE_TREE] = treeSlotFrame;
         var animalSlotFrame:MasterySlotContainerFrame = new MasterySlotContainerFrame(m_window.animalMasterySlotContainer,[],this);
         addWidget(animalSlotFrame,false);
         this.m_slotContainerFrames[TYPE_ANIMAL] = animalSlotFrame;
         if(this.m_isInRecipeExperiment)
         {
            recipeSlotFrame = new RecipeMasterySlotContainerFrame(m_window.recipesMasterySlotContainer,[],this);
            addWidget(recipeSlotFrame,false);
            this.m_slotContainerFrames[TYPE_RECIPE] = recipeSlotFrame;
         }
         if(this.m_isInBloomsExperiment)
         {
            bloomSlotFrame = new MasterySlotContainerFrame(m_window.flowerMasterySlotContainer,[],this);
            bloomSlotFrame.masteryType = TYPE_BLOOM;
            addWidget(bloomSlotFrame,false);
            this.m_slotContainerFrames[TYPE_BLOOM] = bloomSlotFrame;
         }
         this.m_toggleManager = new ZwToggleManager();
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(cropTab,cropSlotFrame,this.optimizedSelectedSeedFrame),this.m_currentType == TYPE_SEED);
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(treeTab,treeSlotFrame,this.optimizedSelectedTreeFrame),this.m_currentType == TYPE_TREE);
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(animalTab,animalSlotFrame,this.optimizedSelectedAnimalFrame),this.m_currentType == TYPE_ANIMAL);
         if(this.m_isInRecipeExperiment)
         {
            recipeTab = addWidget(new FarmTabButton(m_window.tab3_mc,ZLocUtils.t("Dialogs","Mastery_RecipeTab"))) as FarmTabButton;
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(recipeTab,recipeSlotFrame,this.optimizedSelectedRecipeFrame),this.m_currentType == TYPE_RECIPE);
         }
         if(this.m_isInBloomsExperiment)
         {
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(bloomsTab,bloomSlotFrame,this.optimizedSelectedBloomFrame),this.m_currentType == TYPE_BLOOM);
         }
         switch(this.m_currentType)
         {
            case TYPE_SEED:
               currentFrame = cropSlotFrame;
               this.optimizedSelectedSeedFrame();
               break;
            case TYPE_TREE:
               currentFrame = treeSlotFrame;
               this.optimizedSelectedTreeFrame();
               break;
            case TYPE_ANIMAL:
               currentFrame = animalSlotFrame;
               this.optimizedSelectedAnimalFrame();
               break;
            case TYPE_RECIPE:
               currentFrame = recipeSlotFrame;
               this.optimizedSelectedRecipeFrame();
               break;
            case TYPE_BLOOM:
               currentFrame = bloomSlotFrame;
               this.optimizedSelectedBloomFrame();
         }
         if(this.m_currentItem != null)
         {
            this.setPageNumberByCurrentItem(currentFrame,m_itemDataIndex[this.m_currentType]);
         }
         this.m_searchFrame = new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate);
         addWidget(this.m_searchFrame);
      }
      
      private function addTutMC() : void
      {
         var tutorial_mc:MovieClip = null;
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            addWidget(this.m_tutorial_mc = new ZwFrame(m_window.tutorial_mc),false);
            tutorial_mc = m_window.tutorial_mc as MovieClip;
            if(tutorial_mc.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(tutorial_mc.accept_bt,ZLocUtils.t("Dialogs","MasteryReduction_tut_accept"),this.hideTut));
            }
            if(m_window.hasOwnProperty("whatisthis_mc"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","MasteryReduction_whatisthis"),this.showTut));
            }
         }
      }
      
      private function hideTut(event:MouseEvent = null) : void
      {
         if(null != this.m_tutorial_mc)
         {
            this.m_tutorial_mc.visible = false;
         }
      }
      
      private function showTut(event:MouseEvent = null) : void
      {
         if(null != this.m_tutorial_mc)
         {
            this.m_tutorial_mc.visible = true;
         }
      }
      
      private function selectedSeedFrame() : void
      {
         this.selectFrame(TYPE_SEED);
      }
      
      private function selectedTreeFrame() : void
      {
         this.selectFrame(TYPE_TREE);
      }
      
      private function selectedAnimalFrame() : void
      {
         this.selectFrame(TYPE_ANIMAL);
      }
      
      private function selectedRecipeFrame() : void
      {
         this.selectFrame(TYPE_RECIPE);
      }
      
      private function selectedBloomFrame() : void
      {
         this.selectFrame(TYPE_BLOOM);
      }
      
      private function optimizedSelectedSeedFrame() : void
      {
         if(m_itemDataIndex[TYPE_SEED] == null)
         {
            m_itemDataIndex[TYPE_SEED] = this.getMasteryData(TYPE_SEED);
         }
         (this.m_slotContainerFrames[TYPE_SEED] as MasterySlotContainerFrame).changeData(m_itemDataIndex[TYPE_SEED]);
         this.selectFrame(TYPE_SEED);
      }
      
      private function optimizedSelectedTreeFrame() : void
      {
         if(m_itemDataIndex[TYPE_TREE] == null)
         {
            m_itemDataIndex[TYPE_TREE] = this.getMasteryData(TYPE_TREE);
         }
         (this.m_slotContainerFrames[TYPE_TREE] as TreeMasterySlotContainerFrame).changeData(m_itemDataIndex[TYPE_TREE]);
         this.selectFrame(TYPE_TREE);
      }
      
      private function optimizedSelectedAnimalFrame() : void
      {
         if(m_itemDataIndex[TYPE_ANIMAL] == null)
         {
            m_itemDataIndex[TYPE_ANIMAL] = this.getMasteryData(TYPE_ANIMAL);
         }
         (this.m_slotContainerFrames[TYPE_ANIMAL] as MasterySlotContainerFrame).changeData(m_itemDataIndex[TYPE_ANIMAL]);
         this.selectFrame(TYPE_ANIMAL);
      }
      
      private function optimizedSelectedRecipeFrame() : void
      {
         if(m_itemDataIndex[TYPE_RECIPE] == null)
         {
            m_itemDataIndex[TYPE_RECIPE] = this.getRecipeData();
         }
         (this.m_slotContainerFrames[TYPE_RECIPE] as RecipeMasterySlotContainerFrame).changeData(m_itemDataIndex[TYPE_RECIPE]);
         this.selectFrame(TYPE_RECIPE);
      }
      
      private function optimizedSelectedBloomFrame() : void
      {
         if(m_itemDataIndex[TYPE_BLOOM] == null)
         {
            m_itemDataIndex[TYPE_BLOOM] = this.getMasteryData(TYPE_BLOOM);
         }
         (this.m_slotContainerFrames[TYPE_BLOOM] as MasterySlotContainerFrame).changeData(m_itemDataIndex[TYPE_BLOOM]);
         this.selectFrame(TYPE_BLOOM);
      }
      
      private function selectFrame(newType:String) : void
      {
         this.m_currentType = newType;
         if(this.m_searchFrame != null)
         {
            this.m_searchFrame.reset();
            this.onSearchUpdate("");
         }
      }
      
      private function onSearchUpdate(searchString:String = "") : void
      {
         var itemsToDisplay:Array = null;
         if(searchString == "" || this.m_searchString != searchString)
         {
            this.m_searchString = searchString;
            if(this.m_searchString == "")
            {
               itemsToDisplay = m_itemDataIndex[this.m_currentType];
            }
            else
            {
               itemsToDisplay = this.searchFarmItems(m_itemDataIndex[this.m_currentType],this.m_searchString);
            }
            (this.m_slotContainerFrames[this.m_currentType] as MasterySlotContainerFrame).changeData(itemsToDisplay);
            this.m_noResultsTextField.visible = itemsToDisplay.length == 0;
         }
      }
      
      private function setPageNumberByCurrentItem(slotContainerFrame:MasterySlotContainerFrame, masteryData:Array) : void
      {
         var pageIndex:int = 0;
         if(this.m_currentItem != null)
         {
            if(m_itemSlotIndex != null && m_itemSlotIndex.hasOwnProperty(this.m_currentItem.code))
            {
               pageIndex = Math.floor(m_itemSlotIndex[this.m_currentItem.code] / slotContainerFrame.totalSlots());
               if(pageIndex <= slotContainerFrame.calcMaxPageNumber())
               {
                  slotContainerFrame.pageNumber = pageIndex;
               }
            }
         }
      }
      
      override protected function release() : void
      {
         if(this.m_toggleManager)
         {
            this.m_toggleManager.release();
            this.m_toggleManager = null;
         }
         super.release();
      }
      
      protected function getMasteryData(type:String) : Array
      {
         var farmItem:FarmItem = null;
         var harvestableItem:HarvestableItem = null;
         var allTrees:Array = null;
         var level2Tree:Object = null;
         var treeIdx:int = 0;
         var treeItem:TreeItem = null;
         var nextLevelCode:String = null;
         var allAnimals:Array = null;
         var animalIdx:int = 0;
         var animal:FarmItem = null;
         var itemType:String = "";
         var itemSubtype:String = "";
         switch(type)
         {
            case TYPE_SEED:
               itemType = TYPE_SEED;
               itemSubtype = SUBTYPE_SEEDS;
               break;
            case TYPE_TREE:
               itemType = TYPE_SEED;
               itemSubtype = TYPE_TREE;
               break;
            case TYPE_ANIMAL:
               itemType = TYPE_ANIMAL;
               itemSubtype = FarmGameSettingsManager.ALL;
               break;
            case TYPE_BLOOM:
               itemType = TYPE_SEED;
               itemSubtype = SUBTYPE_BLOOMS;
         }
         var allItems:Array = Global.farmGameSettingsManager.getFarmItemsArray(itemType,itemSubtype,FarmGameSettingsManager.ALL,FarmGameSettingsManager.NAME,FarmGameSettingsManager.ASCENDING,false,"");
         var result:Array = [];
         if(m_itemSlotIndex == null)
         {
            m_itemSlotIndex = new Array();
         }
         var itemIdx:int = 0;
         for each(farmItem in allItems)
         {
            harvestableItem = farmItem as HarvestableItem;
            if(harvestableItem)
            {
               if(Boolean(harvestableItem.isMasterable()) && (Boolean(harvestableItem.mastery.hasAnyMastery() || harvestableItem.checkExperimentGate())) && (type == TYPE_TREE || this.checkLimited(harvestableItem) || type == TYPE_ANIMAL && this.checkLimitedStart(harvestableItem)))
               {
                  result.push(harvestableItem);
                  m_itemSlotIndex[harvestableItem.code] = itemIdx;
                  itemIdx++;
               }
            }
         }
         if(type == TYPE_TREE)
         {
            allTrees = result.concat([]);
            result = [];
            treeIdx = 0;
            for each(treeItem in allTrees)
            {
               if(treeItem.nextLevel != treeItem.code)
               {
                  nextLevelCode = treeItem.nextLevel;
                  if(this.isregionExcludeMarketPreq(treeItem.marketPrereqName))
                  {
                     if(treeItem.checkMarketPrereqs())
                     {
                        result.push([treeItem,Global.farmGameSettingsManager.getFarmItemByCode(nextLevelCode)]);
                        m_itemSlotIndex[treeItem.code] = treeIdx;
                        m_itemSlotIndex[nextLevelCode] = treeIdx;
                        treeIdx++;
                     }
                  }
                  else
                  {
                     result.push([treeItem,Global.farmGameSettingsManager.getFarmItemByCode(nextLevelCode)]);
                     m_itemSlotIndex[treeItem.code] = treeIdx;
                     m_itemSlotIndex[nextLevelCode] = treeIdx;
                     treeIdx++;
                  }
               }
            }
         }
         if(type == TYPE_ANIMAL)
         {
            allAnimals = result.concat([]);
            result = [];
            animalIdx = 0;
            for each(animal in allAnimals)
            {
               if(animal.code == HarvestableStorageBuilding.getItemCodeForMasteryOverrideExportName(animal.code))
               {
                  if(this.isregionExcludeMarketPreq(animal.marketPrereqName))
                  {
                     if(animal.checkMarketPrereqs())
                     {
                        result.push(animal);
                        m_itemSlotIndex[animal.code] = animalIdx;
                        animalIdx++;
                     }
                  }
                  else
                  {
                     result.push(animal);
                     m_itemSlotIndex[animal.code] = animalIdx;
                     animalIdx++;
                  }
               }
            }
         }
         return result;
      }
      
      private function getRecipeData() : Array
      {
         var allRecipes:Array = null;
         var recipe:RecipeItem = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SORT_RECIPE_DATA);
         if(variant == Experiments.VARIANT_FLASH_SORT_RECIPE_DATA)
         {
            allRecipes = Global.craftConfigSettings.getAllRecipes(null,0,false);
         }
         else
         {
            allRecipes = Global.craftConfigSettings.getAllRecipes();
         }
         var result:Array = [];
         var craftVersions:Object = {};
         for each(recipe in allRecipes)
         {
            if(!craftVersions[recipe.craft])
            {
               craftVersions[recipe.craft] = Global.craftConfigSettings.getCraftVersion(recipe.craft);
            }
            if(craftVersions[recipe.craft] == CraftConfigSettings.CRAFT_VERSION_INITIAL && !recipe.isLimited)
            {
               if(WorldSeasonsManager.getInstance().hasSeasons(Global.worldManager.currentWorldType))
               {
                  if(recipe.isPlayerEligible() == true)
                  {
                     result.push(recipe);
                  }
               }
               else
               {
                  result.push(recipe);
               }
            }
         }
         return result.sortOn("friendlyTitle");
      }
      
      public function getPurchasableSigns() : Array
      {
         if(!this.m_cachedPurchasableMasterySigns)
         {
            this.m_cachedPurchasableMasterySigns = this.findMasterySignsToPurchase();
         }
         return this.m_cachedPurchasableMasterySigns;
      }
      
      public function purchaseMasterySign(masterySignCode:String, masteryType:String, masteredItem:String) : void
      {
         var itemName:String = null;
         if(this.m_cachedPurchasableMasterySigns.indexOf(masterySignCode) != -1 && Global.player.canBuy(this.masterySignCoinCost(),true))
         {
            TransactionManager.addTransaction(new TGenericTransaction("PurchaseMasterySignService","onPurchaseMasterySign",null,[masteryType,masteredItem]));
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(masterySignCode);
            Global.player.gold -= this.masterySignCoinCost();
            Global.player.addGift(itemName);
            this.m_cachedPurchasableMasterySigns.splice(this.m_cachedPurchasableMasterySigns.indexOf(masterySignCode),1);
            (this.m_slotContainerFrames[this.m_currentType] as MasterySlotContainerFrame).refresh();
         }
      }
      
      public function masterySignCoinCost() : int
      {
         return Global.farmGameSettingsManager.getInt("MasteryBuyBackCoinCost",10);
      }
      
      private function findMasterySignsToPurchase() : Array
      {
         var instances:Array = null;
         var buildingItems:Object = null;
         var itemCode:String = null;
         var masteredItem:String = null;
         var harvestableItem:HarvestableItem = null;
         var variant:int = 0;
         var recipes:Array = null;
         var recipe:RecipeItem = null;
         var recipeLevel:int = 0;
         var mastery:Object = Global.player.mastery;
         var allowedToBuy:Array = [];
         for(masteredItem in mastery)
         {
            if(mastery[masteredItem] >= 2)
            {
               harvestableItem = Global.farmGameSettingsManager.getFarmItemByCode(masteredItem) as HarvestableItem;
               if(harvestableItem)
               {
                  itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(harvestableItem.mastery.finalGift);
                  if(itemCode)
                  {
                     instances = Global.world.getObjectsByCode(itemCode);
                     if(instances.length == 0 && (!Global.player.gifts[itemCode] || (Global.player.gifts[itemCode] as StorageItem).isEmpty()))
                     {
                        if(buildingItems == null)
                        {
                           buildingItems = this.getAllPartsFromBuildings();
                        }
                        if(!buildingItems[itemCode])
                        {
                           allowedToBuy.push(itemCode);
                        }
                     }
                  }
               }
            }
         }
         if(this.m_isInRecipeExperiment)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SORT_RECIPE_DATA);
            if(variant == Experiments.VARIANT_FLASH_SORT_RECIPE_DATA)
            {
               recipes = Global.craftConfigSettings.getAllRecipes(null,0,false);
            }
            else
            {
               recipes = Global.craftConfigSettings.getAllRecipes();
            }
            for each(recipe in recipes)
            {
               recipeLevel = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipe.id).level;
               if(recipe.getMasteryLevelForRecipeLevel(recipeLevel) > 0)
               {
                  itemCode = recipe.masterySignCode;
                  if(itemCode)
                  {
                     instances = Global.world.getObjectsByCode(itemCode);
                     if(instances.length == 0 && (!Global.player.gifts[itemCode] || (Global.player.gifts[itemCode] as StorageItem).isEmpty()))
                     {
                        if(buildingItems == null)
                        {
                           buildingItems = this.getAllPartsFromBuildings();
                        }
                        if(!buildingItems[itemCode])
                        {
                           allowedToBuy.push(itemCode);
                        }
                     }
                  }
               }
            }
         }
         return allowedToBuy;
      }
      
      private function getAllPartsFromBuildings() : Object
      {
         var building:StorageBuilding = null;
         var contentCode:String = null;
         var buildings:Array = Global.world.getObjectsByClass(StorageBuilding);
         var buildingItems:Object = {};
         for each(building in buildings)
         {
            for(contentCode in building.contents)
            {
               buildingItems[contentCode] = 1;
            }
         }
         return buildingItems;
      }
      
      private function checkLimited(farmItem:HarvestableItem) : Boolean
      {
         var result:Boolean = false;
         if(farmItem.checkDateGate() && farmItem.checkGeoGate())
         {
            result = true;
         }
         else if(farmItem.mastery.getCurrentCount() > 0)
         {
            result = true;
         }
         return result;
      }
      
      private function checkLimitedStart(farmItem:HarvestableItem) : Boolean
      {
         var result:Boolean = false;
         if(farmItem.checkStartDateGate() && farmItem.checkGeoGate())
         {
            result = true;
         }
         else if(farmItem.mastery.getCurrentCount() > 0)
         {
            result = true;
         }
         return result;
      }
      
      private function searchFarmItems(farmItems:Array, searchString:String) : Array
      {
         var friendlyName:String = null;
         var levelTwoTreeFriendlyName:String = null;
         var treeItem:Array = null;
         var recipe:RecipeItem = null;
         var item:HarvestableItem = null;
         var results:Array = new Array();
         searchString = searchString.toLowerCase();
         if(this.m_currentType == TYPE_TREE)
         {
            for each(treeItem in farmItems)
            {
               friendlyName = treeItem[0].friendlyTitle.toLowerCase();
               if(treeItem.length == 2 && treeItem[1] is FarmItem)
               {
                  levelTwoTreeFriendlyName = treeItem[1].friendlyTitle.toLowerCase();
               }
               else
               {
                  levelTwoTreeFriendlyName = "";
               }
               if(friendlyName.search(searchString) != -1 || levelTwoTreeFriendlyName.search(searchString) != -1)
               {
                  results.push(treeItem);
               }
            }
         }
         else if(this.m_currentType == TYPE_RECIPE)
         {
            for each(recipe in farmItems)
            {
               friendlyName = recipe.friendlyTitle.toLowerCase();
               if(friendlyName.search(searchString) != -1)
               {
                  results.push(recipe);
               }
            }
         }
         else
         {
            for each(item in farmItems)
            {
               friendlyName = item.friendlyTitle.toLowerCase();
               if(friendlyName.search(searchString) != -1)
               {
                  results.push(item);
               }
            }
         }
         return results;
      }
      
      public function inVersion3() : Boolean
      {
         return this.m_isInVersion3Experiment;
      }
      
      public function inBuyBackExperiment() : Boolean
      {
         return this.m_isInBuyBackExperiment;
      }
      
      private function isregionExcludeMarketPreq(marketPrereqName:String) : Boolean
      {
         var prereqs:Array = null;
         var prereq:String = null;
         var result:Boolean = false;
         if(marketPrereqName != null)
         {
            if(marketPrereqName.indexOf(",") != -1)
            {
               prereqs = marketPrereqName.split(",");
               for each(prereq in prereqs)
               {
                  if(this.m_regionExcludeMarketPreq.indexOf(prereq) != -1)
                  {
                     result = true;
                     break;
                  }
               }
            }
            else if(this.m_regionExcludeMarketPreq.indexOf(marketPrereqName) != -1)
            {
               result = true;
            }
         }
         return result;
      }
   }
}

