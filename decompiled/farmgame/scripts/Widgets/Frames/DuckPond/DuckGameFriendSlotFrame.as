package Widgets.Frames.DuckPond
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.DuckPond.DuckGameFriendSlot;
   import Widgets.Windows.DuckPond.DuckGameWindow;
   import flash.display.DisplayObject;
   
   public class DuckGameFriendSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_duckGameWindow:DuckGameWindow;
      
      public function DuckGameFriendSlotFrame(element:DisplayObject, items:Array, duckGameWindow:DuckGameWindow)
      {
         this.m_items = items;
         this.m_duckGameWindow = duckGameWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DuckGameFriendSlot(slotElement,this.m_duckGameWindow);
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

