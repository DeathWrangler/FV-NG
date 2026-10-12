package Init
{
   import Display.*;
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Managers.AssetHashManager;
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class AssetHashInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "SWFSettingsInit";
      
      protected var m_url:String = "";
      
      protected var m_assetAmfUrl:String = "";
      
      protected var m_assetAmfDeltaUrl:String = "";
      
      protected var m_loader:Loader = null;
      
      protected var m_masterAmfLoader:URLLoader = null;
      
      protected var m_deltaAmfLoader:URLLoader = null;
      
      protected var m_isMasterAMFLoaded:Boolean = false;
      
      protected var m_isDeltaAMFLoaded:Boolean = false;
      
      public function AssetHashInit()
      {
         super(INIT_ID);
         this.m_url = GlobalEngine.getFlashVar("assethash_url") as String;
         if(AssetHashManager.isUsingExternalHash())
         {
            this.m_assetAmfUrl = Global.getMasterAssetHashPath();
            this.m_assetAmfDeltaUrl = Global.getXMLPath() + "assethash.min.amf.gz";
         }
      }
      
      override public function execute() : void
      {
         var fileRequest:URLRequest = null;
         var fileRequest1:URLRequest = null;
         if(this.m_url)
         {
            this.m_loader = new Loader();
            this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
            this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
            this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
            this.m_loader.load(new URLRequest(this.m_url));
         }
         else if(Boolean(this.m_assetAmfUrl) && Boolean(this.m_assetAmfDeltaUrl))
         {
            this.m_masterAmfLoader = new URLLoader();
            this.m_masterAmfLoader.dataFormat = URLLoaderDataFormat.BINARY;
            this.m_masterAmfLoader.addEventListener(Event.COMPLETE,this.onLoadAMFComplete);
            this.m_masterAmfLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadAMFComplete);
            this.m_masterAmfLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadAMFComplete);
            fileRequest = new URLRequest(this.m_assetAmfUrl);
            this.m_masterAmfLoader.load(fileRequest);
            this.m_deltaAmfLoader = new URLLoader();
            this.m_deltaAmfLoader.dataFormat = URLLoaderDataFormat.BINARY;
            this.m_deltaAmfLoader.addEventListener(Event.COMPLETE,this.onLoadDeltaAMFComplete);
            this.m_deltaAmfLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadDeltaAMFComplete);
            this.m_deltaAmfLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadDeltaAMFComplete);
            fileRequest1 = new URLRequest(this.m_assetAmfDeltaUrl);
            this.m_deltaAmfLoader.load(fileRequest1);
         }
         else
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      protected function onLoadAMFComplete(e:Event) : void
      {
         var errorMessage:String = null;
         var rawAmf:ByteArray = e.target.data;
         var isUncompressed:Boolean = false;
         var assetHash:Object = {};
         try
         {
            rawAmf.uncompress();
            isUncompressed = true;
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress assethash-delta data.";
            errorMessage += ",stackRoot=AssetHashInit.onLoadMasterAMFComplete";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
         }
         if(isUncompressed)
         {
            assetHash = rawAmf.readObject();
         }
         AssetHashManager.masterData = assetHash;
         this.m_masterAmfLoader.removeEventListener(Event.COMPLETE,this.onLoadAMFComplete);
         this.m_masterAmfLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadAMFComplete);
         this.m_masterAmfLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadAMFComplete);
         this.m_masterAmfLoader = null;
         this.onExternalAssetHashComplete("master");
      }
      
      protected function onLoadDeltaAMFComplete(e:Event) : void
      {
         var errorMessage:String = null;
         var rawAmf:ByteArray = e.target.data;
         var isUncompressed:Boolean = false;
         var assetHash:Object = {};
         try
         {
            rawAmf.uncompress();
            isUncompressed = true;
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress assethash-delta data.";
            errorMessage += ",stackRoot=AssetHashInit.onLoadDeltaAMFComplete";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
         }
         if(isUncompressed)
         {
            assetHash = rawAmf.readObject();
         }
         AssetHashManager.deltaData = assetHash;
         this.m_deltaAmfLoader.removeEventListener(Event.COMPLETE,this.onLoadDeltaAMFComplete);
         this.m_deltaAmfLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadDeltaAMFComplete);
         this.m_deltaAmfLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadDeltaAMFComplete);
         this.m_deltaAmfLoader = null;
         this.onExternalAssetHashComplete("delta");
      }
      
      private function onExternalAssetHashComplete(whichOne:String) : void
      {
         switch(whichOne)
         {
            case "master":
               this.m_isMasterAMFLoaded = true;
               break;
            case "delta":
               this.m_isDeltaAMFLoaded = true;
         }
         if(this.m_isDeltaAMFLoaded && this.m_isMasterAMFLoaded)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      protected function release() : void
      {
         this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.m_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.m_loader = null;
      }
      
      protected function onLoadComplete(e:Event) : void
      {
         var key:String = null;
         var hashValue:String = null;
         if(!AssetHashMap)
         {
            AssetHashMap = {};
         }
         for(key in e.target.content.AssetHashMap)
         {
            hashValue = e.target.content.AssetHashMap[key];
            AssetHashMap[key] = hashValue;
         }
         this.release();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function onLoadError(event:ErrorEvent) : void
      {
         GlobalEngine.error("Init","Error loading asset hash: " + event.text);
         StatsManager.sample(StatsManager.FEATURE_SAMPLE_RATE,"errors","flash","asset_hash_load_fail",event.type);
         this.release();
      }
   }
}

