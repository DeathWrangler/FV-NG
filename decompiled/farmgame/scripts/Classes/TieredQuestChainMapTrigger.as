package Classes
{
   import Classes.Quest.FarmQuest;
   import Display.UI;
   import Events.FeatureMessageEvent;
   import Managers.FeatureMessagingManager;
   import Widgets.Windows.TieredQuestWindow;
   import ZQuest.Events.QuestEvent;
   
   public class TieredQuestChainMapTrigger extends RecurringQuestChainMapTrigger
   {
      
      private var m_tieredQuestUi:TieredQuestWindow = null;
      
      public function TieredQuestChainMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function showUI() : void
      {
         var url:String = m_questMapping[m_farmQuest.name].dialogUrl;
         if(m_farmQuest.numOfCompletedTasks != m_farmQuest.farmTasks.length)
         {
            this.m_tieredQuestUi = new TieredQuestWindow(m_chainOrder,m_farmQuest,m_stage,url,m_itemName);
            UI.displayPopup(this.m_tieredQuestUi,true,"",true);
         }
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         super.loadXmlData(xmlData);
      }
      
      override protected function onQuestUpdates(event:QuestEvent) : void
      {
         var oldQuest:FarmQuest = m_farmQuest;
         this.updateStateAndStage();
         if(this.m_tieredQuestUi)
         {
            this.m_tieredQuestUi.refreshUI();
         }
         if(oldQuest != m_farmQuest)
         {
            if(event.quest is FarmQuest)
            {
               FeatureMessagingManager.getInstance().dispatchFeatureMessage(new FeatureMessageEvent(FeatureMessageEvent.FEATURE_STATE_CHANGE,(event.quest as FarmQuest).chain));
            }
            if(this.m_tieredQuestUi)
            {
               this.m_tieredQuestUi.close();
            }
         }
      }
      
      override protected function onQuestComplete(event:QuestEvent) : void
      {
         if(this.m_tieredQuestUi)
         {
            this.m_tieredQuestUi.close();
         }
         super.onQuestComplete(event);
      }
      
      override protected function updateStateAndStage() : void
      {
         var newState:String = null;
         var curFarmQuest:FarmQuest = findCurrentFarmQuest();
         if(curFarmQuest != null && !Global.worldManager.isVisiting())
         {
            if(m_farmQuest == null)
            {
               conditionallyReattach(true);
            }
            m_farmQuest = curFarmQuest;
            newState = m_questMapping[curFarmQuest.name].state;
            m_stage = m_questMapping[curFarmQuest.name].stage;
            if(newState != null)
            {
               setState(newState);
            }
         }
      }
   }
}

