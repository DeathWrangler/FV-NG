package Engine.Transactions
{
   public class TransactionLogEntry
   {
      
      private var m_elapsedSessionTime:int = 0;
      
      private var m_request:Object = null;
      
      private var m_isEndofBatch:Boolean = false;
      
      public function TransactionLogEntry(param1:Object)
      {
         super();
         this.m_request = param1;
         this.m_elapsedSessionTime = GlobalEngine.currentTime;
      }
      
      public function get request() : Object
      {
         return this.m_request;
      }
      
      public function setEndOfBatch() : void
      {
         this.m_isEndofBatch = true;
      }
      
      public function toAmfFormat() : Object
      {
         var _loc1_:Object = {};
         _loc1_["Timestamp"] = this.m_elapsedSessionTime;
         _loc1_["request"] = this.m_request;
         _loc1_["isEndOFBatch"] = this.m_isEndofBatch;
         return _loc1_;
      }
   }
}

