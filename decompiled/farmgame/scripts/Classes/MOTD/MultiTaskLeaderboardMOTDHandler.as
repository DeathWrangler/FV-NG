package Classes.MOTD
{
   import Managers.LeaderboardManager;
   
   public class MultiTaskLeaderboardMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function MultiTaskLeaderboardMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         LeaderboardManager.displayMultiTaskLeaderboardWindow();
      }
   }
}

