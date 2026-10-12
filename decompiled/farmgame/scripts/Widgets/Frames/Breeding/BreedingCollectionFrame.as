package Widgets.Frames.Breeding
{
   import Classes.Collections.AnimalBreedingCollection;
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Managers.CollectionsManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Breeding.BreedingCollectionSlot;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   
   public class BreedingCollectionFrame extends FarmSlotContainerFrame
   {
      
      public static const COLLECTION_PATTERN_INDEX:int = 0;
      
      public static const COLLECTION_COLOR_INDEX:int = 1;
      
      private var m_parentWindow:BreedingWindow = null;
      
      private var m_loadingOverlay:ZwBaseWidget;
      
      protected var m_page:ZwTextField;
      
      private var m_collections:Vector.<AnimalBreedingCollection>;
      
      private var m_topLevelMenu:Dictionary;
      
      private var m_activeCollection:AnimalBreedingCollection;
      
      private var m_featureName:String;
      
      private var m_colorPickerFrame:BreedingCollectionColorsFrame;
      
      private var m_collectionPreviewFrame:BreedingCollectionPreviewFrame;
      
      public function BreedingCollectionFrame(element:DisplayObject, parentWindow:BreedingWindow, featureName:String = null)
      {
         var animalCollection:AnimalBreedingCollection = null;
         var nameTokens:Array = null;
         var colors:Array = null;
         var colorName:String = null;
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_featureName = featureName != null ? featureName : parentWindow.getFeatureName();
         addWidget(this.m_loadingOverlay = new ZwBaseWidget(m_element.loading_mc),false);
         this.m_collections = new Vector.<AnimalBreedingCollection>();
         this.m_topLevelMenu = new Dictionary();
         var collections:XMLList = CollectionsManager.getInstance().getAllCollectionXMLByType(Collection.TYPE_ANIMAL_BREEDING);
         var collectionPatterns:Array = new Array();
         for(var i:int = 0; i < collections.length(); i++)
         {
            animalCollection = new AnimalBreedingCollection(collections[i]);
            if(animalCollection.featureName == this.m_featureName)
            {
               this.m_collections.push(animalCollection);
               nameTokens = animalCollection.name.split("_");
               if(this.m_topLevelMenu.hasOwnProperty(nameTokens[COLLECTION_PATTERN_INDEX]))
               {
                  colors = this.m_topLevelMenu[nameTokens[COLLECTION_PATTERN_INDEX]] as Array;
                  colorName = nameTokens[COLLECTION_COLOR_INDEX];
                  if(colors.indexOf(colorName) == -1 && nameTokens[COLLECTION_COLOR_INDEX] != null)
                  {
                     colors.push({
                        "colorName":colorName,
                        "animalCollection":animalCollection
                     });
                  }
               }
               else
               {
                  collectionPatterns.push(nameTokens[COLLECTION_PATTERN_INDEX]);
                  this.m_topLevelMenu[nameTokens[COLLECTION_PATTERN_INDEX]] = new Array();
                  if(nameTokens[COLLECTION_COLOR_INDEX] != null)
                  {
                     (this.m_topLevelMenu[nameTokens[COLLECTION_PATTERN_INDEX]] as Array).push({
                        "colorName":nameTokens[COLLECTION_COLOR_INDEX],
                        "animalCollection":animalCollection
                     });
                  }
               }
            }
         }
         addWidget(this.m_colorPickerFrame = new BreedingCollectionColorsFrame(m_element.colorSlots_mc,this));
         addWidget(this.m_collectionPreviewFrame = new BreedingCollectionPreviewFrame(m_element.collectionPreview_mc,this));
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(m_element.page_tf != null)
         {
            this.m_page = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         }
         if(this.m_collections.length > 0)
         {
            this.m_activeCollection = this.m_collections[0];
            this.m_collectionPreviewFrame.collection = this.m_activeCollection;
            this.m_colorPickerFrame.colors = this.m_topLevelMenu[collectionPatterns[0]];
         }
         this.styles = collectionPatterns;
      }
      
      override public function refresh() : void
      {
         super.refresh();
         adjustPagingWidgetVisibility();
         this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
      }
      
      public function get activeCollection() : AnimalBreedingCollection
      {
         return this.m_activeCollection;
      }
      
      public function set activeCollection(activeCollection:AnimalBreedingCollection) : void
      {
         var nameTokens:Array = null;
         this.m_activeCollection = activeCollection;
         if(this.m_page != null)
         {
            this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
               "current":m_pagingComponent.currentPageNumber + 1,
               "total":m_pagingComponent.maxPageNumber + 1
            });
         }
         if(this.m_topLevelMenu[activeCollection.name] != null)
         {
            this.m_colorPickerFrame.visible = false;
         }
         else
         {
            nameTokens = activeCollection.name.split("_");
            if(this.m_topLevelMenu[nameTokens[COLLECTION_PATTERN_INDEX]] != null)
            {
               this.m_colorPickerFrame.visible = true;
               this.m_colorPickerFrame.colors = this.m_topLevelMenu[nameTokens[COLLECTION_PATTERN_INDEX]];
            }
         }
         this.m_collectionPreviewFrame.collection = this.m_activeCollection;
      }
      
      public function setActiveCollectionByName(activeCollectionName:String) : void
      {
         var i:int = 0;
         var refreshContents:Boolean = false;
         if(this.m_topLevelMenu[activeCollectionName] != null)
         {
            if((this.m_topLevelMenu[activeCollectionName] as Array).length > 0)
            {
               this.m_activeCollection = this.m_topLevelMenu[activeCollectionName][0].animalCollection;
               this.m_colorPickerFrame.visible = true;
               this.m_colorPickerFrame.colors = this.m_topLevelMenu[activeCollectionName];
            }
            else
            {
               this.m_colorPickerFrame.visible = false;
               for(i = 0; i < this.m_collections.length; i++)
               {
                  if(this.m_collections[i].name == activeCollectionName)
                  {
                     this.m_activeCollection = this.m_collections[i];
                     break;
                  }
               }
            }
            this.m_collectionPreviewFrame.collection = this.m_activeCollection;
         }
         this.refresh();
      }
      
      public function getFeatureName() : String
      {
         return this.m_parentWindow.getFeatureName();
      }
      
      public function get parentWindow() : BreedingWindow
      {
         return this.m_parentWindow;
      }
      
      public function showLoadingOverlay() : void
      {
         (this.m_loadingOverlay.element as MovieClip).gotoAndPlay(0);
         this.m_loadingOverlay.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BreedingCollectionSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set styles(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "btn_Pattern";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
   }
}

