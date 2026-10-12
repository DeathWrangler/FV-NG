package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.TravelOptionSmallSlot;
   import flash.display.DisplayObject;
   
   public class TravelDialogSmallFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      private var m_clickCallback:Function;
      
      public function TravelDialogSmallFrame(element:DisplayObject, callBack:Function)
      {
         this.m_clickCallback = callBack;
         super(element);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      override protected function setupData() : void
      {
      }
      
      public function set travelSlots(travelSlotData:Array) : void
      {
         m_slotData = travelSlotData;
         clearSlots();
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TravelOptionSmallSlot(slotElement,this.m_clickCallback);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

