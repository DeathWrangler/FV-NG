package Widgets.Frames
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CocowonderlandInnovationIngredientsSlot;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CocowonderlandInnovationIngredientsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "main_ing";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function CocowonderlandInnovationIngredientsFrame(element:DisplayObject, window:CocowonderlandInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      override protected function getSlotPrefix() : String
      {
         return CocowonderlandInnovationIngredientsFrame.SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return CocowonderlandInnovationIngredientsFrame.SLOT_POSTFIX;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CocowonderlandInnovationIngredientsSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var i:int = 0;
         for(var j:int = 0; j < m_slots.length; j++)
         {
            (m_slots[j] as CocowonderlandInnovationIngredientsSlot).removeAllToolTips();
         }
         m_slotData = [];
         var ingredientsList:Vector.<XML> = CocowonderlandInnovationManager.getInstance(this.m_featureName).getIngredients();
         if(ingredientsList)
         {
            for(i = 0; i < ingredientsList.length; i++)
            {
               m_slotData.push({
                  "questIngredientSlotNumber":i,
                  "ingredient":ingredientsList[i]
               });
            }
         }
      }
      
      public function disableBuyButtonForSlot(slotNumber:int, taskPoints:int, coupons:int) : *
      {
         if(coupons > taskPoints)
         {
            (m_slots[slotNumber] as CocowonderlandInnovationIngredientsSlot).disableBuyButton();
         }
      }
      
      public function disableAddButtonForSlot(slotNumber:int) : *
      {
         (m_slots[slotNumber] as CocowonderlandInnovationIngredientsSlot).disableAddButton();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function onBuyIngredientDone(result:Object) : void
      {
         if(result["slotNumber"] >= 0 && result["slotNumber"] < m_slots.length)
         {
            (m_slots[result["slotNumber"]] as CocowonderlandInnovationIngredientsSlot).onBuyDone(true);
         }
      }
      
      public function updateIngredientSlot(ingredient:XML) : void
      {
         var slotIngredient:XML = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slotIngredient = (m_slots[i] as CocowonderlandInnovationIngredientsSlot).getIngredient();
            if(slotIngredient["@name"] == ingredient["@name"])
            {
               (m_slots[i] as CocowonderlandInnovationIngredientsSlot).onBuyDone(true);
            }
         }
      }
   }
}

