package Transactions
{
   import Classes.MadagascarInnovationCommunityGoalTask;
   
   public class TMadagascarCommunityGoalsGetProgress extends TFarmTransaction
   {
      
      protected var m_task:MadagascarInnovationCommunityGoalTask;
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TMadagascarCommunityGoalsGetProgress(task:MadagascarInnovationCommunityGoalTask, transactionCompleteCallback:Function = null)
      {
         super();
         this.m_task = task;
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("MadagascarInnovationService.getProgressForTask",this.m_task.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_transactionCompleteCallBack != null)
         {
            this.m_transactionCompleteCallBack(result);
         }
      }
   }
}

