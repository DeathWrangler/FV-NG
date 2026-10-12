package Widgets.Frames
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Halloween2019InnovationStationSlot;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class Halloween2019InnovationStationsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "special_candy_station_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected static const STATIONS_COUNT:int = 3;
      
      private var m_window:Halloween2019InnovationMainWindow;
      
      private var m_featureName:String = "CocowonderlandInnovation";
      
      public function Halloween2019InnovationStationsFrame(element:DisplayObject, parentWindow:Halloween2019InnovationMainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new Halloween2019InnovationStationSlot(slotElement,this.m_window);
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
      
      private function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance(this.m_featureName);
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

