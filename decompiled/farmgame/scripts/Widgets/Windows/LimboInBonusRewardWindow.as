package Widgets.Windows
{
   public class LimboInBonusRewardWindow extends LimboInnovationRewardWindow
   {
      
      public function LimboInBonusRewardWindow(assetUrl:String, featureName:String, buildingId:String, isBonusReward:Boolean)
      {
         m_featureName = featureName;
         m_isBonusReward = isBonusReward;
         m_buildingId = buildingId;
         super(assetUrl,featureName,buildingId,isBonusReward);
      }
   }
}

