package Init
{
   public class CrossPromoSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "crosspromo";
      
      public function CrossPromoSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"crosspromo.xml",buildVersion);
         addDependency(AssetHashInit.INIT_ID);
         addDependency(GlobalsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         if(!Global.toolMode && !Global.uiSandboxMode && !Global.questTool2Mode && !Global.artuploadSandboxMode)
         {
            Global.crosspromoDescriptorManager.setCrossPromoXml(xml);
         }
         super.onLoadCallback(xml);
      }
   }
}

