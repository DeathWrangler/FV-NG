package Widgets.Frames.LESet
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.LESet.LEBundleSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class LEBundleSlotFrame extends LESlotFrame
   {
      
      public function LEBundleSlotFrame(element:DisplayObject, leSet:Array, parentWindow:FarmWindow)
      {
         super(element,leSet,parentWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LEBundleSlot(slotElement,m_parentWindow);
      }
      
      override protected function allowPaging() : Boolean
      {
         return false;
      }
   }
}

