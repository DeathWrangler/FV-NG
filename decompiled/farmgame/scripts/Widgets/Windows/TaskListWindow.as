package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TaskListManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.TaskList.TaskListSlotFrame;
   import flash.events.Event;
   
   public final class TaskListWindow extends FarmWindow
   {
      
      public static const WINDOW_NAME:String = "gildaTaskListWindow";
      
      private static const ASSET_SWF:String = "assets/dialogs/FV_GildasList.swf";
      
      private var m_bodyText:ZwTextField = null;
      
      private var m_taskSlots:TaskListSlotFrame = null;
      
      private var m_whatIsThisButton:FarmButton = null;
      
      private var m_whatIsThis:ZwFrame = null;
      
      private var m_taskData:Array = null;
      
      private var m_numTasksCompleted:int = 0;
      
      private var m_showTutorial:Boolean;
      
      public function TaskListWindow(showTutorial:Boolean = false)
      {
         super(ASSET_SWF,true,true);
         this.m_showTutorial = showTutorial;
         TaskListManager.getInstance().windowOpen = true;
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_taskData = TaskListManager.getInstance().getCurrentTasks();
         this.m_taskSlots = new TaskListSlotFrame(m_window,this.m_taskData,this);
         this.m_bodyText = addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","TaskList_windowDescription")),true) as ZwTextField;
         this.m_whatIsThisButton = addWidget(new FarmButton(m_window.whatisthis_bt,this.onWhatIsThisClick),true) as FarmButton;
         this.m_whatIsThis = addWidget(new ZwFrame(m_window.whatisthis_mc),false) as ZwFrame;
         addWidget(new FarmAnimatedTextButton(this.m_whatIsThis.element.craftNow_bt,ZLocUtils.t("Dialogs","LetsGo"),this.onWhatIsThisOKClick),true) as FarmAnimatedTextButton;
         if(this.m_showTutorial)
         {
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"view","motd");
            this.m_whatIsThis.visible = true;
         }
         else
         {
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"view");
         }
         super.postLoadComplete();
      }
      
      public function get numTasksCompleted() : int
      {
         return this.m_numTasksCompleted;
      }
      
      public function set numTasksCompleted(num:int) : void
      {
         this.m_numTasksCompleted = num;
      }
      
      public function refreshSlots(slotsData:Array) : void
      {
         this.m_taskSlots.refreshSlots(slotsData);
      }
      
      public function toggleCloseButton(enabled:Boolean) : void
      {
         m_closeButton.enabled = enabled;
         m_closeButton.applyGrayOut = !enabled;
      }
      
      override protected function onClose(event:Event) : void
      {
         TaskListManager.getInstance().windowOpen = false;
         super.onClose(event);
      }
      
      override public function close() : void
      {
         TaskListManager.getInstance().windowOpen = false;
         super.close();
      }
      
      private function onWhatIsThisClick(e:Event) : void
      {
         this.m_whatIsThis.visible = true;
      }
      
      private function onWhatIsThisOKClick(e:Event) : void
      {
         this.m_whatIsThis.visible = false;
      }
   }
}

