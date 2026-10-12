package Init
{
   import Classes.StorageConfigSettings;
   
   public class StorageSettingsInit extends XMLSettingsInit
   {
      
      public function StorageSettingsInit(buildVersion:Number)
      {
         super("StorageSettings","StorageConfig.xml",buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.storageSettings = new StorageConfigSettings(xml,null);
         super.onLoadCallback(xml);
      }
   }
}

