package Widgets.Frames.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingRewardSlot;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_system:FeatureCraftingSystem;
      
      public function FeatureCraftingRewardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingRewardSlot(slotElement);
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function set system(value:FeatureCraftingSystem) : void
      {
         this.m_system = value;
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

