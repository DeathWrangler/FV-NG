package Widgets.Frames
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Halloween2019InnovationExperimentRecipeSlot;
   import Widgets.Windows.Halloween2019InnovationCandyConversionWindow;
   import flash.display.DisplayObject;
   
   public class Halloween2019InnovationExperimentRecipeFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "try_recipe_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected static const EXPERIMENT_COUNT:int = 6;
      
      private var m_window:Halloween2019InnovationCandyConversionWindow;
      
      private var m_featureName:String;
      
      public function Halloween2019InnovationExperimentRecipeFrame(element:DisplayObject, window:Halloween2019InnovationCandyConversionWindow, featureName:String)
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
         return new Halloween2019InnovationExperimentRecipeSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var basicCandiesData:Object = manager.getBasicCandiesNameCount();
         var baseCoat:Array = manager.getBaseCoatCombination();
         var basicCandyNameURL:Object = manager.getBasicCandyNameURLS();
         for(var i:int = 0; i < EXPERIMENT_COUNT; i++)
         {
            m_slotData.push({
               "questOrderSlotNumber":i,
               "baseCandyName":baseCoat[i][0],
               "baseCandyURL":basicCandyNameURL[baseCoat[i][0]],
               "baseCandyCount":basicCandiesData[baseCoat[i][0]],
               "coatCandyName":baseCoat[i][1],
               "coatCandyURL":basicCandyNameURL[baseCoat[i][1]],
               "coatCandyCount":basicCandiesData[baseCoat[i][1]]
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

