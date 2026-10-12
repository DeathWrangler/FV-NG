package Widgets.Frames.LimitedGifting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.RecentlyPlayedFriendsGiftSlotFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LimitedGiftingSlotFrame extends RecentlyPlayedFriendsGiftSlotFrame
   {
      
      private var m_showArrows:Boolean;
      
      private var m_refreshCallback:Function;
      
      public function LimitedGiftingSlotFrame(element:MovieClip, clickCallback:Function, showArrows:Boolean, refreshCallback:Function)
      {
         super(element,clickCallback);
         if(showArrows)
         {
            this.m_refreshCallback = refreshCallback;
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,this.pageBack);
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,this.pageForward);
         }
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
   }
}

