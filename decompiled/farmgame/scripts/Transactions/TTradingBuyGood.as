package Transactions
{
   import Classes.Trading.TradingGood;
   
   public class TTradingBuyGood extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_goodToBuy:TradingGood = null;
      
      private var m_failCallBack:Function;
      
      public function TTradingBuyGood(goodToBuy:TradingGood, callback:Function = null, failCallBack:Function = null)
      {
         super();
         this.m_goodToBuy = goodToBuy;
         this.m_callback = callback;
         this.m_failCallBack = failCallBack;
      }
      
      override public function perform() : void
      {
         signedCall("TradingGoodService.onBuyGood",":" + this.m_goodToBuy.sellingUid,this.m_goodToBuy.itemCode,this.m_goodToBuy.orderType);
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

