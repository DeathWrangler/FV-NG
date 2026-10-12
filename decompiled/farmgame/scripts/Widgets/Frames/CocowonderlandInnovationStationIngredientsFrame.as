package Widgets.Frames
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CocowonderlandInnovationStationIngredientSlot;
   import Widgets.Slots.CocowonderlandInnovationStationSlot;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CocowonderlandInnovationStationIngredientsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "order_ing_item";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private var m_featureName:String = "CocowonderlandInnovation";
      
      private var m_stationSlot:CocowonderlandInnovationStationSlot;
      
      private var m_ingredients:Array;
      
      public function CocowonderlandInnovationStationIngredientsFrame(element:DisplayObject, parentWindow:CocowonderlandInnovationMainWindow, featureName:String = "", stationSlot:CocowonderlandInnovationStationSlot = null)
      {
         this.m_stationSlot = stationSlot;
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CocowonderlandInnovationStationIngredientSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         var i:int = 0;
         m_slotData = [];
         if(this.m_ingredients)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               if(this.m_ingredients.length > i)
               {
                  m_slotData.push({
                     "questIngredientSlotNumber":i,
                     "ingredient":this.m_ingredients[i]
                  });
               }
               else
               {
                  m_slotData.push({"questIngredientSlotNumber":i});
               }
            }
         }
      }
      
      public function setData(ingredients:Array) : void
      {
         this.m_ingredients = ingredients;
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
      }
      
      public function checkAndAddIngredient(ingredient:XML) : Boolean
      {
         var result:Boolean = false;
         if(m_slots.length > this.m_ingredients.length)
         {
            this.m_ingredients.push(ingredient);
            result = true;
            this.refresh();
         }
         return result;
      }
      
      public function isCookingStarted() : Boolean
      {
         if(this.m_stationSlot)
         {
            return this.m_stationSlot.isCookingStarted();
         }
         return false;
      }
      
      public function getIngredients() : Array
      {
         return this.m_ingredients;
      }
      
      public function onStartCooking() : void
      {
         for(var i:int = 0; i < m_slots.length; i++)
         {
            (m_slots[i] as CocowonderlandInnovationStationIngredientSlot).onStartCooking();
         }
      }
      
      public function removeIngredient(ingredient:XML) : void
      {
         var index:int = this.m_ingredients.indexOf(ingredient);
         if(index != -1)
         {
            this.m_ingredients.splice(index,1);
         }
         this.refresh();
         this.m_stationSlot.onRemoveIngredient(this.m_ingredients.length);
         this.manager.updateIngredientSlot(ingredient);
      }
   }
}

