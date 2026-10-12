package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildKeyRequestSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildKeyRequestFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      public function GuildKeyRequestFrame(element:DisplayObject, featureName:String)
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
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getKeyRequestData();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildKeyRequestSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "request";
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
         clearSlots();
         if(GuildManager.getInstance().getKeyRequestData().length > 0)
         {
            this.setupSlotData(GuildManager.getInstance().getKeyRequestData());
            m_pagingComponent.maxPageNumber = calcMaxPageNumber();
            populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
            adjustPagingWidgetVisibility();
         }
         else
         {
            GuildManager.getInstance().m_guildMainWindow.m_requestFrameDefault_tf.visible = true;
            m_element.visible = false;
         }
      }
   }
}

