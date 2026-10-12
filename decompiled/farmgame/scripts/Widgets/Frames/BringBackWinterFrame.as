package Widgets.Frames
{
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BringBackWinterSlot;
   import Widgets.Windows.BBWinterReskinnableWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BringBackWinterFrame extends FarmSlotContainerFrame
   {
      
      protected var m_featureName:String = null;
      
      private var m_owner:DisplayObject;
      
      protected var m_window:BBWinterReskinnableWindow;
      
      private var slot_mc:MovieClip;
      
      public function BringBackWinterFrame(element:DisplayObject, featureName:String, parentWindow:BBWinterReskinnableWindow)
      {
         this.m_featureName = featureName;
         this.m_window = parentWindow;
         super(element);
         m_pagingComponent.maxPageNumber = 1;
         if(m_element.back_bt != null)
         {
            m_pageBackWidget = new FarmAnimatedButton(m_element.back_bt,this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.next_bt != null)
         {
            m_pageForwardWidget = new FarmAnimatedButton(m_element.next_bt,this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      protected function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         m_pageForwardWidget.visible = true;
         if(m_pagingComponent.currentPageNumber == 0)
         {
            m_pageBackWidget.visible = false;
         }
      }
      
      protected function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
         m_pageBackWidget.visible = true;
         if(m_pagingComponent.currentPageNumber == m_pagingComponent.maxPageNumber)
         {
            m_pageForwardWidget.visible = false;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BringBackWinterSlot(slotElement,this.m_featureName,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var slotData:Array = BringBackWinterManager.getInstance(this.m_featureName).getRewardPkgs();
         for(var i:int = 0; i < slotData.length; i++)
         {
            slotData[i].index = i + 1;
         }
         m_slotData = slotData;
      }
      
      public function refreshSlots() : void
      {
         var slot:BringBackWinterSlot = null;
         for each(slot in m_slots)
         {
            slot.refreshSlot();
         }
      }
   }
}

