package Transactions
{
   public class DollarBundle extends TFarmTransaction
   {
      
      private var m_transactionCompleteCallBack:Function;
      
      private var m_paymentCode:String;
      
      public function DollarBundle(extraData:Object = null, paymentcode:String = null, onBuyCallback:Function = null)
      {
         super();
         this.m_transactionCompleteCallBack = onBuyCallback;
         this.m_paymentCode = paymentcode;
      }
      
      override public function perform() : void
      {
         signedCall("DollarBundleService.BuyBundle",this.m_paymentCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_transactionCompleteCallBack != null)
         {
            this.m_transactionCompleteCallBack();
         }
      }
   }
}

