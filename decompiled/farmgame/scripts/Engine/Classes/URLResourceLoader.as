package Engine.Classes
{
   import cipro.Profiler.RuntimeProfiler;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   
   public class URLResourceLoader extends ResourceLoader
   {
      
      private var m_internalLoader:URLLoader = null;
      
      private var m_bytesTotal:int = 0;
      
      public function URLResourceLoader(param1:String, param2:int = 0, param3:Function = null, param4:Function = null)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function makeLoader() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.dataFormat = URLLoaderDataFormat.BINARY;
         m_loader = _loc1_;
      }
      
      override public function getbytesTotal() : int
      {
         if(this.m_internalLoader !== null)
         {
            return this.m_internalLoader.bytesTotal;
         }
         return this.m_bytesTotal;
      }
      
      override protected function chooseLoad() : void
      {
         this.m_bytesTotal = 0;
         this.m_internalLoader = new URLLoader();
         this.m_internalLoader.dataFormat = URLLoaderDataFormat.BINARY;
         this.m_internalLoader.addEventListener(Event.COMPLETE,this.onInternalComplete);
         this.m_internalLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
         this.m_internalLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
         this.m_internalLoader.addEventListener(ProgressEvent.PROGRESS,onProgress);
         this.m_internalLoader.addEventListener(Event.OPEN,onOpen);
         this.m_internalLoader.load(m_urlRequest);
      }
      
      override protected function getEventDispatcher() : EventDispatcher
      {
         return m_loader;
      }
      
      override protected function chooseClose() : void
      {
         this.m_bytesTotal = this.m_internalLoader.bytesTotal;
         this.m_internalLoader.removeEventListener(Event.COMPLETE,this.onInternalComplete);
         this.m_internalLoader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
         this.m_internalLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
         this.m_internalLoader.removeEventListener(ProgressEvent.PROGRESS,onProgress);
         this.m_internalLoader.removeEventListener(Event.OPEN,onOpen);
         this.m_internalLoader = null;
      }
      
      override protected function invokeCallback(param1:Event) : void
      {
         m_completeCallback(param1,getStats());
      }
      
      private function onInternalComplete(param1:Event) : void
      {
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.URLResourceLoaderOnInternalComplete);
         var _loc3_:URLLoader = m_loader as URLLoader;
         _loc3_.data = param1.target.data as ByteArray;
         _loc3_.bytesLoaded = param1.target.bytesLoaded;
         _loc3_.bytesTotal = param1.target.bytesTotal;
         _loc3_.dispatchEvent(new Event(Event.COMPLETE));
         RuntimeProfiler.leave(_loc2_);
      }
   }
}

