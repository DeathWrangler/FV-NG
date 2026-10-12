package Widgets.Frames.Breeding
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Breeding.AnimalBreedingContentsSlot;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   
   public class AnimalBreedingContentsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_mainWindow:BaseContentsWindow = null;
      
      protected var m_animals:Array = new Array();
      
      protected var m_page:ZwTextField;
      
      protected var m_spellButton:ZwButton = null;
      
      private var m_buildingConfig:XML = null;
      
      private var m_classCompiling:Array = [DragonBreedingContentsSlotFrame];
      
      public function AnimalBreedingContentsSlotFrame(element:DisplayObject, animals:Array, mainWindow:BaseContentsWindow, buildingConfig:XML = null)
      {
         this.m_mainWindow = mainWindow;
         this.m_animals = animals;
         this.m_buildingConfig = buildingConfig;
         super(element);
         if(m_element.leftArrow_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(m_element.page_tf != null)
         {
            this.m_page = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         }
         this.refresh();
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         if(this.m_page != null)
         {
            this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
               "current":m_pagingComponent.currentPageNumber + 1,
               "total":m_pagingComponent.maxPageNumber + 1
            });
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 0;
         while(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()])
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var animalSlotFrameClass:Class = null;
         var animalSlot:* = null;
         if(this.m_buildingConfig.hasOwnProperty("animalSlot"))
         {
            animalSlotFrameClass = getDefinitionByName(this.m_buildingConfig["animalSlot"]) as Class;
            animalSlot = new animalSlotFrameClass(slotElement,this.m_mainWindow,this.m_buildingConfig);
         }
         else
         {
            animalSlot = new AnimalBreedingContentsSlot(slotElement,this.m_mainWindow,this.m_buildingConfig);
         }
         return animalSlot;
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_animals;
      }
   }
}

