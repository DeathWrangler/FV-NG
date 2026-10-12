package Classes
{
   import Classes.ZItem.PetFarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TPetPerformTrick;
   import flash.utils.getDefinitionByName;
   
   public class PetTrick
   {
      
      public static const PET_TRICK_FREQUENCY_KEY:String = "petTrickFreqKey";
      
      public static const PET_TRICK_FREQUENCY:Number = 86400;
      
      public var m_pet:Pet;
      
      public var m_petItem:PetFarmItem;
      
      public var m_harvestObjectIds:Array;
      
      private var m_trickName:String;
      
      private var m_trickTypes:Array = [PetTrickHarvest,PetTrickFetch];
      
      public function PetTrick(pet:Pet)
      {
         super();
         this.m_pet = pet;
         this.m_petItem = PetConfig.getPetItem(this.m_pet.getItem().name);
         this.m_trickName = this.m_petItem.getLevelTrick(this.m_pet.petLevel);
      }
      
      public static function createPetTrick(pet:Pet) : PetTrick
      {
         var tempClass:Class = null;
         var petItem:PetFarmItem = PetConfig.getPetItem(pet.getItem().name);
         var trickName:String = petItem.getLevelTrick(pet.petLevel);
         var trick:PetTrick = null;
         var className:String = PetConfig.getTrickClassName(trickName);
         if(className != "")
         {
            tempClass = getDefinitionByName("Classes." + className) as Class;
            trick = new tempClass(pet);
         }
         return trick;
      }
      
      public function perform() : void
      {
         TransactionManager.addTransaction(new TPetPerformTrick(this.m_pet,this.m_trickName,this.m_harvestObjectIds));
      }
      
      protected function getTrickFrequency() : Number
      {
         return PetTrick.PET_TRICK_FREQUENCY;
      }
      
      protected function getTrickFrequencyKey() : String
      {
         return PetTrick.PET_TRICK_FREQUENCY_KEY;
      }
      
      public function canPerformTrick(id:Number) : Boolean
      {
         var key:String = this.getTrickFrequencyKey() + id;
         var currentTime:Number = Global.worldTime / 1000;
         var deltaTime:Number = currentTime - Global.player.getFeatureLastShown(key);
         var canPerform:Boolean = false;
         if(deltaTime >= this.getTrickFrequency())
         {
            canPerform = true;
            Global.player.setFeatureLastShown(key,currentTime,false);
         }
         return canPerform;
      }
   }
}

