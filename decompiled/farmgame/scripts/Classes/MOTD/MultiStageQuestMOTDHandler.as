package Classes.MOTD
{
   import Classes.MapTrigger;
   import Classes.QuestChainMapTrigger;
   import Managers.MapTriggerManager;
   
   public class MultiStageQuestMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function MultiStageQuestMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         if(m_currentMOTD["autoAccept"] == "true")
         {
            this.acceptMOTD();
            m_isFinished = true;
         }
         else
         {
            super.execute();
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         var trigger:MapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(m_currentMOTD["mapTriggerName"]);
         if(Boolean(trigger) && trigger is QuestChainMapTrigger)
         {
            (trigger as QuestChainMapTrigger).showUI();
         }
      }
   }
}

