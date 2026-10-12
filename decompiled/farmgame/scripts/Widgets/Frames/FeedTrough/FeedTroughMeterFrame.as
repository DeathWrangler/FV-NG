package Widgets.Frames.FeedTrough
{
   import Classes.CreditsBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CreditsBuilding.MeterFrame;
   import flash.display.DisplayObject;
   
   public class FeedTroughMeterFrame extends MeterFrame
   {
      
      public function FeedTroughMeterFrame(element:DisplayObject, building:CreditsBuilding, featureName:String)
      {
         super(element,building,featureName);
         var grainTop:ZwFrame = new ZwFrame(m_element.grainTop_mc);
         grainTop.y = m_element.bar_mc.y - grainTop.height / 2;
         addWidget(grainTop);
      }
      
      override public function refreshMeter() : void
      {
         super.refreshMeter();
         (getWidget(m_element.receivedAmount_tf) as ZwTextField).text = ZLocUtils.t("Dialogs","MeterCount",{
            "quantity":m_building.getCurrentCredits(),
            "maximum":m_building.capacity
         });
         var grainTop:ZwFrame = getWidget(m_element.grainTop_mc) as ZwFrame;
         grainTop.y = m_element.bar_mc.y - grainTop.height / 2;
      }
      
      override protected function getProgressBarContainer() : DisplayObject
      {
         return m_element as DisplayObject;
      }
      
      override protected function getIncrementPrefixTextFieldContainer() : String
      {
         return "increment";
      }
      
      override protected function addCounterText() : void
      {
         addWidget(new ZwTextField(m_element.receivedLabel_tf,ZLocUtils.t("Dialogs","CurrentFeed")));
         addWidget(new ZwTextField(m_element.receivedAmount_tf,ZLocUtils.t("Dialogs","MeterCount",{
            "quantity":m_building.getCurrentCredits(),
            "maximum":m_building.capacity
         })));
      }
   }
}

