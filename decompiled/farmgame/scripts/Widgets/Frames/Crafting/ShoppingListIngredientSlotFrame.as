package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.ShoppingListIngredientSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ShoppingListIngredientSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_recipe:RecipeItem;
      
      private var m_getItemCallback:Function;
      
      private var m_askForItemCallback:Function;
      
      private var m_viewInventoryCallback:Function;
      
      private var m_buyButtonCallback:Function;
      
      public function ShoppingListIngredientSlotFrame(element:MovieClip, recipe:RecipeItem, getItemCallback:Function, askForItemCallback:Function, viewInventoryCallback:Function, buyButtonCallback:Function = null)
      {
         this.m_recipe = recipe;
         this.m_getItemCallback = getItemCallback;
         this.m_askForItemCallback = askForItemCallback;
         this.m_viewInventoryCallback = viewInventoryCallback;
         this.m_buyButtonCallback = buyButtonCallback;
         super(element);
         this.setupData();
         refresh();
      }
      
      override protected function setupData() : void
      {
         var index:String = null;
         m_slotData = [];
         if(this.m_recipe)
         {
            for(index in this.m_recipe.ingredients)
            {
               if(!(this.m_recipe.ingredients[index].hasOwnProperty(RecipeItem.SWAPPABLE) && this.m_recipe.ingredients[index][RecipeItem.SWAPPABLE] == true))
               {
                  m_slotData.push(this.m_recipe.ingredients[index]);
               }
            }
         }
      }
      
      public function set recipe(recipe:RecipeItem) : void
      {
         this.m_recipe = recipe;
         this.setupData();
         refresh();
      }
      
      public function get recipe() : RecipeItem
      {
         return this.m_recipe;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ShoppingListIngredientSlot(slotElement,this.m_getItemCallback,this.m_askForItemCallback,this.m_viewInventoryCallback,this.m_buyButtonCallback);
      }
      
      public function isComplete() : Boolean
      {
         var slot:ShoppingListIngredientSlot = null;
         var result:Boolean = true;
         for each(slot in m_slots)
         {
            if(!slot.isComplete())
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      override public function release() : void
      {
         this.m_recipe = null;
         this.m_getItemCallback = null;
         this.m_askForItemCallback = null;
         this.m_viewInventoryCallback = null;
         this.m_buyButtonCallback = null;
         super.release();
      }
   }
}

