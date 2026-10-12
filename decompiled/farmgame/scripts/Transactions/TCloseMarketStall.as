package Transactions
{
   public class TCloseMarketStall extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      private var m_MarketStallObjectId:Number;
      
      public function TCloseMarketStall(stallObjectId:Number, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_MarketStallObjectId = stallObjectId;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onCloseStall",this.m_MarketStallObjectId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var error:Boolean = false;
         if(null != result && result.hasOwnProperty("success"))
         {
            if(result.success)
            {
               error = true;
            }
         }
         else
         {
            error = true;
         }
         if(error)
         {
         }
      }
   }
}

