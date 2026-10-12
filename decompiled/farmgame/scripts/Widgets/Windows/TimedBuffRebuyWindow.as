package Widgets.Windows
{
   import Widgets.Frames.TimedBuffRebuySlotFrame;
   
   public class TimedBuffRebuyWindow extends ToasterWindow
   {
      
      private static const TOASTER_OFFSET:int = 13;
      
      private const TIMED_REBUY_WINDOW_ASSET:String = "assets/dialogs/FV_HUDSurfacing_timeconsumable.swf";
      
      public function TimedBuffRebuyWindow()
      {
         super(this.TIMED_REBUY_WINDOW_ASSET);
         this.name = "TimedBuffRebuyWindow";
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("slotFrame_mc"))
         {
            addWidget(new TimedBuffRebuySlotFrame(m_window.slotFrame_mc,this));
         }
      }
   }
}

