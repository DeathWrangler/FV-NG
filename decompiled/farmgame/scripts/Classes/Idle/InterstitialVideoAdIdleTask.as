package Classes.Idle
{
   import Managers.FarmStatsManager;
   import flash.external.ExternalInterface;
   
   public class InterstitialVideoAdIdleTask extends BaseIdleTask
   {
      
      public static const BACKOFF_MAX_DAYS:int = 7;
      
      public static const MOUSE_IDLE_MILLISECONDS:Number = 10000;
      
      public static const ACTION_QUEUE_EMPTY_MILLISECONDS:Number = 10000;
      
      public static var INTERSTITIAL_VIDEO_AD_SLOT_ID_IDLE_TIME:String = "INTERSTITIAL_VIDEO_AD_SLOT_ID_IDLE_TIME";
      
      public static var STAT_COUNTER:String = "interstitial_video";
      
      public static var EI_FUNTCTION_INTERSTITIAL_SHOW:String = "showInterstitialAd";
      
      public function InterstitialVideoAdIdleTask()
      {
         super();
         m_displaysPopup = true;
      }
      
      private static function canShowWithBackoff() : Boolean
      {
         return Global.player.canShowFeatureWithBackoff(INTERSTITIAL_VIDEO_AD_SLOT_ID_IDLE_TIME);
      }
      
      public static function shouldAddStatic() : Boolean
      {
         return canShowWithBackoff() && arePrereqsMet();
      }
      
      public static function canFireStatic() : Boolean
      {
         return canShowWithBackoff();
      }
      
      public static function fireIdlePrompt() : void
      {
         var idleTask:InterstitialVideoAdIdleTask = new InterstitialVideoAdIdleTask();
         if(idleTask.canFire)
         {
            idleTask.fire();
         }
      }
      
      public static function arePrereqsMet() : Boolean
      {
         return GlobalEngine.getFlashVar("showInterstitialAd") != null && GlobalEngine.getFlashVar("showInterstitialAd") == true;
      }
      
      public static function viewSuccess() : void
      {
         if(Global.player.getBackoffInterval(INTERSTITIAL_VIDEO_AD_SLOT_ID_IDLE_TIME) < BACKOFF_MAX_DAYS)
         {
            Global.player.incrementBackoffInterval(INTERSTITIAL_VIDEO_AD_SLOT_ID_IDLE_TIME);
         }
         FarmStatsManager.count(InterstitialVideoAdIdleTask.STAT_COUNTER,"success","view");
      }
      
      public static function viewError() : void
      {
         IdleTaskQueue.getInstance().addTask(new InterstitialVideoAdIdleTask());
         FarmStatsManager.count(InterstitialVideoAdIdleTask.STAT_COUNTER,"error","view");
      }
      
      override public function get minActionIdleMilliseconds() : Number
      {
         return ACTION_QUEUE_EMPTY_MILLISECONDS;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return MOUSE_IDLE_MILLISECONDS;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return shouldAddStatic();
      }
      
      override public function get canFire() : Boolean
      {
         return canFireStatic();
      }
      
      override public function fire() : void
      {
         FarmStatsManager.count(InterstitialVideoAdIdleTask.STAT_COUNTER,"trigger","view");
         if(ExternalInterface.available)
         {
            ExternalInterface.call(EI_FUNTCTION_INTERSTITIAL_SHOW);
         }
      }
   }
}

