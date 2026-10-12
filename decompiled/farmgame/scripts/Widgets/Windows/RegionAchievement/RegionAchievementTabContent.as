package Widgets.Windows.RegionAchievement
{
   import Managers.RegionAchievementManager;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   
   public class RegionAchievementTabContent extends ZwFrame
   {
      
      private static const TROPHY_MC:String = "trophyContainer_mc";
      
      private static const TASK_MC:String = "taskContainer_mc";
      
      private var m_featureName:String;
      
      private var m_taskFrame:RegionAchievementTaskContainerFrame;
      
      private var m_trophyFrame:RegionAchievementTrophyFrame;
      
      private var m_tabName:String;
      
      public function RegionAchievementTabContent(element:DisplayObject, featureName:String, tabName:String)
      {
         this.m_featureName = featureName;
         this.m_tabName = tabName;
         super(element);
         this.initTrophyFrame();
         this.initTaskFrame();
         this.refresh(this.m_tabName);
      }
      
      private function initTrophyFrame() : void
      {
         if(m_element.hasOwnProperty(TROPHY_MC))
         {
            this.m_trophyFrame = addWidget(new RegionAchievementTrophyFrame(m_element[TROPHY_MC],this.m_featureName,this.m_tabName)) as RegionAchievementTrophyFrame;
            this.m_trophyFrame.visible = true;
         }
      }
      
      private function initTaskFrame() : void
      {
         if(m_element.hasOwnProperty(TASK_MC))
         {
            this.m_taskFrame = addWidget(new RegionAchievementTaskContainerFrame(m_element[TASK_MC],this.m_featureName)) as RegionAchievementTaskContainerFrame;
            this.m_taskFrame.visible = true;
         }
      }
      
      public function refresh(tabName:String) : void
      {
         this.m_tabName = tabName;
         this.m_trophyFrame.refresh(this.m_tabName);
         this.m_taskFrame.items = RegionAchievementManager.getInstance(this.m_featureName).getActiveRegionAchievementsByRegionId(this.m_tabName);
      }
   }
}

