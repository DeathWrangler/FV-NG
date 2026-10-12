package Widgets.Frames.Beehives
{
   import Classes.BeehiveBuilding;
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CreditsBuilding.MeterFrame;
   import flash.display.DisplayObject;
   
   public class BeehiveMeterFrame extends MeterFrame
   {
      
      private var m_levelTitles:Array = new Array();
      
      public function BeehiveMeterFrame(element:DisplayObject, building:RewardCreditsBuilding, featureName:String)
      {
         super(element,building,featureName);
         this.populateLevelTitles();
         addWidget(new ZwTextField(m_element.status_tf,this.getLevelTitle(m_building.getCurrentCredits())));
      }
      
      private function populateLevelTitles() : void
      {
         var levels:Array = m_building.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            this.m_levelTitles[index] = ZLocUtils.t(PROPERTIES_FILE_NAME,m_featureName + "_Level_" + (index + 1));
         }
      }
      
      private function getLevelTitle(numCreditsReceived:uint) : String
      {
         var title:String = "";
         var levels:Array = m_building.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            if(numCreditsReceived >= levels[index])
            {
               title = this.m_levelTitles[index];
            }
         }
         if(!title)
         {
            title = ZLocUtils.t(PROPERTIES_FILE_NAME,m_featureName + "_Level_0");
         }
         return title;
      }
      
      override protected function getProgressBarContainer() : DisplayObject
      {
         return m_element.meterbar_mc;
      }
      
      override protected function getIncrementPrefixTextFieldContainer() : String
      {
         return "increment";
      }
      
      override protected function addCounterText() : void
      {
         addWidget(new ZwTextField(m_element.meterLabel_tf,ZLocUtils.t(PROPERTIES_FILE_NAME,BeehiveBuilding.BEEHIVE_FEATURE + "_TotalBees")));
         addWidget(new ZwTextField(m_element.amount_tf,m_building.getCurrentCredits().toString()));
      }
   }
}

