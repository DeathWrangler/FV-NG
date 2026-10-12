package Classes.MOTD
{
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   
   public class NeighborCleanupMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function NeighborCleanupMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         TransactionManager.addTransaction(new TGenericTransaction("UserService","cleanupNeighborData",null,null),true);
      }
      
      private function logButtonClick() : void
      {
         FarmStatsManager.count("NeighborCleanup","MOTD_Button_Clicked");
      }
   }
}

