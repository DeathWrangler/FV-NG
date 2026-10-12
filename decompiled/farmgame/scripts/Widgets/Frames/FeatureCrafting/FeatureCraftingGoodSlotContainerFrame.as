package Widgets.Frames.FeatureCrafting
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingGoodSlot;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingGoodSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function FeatureCraftingGoodSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingGoodSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

