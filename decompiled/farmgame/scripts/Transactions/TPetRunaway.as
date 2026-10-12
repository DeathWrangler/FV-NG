package Transactions
{
   import Classes.Pet;
   
   public class TPetRunaway extends TWorldState
   {
      
      public function TPetRunaway(pet:Pet)
      {
         super(pet);
      }
      
      override public function perform() : void
      {
         signedWorldAction("runaway");
      }
   }
}

