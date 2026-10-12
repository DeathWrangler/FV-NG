package Classes.Idle.Quest
{
   import Classes.Idle.BaseIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Display.QueuedIcons.QuestQueuedIcon;
   
   public class NewIndicatorIdleTask extends BaseIdleTask
   {
      
      private var m_possibleQuests:Vector.<FarmQuest> = null;
      
      private var m_arrowAddedTimeStamp:Number = 0;
      
      public function NewIndicatorIdleTask(params:Object = null)
      {
         super();
         this.m_possibleQuests = new Vector.<FarmQuest>();
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return Global.farmGameSettingsManager.getInt("minMouseIdleMilliseconds",35000);
      }
      
      override public function get canFire() : Boolean
      {
         var hasMadeProgressOnQuest:Boolean = false;
         var quest:FarmQuest = null;
         var result:Boolean = false;
         if(GlobalEngine.currentTime >= this.m_arrowAddedTimeStamp + this.minMouseIdleMilliseconds)
         {
            hasMadeProgressOnQuest = false;
            for each(quest in FarmQuestManager.getInstance().getActiveQuests())
            {
               hasMadeProgressOnQuest = quest.progress > 0;
               if(quest.isNew || hasMadeProgressOnQuest == true)
               {
                  this.m_possibleQuests.push(quest);
               }
            }
            if(this.m_possibleQuests.length > 0)
            {
               this.m_arrowAddedTimeStamp = GlobalEngine.currentTime;
               result = true;
            }
         }
         return result;
      }
      
      override public function fire() : void
      {
         var randomIndex:int = Math.floor(Math.random() * this.m_possibleQuests.length);
         var quest:FarmQuest = this.m_possibleQuests[randomIndex];
         var icon:QuestQueuedIcon = Global.hud.iconQueue.getIconByName(quest.name) as QuestQueuedIcon;
         if(icon != null)
         {
            icon.conditionallyAttachArrow();
         }
         IdleTaskQueue.getInstance().addTask(this);
      }
   }
}

