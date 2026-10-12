package Widgets.Frames
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CocowonderlandInnovationStationSlot;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CocowonderlandInnovationStationsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "station";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private var m_featureName:String = "CocowonderlandInnovation";
      
      private var m_highlightedSlot:int = -1;
      
      public function CocowonderlandInnovationStationsFrame(element:DisplayObject, parentWindow:CocowonderlandInnovationMainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CocowonderlandInnovationStationSlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var j:int = 0;
         var highlight:Boolean = false;
         var highlighted:Boolean = false;
         var i:int = 0;
         if(m_slots.length > 0)
         {
            for(j = 0; j < m_slots.length; j++)
            {
               (m_slots[j] as CocowonderlandInnovationStationSlot).removeTimer();
            }
         }
         m_slotData = [];
         this.m_highlightedSlot = -1;
         var stationsData:Array = CocowonderlandInnovationManager.getInstance(this.m_featureName).getStationsInfo();
         if(stationsData != null)
         {
            highlight = false;
            highlighted = false;
            for(i = 0; i < stationsData.length; i++)
            {
               if(Boolean(stationsData[i].hasOwnProperty("state") && stationsData[i]["state"] == CocowonderlandInnovationManager.STATION_STATES[CocowonderlandInnovationManager.STATION_STATE_UNLOCKED] && stationsData[i].hasOwnProperty("cookTimeStart")) && Boolean(stationsData[i]["cookTimeStart"] == 0) && !highlighted)
               {
                  highlight = true;
                  highlighted = true;
                  this.m_highlightedSlot = i;
               }
               else
               {
                  highlight = false;
               }
               m_slotData.push({
                  "questStationSlotNumber":i,
                  "StationData":stationsData[i],
                  "highlight":highlight.toString()
               });
            }
         }
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.m_featureName);
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
         if(this.m_window.isFirstTimeTutorial())
         {
            this.hideStations(true);
         }
      }
      
      public function checkAndAddIngredientToSlot(ingredient:XML) : Boolean
      {
         var result:Boolean = false;
         if(this.m_highlightedSlot >= 0)
         {
            result = (m_slots[this.m_highlightedSlot] as CocowonderlandInnovationStationSlot).checkAndAddIngredient(ingredient);
         }
         return result;
      }
      
      public function refreshSlot(slotNumber:int) : void
      {
         var stationsData:Array = CocowonderlandInnovationManager.getInstance(this.m_featureName).getStationsInfo();
         if(this.isStationAvailable())
         {
            m_slotData[slotNumber] = {
               "questStationSlotNumber":slotNumber,
               "StationData":stationsData[slotNumber]
            };
         }
         else
         {
            this.m_highlightedSlot = slotNumber;
            m_slotData[slotNumber] = {
               "questStationSlotNumber":slotNumber,
               "StationData":stationsData[slotNumber],
               "highlight":true.toString()
            };
         }
         (m_slots[slotNumber] as CocowonderlandInnovationStationSlot).populate(m_slotData[slotNumber]);
      }
      
      public function isStationAvailable() : Boolean
      {
         return this.m_highlightedSlot >= 0;
      }
      
      public function onStartCooking(slotNumber:int, cookedOrder:String, cookTimeStart:int) : void
      {
         (m_slots[slotNumber] as CocowonderlandInnovationStationSlot).onStartCooking(cookedOrder,cookTimeStart);
         this.refresh();
      }
      
      public function hideStations(hide:Boolean) : void
      {
         for(var j:int = 0; j < m_slots.length; j++)
         {
            (m_slots[j] as CocowonderlandInnovationStationSlot).hideStation(hide);
         }
      }
   }
}

