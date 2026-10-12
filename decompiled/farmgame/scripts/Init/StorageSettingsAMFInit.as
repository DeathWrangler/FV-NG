package Init
{
   import Classes.StorageConfigSettings;
   import Init.Worlds.AMFSettingsInit;
   
   public class StorageSettingsAMFInit extends AMFSettingsInit
   {
      
      public static const INIT_ID:String = "StorageSettingsAMFInit";
      
      public static const GLOBAL_STORAGECONFIG_AMF:String = "storageConfig.amf";
      
      public function StorageSettingsAMFInit(buildVersion:Number)
      {
         super(INIT_ID,GLOBAL_STORAGECONFIG_AMF,buildVersion);
      }
      
      override protected function onLoadCallback(storageConfig:Object) : void
      {
         Global.storageSettings = new StorageConfigSettings(null,storageConfig);
         super.onLoadCallback(storageConfig);
      }
   }
}

