package Transactions
{
   import Classes.IsraelInnovationCommunityGoalTask;
   
   public class TIsraelCommunityGoalsGetProgress extends TFarmTransaction
   {
      
      protected var m_task:IsraelInnovationCommunityGoalTask;
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TIsraelCommunityGoalsGetProgress(task:IsraelInnovationCommunityGoalTask, transactionCompleteCallback:Function = null)
      {
         super();
         this.m_task = task;
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("IsraelInnovationService.getProgressForTask",this.m_task.name);
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

