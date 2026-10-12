package Managers
{
   import Classes.util.ExternalUtil;
   
   public class UISandboxManager
   {
      
      private static const JS_SET_SEND_ASSET_NAME_CALLBACK_ID:String = "FarmNS.UISandboxManager.setSendAssetNameCallbackID";
      
      private static const JS_SET_REMOVE_ASSET_NAME_CALLBACK_ID:String = "FarmNS.UISandboxManager.setRemoveAssetNameCallbackID";
      
      private static const JS_SET_ASSET_TO_SYNCED:String = "FarmNS.UISandboxManager.setAssetToSynced";
      
      private static const JS_ON_FLASH_LOAD_COMPLETE:String = "FarmNS.UISandboxManager.onFlashLoadComplete";
      
      public function UISandboxManager()
      {
         super();
      }
      
      public static function init() : void
      {
         registerCallbacks();
         onFlashLoadComplete();
      }
      
      public static function registerCallbacks() : void
      {
         var callId:String = ExternalUtil.instance.registerCallback(sendAssetName);
         ExternalUtil.instance.call(JS_SET_SEND_ASSET_NAME_CALLBACK_ID,callId);
         var callId2:String = ExternalUtil.instance.registerCallback(removeAssetName);
         ExternalUtil.instance.call(JS_SET_REMOVE_ASSET_NAME_CALLBACK_ID,callId2);
      }
      
      public static function onFlashLoadComplete() : void
      {
         ExternalUtil.instance.call(JS_ON_FLASH_LOAD_COMPLETE);
      }
      
      public static function sendAssetName(assetName:String) : void
      {
         Global.sandboxAssets[assetName] = true;
         ExternalUtil.instance.call(JS_SET_ASSET_TO_SYNCED,assetName);
      }
      
      public static function removeAssetName(assetName:String) : void
      {
         if(Global.sandboxAssets[assetName])
         {
            Global.sandboxAssets[assetName] = false;
         }
      }
   }
}

