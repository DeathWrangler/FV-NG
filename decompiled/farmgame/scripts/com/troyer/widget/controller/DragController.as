package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   
   public class DragController extends BaseWidgetController
   {
      
      public function DragController(param1:BaseWidgetView)
      {
         super(param1);
         addGlobalListener(WidgetControllerEvent.BEGIN_DRAG_DIALOG);
         addGlobalListener(WidgetControllerEvent.END_DRAG_DIALOG);
      }
      
      override public function initialize() : void
      {
         super.initialize();
         addViewListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addViewListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BEGIN_DRAG_DIALOG,this));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.BEGIN_DRAG_DIALOG,this));
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.END_DRAG_DIALOG,this));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.END_DRAG_DIALOG,this));
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.END_DRAG_DIALOG,this));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.END_DRAG_DIALOG,this));
      }
   }
}

