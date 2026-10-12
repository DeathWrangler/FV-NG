package Classes.consumables
{
   import Classes.util.UserRewardUtil;
   import Managers.FarmGameSettingsManager;
   
   public class CRewardConsumeAll extends CRewardConsumable
   {
      
      public function CRewardConsumeAll(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            UserRewardUtil.grantUserRewardsFromDataSource(getItem().rewardsData);
         }
         else
         {
            UserRewardUtil.grantUserRewardsFromXml(getItem().rewardsXML);
         }
      }
   }
}

