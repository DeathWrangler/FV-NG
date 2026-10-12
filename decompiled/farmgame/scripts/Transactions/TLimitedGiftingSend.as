package Transactions
{
   public class TLimitedGiftingSend extends TFarmTransaction
   {
      
      public static const ITEMCONTEXT_LIMITEDGIFT:String = "limitedGift";
      
      private var m_featureName:String;
      
      private var m_recipients:Array;
      
      private var m_retryCount:int;
      
      private var m_callback:Function;
      
      private var m_isMultiGiftSend:Boolean;
      
      private var m_itemIndexArray:Array;
      
      public function TLimitedGiftingSend(featureName:String, recipients:Array, callback:Function = null, retryCount:int = 0, multiGiftSend:Boolean = false, itemIndexArray:Array = null)
      {
         super();
         this.m_featureName = featureName;
         this.m_recipients = recipients;
         this.m_retryCount = retryCount;
         this.m_callback = callback;
         this.m_isMultiGiftSend = multiGiftSend;
         this.m_itemIndexArray = itemIndexArray;
      }
      
      override public function perform() : void
      {
         signedCall("PresentService.buyAndSendLimitedGift",this.m_featureName,this.m_recipients,ITEMCONTEXT_LIMITEDGIFT,null,this.m_retryCount,this.m_isMultiGiftSend,this.m_itemIndexArray);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && result.complete != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

