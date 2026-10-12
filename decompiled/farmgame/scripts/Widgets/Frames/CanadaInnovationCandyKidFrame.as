package Widgets.Frames
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CanadaInnovationCandyKidSlot;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CanadaInnovationCandyKidFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "candy_kid_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CanadaInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function CanadaInnovationCandyKidFrame(element:DisplayObject, window:CanadaInnovationMainWindow, featureName:String)
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
         return new CanadaInnovationCandyKidSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "candy_kid_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         var kidsNameList:Array = null;
         var kidsDetails:Object = null;
         var week:int = 0;
         var kidChar:String = null;
         kidsNameList = manager.getKidsName();
         kidsDetails = manager.getKidsDetailsByWeek();
         week = manager.getWeekNumber();
         m_slotData = [];
         for(var i:int = 0; i < 3; i++)
         {
            kidChar = manager.KID_CHAR_ARRAY[week * 3 + i];
            m_slotData.push({
               "questOrderSlotNumber":i,
               "kidIcon":"assets/newsfeed/xcd_" + kidChar + "_happy_icon.png",
               "candyDetails":kidsDetails[kidsNameList[i]],
               "kidName":kidsNameList[i]
            });
         }
      }
      
      override public function refresh() : void
      {
         this.stopAllKidsTimer();
         this.setupData();
         super.refresh();
      }
      
      public function refreshSlot(slotNumber:int) : void
      {
         this.stopKidTimer(slotNumber);
         var kidsNameList:Array = manager.getKidsName();
         var kidsDetails:Object = manager.getKidsDetailsByWeek();
         var week:int = manager.getWeekNumber();
         var kidChar:String = manager.KID_CHAR_ARRAY[week * 3 + slotNumber];
         m_slotData[slotNumber] = {
            "questOrderSlotNumber":slotNumber,
            "kidIcon":"assets/newsfeed/xcd_" + kidChar + "_happy_icon.png",
            "candyDetails":kidsDetails[kidsNameList[slotNumber]],
            "kidName":kidsNameList[slotNumber]
         };
         (m_slots[slotNumber] as CanadaInnovationCandyKidSlot).populate(m_slotData[slotNumber]);
      }
      
      public function stopAllKidsTimer() : void
      {
         for(var slotNumber:int = 0; slotNumber < 3; slotNumber++)
         {
            (m_slots[slotNumber] as CanadaInnovationCandyKidSlot).stopKidReturnTimer();
            (m_slots[slotNumber] as CanadaInnovationCandyKidSlot).stopKidWaitTimer();
         }
      }
      
      public function stopKidTimer(slotNumber:int) : void
      {
         (m_slots[slotNumber] as CanadaInnovationCandyKidSlot).stopKidReturnTimer();
         (m_slots[slotNumber] as CanadaInnovationCandyKidSlot).stopKidWaitTimer();
      }
   }
}

