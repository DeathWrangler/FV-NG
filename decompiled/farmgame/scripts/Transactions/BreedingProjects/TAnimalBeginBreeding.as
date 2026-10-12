package Transactions.BreedingProjects
{
   import Classes.breeding.AnimalBreedingSession;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.TFarmTransaction;
   
   public class TAnimalBeginBreeding extends TFarmTransaction
   {
      
      public static const ACTION_ON_BEGIN_BREEDING:String = "onBeginBreeding";
      
      private var m_breedSession:AnimalBreedingSession = null;
      
      private var m_callback:Function = null;
      
      public function TAnimalBeginBreeding(breedSession:AnimalBreedingSession, callback:Function)
      {
         this.m_breedSession = breedSession.clone();
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onBeginBreeding",this.m_breedSession.serializeForPhp());
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            AnimalBreedingManager.getInstance().updateBreedingState(this.m_breedSession,result);
            this.m_callback(result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = ACTION_ON_BEGIN_BREEDING;
         result.breedSession = this.m_breedSession;
         return result;
      }
   }
}

