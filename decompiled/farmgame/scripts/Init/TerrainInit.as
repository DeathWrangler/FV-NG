package Init
{
   import Classes.Terrain.TerrainConfigManager;
   
   public class TerrainInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "TerrainInit";
      
      public static const TERRAIN_CONFIG_FILENAME:String = "terrain.xml";
      
      public function TerrainInit(buildVersion:Number)
      {
         super(INIT_ID,TERRAIN_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         TerrainConfigManager.getInstance().setConfigXml(xml);
         super.onLoadCallback(xml);
      }
   }
}

