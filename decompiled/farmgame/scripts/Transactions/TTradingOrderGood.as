package Transactions
{
   import Classes.Trading.TradingGood;
   
   public class TTradingOrderGood extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_goodToOrder:TradingGood = null;
      
      private var m_failCallBack:Function;
      
      public function TTradingOrderGood(goodToOrder:TradingGood, callback:Function = null, failCallBack:Function = null)
      {
         super();
         this.m_goodToOrder = goodToOrder;
         this.m_callback = callback;
         this.m_failCallBack = failCallBack;
      }
      
      override public function perform() : void
      {
         signedCall("TradingGoodService.onOrderGood",":" + this.m_goodToOrder.sellingUid,this.m_goodToOrder.itemCode,this.m_goodToOrder.orderType);
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

