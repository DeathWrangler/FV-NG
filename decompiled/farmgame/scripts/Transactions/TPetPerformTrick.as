package Transactions
{
   import Classes.Pet;
   import Managers.PetManager;
   
   public class TPetPerformTrick extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TPetPerformTrick(pet:Pet, trickName:String, harvestObjectIds:Array)
      {
         super(pet);
         this.m_params = new Object();
         this.m_params.trickName = trickName;
         this.m_params.harvestObjectIds = harvestObjectIds;
      }
      
      override public function perform() : void
      {
         signedWorldAction("performTrick",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("fetchStatus"))
         {
            if(result.fetchStatus)
            {
               if(result.hasOwnProperty("fetchItem") && Boolean(result.fetchItem))
               {
                  Global.player.addGift(result.fetchItem);
               }
            }
            PetManager.getInstance().onPetTrickFetchComplete(result.fetchStatus,result.fetchItem,m_object as Pet);
         }
         else if(result.hasOwnProperty("harvestLimitedAnimalStatus"))
         {
            if(!result.harvestLimitedAnimalStatus)
            {
               PetManager.getInstance().onPetTrickHarvestAnimalTooSoon(m_object as Pet);
            }
         }
      }
   }
}

