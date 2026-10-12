package Transactions
{
   public class TDollarBundleDiscount extends TFarmTransaction
   {
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TDollarBundleDiscount(transactionCompleteCallback:Function = null)
      {
         super();
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("DollarBundleService.getBundleDiscount");
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_transactionCompleteCallBack != null)
         {
            this.m_transactionCompleteCallBack(result);
         }
      }
   }
}

