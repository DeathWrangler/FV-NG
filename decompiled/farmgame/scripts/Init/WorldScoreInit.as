package Init
{
   public class WorldScoreInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "WorldScoreInit";
      
      public function WorldScoreInit(buildVersion:Number, xmlFile:String)
      {
         super(INIT_ID,xmlFile,buildVersion);
         super.setActionId(INIT_ID + xmlFile);
         this.addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.worldScoreSettingsManager.addConfigXML(xml);
         super.onLoadCallback(xml);
      }
   }
}

