package Widgets.Frames
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CanadaInnovationStationSlot;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CanadaInnovationStationsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "special_candy_station_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected static const STATIONS_COUNT:int = 3;
      
      private var m_window:CanadaInnovationMainWindow;
      
      private var m_featureName:String = "CocowonderlandInnovation";
      
      public function CanadaInnovationStationsFrame(element:DisplayObject, parentWindow:CanadaInnovationMainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CanadaInnovationStationSlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var stationsData:Array = this.manager.getStaionsData();
         for(var i:int = 0; i < STATIONS_COUNT; i++)
         {
            m_slotData.push({
               "stationId":i,
               "specialCandyName":stationsData[i][0],
               "specialCandyUrl":this.manager.getSpecialCandyURLByName(stationsData[i][0]),
               "stationTimer":stationsData[i][1],
               "stationBusy":stationsData[i][2],
               "base":stationsData[i][3],
               "coat":stationsData[i][4]
            });
         }
      }
      
      private function get manager() : CanadaInnovationManager
      {
         return CanadaInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

