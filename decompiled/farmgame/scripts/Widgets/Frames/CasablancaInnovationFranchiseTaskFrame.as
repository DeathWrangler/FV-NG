package Widgets.Frames
{
   import Managers.OrderBoard.CasablancaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CasablancaInnovationFranchiseTaskSlot;
   import Widgets.Windows.CasablancaInnovationFranchiseWindow;
   import flash.display.DisplayObject;
   
   public class CasablancaInnovationFranchiseTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:CasablancaInnovationFranchiseWindow;
      
      private var m_featureName:String;
      
      public function CasablancaInnovationFranchiseTaskFrame(element:DisplayObject, window:CasablancaInnovationFranchiseWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CasablancaInnovationFranchiseTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      private function get manager() : CasablancaInnovationManager
      {
         return CasablancaInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         var tileUnlockCount:Number = this.manager.getTileUnlockCount();
         for(var i:int = 0; i < 8; i++)
         {
            m_slotData.push({
               "rewardSlotNumber":i + 1,
               "tileUnlockCount":tileUnlockCount
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

