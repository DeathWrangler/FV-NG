package Transactions.BreedingProjects
{
   import Transactions.TFarmTransaction;
   
   public class TAnimalAskForBreedItem extends TFarmTransaction
   {
      
      private var m_itemCode:String = "";
      
      private var m_callback:Function = null;
      
      public function TAnimalAskForBreedItem(itemCode:String, callback:Function)
      {
         this.m_itemCode = itemCode;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onAskForBreedingItem",this.m_itemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && Boolean(result.rewardLink))
         {
            this.m_callback(result.rewardLink);
         }
      }
   }
}

