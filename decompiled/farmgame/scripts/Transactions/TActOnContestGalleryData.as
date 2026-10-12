package Transactions
{
   import Classes.util.UserRewardUtil;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   
   public class TActOnContestGalleryData extends TFarmTransaction
   {
      
      private static const FARM_QUEST_METHOD:String = "onSubmitGalleryVotes";
      
      private var m_params:Object = {};
      
      public function TActOnContestGalleryData(params:Object = null)
      {
         super();
         this.m_params = params;
      }
      
      override public function perform() : void
      {
         if(this.m_params.hasOwnProperty("eventId") && this.m_params["eventId"] != null && (this.m_params.hasOwnProperty("votes") && this.m_params["votes"] != null))
         {
            signedCall("PhotoContestService.onSubmitGalleryVotes",this.m_params["eventId"],this.m_params["votes"]);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(result.hasOwnProperty("rewardData") && result["rewardData"].length > 0)
            {
               FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_POINTS_PHYLUM,DecoPointsManager.DECOPOINTS_POINTS_GALLERY,DecoPointsManager.DECOPOINTS_POINTS_GALLERY_VOTE);
               UserRewardUtil.grantUserRewardsFromArray(result["rewardData"]);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var vote:int = 0;
         var result:Object = new Object();
         result.method = FARM_QUEST_METHOD;
         result.count = 0;
         if(this.m_params.hasOwnProperty("votes") && this.m_params["votes"] != null)
         {
            for each(vote in this.m_params["votes"])
            {
               if(vote == DecoPointsManager.SUBMIT_GALLERY_VOTE)
               {
                  ++result.count;
               }
            }
         }
         return result;
      }
   }
}

