package Transactions
{
   import Managers.Crafting.MarketViewManager;
   
   public class TGetMarketView extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      public function TGetMarketView(callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onRefreshMarketView");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            MarketViewManager.getInstance().updateViewFromResponse(result);
            if(null != this.m_Callback)
            {
               this.m_Callback();
            }
         }
      }
   }
}

