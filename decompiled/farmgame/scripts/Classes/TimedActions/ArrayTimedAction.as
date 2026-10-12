package Classes.TimedActions
{
   public class ArrayTimedAction extends TimedAction
   {
      
      protected var m_index:int;
      
      public function ArrayTimedAction(totalTime:Number, data:Array, index:int = 0, retryCount:int = 0)
      {
         super(totalTime,data,retryCount);
         this.m_index = index;
      }
      
      override public function perform(data:Object = null) : Object
      {
         var superResult:Object = null;
         var newData:Object = data;
         if(newData == null)
         {
            newData = m_data;
         }
         while(newData != null && this.m_index < (newData as Array).length)
         {
            superResult = super.perform(newData[this.m_index]);
            ++this.m_index;
            if(superResult == null)
            {
               break;
            }
         }
         return superResult;
      }
      
      override protected function reAddToQueue() : void
      {
         if(m_retriesSoFar < Number(GlobalEngine.getFlashVar("TIMED_ACTION_MAX_RETRIES")))
         {
            Global.world.addTimedActionToQueue(new (this.getClassName())(m_timeToRun,m_data as Array,this.m_index,m_retriesSoFar + 1));
         }
      }
      
      override protected function getClassName() : Class
      {
         return ArrayTimedAction;
      }
   }
}

