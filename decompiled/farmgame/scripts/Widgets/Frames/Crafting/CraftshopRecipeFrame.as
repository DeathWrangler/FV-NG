package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Crafting.CraftshopRecipeSlot;
   import Widgets.Slots.Crafting.OneIconCrafshopRecipeSlot;
   import flash.display.DisplayObject;
   
   public class CraftshopRecipeFrame extends CraftingRecipeBaseFrame
   {
      
      private var m_craftSkill:String = "";
      
      private var m_currentTab:String = "";
      
      private var m_isInNewCraftshopExperiment:Boolean;
      
      private var m_featureName:String;
      
      public function CraftshopRecipeFrame(element:DisplayObject, callBackObject:Object, craftskill:String, tabName:String = "", featureName:String = "")
      {
         this.m_craftSkill = craftskill;
         this.m_currentTab = tabName;
         this.m_featureName = featureName;
         this.m_isInNewCraftshopExperiment = CraftingManager.shouldUseNewCraftshopInFeature(this.m_featureName);
         super(element,callBackObject);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return this.m_isInNewCraftshopExperiment ? new OneIconCrafshopRecipeSlot(slotElement,m_callBackObject) : new CraftshopRecipeSlot(slotElement,m_callBackObject,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         var recipeData:Array = null;
         var slotData:Object = null;
         var newObject:Object = null;
         var recipe:Object = null;
         var prop:String = null;
         m_slotData = new Array();
         if(this.m_isInNewCraftshopExperiment)
         {
            recipeData = CraftingManager.getInstance().getRecipeDataForSpecializationAndType(this.m_craftSkill,CraftingConstants.CRAFTSHOP_SPECIALIZATION,this.m_currentTab,m_callBackObject.searchString(),m_callBackObject.getSortInfo());
         }
         else
         {
            recipeData = CraftingManager.getInstance().getRecipeData(this.m_craftSkill,CraftingConstants.CRAFTSHOP_SPECIALIZATION,true,false,m_callBackObject.searchString());
         }
         var inProgressRecipeIdHash:Object = CraftingManager.getInProgressRecipeHash(this.m_craftSkill);
         var recipeStarsEarned:int = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType(this.m_craftSkill);
         for each(recipe in recipeData)
         {
            slotData = populateRecipeData(recipe,recipeStarsEarned,inProgressRecipeIdHash,this.m_craftSkill);
            newObject = new Object();
            for(prop in slotData)
            {
               newObject[prop] = slotData[prop];
            }
            m_slotData.push(newObject);
         }
      }
      
      public function setCurrentTab(currentTab:String) : void
      {
         this.m_currentTab = currentTab;
      }
      
      public function refreshRecipe(recipeId:String) : void
      {
         var recipeData:Object = null;
         var recipeStarsEarned:int = 0;
         var inProgressRecipeIdHash:Object = null;
         for(var recipeIndex:int = 0; recipeIndex < m_slotData.length; recipeIndex++)
         {
            recipeData = m_slotData[recipeIndex];
            if(recipeData.recipeId == recipeId)
            {
               recipeStarsEarned = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType(this.m_craftSkill);
               inProgressRecipeIdHash = CraftingManager.getInProgressRecipeHash(this.m_craftSkill);
               m_slotData[recipeIndex] = populateRecipeData(recipeData,recipeStarsEarned,inProgressRecipeIdHash,this.m_craftSkill);
               refresh();
               break;
            }
         }
      }
      
      public function refreshMasteryLocks() : void
      {
         var recipeItem:RecipeItem = null;
         var recipeData:Object = null;
         var recipeStarsEarned:int = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType(this.m_craftSkill);
         var inProgressRecipeIdHash:Object = CraftingManager.getInProgressRecipeHash(this.m_craftSkill);
         var shouldRefresh:Boolean = false;
         var recipeCount:int = int(m_slotData.length);
         for(var recipeIndex:int = 0; recipeIndex < recipeCount; recipeIndex++)
         {
            recipeData = m_slotData[recipeIndex];
            recipeItem = CraftingManager.getRecipeItemFromId(recipeData.recipeId,this.m_craftSkill);
            if(recipeItem.requiredRecipeMastery > 0 && recipeItem.requiredRecipeMastery <= recipeStarsEarned)
            {
               m_slotData[recipeIndex] = populateRecipeData(recipeData,recipeStarsEarned,inProgressRecipeIdHash,this.m_craftSkill);
               shouldRefresh = true;
            }
         }
         if(shouldRefresh)
         {
            refresh();
         }
      }
      
      public function filterOptionsChanged() : void
      {
         this.setupData();
         refresh();
      }
   }
}

