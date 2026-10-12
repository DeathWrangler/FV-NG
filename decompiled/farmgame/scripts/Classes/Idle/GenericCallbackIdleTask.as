package Classes.Idle
{
   public class GenericCallbackIdleTask extends BaseIdleTask
   {
      
      private var m_timeDelaySeconds:int;
      
      private var m_callback:Function;
      
      public function GenericCallbackIdleTask(callback:Function, timeDelaySeconds:int)
      {
         super();
         this.m_callback = callback;
         this.m_timeDelaySeconds = timeDelaySeconds;
      }
      
      override public function fire() : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime / 1000 > this.m_timeAddedMilliseconds / 1000 + this.m_timeDelaySeconds;
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
   }
}

