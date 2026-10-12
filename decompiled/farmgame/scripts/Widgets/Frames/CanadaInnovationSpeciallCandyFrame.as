package Widgets.Frames
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CanadaInnovationSpecialCandySlot;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CanadaInnovationSpeciallCandyFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "candy_special";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CanadaInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function CanadaInnovationSpeciallCandyFrame(element:DisplayObject, window:CanadaInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      private static function get manager() : CanadaInnovationManager
      {
         return CanadaInnovationManager.getInstance();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CanadaInnovationSpecialCandySlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "candy_special_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         var baseCandies:Array = null;
         m_slotData = [];
         var specialCandyNameURL:Object = manager.getSpecialCandyNameURLS();
         var specialCandyNames:Array = manager.getSpecialCandiesNames();
         var stationsData:Array = manager.getStaionsData();
         for(var i:int = 0; i < 3; i++)
         {
            baseCandies = manager.getBaseCoatCandyBySpecialCandyName(specialCandyNames[i]);
            m_slotData.push({
               "questOrderSlotNumber":i,
               "candyIcon":specialCandyNameURL[specialCandyNames[i]],
               "candyCount":manager.getSpecialCandyCountByName(specialCandyNames[i]),
               "candyName":specialCandyNames[i],
               "baseCandyName":baseCandies[0],
               "baseCandyUrl":manager.getBasicCandyURLByName(baseCandies[0]),
               "coatCandyName":baseCandies[1],
               "coatCandyUrl":manager.getBasicCandyURLByName(baseCandies[1]),
               "stationId":i,
               "stationTimer":stationsData[i][1],
               "stationBusy":stationsData[i][2]
            });
         }
      }
      
      public function refreshSlot(slotNumber:int) : void
      {
         var baseCandies:Array = null;
         this.stopCandyTimer(slotNumber);
         var specialCandyNameURL:Object = manager.getSpecialCandyNameURLS();
         var specialCandyNames:Array = manager.getSpecialCandiesNames();
         var stationsData:Array = manager.getStaionsData();
         baseCandies = manager.getBaseCoatCandyBySpecialCandyName(specialCandyNames[slotNumber]);
         m_slotData[slotNumber] = {
            "questOrderSlotNumber":slotNumber,
            "candyIcon":specialCandyNameURL[specialCandyNames[slotNumber]],
            "candyCount":manager.getSpecialCandyCountByName(specialCandyNames[slotNumber]),
            "candyName":specialCandyNames[slotNumber],
            "baseCandyName":baseCandies[0],
            "baseCandyUrl":manager.getBasicCandyURLByName(baseCandies[0]),
            "coatCandyName":baseCandies[1],
            "coatCandyUrl":manager.getBasicCandyURLByName(baseCandies[1]),
            "stationId":slotNumber,
            "stationTimer":stationsData[slotNumber][1],
            "stationBusy":stationsData[slotNumber][2]
         };
         (m_slots[slotNumber] as CanadaInnovationSpecialCandySlot).populate(m_slotData[slotNumber]);
      }
      
      override public function refresh() : void
      {
         this.stopAllCandiesTimer();
         this.setupData();
         super.refresh();
      }
      
      public function stopAllCandiesTimer() : void
      {
         for(var slotNumber:int = 0; slotNumber < 3; slotNumber++)
         {
            (m_slots[slotNumber] as CanadaInnovationSpecialCandySlot).stopCollectTimer();
         }
      }
      
      public function stopCandyTimer(slotNumber:int) : void
      {
         (m_slots[slotNumber] as CanadaInnovationSpecialCandySlot).stopCollectTimer();
      }
   }
}

