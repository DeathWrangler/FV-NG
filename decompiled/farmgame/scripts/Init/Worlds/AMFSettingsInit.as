package Init.Worlds
{
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class AMFSettingsInit extends InitializationAction
   {
      
      private var m_loadUrlSequence:Array;
      
      private var loader:URLLoader;
      
      public function AMFSettingsInit(initId:String, amfFile:String, buildVersion:Number)
      {
         var versionSubDir:String = null;
         this.m_loadUrlSequence = [];
         super(initId);
         if(!isNaN(buildVersion))
         {
            versionSubDir = "v" + buildVersion;
            this.m_loadUrlSequence.push(Global.getXMLPath() + amfFile + ".gz");
            this.m_loadUrlSequence.push(Global.getXMLPath() + amfFile);
            this.m_loadUrlSequence.push(FarmGameUtil.getXmlBackupFilename(Global.getXMLPath() + amfFile + ".gz"));
         }
         this.m_loadUrlSequence.push(Global.getXMLPath() + amfFile + ".gz");
         this.m_loadUrlSequence.push(Global.getXMLPath() + amfFile);
         this.m_loadUrlSequence.push(FarmGameUtil.getXmlBackupFilename(Global.getXMLPath() + amfFile + ".gz"));
         GlobalEngine.log("AMFSettingsInit","(" + initId + "," + amfFile + "," + buildVersion + ")");
         GlobalEngine.log("AMFSettingsInit","load sequence:\n" + this.m_loadUrlSequence.join("\n") + "\n");
      }
      
      override public function execute() : void
      {
         this.loadConfigAMF();
         this.onExecuteCallback();
      }
      
      private function loadConfigAMF(attempts:int = 0) : void
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
            this.loader.addEventListener(Event.COMPLETE,this.onConfigAmfLoaded);
            errorEventHandler = function(event:ErrorEvent):void
            {
               loadConfigAMF(attempts + 1);
               var errorMessage:String = "Failed to load config file.";
               errorMessage += ",stackRoot=AMFSettingsInit.loadConfigAMF";
               errorMessage += ",attempts=" + attempts;
               errorMessage += ",url=" + url;
               errorMessage += ",errorType=" + event.type;
               ErrorManager.addError(errorMessage);
            };
            this.loader.addEventListener(IOErrorEvent.IO_ERROR,errorEventHandler);
            this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorEventHandler);
         }
      }
      
      protected function onExecuteCallback() : void
      {
         GlobalEngine.log("AMFSettingsInit","onExecuteCallback()");
      }
      
      private function onConfigAmfLoaded(event:Event) : void
      {
         this.loader.removeEventListener(Event.COMPLETE,this.onConfigAmfLoaded);
         var rawAMF:ByteArray = event.target.data;
         rawAMF.uncompress();
         var itemsObject:Object = rawAMF.readObject();
         this.onLoadCallback(itemsObject);
      }
      
      protected function onLoadCallback(worldScoreObj:Object) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         GlobalEngine.log("AMFSettingsInit","onLoadCallback");
      }
   }
}

