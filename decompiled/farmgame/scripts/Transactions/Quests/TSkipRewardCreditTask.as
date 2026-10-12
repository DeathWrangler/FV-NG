package Transactions.Quests
{
   import Classes.CreditsBuilding;
   import Classes.ItemInstance;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import ZQuest.Init.QuestSettingsInit;
   import flash.utils.getDefinitionByName;
   
   public class TSkipRewardCreditTask extends TSkipQuestTask
   {
      
      public function TSkipRewardCreditTask(questName:String, taskIndex:int)
      {
         super(questName,taskIndex);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.skipRewardCreditsTask",m_questName,m_taskIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var quest:FarmQuest = null;
         var task:FarmTask = null;
         var objectsInWorld:Array = null;
         var item:ItemInstance = null;
         var creditsReceived:int = 0;
         var creditsToAdd:int = 0;
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
                  if(objectsInWorld.length == 0)
                  {
                     objectsInWorld.push(this.getTempRewardBuildingInstance(task.type));
                  }
                  break;
               case "category":
               case "class":
            }
            for each(item in objectsInWorld)
            {
               if(item is CreditsBuilding)
               {
                  creditsReceived = int((item as CreditsBuilding).getTotalCreditsReceived());
                  creditsToAdd = task.total - creditsReceived;
                  if(creditsToAdd > 0)
                  {
                     (item as CreditsBuilding).addCredits(creditsToAdd);
                     break;
                  }
               }
            }
         }
      }
      
      private function getTempRewardBuildingInstance(itemCode:String) : ItemInstance
      {
         var result:ItemInstance = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var tempClass:Class = null;
         if(item.className != "")
         {
            tempClass = getDefinitionByName("Classes." + item.className) as Class;
         }
         if(tempClass != null)
         {
            result = new tempClass(item.name);
         }
         Global.player.removeLimitedItem(item.name);
         return result;
      }
   }
}

