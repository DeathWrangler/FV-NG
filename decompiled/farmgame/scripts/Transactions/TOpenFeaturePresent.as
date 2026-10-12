package Transactions
{
   import Classes.FeaturePresent;
   import Classes.RewardCreditsBuilding;
   
   public class TOpenFeaturePresent extends TWorldState
   {
      
      private var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      private var m_presentData:FeaturePresent;
      
      private var m_callback:Function = null;
      
      public function TOpenFeaturePresent(building:RewardCreditsBuilding, presentData:FeaturePresent, callback:Function)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_presentData = presentData;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("openPresent",this.m_presentData.friendId,this.m_presentData.creationTimestamp);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var rewardURL:String = "";
         if(Boolean(result) && Boolean(result.rewardUrl))
         {
            rewardURL = result.rewardUrl;
         }
         if(this.m_callback != null)
         {
            this.m_callback(this.m_rewardCreditsBuilding,this.m_presentData,rewardURL);
         }
      }
   }
}

