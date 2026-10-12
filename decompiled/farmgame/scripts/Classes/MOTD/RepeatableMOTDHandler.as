package Classes.MOTD
{
   import Engine.Managers.TransactionManager;
   import Transactions.TRefreshGifts;
   import Transactions.TSawSpecificMOTD;
   import flash.events.Event;
   
   public class RepeatableMOTDHandler extends MOTDHandler
   {
      
      protected var m_addToQueue:Boolean = true;
      
      public function RepeatableMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      public function set addToQueue(shouldAdd:Boolean) : void
      {
         this.m_addToQueue = shouldAdd;
      }
      
      override protected function acceptMOTD() : void
      {
         if(!Global.flashHotParams["MP_MOTD_CLICK_TEMPRT"])
         {
            ztrack("click");
         }
         if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.motdSeenFlag))
         {
            if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.noAddingGiftToGiftBox))
            {
               TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,false));
            }
            else
            {
               TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,true));
               TransactionManager.addTransaction(new TRefreshGifts(),true);
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
         removeAllEventListeners();
      }
      
      override protected function closeMOTD() : void
      {
         if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.motdSeenFlag) && !Global.player.isMotdSeenFlagSet(m_currentMOTD.motdSeenFlag))
         {
            TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,false));
         }
         if(!m_currentMOTD.noAddingGiftToGiftBox)
         {
            dispatchEvent(new Event(Event.CANCEL));
         }
         removeAllEventListeners();
      }
   }
}

