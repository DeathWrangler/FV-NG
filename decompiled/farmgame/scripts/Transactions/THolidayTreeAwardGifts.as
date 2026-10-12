package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class THolidayTreeAwardGifts extends TWorldState
   {
      
      private var m_callback:Function;
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      public function THolidayTreeAwardGifts(building:RewardCreditsBuilding, callback:Function = null)
      {
         super(building);
         this.m_callback = callback;
         this.m_rewardCreditsBuilding = building;
      }
      
      override public function perform() : void
      {
         signedWorldAction("awardGifts");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftName:String = null;
         if(result != null)
         {
            if(result.gifts)
            {
               for each(giftName in result.gifts)
               {
                  if(giftName != "")
                  {
                     Global.player.addGift(giftName,"0",1);
                  }
               }
            }
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

