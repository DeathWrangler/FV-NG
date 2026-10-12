package Widgets.Frames
{
   import Managers.JMInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.JMInnovationHarvestStationSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class JMInnovationHarvestStationSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_window:FarmWindow;
      
      protected var m_featureName:String;
      
      public function JMInnovationHarvestStationSlotFrame(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new JMInnovationHarvestStationSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var itemObject:Object = null;
         m_slotData = new Array();
         var buildingArray:Array = this.manager.buildingNameArray;
         var count:* = 1;
         for(var index:int = 1; index < buildingArray.length; index++)
         {
            itemObject = new Object();
            itemObject.name = buildingArray[index];
            itemObject.level = this.manager.getBuildingLevelByName(buildingArray[index]);
            itemObject.slotIndex = count++;
            m_slotData.push(itemObject);
         }
      }
      
      private function get manager() : JMInnovationManager
      {
         return JMInnovationManager.getInstance();
      }
   }
}

