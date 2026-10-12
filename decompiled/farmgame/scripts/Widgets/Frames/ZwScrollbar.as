package Widgets.Frames
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.*;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Interfaces.IFarmScrollBarInteractiveComponent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class ZwScrollbar extends ZwFrame
   {
      
      protected var m_backButton:ZwButton = null;
      
      protected var m_forwardButton:ZwButton = null;
      
      protected var m_back:ZwWidget = null;
      
      protected var m_handle:ZwWidget = null;
      
      protected var m_handleMinY:int = 0;
      
      protected var m_handleMaxY:int = 0;
      
      protected var m_HandleYRange:int = 0;
      
      protected var m_lastScrollY:int = 0;
      
      protected var m_handleBoundary:Rectangle = null;
      
      protected var m_interactiveHandle:IFarmScrollBarInteractiveComponent = null;
      
      public function ZwScrollbar(element:DisplayObject, interactiveHandle:IFarmScrollBarInteractiveComponent)
      {
         super(element);
         this.m_interactiveHandle = interactiveHandle;
         if(m_element.scrollBack_mc)
         {
            this.m_backButton = new ZwButton(m_element.scrollBack_mc,this.backClick);
            addWidget(this.m_backButton);
         }
         if(m_element.scrollForward_mc)
         {
            this.m_forwardButton = new ZwButton(m_element.scrollForward_mc,this.forwardClick);
            addWidget(this.m_forwardButton);
         }
         if(m_element.scrollBackground_mc)
         {
            this.m_back = new ZwWidget(m_element.scrollBackground_mc);
            addWidget(this.m_back);
         }
         if(m_element.scrollHandle_mc)
         {
            this.m_handle = new ZwWidget(m_element.scrollHandle_mc);
            addWidget(this.m_handle);
            this.m_handleMinY = this.m_backButton.y + this.m_backButton.height + 1;
            this.m_handleMaxY = this.m_forwardButton.y - this.m_handle.height - this.m_forwardButton.height;
            this.m_HandleYRange = this.m_handleMaxY - this.m_handleMinY;
            this.m_handle.y = this.m_handleMinY;
            this.m_lastScrollY = this.m_handleMinY;
            this.m_handleBoundary = new Rectangle(this.m_handle.x,this.m_handleMinY,0,this.m_HandleYRange);
            this.m_handle.registerEventListener(MouseEvent.MOUSE_DOWN,this.dragHandle);
         }
      }
      
      private function backClick(e:MouseEvent) : void
      {
         var percent:Number = this.m_interactiveHandle.scrollBackCallback();
         this.repositionHandle(percent);
      }
      
      private function forwardClick(e:MouseEvent) : void
      {
         var percent:Number = this.m_interactiveHandle.scrollForwardCallback();
         this.repositionHandle(percent);
      }
      
      private function dragHandle(e:MouseEvent) : void
      {
         m_element.scrollHandle_mc.startDrag(false,this.m_handleBoundary);
         Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.dropHandle);
         this.m_handle.registerEventListener(Event.ENTER_FRAME,this.scroll);
      }
      
      private function dropHandle(e:MouseEvent) : void
      {
         m_element.scrollHandle_mc.stopDrag();
         Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.dropHandle);
         this.m_handle.unregisterEventListener(Event.ENTER_FRAME,this.scroll);
         this.scroll();
      }
      
      private function scroll(e:Event = null) : void
      {
         var percent:Number = NaN;
         if(this.m_handle.y != this.m_lastScrollY)
         {
            percent = (this.m_handle.y - this.m_handleMinY) / this.m_HandleYRange;
            this.m_lastScrollY = this.m_handle.y;
            this.m_interactiveHandle.scrollCallback(percent);
         }
      }
      
      private function repositionHandle(percent:Number) : void
      {
         var offset:int = Math.floor(percent * this.m_HandleYRange);
         this.m_handle.y = this.m_handleMinY + offset;
      }
   }
}

