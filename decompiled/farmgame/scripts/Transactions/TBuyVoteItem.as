package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class TBuyVoteItem extends TWorldState
   {
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_voteItemName:String = "";
      
      protected var m_expectedPrice:int = 0;
      
      protected var m_completeCallback:Function = null;
      
      public function TBuyVoteItem(building:RewardCreditsBuilding, voteItemName:String, expectedPrice:int, completeCallBack:Function = null)
      {
         super(building);
         this.m_rewardCreditsBuilding = building;
         this.m_voteItemName = voteItemName;
         this.m_expectedPrice = expectedPrice;
         this.m_completeCallback = completeCallBack;
      }
      
      override public function perform() : void
      {
         signedWorldAction("buyVoteItem",{
            "itemName":this.m_voteItemName,
            "price":this.m_expectedPrice
         });
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

