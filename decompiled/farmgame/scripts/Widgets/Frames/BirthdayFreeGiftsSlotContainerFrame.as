package Widgets.Frames
{
   import Classes.Constants.Experiments;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BirthdayFreeGiftsSlot;
   import flash.display.DisplayObject;
   
   public class BirthdayFreeGiftsSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:DisplayObject;
      
      public function BirthdayFreeGiftsSlotContainerFrame(element:DisplayObject, owner:DisplayObject)
      {
         this.m_owner = owner;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BirthdayFreeGiftsSlot(slotElement,this.m_owner);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BUGFIX_SLOT_CONTAINER_RELEASE) == 0)
         {
            for each(slot in m_slots)
            {
               slot.release();
            }
         }
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

