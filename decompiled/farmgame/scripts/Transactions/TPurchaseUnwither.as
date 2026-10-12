package Transactions
{
   public class TPurchaseUnwither extends TFarmTransaction
   {
      
      private var m_unwitherPrice:int;
      
      public function TPurchaseUnwither(unwitherPrice:int)
      {
         this.m_unwitherPrice = unwitherPrice;
         super();
      }
      
      override public function perform() : void
      {
         var neighborId:String = "";
         if(Global.worldManager.isVisiting())
         {
            neighborId = Global.worldManager.getVisiting();
         }
         signedCall("PurchaseUnwitherService.purchaseUnwitherItem",this.m_unwitherPrice,neighborId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.unwitherPurchased)
         {
            Global.player.cash -= this.m_unwitherPrice;
         }
      }
   }
}

