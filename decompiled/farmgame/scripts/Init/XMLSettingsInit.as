package Init
{
   import Classes.*;
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class XMLSettingsInit extends InitializationAction
   {
      
      private var m_settingsUrl:String;
      
      private var m_settingsUrlBackup:String;
      
      private var m_loadUrlSequence:Array;
      
      private var loader:URLLoader;
      
      public function XMLSettingsInit(initId:String, xmlFile:String, buildVersion:Number)
      {
         var versionSubDir:String = null;
         this.m_loadUrlSequence = [];
         super(initId);
         if(!isNaN(buildVersion))
         {
            versionSubDir = "v" + buildVersion;
            this.m_loadUrlSequence.push(Global.getXMLPath() + xmlFile + ".gz");
            this.m_loadUrlSequence.push(Global.getXMLPath() + xmlFile);
            this.m_loadUrlSequence.push(FarmGameUtil.getXmlBackupFilename(Global.getXMLPath() + xmlFile + ".gz"));
         }
         this.m_loadUrlSequence.push(Global.getXMLPath() + xmlFile + ".gz");
         this.m_loadUrlSequence.push(Global.getXMLPath() + xmlFile);
         this.m_loadUrlSequence.push(FarmGameUtil.getXmlBackupFilename(Global.getXMLPath() + xmlFile + ".gz"));
         GlobalEngine.log("XMLSettingsInit","(" + initId + "," + xmlFile + "," + buildVersion + ")");
         GlobalEngine.log("XMLSettingsInit","load sequence:\n" + this.m_loadUrlSequence.join("\n") + "\n");
      }
      
      override public function execute() : void
      {
         this.loadConfigXML();
         this.onExecuteCallback();
      }
      
      private function loadConfigXML(attempts:int = 0) : void
      {
         var url:String = null;
         var errorEventHandler:Function = null;
         if(attempts >= this.m_loadUrlSequence.length)
         {
            GlobalEngine.error("Init",_id + " init step failed : XMLSettingsInit could not load configuration after " + attempts + " attempts.  Last attempt was made for " + this.m_loadUrlSequence[attempts - 1]);
         }
         else
         {
            url = this.m_loadUrlSequence[attempts];
            this.loader = new URLLoader(new URLRequest(url));
            this.loader.dataFormat = URLLoaderDataFormat.BINARY;
            this.loader.addEventListener(Event.COMPLETE,this.onConfigXmlLoaded);
            errorEventHandler = function(event:ErrorEvent):void
            {
               loadConfigXML(attempts + 1);
               var errorMessage:String = "Failed to load config file.";
               errorMessage += ",stackRoot=XMLSettingsInit.loadConfigXML";
               errorMessage += ",attempts=" + attempts;
               errorMessage += ",url=" + url;
               errorMessage += ",errorType=" + event.type;
               ErrorManager.addError(errorMessage);
            };
            this.loader.addEventListener(IOErrorEvent.IO_ERROR,errorEventHandler);
            this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEventHandler);
         }
      }
      
      private function onConfigXmlLoaded(event:Event) : void
      {
         var uncompressedData:String = null;
         var xml:XML = null;
         this.loader.removeEventListener(Event.COMPLETE,this.onConfigXmlLoaded);
         try
         {
            uncompressedData = Utilities.uncompress(event.target.data);
         }
         catch(error:Error)
         {
            uncompressedData = event.target.data as String;
         }
         if(uncompressedData)
         {
            xml = XML(uncompressedData);
            GlobalEngine.log("XMLSettingsInit","success: loaded " + uncompressedData.length + " bytes");
            if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
            {
               event.target.data.clear();
               event.target.data = null;
               uncompressedData = null;
            }
            this.onLoadCallback(xml);
         }
      }
      
      protected function onExecuteCallback() : void
      {
         GlobalEngine.log("XMLSettingsInit","onExecuteCallback()");
      }
      
      protected function onLoadCallback(xml:XML) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         GlobalEngine.log("XMLSettingsInit","onLoadCallback");
      }
   }
}

