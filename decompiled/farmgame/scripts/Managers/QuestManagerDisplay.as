package Managers
{
   import Display.QueuedIcons.QuestManagerQueuedIcon;
   import Display.UI;
   import Widgets.Windows.QuestManager.QuestManagerWindowV2;
   import Widgets.Windows.TaskListWindow;
   
   public class QuestManagerDisplay
   {
      
      private static var s_objInstance:QuestManagerDisplay;
      
      public static const STATS_COUNTER:String = "quest_manager";
      
      private var m_questManagerWindow:QuestManagerWindowV2 = null;
      
      public function QuestManagerDisplay(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : QuestManagerDisplay
      {
         if(s_objInstance == null)
         {
            s_objInstance = new QuestManagerDisplay(new SingletonEnforcer());
         }
         return s_objInstance;
      }
      
      public function openQuestManagerWindow(isMOTDFlow:Boolean = false) : void
      {
         this.m_questManagerWindow = new QuestManagerWindowV2(isMOTDFlow);
         UI.displayPopup(this.m_questManagerWindow,true,TaskListWindow.WINDOW_NAME,true);
      }
      
      public function refreshWindow() : void
      {
         if(this.m_questManagerWindow)
         {
            this.m_questManagerWindow.refreshWindow();
         }
      }
      
      public function releaseWindow() : void
      {
         if(this.m_questManagerWindow)
         {
            this.m_questManagerWindow = null;
         }
      }
      
      public function showHUDIcon() : void
      {
         QuestManagerQueuedIcon.showHUDIcon();
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
