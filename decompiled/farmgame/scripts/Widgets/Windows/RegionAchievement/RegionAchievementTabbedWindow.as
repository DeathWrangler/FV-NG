package Widgets.Windows.RegionAchievement
{
   import Widgets.Windows.FarmWindow;
   
   public class RegionAchievementTabbedWindow extends FarmWindow
   {
      
      private static const SHIELD_DISPLAY:String = "shieldDisplay_mc";
      
      private var m_featureName:String;
      
      private var m_regionId:String;
      
      private var m_tabFrame:RegionAchievementTabContainerFrame;
      
      public function RegionAchievementTabbedWindow(assetURL:String, featureName:String, regionId:String)
      {
         super(assetURL);
         this.m_featureName = featureName;
         this.m_regionId = regionId;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(SHIELD_DISPLAY))
         {
            this.m_tabFrame = addWidget(new RegionAchievementTabContainerFrame(m_window[SHIELD_DISPLAY],this.m_featureName,this)) as RegionAchievementTabContainerFrame;
            this.m_tabFrame.visible = true;
            this.m_tabFrame.refresh();
            this.m_tabFrame.showTab(this.m_regionId);
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.m_tabFrame.refresh();
      }
   }
}

