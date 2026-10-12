package Widgets.Frames
{
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.LandBundleUnlockFeatureAllTilesSlot;
   import Widgets.Slots.LandBundleUnlockFeatureSelectionMenuTileSlot;
   import Widgets.Windows.LandBundleUnlockFeatureWindow;
   import flash.display.DisplayObject;
   
   public class LandBundleUnlockFeatureAllTilesFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "np";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:LandBundleUnlockFeatureWindow;
      
      private var m_featureName:String = "LandBundleUnlockFeature";
      
      private var m_stationSlot:LandBundleUnlockFeatureSelectionMenuTileSlot;
      
      private var m_tiles:Object;
      
      public function LandBundleUnlockFeatureAllTilesFrame(element:DisplayObject, parentWindow:LandBundleUnlockFeatureWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LandBundleUnlockFeatureAllTilesSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         for(var index:int = 0; index < m_slots.length; index++)
         {
            m_slotData.push({"tileSlotNumber":index});
         }
      }
      
      public function onTileUnselect(tileName:String) : void
      {
         for(var index:int = 0; index < m_slots.length; index++)
         {
            if((m_slots[index] as LandBundleUnlockFeatureAllTilesSlot).getTileItemName() == tileName)
            {
               (m_slots[index] as LandBundleUnlockFeatureAllTilesSlot).unselectTile();
            }
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

