package Widgets.Frames
{
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRunV5QuestWorldSlot;
   import Widgets.Windows.FarmRunV5MainWindow;
   import flash.display.DisplayObject;
   
   public class FarmRunV5QuestWorldFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:FarmRunV5MainWindow;
      
      private var m_featureName:String = "FarmRunV5";
      
      public function FarmRunV5QuestWorldFrame(element:DisplayObject, parentWindow:FarmRunV5MainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunV5QuestWorldSlot(slotElement,this.m_window,this.m_featureName);
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
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
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

