package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ScratchCardTileSlot;
   import Widgets.Windows.ScratchCardWindow;
   import flash.display.DisplayObject;
   
   public final class ScratchCardTileFrame extends FarmSlotContainerFrame
   {
      
      public static const KEY_STATUS_SCRATCHED:String = "scratched";
      
      public static const KEY_STATUS_TILE_ITEM:String = "item";
      
      private var m_slotPrefix:String = "slot_";
      
      private var m_slotSuffix:String = "_mc";
      
      public const NUM_TILES:int = 9;
      
      protected var m_items:Array = null;
      
      public function ScratchCardTileFrame(element:DisplayObject, prizes:Array)
      {
         this.m_items = prizes;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ScratchCardTileSlot(slotElement);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
      
      override protected function getSlotPostfix() : String
      {
         return this.m_slotSuffix;
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      public function repopulateData(items:Array) : void
      {
         if(items == null)
         {
            items = [];
         }
         this.m_items = items;
         this.setupData();
         this.refresh();
      }
      
      public function setSlotClickCallbacks(callback:Function) : void
      {
         var tile:ScratchCardTileSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            tile = m_slots[i] as ScratchCardTileSlot;
            tile.setSlotClickCallback(callback);
         }
      }
      
      public function getTileScratchedStatus() : Array
      {
         var tile:ScratchCardTileSlot = null;
         var scratchedStatusObject:Object = null;
         var result:Array = new Array();
         for(var i:int = 0; i < m_slots.length; i++)
         {
            tile = m_slots[i] as ScratchCardTileSlot;
            scratchedStatusObject = {};
            scratchedStatusObject[KEY_STATUS_SCRATCHED] = tile.isScratched();
            scratchedStatusObject[KEY_STATUS_TILE_ITEM] = this.m_items[i];
            result.push(scratchedStatusObject);
         }
         return result;
      }
      
      public function resetTiles() : void
      {
         var tile:ScratchCardTileSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            tile = m_slots[i] as ScratchCardTileSlot;
            tile.resetTile();
         }
      }
      
      public function scratchAllTiles() : void
      {
         var tile:ScratchCardTileSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            tile = m_slots[i] as ScratchCardTileSlot;
            tile.scratchTile();
         }
      }
      
      public function setWinningItem(winningValue:Object) : void
      {
         var tile:ScratchCardTileSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            tile = m_slots[i] as ScratchCardTileSlot;
            if(ScratchCardWindow.compareScratchObjects(this.m_items[i],winningValue) == true)
            {
               tile.playWinAnimation();
               tile.toggleMatchedBorder(true);
            }
         }
      }
   }
}

