package Widgets.Frames.Crafting
{
   import Managers.Crafting.CraftingConstants;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.ReportSlot;
   import flash.display.DisplayObject;
   
   public class ReportSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      public function ReportSlotFrame(element:DisplayObject, items:Array)
      {
         this.m_items = items;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.arrowButtonUp_mc,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.arrowButtonDown_mc,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      public function setFilteredItems(items:Array, filter:String) : void
      {
         var item:Object = null;
         var i:int = 0;
         this.m_items = [];
         for each(item in items)
         {
            switch(filter)
            {
               case "all":
                  this.m_items.unshift(item);
                  break;
               case "levelups":
                  if(item[CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_RECIPE_LVL)
                  {
                     this.m_items.unshift(item);
                  }
                  break;
               case "recipes":
                  if(item[CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_SOLD)
                  {
                     this.m_items.unshift(item);
                  }
            }
         }
         i = this.m_items.length % 3;
         if(!(i == 0 && this.m_items.length > 2))
         {
            while(i < 3)
            {
               this.m_items.push({});
               i++;
            }
         }
         this.m_pagingComponent.currentPageNumber = 0;
         this.setupData();
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ReportSlot(slotElement);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
   }
}

