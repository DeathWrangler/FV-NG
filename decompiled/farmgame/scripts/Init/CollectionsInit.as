package Init
{
   import Managers.CollectionsManager;
   
   public class CollectionsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "CollectionsInit";
      
      public static const COLLECTIONS_CONFIG_FILENAME:String = "collections.xml";
      
      public function CollectionsInit(buildVersion:Number)
      {
         super(INIT_ID,COLLECTIONS_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         CollectionsManager.getInstance().setConfigXml(xml);
         super.onLoadCallback(xml);
      }
   }
}

