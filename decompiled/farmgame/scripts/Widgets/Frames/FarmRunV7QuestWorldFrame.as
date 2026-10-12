package Widgets.Frames
{
   import Managers.OrderBoard.FarmRunV7Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRunV7QuestWorldSlot;
   import Widgets.Windows.FarmRunV7Window;
   import flash.display.DisplayObject;
   
   public class FarmRunV7QuestWorldFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:FarmRunV7Window;
      
      private var m_featureName:String = "FarmRunV7";
      
      public function FarmRunV7QuestWorldFrame(element:DisplayObject, parentWindow:FarmRunV7Window, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunV7QuestWorldSlot(slotElement,this.m_window);
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
      
      private function get manager() : FarmRunV7Manager
      {
         return FarmRunV7Manager.getInstance(this.m_featureName);
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

