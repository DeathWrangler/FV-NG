package Classes.Idle
{
   import Managers.ClickTrackingManager;
   
   public class ClickTrackingIdleTask extends BaseIdleTask
   {
      
      private static var m_nextFireTime:Number = 0;
      
      private var m_sendStatsCooldown:int = 180000;
      
      public function ClickTrackingIdleTask()
      {
         super();
         this.m_sendStatsCooldown = Global.farmGameSettingsManager.getNumber("clickTrackingCooldown",180) * 1000;
         m_nextFireTime = GlobalEngine.currentTime + this.m_sendStatsCooldown;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get queueCoolDownMilliseconds() : Number
      {
         return 0;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > m_nextFireTime;
      }
      
      override public function fire() : void
      {
         ClickTrackingManager.getInstance().sendStats();
         this.resetTask();
      }
      
      private function resetTask() : void
      {
         m_nextFireTime = GlobalEngine.currentTime + this.m_sendStatsCooldown;
         IdleTaskQueue.getInstance().addTask(this);
      }
   }
}

