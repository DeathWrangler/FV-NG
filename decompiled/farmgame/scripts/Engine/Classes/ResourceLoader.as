package Engine.Classes
{
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import cipro.Profiler.RuntimeProfiler;
   import com.adobe.net.URI;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.utils.Timer;
   
   public class ResourceLoader implements IEventDispatcher
   {
      
      private var m_retryCount:int = 0;
      
      protected var m_url:String = null;
      
      private var m_domain:String = null;
      
      private var m_priority:int = 0;
      
      protected var m_loader:EventDispatcher = null;
      
      protected var m_completeCallback:Function = null;
      
      private var m_faultCallback:Function = null;
      
      protected var m_urlRequest:URLRequest = null;
      
      private var m_context:LoaderContext = null;
      
      private var m_dispatcher:EventDispatcher = null;
      
      private var m_dispatchedEvent:Boolean = false;
      
      private var m_timeoutTimer:Timer;
      
      private var m_receivedBytes:Boolean = false;
      
      private var m_loadStarted:Boolean = false;
      
      private var m_zaspLoadHandle:int = 0;
      
      public function ResourceLoader(param1:String, param2:int = 0, param3:Function = null, param4:Function = null)
      {
         super();
         var _loc5_:URI = new URI(param1);
         this.m_dispatcher = new EventDispatcher(this);
         this.m_domain = _loc5_.authority;
         this.m_url = param1;
         this.m_priority = param2;
         this.m_completeCallback = param3;
         this.m_faultCallback = param4;
         if(GlobalEngine.zaspManager)
         {
            this.m_zaspLoadHandle = GlobalEngine.zaspManager.zaspWaitStart(param2 == LoadingManager.PRIORITY_HIGH ? "HIPRI_ASSET" : "ASSET",this.m_url);
         }
         this.makeLoader();
         this.addEventListeners();
         try
         {
            Security.allowDomain("*");
         }
         catch(error:SecurityError)
         {
         }
         this.m_context = new LoaderContext();
         if(Security.sandboxType == Security.REMOTE)
         {
            this.m_context.securityDomain = SecurityDomain.currentDomain;
         }
         this.m_context.applicationDomain = ApplicationDomain.currentDomain;
         this.m_context.checkPolicyFile = true;
         this.m_urlRequest = new URLRequest(param1);
      }
      
      protected function makeLoader() : void
      {
         var _loc1_:Loader = new Loader();
         this.m_loader = _loc1_;
      }
      
      public function getLoader() : EventDispatcher
      {
         return this.m_loader;
      }
      
      public function getPriority() : Number
      {
         return this.m_priority;
      }
      
      public function getDomain() : String
      {
         return this.m_domain;
      }
      
      public function getURL() : String
      {
         return this.m_url;
      }
      
      public function getRetryCount() : int
      {
         return this.retryCount;
      }
      
      public function getbytesTotal() : int
      {
         return (this.m_loader as Loader).contentLoaderInfo.bytesTotal;
      }
      
      public function getStats() : Object
      {
         return {
            "url":this.getURL(),
            "priority":this.getPriority(),
            "retryCount":this.getRetryCount(),
            "bytesTotal":this.getbytesTotal()
         };
      }
      
      protected function getEventDispatcher() : EventDispatcher
      {
         return (this.m_loader as Loader).contentLoaderInfo;
      }
      
      public function startLoad() : void
      {
         if(this.m_loadStarted)
         {
            this.resetLoader();
         }
         this.m_loadStarted = true;
         try
         {
            this.chooseLoad();
            this.m_timeoutTimer = new Timer(this.timeoutLength);
            this.m_timeoutTimer.addEventListener(TimerEvent.TIMER,this.onTimeout);
            this.m_timeoutTimer.start();
            if(Boolean(GlobalEngine.zaspManager) && !this.m_zaspLoadHandle)
            {
               this.m_zaspLoadHandle = GlobalEngine.zaspManager.zaspWaitStart("ASSET",this.m_url);
            }
         }
         catch(error:Error)
         {
            GlobalEngine.log("Loader","Start load error: " + m_url + " : " + error.toString());
            dispatchFault(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,"ResourceLoader Dispatched IOError Event"),ErrorManager.ERROR_FAILED_TO_LOAD);
         }
      }
      
      protected function chooseLoad() : void
      {
         (this.m_loader as Loader).load(this.m_urlRequest,this.m_context);
      }
      
      protected function chooseClose() : void
      {
         (this.m_loader as Loader).close();
      }
      
      public function stopLoad() : void
      {
         this.stopTimeoutTimer();
         if(this.m_loader != null)
         {
            this.removeEventListeners();
            this.m_dispatchedEvent = true;
            try
            {
               this.chooseClose();
            }
            catch(error:Error)
            {
            }
         }
      }
      
      protected function resetLoader() : void
      {
         this.m_dispatchedEvent = false;
         this.m_loadStarted = false;
         this.removeEventListeners();
         try
         {
            this.chooseClose();
         }
         catch(error:Error)
         {
         }
         this.addEventListeners();
      }
      
      protected function get timeoutLength() : Number
      {
         return LoaderConstants.TIMEOUT_LENGTH;
      }
      
      protected function get retryCount() : int
      {
         return this.m_retryCount;
      }
      
      protected function set retryCount(param1:int) : void
      {
         this.m_retryCount = param1;
      }
      
      protected function onOpen(param1:Event) : void
      {
         GlobalEngine.log("Loader","Start load: " + this.m_url);
         this.stopTimeoutTimer();
      }
      
      private function stopTimeoutTimer() : void
      {
         if(this.m_zaspLoadHandle)
         {
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.zaspWaitEnd(this.m_zaspLoadHandle);
            }
            this.m_zaspLoadHandle = 0;
         }
         if(this.m_timeoutTimer)
         {
            this.m_timeoutTimer.stop();
            this.m_timeoutTimer.removeEventListener(TimerEvent.TIMER,this.onTimeout);
            this.m_timeoutTimer = null;
         }
      }
      
      private function onTimeout(param1:Event) : void
      {
         this.stopTimeoutTimer();
         if(this.m_dispatchedEvent == false)
         {
            GlobalEngine.log("Loader","Load timed out (try: " + this.retryCount + "): " + this.m_url);
         }
         if(this.retryCount >= LoaderConstants.MAX_RETRIES)
         {
            this.dispatchFault(param1,ErrorManager.ERROR_LOAD_TIMED_OUT);
         }
         else
         {
            ++this.retryCount;
            this.startLoad();
         }
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.ResourceLoaderOnComplete);
         this.stopTimeoutTimer();
         if(this.m_dispatchedEvent == false)
         {
            this.dispatchEvent(new Event(Event.COMPLETE));
            if(this.m_completeCallback != null)
            {
               this.invokeCallback(param1);
               this.m_completeCallback = null;
            }
            this.m_dispatchedEvent = true;
            this.removeEventListeners();
         }
         RuntimeProfiler.leave(_loc2_);
      }
      
      protected function invokeCallback(param1:Event) : void
      {
         this.m_completeCallback(param1);
      }
      
      protected function onProgress(param1:ProgressEvent) : void
      {
         this.m_receivedBytes = true;
         this.stopTimeoutTimer();
         var _loc2_:EventDispatcher = this.getEventDispatcher();
         _loc2_.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
      }
      
      private function dispatchFault(param1:Event, param2:int, param3:Object = null) : void
      {
         var _loc4_:String = null;
         this.stopTimeoutTimer();
         if(this.m_dispatchedEvent == false)
         {
            this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,"ResourceLoader Dispatched IOError Event"));
            _loc4_ = "Failed to load resource asset.";
            _loc4_ = _loc4_ + ",stackRoot=ResourceLoader.dispatchFault";
            _loc4_ = _loc4_ + (",loadErrorType=" + param2);
            _loc4_ = _loc4_ + (",url=" + this.m_url);
            ErrorManager.addError(_loc4_,param2,param3);
            if(this.m_faultCallback != null && param1 is IOErrorEvent)
            {
               this.m_faultCallback(param1);
            }
            this.m_dispatchedEvent = true;
         }
      }
      
      protected function onError(param1:IOErrorEvent) : void
      {
         this.stopTimeoutTimer();
         if(this.m_dispatchedEvent == false)
         {
            GlobalEngine.log("Loader","Load error (try: " + this.retryCount + "): " + this.m_url);
         }
         if(this.retryCount >= LoaderConstants.MAX_RETRIES)
         {
            this.dispatchFault(param1,ErrorManager.ERROR_LOAD_IO_ERROR);
         }
         else
         {
            ++this.retryCount;
            this.startLoad();
         }
      }
      
      protected function onSecurityError(param1:SecurityErrorEvent) : void
      {
         if(this.m_dispatchedEvent == false)
         {
            this.stopTimeoutTimer();
            if(this.m_dispatchedEvent == false)
            {
               GlobalEngine.log("Loader","Security Load error (try: " + this.retryCount + "): " + this.m_url);
            }
            if(this.retryCount >= LoaderConstants.MAX_RETRIES)
            {
               this.dispatchFault(param1,ErrorManager.ERROR_LOAD_SECURITY_ERROR);
            }
            else
            {
               ++this.retryCount;
               this.startLoad();
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(param1);
      }
      
      protected function addEventListeners() : void
      {
         var _loc1_:EventDispatcher = this.getEventDispatcher();
         _loc1_.addEventListener(Event.COMPLETE,this.onComplete);
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _loc1_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         _loc1_.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _loc1_.addEventListener(Event.OPEN,this.onOpen);
      }
      
      protected function removeEventListeners() : void
      {
         var _loc1_:EventDispatcher = this.getEventDispatcher();
         _loc1_.removeEventListener(Event.COMPLETE,this.onComplete);
         _loc1_.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _loc1_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         _loc1_.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _loc1_.removeEventListener(Event.OPEN,this.onOpen);
      }
   }
}

