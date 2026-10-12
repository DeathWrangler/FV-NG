package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   
   public class QMWReplayableQuestsNewSlotFrame extends QMWReplayableQuestsBaseSlotFrame
   {
      
      public function QMWReplayableQuestsNewSlotFrame(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
         setUpPagingArrows();
      }
      
      private static function sortOnQuestManagerSortIndexAndFriendlyName(questA:FarmQuest, questB:FarmQuest) : int
      {
         var farmQuestManager:FarmQuestManager = null;
         var questChainNameA:String = null;
         var questChainNameB:String = null;
         var result:int = 0;
         var questSortIndexA:int = FarmQuestSettingsInit.getInstance().questManagerGetSortIndexForReplayableQuestChain(questA.name);
         var questSortIndexB:int = FarmQuestSettingsInit.getInstance().questManagerGetSortIndexForReplayableQuestChain(questB.name);
         if(questSortIndexA > questSortIndexB)
         {
            result = -1;
         }
         else if(questSortIndexA < questSortIndexB)
         {
            result = 1;
         }
         else
         {
            farmQuestManager = FarmQuestManager.getInstance();
            questChainNameA = farmQuestManager.getQuestChainFriendlyName(questA.name).toLowerCase();
            questChainNameB = farmQuestManager.getQuestChainFriendlyName(questB.name).toLowerCase();
            if(questChainNameA < questChainNameB)
            {
               result = -1;
            }
            else if(questChainNameA > questChainNameB)
            {
               result = 1;
            }
         }
         return result;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new QMWReplayableQuestsNewSlot(slotElement,m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         var questObj:Object = null;
         var farmQuest:FarmQuest = null;
         var farmQuestManager:FarmQuestManager = null;
         var parentQuestNamesOfQuest:Array = null;
         var noQuestsInChainAreActive:Boolean = false;
         var questName:String = null;
         m_slotData = new Array();
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         var replayableQuests:Array = farmQuestSettingsInit.questManagerGetReplayableQuests();
         for each(questObj in replayableQuests)
         {
            farmQuest = farmQuestSettingsInit.getItemByName(questObj.firstQuestName) as FarmQuest;
            farmQuestManager = FarmQuestManager.getInstance();
            if(farmQuestManager.canActivateReplayableQuest(farmQuest) && farmQuestSettingsInit.questManagerQuestChainCacheContains(farmQuest.name) && !farmQuestManager.hasReplayableQuestBeenCompleted(farmQuest.name))
            {
               parentQuestNamesOfQuest = farmQuestManager.questManagerGetListOfChildQuests(farmQuest.name,true);
               noQuestsInChainAreActive = true;
               for each(questName in parentQuestNamesOfQuest)
               {
                  if(farmQuestManager.isQuestActive(questName))
                  {
                     noQuestsInChainAreActive = false;
                     break;
                  }
               }
               if(noQuestsInChainAreActive)
               {
                  m_slotData.push(farmQuest);
               }
            }
         }
         m_slotData.sort(sortOnQuestManagerSortIndexAndFriendlyName);
      }
   }
}

