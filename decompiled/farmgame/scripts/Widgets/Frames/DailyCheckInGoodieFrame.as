package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.DailyCheckInGoodieSlot;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.display.DisplayObject;
   
   public class DailyCheckInGoodieFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:DailyCheckInWindow;
      
      private var m_goodieUrl:String;
      
      public function DailyCheckInGoodieFrame(element:DisplayObject, goodieUrl:String, window:DailyCheckInWindow)
      {
         this.m_window = window;
         this.m_goodieUrl = goodieUrl;
         super(element);
         slots;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DailyCheckInGoodieSlot(slotElement,this.m_goodieUrl,this.m_window);
      }
      
      override protected function setupData() : void
      {
         for(var i:int = 1; i <= 7; i++)
         {
            m_slotData.push({"dayNo":i});
         }
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         this.m_window = null;
         for each(slot in slots)
         {
            slot.release();
         }
         super.release();
      }
   }
}

