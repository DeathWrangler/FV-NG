package Widgets.Frames.Orchards
{
   import Classes.OrchardBuilding;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Orchards.OrchardsSlot;
   import Widgets.Windows.Orchards.OrchardManagementWindow;
   import flash.display.DisplayObject;
   
   public class OrchardsSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:OrchardManagementWindow;
      
      private var m_orchard:OrchardBuilding;
      
      public function OrchardsSlotFrame(element:DisplayObject, orchardBuilding:OrchardBuilding, parentWindow:OrchardManagementWindow)
      {
         this.m_parentWindow = parentWindow;
         this.m_orchard = orchardBuilding;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         m_slotData = this.m_orchard.getContents();
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new OrchardsSlot(slotElement,this.m_orchard,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
         this.m_orchard = null;
      }
   }
}

