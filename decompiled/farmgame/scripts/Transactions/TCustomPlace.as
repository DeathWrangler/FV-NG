package Transactions
{
   import Classes.MapResource;
   
   public class TCustomPlace extends TPlace
   {
      
      public function TCustomPlace(mapResource:MapResource, isGift:Boolean = false, containerId:Number = 0)
      {
         super(mapResource);
         m_params.isGift = isGift;
         m_params.isStorageWithdrawal = containerId;
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = super.getTransactionData();
         result.isStorageWithdrawl = m_params.isStorageWithdrawal;
         return result;
      }
   }
}

