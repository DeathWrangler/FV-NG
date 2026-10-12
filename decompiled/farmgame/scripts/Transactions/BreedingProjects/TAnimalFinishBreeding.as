package Transactions.BreedingProjects
{
   import Classes.breeding.AnimalBreedingSession;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.TFarmTransaction;
   
   public class TAnimalFinishBreeding extends TFarmTransaction
   {
      
      private var m_breedSession:AnimalBreedingSession = null;
      
      private var m_callback:Function = null;
      
      public function TAnimalFinishBreeding(breedSession:AnimalBreedingSession, callback:Function)
      {
         this.m_breedSession = breedSession;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onFinishBreeding",this.m_breedSession.serializeForPhp());
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            AnimalBreedingManager.getInstance().processBreedResult(this.m_breedSession,result);
            this.m_callback(result);
         }
      }
   }
}

