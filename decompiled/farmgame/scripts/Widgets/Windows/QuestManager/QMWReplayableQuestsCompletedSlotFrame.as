package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.ReplayableFarmQuestData;
   import Widgets.Core.Frames.ZwSlotFrame;
   import ZQuest.Classes.Quest;
   import flash.display.DisplayObject;
   
   public class QMWReplayableQuestsCompletedSlotFrame extends QMWReplayableQuestsBaseSlotFrame
   {
      
      public function QMWReplayableQuestsCompletedSlotFrame(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
         setUpPagingArrows();
      }
      
      private static function sortOnCompletionDate(questDataA:ReplayableFarmQuestData, questDataB:ReplayableFarmQuestData) : int
      {
         var result:int = 0;
         if(questDataA.mostRecentlyCompletedDate < questDataB.mostRecentlyCompletedDate)
         {
            result = -1;
         }
         else if(questDataA.mostRecentlyCompletedDate > questDataB.mostRecentlyCompletedDate)
         {
            result = 1;
         }
         return result;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new QMWReplayableQuestsCompletedSlot(slotElement,m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         var sessionCompletedQuestName:String = null;
         var completedReplayableQuests:Vector.<ReplayableFarmQuestData> = null;
         var replayableFarmQuestData:ReplayableFarmQuestData = null;
         var sessionCompletedQuest:FarmQuest = null;
         var nameOfFirstQuestInChainOfSessionCompletedQuest:String = null;
         var firstQuestInChainOfSessionCompletedQuest:FarmQuest = null;
         var shouldAdd:Boolean = false;
         var activeQuests:Vector.<Quest> = null;
         var activeQuest:Quest = null;
         var activeReplayableQuestName:String = null;
         var slotDatum:Object = null;
         var slotDatumAsQuest:FarmQuest = null;
         var farmQuest:FarmQuest = null;
         m_slotData = new Array();
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         for each(sessionCompletedQuestName in farmQuestManager.completedQuests)
         {
            sessionCompletedQuest = farmQuestSettingsInit.getItemByName(sessionCompletedQuestName) as FarmQuest;
            if(sessionCompletedQuest != null && sessionCompletedQuest.children.length == 0)
            {
               nameOfFirstQuestInChainOfSessionCompletedQuest = farmQuestSettingsInit.questManagerGetNameOfFirstQuestInReplayableChain(sessionCompletedQuest.name);
               if(nameOfFirstQuestInChainOfSessionCompletedQuest != null)
               {
                  firstQuestInChainOfSessionCompletedQuest = farmQuestSettingsInit.getItemByName(nameOfFirstQuestInChainOfSessionCompletedQuest) as FarmQuest;
                  if(firstQuestInChainOfSessionCompletedQuest != null)
                  {
                     m_slotData.push(firstQuestInChainOfSessionCompletedQuest);
                  }
               }
            }
         }
         completedReplayableQuests = farmQuestManager.completedReplayableQuests;
         completedReplayableQuests.sort(sortOnCompletionDate);
         for each(replayableFarmQuestData in completedReplayableQuests)
         {
            shouldAdd = !replayableFarmQuestData.hideFromQuestManagerComplete;
            if(shouldAdd)
            {
               activeQuests = farmQuestManager.getActiveQuests();
               for each(activeQuest in activeQuests)
               {
                  activeReplayableQuestName = farmQuestSettingsInit.questManagerGetNameOfFirstQuestInReplayableChain(activeQuest.name);
                  if(activeReplayableQuestName != null && activeReplayableQuestName == replayableFarmQuestData.questName)
                  {
                     shouldAdd = false;
                     break;
                  }
               }
               if(shouldAdd)
               {
                  for each(slotDatum in m_slotData)
                  {
                     slotDatumAsQuest = slotDatum as FarmQuest;
                     if(slotDatumAsQuest != null && slotDatumAsQuest.name == replayableFarmQuestData.questName)
                     {
                        shouldAdd = false;
                        break;
                     }
                  }
                  if(shouldAdd)
                  {
                     farmQuest = FarmQuestSettingsInit.getInstance().getItemByName(replayableFarmQuestData.questName) as FarmQuest;
                     if(farmQuest != null)
                     {
                        m_slotData.push(farmQuest);
                     }
                  }
               }
            }
         }
      }
   }
}

