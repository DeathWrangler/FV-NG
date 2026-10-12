package Widgets.Frames
{
   import Managers.JMInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.JMInnovationRecipeStationSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class JMInnovationRecipeStationSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_window:FarmWindow;
      
      protected var m_featureName:String;
      
      public function JMInnovationRecipeStationSlotFrame(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new JMInnovationRecipeStationSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var recipe1:Object = null;
         var recipe:Object = null;
         m_slotData = new Array();
         var recipeList:Array = JMInnovationManager.getInstance().recipeList;
         var count:* = 0;
         for each(recipe1 in recipeList)
         {
            recipe = new Object();
            recipe.code = recipe1.toString();
            recipe.slotIndex = count++;
            m_slotData.push(recipe);
         }
      }
   }
}

