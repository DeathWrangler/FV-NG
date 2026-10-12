package Widgets.Frames.LonelyAnimal
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LonelyAnimal.LonelyAnimalFriendSlot;
   import Widgets.Windows.LonelyAnimal.LonelyAnimalWindow;
   import flash.display.DisplayObject;
   
   public class LonelyAnimalFriendSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_lonelyAnimalWindow:LonelyAnimalWindow;
      
      public function LonelyAnimalFriendSlotFrame(element:DisplayObject, items:Array, lonelyAnimalWindow:LonelyAnimalWindow)
      {
         this.m_items = items;
         this.m_lonelyAnimalWindow = lonelyAnimalWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LonelyAnimalFriendSlot(slotElement,this.m_lonelyAnimalWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

