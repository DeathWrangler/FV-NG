package Widgets.Frames
{
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CarribeanInnovationFranchiseTaskSlot;
   import Widgets.Windows.CarribeanInnovationFranchiseWindow;
   import flash.display.DisplayObject;
   
   public class CarribeanInnovationFranchiseTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:CarribeanInnovationFranchiseWindow;
      
      private var m_featureName:String;
      
      public function CarribeanInnovationFranchiseTaskFrame(element:DisplayObject, window:CarribeanInnovationFranchiseWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CarribeanInnovationFranchiseTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(this.m_featureName);
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

