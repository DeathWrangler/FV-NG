package Widgets.Tooltips
{
   import Widgets.Core.Base.ZwWidget;
   import flash.events.MouseEvent;
   
   public class StaticWidgetTooltip extends WidgetTooltip
   {
      
      public function StaticWidgetTooltip(widget:ZwWidget = null, toggleCallback:Function = null)
      {
         super(widget,toggleCallback);
      }
      
      override protected function updatePosition(event:MouseEvent) : void
      {
      }
   }
}

