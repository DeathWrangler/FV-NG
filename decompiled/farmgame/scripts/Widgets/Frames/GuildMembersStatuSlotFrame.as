package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildMembersStatuSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildMembersStatuSlotFrame extends FarmSlotContainerFrame
   {
      
      private static const BACK_BT:String = "back_bt";
      
      private static const NEXT_BT:String = "next_bt";
      
      private var m_featureName:String = null;
      
      public function GuildMembersStatuSlotFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element[BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[BACK_BT],this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[NEXT_BT],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getGuildMembersStatus();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildMembersStatuSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "status";
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
         this.setupData();
         super.refresh();
      }
   }
}

