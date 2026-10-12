package ZQuest.Init
{
   import Engine.Init.InitializationAction;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   
   public class QuestInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "ZQuestInit";
      
      protected var m_questManager:Class;
      
      public function QuestInit(param1:Class)
      {
         super(INIT_ID);
         addDependency(QuestSettingsInit.INIT_ID);
         this.m_questManager = param1;
      }
      
      override public function execute() : void
      {
         QuestManager.getInstance(this.m_questManager).initialize();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

