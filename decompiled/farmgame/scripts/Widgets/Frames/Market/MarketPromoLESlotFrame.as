package Widgets.Frames.Market
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Market.MarketLePromoSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MarketPromoLESlotFrame extends MarketPromoSlotFrame
   {
      
      public function MarketPromoLESlotFrame(element:MovieClip, onPromoClickCallback:Function)
      {
         super(element,onPromoClickCallback);
         refresh();
      }
      
      override public function get items() : Array
      {
         return m_slotData;
      }
      
      override public function get promoClickCallback() : Function
      {
         return m_onPromoClickCallback;
      }
      
      override public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MarketLePromoSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

