package Widgets.Frames.Storage
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Storage.DecoratorModeStorageSlot;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   
   public class DecoratorModeStorageSlotFrame extends StorageSlotFrame
   {
      
      public function DecoratorModeStorageSlotFrame(element:DisplayObject, items:Array, storageWindow:StorageWindow)
      {
         super(element,items,storageWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DecoratorModeStorageSlot(slotElement,m_storageWindow);
      }
   }
}

