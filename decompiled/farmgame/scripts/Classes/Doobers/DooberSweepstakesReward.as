package Classes.Doobers
{
   import Classes.FarmGameObject;
   import Managers.EnglishSweepstakesPromoManager;
   import Managers.FarmStatsManager;
   
   public class DooberSweepstakesReward extends DooberReward
   {
      
      public function DooberSweepstakesReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         super(rewardXml,actionObject);
      }
      
      override public function applyReward() : void
      {
         FarmStatsManager.count("englandsweeps","tripdoober","drop");
         EnglishSweepstakesPromoManager.showDooberToaster();
         EnglishSweepstakesPromoManager.addRewardEntry();
      }
      
      override public function isAvailable() : Boolean
      {
         return EnglishSweepstakesPromoManager.getManager().isFeatureVisible() && EnglishSweepstakesPromoManager.getRewardEntryCount() > 0;
      }
   }
}

