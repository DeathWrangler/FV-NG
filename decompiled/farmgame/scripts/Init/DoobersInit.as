package Init
{
   import Managers.DoobersManager;
   
   public class DoobersInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "DoobersInit";
      
      public static const DOOBERS_CONFIG_FILENAME:String = "doobers.xml";
      
      public function DoobersInit(buildVersion:Number)
      {
         super(INIT_ID,DOOBERS_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         DoobersManager.getInstance().setConfigXml(xml);
         super.onLoadCallback(xml);
      }
   }
}

