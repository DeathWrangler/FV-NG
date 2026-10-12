package Transactions
{
   public class TSetCraftedGoodPrice extends TFarmTransaction
   {
      
      public static const PRICE_SET_OK:int = 0;
      
      public static const ERROR_UNKNOWN:int = 1;
      
      public static const ERROR_BAD_PRICE:int = 2;
      
      public static const ERROR_RAILS_TOO_HIGH:int = 3;
      
      public static const ERROR_RAILS_TOO_LOW:int = 4;
      
      public static const ERROR_COTTAGE_NOT_FOUND:int = 5;
      
      public static const ERROR_GOOD_NOT_FOUND:int = 6;
      
      public static const ERROR_GOOD_QUANTITY_INSUFFICIENT:int = 7;
      
      public static const ERROR_BAD_ITEM_CODE:int = 8;
      
      private var m_craftingCottageBuildingId:int;
      
      private var m_productCode:String;
      
      private var m_newPrice:Number;
      
      private var m_callback:Function;
      
      public function TSetCraftedGoodPrice(craftingCottageBuildingId:int, productItemCode:String, newPrice:Number, callback:Function)
      {
         super();
         this.m_craftingCottageBuildingId = craftingCottageBuildingId;
         this.m_productCode = productItemCode;
         this.m_newPrice = newPrice;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onSetCraftedGoodPrice",this.m_craftingCottageBuildingId,this.m_productCode,this.m_newPrice);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result.responseCode);
         }
      }
   }
}

