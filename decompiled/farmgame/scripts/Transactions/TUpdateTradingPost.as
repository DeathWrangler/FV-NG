package Transactions
{
   public class TUpdateTradingPost extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TUpdateTradingPost(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("TradingGoodService.getTradingGoods");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

