package Init
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.AssetUrlManager;
   import Engine.Managers.ErrorManager;
   import Managers.FarmGameSettingsManager;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class ZGameSettingsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "ZGameSettingsInit";
      
      protected static const SKIP_NEW_CMS_MODULES:String = "SKIP_NEW_CMS_MODULES";
      
      protected static const AMF_CONTENT_TYPE:String = "application/x-amf";
      
      private var m_settingsUrl:String;
      
      private var m_settingsBackupUrl:String;
      
      private var m_itemsUrl:String;
      
      private var m_itemsPristineURL:String;
      
      private var m_itemsBackupUrl:String;
      
      private var m_itemsPristineBackupUrl:String;
      
      private var m_gameSettingsCMSUrl:String;
      
      private var m_gameSettingsCMSBackupUrl:String;
      
      private var m_itemsTrunkURL:String;
      
      protected var m_executeComplete:Boolean = false;
      
      protected var m_downloadEvent:Event;
      
      protected var m_masteryAmfURL:String;
      
      public function ZGameSettingsInit(settingsUrl:String, itemsUrl:String, gameSettingsCMSUrl:String, itemsPristineURL:String = null, itemsTrunkURL:String = null, itemsMasteryAMFURL:String = null)
      {
         super(INIT_ID);
         addDependency(MarketSettingsInit.INIT_ID);
         this.m_settingsUrl = settingsUrl;
         this.m_itemsUrl = itemsUrl;
         this.m_itemsPristineURL = itemsPristineURL;
         this.m_gameSettingsCMSUrl = gameSettingsCMSUrl;
         this.m_itemsTrunkURL = itemsTrunkURL;
         this.m_masteryAmfURL = itemsMasteryAMFURL;
         new AssetUrlManager(null,null,null);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_ITEMS_INIT) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            this.downloadItems();
         }
      }
      
      private function downloadItems() : void
      {
         var fileType:String = "";
         if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
         {
            fileType = AMF_CONTENT_TYPE;
         }
         if(FarmGameSettingsManager.isInItemsAMFExperiment() || GlobalEngine.isFlashVarSetAndTrue(FarmGame.FGSM_AMF_ENABLED_FLASH_VAR))
         {
            fileType = AMF_CONTENT_TYPE;
         }
         this.downloadFile(this.m_itemsUrl,this.onItemsLoaded,this.onItemsError,fileType);
         if(FarmGameSettingsManager.isInItemsAMFBuildTimeReduction())
         {
            fileType = AMF_CONTENT_TYPE;
            this.downloadFile(this.m_itemsTrunkURL,this.onItemsAmfTrunkLoaded,this.onItemsAmfTrunkError,fileType);
         }
         if(FarmGameSettingsManager.isInItemAMFPristineExperiment())
         {
            fileType = AMF_CONTENT_TYPE;
            this.downloadFile(this.m_itemsPristineURL,this.onItemsAMFPristineLoaded,this.onItemsAMFPristineError,fileType);
         }
         if(FarmGameSettingsManager.shouldUseMasteryAMF())
         {
            fileType = AMF_CONTENT_TYPE;
            this.downloadFile(this.m_masteryAmfURL,this.onMasteryAMFLoaded,this.onMasteryAMFError,fileType);
         }
      }
      
      private function downloadFile(fileURL:String, completeCallback:Function, errorCallback:Function, fileType:String) : void
      {
         var itemsLoader:URLLoader = new URLLoader();
         itemsLoader.dataFormat = URLLoaderDataFormat.BINARY;
         itemsLoader.addEventListener(Event.COMPLETE,completeCallback);
         itemsLoader.addEventListener(IOErrorEvent.IO_ERROR,errorCallback,false,0,true);
         itemsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorCallback,false,0,true);
         var fileRequest:URLRequest = new URLRequest(fileURL);
         if(fileType != "")
         {
            fileRequest.contentType = fileType;
         }
         itemsLoader.load(fileRequest);
      }
      
      override public function execute() : void
      {
         var gameSettingsCMS:URLLoader = null;
         var loader:URLLoader = new URLLoader(new URLRequest(this.m_settingsUrl));
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,this.onSettingsXmlLoaded);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onSettingsXmlError,false,0,true);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSettingsXmlError,false,0,true);
         if(!Global.flashHotParams[SKIP_NEW_CMS_MODULES])
         {
            gameSettingsCMS = new URLLoader(new URLRequest(this.m_gameSettingsCMSUrl));
            gameSettingsCMS.dataFormat = URLLoaderDataFormat.BINARY;
            gameSettingsCMS.addEventListener(Event.COMPLETE,this.onGameSettingsCMSXmlLoaded);
            gameSettingsCMS.addEventListener(IOErrorEvent.IO_ERROR,this.onGameSettingsCMSXmlError,false,0,true);
            gameSettingsCMS.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGameSettingsCMSXmlError,false,0,true);
         }
         this.m_executeComplete = true;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_ITEMS_INIT) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(this.m_downloadEvent)
            {
               this.onItemsLoaded(this.m_downloadEvent);
            }
         }
         else
         {
            this.downloadItems();
         }
      }
      
      private function onSettingsXmlError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onSettingsXmlError";
         errorMessage += ",url=" + this.m_settingsUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_settingsBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_settingsUrl);
         var loader:URLLoader = new URLLoader(new URLRequest(this.m_settingsBackupUrl));
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,this.onSettingsXmlLoaded);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onSettingsXmlRetryError,false,0,true);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSettingsXmlRetryError,false,0,true);
      }
      
      private function onSettingsXmlRetryError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onSettingsXmlRetryError";
         errorMessage += ",url=" + this.m_settingsBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      protected function onSettingsXmlLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onSettingsXmlLoaded.");
      }
      
      private function onItemsError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onItemsError";
         errorMessage += ",url=" + this.m_itemsUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_itemsBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_itemsUrl);
         var fileType:String = "";
         if(FarmGameSettingsManager.isInItemsAMFExperiment() || FarmGameSettingsManager.isInOptItemsAMFExperiment())
         {
            fileType = AMF_CONTENT_TYPE;
         }
         this.downloadFile(this.m_itemsBackupUrl,this.onItemsLoaded,this.onItemsRetryError,fileType);
      }
      
      private function onItemsAMFPristineError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onItemsAMFPristineError";
         errorMessage += ",url=" + this.m_itemsUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_itemsPristineBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_itemsPristineURL);
         var fileType:String = AMF_CONTENT_TYPE;
         this.downloadFile(this.m_itemsPristineBackupUrl,this.onItemsAMFPristineLoaded,this.onItemsAMFPristineRetryError,fileType);
      }
      
      private function onItemsRetryError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onItemsRetryError";
         errorMessage += ",url=" + this.m_itemsBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      private function onItemsAMFPristineRetryError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onItemsAMFPristineRetryError";
         errorMessage += ",url=" + this.m_itemsPristineBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      private function onMasteryAMFError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file";
         errorMessage += ",stackRoot=ZGameSettingsInit.onMasteryAMFError";
         errorMessage += ",url=" + this.m_masteryAmfURL;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      private function onItemsLoaded(event:Event) : void
      {
         if(this.m_executeComplete && Boolean(event))
         {
            if(GlobalEngine.isFlashVarSetAndTrue(FarmGame.FGSM_AMF_ENABLED_FLASH_VAR))
            {
               this.onFgsmAmfLoaded(event);
            }
            else if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
            {
               this.onOptItemsAmfLoaded(event);
            }
            else if(FarmGameSettingsManager.isInItemsAMFExperiment())
            {
               this.onItemsAmfLoaded(event);
            }
            else
            {
               this.onItemsXmlLoaded(event);
            }
         }
         else if(event)
         {
            this.m_downloadEvent = event;
         }
      }
      
      protected function onItemsXmlLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onItemsXmlLoaded.");
      }
      
      protected function onItemsAmfLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onItemsAmfLoaded.");
      }
      
      protected function onOptItemsAmfLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onOptItemsAmfLoaded.");
      }
      
      protected function onItemsAMFPristineLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onItemsAMFPristineLoaded.");
      }
      
      protected function onFgsmAmfLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onFgsmAmfLoaded.");
      }
      
      protected function onMasteryAMFLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract function. should be overridden");
      }
      
      private function onGameSettingsCMSXmlError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onGameSettingsCMSXmlError";
         errorMessage += ",url=" + this.m_gameSettingsCMSUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_gameSettingsCMSBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_gameSettingsCMSUrl);
         var gameSettingsCMSLoader:URLLoader = new URLLoader(new URLRequest(this.m_gameSettingsCMSBackupUrl));
         gameSettingsCMSLoader.dataFormat = URLLoaderDataFormat.BINARY;
         gameSettingsCMSLoader.addEventListener(Event.COMPLETE,this.onGameSettingsCMSXmlLoaded);
         gameSettingsCMSLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onGameSettingsCMSXmlRetryError,false,0,true);
         gameSettingsCMSLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGameSettingsCMSXmlRetryError,false,0,true);
      }
      
      private function onGameSettingsCMSXmlRetryError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onGameSettingsCMSXmlRetryError";
         errorMessage += ",url=" + this.m_gameSettingsCMSBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      protected function onGameSettingsCMSXmlLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onGameSettingsCMSXmlLoaded.");
      }
      
      protected function onItemsAmfTrunkLoaded(event:Event) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZGameSettingsInit:onItemsAmfTrunkLoaded.");
      }
      
      private function onItemsAmfTrunkError(event:ErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=ZGameSettingsInit.onItemsAmfTrunkError";
         errorMessage += ",url=" + this.m_itemsUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
   }
}

