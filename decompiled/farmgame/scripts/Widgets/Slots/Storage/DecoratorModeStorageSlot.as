package Widgets.Slots.Storage
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.DecoratorModeManager;
   import Managers.FreezeManager;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DecoratorModeStorageSlot extends StorageSlot
   {
      
      public function DecoratorModeStorageSlot(element:DisplayObject, storageWindow:StorageWindow)
      {
         super(element,storageWindow);
      }
      
      override protected function onUseClick(event:MouseEvent) : void
      {
         super.onUseClick(event);
         StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"deco_action","remove_store");
      }
      
      override protected function shouldCloseOnUse() : Boolean
      {
         return false;
      }
      
      override protected function onSellClick(event:MouseEvent) : void
      {
         UI.suppressPopupQueue = false;
         super.onSellClick(event);
      }
      
      override protected function closeMultipleSellHandler(e:Event) : void
      {
         this.enableUIControl();
         super.closeMultipleSellHandler(e);
      }
      
      override protected function sellMultipleGiftsHandler(data:Object) : void
      {
         this.enableUIControl();
         super.sellMultipleGiftsHandler(data);
      }
      
      private function enableUIControl() : void
      {
         UI.suppressPopupQueue = true;
         if(FreezeManager.isRenderFrozen())
         {
            FreezeManager.thaw(true);
         }
      }
   }
}

