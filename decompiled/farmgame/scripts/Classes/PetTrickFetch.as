package Classes
{
   public class PetTrickFetch extends PetTrick
   {
      
      public static const PET_FETCH_FREQ_KEY:String = "petFetchFrequencyKey";
      
      public function PetTrickFetch(pet:Pet)
      {
         super(pet);
      }
      
      override public function perform() : void
      {
         super.perform();
      }
      
      override protected function getTrickFrequency() : Number
      {
         return Global.farmGameSettingsManager.getNumber("petFetchFrequency",PetTrick.PET_TRICK_FREQUENCY);
      }
      
      override protected function getTrickFrequencyKey() : String
      {
         return PetTrickFetch.PET_FETCH_FREQ_KEY;
      }
   }
}

