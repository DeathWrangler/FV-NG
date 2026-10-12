package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.Crafting.VillageResourceBuildingRecipeIngredientSlot;
   import Widgets.Slots.Crafting.VillageResourceBuildingRecipeSlot;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class VillageResourceBuildingRecipeFrame extends FarmSlotContainerFrame
   {
      
      protected static const RESOURCE_BUILDING_RECIPE_SLOT_PREFIX:String = "recipe_";
      
      protected static const RESOURCE_BUILDING_RECIPE_SLOT_POSTFIX:String = "_mc";
      
      private var m_currentTab:String = "";
      
      private var m_craftSkill:String = "";
      
      private var m_parentWindow:VillageResourceBuildingWindow = null;
      
      private var m_ingredientsFrame:GenericSlotContainerFrame = null;
      
      private var m_selectedIngredientNameTextField:ZwTextField = null;
      
      private var m_selectedRecipe:RecipeItem = null;
      
      private var m_ingredientSlotData:Array = null;
      
      public function VillageResourceBuildingRecipeFrame(element:DisplayObject, craftSkill:String, tabName:String, parentWindow:VillageResourceBuildingWindow)
      {
         this.m_currentTab = tabName;
         this.m_craftSkill = craftSkill;
         this.m_parentWindow = parentWindow;
         super(element);
         if(Boolean(m_slotData[0]) && Boolean(m_slotData[0].recipeItem))
         {
            this.m_selectedRecipe = m_slotData[0].recipeItem;
         }
         if(m_element.hasOwnProperty("leftArrow_bt"))
         {
            addWidget(new FarmAnimatedButton(m_element.leftArrow_bt,this.leftArrowButtonCallback));
         }
         if(m_element.hasOwnProperty("rightArrow_bt"))
         {
            addWidget(new FarmAnimatedButton(m_element.rightArrow_bt,this.rightArrowButtonCallback));
         }
         if(m_element.hasOwnProperty("ingredientSlot_mc"))
         {
            this.setupIngredientData();
            this.m_ingredientsFrame = addWidget(new GenericSlotContainerFrame(m_element.ingredientSlot_mc,VillageResourceBuildingRecipeIngredientSlot,this.m_ingredientSlotData,this.m_parentWindow)) as GenericSlotContainerFrame;
         }
         if(m_element.hasOwnProperty("generic_tf") && Boolean(this.m_selectedRecipe))
         {
            this.m_selectedIngredientNameTextField = addWidget(new ZwTextField(m_element.generic_tf,this.m_selectedRecipe.friendlyTitle)) as ZwTextField;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new VillageResourceBuildingRecipeSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         var slotData:Object = null;
         var recipe:Object = null;
         m_slotData = new Array();
         var sortBy:Object = {
            "sortBy":"name",
            "direction":"desc"
         };
         var recipeData:Array = CraftingManager.getInstance().getRecipeDataForSpecializationAndType(this.m_craftSkill,CraftingConstants.VILLAGE_SPECIALIZATION,this.m_currentTab,"",sortBy);
         var index:int = 0;
         for each(recipe in recipeData)
         {
            slotData = this.populateRecipeData(recipe,this.m_craftSkill,index);
            m_slotData.push(slotData);
            index++;
         }
      }
      
      override protected function populateSlots(dataIndex:uint = 0) : void
      {
         var i:int = 0;
         clearSlots();
         var slotIdx:uint = 0;
         var slotsLength:int = int(m_slots.length);
         var slotDataLength:int = int(m_slotData.length);
         if(m_slotData)
         {
            while(slotIdx < slotsLength && Boolean(m_slots[slotIdx]))
            {
               for(i = 0; i < slotDataLength; i++)
               {
                  if(Boolean(m_slotData[i]) && m_slotData[i].index == slotIdx)
                  {
                     populateSlot(m_slots[slotIdx] as ZwSlotFrame,m_slotData[i]);
                     break;
                  }
               }
               slotIdx++;
            }
         }
         m_lastPopulateStartIndex = slotIdx;
      }
      
      private function setupIngredientData() : void
      {
         var ingredientsArray:Array = null;
         var ingredientsLength:int = 0;
         var ingredientItem:Object = null;
         var i:int = 0;
         this.m_ingredientSlotData = new Array();
         var newObject:Object = null;
         if(Boolean(this.m_selectedRecipe) && Boolean(this.m_selectedRecipe.ingredients))
         {
            ingredientsArray = this.m_selectedRecipe.ingredients;
            ingredientsLength = int(ingredientsArray.length);
            ingredientItem = new Object();
            for(i = 0; i < ingredientsLength; i++)
            {
               newObject = new Object();
               ingredientItem = ingredientsArray[i];
               if(ingredientItem)
               {
                  newObject.itemCode = ingredientItem.itemCode;
                  newObject.quantityRequired = ingredientItem.quantityRequired;
               }
               newObject.craftType = this.m_selectedRecipe.craft;
               this.m_ingredientSlotData.push(newObject);
            }
         }
      }
      
      private function populateRecipeData(recipeData:Object, craftType:String, index:int) : Object
      {
         var recipeItem:RecipeItem = CraftingManager.getRecipeItemFromId(recipeData.recipeId,craftType);
         recipeData.recipeState = "";
         if(recipeItem)
         {
            recipeData.recipeItem = recipeItem;
            if(!recipeItem.canUnlock)
            {
               recipeData.recipeState = CraftingConstants.RECIPE_STATE_PREREQ_LOCKED;
            }
            else if(recipeItem.canMake)
            {
               recipeData.recipeState = CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS;
            }
            recipeData.index = index;
            recipeData.image = recipeItem.image;
         }
         return recipeData;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      public function get selectedRecipe() : RecipeItem
      {
         return this.m_selectedRecipe;
      }
      
      override protected function getSlotPrefix() : String
      {
         return RESOURCE_BUILDING_RECIPE_SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return RESOURCE_BUILDING_RECIPE_SLOT_POSTFIX;
      }
      
      private function leftArrowButtonCallback(event:MouseEvent = null) : void
      {
         this.adjustArrayToTheLeft();
         this.populateSlots();
         this.updateRecipeSlots();
      }
      
      private function adjustArrayToTheLeft() : void
      {
         var dataLength:int = int(m_slotData.length);
         var slotIndex:int = 0;
         var newIndex:int = 0;
         for(var i:int = 0; i < dataLength; i++)
         {
            if(m_slotData[i])
            {
               slotIndex = int(m_slotData[i].index);
               if(slotIndex == 0)
               {
                  newIndex = 1;
               }
               else if(slotIndex % 2 != 0)
               {
                  newIndex = slotIndex + 2;
               }
               else
               {
                  newIndex = slotIndex - 2;
               }
               if(newIndex > dataLength - 1)
               {
                  if(dataLength % 2 != 0)
                  {
                     newIndex = slotIndex + 1;
                  }
                  else
                  {
                     newIndex = slotIndex - 1;
                  }
               }
               m_slotData[i].index = newIndex;
            }
         }
      }
      
      private function rightArrowButtonCallback(event:MouseEvent = null) : void
      {
         this.adjustArrayToTheRight();
         this.populateSlots();
         this.updateRecipeSlots();
      }
      
      private function adjustArrayToTheRight() : void
      {
         var dataLength:int = int(m_slotData.length);
         var slotIndex:int = 0;
         var newIndex:int = 0;
         for(var i:int = 0; i < dataLength; i++)
         {
            if(m_slotData[i])
            {
               slotIndex = int(m_slotData[i].index);
               if(slotIndex == 1)
               {
                  newIndex = 0;
               }
               else if(slotIndex % 2 != 0)
               {
                  newIndex = slotIndex - 2;
               }
               else
               {
                  newIndex = slotIndex + 2;
               }
               if(newIndex > dataLength - 1)
               {
                  if(dataLength % 2 != 0)
                  {
                     newIndex = slotIndex - 1;
                  }
                  else
                  {
                     newIndex = slotIndex + 1;
                  }
               }
               m_slotData[i].index = newIndex;
            }
         }
      }
      
      public function setCurrentTab(currentTab:String) : void
      {
         this.m_currentTab = currentTab;
      }
      
      public function update() : void
      {
         this.setupData();
         this.updateRecipeSlots();
      }
      
      public function updateRecipeSlots() : void
      {
         this.updateSelectedRecipe();
         this.setupIngredientData();
         if(Boolean(this.m_ingredientsFrame) && Boolean(this.m_ingredientSlotData))
         {
            this.m_ingredientsFrame.setData(this.m_ingredientSlotData);
         }
         if(Boolean(this.m_selectedIngredientNameTextField) && Boolean(this.m_selectedRecipe))
         {
            this.m_selectedIngredientNameTextField.text = this.m_selectedRecipe.friendlyTitle;
         }
         if(this.m_parentWindow)
         {
            this.m_parentWindow.updateMakeOrGetAllButton();
         }
      }
      
      private function updateSelectedRecipe() : void
      {
         var dataLength:int = int(m_slotData.length);
         for(var i:int = 0; i < dataLength; i++)
         {
            if(m_slotData[i].index == 0)
            {
               this.m_selectedRecipe = m_slotData[i].recipeItem;
               break;
            }
         }
      }
      
      public function setSelectedRecipeById(selectedRecipeId:String, currentTabName:String) : void
      {
         var iterateRight:int = 0;
         var iterateLeft:int = 0;
         if(this.m_currentTab != currentTabName)
         {
            this.m_currentTab = currentTabName;
            this.setupData();
         }
         var dataLength:int = int(m_slotData.length);
         var currentIndex:int = 0;
         for(var i:int = 0; i < dataLength; i++)
         {
            if(m_slotData[i].recipeItem.id == selectedRecipeId)
            {
               currentIndex = int(m_slotData[i].index);
               break;
            }
         }
         var isRightDirection:Boolean = currentIndex % 2 != 0;
         var countForAdjust:int = 0;
         if(isRightDirection)
         {
            countForAdjust = Math.floor(currentIndex / 2) + 1;
            for(iterateRight = 0; iterateRight < countForAdjust; iterateRight++)
            {
               this.adjustArrayToTheRight();
            }
         }
         else
         {
            countForAdjust = currentIndex / 2;
            for(iterateLeft = 0; iterateLeft < countForAdjust; iterateLeft++)
            {
               this.adjustArrayToTheLeft();
            }
         }
         this.populateSlots();
         this.updateRecipeSlots();
      }
   }
}

