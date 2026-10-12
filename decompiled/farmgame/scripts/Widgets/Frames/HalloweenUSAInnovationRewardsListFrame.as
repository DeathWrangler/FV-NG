package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.HalloweenUSAInnovationRewardsListSlot;
   import flash.display.DisplayObject;
   
   public class HalloweenUSAInnovationRewardsListFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function HalloweenUSAInnovationRewardsListFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function setupData() : void
      {
         m_slotData.push({"code":"thr"},{"code":"0v5n"},{"code":"xvh"},{"code":"06f7"},{"code":"0qrx"},{"code":"0znw"});
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new HalloweenUSAInnovationRewardsListSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "reward";
      }
   }
}

