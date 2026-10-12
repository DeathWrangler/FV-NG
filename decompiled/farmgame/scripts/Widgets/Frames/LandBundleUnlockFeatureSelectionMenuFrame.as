package Widgets.Frames
{
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.LandBundleUnlockFeatureSelectionMenuTileSlot;
   import Widgets.Windows.LandBundleUnlockFeatureWindow;
   import flash.display.DisplayObject;
   
   public class LandBundleUnlockFeatureSelectionMenuFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "selected_tile_item_";
      
      protected static const SLOT_POSTFIX:String = "";
      
      private var m_window:LandBundleUnlockFeatureWindow;
      
      private var m_featureName:String = "LandBundleUnlockFeature";
      
      private var m_stationSlot:LandBundleUnlockFeatureSelectionMenuTileSlot;
      
      private var m_tiles:Array;
      
      public function LandBundleUnlockFeatureSelectionMenuFrame(element:DisplayObject, parentWindow:LandBundleUnlockFeatureWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LandBundleUnlockFeatureSelectionMenuTileSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         var i:int = 0;
         m_slotData = [];
         this.setData();
         if(this.m_tiles)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               m_slotData.push({
                  "tileSlotNumber":i,
                  "tile":this.m_tiles[i]
               });
            }
         }
      }
      
      public function setData() : void
      {
         var tileData:XML = null;
         this.m_tiles = [];
         var selectedTiles:Array = this.manager.getTileSelectionList();
         for(var index:* = 0; index < selectedTiles.length; index++)
         {
            tileData = this.manager.getTileData(selectedTiles[index]);
            this.m_tiles[index] = {
               "tileName":tileData.@friendlyName,
               "tileCost":tileData.@cost,
               "tileItemName":tileData.@name
            };
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

