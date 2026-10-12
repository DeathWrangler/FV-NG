package Widgets.Frames.Lottery
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Lottery.LotteryTicketSlot;
   import flash.display.DisplayObject;
   
   public class LotteryTicketFrame extends FarmSlotContainerFrame
   {
      
      private var m_mypickSlotframe_mc:ZwBaseWidget;
      
      private var m_frameType:String;
      
      public function LotteryTicketFrame(element:DisplayObject, type:String)
      {
         this.m_frameType = type;
         super(element);
      }
      
      public function get choooseNumbersFrame() : ZwBaseWidget
      {
         return this.m_mypickSlotframe_mc;
      }
      
      public function get tickets() : Array
      {
         return m_slotData;
      }
      
      public function set tickets(tickets:Array) : void
      {
         m_slotData = tickets;
         refresh();
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LotteryTicketSlot(slotElement,this.m_frameType);
      }
   }
}

