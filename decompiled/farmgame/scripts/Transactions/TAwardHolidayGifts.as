package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class TAwardHolidayGifts extends TWorldState
   {
      
      private var m_numGifts:int;
      
      private var m_callback:Function;
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      public function TAwardHolidayGifts(building:RewardCreditsBuilding, numGifts:int, callback:Function = null)
      {
         super(building);
         this.m_numGifts = numGifts;
         this.m_rewardCreditsBuilding = building;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedWorldAction("awardOpenedGifts",{"numGifts":this.m_numGifts});
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

