package Widgets.Frames.CreditsBuilding
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PresentsSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_openPresentCallback:Function;
      
      private var m_featureName:String;
      
      public function PresentsSlotFrame(element:MovieClip, openPresentCallback:Function, featureName:String = null)
      {
         var rightArrow:ZwButton = null;
         this.m_openPresentCallback = openPresentCallback;
         this.m_featureName = featureName;
         super(element);
         var leftArrow:ZwButton = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
         rightArrow = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
         addWidget(leftArrow);
         addWidget(rightArrow);
         m_pageBackWidget = leftArrow;
         m_pageForwardWidget = rightArrow;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PresentsSlot(slotElement,this.m_openPresentCallback,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         this.m_openPresentCallback = null;
         super.release();
      }
   }
}

