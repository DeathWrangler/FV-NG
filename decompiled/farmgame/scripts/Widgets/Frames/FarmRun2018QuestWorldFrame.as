package Widgets.Frames
{
   import Managers.FarmRunQuestManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRun2018QuestWorldSlot;
   import Widgets.Windows.FarmRun2018MainWindow;
   import flash.display.DisplayObject;
   
   public class FarmRun2018QuestWorldFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:FarmRun2018MainWindow;
      
      private var m_featureName:String = "FarmRunV10_2020";
      
      public function FarmRun2018QuestWorldFrame(element:DisplayObject, parentWindow:FarmRun2018MainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         var items:Array = FarmRunQuestManager.getInstance().getRewardsItemsArray();
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRun2018QuestWorldSlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var worldArray:Array = this.manager.worldArray;
         for(var i:int = 0; i < worldArray.length; i++)
         {
            m_slotData.push({
               "world_code":worldArray[i],
               "index":i
            });
         }
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

