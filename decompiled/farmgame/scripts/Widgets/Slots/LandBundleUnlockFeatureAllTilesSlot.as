package Widgets.Slots
{
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.LandBundleUnlockFeatureAllTilesFrame;
   import Widgets.Windows.LandBundleUnlockFeatureWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class LandBundleUnlockFeatureAllTilesSlot extends ZwSlotFrame
   {
      
      private static const STATE_NORMAL:String = "normal";
      
      private static const STATE_HIGHLIGHT:String = "highlight";
      
      private static const STATE_SELECTED:String = "selected";
      
      private static const STATE_UNLOCKED:String = "unlocked";
      
      private static const PREFIX_EXPANSION:String = "xbb_";
      
      private static const SUFFIX_PAYER:String = "_payer";
      
      private var m_window:LandBundleUnlockFeatureWindow;
      
      private var m_frame:LandBundleUnlockFeatureAllTilesFrame;
      
      private const FEATURE_NAME:String = "LandBundleUnlockFeature";
      
      private var m_tileState:String;
      
      private var m_tileName:String;
      
      private var m_slotNumber:Number;
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_currentSlot:MovieClip;
      
      public function LandBundleUnlockFeatureAllTilesSlot(element:DisplayObject, window:LandBundleUnlockFeatureWindow, frame:LandBundleUnlockFeatureAllTilesFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = true;
         this.m_currentElement_mc = element as MovieClip;
         if(this.m_currentElement_mc)
         {
            this.m_currentElement_mc.visible = true;
            if(this.m_currentElement_mc.hasOwnProperty("hover_me_mc"))
            {
               this.m_currentSlot = this.m_currentElement_mc["hover_me_mc"] as MovieClip;
               this.m_currentSlot.visible = true;
               this.m_currentSlot.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               this.m_currentSlot.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               this.m_currentSlot.addEventListener(MouseEvent.CLICK,this.onTileClick);
            }
         }
      }
      
      private static function isTileLocked(tileName:String) : Boolean
      {
         var result:Boolean = false;
         if(Global.world.getObjectsByName(tileName).length > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function onMouseOver(e:MouseEvent) : void
      {
         if(this.m_tileState == STATE_UNLOCKED)
         {
            this.m_currentElement_mc.gotoAndStop(3);
            return;
         }
         if(!this.manager.canSelectBundle())
         {
            return;
         }
         if(this.m_tileState == STATE_NORMAL)
         {
            this.m_currentElement_mc.gotoAndStop(2);
            this.m_tileState = STATE_HIGHLIGHT;
         }
      }
      
      public function onMouseOut(e:MouseEvent) : void
      {
         if(this.m_tileState == STATE_UNLOCKED)
         {
            this.m_currentElement_mc.gotoAndStop(3);
            return;
         }
         if(!this.manager.canSelectBundle() && this.m_tileState != STATE_SELECTED)
         {
            return;
         }
         if(this.m_tileState == STATE_HIGHLIGHT)
         {
            this.m_currentElement_mc.gotoAndStop(1);
            this.m_tileState = STATE_NORMAL;
         }
      }
      
      public function onTileClick(e:MouseEvent) : void
      {
         if(this.m_tileState == STATE_UNLOCKED)
         {
            this.m_currentElement_mc.gotoAndStop(3);
            return;
         }
         if(!this.manager.canSelectBundle() && this.m_tileState != STATE_SELECTED)
         {
            return;
         }
         if(this.m_tileState == STATE_SELECTED)
         {
            this.m_currentElement_mc.gotoAndStop(1);
            this.m_tileState = STATE_NORMAL;
            this.manager.onTileUnselected(this.m_tileName);
            this.m_window.refreshTilesMenu();
         }
         if(this.m_tileState == STATE_HIGHLIGHT)
         {
            this.m_currentElement_mc.gotoAndStop(4);
            this.m_tileState = STATE_SELECTED;
            this.manager.onTileSelected(this.m_tileName);
            this.m_window.refreshTilesMenu();
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
            if(this.m_slotNumber >= 0 && this.m_slotNumber < this.manager.COUNT_NON_PAYER_TILES)
            {
               this.m_tileName = PREFIX_EXPANSION + "rubbletreasure" + (this.m_slotNumber + 1).toString();
            }
            else
            {
               this.m_tileName = PREFIX_EXPANSION + "rubbletreasure" + SUFFIX_PAYER + (this.m_slotNumber - (this.manager.COUNT_NON_PAYER_TILES - 1)).toString();
            }
            if(!isTileLocked(this.m_tileName) || this.manager.isNonPayerTilePrereqMet(this.m_tileName))
            {
               this.m_tileState = STATE_UNLOCKED;
               this.m_currentElement_mc.gotoAndStop(3);
            }
            else if(this.manager.isTileSelected(this.m_tileName))
            {
               this.m_tileState = STATE_SELECTED;
               this.m_currentElement_mc.gotoAndStop(4);
            }
            else
            {
               this.m_tileState = STATE_NORMAL;
               this.m_currentElement_mc.gotoAndStop(1);
            }
         }
      }
      
      public function unselectTile() : void
      {
         if(this.m_tileState == STATE_SELECTED)
         {
            this.m_currentElement_mc.gotoAndStop(1);
            this.m_tileState = STATE_NORMAL;
         }
      }
      
      public function getTileItemName() : String
      {
         return this.m_tileName;
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

