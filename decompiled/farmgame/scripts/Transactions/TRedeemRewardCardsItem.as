package Transactions
{
   public class TRedeemRewardCardsItem extends TFarmTransaction
   {
      
      private var m_completeCallback:Function;
      
      private var m_redeemItem:String = null;
      
      public function TRedeemRewardCardsItem(completeCallBack:Function, itemCode:String = null)
      {
         this.m_completeCallback = completeCallBack;
         this.m_redeemItem = itemCode;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RewardCardsService.redeemItem",this.m_redeemItem);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_completeCallback != null)
         {
            this.m_completeCallback(result);
         }
      }
   }
}

