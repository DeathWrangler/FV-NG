package Init
{
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.Parser.XMLExtendableData;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class XMLDialogsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "XMLDialogsInit";
      
      private var m_sDialogsUrl:String;
      
      private var m_sDialogsBackupUrl:String;
      
      private var m_xml:XMLList;
      
      private var m_rawXml:XML;
      
      private var m_pStyleData:XMLExtendableData = null;
      
      private var m_aDefaultStylesHash:Array = null;
      
      private var m_compressed:Boolean;
      
      public function XMLDialogsInit(dialogsUrl:String, compressed:Boolean = true)
      {
         super(INIT_ID);
         this.m_sDialogsUrl = dialogsUrl;
         this.m_compressed = compressed;
      }
      
      override public function execute() : void
      {
         var loader:URLLoader = new URLLoader(new URLRequest(this.m_sDialogsUrl));
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,this.onDialogsXmlLoaded);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onDialogsXmlError,false,0,true);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDialogsXmlError,false,0,true);
         Global.dynamicDialogs = this;
      }
      
      private function onDialogsXmlError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=XMLDialogsInit.onDialogsXmlError";
         errorMessage += ",url=" + this.m_sDialogsUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_sDialogsBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_sDialogsUrl);
         var loader:URLLoader = new URLLoader(new URLRequest(this.m_sDialogsBackupUrl));
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,this.onDialogsXmlLoaded);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onDialogsXmlRetryError,false,0,true);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDialogsXmlRetryError,false,0,true);
      }
      
      private function onDialogsXmlRetryError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=XMLDialogsInit.onDialogsXmlError";
         errorMessage += ",url=" + this.m_sDialogsBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      private function onDialogsXmlLoaded(event:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var xml:XML = null;
         if(this.m_compressed)
         {
            try
            {
               uncompressedData = Utilities.uncompress(event.target.data);
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data.";
               errorMessage += ",stackRoot=XMLDialogsInit.onDialogsXmlLoaded";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         else
         {
            uncompressedData = event.target.data as String;
         }
         if(uncompressedData)
         {
            xml = XML(uncompressedData);
            if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
            {
               event.target.data.clear();
               event.target.data = null;
               uncompressedData = null;
            }
            this.m_rawXml = xml;
            this.m_xml = xml..dialogTemplates..dialog;
            if(this.m_xml.length > 0)
            {
               this.m_xml = this.m_xml[0];
            }
            this.m_pStyleData = new XMLExtendableData(this.m_rawXml);
            this.parseAndSaveDefaultStyles();
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function parseAndSaveDefaultStyles() : void
      {
         var sToken:String = this.m_rawXml..dialogTemplates..@aStyles;
         var aTokens:Array = XMLExtendableData.convertTokenToArrayOfTokens(sToken);
         this.m_aDefaultStylesHash = XMLExtendableData.convertArrayOfTokensToKeyValuePairs(aTokens);
      }
      
      public function getTagDefaultStyleName(sTagName:String) : String
      {
         if(this.m_aDefaultStylesHash != null && this.m_aDefaultStylesHash.hasOwnProperty(sTagName))
         {
            return this.m_aDefaultStylesHash[sTagName];
         }
         return null;
      }
      
      public function getStyleNodeByName(sStyleName:String) : XML
      {
         return this.m_pStyleData.getXDNodeByName(sStyleName);
      }
      
      public function getDefaultKeyValuePairsForXMLTag(sXMLTagName:String, aTokenValues:Array, xml:XML = null) : Array
      {
         var sStyleDataName:String = null;
         if(xml != null)
         {
            sXMLTagName = xml.name().localName.toLowerCase();
            sStyleDataName = XMLDialogParser.getStyleDataNameFromXMLNode(xml);
         }
         else
         {
            sStyleDataName = this.getTagDefaultStyleName(sXMLTagName);
         }
         var xmlStyleNode:XML = Global.dynamicDialogs.getStyleNodeByName(sStyleDataName);
         return XMLDialogParser.getKeyValuePairsFromXMLNode(xml,xmlStyleNode,aTokenValues,XMLDialogParser.getSupportedAttributeNameAndTypeCB(sXMLTagName));
      }
      
      public function getXML() : XML
      {
         return this.m_rawXml;
      }
      
      public function getDilaogsXMLList() : XMLList
      {
         return this.m_xml;
      }
      
      public function getDialogsXMLByName(sName:String) : XML
      {
         return this.m_xml.(@sName == sName)[0];
      }
   }
}

