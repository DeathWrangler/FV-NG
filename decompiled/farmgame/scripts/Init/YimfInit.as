package Init
{
   import Classes.Yimf.YimfManager;
   
   public class YimfInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "YimfInit";
      
      public static const YIMF_CONFIG_FILENAME:String = "yimf.xml";
      
      public function YimfInit(buildVersion:Number)
      {
         super(INIT_ID,YIMF_CONFIG_FILENAME,buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         YimfManager.getInstance().setConfigXml(xml);
         super.onLoadCallback(xml);
      }
   }
}

