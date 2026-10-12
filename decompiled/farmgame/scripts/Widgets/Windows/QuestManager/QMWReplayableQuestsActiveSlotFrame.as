package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.util.FarmGameUtil;
   import Widgets.Core.Frames.ZwSlotFrame;
   import ZQuest.Classes.Quest;
   import flash.display.DisplayObject;
   
   public class QMWReplayableQuestsActiveSlotFrame extends QMWReplayableQuestsBaseSlotFrame
   {
      
      private var m_featuredQuest:FarmQuest = null;
      
      private var m_activeReplayableQuests:Vector.<FarmQuest> = new Vector.<FarmQuest>();
      
      public function QMWReplayableQuestsActiveSlotFrame(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
      }
      
      private static function sortOnQuestProgress(farmQuestA:FarmQuest, farmQuestB:FarmQuest) : int
      {
         var farmQuestAProgress:Number = NaN;
         var farmQuestBProgress:Number = NaN;
         var result:int = 0;
         var farmQuestAQuestNumber:int = farmQuestA.questNumber;
         var farmQuestBQuestNumber:int = farmQuestB.questNumber;
         if(farmQuestAQuestNumber > farmQuestBQuestNumber)
         {
            result = -1;
         }
         else if(farmQuestAQuestNumber < farmQuestBQuestNumber)
         {
            result = 1;
         }
         else
         {
            farmQuestAProgress = farmQuestA.progress;
            farmQuestBProgress = farmQuestB.progress;
            if(farmQuestAProgress > farmQuestBProgress)
            {
               result = -1;
            }
            else if(farmQuestBProgress > farmQuestAProgress)
            {
               result = 1;
            }
         }
         return result;
      }
      
      private static function getRandomReplayableQuest() : FarmQuest
      {
         var result:FarmQuest = null;
         var questObj:Object = null;
         var index:int = 0;
         var farmQuest:FarmQuest = null;
         var farmQuestSettingsInit:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var allReplayableQuests:Array = farmQuestSettingsInit.questManagerGetReplayableQuests();
         var inactiveReplayableQuests:Vector.<FarmQuest> = new Vector.<FarmQuest>();
         var inactiveAndNeverBeforeCompletedReplayableQuests:Vector.<FarmQuest> = new Vector.<FarmQuest>();
         for each(questObj in allReplayableQuests)
         {
            farmQuest = farmQuestSettingsInit.getItemByName(questObj.firstQuestName) as FarmQuest;
            if(farmQuest != null && farmQuestManager.canActivateReplayableQuest(farmQuest) && !farmQuestManager.isQuestActive(farmQuest.name))
            {
               if(!farmQuestManager.isQuestComplete(farmQuest.name))
               {
                  inactiveAndNeverBeforeCompletedReplayableQuests.push(farmQuest);
               }
               else
               {
                  inactiveReplayableQuests.push(farmQuest);
               }
            }
         }
         index = 0;
         if(inactiveAndNeverBeforeCompletedReplayableQuests.length > 0)
         {
            index = FarmGameUtil.getRandomInt(inactiveAndNeverBeforeCompletedReplayableQuests.length - 1);
            result = inactiveAndNeverBeforeCompletedReplayableQuests[index];
         }
         else
         {
            index = FarmGameUtil.getRandomInt(inactiveReplayableQuests.length - 1);
            result = inactiveReplayableQuests[index];
         }
         return result;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new QMWReplayableQuestsActiveSlot(slotElement,m_mainWindow);
      }
      
      private function setActiveReplayableQuestData() : void
      {
         var quest:Quest = null;
         var farmQuest:FarmQuest = null;
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var activeQuests:Vector.<Quest> = farmQuestManager.getActiveQuests();
         this.m_activeReplayableQuests = new Vector.<FarmQuest>();
         for each(quest in activeQuests)
         {
            farmQuest = quest as FarmQuest;
            if(farmQuest != null && farmQuest.isQuestManagerReplayableQuest() && FarmQuestManager.getInstance().canActivateReplayableQuest(farmQuest) && farmQuestManager.completedQuests.indexOf(farmQuest.name) == -1)
            {
               this.m_activeReplayableQuests.push(farmQuest);
            }
         }
         this.m_activeReplayableQuests.sort(sortOnQuestProgress);
      }
      
      override protected function setupData() : void
      {
         var farmQuest:FarmQuest = null;
         this.setActiveReplayableQuestData();
         var slotData:Array = new Array();
         if(this.m_activeReplayableQuests.length < m_slots.length)
         {
            if(this.m_featuredQuest == null)
            {
               this.m_featuredQuest = getRandomReplayableQuest();
            }
            if(this.m_featuredQuest != null)
            {
               slotData.push(this.m_featuredQuest);
            }
         }
         for each(farmQuest in this.m_activeReplayableQuests)
         {
            slotData.push(farmQuest);
         }
         this.m_slotData = slotData;
      }
   }
}

