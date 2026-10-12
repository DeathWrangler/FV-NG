package Transactions
{
   public class TFleaMarket extends TFarmTransaction
   {
      
      public static const TYPE_INIT:String = "initialize";
      
      public static const TYPE_RESELL:String = "resellItem";
      
      private var m_transactionType:String;
      
      private var m_callback:Function;
      
      private var m_extraData:Object = null;
      
      public function TFleaMarket(transactionType:String = "initialize", callback:Function = null, extraData:Object = null)
      {
         this.m_transactionType = transactionType;
         this.m_callback = callback;
         this.m_extraData = extraData;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("FleaMarketService." + this.m_transactionType,this.m_extraData);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

