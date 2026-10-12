package Transactions
{
   public class TSignedCallTransaction extends TFarmTransaction
   {
      
      protected var m_signedCall:String;
      
      protected var m_params:Array;
      
      protected var m_onCompleteCallback:Function;
      
      public function TSignedCallTransaction(signedCall:String = "", params:Array = null, onCompleteCallback:Function = null)
      {
         super();
         this.m_signedCall = signedCall;
         this.m_params = params;
         this.m_onCompleteCallback = onCompleteCallback;
      }
      
      override public function perform() : void
      {
         if(this.m_signedCall != "")
         {
            signedCall(this.m_signedCall,this.m_params);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_onCompleteCallback != null)
         {
            this.m_onCompleteCallback(result);
         }
      }
   }
}

