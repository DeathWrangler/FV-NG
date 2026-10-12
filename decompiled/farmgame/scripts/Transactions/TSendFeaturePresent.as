package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class TSendFeaturePresent extends TWorldState
   {
      
      private var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      private var m_friendId:String;
      
      private var m_friendName:String;
      
      private var m_presentItemName:String;
      
      private var m_callback:Function = null;
      
      public function TSendFeaturePresent(building:RewardCreditsBuilding, friendId:String, friendName:String, presentItemName:String, callback:Function)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_presentItemName = presentItemName;
         this.m_friendId = friendId;
         this.m_friendName = friendName;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("sendPresent",this.m_friendId,this.m_presentItemName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(this.m_callback != null)
            {
               this.m_callback(this.m_friendId,this.m_friendName);
            }
         }
      }
   }
}

