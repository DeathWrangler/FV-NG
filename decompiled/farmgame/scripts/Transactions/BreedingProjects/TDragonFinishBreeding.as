package Transactions.BreedingProjects
{
   import Classes.DragonBreeding.DragonBreedingSession;
   import Managers.DragonBreedingManager;
   import Transactions.TFarmTransaction;
   
   public class TDragonFinishBreeding extends TFarmTransaction
   {
      
      private var m_breedSession:DragonBreedingSession = null;
      
      private var m_callback:Function = null;
      
      private var m_featureName:String;
      
      public function TDragonFinishBreeding(breedSession:DragonBreedingSession, callback:Function, featureName:String)
      {
         this.m_breedSession = breedSession;
         this.m_callback = callback;
         this.m_featureName = featureName;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DragonBreedingService.onFinishBreeding",this.m_breedSession.serializeForPhp());
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            if(Boolean(this.m_breedSession) && Boolean(result))
            {
               DragonBreedingManager.getInstance(this.m_featureName).updateBreedingState(this.m_breedSession,result);
               if(result)
               {
                  this.m_callback();
               }
            }
         }
      }
   }
}

