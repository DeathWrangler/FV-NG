package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.WanderingPirateKeyBoxSlot;
   import flash.display.DisplayObject;
   
   public class WanderingPirateKeyBoxSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:DisplayObject;
      
      public function WanderingPirateKeyBoxSlotContainerFrame(element:DisplayObject, owner:DisplayObject)
      {
         this.m_owner = owner;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WanderingPirateKeyBoxSlot(slotElement,this.m_owner);
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

