package Widgets.Frames.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class LabRecipeIngredientFrame extends CraftingRecipeIngredientBaseFrame
   {
      
      private var m_callBackObject:Object;
      
      private var m_bushel:String;
      
      private var m_recipe:String;
      
      public function LabRecipeIngredientFrame(element:DisplayObject, callBackObject:Object)
      {
         this.m_callBackObject = callBackObject;
         super(element);
      }
      
      public function update(recipeItem:RecipeItem, ingredientIndex:int, hideRecipeRequirement:Boolean = false, showIndividualBuyButtons:Boolean = true) : void
      {
         var itemCode:String = null;
         var nHave:int = 0;
         var bushelItem:FarmItem = null;
         this.m_widgetManager.hideAllWidgets();
         this.applyGrayOut = false;
         this.visible = true;
         if(Boolean(recipeItem) && Boolean(recipeItem.ingredients) && recipeItem.ingredients.hasOwnProperty(ingredientIndex))
         {
            itemCode = recipeItem.ingredients[ingredientIndex].itemCode;
            if(itemCode)
            {
               this.m_bushel = itemCode;
               this.m_recipe = recipeItem.id;
               this.prepIngredientItemIcon(itemCode,true);
               if(recipeItem.ingredients[ingredientIndex].quantityRequired)
               {
                  nHave = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
                  m_info.text = nHave.toString();
                  m_info.visible = true;
               }
               if(!hideRecipeRequirement)
               {
                  m_info.text = m_info.text + "/" + recipeItem.ingredients[ingredientIndex].quantityRequired;
               }
               if(m_getBushel != null && showIndividualBuyButtons)
               {
                  bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  m_getBushel.setAmountText(Global.farmGameSettingsManager.getAttribute(bushelItem.name + "Price",1));
                  m_getBushel.callback = this.pressBuyBushel;
                  m_getBushel.visible = true;
               }
            }
         }
      }
      
      public function unusedIngredientFrame(itemCode:String) : void
      {
         this.m_widgetManager.hideAllWidgets();
         this.applyGrayOut = true;
         this.visible = true;
         if(itemCode)
         {
            this.prepIngredientItemIcon(itemCode,false);
         }
      }
      
      private function prepIngredientItemIcon(itemCode:String, active:Boolean) : void
      {
         var bushelName:String = null;
         var ingredientItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(ingredientItem)
         {
            if(ingredientItem.icon)
            {
               m_icon.loadIcon(ingredientItem.icon);
               m_icon.setIconSize(50,50);
               m_icon.visible = true;
            }
            bushelName = ingredientItem.friendlyTitle;
            if(!active)
            {
               bushelName += ZLocUtils.t("Dialogs","IngredientNotNeeded");
            }
            m_toolTip.setText(bushelName);
         }
      }
      
      public function pressBuyBushel(event:MouseEvent) : void
      {
         if(this.m_callBackObject != null)
         {
            this.m_callBackObject.buyBushel(this.m_bushel,this.m_recipe);
         }
      }
   }
}

