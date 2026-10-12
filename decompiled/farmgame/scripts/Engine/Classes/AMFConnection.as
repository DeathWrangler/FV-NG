package Engine.Classes
{
   import Engine.Transactions.Transaction;
   import cipro.Profiler.RuntimeProfiler;
   import flash.events.AsyncErrorEvent;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.NetConnection;
   import flash.net.Responder;
   
   public class AMFConnection
   {
      
      protected var m_netConnection:NetConnection = new NetConnection();
      
      protected var m_responder:Responder;
      
      protected var m_statusCallback:Function = null;
      
      protected var m_resultCallback:Function = null;
      
      protected var m_droppedConnectionCallback:Function = null;
      
      private var m_shouldIgnoreNetworkChange:Boolean;
      
      private const SHOULD_IGNORE_NETWORK_CHANGE_RUNTIME:String = "OPS_SHOULD_IGNORE_NETWORK_CHANGE_TEMPRT";
      
      protected var m_functionName:String;
      
      private const TRANSPORT_FAILURE_AMF_FAULT:int = 1;
      
      private const TRANSPORT_FAILURE_NET_STATUS:int = 2;
      
      private const TRANSPORT_FAILURE_IO_ERROR:int = 3;
      
      private const TRANSPORT_FAILURE_ASYNC_ERROR:int = 4;
      
      private const TRANSPORT_FAILURE_SECURITY_ERROR:int = 5;
      
      private const NET_STATUS_CALL_FAILED:String = "NetConnection.Call.Failed";
      
      private const NET_STATUS_NETWORK_CHANGED:String = "NetConnection.Connect.NetworkChange";
      
      private const HTTP_STATUS_INTERNAL_SERVER_ERROR:String = "500";
      
      public function AMFConnection(param1:Function, param2:Function, param3:Function)
      {
         super();
         this.m_statusCallback = param2;
         this.m_resultCallback = param1;
         this.m_droppedConnectionCallback = param3;
         this.m_responder = new Responder(this.onResult,this.onFault);
         this.m_netConnection.connect(Config.SERVICES_GATEWAY_PATH);
         this.m_netConnection.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.m_netConnection.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
         this.m_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onAsyncError,false,0,true);
         this.m_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError,false,0,true);
      }
      
      protected function onResult(param1:Object) : void
      {
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.AMFConnectionOnResult);
         this.logEvent("Result received.");
         if(this.m_resultCallback != null)
         {
            this.m_resultCallback(param1);
         }
         RuntimeProfiler.leave(_loc2_);
      }
      
      protected function onFault(param1:Object) : void
      {
         var _loc2_:String = null;
         this.logEvent("Fault received.");
         for(_loc2_ in param1)
         {
            this.logEvent(_loc2_ + ": " + param1[_loc2_]);
         }
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_AMF_FAULT,"transport failure");
         }
      }
      
      protected function onAsyncError(param1:AsyncErrorEvent) : void
      {
         this.logEvent("Async error: " + param1.toString());
         var _loc2_:String = "unknown error";
         if(param1.error)
         {
            _loc2_ = param1.error.toString();
         }
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_ASYNC_ERROR,"async failure: " + _loc2_);
         }
      }
      
      protected function onIOError(param1:IOErrorEvent) : void
      {
         this.logEvent("IO error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_IO_ERROR,"io failure: " + param1.toString());
         }
      }
      
      protected function onNetStatus(param1:NetStatusEvent) : void
      {
         var _loc6_:RegExp = null;
         this.logEvent("Net status error: " + param1.toString());
         var _loc2_:String = "unknown code";
         var _loc3_:String = "unknown level";
         var _loc4_:String = null;
         var _loc5_:int = this.TRANSPORT_FAILURE_NET_STATUS;
         if(!this.m_shouldIgnoreNetworkChange)
         {
            this.m_shouldIgnoreNetworkChange = GlobalEngine.isFlashVarSetAndTrue(this.SHOULD_IGNORE_NETWORK_CHANGE_RUNTIME);
         }
         if(param1.info)
         {
            if(param1.info.code)
            {
               _loc2_ = param1.info.code;
            }
            if(param1.info.level)
            {
               _loc3_ = param1.info.level;
            }
            if(param1.info.description)
            {
               _loc6_ = /^HTTP: Status (\d+)$/;
               _loc4_ = (param1.info.description as String).replace(_loc6_,"$1");
            }
         }
         if(Boolean(_loc2_ == this.NET_STATUS_CALL_FAILED) && (Boolean(_loc4_ && _loc4_ != this.HTTP_STATUS_INTERNAL_SERVER_ERROR)) && this.m_droppedConnectionCallback != null)
         {
            this.m_droppedConnectionCallback(_loc4_);
         }
         else if((_loc2_ != this.NET_STATUS_NETWORK_CHANGED || !this.m_shouldIgnoreNetworkChange) && this.m_statusCallback != null)
         {
            if(Boolean(_loc4_) && _loc4_ == this.HTTP_STATUS_INTERNAL_SERVER_ERROR)
            {
               _loc5_ = Transaction.PHP_FATAL;
            }
            this.m_statusCallback(param1,_loc5_,"net status event: " + _loc3_ + ", " + _loc2_ + ", HTTP " + _loc4_);
         }
      }
      
      protected function onSecurityError(param1:SecurityErrorEvent) : void
      {
         this.logEvent("Security error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_SECURITY_ERROR,"security failure: " + param1.toString());
         }
      }
      
      protected function logEvent(param1:String) : void
      {
         GlobalEngine.log("AMFConnection",this.m_functionName + ": " + param1);
      }
      
      public function call(param1:String, ... rest) : void
      {
         var _loc3_:Array = [param1,this.m_responder];
         this.m_functionName = param1;
         _loc3_ = _loc3_.concat(rest);
         this.m_netConnection.call.apply(this.m_netConnection,_loc3_);
         this.logEvent("Call: " + param1);
      }
   }
}

