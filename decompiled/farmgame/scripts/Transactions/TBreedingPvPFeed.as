package Transactions
{
   import Classes.feed.BreedingPvPFeed;
   
   public class TBreedingPvPFeed extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      protected var m_feedObject:BreedingPvPFeed;
      
      public function TBreedingPvPFeed(featureName:String, feedObject:BreedingPvPFeed)
      {
         this.m_featureName = featureName;
         this.m_feedObject = feedObject;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BreedingService.getPvPReward",this.m_featureName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.rewardLink))
         {
            this.m_feedObject.onGetReward(result);
         }
      }
   }
}

