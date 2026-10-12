package Widgets.Frames
{
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.HalloweenUSAInnovationRewardsSlot;
   import flash.display.DisplayObject;
   
   public class HalloweenUSAInnovationRewardsFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function HalloweenUSAInnovationRewardsFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function setupData() : void
      {
         m_slotData = HalloweenInnovationManager.getInstance().getRewardsOfTier(0);
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new HalloweenUSAInnovationRewardsSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
   }
}

