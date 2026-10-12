package Classes.MOTD
{
   import Display.MOTD;
   import Engine.Managers.TransactionManager;
   import Init.PostInitActionHandlers.AbstractPostInitAction;
   import Managers.FarmStatsManager;
   import Transactions.TRefreshGifts;
   import Transactions.TSawMOTD;
   import flash.events.Event;
   
   public class MOTDHandler extends AbstractPostInitAction
   {
      
      public static const MOTD_DIALOG:String = "dialog";
      
      public static const SEEN_MOTD_SESSION_FLAG:String = "sawMotd";
      
      protected static const MOTD_DIALOG_NAME_NORMAL:String = "MotdBuildableOnboard";
      
      protected static const MOTD_DIALOG_NAME_NO_CANCEL:String = "MotdBuildableOnboardNoCancel";
      
      protected var m_currentMOTD:Object = {};
      
      protected var m_callbackData:Object = {};
      
      public function MOTDHandler(currentMOTD:Object)
      {
         super();
         this.m_currentMOTD = currentMOTD;
      }
      
      override public function execute() : void
      {
         this.ztrack("impressions");
         Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
         m_isFinished = true;
      }
      
      protected function acceptMOTD() : void
      {
         if(!Global.flashHotParams["MP_MOTD_CLICK_TEMPRT"])
         {
            this.ztrack("click");
         }
         this.closeMOTD();
      }
      
      protected function closeMOTD() : void
      {
         TransactionManager.addTransaction(new TSawMOTD(this.m_currentMOTD),true);
         TransactionManager.addTransaction(new TRefreshGifts(),true);
         dispatchEvent(new Event(Event.COMPLETE));
         removeAllEventListeners();
      }
      
      protected function ztrack(kingdom:String) : void
      {
         FarmStatsManager.count("MOTD",kingdom,this.m_currentMOTD.motdSeenFlag);
      }
   }
}

