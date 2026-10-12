package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   
   public class CloseButtonController extends ButtonController
   {
      
      public function CloseButtonController(param1:BaseWidgetView)
      {
         super(param1);
         addGlobalListener(WidgetControllerEvent.CLOSE);
      }
      
      override protected function onMouseUp(param1:MouseEvent) : void
      {
         super.onMouseUp(param1);
         if(m_mouseDown)
         {
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.CLOSE,this));
            MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.CLOSE,this));
         }
      }
   }
}

