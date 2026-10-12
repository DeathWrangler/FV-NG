package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.RegionAchievement;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class RegionAchievementSmallRelicWindow extends FarmWindow
   {
      
      private static const TROPHY_WON:String = "smallTrophyWon_mc";
      
      private var m_featureName:String;
      
      private var m_rewardFrame:RegionAchievementRewardFrame;
      
      private var m_achievement:RegionAchievement;
      
      public function RegionAchievementSmallRelicWindow(assetURL:String, featureName:String, achievement:RegionAchievement)
      {
         super(assetURL);
         this.m_featureName = featureName;
         this.m_achievement = achievement;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(TROPHY_WON))
         {
            this.m_rewardFrame = addWidget(new RegionAchievementRewardFrame(m_window[TROPHY_WON],this.m_featureName,this)) as RegionAchievementRewardFrame;
            this.m_rewardFrame.refresh(this.m_achievement);
            this.m_rewardFrame.visible = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         var toggleNPCEvent:RegionAchievementEvent = new RegionAchievementEvent(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,{"visible":true});
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(toggleNPCEvent);
         super.onClose(event);
      }
   }
}

