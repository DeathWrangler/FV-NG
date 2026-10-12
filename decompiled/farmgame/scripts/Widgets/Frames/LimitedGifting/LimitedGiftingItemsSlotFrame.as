package Widgets.Frames.LimitedGifting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LimitedGifting.LimitedGiftingItemSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LimitedGiftingItemsSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_showArrows:Boolean;
      
      private var m_refreshCallback:Function;
      
      private var m_clickCallback:Function;
      
      public function LimitedGiftingItemsSlotFrame(element:MovieClip, clickCallback:Function, showArrows:Boolean, refreshCallback:Function)
      {
         this.m_clickCallback = clickCallback;
         super(element);
         this.m_showArrows = showArrows;
         if(showArrows)
         {
            this.m_refreshCallback = refreshCallback;
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,this.pageBack);
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,this.pageForward);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LimitedGiftingItemSlot(slotElement,this.m_clickCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      private function pageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         if(this.m_refreshCallback != null)
         {
            this.m_refreshCallback();
         }
      }
      
      private function pageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
         if(this.m_refreshCallback != null)
         {
            this.m_refreshCallback();
         }
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      public function setNumberOfSelected(indexesToSelect:Array) : void
      {
         var num:int = 0;
         for each(num in indexesToSelect)
         {
            m_slots[num].selected = true;
         }
      }
   }
}

