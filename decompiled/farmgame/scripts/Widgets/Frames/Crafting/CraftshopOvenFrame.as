package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.CraftingRecipeQueueManager;
   import Managers.HangingGardensManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftshopOvenSlot;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import flash.display.DisplayObject;
   
   public class CraftshopOvenFrame extends FarmSlotContainerFrame
   {
      
      public static const ICON_STATE_RECIPE_COMPLETE:String = "recipeComplete";
      
      public static const ICON_STATE_IN_PROGRESS:String = "inProgress";
      
      public static const ICON_STATE_OPEN:String = "open";
      
      public static const ICON_STATE_UNLOCKED:String = "unlocked";
      
      public static const ICON_STATE_LOCKED:String = "locked";
      
      protected var m_window:CraftshopWindow = null;
      
      private var m_craftSkill:String = "";
      
      private var m_featureName:String;
      
      public function CraftshopOvenFrame(element:DisplayObject, window:CraftshopWindow, craftSkill:String, featureName:String = "")
      {
         this.m_craftSkill = craftSkill;
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftshopOvenSlot(slotElement,this.m_window,this.m_featureName);
      }
      
      public function update() : void
      {
         this.setupData();
         populateSlots();
      }
      
      override protected function setupData() : void
      {
         var recipeId:String = null;
         var ovenSlot:int = 0;
         var slotRecipeData:Array = null;
         var inProgressRecipeIdHash:Object = null;
         var minRecipe:int = 0;
         var maxRecipe:int = 0;
         var j:int = 0;
         var recipeQueue:Array = null;
         var k:int = 0;
         var recipeData:Array = CraftingManager.getInstance().getRecipeData(this.m_craftSkill,CraftingConstants.CRAFTSHOP_SPECIALIZATION,false,true);
         var recipesInProgress:Array = CraftingRecipeQueueManager.getInstanceByCraftType(this.m_craftSkill).recipeQueue;
         var recipeItem:RecipeItem = null;
         var finishTimeString:String = "";
         var timeRemaining:int = 0;
         var i:int = 0;
         if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
         {
            m_slotData = new Array();
            for(i = 0; i < recipesInProgress.length; i++)
            {
               if(recipesInProgress[i])
               {
                  recipeItem = recipesInProgress[i] as RecipeItem;
                  recipeId = recipeItem.id;
                  ovenSlot = recipeItem.ovenSlot;
                  if(Boolean(recipeId) && recipeItem.worldType == Global.worldManager.currentWorldType)
                  {
                     if(m_slotData.length < CraftingConstants.MAX_POSSIBLE_OVEN_SLOTS)
                     {
                        if(ovenSlot >= 0)
                        {
                           slotRecipeData = new Array();
                           slotRecipeData.recipeId = recipeId;
                           slotRecipeData.ovenSlot = ovenSlot;
                           slotRecipeData.recipeState = ICON_STATE_IN_PROGRESS;
                           if(recipeItem.serverStartTS > 0 && recipeItem.realTimeRemaining <= 0)
                           {
                              slotRecipeData.recipeState = ICON_STATE_RECIPE_COMPLETE;
                              finishTimeString = ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsReady",{"item":ZLocUtils.tk_pk(recipeItem.friendlyName)});
                           }
                           else
                           {
                              timeRemaining = recipeItem.realTimeRemaining;
                              finishTimeString = FarmGameUtil.toFriendlyTime(recipeItem.realTimeRemaining);
                              slotRecipeData.percent = Number((recipeItem.secondsToCook - timeRemaining) / recipeItem.secondsToCook);
                           }
                           slotRecipeData.finishTime = finishTimeString;
                           m_slotData.push(slotRecipeData);
                        }
                     }
                  }
               }
            }
         }
         else
         {
            inProgressRecipeIdHash = {};
            for(i = 0; i < recipesInProgress.length; i++)
            {
               if(Boolean(recipesInProgress[i].id) && (recipesInProgress[i] as RecipeItem).worldType == Global.worldManager.currentWorldType)
               {
                  inProgressRecipeIdHash[recipesInProgress[i].id] = 1;
               }
            }
            recipeData = this.sortRecipeDataByType(recipeData,inProgressRecipeIdHash);
            minRecipe = 0;
            maxRecipe = CraftingConstants.MAX_POSSIBLE_OVEN_SLOTS;
            m_slotData = new Array();
            for(j = minRecipe; j < maxRecipe; j++)
            {
               if(recipeData.hasOwnProperty(j.toString()) && Boolean(recipeData[j]))
               {
                  recipeItem = Global.craftConfigSettings.getRecipeById(recipeData[j].recipeId);
                  recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(this.m_craftSkill);
                  for(k = 0; k < recipeQueue.length; k++)
                  {
                     if(recipeQueue[k].id == recipeData[j].recipeId && (recipeQueue[k] as RecipeItem).worldType == Global.worldManager.currentWorldType)
                     {
                        recipeItem = recipeQueue[k];
                     }
                  }
                  recipeData[j].recipeState = "";
                  finishTimeString = "";
                  if(inProgressRecipeIdHash.hasOwnProperty(recipeData[j].recipeId))
                  {
                     recipeData[j].recipeState = ICON_STATE_IN_PROGRESS;
                     if(recipeItem.serverStartTS > 0 && recipeItem.realTimeRemaining <= 0)
                     {
                        recipeData[j].recipeState = ICON_STATE_RECIPE_COMPLETE;
                        finishTimeString = ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsReady",{"item":ZLocUtils.tk_pk(recipeItem.friendlyName)});
                     }
                     else
                     {
                        timeRemaining = recipeItem.realTimeRemaining;
                        finishTimeString = FarmGameUtil.toFriendlyTime(recipeItem.secondsToCook);
                        recipeData[j].percent = Number((recipeItem.secondsToCook - timeRemaining) / recipeItem.secondsToCook);
                     }
                     recipeData[j].finishTime = finishTimeString;
                     m_slotData.push(recipeData[j]);
                  }
               }
            }
         }
         var totalOvens:Number = CraftingConstants.MAX_POSSIBLE_OVEN_SLOTS;
         var totalOvensUsable:Number = this.m_window.getBuildingStorageLevel();
         var remainingItem:Object = null;
         for(var iLocked:int = int(m_slotData.length); iLocked < totalOvens; iLocked++)
         {
            if(iLocked < totalOvensUsable)
            {
               remainingItem = {
                  "recipeId":"",
                  "recipeState":ICON_STATE_OPEN
               };
            }
            else if(iLocked == totalOvensUsable)
            {
               remainingItem = {
                  "recipeId":"",
                  "recipeState":ICON_STATE_UNLOCKED
               };
            }
            else
            {
               remainingItem = {
                  "recipeId":"",
                  "recipeState":ICON_STATE_LOCKED
               };
            }
            m_slotData.push(remainingItem);
         }
      }
      
      private function sortRecipeDataByType(recipeData:Array, inProgressRecipeIdHash:Object) : Array
      {
         var recipeDataSorted:Array = null;
         var canMake:Array = null;
         var inProgress:Array = null;
         var comingSoon:Array = null;
         var others:Array = null;
         var rctr:int = 0;
         var rObject:Object = null;
         var recipeItem:RecipeItem = null;
         if(!HangingGardensManager.isInHangingGardensExperiment() || !Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"])
         {
            canMake = [];
            inProgress = [];
            comingSoon = [];
            others = [];
            for(rctr = 0; rctr < recipeData.length; rctr++)
            {
               rObject = recipeData[rctr];
               recipeItem = Global.craftConfigSettings.getRecipeById(rObject.recipeId);
               if(inProgressRecipeIdHash.hasOwnProperty(rObject.recipeId))
               {
                  inProgress.push(rObject);
               }
               else if(recipeItem.canMake)
               {
                  canMake.push(rObject);
               }
               else if(recipeItem.comingSoon)
               {
                  comingSoon.push(rObject);
               }
               else
               {
                  others.push(rObject);
               }
            }
            recipeDataSorted = inProgress.concat(canMake,others,comingSoon);
         }
         return recipeDataSorted;
      }
   }
}

