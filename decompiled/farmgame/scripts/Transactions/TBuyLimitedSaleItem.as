package Transactions
{
   import Engine.Events.TransactionEvent;
   
   public class TBuyLimitedSaleItem extends TFarmTransaction
   {
      
      private var m_itemName:String;
      
      private var m_salePrice:int;
      
      public function TBuyLimitedSaleItem(itemName:String, salePrice:int)
      {
         super();
         this.m_itemName = itemName;
         this.m_salePrice = salePrice;
      }
      
      override public function perform() : void
      {
         signedCall("LimitedSaleService.purchaseSaleItem",this.m_itemName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result == "success")
         {
            dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED,this));
         }
      }
   }
}

