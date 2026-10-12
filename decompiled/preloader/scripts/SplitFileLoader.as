package
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class SplitFileLoader implements IEventDispatcher
   {
      
      private var dispatcher:EventDispatcher;
      
      private var m_assetUrlList:Array;
      
      private var swfStreamArray:Array = new Array();
      
      private var downloadCompletes:int = 0;
      
      private var totalParts:int = 0;
      
      public var maxParts:int = 8;
      
      private var sfLoader:Loader = new Loader();
      
      public var swfData:ByteArray = new ByteArray();
      
      public function SplitFileLoader(param1:Array)
      {
         super();
         this.m_assetUrlList = param1;
         this.dispatcher = new EventDispatcher(this);
      }
      
      public function load(param1:String, param2:int, param3:String) : Boolean
      {
         var _loc5_:URLStream = null;
         var _loc6_:Object = null;
         if(param2 >= this.maxParts)
         {
            return false;
         }
         this.totalParts = param2;
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc5_ = new URLStream();
            _loc5_.load(new URLRequest(this.m_assetUrlList[_loc4_ % this.m_assetUrlList.length] + param1 + "_" + _loc4_ + param3));
            _loc5_.addEventListener(Event.COMPLETE,this.streamDownloadComplete);
            _loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.streamError);
            _loc5_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.streamError);
            _loc6_ = {
               "bytesTotal":0,
               "bytesLoaded":0,
               "stream":_loc5_
            };
            _loc5_.addEventListener(ProgressEvent.PROGRESS,this.streamProgress(_loc6_));
            this.swfStreamArray.push(_loc6_);
            _loc4_++;
         }
         return true;
      }
      
      private function streamProgress(param1:Object) : Function
      {
         var obj:Object = param1;
         return function(param1:ProgressEvent):void
         {
            obj.bytesTotal = param1.bytesTotal;
            obj.bytesLoaded = param1.bytesLoaded;
            fireProgressEvent();
         };
      }
      
      private function fireProgressEvent() : void
      {
         var _loc3_:Object = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this.swfStreamArray)
         {
            _loc1_ += _loc3_.bytesTotal;
            _loc2_ += _loc3_.bytesLoaded;
         }
         if(_loc1_ > 0)
         {
            this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,_loc2_,_loc1_));
         }
      }
      
      public function streamDownloadComplete(param1:Event) : void
      {
         var i:int = 0;
         var splitLoaderCtx:LoaderContext = null;
         var currentSwfStream:URLStream = null;
         var ev:Event = param1;
         ++this.downloadCompletes;
         if(this.downloadCompletes == this.totalParts)
         {
            i = 0;
            while(i < this.totalParts)
            {
               currentSwfStream = this.swfStreamArray[i].stream;
               currentSwfStream.readBytes(this.swfData,this.swfData.bytesAvailable,0);
               currentSwfStream.close();
               i++;
            }
            splitLoaderCtx = new LoaderContext(false,ApplicationDomain.currentDomain);
            this.sfLoader.contentLoaderInfo.addEventListener(Event.INIT,function(param1:Event):void
            {
               dispatchEvent(new Event(Event.COMPLETE));
            });
            this.sfLoader.loadBytes(this.swfData,splitLoaderCtx);
         }
      }
      
      public function get content() : DisplayObject
      {
         return this.sfLoader.content;
      }
      
      public function streamError(param1:Event) : void
      {
         this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.dispatcher.willTrigger(param1);
      }
   }
}

