package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class CraftingRecipeBaseFrame extends FarmSlotContainerFrame
   {
      
      private static const RECIPES_PER_PAGE:int = 3;
      
      protected var m_topCell:ZwWidget = null;
      
      protected var m_bottomCell:ZwWidget = null;
      
      protected var m_page:int = 0;
      
      protected var m_callBackObject:Object;
      
      public function CraftingRecipeBaseFrame(element:DisplayObject, callBackObject:Object)
      {
         this.m_callBackObject = callBackObject;
         super(element);
         if(this.element.hasOwnProperty("arrowUp_bt"))
         {
            m_pageBackWidget = addWidget(new ZwButton(this.element.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         }
         if(this.element.hasOwnProperty("arrowDown_bt"))
         {
            m_pageForwardWidget = addWidget(new ZwButton(this.element.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         }
         if(this.element.hasOwnProperty("topCell_mc"))
         {
            this.m_topCell = addWidget(new ZwWidget(this.element.topCell_mc),false) as ZwWidget;
         }
         if(this.element.hasOwnProperty("botCell_mc"))
         {
            this.m_bottomCell = addWidget(new ZwWidget(this.element.botCell_mc)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("page_tf"))
         {
            m_currentPageLabel = new ZwTextField(m_element.page_tf);
            addWidget(m_currentPageLabel);
         }
         refresh();
      }
      
      public function update() : void
      {
         setupData();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
      }
      
      protected function getRecipeCount() : int
      {
         return 0;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      protected function populateRecipeData(recipeData:Object, masteryStars:int, inProgressRecipeIdHash:Object, craftSkill:String) : Object
      {
         var timeRemaining:int = 0;
         var recipeItem:RecipeItem = CraftingManager.getRecipeItemFromId(recipeData.recipeId,craftSkill);
         recipeData.recipeState = "";
         if(recipeItem.comingSoon)
         {
            recipeData.recipeState = CraftingConstants.RECIPE_STATE_LOCK;
         }
         else if(!recipeItem.canUnlock)
         {
            recipeData.recipeState = CraftingConstants.RECIPE_STATE_PREREQ_LOCKED;
         }
         else
         {
            if(recipeItem.canMake)
            {
               recipeData.recipeState = CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS;
            }
            if(recipeItem.requiredRecipeMastery > masteryStars)
            {
               recipeData.recipeState = CraftingConstants.RECIPE_STATE_RECIPE_MASTERY_LOCKED;
            }
            if(inProgressRecipeIdHash.hasOwnProperty(recipeData.recipeId))
            {
               recipeData.recipeState = CraftingConstants.RECIPE_STATE_IN_PROGRESS;
               if(recipeItem.serverStartTS > 0 && recipeItem.realTimeRemaining <= 0)
               {
                  recipeData.recipeState = CraftingConstants.RECIPE_STATE_COMPLETE;
               }
               else
               {
                  timeRemaining = recipeItem.realTimeRemaining;
                  recipeData.finishTime = FarmGameUtil.toFriendlyTime(timeRemaining);
                  recipeData.percent = Number((recipeItem.secondsToCook - timeRemaining) / recipeItem.secondsToCook);
               }
            }
         }
         return recipeData;
      }
   }
}

