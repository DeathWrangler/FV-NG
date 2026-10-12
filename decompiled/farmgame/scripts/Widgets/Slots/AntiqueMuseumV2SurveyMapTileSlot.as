package Widgets.Slots
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumV2SurveyMapTilesFrame;
   import Widgets.Windows.AntiqueMuseumV2SurveyMapWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AntiqueMuseumV2SurveyMapTileSlot extends ZwSlotFrame
   {
      
      private static const STATE_NORMAL:String = "normal";
      
      private static const STATE_HIGHLIGHT:String = "highlight";
      
      private static const STATE_SELECTED:String = "selected";
      
      private static const STATE_UNLOCKED:String = "unlocked";
      
      private static const PREFIX_EXPANSION:String = "xhf_";
      
      private static const SUFFIX_PAYER:String = "_payer";
      
      private var m_window:AntiqueMuseumV2SurveyMapWindow;
      
      private var m_frame:AntiqueMuseumV2SurveyMapTilesFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_currentSlot:MovieClip;
      
      private var m_buyPopup:MovieClip;
      
      private var m_dropRate_tf:ZwTextField;
      
      private var m_buytile_bt:FarmAnimatedTextButton;
      
      private var m_popupclose_bt:FarmButton;
      
      private var m_hover_frame:ZwFrame;
      
      private var m_tileState:String;
      
      private var m_tileName:String;
      
      private var m_tileWeight:int;
      
      private var m_slotNumber:Number;
      
      public function AntiqueMuseumV2SurveyMapTileSlot(element:DisplayObject, window:AntiqueMuseumV2SurveyMapWindow, frame:AntiqueMuseumV2SurveyMapTilesFrame)
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
         if(!this.manager.canSelectTile())
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
         if(!this.manager.canSelectTile() && this.m_tileState != STATE_SELECTED)
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
         if(!this.manager.canSelectTile() && this.m_tileState != STATE_SELECTED)
         {
            return;
         }
         if(this.m_tileState == STATE_SELECTED)
         {
            this.m_currentElement_mc.gotoAndStop(1);
            this.m_tileState = STATE_NORMAL;
            this.manager.onTileUnselected(this.m_tileName);
         }
         if(this.m_tileState == STATE_HIGHLIGHT)
         {
            this.m_currentElement_mc.gotoAndStop(5);
            if(this.m_currentElement_mc.hasOwnProperty("buy_popup"))
            {
               this.m_buyPopup = this.m_currentElement_mc["buy_popup"] as MovieClip;
               this.m_buyPopup.visible = true;
               if(this.m_buyPopup.hasOwnProperty("droprate_tf"))
               {
                  this.m_dropRate_tf = new ZwTextField(this.m_buyPopup["droprate_tf"],"");
                  this.m_dropRate_tf.text = this.getTileIntensitybyWeight(this.m_tileWeight);
                  this.m_dropRate_tf.visible = true;
               }
               if(this.m_buyPopup.hasOwnProperty("buy_bt"))
               {
                  this.m_buytile_bt = new FarmAnimatedTextButton(this.m_buyPopup["buy_bt"],"Buy",this.onTileBuyButtonClick);
                  this.m_buytile_bt.visible = true;
                  this.m_buytile_bt.enabled = true;
               }
               if(this.m_buyPopup.hasOwnProperty("popupclose_bt"))
               {
                  this.m_popupclose_bt = new FarmButton(this.m_buyPopup["popupclose_bt"],this.onPopupClose);
                  this.m_popupclose_bt.visible = true;
               }
            }
            this.m_tileState = STATE_SELECTED;
            this.manager.onTileSelected(this.m_tileName);
         }
      }
      
      private function getTileIntensitybyWeight(weight:int) : String
      {
         var result:String = "Low";
         if(weight == 3)
         {
            result = "Medium";
         }
         if(weight == 9)
         {
            result = "High";
         }
         return result;
      }
      
      override public function populate(data:Object) : void
      {
         if(data)
         {
            if(data.hasOwnProperty("tileSlotNumber"))
            {
               this.m_slotNumber = data["tileSlotNumber"];
            }
            if(this.m_slotNumber >= 0 && this.m_slotNumber <= 8)
            {
               this.m_tileName = PREFIX_EXPANSION + "rubbletreasure" + (this.m_slotNumber + 1).toString();
            }
            else
            {
               this.m_tileName = PREFIX_EXPANSION + "rubbletreasure" + SUFFIX_PAYER + (this.m_slotNumber - 8).toString();
            }
            this.m_tileWeight = this.manager.getTileWeight(this.m_tileName);
            if(!isTileLocked(this.m_tileName) || this.manager.isNonPayerTilePrereqMet(this.m_tileName))
            {
               this.m_tileState = STATE_UNLOCKED;
               this.m_currentElement_mc.gotoAndStop(3);
            }
            else
            {
               this.m_tileState = STATE_NORMAL;
               this.m_currentElement_mc.gotoAndStop(1);
            }
         }
      }
      
      private function onTileBuyButtonClick(e:Event) : void
      {
         StatsManager.count("AntiqueMuseumV2","dump_map","buy","click",this.m_tileName);
         UI.displayMiniMarketDialog([this.m_tileName],null,"seed",null,true,false,false,true);
         if(this.m_window)
         {
            this.m_window.close();
         }
         this.manager.closeMainWindow(e);
      }
      
      private function onPopupClose(e:Event) : void
      {
         if(this.m_buyPopup)
         {
            this.m_buyPopup.visible = false;
            this.m_currentElement_mc.gotoAndStop(1);
            this.m_tileState = STATE_NORMAL;
            this.manager.onTileUnselected(this.m_tileName);
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
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

