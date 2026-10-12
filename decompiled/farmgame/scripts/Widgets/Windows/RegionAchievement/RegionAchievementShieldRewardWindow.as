package Widgets.Windows.RegionAchievement
{
   import Widgets.Windows.FarmWindow;
   
   public class RegionAchievementShieldRewardWindow extends FarmWindow
   {
      
      private static const SHIELD_WON:String = "mediumTrophyWon_mc";
      
      private var m_featureName:String;
      
      private var m_regionId:String;
      
      private var m_shieldRewardFrame:RegionAchievementShieldRewardFrame;
      
      public function RegionAchievementShieldRewardWindow(assetURL:String, featureName:String, regionId:String)
      {
         super(assetURL);
         this.m_featureName = featureName;
         this.m_regionId = regionId;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(SHIELD_WON))
         {
            this.m_shieldRewardFrame = addWidget(new RegionAchievementShieldRewardFrame(m_window[SHIELD_WON],this.m_featureName,this)) as RegionAchievementShieldRewardFrame;
            this.m_shieldRewardFrame.visible = true;
            this.m_shieldRewardFrame.refresh(this.m_regionId);
         }
      }
   }
}

