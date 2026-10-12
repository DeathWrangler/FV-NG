package Widgets.Frames
{
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AntiqueMuseumV2SurveyMapTileSlot;
   import Widgets.Windows.AntiqueMuseumV2SurveyMapWindow;
   import flash.display.DisplayObject;
   
   public class AntiqueMuseumV2SurveyMapTilesFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "np";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumV2SurveyMapWindow;
      
      private var m_featureName:String = "AntiqueMuseumV2";
      
      private var m_tiles:Object;
      
      public function AntiqueMuseumV2SurveyMapTilesFrame(element:DisplayObject, parentWindow:AntiqueMuseumV2SurveyMapWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumV2SurveyMapTileSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         for(var index:int = 0; index < m_slots.length; index++)
         {
            m_slotData.push({"tileSlotNumber":index});
         }
      }
      
      private function get manager() : LandBundleUnlockFeatureManager
      {
         return LandBundleUnlockFeatureManager.getInstance(this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

