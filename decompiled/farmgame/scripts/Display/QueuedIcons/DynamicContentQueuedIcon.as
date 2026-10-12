package Display.QueuedIcons
{
   import Display.QueuedIcon;
   import Widgets.Core.Managers.ZwWidgetManager;
   import flash.events.Event;
   
   public class DynamicContentQueuedIcon extends QueuedIcon
   {
      
      protected var m_widgetManager:ZwWidgetManager;
      
      public function DynamicContentQueuedIcon(xml:XML)
      {
         super(xml);
         this.m_widgetManager = new ZwWidgetManager();
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         super.onButtonIconLoaded(event);
         this.injectContent();
      }
      
      protected function injectContent() : void
      {
      }
   }
}

