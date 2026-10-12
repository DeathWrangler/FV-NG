package Widgets.Frames.Crafting
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.ShoppingListGetBushelSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ShoppingListGetBushelSlotFrame extends FarmSlotContainerFrame
   {
      
      private static var m_emptySlotNames:Array = ["slotEmpty_0_mc","slotEmpty_1_mc","slotEmpty_2_mc","slotEmpty_3_mc"];
      
      private var m_friendsWithBushels:Array;
      
      private var m_getItemCallback:Function;
      
      public function ShoppingListGetBushelSlotFrame(element:MovieClip, getItemCallback:Function)
      {
         var name:String = null;
         this.m_friendsWithBushels = [];
         this.m_getItemCallback = getItemCallback;
         super(element);
         for each(name in m_emptySlotNames)
         {
            addWidget(new ZwWidget(m_element[name]));
         }
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwButton;
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_friendsWithBushels;
      }
      
      public function updateItems(items:Array) : void
      {
         this.m_friendsWithBushels = items;
         this.setupData();
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ShoppingListGetBushelSlot(slotElement,this.m_getItemCallback);
      }
      
      override public function refresh() : void
      {
         var bushelSlot:ShoppingListGetBushelSlot = null;
         var emptySlot:ZwWidget = null;
         super.refresh();
         for(var i:int = 0; i < m_slots.length; i++)
         {
            bushelSlot = m_slots[i] as ShoppingListGetBushelSlot;
            emptySlot = getWidget(m_element[m_emptySlotNames[i]]) as ZwWidget;
            emptySlot.visible = !bushelSlot.visible;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_friendsWithBushels = null;
         this.m_getItemCallback = null;
      }
   }
}

