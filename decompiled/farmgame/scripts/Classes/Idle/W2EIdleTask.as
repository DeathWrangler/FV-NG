package Classes.Idle
{
   import Classes.Constants.Experiments;
   import Classes.WatchToEarnManager;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.WatchToEarnPromptWindow;
   
   public class W2EIdleTask extends BaseIdleTask
   {
      
      public static const BACKOFF_MAX_DAYS:int = 7;
      
      public static const MOUSE_IDLE_MILLISECONDS:Number = 5000;
      
      public static const ACTION_QUEUE_EMPTY_MILLISECONDS:Number = 5000;
      
      public static var W2E_SLOT_ID_IDLE_TIME:String = "WEB_FARM_INC_PP_IDLE";
      
      public static const ZRUNTIME_W2E_POPUP_CONTROL:String = "W2E_POPUP_CONTROL_RUNTIME";
      
      public function W2EIdleTask()
      {
         super();
         m_displaysPopup = true;
      }
      
      private static function canShowWithBackoff() : Boolean
      {
         return Global.player.canShowFeatureWithBackoff(Experiments.EXPERIMENT_FLASH_W2E_INGAME);
      }
      
      public static function shouldAddStatic() : Boolean
      {
         return canShowWithBackoff() && Global.watchToEarn.areSlotPrerequisitesMet(W2E_SLOT_ID_IDLE_TIME);
      }
      
      public static function canFireStatic() : Boolean
      {
         return canShowWithBackoff();
      }
      
      public static function fireIdlePrompt() : void
      {
         var idleTask:W2EIdleTask = new W2EIdleTask();
         if(idleTask.canFire)
         {
            idleTask.fire();
         }
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
         if(Global.player.getBackoffInterval(Experiments.EXPERIMENT_FLASH_W2E_INGAME) < BACKOFF_MAX_DAYS)
         {
            Global.player.incrementBackoffInterval(Experiments.EXPERIMENT_FLASH_W2E_INGAME);
         }
         FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_IDLE_TIME,"view");
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_W2E_POPUP_CONTROL) && Boolean(Global.flashHotParams[ZRUNTIME_W2E_POPUP_CONTROL]))
         {
            UI.displayPopup(new WatchToEarnPromptWindow(this.onPopupAcceptButtonClicked),false);
         }
      }
      
      private function onPopupAcceptButtonClicked() : void
      {
      }
   }
}

