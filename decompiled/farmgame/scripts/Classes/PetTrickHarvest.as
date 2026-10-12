package Classes
{
   import Classes.consumables.CHarvestAnimals;
   import Classes.util.ZLocUtils;
   import Display.UI;
   
   public class PetTrickHarvest extends PetTrick
   {
      
      public static const PET_HARVEST_ANIMAL_FREQ_KEY:String = "petHarvestAnimalFreqKey";
      
      private var m_consumable:Consumable;
      
      public function PetTrickHarvest(pet:Pet)
      {
         super(pet);
      }
      
      override public function perform() : void
      {
         var consumableHarvest:CHarvestAnimals = null;
         this.m_consumable = Consumable.createConsumable(m_petItem.getTrickConsumable(m_pet.petLevel));
         if(this.m_consumable.canUse())
         {
            consumableHarvest = this.m_consumable as CHarvestAnimals;
            m_harvestObjectIds = consumableHarvest.getHarvestObjectIds();
            this.m_consumable.onUse();
            super.perform();
         }
         else
         {
            this.showAnimalsNotReady();
         }
      }
      
      public function showAnimalsNotReady() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","PetTrick_harvest_" + m_petItem.getTrickHarvestType(m_pet.petLevel) + "_not_ready");
         UI.displayMessage(msg);
      }
      
      override protected function getTrickFrequency() : Number
      {
         return Global.farmGameSettingsManager.getNumber("petHarvestAnimalFrequency",PetTrick.PET_TRICK_FREQUENCY);
      }
      
      override protected function getTrickFrequencyKey() : String
      {
         return PetTrickHarvest.PET_HARVEST_ANIMAL_FREQ_KEY;
      }
   }
}

