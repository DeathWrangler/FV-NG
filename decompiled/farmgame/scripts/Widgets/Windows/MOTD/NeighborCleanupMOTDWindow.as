package Widgets.Windows.MOTD
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class NeighborCleanupMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_counterMC:MovieClip;
      
      public function NeighborCleanupMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
         }
      }
   }
}

