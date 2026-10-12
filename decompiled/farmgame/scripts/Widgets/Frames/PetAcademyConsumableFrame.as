package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.PetAcademyConsumableSlot;
   import Widgets.Windows.PetAcademyExamWindow;
   import flash.display.DisplayObject;
   
   public class PetAcademyConsumableFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:PetAcademyExamWindow;
      
      public function PetAcademyConsumableFrame(element:DisplayObject, owner:PetAcademyExamWindow)
      {
         this.m_owner = owner;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PetAcademyConsumableSlot(slotElement,this.m_owner);
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
      
      override protected function getSlotPrefix() : String
      {
         return "consumable";
      }
   }
}

