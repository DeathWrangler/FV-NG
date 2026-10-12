package Widgets.Frames
{
   import Managers.FarmRunQuestManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRun2018QuestionarreSlot;
   import Widgets.Windows.FarmRun2018QuestionarreWindow;
   import flash.display.DisplayObject;
   
   public class FarmRun2018QuestionarreFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:FarmRun2018QuestionarreWindow;
      
      private var m_featureName:String = "FarmRunV10_2020";
      
      private var m_questionData:Array;
      
      public var start_count:int = 0;
      
      public function FarmRun2018QuestionarreFrame(element:DisplayObject, parentWindow:FarmRun2018QuestionarreWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         var items:Array = FarmRunQuestManager.getInstance().getRewardsItemsArray();
         this.m_questionData = this.manager.getQuestionData();
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRun2018QuestionarreSlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var optionText:String = null;
         this.start_count = this.manager.getQuestionCount(this.m_featureName) as int;
         m_slotData = [];
         for(var i:int = 0; i < 3; i++)
         {
            optionText = this.m_questionData[this.start_count].options[i];
            m_slotData.push({
               "slotNumber":i,
               "option":optionText
            });
         }
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(this.m_featureName);
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

