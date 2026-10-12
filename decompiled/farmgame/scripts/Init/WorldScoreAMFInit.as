package Init
{
   import Init.Worlds.AMFSettingsInit;
   
   public class WorldScoreAMFInit extends AMFSettingsInit
   {
      
      public static const INIT_ID:String = "WorldScoreAMFInit";
      
      public function WorldScoreAMFInit(buildVersion:Number, amfFile:String)
      {
         super(INIT_ID,amfFile,buildVersion);
         super.setActionId(INIT_ID + amfFile);
         this.addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override protected function onLoadCallback(worldScore:Object) : void
      {
         Global.worldScoreSettingsManager.addWorldScoresConfig(worldScore);
         super.onLoadCallback(worldScore);
      }
   }
}

