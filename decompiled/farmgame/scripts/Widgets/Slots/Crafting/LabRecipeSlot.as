package Widgets.Slots.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.LabBuildingManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Frames.Crafting.CraftingRecipeIngredientBaseFrame;
   import Widgets.Frames.Crafting.LabRecipeIngredientFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class LabRecipeSlot extends CraftingRecipeBaseSlot
   {
      
      protected var m_recipeSlots:Array;
      
      protected var m_getBushels:FarmAnimatedCashButton;
      
      protected var m_buildingName:String;
      
      protected var m_labConfig:XML;
      
      public function LabRecipeSlot(element:DisplayObject, callBackObject:Object, labConfig:XML)
      {
         var fullSlot:String = null;
         this.m_recipeSlots = new Array();
         this.m_labConfig = labConfig;
         this.m_buildingName = LabBuildingManager.getInstance().getLabNameFromConfig(labConfig);
         super(element,callBackObject);
         var numIngredients:int = 6;
         if(this.m_labConfig.hasOwnProperty("maxIngredients"))
         {
            numIngredients = int(this.m_labConfig["maxIngredients"]);
         }
         for(var index:int = 1; index <= numIngredients; index++)
         {
            fullSlot = "recipeSlotFull" + index + "_mc";
            this.m_recipeSlots.push(addWidget(new LabRecipeIngredientFrame(this.element[fullSlot],callBackObject)) as LabRecipeIngredientFrame);
         }
         addWidget(this.m_getBushels = new FarmAnimatedCashButton(this.element.buyAll_bt,ZLocUtils.t("Dialogs",this.m_buildingName + "_GetIngredient"),String(CraftingRecipeIngredientBaseFrame.DEFAULT_BUSHEL_PRICE),this.pressBuyAll));
         m_recipeIcon.x -= 15;
         m_recipeIcon.y -= 23;
      }
      
      private function pressBuyAll(e:MouseEvent) : void
      {
         m_callBackObject.buyIngredients(m_recipeId);
      }
      
      public function updateRecipeInfo() : void
      {
         if(m_recipeItem)
         {
            if(m_recipeItem.image)
            {
               m_recipeIcon.loadIcon(m_recipeItem.image);
               m_recipeIcon.visible = true;
            }
            if(m_recipeItem.name)
            {
               m_recipeName.text = ZLocUtils.tk_pk_asTitle(m_recipeItem.friendlyName);
               m_recipeName.visible = true;
            }
         }
      }
      
      override protected function updateMakeButton(makeItEnabled:int, recipeItem:RecipeItem = null) : void
      {
         m_makeItEnabled = makeItEnabled;
         m_makeIt.applyGrayOut = makeItEnabled != CraftingConstants.CAN_MAKE_RECIPE;
         if(makeItEnabled == CraftingConstants.CAN_MAKE_RECIPE)
         {
            m_makeItToolTip.setText("");
         }
         else
         {
            m_makeItToolTip.setText(ZLocUtils.t("Dialogs",this.m_buildingName + "_CantMake"));
         }
         m_makeIt.visible = true;
      }
      
      public function updateSubSlots(data:Object, showIndividualBuyButtons:Boolean = true) : void
      {
         var numIngredients:int = 0;
         var defaultIngredientOrder:Array = null;
         var numDefaultIngredients:int = 0;
         var ingredientsUsed:Object = null;
         var ingredientIndex:int = 0;
         var ingredientSlotIndex:int = 0;
         var itemCode:String = null;
         if(Boolean(m_recipeItem) && Boolean(this.m_recipeSlots))
         {
            numIngredients = int(m_recipeItem.ingredients.length);
            defaultIngredientOrder = Global.craftConfigSettings.getCraftSkillDataForKey(this.m_labConfig["skillType"],"ingredientOrder");
            numDefaultIngredients = int(defaultIngredientOrder.length);
            ingredientsUsed = {};
            for(ingredientIndex = 0; ingredientIndex < numIngredients; ingredientIndex++)
            {
               ingredientsUsed[m_recipeItem.ingredients[ingredientIndex].itemCode] = ingredientIndex;
            }
            for(ingredientSlotIndex = 0; ingredientSlotIndex < numDefaultIngredients; ingredientSlotIndex++)
            {
               itemCode = defaultIngredientOrder[ingredientSlotIndex];
               if(ingredientsUsed.hasOwnProperty(itemCode))
               {
                  (this.m_recipeSlots[ingredientSlotIndex] as LabRecipeIngredientFrame).update(m_recipeItem,ingredientsUsed[itemCode],false,showIndividualBuyButtons);
               }
               else
               {
                  (this.m_recipeSlots[ingredientSlotIndex] as LabRecipeIngredientFrame).unusedIngredientFrame(itemCode);
               }
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         m_recipeId = "";
         m_recipeItem = null;
         if(data.hasOwnProperty("recipeId"))
         {
            m_recipeId = data.recipeId;
            m_recipeItem = Global.craftConfigSettings.getRecipeById(data.recipeId);
         }
         this.m_getBushels.setAmountText(CraftingManager.getInstance().getTotalBushelPrice(m_recipeItem).toString());
         this.m_getBushels.visible = true;
         if(m_recipeItem)
         {
            this.updateRecipeInfo();
            this.updateSubSlots(data,true);
            if(data.hasOwnProperty("recipeState"))
            {
               switch(data.recipeState)
               {
                  case CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS:
                     this.updateMakeButton(CraftingConstants.CAN_MAKE_RECIPE);
                     break;
                  case CraftingConstants.RECIPE_STATE_LOCK:
                     m_locked.visible = true;
                     m_lockedText.text = ZLocUtils.t("Crafting","General_Locked");
                     m_lockedText.visible = true;
                     m_lockedDescription.text = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedComingSoon");
                     m_lockedDescription.visible = true;
                     break;
                  case "":
                  default:
                     this.updateMakeButton(CraftingConstants.OVEN_SLOTS_FULL);
               }
            }
         }
      }
   }
}

