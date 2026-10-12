package Classes.MOTD
{
   import Managers.FarmStatsManager;
   import Managers.UnlimitedPacksManager;
   
   public class UnlimitedPacksMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function UnlimitedPacksMOTDHandler(currentMOTD:Object)
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
         UnlimitedPacksManager.getInstance().onBuyBundle();
         this.logButtonClick();
      }
      
      private function logButtonClick() : void
      {
         FarmStatsManager.count(UnlimitedPacksManager.FEATURE_NAME,"motd_buy_clicked");
      }
   }
}

