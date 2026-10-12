package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.PostVotingSlot;
   import Widgets.Slots.WeekendDelightSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class WeekendDelightFrame extends GenericTimedSlotFrame
   {
      
      public function WeekendDelightFrame(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,PostVotingSlot,new Array(),parentWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WeekendDelightSlot(slotElement,m_parentWindow);
      }
   }
}

