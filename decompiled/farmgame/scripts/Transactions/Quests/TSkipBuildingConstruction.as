package Transactions.Quests
{
   import Classes.ConstructionBuilding;
   import Classes.ItemInstance;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import ZQuest.Init.QuestSettingsInit;
   import flash.utils.getDefinitionByName;
   
   public class TSkipBuildingConstruction extends TSkipQuestTask
   {
      
      public function TSkipBuildingConstruction(questName:String, taskIndex:int)
      {
         super(questName,taskIndex);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.skipConstructionBuildingTask",m_questName,m_taskIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var quest:FarmQuest = null;
         var task:FarmTask = null;
         var objectsInWorld:Array = null;
         var item:ItemInstance = null;
         super.onComplete(result);
         if(result != null)
         {
            quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(m_questName) as FarmQuest;
            task = quest.farmTasks[m_taskIndex];
            objectsInWorld = new Array();
            switch(task.targetType)
            {
               case "code":
                  objectsInWorld = Global.world.getObjectsByName(Global.farmGameSettingsManager.getFarmItemByCode(task.type).name);
                  break;
               case "category":
                  break;
               case "class":
                  objectsInWorld = Global.world.getObjectsByClass(getDefinitionByName("Classes." + task.type) as Class);
            }
            for each(item in objectsInWorld)
            {
               if(item is ConstructionBuilding)
               {
                  (item as ConstructionBuilding).transformBuilding();
               }
            }
         }
      }
   }
}

