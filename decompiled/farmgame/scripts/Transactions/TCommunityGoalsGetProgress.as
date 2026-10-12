package Transactions
{
   import Classes.CommunityGoals.CommunityGoalsTask;
   
   public class TCommunityGoalsGetProgress extends TFarmTransaction
   {
      
      protected var m_task:CommunityGoalsTask;
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TCommunityGoalsGetProgress(task:CommunityGoalsTask, transactionCompleteCallback:Function = null)
      {
         super();
         this.m_task = task;
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("CommunityGoalsService.getProgressForTask",this.m_task.name);
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

