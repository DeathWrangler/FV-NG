package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GuildListSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildListFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      public function GuildListFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element[this.BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[this.BACK_BT],this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[this.NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[this.NEXT_BT],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(m_element["page_tf"])
         {
            m_currentPageLabel = new ZwTextField(m_element["page_tf"],"Page \n1 of " + (m_pagingComponent.maxPageNumber + 1).toString());
            addWidget(m_currentPageLabel);
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getGuildListData();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildListSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "coop";
      }
      
      private function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      private function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         m_currentPageLabel.text = "Page \n" + (m_pagingComponent.currentPageNumber + 1).toString() + " of " + (m_pagingComponent.maxPageNumber + 1).toString();
      }
   }
}

