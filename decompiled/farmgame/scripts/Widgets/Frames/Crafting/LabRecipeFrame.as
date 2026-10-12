package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Crafting.DragonLairRecipeSlot;
   import Widgets.Slots.Crafting.LabRecipeSlot;
   import Widgets.Slots.Crafting.UnicornIslandRecipeSlot;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   
   public class LabRecipeFrame extends CraftingRecipeBaseFrame
   {
      
      private static var m_classCompilingArray:Array = [LabRecipeSlot,UnicornIslandRecipeSlot,DragonLairRecipeSlot];
      
      private var m_labSkill:String;
      
      private var m_labSpecialization:String;
      
      private var m_labConfig:XML;
      
      public function LabRecipeFrame(element:DisplayObject, callBackObject:Object, labConfig:XML)
      {
         this.m_labSkill = labConfig["skillType"];
         this.m_labSpecialization = labConfig["specialization"];
         this.m_labConfig = labConfig;
         super(element,callBackObject);
      }
      
      public function refreshRecipe(recipeId:String, openNextSlot:Boolean = false) : void
      {
         var recipeData:Object = null;
         for(var recipeIndex:int = 0; recipeIndex < m_slotData.length; recipeIndex++)
         {
            recipeData = m_slotData[recipeIndex];
            if(recipeData.recipeId == recipeId)
            {
               m_slotData[recipeIndex] = this.populateLabRecipeData(recipeData);
               if(openNextSlot)
               {
                  this.setupData();
                  this.refreshAndPopulateNextSlot(m_slots.length * m_pagingComponent.currentPageNumber,recipeId);
               }
               refresh();
               break;
            }
         }
      }
      
      private function populateLabRecipeData(recipeData:Object) : Object
      {
         var recipeItem:RecipeItem = CraftingManager.getRecipeItemFromId(recipeData.recipeId,this.m_labSkill);
         recipeData.recipeState = "";
         if(recipeItem.comingSoon)
         {
            recipeData.recipeState = CraftingConstants.RECIPE_STATE_LOCK;
         }
         else if(recipeItem.canMake)
         {
            recipeData.recipeState = CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS;
         }
         return recipeData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var recipeSlotClass:Class = getDefinitionByName(this.m_labConfig["recipeSlotClass"]) as Class;
         return new recipeSlotClass(slotElement,m_callBackObject,this.m_labConfig);
      }
      
      override protected function getRecipeCount() : int
      {
         return CraftingManager.getInstance().getRecipeData(this.m_labSkill,this.m_labSpecialization).length;
      }
      
      override protected function setupData() : void
      {
         var recipeData:Array = null;
         var recipeItem:RecipeItem = null;
         recipeData = CraftingManager.getInstance().getRecipeData(this.m_labSkill,this.m_labSpecialization);
         m_slotData = new Array();
         var len:int = int(recipeData.length);
         for(var j:int = 0; j < len; j++)
         {
            if(recipeData.hasOwnProperty(j) && Boolean(recipeData[j]))
            {
               recipeItem = Global.craftConfigSettings.getRecipeById(recipeData[j].recipeId);
               recipeData[j].recipeState = "";
               if(recipeItem.comingSoon)
               {
                  recipeData[j].recipeState = CraftingConstants.RECIPE_STATE_LOCK;
               }
               else if(recipeItem.canMake)
               {
                  recipeData[j].recipeState = CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS;
               }
               m_slotData.push(recipeData[j]);
            }
         }
      }
      
      private function refreshAndPopulateNextSlot(dataIndex:uint, recipeId:String) : void
      {
         var slot:ZwSlotFrame = null;
         var data:Object = null;
         var recipeData:Object = null;
         clearSlots();
         var slotIdx:uint = 0;
         while(slotIdx < m_slots.length && Boolean(m_slots[slotIdx]))
         {
            if(!(dataIndex < m_slotData.length && Boolean(m_slotData[dataIndex])))
            {
               break;
            }
            recipeData = m_slotData[dataIndex];
            if(recipeData.recipeId == recipeId)
            {
               recipeData["showRecipeImage"] = true;
               populateSlot(m_slots[slotIdx] as ZwSlotFrame,m_slotData[dataIndex]);
               slotIdx++;
               dataIndex++;
               if(Boolean(dataIndex < m_slotData.length) && Boolean(m_slotData[dataIndex]) && Boolean(m_slots[slotIdx]))
               {
                  recipeData = m_slotData[dataIndex];
                  recipeData["forceOpenSlot"] = true;
                  populateSlot(m_slots[slotIdx] as ZwSlotFrame,m_slotData[dataIndex]);
               }
               break;
            }
            slotIdx++;
            dataIndex++;
         }
         m_lastPopulateStartIndex = dataIndex;
      }
   }
}

