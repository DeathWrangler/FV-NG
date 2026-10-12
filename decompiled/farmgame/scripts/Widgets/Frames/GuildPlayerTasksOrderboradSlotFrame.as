package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.GuildEventManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GuildPlayerTasksOrderboradSlot;
   import Widgets.Windows.GuildEventMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildPlayerTasksOrderboradSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      public var m_parentWindow:GuildEventMainWindow;
      
      private var m_orderCounter_tf:ZwTextField;
      
      private var m_view_bt:FarmAnimatedTextButton;
      
      public function GuildPlayerTasksOrderboradSlotFrame(element:DisplayObject, featureName:String, window:GuildEventMainWindow)
      {
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
         if(m_element.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_view_bt = new FarmAnimatedTextButton(m_element["view_bt"],"Event Tasks",this.onClickViewButton));
            this.m_view_bt.visible = this.eventManager.allSlotsFull();
         }
         this.m_orderCounter_tf = new ZwTextField(m_element["order_counter_tf"],"Tasks Completed:\n" + this.eventManager.getNoOfTasksDone().toString());
         this.m_orderCounter_tf.visible = true;
         this.refresh();
      }
      
      private function onClickViewButton(e:Event) : void
      {
         GuildEventManager.getInstance().openOrderboardSelectionUI(4);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = GuildEventManager.getInstance(this.m_featureName).getActiveTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = GuildEventManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = GuildEventManager.getInstance().isTaskRedeemable(i);
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue,
               "progress":progress,
               "completed":completedTask
            });
         }
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildPlayerTasksOrderboradSlot(this.m_featureName,slotElement,this.m_parentWindow);
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
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      public function updateNoOfUserTasks() : void
      {
         if(this.m_orderCounter_tf)
         {
            this.m_orderCounter_tf.text = "Tasks Completed:\n" + this.eventManager.getNoOfTasksDone().toString();
            this.m_orderCounter_tf.visible = true;
         }
         if(!Global.player.getSeenFlag(GuildEventMainWindow.GUILD_FIRST_ORDER_SEEN_FLAG))
         {
            this.m_parentWindow.showAutoHideBottomNPCCallouts();
            Global.player.setSeenFlag(GuildEventMainWindow.GUILD_FIRST_ORDER_SEEN_FLAG);
         }
      }
      
      public function updateViewButton() : void
      {
         if(this.m_view_bt)
         {
            this.m_view_bt.visible = this.eventManager.allSlotsFull();
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         this.updateViewButton();
         if(this.eventManager.allSlotsFull())
         {
            if(!Global.player.getSeenFlag(GuildEventMainWindow.GUILD_EVENT_ALL_SLOT_FULL_FLAG))
            {
               Global.player.setSeenFlag(GuildEventMainWindow.GUILD_EVENT_ALL_SLOT_FULL_FLAG);
               if(this.m_parentWindow.m_tutorial1Mc)
               {
                  this.m_parentWindow.m_tutorial1Mc.visible = true;
               }
            }
         }
         super.refresh();
      }
   }
}

