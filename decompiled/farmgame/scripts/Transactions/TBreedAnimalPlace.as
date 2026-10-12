package Transactions
{
   import Classes.MutableAnimal;
   
   public class TBreedAnimalPlace extends TAnimalPlace
   {
      
      public function TBreedAnimalPlace(animal:MutableAnimal, isGift:Boolean = false, containerId:Number = 0)
      {
         super(animal,isGift,containerId);
         m_params.metadata = animal.getPackedMutableState();
      }
   }
}

