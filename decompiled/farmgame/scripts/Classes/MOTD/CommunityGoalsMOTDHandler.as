package Classes.MOTD
{
   import Engine.Managers.TransactionManager;
   import Managers.CommunityGoalsManager;
   import Transactions.TSawSpecificMOTD;
   import flash.events.Event;
   
   public class CommunityGoalsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function CommunityGoalsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         if(!Global.flashHotParams["MP_MOTD_CLICK_TEMPRT"])
         {
            ztrack("click");
         }
         if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.motdSeenFlag))
         {
            if(m_currentMOTD)
            {
               TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,true));
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
         removeAllEventListeners();
         var manager:CommunityGoalsManager = CommunityGoalsManager.getInstance();
         manager.registerFeature();
         manager.displayDialog();
      }
   }
}

