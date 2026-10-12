package Managers
{
   import Classes.util.ExternalUtil;
   
   public class ArtUploadManager extends ToolModeManager
   {
      
      public static const JS_UPDATE_ITEM_XML:String = "FarmNS.ArtUploadManager.onUpdateItemXML";
      
      public static const JS_AUTH_ASSETS:String = "FarmNS.ArtUploadManager.onAuthorizeUploadAsset";
      
      private static const JS_ON_FLASH_LOAD_COMPLETE:String = "FarmNS.ArtUploadManager.onFlashLoadComplete";
      
      private static const JS_SET_LOAD_SANDBOX_ASSET_CALLBACK_ID:String = "FarmNS.ArtUploadManager.setLoadSandboxAssetCallbackID";
      
      private static const JS_SET_LOAD_SANDBOX_ICON_CALLBACK_ID:String = "FarmNS.ArtUploadManager.setLoadSandboxIconCallbackID";
      
      public function ArtUploadManager()
      {
         super();
      }
      
      public static function init() : void
      {
         initJS();
         onFlashLoadComplete();
      }
      
      public static function onFlashLoadComplete() : void
      {
         ExternalUtil.instance.call(JS_ON_FLASH_LOAD_COMPLETE);
      }
      
      public static function initJS() : void
      {
         var callId:String = ExternalUtil.instance.registerCallback(loadSandboxAsset);
         ExternalUtil.instance.call(JS_SET_LOAD_SANDBOX_ASSET_CALLBACK_ID,callId);
         var callId2:String = ExternalUtil.instance.registerCallback(loadSandboxIcon);
         ExternalUtil.instance.call(JS_SET_LOAD_SANDBOX_ICON_CALLBACK_ID,callId2);
      }
   }
}

