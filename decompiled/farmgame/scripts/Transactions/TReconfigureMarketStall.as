package Transactions
{
   public class TReconfigureMarketStall extends TFarmTransaction
   {
      
      private var m_MarketStallId:int;
      
      private var m_BushelItemCode:String;
      
      private var m_Callback:Function;
      
      public function TReconfigureMarketStall(marketStallId:int, bushelItemCode:String, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_MarketStallId = marketStallId;
         this.m_BushelItemCode = bushelItemCode;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onReconfigureStall",this.m_MarketStallId,this.m_BushelItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_Callback)
            {
               this.m_Callback();
            }
         }
      }
   }
}

