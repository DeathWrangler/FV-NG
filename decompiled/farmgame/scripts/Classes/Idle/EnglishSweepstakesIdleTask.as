package Classes.Idle
{
   import Managers.ToasterManager;
   import Widgets.Windows.Promotions.EnglishSweepstakesToasterWindow;
   
   public class EnglishSweepstakesIdleTask extends BaseIdleTask
   {
      
      public static const EXTENDED_TOASTER_DELAY:int = 30000;
      
      public static const DEFAULT_TOASTER_DELAY:int = 2000;
      
      public static const QUEST_FINISHED:String = "ecsweeps_toaster_questFinished";
      
      public static const DOOBER_HARVESTED:String = "ecsweeps_toaster_dooberHarvested";
      
      protected var m_timeToPop:int = 0;
      
      private var m_toasterType:String;
      
      public function EnglishSweepstakesIdleTask(popDelay:int = 2000, toasterType:String = "ecsweeps_toaster_dooberHarvested")
      {
         this.m_toasterType = toasterType;
         if(GlobalEngine.getFlashVar("ref") == "Reactivate_email_England" && popDelay == EnglishSweepstakesIdleTask.EXTENDED_TOASTER_DELAY)
         {
            popDelay += EnglishSweepstakesIdleTask.EXTENDED_TOASTER_DELAY;
         }
         this.m_timeToPop = popDelay + GlobalEngine.currentTime;
         m_displaysPopup = true;
         super();
      }
      
      override public function fire() : void
      {
         ToasterManager.getInstance().add(new EnglishSweepstakesToasterWindow(this.m_toasterType));
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_timeToPop;
      }
   }
}

