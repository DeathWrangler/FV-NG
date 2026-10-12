package Widgets.Slots
{
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LandBundleUnlockFeatureSelectionMenuFrame;
   import Widgets.Windows.LandBundleUnlockFeatureWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LandBundleUnlockFeatureSelectionMenuTileSlot extends ZwSlotFrame
   {
      
      private var m_window:LandBundleUnlockFeatureWindow;
      
      private var m_frame:LandBundleUnlockFeatureSelectionMenuFrame;
      
      private const FEATURE_NAME:String = "LandBundleUnlockFeature";
      
      private var m_tileName_tf:ZwTextField;
      
      private var m_tileCost_tf:ZwTextField;
      
      private var m_remove_bt:FarmAnimatedButton;
      
      private var m_tile:Object;
      
      private var m_slotNumber:Number;
      
      public function LandBundleUnlockFeatureSelectionMenuTileSlot(element:DisplayObject, window:LandBundleUnlockFeatureWindow, frame:LandBundleUnlockFeatureSelectionMenuFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = false;
         if(m_element.hasOwnProperty("tile_name_tf"))
         {
            addWidget(this.m_tileName_tf = new ZwTextField(m_element["tile_name_tf"],"Select Tile"));
            this.m_tileName_tf.visible = true;
         }
         if(m_element.hasOwnProperty("tile_cost_tf"))
         {
            addWidget(this.m_tileCost_tf = new ZwTextField(m_element["tile_cost_tf"],""));
            this.m_tileCost_tf.visible = false;
         }
         if(m_element.hasOwnProperty("remove_mc"))
         {
            addWidget(this.m_remove_bt = new FarmAnimatedButton(m_element["remove_mc"]));
            this.m_remove_bt.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         if(data)
         {
            if(data.hasOwnProperty("tileSlotNumber"))
            {
               this.m_slotNumber = data["tileSlotNumber"];
            }
            if(data.hasOwnProperty("tile"))
            {
               this.m_tile = data["tile"];
               if(this.m_tile)
               {
                  this.visible = true;
                  if(this.m_tile.hasOwnProperty("tileName"))
                  {
                     this.m_tileName_tf.text = this.m_tile["tileName"];
                     this.m_tileName_tf.visible = true;
                  }
                  if(this.m_tile.hasOwnProperty("tileCost"))
                  {
                     this.m_tileCost_tf.text = this.m_tile["tileCost"] + " FC";
                     this.m_tileCost_tf.visible = true;
                  }
                  this.m_remove_bt.visible = true;
                  this.m_remove_bt.enabled = true;
                  this.m_remove_bt.callback = this.onRemoveTileClick;
               }
               else
               {
                  this.m_tileName_tf.text = "Select Tile";
                  this.m_tileName_tf.visible = true;
                  this.m_remove_bt.visible = false;
                  this.m_tileCost_tf.visible = false;
               }
            }
         }
      }
      
      public function getTileItemName() : String
      {
         return this.m_tile["tileName"];
      }
      
      public function onRemoveTileClick(e:Event) : *
      {
         this.m_window.disselectTileOnLand(this.m_tile["tileItemName"]);
         this.manager.onTileUnselected(this.m_tile["tileItemName"]);
         this.m_window.refreshTilesMenu();
      }
      
      private function get manager() : LandBundleUnlockFeatureManager
      {
         return LandBundleUnlockFeatureManager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

