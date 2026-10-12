package Transactions.Quests
{
   import Classes.ItemInstance;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.StorageBuilding;
   import ZQuest.Init.QuestSettingsInit;
   
   public class TSkipExpandStorageBuilding extends TSkipQuestTask
   {
      
      private var m_storageBuilding:StorageBuilding = null;
      
      public function TSkipExpandStorageBuilding(questName:String, taskIndex:int, storageBuildingName:String)
      {
         var item:ItemInstance = null;
         super(questName,taskIndex);
         var objectsInWorld:Array = Global.world.getObjectsByName(storageBuildingName);
         for each(item in objectsInWorld)
         {
            if(item is StorageBuilding)
            {
               this.m_storageBuilding = item as StorageBuilding;
               break;
            }
         }
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.skipExpandStorageBuildingTask",m_questName,m_taskIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var quest:FarmQuest = null;
         var task:FarmTask = null;
         var extraData:Object = null;
         var targetStorageLevel:int = 0;
         super.onComplete(result);
         if(result != null)
         {
            if(this.m_storageBuilding != null)
            {
               quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(m_questName) as FarmQuest;
               task = quest.farmTasks[m_taskIndex];
               if(task != null && task.hasOwnProperty("extraData"))
               {
                  extraData = task.extraData;
                  if(extraData.hasOwnProperty("level"))
                  {
                     targetStorageLevel = int(extraData.level);
                     while(this.m_storageBuilding.storageLevel < targetStorageLevel)
                     {
                        this.m_storageBuilding.expandToNextStorageLevel();
                     }
                     this.m_storageBuilding.reloadImage();
                  }
               }
            }
         }
      }
   }
}

