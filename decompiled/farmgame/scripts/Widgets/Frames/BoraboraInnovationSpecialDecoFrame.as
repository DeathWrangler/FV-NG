package Widgets.Frames
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BoraboraInnovationSpecialDecoSlot;
   import flash.display.DisplayObject;
   
   public class BoraboraInnovationSpecialDecoFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "deco_item_";
      
      protected static const SLOT_POSTFIX:String = "";
      
      private var m_featureName:String;
      
      private var m_slotIndex:int = -1;
      
      public function BoraboraInnovationSpecialDecoFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         ++this.m_slotIndex;
         return new BoraboraInnovationSpecialDecoSlot(slotElement,this.m_slotIndex);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         var numberOfSlots:int = 0;
         m_slotData = [];
         var basicPanelData:Array = this.manager.getExtraPanelData();
         if(this.manager.m_isEA)
         {
            numberOfSlots = 6;
         }
         else
         {
            numberOfSlots = 5;
         }
         for(var i:int = 0; i < numberOfSlots; i++)
         {
            m_slotData.push({
               "decoId":i,
               "decoItem":basicPanelData[i]["item"],
               "thumbs":basicPanelData[i]["thumbs"],
               "total":basicPanelData[i]["total"],
               "fc":basicPanelData[i]["fc"],
               "ea":basicPanelData[i]["ea"]
            });
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

