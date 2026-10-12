package Widgets.Frames.Crafting
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingGetGoodsSlot;
   import Widgets.Windows.Crafting.CraftingGetGoodsWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CraftingGetGoodsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_craftingGetGoodsWindow:CraftingGetGoodsWindow = null;
      
      private var m_sortHighestLevelButton:FarmAnimatedTextButton;
      
      private var m_sortLowestLevelButton:FarmAnimatedTextButton;
      
      public var m_sortOrderLowestFirst:Boolean = true;
      
      public function CraftingGetGoodsSlotFrame(element:DisplayObject, items:Array, craftingGetGoodsWindow:CraftingGetGoodsWindow)
      {
         this.m_items = items;
         this.m_craftingGetGoodsWindow = craftingGetGoodsWindow;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwButton;
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         if(m_element.highestLvl_bt)
         {
            this.m_sortHighestLevelButton = addWidget(new FarmAnimatedTextButton(m_element.highestLvl_bt,"Highest Level",this.onSortButtonClicked)) as FarmAnimatedTextButton;
            this.m_sortHighestLevelButton.visible = true;
         }
         if(m_element.lowestLvl_bt)
         {
            this.m_sortLowestLevelButton = addWidget(new FarmAnimatedTextButton(m_element.lowestLvl_bt,"Lowest Level",this.onSortButtonClicked)) as FarmAnimatedTextButton;
         }
         adjustPagingWidgetVisibility();
      }
      
      public function onSortButtonClicked(event:Event) : void
      {
         this.m_sortOrderLowestFirst = !this.m_sortOrderLowestFirst;
         this.m_sortHighestLevelButton.visible = this.m_sortOrderLowestFirst;
         this.m_sortLowestLevelButton.visible = !this.m_sortOrderLowestFirst;
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingGetGoodsSlot(slotElement,this,this.m_craftingGetGoodsWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_craftingGetGoodsWindow = null;
      }
      
      public function enterFrame() : void
      {
         var slot:CraftingGetGoodsSlot = null;
         for each(slot in m_slots)
         {
            slot.enterFrame();
         }
      }
      
      public function refreshSlotData(items:Array) : void
      {
         m_slotData = this.m_items = items;
         refresh();
      }
   }
}

