package Widgets.Frames.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingStationSlot;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingStationSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_location:String = "";
      
      public function FeatureCraftingStationSlotContainerFrame(element:DisplayObject, location:String = "")
      {
         this.m_location = location;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingStationSlot(slotElement,this.m_location);
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
      
      public function getSlotIdByStation(selectedStation:FeatureCraftingStation) : FeatureCraftingStationSlot
      {
         var slot:FeatureCraftingStationSlot = null;
         var result:FeatureCraftingStationSlot = null;
         for each(slot in m_slots)
         {
            if(Boolean(slot) && slot.data == selectedStation)
            {
               result = slot;
               break;
            }
         }
         return result;
      }
      
      public function hideAllTooltips() : void
      {
         var slot:FeatureCraftingStationSlot = null;
         for each(slot in m_slots)
         {
            slot.toggleTooltip(false);
         }
      }
   }
}

