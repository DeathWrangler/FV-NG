package Transactions.Quests
{
   import Transactions.TFarmTransaction;
   
   public class TIncrementGenericFarmTask extends TFarmTransaction
   {
      
      public static const METHOD_INCREMENT_TASK:String = "incrementGenericFarmTask";
      
      private var m_action:String = "";
      
      public function TIncrementGenericFarmTask(taskAction:String)
      {
         super();
         this.m_action = taskAction;
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService." + METHOD_INCREMENT_TASK,this.m_action);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_INCREMENT_TASK;
         result.taskAction = this.m_action;
         return result;
      }
   }
}

