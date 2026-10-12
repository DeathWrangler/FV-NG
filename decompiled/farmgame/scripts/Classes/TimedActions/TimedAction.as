package Classes.TimedActions
{
   import flash.utils.getTimer;
   
   public class TimedAction
   {
      
      protected var m_data:Object;
      
      protected var m_timeToRun:Number;
      
      protected var m_startTime:Number;
      
      private var m_endTime:Number;
      
      protected var m_retriesSoFar:Number = 0;
      
      public function TimedAction(totalTime:Number, data:Object, retryCount:int = 0)
      {
         super();
         this.m_data = data;
         this.m_timeToRun = totalTime;
         this.m_startTime = 0;
         this.m_endTime = 0;
         this.m_retriesSoFar = retryCount;
      }
      
      public function perform(data:Object = null) : Object
      {
         var actionableData:Object = null;
         if(this.m_startTime == 0)
         {
            this.m_startTime = getTimer();
         }
         var result:Object = null;
         if(this.m_endTime - this.m_startTime < this.m_timeToRun)
         {
            actionableData = data;
            if(actionableData == null)
            {
               actionableData = this.m_data;
            }
            result = this.performHelper(actionableData);
            this.m_endTime = getTimer();
         }
         else
         {
            this.reAddToQueue();
            result = null;
         }
         return result;
      }
      
      protected function performHelper(data:Object) : Object
      {
         return null;
      }
      
      protected function reAddToQueue() : void
      {
         if(this.m_retriesSoFar < Number(GlobalEngine.getFlashVar("TIMED_ACTION_MAX_RETRIES")))
         {
            Global.world.addTimedActionToQueue(new (this.getClassName())(this.m_timeToRun,this.m_data,this.m_retriesSoFar + 1));
         }
      }
      
      protected function getClassName() : Class
      {
         return TimedAction;
      }
   }
}

