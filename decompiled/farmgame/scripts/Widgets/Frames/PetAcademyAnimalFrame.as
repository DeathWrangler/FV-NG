package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.PetAcademyAnimalSlot;
   import Widgets.Windows.PetAcademyMainWindow;
   import flash.display.DisplayObject;
   
   public class PetAcademyAnimalFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:PetAcademyMainWindow;
      
      public function PetAcademyAnimalFrame(element:DisplayObject, owner:PetAcademyMainWindow)
      {
         this.m_owner = owner;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PetAcademyAnimalSlot(slotElement,this.m_owner);
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

