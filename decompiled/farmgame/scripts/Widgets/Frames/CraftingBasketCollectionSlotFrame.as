package Widgets.Frames
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CraftingBasket.CraftingBasketCollectionSlot;
   import flash.display.DisplayObject;
   
   public class CraftingBasketCollectionSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_callBacks:Object;
      
      public function CraftingBasketCollectionSlotFrame(element:DisplayObject, featureName:String, callBacks:Object)
      {
         this.m_featureName = featureName;
         this.m_callBacks = callBacks;
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingBasketCollectionSlot(slotElement,this.m_featureName,this.m_callBacks);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

