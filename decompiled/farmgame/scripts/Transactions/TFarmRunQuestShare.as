package Transactions
{
   import Managers.FarmRunQuestManager;
   
   public class TFarmRunQuestShare extends TFarmTransaction
   {
      
      private var m_featureName:String = null;
      
      private var m_ItemCode:String = null;
      
      public function TFarmRunQuestShare(featureName:String, itemCode:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_ItemCode = itemCode;
      }
      
      override public function perform() : void
      {
         signedCall("FarmRunQuestService.shareReward",this.m_featureName,this.m_ItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(result["friendReward"] != null)
         {
            FarmRunQuestManager.getInstance().postRewardFeed(result["friendReward"]);
         }
      }
   }
}

