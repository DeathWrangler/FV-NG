package Widgets.Frames
{
   import Classes.FeatureBuilding;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GenericExpandSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class BuildingDialogSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "giftPanel";
      
      protected static const SLOT_POSTFIX:String = "";
      
      protected var m_mainWindow:FarmWindow = null;
      
      protected var m_data:Array = new Array();
      
      protected var m_page:ZwTextField;
      
      protected var m_building:FeatureBuilding;
      
      public function BuildingDialogSlotFrame(element:DisplayObject, data:Array, mainWindow:FarmWindow, building:FeatureBuilding)
      {
         this.m_mainWindow = mainWindow;
         this.m_data = data;
         this.m_building = building;
         super(element);
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
         if(m_element.page_tf)
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
      }
      
      override protected function getSlotPrefix() : String
      {
         return "giftPanel";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 1;
         while(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()] != null)
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GenericExpandSlot(slotElement,this.m_mainWindow,this.m_building,this.m_building.expand,this.m_building.expand.frictionless);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_data;
      }
   }
}

