package Widgets.Frames
{
   import Managers.JMInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.JMInnovationCraftConsumableSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class JMInnovationCraftConsumableSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_window:FarmWindow;
      
      protected var m_featureName:String;
      
      public function JMInnovationCraftConsumableSlotFrame(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new JMInnovationCraftConsumableSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var consumableCode:Object = null;
         var itemObject:Object = null;
         m_slotData = new Array();
         var consumableList:Array = JMInnovationManager.getInstance().ConsumableList;
         var slotIndex:int = 0;
         for each(consumableCode in consumableList)
         {
            itemObject = new Object();
            itemObject.code = consumableCode;
            itemObject.slotIndex = slotIndex;
            slotIndex++;
            m_slotData.push(itemObject);
         }
      }
   }
}

