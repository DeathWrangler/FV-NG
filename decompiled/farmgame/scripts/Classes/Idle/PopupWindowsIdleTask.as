package Classes.Idle
{
   import Managers.BingoManager;
   import Managers.FarmStatsManager;
   import Managers.HolidayCountdownManager;
   
   public class PopupWindowsIdleTask extends BaseIdleTask
   {
      
      private var m_isCountdownConfig:Boolean = false;
      
      private var m_bingoManager:BingoManager = BingoManager.getInstance();
      
      public function PopupWindowsIdleTask(isCountdownConfig:Boolean)
      {
         super();
         this.m_isCountdownConfig = isCountdownConfig;
      }
      
      override public function fire() : void
      {
         if(this.m_isCountdownConfig && HolidayCountdownManager.shouldAutoPop())
         {
            HolidayCountdownManager.displayAndTrackDialog();
         }
         else if(this.m_bingoManager.shouldAutoPop())
         {
            FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"autopop","triggered",this.m_bingoManager.getNumberOfSuccessfulBallsOnCard().toString());
            BingoManager.getInstance().displayBingo();
         }
      }
   }
}

