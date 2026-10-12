package Widgets.Frames
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.LightningDealsBundleSlot;
   import flash.display.DisplayObject;
   
   public class LightningDealsBundleFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function LightningDealsBundleFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         var x:ZwFrame = m_element as ZwFrame;
         if(x)
         {
            x.removeAllWidgets();
         }
      }
      
      override protected function setupData() : void
      {
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         if(!slotData)
         {
            m_slotData = null;
            clearSlots();
         }
         else
         {
            m_slotData = slotData;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LightningDealsBundleSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
   }
}

