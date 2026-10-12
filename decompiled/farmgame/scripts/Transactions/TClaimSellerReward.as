package Transactions
{
   import Classes.Trading.TradingOrder;
   
   public class TClaimSellerReward extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_order:TradingOrder;
      
      private var m_failCallBack:Function;
      
      public function TClaimSellerReward(order:TradingOrder, callback:Function = null, failCallBack:Function = null)
      {
         super();
         this.m_order = order;
         this.m_callback = callback;
         this.m_failCallBack = failCallBack;
      }
      
      override public function perform() : void
      {
         signedCall("TradingGoodService.onClaimSellerReward",":" + this.m_order.ordererId,this.m_order.itemCode,this.m_order.orderType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         if(this.m_failCallBack != null)
         {
            this.m_failCallBack(errorData);
         }
      }
   }
}

