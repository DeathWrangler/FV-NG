package Init
{
   import Classes.AnimalBreedingConfigSettings;
   
   public class AnimalBreedingSettingsInit extends XMLSettingsInit
   {
      
      public static const INIT_ID:String = "AnimalBreeding";
      
      public function AnimalBreedingSettingsInit(buildVersion:Number)
      {
         super(INIT_ID,"AnimalBreeding.xml",buildVersion);
      }
      
      override protected function onLoadCallback(xml:XML) : void
      {
         Global.animalBreedingSettings = new AnimalBreedingConfigSettings(xml);
         super.onLoadCallback(xml);
      }
   }
}

