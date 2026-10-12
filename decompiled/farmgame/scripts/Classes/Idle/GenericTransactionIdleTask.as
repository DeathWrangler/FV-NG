package Classes.Idle
{
   import Engine.Managers.TransactionManager;
   import Transactions.TFarmTransaction;
   
   public class GenericTransactionIdleTask extends BaseIdleTask
   {
      
      private var m_transaction:TFarmTransaction;
      
      private var m_timeDelaySeconds:int;
      
      public function GenericTransactionIdleTask(transaction:TFarmTransaction, timeDelaySeconds:int)
      {
         super();
         this.m_transaction = transaction;
         this.m_timeDelaySeconds = timeDelaySeconds;
      }
      
      override public function fire() : void
      {
         if(this.m_transaction != null)
         {
            TransactionManager.addTransaction(this.m_transaction);
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

