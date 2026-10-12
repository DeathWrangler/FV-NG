package Classes.Idle
{
   import Managers.WanderingAnimalsManager;
   
   public class WanderingAnimalTask extends BaseIdleTask
   {
      
      protected static var m_nextFireTime:Number = 0;
      
      protected var m_mouseDelay:Number = 600000;
      
      public function WanderingAnimalTask()
      {
         super();
         this.m_mouseDelay = Global.farmGameSettingsManager.getNumber("idleMissionTime",600) * 1000;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_mouseDelay;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > m_nextFireTime;
      }
      
      override public function fire() : void
      {
         if(WanderingAnimalsManager.getInstance().showWanderingMustang() == false)
         {
            WanderingAnimalsManager.getInstance().showWanderingStallion();
         }
         this.resetIdleMission();
      }
      
      protected function resetIdleMission() : void
      {
         m_nextFireTime = GlobalEngine.currentTime + this.m_mouseDelay;
      }
   }
}

