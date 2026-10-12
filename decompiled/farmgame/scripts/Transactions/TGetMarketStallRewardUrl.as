package Transactions
{
   public class TGetMarketStallRewardUrl extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      private var m_LastBushelCode:String;
      
      private var m_StallOwner:String;
      
      public function TGetMarketStallRewardUrl(lastBushelCode:String, stallOwner:String, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_LastBushelCode = lastBushelCode;
         this.m_StallOwner = stallOwner;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onGetMarketStallRewardUrl",this.m_StallOwner,this.m_LastBushelCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_Callback)
            {
               this.m_Callback(result.rewardUrl);
            }
         }
      }
   }
}

