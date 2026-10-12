package Widgets.Frames
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CanadaInnovationNormalCandySlot;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CanadaInnovationNormalCandyFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "candy_normal";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CanadaInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function CanadaInnovationNormalCandyFrame(element:DisplayObject, window:CanadaInnovationMainWindow, featureName:String)
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
         return new CanadaInnovationNormalCandySlot(this.m_featureName,slotElement,this.m_window);
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

