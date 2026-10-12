package Transactions.BreedingProjects
{
   import Transactions.TFarmTransaction;
   
   public class TAnimalGiveUpForAdoption extends TFarmTransaction
   {
      
      public static const ACTION_GIVE_UP_FOR_ADOPTION:String = "onGiveUpForAdoption";
      
      private var m_itemCode:String = "";
      
      private var m_metadataHash:String = "";
      
      private var m_callback:Function = null;
      
      public function TAnimalGiveUpForAdoption(itemCode:String, metadataHash:String, callback:Function)
      {
         this.m_itemCode = itemCode;
         this.m_metadataHash = metadataHash;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onGiveUpForAdoption",this.m_itemCode,this.m_metadataHash);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = ACTION_GIVE_UP_FOR_ADOPTION;
         result.itemCode = this.m_itemCode;
         return result;
      }
   }
}

