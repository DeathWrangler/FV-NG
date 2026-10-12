package Classes.Idle
{
   import Display.UI;
   import Events.DynamicObjectEvent;
   import GameMode.GMDefault;
   import Managers.SpendometerManager;
   
   public class SpendometerReopenIdleTask extends BaseIdleTask
   {
      
      public function SpendometerReopenIdleTask()
      {
         super();
      }
      
      override public function get canFire() : Boolean
      {
         return UI.numberOfPopupsInQueue == 0 && Global.world.isGameModeActive(GMDefault);
      }
      
      override public function fire() : void
      {
         SpendometerManager.instance.dispatchEvent(new DynamicObjectEvent(SpendometerManager.SHOW_SPENDOMETER_DIALOG,{"source":"idle"}));
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get queueCoolDownMilliseconds() : Number
      {
         return DEFAULT_QUEUE_COOLDOWN_MILLISECONDS * 3;
      }
      
      override public function get singletonClobber() : Boolean
      {
         return true;
      }
   }
}

