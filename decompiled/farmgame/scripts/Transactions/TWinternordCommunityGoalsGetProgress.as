package Transactions
{
   import Classes.WinternordInnovationCommunityGoalTask;
   
   public class TWinternordCommunityGoalsGetProgress extends TFarmTransaction
   {
      
      protected var m_task:WinternordInnovationCommunityGoalTask;
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TWinternordCommunityGoalsGetProgress(task:WinternordInnovationCommunityGoalTask, transactionCompleteCallback:Function = null)
      {
         super();
         this.m_task = task;
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("WinternordInnovationService.getProgressForTask",this.m_task.name);
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

