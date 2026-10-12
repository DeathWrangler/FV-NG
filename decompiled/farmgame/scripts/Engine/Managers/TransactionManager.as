package Engine.Managers
{
   import Engine.Classes.AMFConnection;
   import Engine.Classes.ZEngineCoreModules;
   import Engine.Events.TransactionEvent;
   import Engine.Events.TransactionFaultEvent;
   import Engine.Transactions.Transaction;
   import Engine.Transactions.TransactionLogEntry;
   import cipro.Profiler.RuntimeModule;
   import cipro.Profiler.RuntimeProfiler;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TransactionManager extends EventDispatcher
   {
      
      private static var m_connection:AMFConnection;
      
      private static var m_droppedConnectionMaxRetries:int;
      
      private static var m_instance:TransactionManager;
      
      private static const AMF_MAX_PER_BATCH:int = 8;
      
      private static const AMF_MAX_RETRIES:int = 2;
      
      private static const NUM_MSECS_IN_SECOND:int = 1000;
      
      private static const AMF_DROPPED_CONNECTION_MAX_RETRIES:int = 10;
      
      private static const AMF_DROPPED_CONNECTION_MAX_RETRIES_FLASH_VAR:String = "AMF_DROPPED_CONNECTION_MAX_RETRIES";
      
      private static var m_transactions:Array = [];
      
      private static var m_batchedAmfCalls:Array = [];
      
      private static var m_sequenceID:String = "0";
      
      private static var m_sequenceNumber:int = 0;
      
      private static var m_amfBatchTimer:Timer = null;
      
      private static var m_retryTimer:Timer = null;
      
      private static var m_amfMaxWait:Number = 5000;
      
      private static var m_ageOfOldestCall:Number = 0;
      
      private static var m_numBatchCalls:int = 0;
      
      private static var m_retrySequence:int = 0;
      
      private static var m_retryCount:int = 0;
      
      protected static var m_lastFunc:String = "0";
      
      protected static var m_lastError:String = "0";
      
      protected static var m_lastMsg:String = "0";
      
      protected static var m_inSync:Boolean = true;
      
      protected static var m_queueLimitExceeded:Boolean = false;
      
      private static var m_initialized:Boolean = false;
      
      private static var m_postInitQueued:Boolean = false;
      
      private static var m_addtionalSignedParams:Object = {};
      
      private static var s_transactionModules:Object = {};
      
      private static const TRANSACTION_COMPLETE:String = "end";
      
      private static const PROFILE_KEY_LIMIT:int = 38;
      
      private static var m_reconnecting:Boolean = false;
      
      private static var m_tBatchDebugInfo:Array = [];
      
      private static var s_batchLimiter:Function = null;
      
      private static var s_batchLimiterFunctionExceptions:Object = null;
      
      private static var s_batchLimiterVerboseData:Boolean = false;
      
      public function TransactionManager()
      {
         super();
      }
      
      public static function initialize() : void
      {
         var _loc2_:String = null;
         var _loc1_:Object = GlobalEngine.zyParams;
         for(_loc2_ in _loc1_)
         {
            m_addtionalSignedParams[_loc2_] = _loc1_[_loc2_];
         }
         if(GlobalEngine.getFlashVar("FLASHVAR_TRANSACTION_MAX_WAIT"))
         {
            m_amfMaxWait = parseInt(GlobalEngine.getFlashVar("FLASHVAR_TRANSACTION_MAX_WAIT").toString());
         }
         if(Boolean(GlobalEngine.getFlashVar("sequence_id")) && m_sequenceID == "0")
         {
            m_sequenceID = GlobalEngine.getFlashVar("sequence_id").toString();
         }
      }
      
      public static function getInstance() : TransactionManager
      {
         if(m_instance == null)
         {
            m_instance = new TransactionManager();
         }
         return m_instance;
      }
      
      public static function get lastError() : String
      {
         return m_lastError;
      }
      
      public static function get lastFunc() : String
      {
         return m_lastFunc;
      }
      
      public static function get lastMsg() : String
      {
         return m_lastMsg;
      }
      
      public static function set lastError(param1:String) : void
      {
         m_lastError = param1;
      }
      
      public static function set lastMsg(param1:String) : void
      {
         m_lastMsg = param1;
      }
      
      public static function set lastFunc(param1:String) : void
      {
         m_lastFunc = param1;
      }
      
      public static function get inSync() : Boolean
      {
         return m_inSync;
      }
      
      public static function set additionalSignedParams(param1:Object) : void
      {
         m_addtionalSignedParams = param1;
      }
      
      public static function get additionalSignedParams() : Object
      {
         return m_addtionalSignedParams;
      }
      
      public static function set batchLimiter(param1:Function) : void
      {
         s_batchLimiter = param1;
      }
      
      public static function get batchLimiterFunctionExceptions() : Object
      {
         return s_batchLimiterFunctionExceptions;
      }
      
      public static function set batchLimiterFunctionExceptions(param1:Object) : void
      {
         s_batchLimiterFunctionExceptions = param1;
      }
      
      public static function set batchLimiterVerboseData(param1:Boolean) : void
      {
         s_batchLimiterVerboseData = param1;
      }
      
      public static function addTransaction(param1:Transaction, param2:Boolean = false) : void
      {
         var _loc3_:int = RuntimeProfiler.enter(ZEngineCoreModules.TransactionManagerAddTransaction);
         if(param1.isInitTransaction() == true)
         {
            m_initialized = true;
         }
         if(!canSendTransactions() && Config.DEBUG_MODE)
         {
         }
         if(m_amfBatchTimer == null)
         {
            m_amfBatchTimer = new Timer(1000);
            m_amfBatchTimer.addEventListener(TimerEvent.TIMER,onAmfBatchSend);
            m_amfBatchTimer.start();
         }
         if(inSync == true)
         {
            if(m_transactions.length == 0)
            {
               m_ageOfOldestCall = GlobalEngine.serverTime;
            }
            if(param1.isPostInitTransaction())
            {
               m_transactions.unshift(param1);
               m_postInitQueued = true;
            }
            else
            {
               m_transactions.push(param1);
            }
            param1.markQueued();
            CBReportManager.instance.addTransactionLogEntry(param1,false);
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.ADDED,param1));
            if(param2)
            {
               param1.startZaspLogging();
               sendAllTransactions(false);
            }
            else if(m_transactions.length >= AMF_MAX_PER_BATCH && m_batchedAmfCalls.length == 0 && m_postInitQueued)
            {
               sendAllTransactions(true);
            }
            if(m_transactions.length >= getMaxTransactionQueueSize() && m_queueLimitExceeded == false)
            {
               getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.QUEUE_LIMIT_EXCEEDED));
               m_queueLimitExceeded = true;
            }
         }
         RuntimeProfiler.leave(_loc3_);
      }
      
      private static function getMaxTransactionQueueSize() : int
      {
         var _loc1_:int = 50;
         var _loc2_:Object = GlobalEngine.getFlashVar("MAX_TRANSACTION_DEPTH");
         if(_loc2_ != null)
         {
            _loc1_ = int(uint(_loc2_));
         }
         return _loc1_;
      }
      
      private static function incrementSequence() : int
      {
         ++m_sequenceNumber;
         return m_sequenceNumber;
      }
      
      private static function getSequenceID() : String
      {
         return m_sequenceID;
      }
      
      public static function setSequenceID(param1:String) : void
      {
         m_sequenceID = param1;
      }
      
      private static function generateSignedParams() : Object
      {
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         var _loc1_:Object = new Object();
         for(_loc2_ in m_addtionalSignedParams)
         {
            _loc1_[_loc2_] = m_addtionalSignedParams[_loc2_];
         }
         _loc3_ = GlobalEngine.getFlashVar("flashRevision");
         _loc1_.flashRevision = null;
         if(_loc3_ != null)
         {
            _loc1_.flashRevision = _loc3_.toString();
         }
         var _loc4_:Object = GlobalEngine.getFlashVar("configRevision");
         _loc1_.configRevision = null;
         if(_loc4_ != null)
         {
            _loc1_.configRevision = _loc4_.toString();
         }
         var _loc5_:Object = GlobalEngine.getFlashVar("phpRevision");
         _loc1_.phpRevision = null;
         if(_loc5_ != null)
         {
            _loc1_.phpRevision = _loc5_.toString();
         }
         return _loc1_;
      }
      
      public static function batchCall(param1:Transaction, param2:String, param3:Array, param4:Function, param5:Function = null) : void
      {
         var _loc6_:Object = null;
         if(inSync)
         {
            _loc6_ = {};
            _loc6_["stamp"] = GlobalEngine.serverTime;
            _loc6_["functionName"] = param2;
            _loc6_["params"] = param3;
            _loc6_["onSuccess"] = param4;
            _loc6_["onFailure"] = param5;
            _loc6_["transaction"] = param1;
            _loc6_["sequence"] = TransactionManager.incrementSequence();
            _loc6_["sequenceID"] = TransactionManager.getSequenceID();
            _loc6_["shouldHaveOwnBatch"] = param1.shouldHaveOwnBatch();
            param1.markBatched();
            m_batchedAmfCalls.push(_loc6_);
         }
         else
         {
            ErrorManager.addError("Unable to batch call because client is out-of-sync! (function: " + param2 + ")");
         }
      }
      
      private static function onAmfBatchSend(param1:Event = null, param2:Boolean = false, param3:Boolean = false) : void
      {
         var timeSinceLastCall:Number = NaN;
         var signedParams:Object = null;
         var batchedCallInfo:Array = null;
         var lastTransactionRecord:TransactionLogEntry = null;
         var batchX:int = 0;
         var numTransactions:int = 0;
         var transaction:Transaction = null;
         var shouldHaveOwnBatch:Boolean = false;
         var call:Object = null;
         var obj:Object = null;
         var strs:String = null;
         var e:Event = param1;
         var forceSend:Boolean = param2;
         var retry:Boolean = param3;
         var profCookie:int = RuntimeProfiler.enter(ZEngineCoreModules.TransactionManagerOnAmfBatchSend);
         if(m_batchedAmfCalls.length == 0 && m_transactions.length > 0 || retry)
         {
            timeSinceLastCall = GlobalEngine.serverTime - m_ageOfOldestCall;
            if(m_ageOfOldestCall == 0 || timeSinceLastCall >= m_amfMaxWait || forceSend == true)
            {
               m_amfBatchTimer.stop();
               if(m_batchedAmfCalls.length == 0 || Boolean(m_batchedAmfCalls[0].hasOwnProperty("shouldHaveOwnBatch")) && Boolean(!m_batchedAmfCalls[0].shouldHaveOwnBatch))
               {
                  numTransactions = 0;
                  while(m_transactions.length > 0 && m_batchedAmfCalls.length < AMF_MAX_PER_BATCH)
                  {
                     transaction = m_transactions[0];
                     shouldHaveOwnBatch = transaction.shouldHaveOwnBatch();
                     if(!shouldHaveOwnBatch || numTransactions == 0)
                     {
                        m_transactions.shift();
                        if(transaction.canPerform)
                        {
                           transaction.perform();
                           numTransactions++;
                        }
                     }
                     if(shouldHaveOwnBatch && numTransactions > 0)
                     {
                        break;
                     }
                  }
               }
               GlobalEngine.log("AMFBatch","Executing " + m_batchedAmfCalls.length + " in a batch");
               signedParams = TransactionManager.generateSignedParams();
               batchedCallInfo = new Array();
               lastTransactionRecord = null;
               batchX = 0;
               while(batchX < m_batchedAmfCalls.length)
               {
                  call = m_batchedAmfCalls[batchX];
                  batchedCallInfo.push({
                     "functionName":call["functionName"],
                     "params":call["params"],
                     "sequence":call["sequence"],
                     "sequenceID":call["sequenceID"]
                  });
                  if(!retry)
                  {
                     lastTransactionRecord = CBReportManager.instance.addTransactionLogEntry(m_batchedAmfCalls[batchX]);
                  }
                  batchX++;
               }
               if(lastTransactionRecord)
               {
                  lastTransactionRecord.setEndOfBatch();
               }
               if(m_connection == null)
               {
                  m_connection = new AMFConnection(onAmfBatchComplete,onAmfBatchFault,onAmfBatchConnectionDropped);
               }
               if(s_batchLimiter is Function)
               {
                  try
                  {
                     obj = s_batchLimiter.call(null,batchedCallInfo,s_batchLimiterVerboseData);
                     if(obj.hasOwnProperty("str1"))
                     {
                        signedParams.batchLimit1 = obj.str1;
                     }
                     if(obj.hasOwnProperty("str2"))
                     {
                        signedParams.batchLimit2 = obj.str2;
                     }
                     if(obj.hasOwnProperty("str3"))
                     {
                        signedParams.str3 = obj.str3;
                     }
                  }
                  catch(err:Error)
                  {
                     strs = "";
                     for each(obj in batchedCallInfo)
                     {
                        strs += obj.functionName + ", ";
                     }
                     ErrorManager.addError(err.message + " in batch: " + strs);
                  }
               }
               m_connection.call.apply(m_connection,[GlobalEngine.engineOptions.baseService,signedParams,batchedCallInfo,m_retryCount]);
               m_ageOfOldestCall = GlobalEngine.serverTime;
               m_amfBatchTimer.start();
            }
         }
         RuntimeProfiler.leave(profCookie);
      }
      
      private static function needResultBySequenceNumber(param1:int) : Boolean
      {
         var _loc2_:Boolean = false;
         if(m_batchedAmfCalls.length > 0)
         {
            _loc2_ = m_batchedAmfCalls[0]["sequence"] <= param1;
         }
         return _loc2_;
      }
      
      private static function onAmfBatchComplete(param1:Object) : void
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Function = null;
         var _loc12_:Transaction = null;
         var _loc13_:int = 0;
         var _loc14_:TransactionEvent = null;
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.TransactionManagerOnAmfBatchComplete);
         if(m_reconnecting)
         {
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.RECONNECTED,null));
            m_reconnecting = false;
         }
         var _loc3_:Boolean = false;
         var _loc4_:int = Transaction.NO_ERROR;
         var _loc5_:String = "batch";
         var _loc6_:String = "";
         if(param1 != null && param1.errorType == Transaction.NO_ERROR)
         {
            _loc7_ = param1.data as Array;
            if(_loc7_ != null && _loc7_.length == m_batchedAmfCalls.length)
            {
               if(param1.zySig)
               {
                  GlobalEngine.zyParams = param1.zySig;
               }
               _loc8_ = 0;
               for(; _loc8_ < _loc7_.length; _loc8_++)
               {
                  param1 = _loc7_[_loc8_];
                  _loc9_ = {};
                  _loc10_ = true;
                  if(param1.sequenceNumber != null)
                  {
                     if(!needResultBySequenceNumber(param1.sequenceNumber))
                     {
                        continue;
                     }
                  }
                  if(param1.errorType == Transaction.IGNORE_TRANSACTION)
                  {
                     _loc10_ = false;
                  }
                  if(param1.errorType == Transaction.RETRY_TRANSACTION)
                  {
                     _loc4_ = int(param1.errorType);
                     _loc6_ = param1.errorData;
                     _loc9_ = m_batchedAmfCalls[0];
                     _loc5_ = _loc9_["functionName"];
                     _loc3_ = true;
                     break;
                  }
                  if(param1.errorType == Transaction.FORCE_RELOAD || param1.errorType == Transaction.MULTIPLE_GAME_INSTANCES)
                  {
                     _loc4_ = int(param1.errorType);
                     _loc6_ = param1.errorData;
                     m_retryCount = AMF_MAX_RETRIES + 1;
                     _loc3_ = true;
                     break;
                  }
                  _loc9_ = m_batchedAmfCalls.shift();
                  _loc11_ = _loc9_["onSuccess"];
                  _loc12_ = _loc9_["transaction"] as Transaction;
                  _loc13_ = RuntimeProfiler.enter(getTransactionSubModule(ZEngineCoreModules.TransactionManagerOnAmfBatchSend,_loc12_,TRANSACTION_COMPLETE));
                  if(_loc10_)
                  {
                     _loc11_.apply(_loc12_,[param1]);
                  }
                  if(m_numBatchCalls > 0)
                  {
                     --m_numBatchCalls;
                  }
                  _loc12_.markComplete();
                  if(!_loc12_.isPrefetch())
                  {
                     getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED,_loc12_));
                  }
                  RuntimeProfiler.leave(_loc13_);
               }
               if(m_numBatchCalls > 0)
               {
                  onAmfBatchSend(null,true);
               }
            }
            else
            {
               GlobalEngine.log("AMFBatch","ERROR - batch results is not an array of length " + m_batchedAmfCalls.length);
            }
         }
         else if(param1 != null)
         {
            _loc4_ = param1.errorType ? int(param1.errorType) : -1;
            _loc6_ = param1.errorData ? param1.errorData : "NO DATA";
            if(_loc4_ == Transaction.AUTH_NO_USER_ID || _loc4_ == Transaction.AUTH_NO_SESSION)
            {
               m_inSync = false;
            }
            else if(_loc4_ == Transaction.OUTDATED_GAME_VERSION)
            {
               m_inSync = false;
               _loc14_ = new TransactionEvent(TransactionEvent.VERSION_MISMATCH);
               if(param1["enhancedMessage"])
               {
                  _loc14_.message = param1["enhancedMessage"];
               }
               getInstance().dispatchEvent(_loc14_);
            }
            else
            {
               _loc3_ = true;
            }
         }
         else
         {
            _loc4_ = Transaction.RETRY_TRANSACTION;
            _loc6_ = "noResult";
            _loc3_ = true;
         }
         if(_loc3_ == true)
         {
            m_lastError = _loc4_.toString();
            m_lastFunc = _loc5_;
            m_lastMsg = _loc6_;
            onAmfBatchFault(null,_loc4_,_loc6_);
         }
         else
         {
            if(m_retryCount > 0)
            {
               logTransactionBatchDebugInfo(_loc6_);
            }
            sendAndClearTransactionBatchDebugInfo();
            m_retrySequence = 0;
            m_retryCount = 0;
         }
         if(m_transactions.length < getMaxTransactionQueueSize() && m_queueLimitExceeded)
         {
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.QUEUE_LIMIT_NORMAL));
            m_queueLimitExceeded = false;
         }
         RuntimeProfiler.leave(_loc2_);
      }
      
      private static function logTransactionBatchDebugInfo(param1:String) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Object = {};
         _loc2_["retryCount"] = m_retryCount.toString();
         _loc2_["resultError"] = param1;
         _loc2_["timestamp"] = new Date().time;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < m_batchedAmfCalls.length)
         {
            _loc5_ = m_batchedAmfCalls[_loc4_];
            _loc3_ += "index:" + _loc4_ + ",functionName:" + _loc5_["functionName"] + ",";
            _loc3_ += "sequence:" + _loc5_["sequence"] + ",";
            _loc3_ += "sequenceID:" + _loc5_["sequenceID"] + "\n";
            _loc4_++;
         }
         if(_loc3_)
         {
            _loc2_["batchInfo"] = _loc3_;
            m_tBatchDebugInfo.push(_loc2_);
         }
      }
      
      private static function sendAndClearTransactionBatchDebugInfo() : void
      {
         if(m_tBatchDebugInfo.length > 0)
         {
            if(m_retryCount > 0)
            {
               getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.RETRY_LOGGING,null,Transaction.RETRY_LOGGING,m_tBatchDebugInfo));
            }
            m_tBatchDebugInfo = new Array();
         }
      }
      
      private static function getTransactionSubModule(param1:RuntimeModule, param2:Transaction, param3:String) : RuntimeModule
      {
         var _loc8_:String = null;
         var _loc4_:RuntimeModule = null;
         var _loc5_:String = param1.name;
         var _loc6_:Object = s_transactionModules[_loc5_];
         if(!_loc6_)
         {
            s_transactionModules[_loc5_] = {};
         }
         var _loc7_:String = param2.getFunctionName();
         _loc7_ = (Boolean(_loc7_)) && _loc7_.length > PROFILE_KEY_LIMIT ? _loc7_.substr(0,PROFILE_KEY_LIMIT) : _loc7_;
         if(_loc7_)
         {
            _loc8_ = param3 + "-" + _loc7_;
            _loc4_ = s_transactionModules[_loc8_];
            if(!_loc4_)
            {
               _loc4_ = s_transactionModules[_loc8_] = RuntimeProfiler.registerModule(_loc8_);
            }
         }
         return _loc4_;
      }
      
      private static function onAmfBatchFault(param1:Object, param2:int, param3:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Transaction = null;
         var _loc6_:Function = null;
         var _loc7_:Boolean = false;
         if(m_batchedAmfCalls.length)
         {
            logTransactionBatchDebugInfo(param3);
            m_retrySequence = m_batchedAmfCalls[0].sequence;
            ++m_retryCount;
            if(m_retryCount <= AMF_MAX_RETRIES)
            {
               onRetryPause();
            }
            else
            {
               _loc4_ = m_batchedAmfCalls.shift();
               _loc5_ = _loc4_["transaction"] as Transaction;
               if(_loc5_)
               {
                  _loc7_ = _loc5_.isFaultable();
                  if((_loc7_) || param2 == Transaction.MULTIPLE_GAME_INSTANCES)
                  {
                     getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.FAULT,_loc4_["transaction"],param2,param3));
                     m_inSync = false;
                  }
               }
               _loc6_ = _loc4_["onFailure"];
               _loc6_.apply(_loc4_["transaction"],[param1,param2,param3]);
               sendAndClearTransactionBatchDebugInfo();
            }
         }
         GlobalEngine.log("AMFBatch","Batch exec FAIL result = " + param1);
      }
      
      private static function onAmfBatchConnectionDropped(param1:String) : void
      {
         var _loc2_:Object = null;
         m_reconnecting = true;
         logTransactionBatchDebugInfo("connectionDropped: " + param1);
         if(!m_droppedConnectionMaxRetries)
         {
            _loc2_ = GlobalEngine.getFlashVar(AMF_DROPPED_CONNECTION_MAX_RETRIES_FLASH_VAR);
            if(_loc2_)
            {
               m_droppedConnectionMaxRetries = parseInt(_loc2_.toString());
            }
            else
            {
               m_droppedConnectionMaxRetries = AMF_DROPPED_CONNECTION_MAX_RETRIES;
            }
         }
         if(++m_retryCount <= m_droppedConnectionMaxRetries)
         {
            if(m_retryCount == Math.floor(m_droppedConnectionMaxRetries / 2))
            {
               getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.RECONNECTING,null,Transaction.CONNECTION_DROPPED,"HTTP " + param1));
            }
            onRetryPause(false);
         }
         else
         {
            getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.FAULT,null,Transaction.CONNECTION_DROPPED,"HTTP " + param1));
         }
      }
      
      public static function sendAllTransactions(param1:Boolean) : void
      {
         if(param1)
         {
            m_numBatchCalls = m_transactions.length;
         }
         onAmfBatchSend(null,true);
      }
      
      private static function onRetryPause(param1:Boolean = true) : void
      {
         var _loc2_:Number = 1;
         if(param1)
         {
            _loc2_ = Math.pow(2,m_retryCount);
         }
         var _loc3_:Number = _loc2_ * NUM_MSECS_IN_SECOND;
         if(Config.DEBUG_MODE == true)
         {
            _loc3_ = 1;
         }
         if(m_retryTimer == null)
         {
            m_retryTimer = new Timer(_loc3_,1);
            m_retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onRetrySend);
            m_retryTimer.start();
            GlobalEngine.log("AMFBatch","Waiting " + _loc3_ + "ms before retry");
         }
      }
      
      private static function onRetrySend(param1:TimerEvent) : void
      {
         if(m_retryTimer != null)
         {
            m_retryTimer.stop();
            m_retryTimer = null;
         }
         GlobalEngine.log("AMFBatch","Retrying transaction #" + m_retrySequence + ". " + m_retryCount + " time(s)");
         onAmfBatchSend(null,true,true);
      }
      
      public static function retryReconnect(param1:Event) : void
      {
         m_retryCount = 1;
         getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.RECONNECTING,null,Transaction.CONNECTION_DROPPED,"retry reconnect"));
         onRetrySend(null);
      }
      
      public static function canSendTransactions() : Boolean
      {
         return m_initialized;
      }
      
      public static function disable() : void
      {
         m_amfBatchTimer.stop();
      }
      
      public static function enable() : void
      {
         m_amfBatchTimer.start();
      }
      
      public function getCurrentTransactionSize() : int
      {
         return m_transactions.length;
      }
   }
}

