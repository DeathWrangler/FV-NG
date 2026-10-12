package Widgets.Frames.CreditsBuilding
{
   import Classes.RewardCreditsBuilding;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ProgressSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_redeemItemCallback:Function;
      
      private var m_featureName:String;
      
      private var m_singleClickCallback:Function;
      
      private var m_building:RewardCreditsBuilding;
      
      private var m_window:RewardCreditsWindow;
      
      public function ProgressSlotFrame(element:MovieClip, redeemItemCallback:Function, building:RewardCreditsBuilding, window:RewardCreditsWindow, setupCreditsText:Function = null, featureName:String = null, singleClickCallback:Function = null)
      {
         var leftArrow:ZwButton = null;
         var rightArrow:ZwButton = null;
         this.m_redeemItemCallback = redeemItemCallback;
         this.m_building = building;
         this.m_window = window;
         this.m_featureName = featureName;
         this.m_singleClickCallback = singleClickCallback;
         super(element);
         if(null != setupCreditsText)
         {
            setupCreditsText(this);
         }
         if(Boolean(m_element.leftArrow_bt) && Boolean(m_element.rightArrow_bt))
         {
            leftArrow = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            rightArrow = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(leftArrow);
            addWidget(rightArrow);
            m_pageBackWidget = leftArrow;
            m_pageForwardWidget = rightArrow;
         }
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         if(this.hasObjectPreviewFrame())
         {
            return new ProgressPreviewSlot(slotElement,this.m_redeemItemCallback,this.m_building,this.m_window,this.m_featureName,this.m_singleClickCallback);
         }
         return new ProgressSlot(slotElement,this.m_redeemItemCallback,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         this.m_redeemItemCallback = null;
         super.release();
      }
      
      protected function hasObjectPreviewFrame() : Boolean
      {
         var result:Boolean = false;
         var data:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_featureName);
         if(data.@objectPreviewFrame.toString() == "true")
         {
            result = true;
         }
         return result;
      }
   }
}

