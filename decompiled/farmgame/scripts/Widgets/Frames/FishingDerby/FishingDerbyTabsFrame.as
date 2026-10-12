package Widgets.Frames.FishingDerby
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FishingDerby.FishingDerbyTabsSlot;
   import Widgets.Windows.FishingDerby.FishingDerbyCollectionWindow;
   import flash.display.DisplayObject;
   
   public class FishingDerbyTabsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "generic";
      
      protected static const SLOT_POSTFIX:String = "_bt";
      
      private var m_parentWindow:FishingDerbyCollectionWindow;
      
      public function FishingDerbyTabsFrame(element:DisplayObject, parentWindow:FishingDerbyCollectionWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FishingDerbyTabsSlot(slotElement,this.m_parentWindow);
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
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
   }
}

