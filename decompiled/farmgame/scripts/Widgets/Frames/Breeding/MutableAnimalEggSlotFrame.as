package Widgets.Frames.Breeding
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Breeding.MutableAnimalEggSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class MutableAnimalEggSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_parentWindow:FarmWindow;
      
      public function MutableAnimalEggSlotFrame(element:DisplayObject, items:Array, mutableAnimalEggWindow:FarmWindow)
      {
         this.m_items = items;
         this.m_parentWindow = mutableAnimalEggWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MutableAnimalEggSlot(slotElement);
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
      
      public function updateExtraHelpers(extraCount:int) : void
      {
      }
   }
}

