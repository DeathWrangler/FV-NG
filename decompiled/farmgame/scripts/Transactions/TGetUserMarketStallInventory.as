package Transactions
{
   import Managers.Crafting.MarketViewManager;
   
   public class TGetUserMarketStallInventory extends TFarmTransaction
   {
      
      private var m_Uid:String;
      
      private var m_Callback:Function;
      
      public function TGetUserMarketStallInventory(uid:String, callBack:Function = null)
      {
         super();
         this.m_Uid = uid;
         this.m_Callback = callBack;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onRefreshUserOffering",this.m_Uid);
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

