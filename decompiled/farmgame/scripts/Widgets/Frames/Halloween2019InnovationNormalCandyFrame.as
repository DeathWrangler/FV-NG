package Widgets.Frames
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Halloween2019InnovationNormalCandySlot;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class Halloween2019InnovationNormalCandyFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "candy_normal";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:Halloween2019InnovationMainWindow;
      
      private var m_featureName:String;
      
      public function Halloween2019InnovationNormalCandyFrame(element:DisplayObject, window:Halloween2019InnovationMainWindow, featureName:String)
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
         return new Halloween2019InnovationNormalCandySlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "candy_normal_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var basicCandyNameURL:Object = manager.getBasicCandyNameURLS();
         var basicCandyNames:Array = manager.getBasicCandiesNames();
         for(var i:int = 0; i < 3; i++)
         {
            m_slotData.push({
               "questOrderSlotNumber":i,
               "candyIcon":basicCandyNameURL[basicCandyNames[i]],
               "candyCount":manager.getBasicCandyCountByName(basicCandyNames[i]),
               "candyName":basicCandyNames[i]
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

