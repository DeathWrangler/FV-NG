package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildMemberSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildMembersFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private var m_otherGuildView:Boolean = false;
      
      public function GuildMembersFrame(element:DisplayObject, featureName:String, otherGuild:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_otherGuildView = otherGuild;
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
         if(this.m_otherGuildView == false)
         {
            m_slotData = GuildManager.getInstance().getGuildMembersData();
         }
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildMemberSlot(slotElement,this.m_featureName,this.m_otherGuildView);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "member";
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
         if(!this.m_otherGuildView)
         {
            this.setupData();
         }
         super.refresh();
      }
   }
}

