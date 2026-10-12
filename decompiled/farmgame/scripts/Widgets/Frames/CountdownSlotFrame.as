package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CountdownSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class CountdownSlotFrame extends GenericTimedSlotFrame
   {
      
      public function CountdownSlotFrame(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,CountdownSlot,new Array(),parentWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CountdownSlot(slotElement,m_parentWindow);
      }
   }
}

