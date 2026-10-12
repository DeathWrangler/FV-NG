package Widgets.Frames.TicketParty
{
   import Classes.RewardCreditsBuilding;
   import Widgets.Frames.CreditsBuilding.MeterFrame;
   import flash.display.DisplayObject;
   
   public class TicketPartyMeterFrame extends MeterFrame
   {
      
      public function TicketPartyMeterFrame(element:DisplayObject, building:RewardCreditsBuilding, featureName:String, countToStartMeterAt:Number = 0)
      {
         super(element,building,featureName,true,countToStartMeterAt);
         refreshMeter();
      }
      
      override protected function initMaximum() : void
      {
         m_progressBar.maximum = int(Global.farmGameSettingsManager.getBuildingCreditsXml(m_featureName).@meterMaxCredits);
      }
      
      override protected function getProgressBarContainer() : DisplayObject
      {
         return m_element.bar_mc;
      }
      
      override protected function getIncrementPrefixTextFieldContainer() : String
      {
         return "increment";
      }
      
      override protected function addCounterText() : void
      {
      }
   }
}

