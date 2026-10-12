package Engine.Transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   
   public class Transaction extends EventDispatcher
   {
      
      public static const NO_ERROR:int = 0;
      
      public static const ERROR_AUTH:int = 1;
      
      public static const OUTDATED_GAME_VERSION:int = 10;
      
      public static const AUTH_NO_USER_ID:int = 26;
      
      public static const AUTH_NO_SESSION:int = 27;
      
      public static const RETRY_TRANSACTION:int = 28;
      
      public static const FORCE_RELOAD:int = 29;
      
      public static const MULTIPLE_GAME_INSTANCES:int = 38;
      
      public static const IGNORE_TRANSACTION:int = 39;
      
      public static const CONNECTION_DROPPED:int = 41;
      
      public static const PHP_FATAL:int = 42;
      
      public static const RETRY_LOGGING:int = 43;
      
      protected static var m_transactionId:uint = 1;
      
      protected const ERROR_USER_DATA_MISSING:int = 2;
      
      protected const ERROR_INVALID_STATE:int = 3;
      
      protected const INVALID_DATA:int = 4;
      
      protected const MISSING_DATA:int = 5;
      
      protected const ACTION_CLASS_ERROR:int = 6;
      
      protected const ACTION_METHOD_ERROR:int = 7;
      
      protected const ERROR_RESOURCE_DATA_MISSING:int = 8;
      
      protected const NOT_ENOUGH_MONEY:int = 9;
      
      protected const TRANSPORT_FAILURE_GENERAL:int = 25;
      
      protected var m_id:Number;
      
      private var m_canPerform:Boolean = true;
      
      protected var m_functionName:String;
      
      protected var m_rawResult:Object = null;
      
      protected var m_queueTime:Number = 0;
      
      protected var m_batchTime:Number = 0;
      
      protected var m_completeTime:Number = 0;
      
      protected var m_onFaultResult:Object = null;
      
      protected var m_amfWaitHandle:int = 0;
      
      protected var m_preFetch:Boolean = false;
      
      public function Transaction()
      {
         super(this);
         this.m_id = Utilities.generateUniqueId();
      }
      
      public function getId() : Number
      {
         return this.m_id;
      }
      
      public function postPrefetchActions(param1:Object) : void
      {
      }
      
      public function isPrefetch() : Boolean
      {
         return this.m_preFetch;
      }
      
      protected function signedCall(param1:String, ... rest) : void
      {
         this.m_functionName = param1;
         this.logEvent("Batching AMF call");
         TransactionManager.batchCall(this,param1,rest,this.onAmfComplete,this.onAmfFault);
      }
      
      public function startZaspLogging() : void
      {
         if(GlobalEngine.zaspManager)
         {
            this.m_amfWaitHandle = GlobalEngine.zaspManager.zaspWaitStart("AMF-STP",getQualifiedClassName(this));
         }
      }
      
      public function endZaspLogging() : void
      {
         if(this.m_amfWaitHandle)
         {
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.zaspWaitEnd(this.m_amfWaitHandle);
            }
            this.m_amfWaitHandle = 0;
         }
      }
      
      public function perform() : void
      {
      }
      
      public function set canPerform(param1:Boolean) : void
      {
         this.m_canPerform = param1;
      }
      
      public function get canPerform() : Boolean
      {
         return this.m_canPerform;
      }
      
      public function get rawResult() : Object
      {
         return this.m_rawResult;
      }
      
      public function get faultResult() : Object
      {
         return this.m_onFaultResult;
      }
      
      protected function onAmfComplete(param1:Object) : void
      {
         this.m_rawResult = param1;
         this.endZaspLogging();
         if(param1)
         {
            if(param1.serverTime != null)
            {
               GlobalEngine.setInternalServerTime(param1.serverTime);
            }
            if(param1.isDST != null)
            {
               if(Number(param1.isDST) > 0)
               {
                  GlobalEngine.setIsDSTFlag(true);
               }
               else
               {
                  GlobalEngine.setIsDSTFlag(false);
               }
            }
            if(param1.errorType == NO_ERROR)
            {
               this.logEvent("Complete");
               if(param1.data != null)
               {
                  this.onComplete(param1.data);
               }
            }
            else
            {
               if(param1.errorData)
               {
                  this.logEvent("Error " + param1.errorType + " " + param1.errorData);
               }
               else
               {
                  this.logEvent("Error " + param1.errorType);
               }
               this.onFault(param1.errorType,param1.errorData);
            }
         }
      }
      
      protected function logEvent(param1:String) : void
      {
         GlobalEngine.log("Transaction",this.getId() + " (" + this.m_functionName + "): " + param1);
      }
      
      public function getFunctionName() : String
      {
         return this.m_functionName;
      }
      
      public function markQueued() : void
      {
         this.m_queueTime = this.getTime();
      }
      
      public function markBatched() : void
      {
         this.m_batchTime = this.getTime();
      }
      
      public function markComplete() : void
      {
         this.m_completeTime = this.getTime();
      }
      
      public function getQueueDuration() : Number
      {
         return this.m_batchTime - this.m_queueTime;
      }
      
      public function getExecutionDuration() : Number
      {
         return this.m_completeTime - this.m_batchTime;
      }
      
      public function shouldHaveOwnBatch() : Boolean
      {
         return false;
      }
      
      private function getTime() : Number
      {
         var _loc1_:Date = new Date();
         return _loc1_.getTime() / 1000;
      }
      
      protected function onAmfFault(param1:Object, param2:int = 25, param3:String = "onAmfFault was called") : void
      {
         var _loc4_:String = null;
         this.logEvent("Fault " + param1);
         if(param1)
         {
            this.m_onFaultResult = param1;
         }
         else
         {
            this.m_onFaultResult = param3;
         }
         this.endZaspLogging();
         for(_loc4_ in param1)
         {
            GlobalEngine.log("Transaction",_loc4_ + " : " + param1[_loc4_]);
         }
         this.onFault(param2,param3);
      }
      
      protected function onComplete(param1:Object) : void
      {
      }
      
      public function isFaultable() : Boolean
      {
         return true;
      }
      
      protected function onFault(param1:int, param2:String) : void
      {
      }
      
      public function isInitTransaction() : Boolean
      {
         return false;
      }
      
      public function isPostInitTransaction() : Boolean
      {
         return false;
      }
   }
}

