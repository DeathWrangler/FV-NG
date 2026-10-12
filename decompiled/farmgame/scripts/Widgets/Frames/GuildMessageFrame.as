package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildMessageSlot;
   import Widgets.Windows.GuildMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildMessageFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "next_bt";
      
      private const NEXT_BT:String = "back_bt";
      
      private var m_parentWindow:GuildMainWindow;
      
      private var m_slotPrefix:String;
      
      public function GuildMessageFrame(element:DisplayObject, featureName:String, slotPrefix:String, window:GuildMainWindow = null)
      {
         this.m_featureName = featureName;
         this.m_slotPrefix = slotPrefix;
         this.m_parentWindow = window;
         super(element);
         if(this.m_slotPrefix == "feed")
         {
            if(m_element[this.NEXT_BT] != null)
            {
               m_pageBackWidget = new ZwButton(m_element[this.NEXT_BT],this.onPageBack);
               addWidget(m_pageBackWidget);
               if(m_pagingComponent.currentPageNumber == 0)
               {
                  m_pageBackWidget.visible = false;
               }
            }
            if(m_element[this.BACK_BT] != null)
            {
               m_pageForwardWidget = new ZwButton(m_element[this.BACK_BT],this.onPageForward);
               addWidget(m_pageForwardWidget);
            }
         }
         else
         {
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
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         if(this.m_slotPrefix == "feed")
         {
            if(!Global.player.getSeenFlag(GuildManager.COMPLETED_NOTIFICATION_LOADING))
            {
               this.m_parentWindow.showMessageLoader();
            }
            else
            {
               this.m_parentWindow.hideMessageLoader();
            }
            m_slotData = GuildManager.getInstance().getNotificationMessages();
         }
         else
         {
            m_slotData = GuildManager.getInstance().getChatMessages();
            if(!Global.player.getSeenFlag(GuildManager.COMPLETED_CHAT_HISTORY_LOADING))
            {
               this.m_parentWindow.showMessageLoader();
            }
            else
            {
               this.m_parentWindow.hideMessageLoader();
            }
         }
         if(m_slotData.length > 0)
         {
            this.m_parentWindow.hideMessageLoader();
         }
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
         if(m_slotData.length > 0)
         {
            this.m_parentWindow.hideMessageLoader();
         }
         if(Global.player.getSeenFlag(GuildManager.COMPLETED_NOTIFICATION_LOADING))
         {
            this.m_parentWindow.hideMessageLoader();
         }
         if(Global.player.getSeenFlag(GuildManager.COMPLETED_CHAT_HISTORY_LOADING))
         {
            this.m_parentWindow.hideMessageLoader();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildMessageSlot(slotElement,this.m_featureName,this.m_slotPrefix);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
      
      public function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      public function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
      
      override public function refresh() : void
      {
         if(this.m_slotPrefix == "feed")
         {
            if(!Global.player.getSeenFlag(GuildManager.COMPLETED_NOTIFICATION_LOADING))
            {
               this.m_parentWindow.showMessageLoader();
            }
            else
            {
               this.m_parentWindow.hideMessageLoader();
            }
         }
         else if(!Global.player.getSeenFlag(GuildManager.COMPLETED_CHAT_HISTORY_LOADING))
         {
            this.m_parentWindow.showMessageLoader();
         }
         else
         {
            this.m_parentWindow.hideMessageLoader();
         }
         if(m_slotData.length > 0)
         {
            this.m_parentWindow.hideMessageLoader();
         }
         super.refresh();
      }
   }
}

