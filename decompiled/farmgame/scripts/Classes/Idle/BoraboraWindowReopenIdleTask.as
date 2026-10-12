package Classes.Idle
{
   import GameMode.GMDecorationPlace;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   
   public class BoraboraWindowReopenIdleTask extends BaseIdleTask
   {
      
      public function BoraboraWindowReopenIdleTask()
      {
         super();
      }
      
      override public function get canFire() : Boolean
      {
         return !Global.world.isGameModeActive(GMDecorationPlace) && !BoraBoraInnovationManager.getInstance().isBoraboraInnovationMainWindowActive();
      }
      
      override public function fire() : void
      {
         BoraBoraInnovationManager.getInstance().showMainWindow();
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
         return DEFAULT_QUEUE_COOLDOWN_MILLISECONDS;
      }
      
      override public function get singletonClobber() : Boolean
      {
         return true;
      }
   }
}

