package Classes.Idle
{
   import Managers.HolidayCountdownManager;
   
   public class HolidayCountdownIdleTask extends BaseIdleTask
   {
      
      public function HolidayCountdownIdleTask()
      {
         super();
      }
      
      override public function fire() : void
      {
         if(HolidayCountdownManager.shouldAutoPop())
         {
            HolidayCountdownManager.displayAndTrackDialog();
         }
      }
   }
}

