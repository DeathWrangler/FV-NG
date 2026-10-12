package Classes.consumables
{
   import Classes.Constants.QuestConstants;
   import Classes.Consumable;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import ZQuest.Init.QuestSettingsInit;
   
   public class CQuestProgress extends Consumable
   {
      
      private static const FAIL_NON_ACTIVE_QUEST:String = "non_active";
      
      private static const FAIL_COMPLETE_TASK_PROGRESS:String = "complete_task";
      
      private var m_messageType:String = null;
      
      public function CQuestProgress(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var questName:String = null;
         var quest:FarmQuest = null;
         var task:FarmTask = null;
         var result:Boolean = false;
         var questNameArray:Array = this.targetQuestArray();
         for each(questName in questNameArray)
         {
            if(questName != null)
            {
               if(FarmQuestManager.getInstance().isQuestActive(questName) == true)
               {
                  this.m_messageType = FAIL_COMPLETE_TASK_PROGRESS;
                  quest = QuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
                  if(quest != null)
                  {
                     for each(task in quest.farmTasks)
                     {
                        if(task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
                        {
                           if(task.type == this.getItem().code)
                           {
                              if(task.isComplete() == false)
                              {
                                 result = true;
                                 break;
                              }
                           }
                        }
                     }
                     if(result == true)
                     {
                        break;
                     }
                  }
               }
               else
               {
                  this.m_messageType = FAIL_NON_ACTIVE_QUEST;
               }
            }
         }
         return result;
      }
      
      override public function onFailedPerform() : void
      {
         var msg:String = null;
         if(this.m_messageType == FAIL_NON_ACTIVE_QUEST)
         {
            msg = ZLocUtils.t("Quests","UseConsumableOnInactiveQuest");
         }
         else
         {
            msg = ZLocUtils.t("Quests","UseConsumableOnCompleteTask");
         }
         UI.displayMessage(msg);
      }
      
      private function targetQuestArray() : Array
      {
         return this.getItem().getTargetQuestArray();
      }
   }
}

