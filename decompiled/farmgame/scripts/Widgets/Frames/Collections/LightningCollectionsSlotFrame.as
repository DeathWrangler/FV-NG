package Widgets.Frames.Collections
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Collections.LightningCollectionsSlot;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   
   public class LightningCollectionsSlotFrame extends CollectionsSlotFrame
   {
      
      public function LightningCollectionsSlotFrame(element:DisplayObject, collectionItems:Array, mainWindow:CollectionsWindow)
      {
         super(element,collectionItems,mainWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LightningCollectionsSlot(slotElement,this);
      }
   }
}

