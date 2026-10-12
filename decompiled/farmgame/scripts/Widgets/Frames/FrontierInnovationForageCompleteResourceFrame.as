package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FrontierInnovationForageCompleteResourceSlot;
   import Widgets.Windows.FrontierInnovationWindow;
   import flash.display.DisplayObject;
   
   public class FrontierInnovationForageCompleteResourceFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var NUMBER_RESOURCES:int = 3;
      
      private var m_areaId:int;
      
      private var m_window:FrontierInnovationWindow;
      
      private var manager:FrontierInnovationManager;
      
      public function FrontierInnovationForageCompleteResourceFrame(element:DisplayObject, featureName:String, window:FrontierInnovationWindow, areaId:int)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         this.m_areaId = areaId;
         super(element);
         this.m_frameName = m_element.name;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationForageCompleteResourceSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "resource";
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var areaData:Array = this.manager.getForageData() as Array;
         for(var i:int = 0; i < this.NUMBER_RESOURCES; i++)
         {
            m_slotData.push({
               "count":1,
               "itemCode":areaData[this.m_areaId][0][i]
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

