package ZLocalization
{
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   
   public class LocaleLoader
   {
      
      private static const FONT_MAPPER_DEFINITION:String = "FontMapper";
      
      protected var m_Loader:Loader;
      
      protected var m_urlLoader:URLLoader;
      
      protected var m_localizer:Localizer;
      
      protected var m_onComplete:Function;
      
      protected var m_isCompressed:Boolean;
      
      protected var m_loadFailed:Boolean;
      
      public function LocaleLoader(param1:String, param2:Function, param3:Boolean = false, param4:Boolean = true)
      {
         super();
         this.m_onComplete = param2;
         if(param4)
         {
            this.m_urlLoader = new URLLoader();
            this.m_isCompressed = param3;
            if(param3)
            {
               this.m_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            }
            this.m_urlLoader.addEventListener(Event.COMPLETE,this.onLoadXMLComplete);
            this.m_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadXMLComplete);
            this.m_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadXMLComplete);
            this.m_urlLoader.load(new URLRequest(param1));
         }
         else
         {
            this.m_Loader = new Loader();
            this.m_isCompressed = param3;
            if(param3)
            {
            }
            this.m_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadSWFComplete);
            this.m_Loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadSWFComplete);
            this.m_Loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadSWFComplete);
            this.m_Loader.load(new URLRequest(param1));
         }
      }
      
      public function get localizer() : Localizer
      {
         return this.m_localizer;
      }
      
      public function get loadFailed() : Boolean
      {
         return this.m_loadFailed;
      }
      
      protected function onLoadXMLComplete(param1:Event) : void
      {
         this.m_urlLoader.removeEventListener(Event.COMPLETE,this.onLoadXMLComplete);
         this.m_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadXMLComplete);
         if(!(param1 is ErrorEvent))
         {
            if(this.m_isCompressed)
            {
               this.m_urlLoader.data.uncompress();
            }
            this.m_localizer = new LocalizerXML(new XML(this.m_urlLoader.data.toString()));
         }
         else
         {
            this.m_loadFailed = true;
         }
         if(this.m_onComplete != null)
         {
            this.m_onComplete();
         }
         this.m_onComplete = null;
      }
      
      protected function onLoadSWFComplete(param1:Event) : void
      {
         var _loc2_:LocalizerSWF = null;
         var _loc3_:ApplicationDomain = null;
         var _loc4_:Class = null;
         this.m_Loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadSWFComplete);
         this.m_Loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadSWFComplete);
         if(!(param1 is ErrorEvent))
         {
            _loc2_ = new LocalizerSWF(param1.target.content);
            this.m_localizer = _loc2_;
            _loc3_ = this.m_Loader.contentLoaderInfo.applicationDomain;
            if(_loc3_.hasDefinition(FONT_MAPPER_DEFINITION))
            {
               _loc4_ = _loc3_.getDefinition(FONT_MAPPER_DEFINITION) as Class;
               if(_loc4_)
               {
                  this.localizer.m_fontMapper = new _loc4_();
               }
            }
         }
         else
         {
            this.m_loadFailed = true;
         }
         if(this.m_onComplete != null)
         {
            this.m_onComplete();
         }
         this.m_onComplete = null;
      }
   }
}

