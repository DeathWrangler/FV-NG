package Widgets.Frames
{
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CanadaInnovationDiscoveredRecipeSlot;
   import Widgets.Windows.CanadaInnovationCandyConversionWindow;
   import flash.display.DisplayObject;
   
   public class CanadaInnovationDiscoveredRecipeFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "disc_recipe_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CanadaInnovationCandyConversionWindow;
      
      private var m_featureName:String;
      
      public function CanadaInnovationDiscoveredRecipeFrame(element:DisplayObject, window:CanadaInnovationCandyConversionWindow, featureName:String)
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
         return new CanadaInnovationDiscoveredRecipeSlot(this.m_featureName,slotElement,this.m_window);
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
         var specialCandy:String = null;
         var specialCandyUrl:String = null;
         m_slotData = [];
         var basicCoatMapping:Array = manager.getBasicCoatCandiesFromSpecialCandyMapping();
         for(var index:int = 0; index < basicCoatMapping.length; index++)
         {
            specialCandy = manager.getSpecialCandyByBaseCoat(basicCoatMapping[index][0],basicCoatMapping[index][1]);
            specialCandyUrl = manager.getSpecialCandyURLByName(specialCandy);
            m_slotData.push({
               "questOrderSlotNumber":index,
               "baseCandy":basicCoatMapping[index][0],
               "baseCandyUrl":manager.getBasicCandyURLByName(basicCoatMapping[index][0]),
               "coatCandy":basicCoatMapping[index][1],
               "coatCandyUrl":manager.getBasicCandyURLByName(basicCoatMapping[index][1]),
               "specialCandy":specialCandy,
               "specialCandyUrl":specialCandyUrl,
               "makeBTVisibility":manager.canMakeSpecialCandy(specialCandy),
               "specialCandyIconVisibility":manager.isSpecialCandyVisited(specialCandy)
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

