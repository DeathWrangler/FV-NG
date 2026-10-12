package Init
{
   import Classes.DataSources.OptItemDataSource;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import DataObjects.DataObjectsRegistrar;
   import DataObjects.Items.BaseItemDO;
   import DataSources.DataObjectDataSource;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   import Managers.PerformanceExperimentManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class FarmGameSettingsInit extends ZGameSettingsInit
   {
      
      private static var m_itemsPristineAMFObject:Object;
      
      private static var m_itemsAMFObject:Object;
      
      private static var m_deltaItemsObject:Object;
      
      private static var m_trunkItemsObject:Object;
      
      private static var m_masteryAMFObject:Object;
      
      private static const DEFAULT_NUM_INIT_STEPS:int = 3;
      
      private static var m_masteryAMFInitCompleted:Boolean = false;
      
      private var m_numInitSteps:int = 3;
      
      private var m_initStepsComplete:Number = 0;
      
      private var m_configSwfUrl:String;
      
      private var m_configSwfBackupUrl:String;
      
      private var m_configSwfLoader:Loader;
      
      private var m_cashAndSaleItemNames:Array = new Array();
      
      private var m_itemsPristineInitCompletion:Boolean = false;
      
      private var m_newItemsInitCompletion:Boolean = false;
      
      private var m_trunkItemsLoaded:Boolean = false;
      
      private var m_deltaItemsLoaded:Boolean = false;
      
      public function FarmGameSettingsInit(settingsUrl:String, itemsUrl:String, configSwfUrl:String, gameSettingsCMSUrl:String, itemsPristineURL:String = null, itemsTrunkURL:String = null, itemsMasteryAmfURL:String = null)
      {
         super(settingsUrl,itemsUrl,gameSettingsCMSUrl,itemsPristineURL,itemsTrunkURL,itemsMasteryAmfURL);
         this.m_configSwfUrl = configSwfUrl;
      }
      
      public static function createItemConfigInstance(itemXML:XML, itemData:BaseItemDO = null, optItem:Object = null) : FarmItem
      {
         var itemClass:Class = null;
         var itemName:String = null;
         var farmItem:FarmItem = null;
         itemClass = FarmItemType.getItemClassByType(itemXML,itemData,optItem);
         if(itemClass != null)
         {
            try
            {
               if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
               {
                  farmItem = new itemClass(null,new OptItemDataSource(optItem));
               }
               else if(FarmGameSettingsManager.isInItemsAMFExperiment())
               {
                  farmItem = new itemClass(null,new DataObjectDataSource(itemData));
               }
               else
               {
                  farmItem = new itemClass(itemXML);
               }
            }
            catch(err:Error)
            {
               if(optItem)
               {
                  itemName = optItem.name;
               }
               else if(itemData)
               {
                  itemName = itemData.name;
               }
               else
               {
                  itemName = itemXML.@name;
               }
               ErrorManager.addError("Error instantiating " + String(itemClass) + " for item \'" + itemName + "\'");
            }
         }
         return farmItem;
      }
      
      private function initStepComplete() : void
      {
         ++this.m_initStepsComplete;
         var cmsModuleOffset:int = 0;
         if(Global.flashHotParams[SKIP_NEW_CMS_MODULES])
         {
            cmsModuleOffset = 1;
         }
         if(this.m_initStepsComplete + cmsModuleOffset >= this.m_numInitSteps)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      override public function execute() : void
      {
         this.getCashAndSaleItems();
         super.execute();
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment)
         {
            ++this.m_numInitSteps;
            this.loadConfigSwf();
         }
      }
      
      public function getCashAndSaleItems() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onGetCashAndSaleItems",this.onGetCashAndSaleItems);
            ExternalUtil.instance.call("onGetCashAndSaleItems");
         }
      }
      
      public function onGetCashAndSaleItems(cashAndSaleItems:String) : void
      {
         var runtimeList:String = null;
         if(cashAndSaleItems)
         {
            runtimeList = cashAndSaleItems;
            this.m_cashAndSaleItemNames = runtimeList.split(",");
         }
      }
      
      override protected function onSettingsXmlLoaded(event:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var xml:XML = null;
         var startTime:Number = getTimer();
         try
         {
            uncompressedData = Utilities.uncompress(event.target.data);
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress data.";
            errorMessage += ",stackRoot=FarmGameSettingsInit.onConfigXmlLoaded";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
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
            if(xml)
            {
               Global.farmGameSettingsManager.addConfigXML(xml);
               GlobalEngine.info("Init","gameSettings parse complete: " + (GlobalEngine.currentTime - startTime) + "ms");
               this.initStepComplete();
            }
         }
      }
      
      override protected function onGameSettingsCMSXmlLoaded(event:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var xml:XML = null;
         var startTime:Number = getTimer();
         try
         {
            uncompressedData = Utilities.uncompress(event.target.data);
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress data.";
            errorMessage += ",stackRoot=FarmGameSettingsInit.onGameSettingsCMSXmlLoaded";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
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
            if(xml)
            {
               Global.farmGameSettingsManager.addConfigXML(xml);
               GlobalEngine.info("Init","gameSettingsCMS parse complete: " + (GlobalEngine.currentTime - startTime) + "ms");
               this.initStepComplete();
            }
         }
      }
      
      override protected function onItemsXmlLoaded(event:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var xml:XML = null;
         var itemsXMLList:XMLList = null;
         var mergeItemFlagOptInEnabled:Boolean = GlobalEngine.getFlashVar("FEATURE_MERGEDITEMFLAG_OPT_IN_ENABLED") == "true" || GlobalEngine.getFlashVar("FEATURE_MERGEDITEMFLAG_OPT_IN_ENABLED") == true;
         var startTime:Number = getTimer();
         try
         {
            uncompressedData = Utilities.uncompress(event.target.data);
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress data.";
            errorMessage += ",stackRoot=FarmGameSettingsInit.onItemsXmlLoaded";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
         }
         if(uncompressedData)
         {
            xml = XML(uncompressedData);
            itemsXMLList = xml.items.item;
            Global.farmGameSettingsManager.initItems(itemsXMLList);
            GlobalEngine.info("Init",getTimer() - startTime + "ms");
            this.initStepComplete();
         }
      }
      
      override protected function onItemsAMFPristineLoaded(event:Event) : void
      {
         var rawAMF:ByteArray;
         var isUncompressed:Boolean;
         var compressedAmfFlag:Boolean;
         var errorMessage:String = null;
         DataObjectsRegistrar.registerAll();
         DataObjectDataSource.registerAlias();
         rawAMF = event.target.data;
         isUncompressed = false;
         compressedAmfFlag = GlobalEngine.isFlashVarSetAndTrue("OPS_ITEMS_AMF_COMPRESSED");
         if(compressedAmfFlag)
         {
            try
            {
               rawAMF.uncompress();
               isUncompressed = true;
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data.";
               errorMessage += ",stackRoot=FarmGameSettingsInit.onItemsAMFPristineLoaded";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         if(!compressedAmfFlag || isUncompressed)
         {
            this.postonItemsAMFPristineLoadedSteps(rawAMF);
         }
      }
      
      private function postonItemsAMFPristineLoadedSteps(rawAMF:ByteArray) : void
      {
         var itemsObject:* = undefined;
         var errorMessage:String = null;
         var hasBeenReadSuccessFully:Boolean = false;
         try
         {
            itemsObject = rawAMF.readObject();
            hasBeenReadSuccessFully = true;
         }
         catch(error:Error)
         {
            errorMessage = "Failed to read data.";
            errorMessage += ",stackRoot=FarmGameSettingsInit.onItemsAMFPristineLoaded";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
         }
         if(hasBeenReadSuccessFully)
         {
            this.m_itemsPristineInitCompletion = true;
            if(this.m_newItemsInitCompletion)
            {
               Global.farmGameSettingsManager.initItems(null,itemsObject);
               Global.farmGameSettingsManager.initItems(null,m_itemsAMFObject);
               m_itemsAMFObject = null;
               this.initStepComplete();
            }
            else
            {
               m_itemsPristineAMFObject = itemsObject;
            }
         }
      }
      
      override protected function onOptItemsAmfLoaded(event:Event) : void
      {
         var rawAMF:ByteArray = event.target.data;
         rawAMF.uncompress();
         var optItemsObject:Object = rawAMF.readObject();
         if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
         {
            rawAMF.clear();
            rawAMF = null;
         }
         Global.farmGameSettingsManager.initItems(null,null,optItemsObject.settings.items.item);
         this.initStepComplete();
      }
      
      override protected function onItemsAmfLoaded(event:Event) : void
      {
         var rawAMF:ByteArray;
         var isUncompressed:Boolean;
         var compressedAmfFlag:Boolean;
         var errorMessage:String = null;
         var itemsObject:* = undefined;
         DataObjectsRegistrar.registerAll();
         DataObjectDataSource.registerAlias();
         rawAMF = event.target.data;
         isUncompressed = false;
         compressedAmfFlag = GlobalEngine.isFlashVarSetAndTrue("OPS_ITEMS_AMF_COMPRESSED");
         if(compressedAmfFlag)
         {
            try
            {
               rawAMF.uncompress();
               isUncompressed = true;
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data.";
               errorMessage += ",stackRoot=FarmGameSettingsInit.onItemsAmfLoaded";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         if(!compressedAmfFlag || isUncompressed)
         {
            itemsObject = rawAMF.readObject();
            if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
            {
               rawAMF.clear();
               rawAMF = null;
            }
            if(FarmGameSettingsManager.isInItemAMFPristineExperiment())
            {
               this.m_newItemsInitCompletion = true;
               if(this.m_itemsPristineInitCompletion)
               {
                  Global.farmGameSettingsManager.initItems(null,m_itemsPristineAMFObject);
                  Global.farmGameSettingsManager.initItems(null,itemsObject);
                  m_itemsPristineAMFObject = null;
                  this.initStepComplete();
               }
               else
               {
                  m_itemsAMFObject = itemsObject;
               }
            }
            else if(FarmGameSettingsManager.isInItemsAMFBuildTimeReduction())
            {
               m_deltaItemsObject = itemsObject;
               this.checkForCompletion("deltaItems");
            }
            else if(FarmGameSettingsManager.shouldUseMasteryAMF())
            {
               this.m_newItemsInitCompletion = true;
               if(m_masteryAMFInitCompleted)
               {
                  Global.farmGameSettingsManager.initItemsMultipleAmfs(null,m_masteryAMFObject);
                  Global.farmGameSettingsManager.initItemsMultipleAmfs(null,itemsObject);
                  m_masteryAMFObject = null;
                  this.initStepComplete();
               }
               else
               {
                  m_itemsAMFObject = itemsObject;
               }
            }
            else
            {
               Global.farmGameSettingsManager.initItems(null,itemsObject);
               this.initStepComplete();
            }
         }
      }
      
      override protected function onMasteryAMFLoaded(event:Event) : void
      {
         var rawAMF:ByteArray;
         var isUncompressed:Boolean;
         var compressedAmfFlag:Boolean;
         var errorMessage:String = null;
         var itemsObject:* = undefined;
         DataObjectsRegistrar.registerAll();
         DataObjectDataSource.registerAlias();
         rawAMF = event.target.data;
         isUncompressed = false;
         compressedAmfFlag = GlobalEngine.isFlashVarSetAndTrue("OPS_ITEMS_AMF_COMPRESSED");
         if(compressedAmfFlag)
         {
            try
            {
               rawAMF.uncompress();
               isUncompressed = true;
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data";
               errorMessage += ", stackRoot=FarmGameSettingsInit.onMasteryAMFLoaded";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         if(!compressedAmfFlag || isUncompressed)
         {
            itemsObject = rawAMF.readObject();
            m_masteryAMFInitCompleted = true;
            if(this.m_newItemsInitCompletion)
            {
               Global.farmGameSettingsManager.initItemsMultipleAmfs(null,itemsObject);
               Global.farmGameSettingsManager.initItemsMultipleAmfs(null,m_itemsAMFObject);
               m_itemsAMFObject = null;
               this.initStepComplete();
            }
            else
            {
               m_masteryAMFObject = itemsObject;
            }
         }
      }
      
      override protected function onFgsmAmfLoaded(event:Event) : void
      {
         var rawAmf:ByteArray = event.target.data;
         rawAmf.uncompress();
         Global.farmGameSettingsManager.loadFromAmf(rawAmf);
         this.initStepComplete();
      }
      
      private function loadConfigSwf() : void
      {
         this.m_configSwfLoader = new Loader();
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onConfigSwfLoaderComplete);
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onConfigSwfLoaderError);
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onConfigSwfLoaderError);
         this.m_configSwfLoader.load(new URLRequest(this.m_configSwfUrl),new LoaderContext());
      }
      
      private function onConfigSwfLoaderError(event:IOErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=FarmGameSettingsInit.onConfigSwfLoaderError";
         errorMessage += ",url=" + this.m_configSwfUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
         this.m_configSwfLoader = new Loader();
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onConfigSwfLoaderComplete);
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onConfigSwfLoaderRetryError);
         this.m_configSwfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onConfigSwfLoaderRetryError);
         this.m_configSwfBackupUrl = FarmGameUtil.getXmlBackupFilename(this.m_configSwfUrl);
         this.m_configSwfLoader.load(new URLRequest(this.m_configSwfBackupUrl),new LoaderContext());
      }
      
      private function onConfigSwfLoaderRetryError(event:IOErrorEvent) : void
      {
         var errorMessage:String = "Failed to load config file.";
         errorMessage += ",stackRoot=FarmGameSettingsInit.onConfigSwfLoaderRetryError";
         errorMessage += ",url=" + this.m_configSwfBackupUrl;
         errorMessage += ",errorType=" + event.type;
         ErrorManager.addError(errorMessage);
      }
      
      private function onConfigSwfLoaderComplete(event:Event) : void
      {
         GlobalEngine.log(INIT_ID,"onConfigSwfLoaderComplete");
         var content:Object = event.target.content;
         this.m_configSwfLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onConfigSwfLoaderComplete);
         this.m_configSwfLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onConfigSwfLoaderError);
         this.m_configSwfLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onConfigSwfLoaderError);
         Global.farmGameSettingsManager.loadPropertiesFromConfigSWF(content);
         if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
         {
            this.m_configSwfLoader.unload();
            this.m_configSwfLoader = null;
         }
         this.initStepComplete();
      }
      
      override protected function onItemsAmfTrunkLoaded(event:Event) : void
      {
         var rawAMF:ByteArray;
         var isUncompressed:Boolean;
         var compressedAmfFlag:Boolean;
         var errorMessage:String = null;
         DataObjectsRegistrar.registerAll();
         DataObjectDataSource.registerAlias();
         rawAMF = event.target.data;
         isUncompressed = false;
         compressedAmfFlag = GlobalEngine.isFlashVarSetAndTrue("OPS_ITEMS_AMF_COMPRESSED");
         if(compressedAmfFlag)
         {
            try
            {
               rawAMF.uncompress();
               isUncompressed = true;
            }
            catch(error:Error)
            {
               errorMessage = "Failed to uncompress data.";
               errorMessage += ",stackRoot=FarmGameSettingsInit.onItemsAmfTrunkLoaded";
               errorMessage += ",error=" + error.message;
               ErrorManager.addError(errorMessage);
            }
         }
         if(!compressedAmfFlag || isUncompressed)
         {
            m_trunkItemsObject = rawAMF.readObject();
            this.checkForCompletion("trunkItems");
         }
      }
      
      private function checkForCompletion(completedItems:String) : void
      {
         switch(completedItems)
         {
            case "trunkItems":
               this.m_trunkItemsLoaded = true;
               break;
            case "deltaItems":
               this.m_deltaItemsLoaded = true;
         }
         if(this.m_trunkItemsLoaded && this.m_deltaItemsLoaded)
         {
            Global.farmGameSettingsManager.initItemsMultipleAmfs(null,m_trunkItemsObject);
            Global.farmGameSettingsManager.initItemsMultipleAmfs(null,m_deltaItemsObject);
            m_trunkItemsObject = null;
            m_deltaItemsObject = null;
            this.initStepComplete();
         }
      }
   }
}

