package Engine.Managers
{
   import Engine.Transactions.TransactionLogEntry;
   
   public class CBReportManager
   {
      
      private static const DEFAULT_MAX_LOG_ENTRIES:int = 20;
      
      private static const FLASHVAR_CB_NAME:String = "FLASHVAR_CRASHBUSTERS_LOGSIZE";
      
      private static var m_instance:CBReportManager = null;
      
      private static var m_allowInstantiation:Boolean = false;
      
      private var m_max_log_entries:int = 20;
      
      private var m_nextEmpty:int = 0;
      
      private var m_nextSentEmpty:int = 0;
      
      private var m_transactionLogEntries:Vector.<TransactionLogEntry> = null;
      
      private var m_transactionSentLogEntries:Vector.<TransactionLogEntry> = null;
      
      public function CBReportManager()
      {
         super();
         if(Boolean(m_instance) || !m_allowInstantiation)
         {
            throw new Error("Cannot instantiate a singleton instance");
         }
         if(GlobalEngine.getFlashVar(FLASHVAR_CB_NAME))
         {
            this.m_max_log_entries = parseInt(GlobalEngine.getFlashVar(FLASHVAR_CB_NAME).toString());
         }
         this.m_transactionLogEntries = new Vector.<TransactionLogEntry>(this.m_max_log_entries,true);
         this.m_transactionSentLogEntries = new Vector.<TransactionLogEntry>(this.m_max_log_entries,true);
      }
      
      public static function get instance() : CBReportManager
      {
         if(!m_instance)
         {
            m_allowInstantiation = true;
            m_instance = new CBReportManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function addTransactionLogEntry(param1:Object, param2:Boolean = true) : TransactionLogEntry
      {
         var _loc3_:TransactionLogEntry = new TransactionLogEntry(param1);
         if(param2)
         {
            this.m_transactionSentLogEntries[this.m_nextSentEmpty++ % this.m_max_log_entries] = _loc3_;
         }
         else
         {
            this.m_transactionLogEntries[this.m_nextEmpty++ % this.m_max_log_entries] = _loc3_;
         }
         return _loc3_;
      }
      
      public function get transactionReport() : Object
      {
         var _loc4_:int = 0;
         var _loc5_:TransactionLogEntry = null;
         var _loc1_:Object = {};
         var _loc2_:int = 0;
         var _loc3_:int = this.m_nextEmpty;
         while(_loc2_ < this.m_max_log_entries)
         {
            _loc4_ = _loc3_ % this.m_max_log_entries;
            _loc5_ = this.m_transactionLogEntries[_loc4_];
            if(_loc5_)
            {
               _loc1_[_loc2_.toString()] = _loc5_.toAmfFormat();
            }
            _loc3_++;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get transactionSentReport() : Object
      {
         var _loc4_:int = 0;
         var _loc5_:TransactionLogEntry = null;
         var _loc1_:Object = {};
         var _loc2_:int = 0;
         var _loc3_:int = this.m_nextSentEmpty;
         while(_loc2_ < this.m_max_log_entries)
         {
            _loc4_ = _loc3_ % this.m_max_log_entries;
            _loc5_ = this.m_transactionSentLogEntries[_loc4_];
            if(_loc5_)
            {
               _loc1_[_loc2_.toString()] = _loc5_.toAmfFormat();
            }
            _loc3_++;
            _loc2_++;
         }
         return _loc1_;
      }
   }
}

