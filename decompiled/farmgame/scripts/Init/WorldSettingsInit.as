package Init
{
   public class WorldSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "ExpansionSettingsInit";
      
      public static const EXPANSION_CONFIG_FILENAME:String = "worldSettings.xml";
      
      public function WorldSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,EXPANSION_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.worldSettingsManager.settingsXml = xml;
         super.onLoadCallback(xml);
      }
   }
}

