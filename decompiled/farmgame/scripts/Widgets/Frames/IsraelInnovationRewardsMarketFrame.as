package Widgets.Frames
{
   import Managers.IsraelInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.IsraelInnovationRewardsMarketSlot;
   import Widgets.Windows.IsraelInnovationRewardsMarketWindow;
   import flash.display.DisplayObject;
   
   public class IsraelInnovationRewardsMarketFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:IsraelInnovationRewardsMarketWindow;
      
      private var m_featureName:String;
      
      private const PREFIX:String = "buyCountSlot";
      
      public function IsraelInnovationRewardsMarketFrame(element:DisplayObject, window:IsraelInnovationRewardsMarketWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new IsraelInnovationRewardsMarketSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         var buyCountForSlot:int = 0;
         var marketRewardsData:Object = this.manager.getMarketRewardsData();
         for(var i:int = 0; i < 6; i++)
         {
            buyCountForSlot = this.manager.getBuyCountForSlot(i);
            m_slotData.push({
               "slotNumber":i,
               "buyCountForSlot":buyCountForSlot
            });
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

