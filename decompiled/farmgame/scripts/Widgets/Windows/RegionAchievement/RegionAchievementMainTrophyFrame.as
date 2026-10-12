package Widgets.Windows.RegionAchievement
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class RegionAchievementMainTrophyFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "trophy_";
      
      private var m_parentWindow:RegionAchievementWindow;
      
      private var m_featureName:String;
      
      public function RegionAchievementMainTrophyFrame(element:DisplayObject, parentWindow:RegionAchievementWindow, featureName:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RegionAchievementMainTrophySlot(slotElement,this.m_parentWindow,this.m_featureName);
      }
      
      override protected function populateSlot(slot:ZwSlotFrame, data:Object) : void
      {
         if(data)
         {
            super.populateSlot(slot,data);
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      public function set slotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
   }
}

