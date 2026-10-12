package ZQuest.Classes
{
   import ZQuest.Managers.QuestManager;
   
   public class QuestComponentOptions
   {
      
      public var questClass:Class = Quest;
      
      public var questManager:Class = QuestManager;
      
      public var questUtility:Class = null;
      
      public function QuestComponentOptions()
      {
         super();
      }
   }
}

