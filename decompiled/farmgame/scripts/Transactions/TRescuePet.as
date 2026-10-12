package Transactions
{
   import Classes.Pet;
   import Managers.PetManager;
   
   public class TRescuePet extends TWorldState
   {
      
      public function TRescuePet(pet:Pet)
      {
         super(pet);
      }
      
      override public function perform() : void
      {
         signedWorldAction("rescuePet");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var pet:Pet = null;
         if(result)
         {
            if(result.lastFedTime)
            {
               if(PetManager.getInstance().hasRunawayPet())
               {
                  PetManager.getInstance().removeRunawayPet();
               }
               if(PetManager.getInstance().hasRunawayPet())
               {
                  PetManager.getInstance().showPetRescueReminder();
               }
               pet = m_object as Pet;
               pet.onRescue(result.lastFedTime);
            }
         }
      }
   }
}

