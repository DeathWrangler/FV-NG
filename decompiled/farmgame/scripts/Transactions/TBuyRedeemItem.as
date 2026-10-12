package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class TBuyRedeemItem extends TWorldState
   {
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_redeemItemName:String = "";
      
      protected var m_isAvatarItem:Boolean;
      
      protected var m_completeCallback:Function = null;
      
      public function TBuyRedeemItem(building:RewardCreditsBuilding, redeemItemName:String, isAvatarItem:Boolean = false, completeCallBack:Function = null)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_redeemItemName = redeemItemName;
         this.m_isAvatarItem = isAvatarItem;
         this.m_completeCallback = completeCallBack;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("buyRedeemItem",this.m_redeemItemName,this.m_isAvatarItem);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_completeCallback != null)
         {
            this.m_completeCallback();
         }
      }
   }
}

