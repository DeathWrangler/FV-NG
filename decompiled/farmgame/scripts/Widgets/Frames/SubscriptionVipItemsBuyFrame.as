package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.SubscriptionVipItemsBuySlot;
   import flash.display.DisplayObject;
   
   public class SubscriptionVipItemsBuyFrame extends FarmSlotContainerFrame
   {
      
      public function SubscriptionVipItemsBuyFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SubscriptionVipItemsBuySlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

