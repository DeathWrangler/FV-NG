package Init
{
   import Managers.PostInitSettings;
   
   public class PostInitSequenceInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "PostInitSequenceInit";
      
      public function PostInitSequenceInit(xmlFile:String, buildVersion:Number)
      {
         super(INIT_ID,xmlFile,buildVersion);
         addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.postInitSettings = new PostInitSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

