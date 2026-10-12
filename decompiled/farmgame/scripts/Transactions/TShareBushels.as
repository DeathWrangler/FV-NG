package Transactions
{
   import Classes.ZItem.FarmItem;
   import Managers.Crafting.CraftingManager;
   
   public class TShareBushels extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_bushelCode:String;
      
      private var m_bundleId:String = null;
      
      private var m_quantity:int;
      
      private var m_functionString:String;
      
      public function TShareBushels(bushelCode:String, quantity:int, callBack:Function = null, bundleId:String = "CraftingShareFromStall", deductBushels:Boolean = true)
      {
         super();
         this.m_callback = callBack;
         this.m_quantity = quantity;
         this.m_bushelCode = bushelCode;
         this.m_bundleId = bundleId;
         if(deductBushels)
         {
            this.m_functionString = "CraftingService.onShareBushels";
         }
         else
         {
            this.m_functionString = "CraftingService.onShareNoDeductBushels";
         }
      }
      
      override public function perform() : void
      {
         signedCall(this.m_functionString,this.m_bushelCode,this.m_quantity);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var bushelItem:FarmItem = null;
         if(null != result)
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelCode);
            CraftingManager.getInstance().displayShareMarketStallFeed(bushelItem,this.m_quantity,result.rewardUrl,this.m_bundleId);
            if(null != this.m_callback)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

