package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.TargetedRewardsSlot;
   import flash.display.DisplayObject;
   
   public class TargetedRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:DisplayObject;
      
      private var m_isFirstDay:Boolean;
      
      public function TargetedRewardSlotContainerFrame(element:DisplayObject, owner:DisplayObject, isFirstDay:Boolean)
      {
         this.m_isFirstDay = isFirstDay;
         this.m_owner = owner;
         super(element);
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
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TargetedRewardsSlot(slotElement,this.m_owner,this.m_isFirstDay);
      }
   }
}

