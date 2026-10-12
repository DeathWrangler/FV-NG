package Widgets.Frames.FishingDerby
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FishingDerby.TackleBoxSlot;
   import Widgets.Windows.FishingDerby.TackleBoxWindow;
   import flash.display.DisplayObject;
   
   public class TackleBoxFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:TackleBoxWindow;
      
      public function TackleBoxFrame(element:DisplayObject, parentWindow:TackleBoxWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TackleBoxSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

