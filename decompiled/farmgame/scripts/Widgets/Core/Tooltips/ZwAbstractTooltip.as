package Widgets.Core.Tooltips
{
   import Widgets.Core.Base.ZwObject;
   import Widgets.Core.Interfaces.IZwEventHandling;
   import flash.events.MouseEvent;
   
   public class ZwAbstractTooltip extends ZwObject
   {
      
      protected var m_eventWidget:IZwEventHandling = null;
      
      public function ZwAbstractTooltip()
      {
         super();
      }
      
      override public function release() : void
      {
         this.detach();
         super.release();
      }
      
      final public function attach(eventWidget:IZwEventHandling) : void
      {
         this.m_eventWidget = eventWidget;
         this.m_eventWidget.registerEventListener(MouseEvent.MOUSE_MOVE,this.updatePosition);
         this.m_eventWidget.registerEventListener(MouseEvent.ROLL_OVER,this.show);
         this.m_eventWidget.registerEventListener(MouseEvent.ROLL_OUT,this.hide);
      }
      
      final public function detach() : void
      {
         if(this.m_eventWidget)
         {
            this.m_eventWidget.unregisterEventListener(MouseEvent.MOUSE_MOVE,this.updatePosition);
            this.m_eventWidget.unregisterEventListener(MouseEvent.ROLL_OVER,this.show);
            this.m_eventWidget.unregisterEventListener(MouseEvent.ROLL_OUT,this.hide);
            this.m_eventWidget = null;
         }
      }
      
      protected function updatePosition(event:MouseEvent) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractTooltip:updatePosition.");
      }
      
      protected function show(event:MouseEvent) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractTooltip:show.");
      }
      
      protected function hide(event:MouseEvent) : void
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractTooltip:hide.");
      }
   }
}

