package Classes
{
   public class ShareableHarvestAnimal extends Animal
   {
      
      public function ShareableHarvestAnimal(animalType:String = null)
      {
         super(animalType);
      }
      
      override public function isHarvestableByNeighbors() : Boolean
      {
         return false;
      }
   }
}

