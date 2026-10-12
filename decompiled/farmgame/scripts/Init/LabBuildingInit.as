package Init
{
   import Managers.LabBuildingManager;
   
   public class LabBuildingInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "LabBuildingInit";
      
      public static const LAB_BUILDING_CONFIG_FILENAME:String = "labBuildings.xml";
      
      public function LabBuildingInit(buildVersion:Number)
      {
         super(INIT_ID,LAB_BUILDING_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         LabBuildingManager.getInstance().setConfigXml(xml);
         super.onLoadCallback(xml);
      }
   }
}

