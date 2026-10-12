package Transactions
{
   import Classes.Pet;
   
   public class TPetAdulthoodReached extends TWorldState
   {
      
      public function TPetAdulthoodReached(pet:Pet)
      {
         super(pet);
      }
      
      override public function perform() : void
      {
         signedWorldAction("adulthoodReached");
      }
   }
}

