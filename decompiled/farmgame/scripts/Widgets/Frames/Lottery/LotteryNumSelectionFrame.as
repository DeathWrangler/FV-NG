package Widgets.Frames.Lottery
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Lottery.LotteryPickSlot;
   import flash.display.DisplayObject;
   
   public class LotteryNumSelectionFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "mypick_";
      
      private var m_parentWindow:DisplayObject;
      
      private var m_pickSlotFrame:ZwBaseWidget;
      
      private var m_clickCallback:Function;
      
      public function LotteryNumSelectionFrame(element:DisplayObject, clickCallback:Function)
      {
         this.m_clickCallback = clickCallback;
         super(element);
      }
      
      public function get choooseNumbersFrame() : ZwBaseWidget
      {
         return this.m_pickSlotFrame;
      }
      
      public function get lotteryNumbers() : Array
      {
         return m_slotData;
      }
      
      public function set lotteryNumbers(lotteryNumbers:Array) : void
      {
         m_slotData = lotteryNumbers;
         refresh();
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LotteryPickSlot(slotElement,this.m_clickCallback);
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         super.release();
      }
   }
}

