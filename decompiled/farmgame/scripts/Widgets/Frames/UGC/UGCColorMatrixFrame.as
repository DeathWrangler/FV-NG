package Widgets.Frames.UGC
{
   import Classes.EmbeddedArt;
   import Classes.UGC.UGCConstants;
   import Classes.util.ObjectUtil;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwAbstractToggleSlotContainerFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.UGC.UGCColorSlot;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   
   public class UGCColorMatrixFrame extends ZwAbstractToggleSlotContainerFrame
   {
      
      private static const SLOT_PREFIX:String = "color";
      
      private static const SLOT_POSTFIX:String = "_mc";
      
      private var m_selectedColor:uint;
      
      private var m_cursorId:Number;
      
      private var m_slotsListeners:Vector.<ZwSlotFrame> = new Vector.<ZwSlotFrame>();
      
      public function UGCColorMatrixFrame(element:DisplayObject)
      {
         super(element);
         m_toggleManager.allowDeselectOnClick = true;
         if(ObjectUtil.pathExists(element,"arrowcolorLeft_bt"))
         {
            m_pageBackWidget = new ZwButton(element["arrowcolorLeft_bt"],this.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(ObjectUtil.pathExists(element,"arrowcolorRight_bt"))
         {
            m_pageForwardWidget = new ZwButton(element["arrowcolorRight_bt"],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:UGCColorSlot = new UGCColorSlot(slotElement);
         slot.registerEventListener(MouseEvent.CLICK,this.onColorClick);
         this.m_slotsListeners.push(slot);
         return slot;
      }
      
      override protected function setupData() : void
      {
         m_slotData = UGCConstants.COLOR_DATA;
      }
      
      override public function refresh() : void
      {
         this.clearCursor();
         this.m_selectedColor = UGCConstants.COLOR_UNSET;
         super.refresh();
         m_toggleManager.deselectToggles();
      }
      
      private function onColorClick(event:MouseEvent) : void
      {
         var selectedColor:uint = 0;
         var slot:UGCColorSlot = getWidgetFromEvent(event) as UGCColorSlot;
         if(slot)
         {
            selectedColor = uint(slot.data.color);
            if(selectedColor === this.m_selectedColor)
            {
               this.clearCursor();
               this.m_selectedColor = UGCConstants.COLOR_UNSET;
            }
            else
            {
               this.m_selectedColor = selectedColor;
               this.enableCursor();
            }
            dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_SELECT_COLOR,slot.data));
         }
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         this.refresh();
         if(!enabled)
         {
            m_toggleManager.deselectToggles();
            this.clearCursor();
         }
      }
      
      override public function release() : void
      {
         while(this.m_slotsListeners.length > 0)
         {
            this.m_slotsListeners.shift().unregisterEventListener(MouseEvent.CLICK,this.onColorClick);
         }
         this.clearCursor();
         super.release();
      }
      
      private function enableCursor() : void
      {
         var cursorLoader:Loader = null;
         this.removeCurrentCursor();
         Global.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.hideSystemCursor);
         this.m_cursorId = UI.setCursor(EmbeddedArt.cursor_paint_brush,false,false);
         var cursor:Object = UI.getCursorInfo(this.m_cursorId);
         var cursorDisplay:MovieClip = cursor.displayObj as MovieClip;
         if(Boolean(cursorDisplay) && cursorDisplay.numChildren > 0)
         {
            cursorLoader = cursorDisplay.getChildAt(0) as Loader;
            if(Boolean(cursorLoader) && Boolean(cursorLoader.contentLoaderInfo))
            {
               cursorLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onCursorLoaded);
            }
         }
      }
      
      private function onCursorLoaded(event:Event) : void
      {
         var s:Shape = null;
         var g:Graphics = null;
         var target:LoaderInfo = event.target as LoaderInfo;
         target.removeEventListener(Event.COMPLETE,this.onCursorLoaded);
         var cursor:MovieClip = target.loader.content as MovieClip;
         if(ObjectUtil.pathExists(cursor,"cursor_mc","fill_mc"))
         {
            s = new Shape();
            g = s.graphics;
            g.beginFill(this.m_selectedColor,1);
            g.drawRect(-20,-20,40,40);
            g.endFill();
            cursor.cursor_mc.fill_mc.addChild(s);
         }
      }
      
      public function clearCursor() : void
      {
         Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.hideSystemCursor);
         this.removeCurrentCursor();
         Mouse.show();
      }
      
      private function removeCurrentCursor() : void
      {
         if(this.m_cursorId > 0)
         {
            UI.removeCursor(this.m_cursorId);
            this.m_cursorId = 0;
         }
      }
      
      private function hideSystemCursor(event:MouseEvent) : void
      {
         Mouse.hide();
      }
      
      protected function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      protected function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
   }
}

