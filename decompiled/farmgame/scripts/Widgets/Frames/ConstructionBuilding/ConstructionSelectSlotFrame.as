package Widgets.Frames.ConstructionBuilding
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.ConstructionBuilding.ConstructionSelectSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ConstructionSelectSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_addItemCallback:Function;
      
      private var m_mainWindow:FarmWindow;
      
      public function ConstructionSelectSlotFrame(element:DisplayObject, buildingData:Array, addItemCallback:Function, mainWindow:FarmWindow)
      {
         this.m_mainWindow = mainWindow;
         this.m_addItemCallback = addItemCallback;
         super(element);
         var leftArrow:ZwButton = new ZwButton(m_element.backArrow_bt,m_pagingComponent.onPageBack);
         var rightArrow:ZwButton = new ZwButton(m_element.nextArrow_bt,m_pagingComponent.onPageForward);
         addWidget(leftArrow);
         addWidget(rightArrow);
         m_slotData = buildingData;
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ConstructionSelectSlot(slotElement,this.m_addItemCallback,this.m_mainWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         var leftArrow:ZwButton = null;
         var rightArrow:ZwButton = null;
         super.refresh();
         if(m_slotData.length <= m_slots.length)
         {
            leftArrow = getWidget(m_element.backArrow_bt) as ZwButton;
            rightArrow = getWidget(m_element.nextArrow_bt) as ZwButton;
            leftArrow.visible = false;
            rightArrow.visible = false;
         }
      }
   }
}

