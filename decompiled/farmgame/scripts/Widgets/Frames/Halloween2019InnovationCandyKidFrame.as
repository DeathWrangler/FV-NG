package Widgets.Frames
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Halloween2019InnovationCandyKidSlot;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class Halloween2019InnovationCandyKidFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "candy_kid_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:Halloween2019InnovationMainWindow;
      
      private var m_featureName:String;
      
      public function Halloween2019InnovationCandyKidFrame(element:DisplayObject, window:Halloween2019InnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      private static function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new Halloween2019InnovationCandyKidSlot(this.m_featureName,slotElement,this.m_window);
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
               "kidIcon":"assets/newsfeed/kid_" + kidChar + "_happy_icon.png",
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
            "kidIcon":"assets/newsfeed/kid_" + kidChar + "_happy_icon.png",
            "candyDetails":kidsDetails[kidsNameList[slotNumber]],
            "kidName":kidsNameList[slotNumber]
         };
         (m_slots[slotNumber] as Halloween2019InnovationCandyKidSlot).populate(m_slotData[slotNumber]);
      }
      
      public function stopAllKidsTimer() : void
      {
         for(var slotNumber:int = 0; slotNumber < 3; slotNumber++)
         {
            (m_slots[slotNumber] as Halloween2019InnovationCandyKidSlot).stopKidReturnTimer();
            (m_slots[slotNumber] as Halloween2019InnovationCandyKidSlot).stopKidWaitTimer();
         }
      }
      
      public function stopKidTimer(slotNumber:int) : void
      {
         (m_slots[slotNumber] as Halloween2019InnovationCandyKidSlot).stopKidReturnTimer();
         (m_slots[slotNumber] as Halloween2019InnovationCandyKidSlot).stopKidWaitTimer();
      }
   }
}

