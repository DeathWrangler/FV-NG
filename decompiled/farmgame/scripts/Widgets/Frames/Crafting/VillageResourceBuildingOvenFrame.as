package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingRecipeQueueManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.VillageResourceBuildingOvenSlot;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.DisplayObject;
   
   public class VillageResourceBuildingOvenFrame extends FarmSlotContainerFrame
   {
      
      private static const MAX_POSSIBLE_OVEN_SLOTS:int = 6;
      
      public static const ICON_STATE_RECIPE_COMPLETE:String = "recipeComplete";
      
      public static const ICON_STATE_IN_PROGRESS:String = "inProgress";
      
      public static const ICON_STATE_OPEN:String = "open";
      
      public static const ICON_STATE_UNLOCKED:String = "unlocked";
      
      public static const ICON_STATE_LOCKED:String = "locked";
      
      private var m_parentWindow:VillageResourceBuildingWindow = null;
      
      private var m_craftSkill:String = "";
      
      public function VillageResourceBuildingOvenFrame(element:DisplayObject, parentWindow:VillageResourceBuildingWindow, craftSkill:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_craftSkill = craftSkill;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new VillageResourceBuildingOvenSlot(slotElement,this.m_parentWindow,this.m_craftSkill);
      }
      
      public function update() : void
      {
         this.setupData();
         populateSlots();
      }
      
      override protected function setupData() : void
      {
         var recipesInProgress:Array = null;
         var recipesInProgressLength:int = 0;
         var recipeItem:RecipeItem = null;
         var finishTimeString:String = null;
         var timeRemaining:int = 0;
         var recipeId:String = null;
         var ovenSlot:int = 0;
         var i:int = 0;
         var totalOvens:Number = NaN;
         var totalOvensUsable:Number = NaN;
         var remainingItem:Object = null;
         var iLocked:int = 0;
         var slotRecipeData:Array = null;
         if(CraftingRecipeQueueManager.getInstanceByCraftType(this.m_craftSkill))
         {
            recipesInProgress = CraftingRecipeQueueManager.getInstanceByCraftType(this.m_craftSkill).recipeQueue;
            recipesInProgressLength = int(recipesInProgress.length);
            recipeItem = null;
            finishTimeString = "";
            timeRemaining = 0;
            recipeId = "";
            ovenSlot = 0;
            m_slotData = new Array();
            for(i = 0; i < recipesInProgressLength; i++)
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
                           slotRecipeData.recipeItem = recipeItem;
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
            totalOvens = MAX_POSSIBLE_OVEN_SLOTS;
            totalOvensUsable = this.m_parentWindow.getBuildingStorageLevel();
            remainingItem = null;
            for(iLocked = int(m_slotData.length); iLocked < totalOvens; iLocked++)
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
      }
   }
}

