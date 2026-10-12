package Engine.Events
{
   import Engine.Transactions.Transaction;
   
   public class TransactionFaultEvent extends TransactionEvent
   {
      
      public static const FAULT:String = "fault";
      
      public static const RECONNECTING:String = "reconnecting";
      
      public static const RETRY_LOGGING:String = "retry_logging";
      
      public var errorType:int;
      
      public var errorData:Object;
      
      public function TransactionFaultEvent(param1:String, param2:Transaction, param3:int, param4:Object)
      {
         this.errorType = param3;
         this.errorData = param4;
         super(param1,param2);
      }
   }
}

