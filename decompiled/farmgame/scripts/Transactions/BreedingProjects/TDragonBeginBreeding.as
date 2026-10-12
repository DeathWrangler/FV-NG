package Transactions.BreedingProjects
{
   import Classes.DragonBreeding.DragonBreedingSession;
   import Managers.DragonBreedingManager;
   import Transactions.TFarmTransaction;
   
   public class TDragonBeginBreeding extends TFarmTransaction
   {
      
      public static const ACTION_ON_BEGIN_BREEDING:String = "onBeginBreeding";
      
      private var m_breedSession:DragonBreedingSession = null;
      
      private var m_callback:Function = null;
      
      private var m_featureName:String;
      
      public function TDragonBeginBreeding(breedSession:DragonBreedingSession, callback:Function = null, featureName:String = "")
      {
         this.m_breedSession = breedSession;
         this.m_featureName = breedSession.featureName;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DragonBreedingService." + ACTION_ON_BEGIN_BREEDING,this.m_breedSession.serializeForPhp());
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            DragonBreedingManager.getInstance(this.m_featureName).updateBreedingState(this.m_breedSession,result);
         }
      }
   }
}

