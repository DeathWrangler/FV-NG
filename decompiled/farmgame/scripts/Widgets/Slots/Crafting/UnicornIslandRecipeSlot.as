package Widgets.Slots.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Frames.Crafting.LabRecipeIngredientFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class UnicornIslandRecipeSlot extends LabRecipeSlot
   {
      
      private static const UNICORN_VARIANT_1:int = 1;
      
      private static const UNICORN_VARIANT_2:int = 2;
      
      private static var REPLACEMENT_TO_DEPRECATED_RECIPE_MAP:Object = {"a3i":"a3u"};
      
      private var m_showIcon:Boolean;
      
      private var m_forceShowRecipeImage:Boolean = false;
      
      protected var m_iconToolTip:FarmTextTooltip;
      
      public function UnicornIslandRecipeSlot(element:DisplayObject, callBackObject:Object, labConfig:XML)
      {
         var unicornIslandVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UNICORN_ISLAND);
         switch(unicornIslandVariant)
         {
            case UNICORN_VARIANT_1:
               this.m_showIcon = false;
               break;
            case UNICORN_VARIANT_2:
               this.m_showIcon = true;
         }
         super(element,callBackObject,labConfig);
      }
      
      override public function updateRecipeInfo() : void
      {
         if(m_recipeItem)
         {
            if(this.m_forceShowRecipeImage)
            {
               this.updateRecipeInfoWithFlags(this.m_forceShowRecipeImage);
            }
            else
            {
               this.updateRecipeInfoWithFlags(this.m_showIcon);
            }
         }
      }
      
      private function updateRecipeInfoWithFlags(showIcon:Boolean) : void
      {
         var lootDropMessage:String = null;
         var isUnlocked:Boolean = this.isRecipeIdUnlocked(m_recipeId);
         if(m_recipeItem.image)
         {
            m_recipeIcon.loadIcon(m_recipeItem.image);
            m_recipeIcon.visible = isUnlocked ? isUnlocked : showIcon;
            lootDropMessage = ZLocUtils.t("Crafting",m_recipeItem.name + "_lootdrop");
            this.m_iconToolTip = new FarmTextTooltip(lootDropMessage);
            if(!showIcon)
            {
               if(!isUnlocked)
               {
                  if(this.element.mysteryUnicorn_mc)
                  {
                     this.m_element.mysteryUnicorn_mc.visible = true;
                  }
               }
            }
         }
         if(m_recipeItem.name)
         {
            m_recipeName.text = ZLocUtils.tk_pk_asTitle(m_recipeItem.friendlyName);
            m_recipeName.visible = isUnlocked ? isUnlocked : showIcon;
         }
      }
      
      override public function updateSubSlots(data:Object, showIndividualBuyButtons:Boolean = true) : void
      {
         var numIngredients:int = 0;
         var defaultIngredientOrder:Array = null;
         var numDefaultIngredients:int = 0;
         var ingredientsUsed:Object = null;
         var ingredientIndex:int = 0;
         var ingredientSlotIndex:int = 0;
         var itemCode:String = null;
         if(Boolean(m_recipeItem) && Boolean(m_recipeSlots))
         {
            numIngredients = int(m_recipeItem.ingredients.length);
            defaultIngredientOrder = Global.craftConfigSettings.getCraftSkillDataForKey(m_labConfig["skillType"],"ingredientOrder");
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
                  (m_recipeSlots[ingredientSlotIndex] as LabRecipeIngredientFrame).update(m_recipeItem,ingredientsUsed[itemCode]);
               }
               else
               {
                  (m_recipeSlots[ingredientSlotIndex] as LabRecipeIngredientFrame).unusedIngredientFrame(itemCode);
               }
            }
         }
      }
      
      private function shouldShowRecipeSlot() : Boolean
      {
         var unlockWithItems:Array = null;
         var unlockWithItemsLength:int = 0;
         var index:int = 0;
         var flagsArrayLength:int = 0;
         var flagIndex:int = 0;
         var isUnlocked:Boolean = false;
         var checkObjects:Array = new Array();
         var shouldShowSlot:Boolean = false;
         if(m_recipeItem)
         {
            unlockWithItems = m_recipeItem.unlockWithItems;
            unlockWithItemsLength = int(unlockWithItems.length);
            for(index = 0; index < unlockWithItemsLength; index++)
            {
               isUnlocked = this.isRecipeIdUnlocked(unlockWithItems[index]);
               checkObjects.push(isUnlocked);
            }
            flagsArrayLength = int(checkObjects.length);
            for(flagIndex = 0; flagIndex < flagsArrayLength; flagIndex++)
            {
               if(!checkObjects[flagIndex])
               {
                  return shouldShowSlot;
               }
            }
            shouldShowSlot = true;
         }
         return shouldShowSlot;
      }
      
      private function isRecipeIdUnlocked(recipeItemCode:String) : Boolean
      {
         var isUnlocked:Boolean = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LAB_BUILDING,recipeItemCode));
         if(!isUnlocked && REPLACEMENT_TO_DEPRECATED_RECIPE_MAP.hasOwnProperty(recipeItemCode))
         {
            isUnlocked = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LAB_BUILDING,REPLACEMENT_TO_DEPRECATED_RECIPE_MAP[recipeItemCode]));
         }
         return isUnlocked;
      }
      
      private function lockRecipeSlot() : void
      {
         var text:String = null;
         if(this.m_element.mysteryUnicorn_mc)
         {
            this.m_element.mysteryUnicorn_mc.visible = true;
         }
         if(this.m_element.unlockText_mc.unlock_tf)
         {
            text = ZLocUtils.t("Crafting",m_recipeItem.craft + "_locked_slot");
            if(Boolean(text) && text != "")
            {
               this.m_element.unlockText_mc.unlock_tf.text = text;
            }
         }
      }
      
      private function openRecipeSlot() : void
      {
         if(this.m_element.mysteryUnicorn_mc)
         {
            this.m_element.mysteryUnicorn_mc.visible = false;
         }
         this.m_element.unlockText_mc.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         m_recipeId = "";
         m_recipeItem = null;
         var forceOpenSlot:Boolean = data.hasOwnProperty("forceOpenSlot") ? Boolean(data["forceOpenSlot"]) : false;
         if(data.hasOwnProperty("recipeId"))
         {
            m_recipeId = data.recipeId;
            m_recipeItem = Global.craftConfigSettings.getRecipeById(data.recipeId);
         }
         this.openRecipeSlot();
         var leaveSlotOpen:Boolean = this.shouldShowRecipeSlot();
         if(leaveSlotOpen || forceOpenSlot)
         {
            m_widgetManager.hideAllWidgets();
            m_getBushels.setAmountText(CraftingManager.getInstance().getTotalBushelPrice(m_recipeItem).toString());
            m_getBushels.visible = true;
            if(m_recipeItem)
            {
               this.m_forceShowRecipeImage = data.hasOwnProperty("showRecipeImage") ? Boolean(data["showRecipeImage"]) : false;
               this.updateRecipeInfo();
               this.updateSubSlots(data);
               if(data.hasOwnProperty("recipeState"))
               {
                  switch(data.recipeState)
                  {
                     case CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS:
                        updateMakeButton(CraftingConstants.CAN_MAKE_RECIPE);
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
                        updateMakeButton(CraftingConstants.OVEN_SLOTS_FULL);
                  }
               }
            }
         }
         else
         {
            this.lockRecipeSlot();
         }
      }
   }
}

