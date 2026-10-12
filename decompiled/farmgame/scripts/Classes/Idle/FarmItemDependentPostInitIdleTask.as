package Classes.Idle
{
   public class FarmItemDependentPostInitIdleTask extends BaseIdleTask
   {
      
      private var m_sessionStartDelay:uint;
      
      private var m_taskFunction:Function;
      
      public function FarmItemDependentPostInitIdleTask(taskFunction:Function, delay:uint = 0)
      {
         super();
         this.m_taskFunction = taskFunction;
         this.m_sessionStartDelay = delay;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_sessionStartDelay && Global.farmGameSettingsManager.itemsXMLParsingComplete;
      }
      
      override public function fire() : void
      {
         if(this.m_taskFunction !== null)
         {
            this.m_taskFunction();
         }
      }
      
      override public function get singleton() : Boolean
      {
         return false;
      }
   }
}

