package Engine.Events
{
   import Engine.Transactions.Transaction;
   import flash.events.Event;
   
   public class TransactionEvent extends Event
   {
      
      public static const COMPLETED:String = "completed";
      
      public static const QUEUE_LIMIT_EXCEEDED:String = "exceeded_max_queued";
      
      public static const QUEUE_LIMIT_NORMAL:String = "queue_normal";
      
      public static const VERSION_MISMATCH:String = "version_mismatch";
      
      public static const ADDED:String = "added";
      
      public static const RECONNECTED:String = "reconnected";
      
      public var transaction:Transaction;
      
      private var m_message:String = "";
      
      public function TransactionEvent(param1:String, param2:Transaction = null)
      {
         this.transaction = param2;
         super(param1);
      }
      
      public function get message() : String
      {
         return this.m_message;
      }
      
      public function set message(param1:String) : void
      {
         this.m_message = param1;
      }
   }
}

