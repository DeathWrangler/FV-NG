package ZQuest.Events
{
   import ZQuest.Classes.Quest;
   import flash.events.Event;
   
   public class QuestEvent extends Event
   {
      
      public static const COMPLETED:String = "quest_completed";
      
      public static const EXPIRED:String = "quest_expired";
      
      public static const PROGRESS:String = "quest_progress";
      
      private var m_quest:Quest = null;
      
      private var m_taskCompleted:int = -1;
      
      public function QuestEvent(param1:String, param2:Quest = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.m_quest = param2;
      }
      
      public function get quest() : Quest
      {
         return this.m_quest;
      }
      
      public function set taskCompleted(param1:int) : void
      {
         this.m_taskCompleted = param1;
      }
      
      public function get taskCompleted() : int
      {
         return this.m_taskCompleted;
      }
   }
}

