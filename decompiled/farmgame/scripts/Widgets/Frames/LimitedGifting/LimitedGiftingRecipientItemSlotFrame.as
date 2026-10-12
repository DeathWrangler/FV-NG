package Widgets.Frames.LimitedGifting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LimitedGifting.LimitedGiftingRecipientItemSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LimitedGiftingRecipientItemSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_showArrows:Boolean;
      
      private var m_refreshCallback:Function;
      
      public function LimitedGiftingRecipientItemSlotFrame(element:MovieClip, showArrows:Boolean, refreshCallback:Function)
      {
         super(element);
         if(showArrows)
         {
            this.m_refreshCallback = refreshCallback;
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,this.pageBack);
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,this.pageForward);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LimitedGiftingRecipientItemSlot(slotElement);
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
      
      override public function release() : void
      {
         m_pageBackWidget = null;
         m_pageForwardWidget = null;
         super.release();
      }
   }
}

