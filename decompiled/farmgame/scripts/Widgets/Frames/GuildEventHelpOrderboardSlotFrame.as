package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.GuildEventManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildEventHelpTasksSelectSlot;
   import Widgets.Windows.GuildEventMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildEventHelpOrderboardSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private var m_parentWindow:GuildEventMainWindow;
      
      public function GuildEventHelpOrderboardSlotFrame(element:DisplayObject, featureName:String, window:GuildEventMainWindow)
      {
         var questTasks1:Vector.<FarmTask> = null;
         this.m_featureName = featureName;
         this.m_parentWindow = window;
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
         questTasks1 = GuildEventManager.getInstance(this.m_featureName).getHelpTaskList();
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         m_slotData = [];
         questTasks1 = GuildEventManager.getInstance(this.m_featureName).getHelpTaskList();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue,
               "extraData":questTasks1[i].extraData
            });
         }
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildEventHelpTasksSelectSlot(this.m_featureName,slotElement,this.m_parentWindow);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
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
         this.setupData();
         super.refresh();
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
   }
}

