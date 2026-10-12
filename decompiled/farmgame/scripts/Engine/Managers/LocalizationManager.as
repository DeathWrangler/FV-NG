package Engine.Managers
{
   import Engine.Utilities;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class LocalizationManager
   {
      
      private static var m_xml:XML;
      
      private static var m_callBackFunc:Function;
      
      private static var m_loader:EventDispatcher;
      
      private static var m_dictionary:Dictionary;
      
      private static var m_swfObject:Object;
      
      public static const FORMAT_XML:int = 0;
      
      public static const FORMAT_XML_COMPRESSED:int = 1;
      
      public static const FORMAT_SWF:int = 2;
      
      public static var localizationStringExperimentVariant:int = 0;
      
      private static var m_format:int = 0;
      
      public static const LOCALIZATION_FLASH_STRING_CNT_EXPERIMENT_NAME:String = "fv_flash_localization_string_cnt_test";
      
      public function LocalizationManager()
      {
         super();
      }
      
      public static function init(param1:String, param2:Function, param3:int = 0) : void
      {
         m_format = param3;
         m_callBackFunc = param2;
         switch(param3)
         {
            case FORMAT_XML:
               m_loader = new URLLoader();
               m_loader.addEventListener(Event.COMPLETE,xmlParseCallBack);
               (m_loader as URLLoader).load(new URLRequest(param1));
               break;
            case FORMAT_XML_COMPRESSED:
               m_loader = new URLLoader();
               (m_loader as URLLoader).dataFormat = URLLoaderDataFormat.BINARY;
               m_loader.addEventListener(Event.COMPLETE,xmlParseCallBack);
               (m_loader as URLLoader).load(new URLRequest(param1));
               break;
            case FORMAT_SWF:
               m_loader = new Loader();
               (m_loader as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE,swfParseCallBack);
               (m_loader as Loader).load(new URLRequest(param1));
         }
      }
      
      public static function swfParseCallBack(param1:Event) : void
      {
         m_loader.removeEventListener(Event.COMPLETE,swfParseCallBack);
         m_swfObject = param1.target.content.text;
         m_loader = null;
         m_callBackFunc();
      }
      
      public static function xmlParseCallBack(param1:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var event:Event = param1;
         m_loader.removeEventListener(Event.COMPLETE,xmlParseCallBack);
         if(m_format == FORMAT_XML_COMPRESSED)
         {
            try
            {
               uncompressedData = Utilities.uncompress(event.target.data);
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data.";
               errorMessage += ",stackRoot=LocalizationManager.xmlParseCallBack";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         else
         {
            uncompressedData = event.target.data;
            GlobalEngine.msg("Localization","Loaded uncompressed localization file. Size: ",event.target.data.length);
         }
         if(uncompressedData)
         {
            m_xml = new XML(uncompressedData);
            if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
            {
               event.target.data.clear();
               event.target.data = null;
               uncompressedData = null;
            }
            LocalizationManager.setLocaleXml(m_xml);
            m_dictionary = new Dictionary();
            m_callBackFunc();
         }
      }
      
      public static function setLocaleXml(param1:XML) : void
      {
         m_xml = param1;
      }
      
      private static function getLocalizationString(param1:String, param2:String) : String
      {
         var hashKey:String = null;
         var bundleList:XMLList = null;
         var bundleXML:XML = null;
         var bundleLookup:XMLList = null;
         var bundleName:String = param1;
         var resource:String = param2;
         var stringResult:String = null;
         if(m_xml)
         {
            hashKey = bundleName + ":" + resource;
            stringResult = m_dictionary[hashKey];
            if(stringResult == null)
            {
               bundleList = m_xml.bundle.(@name == bundleName);
               if(bundleList)
               {
                  bundleXML = bundleList[0];
                  if(bundleXML != null && Boolean(bundleXML.bundleLine))
                  {
                     bundleLookup = bundleXML.bundleLine.(@key == resource);
                     if(bundleLookup)
                     {
                        stringResult = bundleLookup.value;
                     }
                     m_dictionary[hashKey] = stringResult;
                  }
               }
            }
         }
         else if(m_swfObject)
         {
            if(m_swfObject[bundleName] != null && m_swfObject[bundleName][resource] != null)
            {
               stringResult = m_swfObject[bundleName][resource];
            }
         }
         if(stringResult == "")
         {
            stringResult = null;
         }
         return stringResult;
      }
      
      public static function hasLocalizationString(param1:String, param2:String) : Boolean
      {
         return getLocalizationString(param1,param2) != null;
      }
      
      public static function quickLocalize(param1:String, param2:String, param3:Array = null) : String
      {
         var _loc5_:RegExp = null;
         var _loc6_:int = 0;
         var _loc4_:String = getLocalizationString(param1,param2);
         if(_loc4_)
         {
            if(param3)
            {
               _loc6_ = 0;
               while(_loc6_ < param3.length)
               {
                  if(_loc4_)
                  {
                     _loc5_ = new RegExp("\\{" + _loc6_ + "\\}","gim");
                     _loc4_ = _loc4_.replace(_loc5_,param3[_loc6_]);
                  }
                  _loc6_++;
               }
            }
         }
         else if(Config.DEBUG_MODE == true)
         {
            _loc4_ = "Could not find localization data for " + param1 + ":" + param2;
            GlobalEngine.log("localization","bundleName: " + param1 + " resource: " + param2);
         }
         else
         {
            _loc4_ = "";
         }
         if(1 == localizationStringExperimentVariant)
         {
            StatsManager.count("cloctest",param1,param2);
         }
         return _loc4_;
      }
   }
}

