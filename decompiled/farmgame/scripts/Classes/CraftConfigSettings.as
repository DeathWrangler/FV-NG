package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftLevel;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import Managers.Crafting.CraftingManager;
   import flash.utils.Dictionary;
   
   public class CraftConfigSettings
   {
      
      public static const CRAFT_VERSION_INITIAL:int = 1;
      
      public static const CRAFT_VERSION_CRAFTSHOP:int = 2;
      
      public static const DEFAULT_TAX_RATE:Number = 0.1;
      
      private const MAX_RECIPE_LEVEL:int = 9999;
      
      private var m_xml:XML;
      
      private var m_recipeList:Array = null;
      
      private var m_recipeHash:Object = null;
      
      private var m_recipeMasterySignHash:Object = null;
      
      private var m_craftTypesHash:Object = null;
      
      private var m_recipeLevelsXML:Object = null;
      
      private var m_recipeTypesHash:Dictionary = null;
      
      private var m_craftExpansionsHash:Object = null;
      
      private var m_cottageLevelGate:Number = -1;
      
      private var m_maxCottageLevel:Number = -1;
      
      private var m_finishRewardLevel:Number = -1;
      
      private var m_craftTypes:Array = new Array();
      
      private var m_craftshopbuildables:Array;
      
      private var m_craftshopfinished:Array;
      
      public function CraftConfigSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
         this.init();
      }
      
      public function getCottageLevelGate() : Number
      {
         if(this.m_cottageLevelGate < 0)
         {
            this.m_cottageLevelGate = 25;
         }
         return this.m_cottageLevelGate;
      }
      
      public function getFinishRewardLevel() : Number
      {
         if(this.m_finishRewardLevel < 0)
         {
            this.m_finishRewardLevel = this.m_xml.featureConfig["finishRewardLevel"];
         }
         return this.m_finishRewardLevel;
      }
      
      public function getCottageLevelForSlot(slotIndex:Number) : Number
      {
         var craftLevel:CraftLevel = null;
         var result:Number = -1;
         var maxLevel:Number = this.getMaxCraftLevel();
         for(var i:Number = 1; i <= maxLevel; i++)
         {
            craftLevel = this.getCraftLevel(i);
            if(craftLevel.recipeSlots >= slotIndex)
            {
               result = i;
               break;
            }
         }
         return result;
      }
      
      private function init() : void
      {
         this.initCraftTypesHash(this.m_xml);
         this.initCraftExpansionsHash(this.m_xml);
         this.initRecipeHash(this.m_xml);
      }
      
      public function getItemNamesWithCraftVersion(version:String) : Array
      {
         var craftSkillXml:XML = null;
         var building:XML = null;
         var itemNames:Array = new Array();
         if(this.m_xml)
         {
            for each(craftSkillXml in this.m_xml.craftSkills.craftSkill)
            {
               if(craftSkillXml.hasOwnProperty("@version") && craftSkillXml.@version == version)
               {
                  if(craftSkillXml.hasOwnProperty("cottageBuilding"))
                  {
                     var _loc7_:int = 0;
                     var _loc8_:* = craftSkillXml.cottageBuilding;
                     for each(building in _loc8_)
                     {
                        itemNames.push(building.@name.toString);
                     }
                  }
               }
            }
         }
         return itemNames;
      }
      
      private function initCraftTypesHash(xml:XML) : void
      {
         var craftSkillXml:XML = null;
         var craftId:String = null;
         var specializations:Object = null;
         var specialization:XML = null;
         var specializationId:String = null;
         var ingredientOrder:Array = null;
         var ingredient:XML = null;
         var id:String = null;
         var tabs:Array = null;
         var tab:XML = null;
         var name:String = null;
         var sortOptions:Array = null;
         var sortOption:XML = null;
         var sortObject:Object = null;
         var slotLevels:Array = null;
         var slot:XML = null;
         var slotId:int = 0;
         var recipesToComplete:int = 0;
         this.m_craftTypesHash = new Object();
         if(xml)
         {
            for each(craftSkillXml in xml.craftSkills.craftSkill)
            {
               craftId = craftSkillXml.@id;
               if(craftId)
               {
                  this.m_craftTypes.push(craftId.toString());
                  if(!this.m_craftTypesHash.hasOwnProperty(craftId))
                  {
                     this.m_craftTypesHash[craftId] = new Object();
                  }
                  if(craftSkillXml.hasOwnProperty("craftingBGStyle"))
                  {
                     this.m_craftTypesHash[craftId]["craftingBGStyle"] = craftSkillXml.craftingBGStyle.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("recipeFrame"))
                  {
                     this.m_craftTypesHash[craftId]["recipeFrame"] = craftSkillXml.recipeFrame.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("recipeSlotIcon"))
                  {
                     this.m_craftTypesHash[craftId]["recipeSlotIcon"] = craftSkillXml.recipeSlotIcon.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("recipeQueueClass"))
                  {
                     this.m_craftTypesHash[craftId]["recipeQueueClass"] = craftSkillXml.recipeQueueClass.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("recipeLevels"))
                  {
                     this.m_craftTypesHash[craftId]["recipeLevels"] = craftSkillXml.recipeLevels;
                  }
                  if(craftSkillXml.hasOwnProperty("specializations"))
                  {
                     specializations = new Object();
                     for each(specialization in craftSkillXml.specializations.specialization)
                     {
                        specializationId = specialization.@id;
                        specializations[specializationId] = new Array();
                     }
                     this.m_craftTypesHash[craftId]["specializations"] = specializations;
                  }
                  if(craftSkillXml.hasOwnProperty("askForHelpWithBushelsBundle"))
                  {
                     this.m_craftTypesHash[craftId]["askForHelpWithBushelsBundle"] = craftSkillXml.askForHelpWithBushelsBundle.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("askForHelpWithBushelsUseItemForFeedImage"))
                  {
                     this.m_craftTypesHash[craftId]["askForHelpWithBushelsUseItemForFeedImage"] = craftSkillXml.askForHelpWithBushelsUseItemForFeedImage.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("thankYouFeedBundle"))
                  {
                     this.m_craftTypesHash[craftId]["thankYouFeedBundle"] = craftSkillXml.thankYouFeedBundle.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("addCrewFeedBundle"))
                  {
                     this.m_craftTypesHash[craftId]["addCrewFeedBundle"] = craftSkillXml.addCrewFeedBundle.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("addCrewFeedIcon"))
                  {
                     this.m_craftTypesHash[craftId]["addCrewFeedIcon"] = craftSkillXml.addCrewFeedIcon.toString();
                  }
                  if(craftSkillXml.hasOwnProperty("ingredientOrder"))
                  {
                     ingredientOrder = new Array();
                     for each(ingredient in craftSkillXml.ingredientOrder.ingredient)
                     {
                        id = ingredient.@id;
                        ingredientOrder.push(id);
                     }
                     this.m_craftTypesHash[craftId]["ingredientOrder"] = ingredientOrder;
                  }
                  if(craftSkillXml.hasOwnProperty("tabs"))
                  {
                     tabs = new Array();
                     for each(tab in craftSkillXml.tabs.tab)
                     {
                        name = tab.@name;
                        tabs.push(name);
                     }
                     this.m_craftTypesHash[craftId]["tabs"] = tabs;
                  }
                  if(craftSkillXml.hasOwnProperty("sortOptions"))
                  {
                     sortOptions = new Array();
                     for each(sortOption in craftSkillXml.sortOptions.sort)
                     {
                        sortObject = {
                           "name":sortOption.@name,
                           "direction":sortOption.@direction
                        };
                        sortOptions.push(sortObject);
                     }
                     this.m_craftTypesHash[craftId]["sortOptions"] = sortOptions;
                  }
                  if(craftSkillXml.hasOwnProperty("slotLevels"))
                  {
                     slotLevels = new Array();
                     for each(slot in craftSkillXml.slotLevels.slot)
                     {
                        slotId = int(slot.@id);
                        recipesToComplete = int(slot.@recipesToComplete);
                        slotLevels.push({
                           "id":slotId,
                           "recipesToComplete":recipesToComplete
                        });
                     }
                     this.m_craftTypesHash[craftId]["slotLevels"] = slotLevels;
                  }
                  if(craftSkillXml.hasOwnProperty("smartSystemTuningTable"))
                  {
                     this.m_craftTypesHash[craftId]["smartSystemTuningTable"] = craftSkillXml.smartSystemTuningTable.toString();
                  }
               }
            }
         }
      }
      
      private function initCraftExpansionsHash(xml:XML) : void
      {
         var expansionXml:XML = null;
         var craftId:String = null;
         this.m_craftExpansionsHash = new Object();
         if(xml)
         {
            for each(expansionXml in xml.craftExpansions.craftExpansion)
            {
               craftId = expansionXml.@id;
               if(craftId)
               {
                  if(!this.m_craftExpansionsHash.hasOwnProperty(craftId))
                  {
                     this.m_craftExpansionsHash[craftId] = new Object();
                  }
                  if(expansionXml.hasOwnProperty("askForHelpWithBushelsBundle"))
                  {
                     this.m_craftExpansionsHash[craftId]["askForHelpWithBushelsBundle"] = expansionXml.askForHelpWithBushelsBundle.toString();
                  }
                  if(expansionXml.hasOwnProperty("askForHelpWithBushelsUseItemForFeedImage"))
                  {
                     this.m_craftExpansionsHash[craftId]["askForHelpWithBushelsUseItemForFeedImage"] = expansionXml.askForHelpWithBushelsUseItemForFeedImage.toString();
                  }
               }
            }
         }
      }
      
      private function initRecipeHash(xml:XML) : void
      {
         var recipe:XML = null;
         var id:String = null;
         var recipeItem:RecipeItem = null;
         var specId:String = null;
         var craft:String = null;
         var recipeType:String = null;
         this.m_recipeHash = new Object();
         this.m_recipeList = new Array();
         this.m_recipeMasterySignHash = new Object();
         this.m_recipeLevelsXML = new Object();
         this.m_recipeTypesHash = new Dictionary();
         if(xml)
         {
            for each(recipe in xml.descendants("CraftingRecipe"))
            {
               id = recipe.@id;
               if(id)
               {
                  this.m_recipeLevelsXML[id] = recipe;
               }
               if(this.isValidRecipe(recipe))
               {
                  recipeItem = RecipeItem.fromXML(recipe);
                  this.m_recipeHash[id] = recipeItem;
                  specId = recipeItem.specialization;
                  if(specId)
                  {
                     craft = recipeItem.craft;
                     if(this.m_craftTypesHash[craft]["specializations"].hasOwnProperty(specId))
                     {
                        this.m_craftTypesHash[craft]["specializations"][specId].push(id);
                     }
                     recipeType = recipeItem.recipeType;
                     if(recipeType)
                     {
                        if(!this.m_recipeTypesHash.hasOwnProperty(craft))
                        {
                           this.m_recipeTypesHash[craft] = new Dictionary();
                        }
                        if(!this.m_recipeTypesHash[craft].hasOwnProperty(specId))
                        {
                           this.m_recipeTypesHash[craft][specId] = new Dictionary();
                        }
                        if(!this.m_recipeTypesHash[craft][specId].hasOwnProperty(recipeType))
                        {
                           this.m_recipeTypesHash[craft][specId][recipeType] = new Array();
                        }
                        if(!this.m_recipeTypesHash[craft][specId].hasOwnProperty("all"))
                        {
                           this.m_recipeTypesHash[craft][specId]["all"] = new Array();
                        }
                        this.m_recipeTypesHash[craft][specId][recipeType].push({"recipeId":id});
                        this.m_recipeTypesHash[craft][specId]["all"].push({"recipeId":id});
                     }
                  }
                  if(recipeItem.masterySignCode)
                  {
                     this.m_recipeMasterySignHash[recipeItem.masterySignCode] = recipeItem;
                  }
                  this.m_recipeList.push(recipeItem);
               }
            }
         }
      }
      
      public function getSlotLevelsByType(craftType:String) : Array
      {
         return this.m_craftTypesHash[craftType]["slotLevels"];
      }
      
      public function getAllRecipeIds(craft:String = null) : Array
      {
         var recipe:RecipeItem = null;
         if(this.m_recipeHash == null)
         {
            this.init();
         }
         var result:Array = new Array();
         for(var i:int = 0; i < this.m_recipeList.length; i++)
         {
            recipe = this.m_recipeList[i];
            if((craft == null || recipe.craft == craft) && recipe.isPlayerEligible())
            {
               result.push(recipe.id);
            }
         }
         return result;
      }
      
      public function getAllRecipes(craft:String = null, craftLevel:int = 0, sortRequired:Boolean = true, sortLockedByLevel:Boolean = false) : Array
      {
         var i:int = 0;
         var recipe:RecipeItem = null;
         if(this.m_recipeList == null)
         {
            this.init();
         }
         var result:Array = new Array();
         if(craft != null)
         {
            for(i = 0; i < this.m_recipeList.length; i++)
            {
               recipe = this.m_recipeList[i];
               if(recipe.craft == craft && recipe.isPlayerEligible())
               {
                  if(craftLevel == 0 || recipe.skillLevelRequired <= craftLevel && recipe.isLimitedValid())
                  {
                     result.push(recipe);
                  }
               }
            }
         }
         else
         {
            result = this.m_recipeList;
         }
         if(sortRequired)
         {
            if(!Global.player.getSeenFlag("craftTutDone"))
            {
               if(sortLockedByLevel)
               {
                  result = this.sortByLevelOnLocked(result);
               }
               else
               {
                  result = this.sortByRecipesNeeded(result);
               }
            }
            else
            {
               result = this.sortLERecipes(result);
            }
         }
         return result;
      }
      
      public function getRecipeTypesHash() : Dictionary
      {
         return this.m_recipeTypesHash;
      }
      
      private function sortByRecipesNeeded(arrayIn:Array) : Array
      {
         var recipe:RecipeItem = null;
         var i:* = 0;
         var arrayOut:Array = [];
         var ignoreDirtyFlag:Boolean = false;
         for(i = int(arrayIn.length - 1); i >= 0; i--)
         {
            recipe = arrayIn[i];
            arrayOut.push({
               "needed":this.getIngredientsNeeded(recipe,ignoreDirtyFlag),
               "recipe":recipe
            });
            ignoreDirtyFlag = true;
         }
         arrayOut.sortOn("needed",Array.NUMERIC);
         for(i = int(arrayOut.length - 1); i >= 0; i--)
         {
            arrayOut[i] = arrayOut[i].recipe;
         }
         return arrayOut;
      }
      
      private function sortByLevelOnLocked(arrayIn:Array) : Array
      {
         var recipe:RecipeItem = null;
         var i:int = 0;
         var arrayOut:Array = [];
         var lockedRecipeArray:Array = [];
         var unlockedRecipeArray:Array = [];
         for(i = 0; i < arrayIn.length; i++)
         {
            recipe = arrayIn[i];
            if(CraftingManager.getInstance().isRecipeLocked(recipe.id) != 0)
            {
               lockedRecipeArray.push(arrayIn[i]);
            }
            else
            {
               unlockedRecipeArray.push(arrayIn[i]);
            }
         }
         unlockedRecipeArray = this.sortByRecipesNeeded(unlockedRecipeArray);
         lockedRecipeArray = this.sortByCraftLevel(lockedRecipeArray);
         return unlockedRecipeArray.concat(lockedRecipeArray);
      }
      
      private function sortByCraftLevel(arrayIn:Array) : Array
      {
         var recipe:RecipeItem = null;
         var i:* = 0;
         var arrayOut:Array = [];
         for(i = int(arrayIn.length - 1); i >= 0; i--)
         {
            recipe = arrayIn[i];
            arrayOut.push({
               "level":recipe.skillLevelRequired,
               "recipe":recipe
            });
         }
         arrayOut.sortOn("level",Array.NUMERIC);
         for(i = int(arrayOut.length - 1); i >= 0; i--)
         {
            arrayOut[i] = arrayOut[i].recipe;
         }
         return arrayOut;
      }
      
      private function sortLERecipes(arrayIn:Array) : Array
      {
         var recipeA:RecipeItem = null;
         var recipeB:RecipeItem = null;
         var i:Number = NaN;
         var recipeC:RecipeItem = null;
         var leRecipes:Array = [];
         var leRecipesOut:Array = [];
         var regularRecipes:Array = [];
         var limitedEndTimestamp1:Number = 0;
         var limitedEndTimestamp2:Number = 0;
         for each(recipeA in arrayIn)
         {
            if(recipeA.isLimited)
            {
               leRecipes.push(recipeA);
            }
            else
            {
               regularRecipes.push(recipeA);
            }
         }
         for each(recipeB in leRecipes)
         {
            if(leRecipesOut.length == 0)
            {
               leRecipesOut.push(recipeB);
            }
            else
            {
               limitedEndTimestamp1 = FarmGameUtil.synchronizedDateToNumber(recipeB.limitedEndDate);
               for(i = 0; i < leRecipesOut.length; i++)
               {
                  recipeC = leRecipesOut[i];
                  limitedEndTimestamp2 = FarmGameUtil.synchronizedDateToNumber(recipeC.limitedEndDate);
                  if(limitedEndTimestamp1 < limitedEndTimestamp2)
                  {
                     leRecipesOut.splice(i,0,recipeB);
                     break;
                  }
                  if(i == leRecipesOut.length - 1)
                  {
                     leRecipesOut.push(recipeB);
                     break;
                  }
               }
            }
         }
         return leRecipesOut.concat(regularRecipes);
      }
      
      public function getIngredientsNeeded(recipe:RecipeItem, ignoreDirtyFlag:Boolean = false) : int
      {
         var ingredientItem:FarmItem = null;
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         var ingredient:Object = null;
         var result:int = 0;
         for each(ingredient in recipe.ingredients)
         {
            ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
            numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(ingredient.itemCode,ignoreDirtyFlag);
            quantityRequired = int(ingredient.quantityRequired);
            result += Math.max(0,quantityRequired - numIngredients);
         }
         if(CraftingManager.getInstance().isRecipeLocked(recipe.id) != 0)
         {
            result += 10000;
         }
         return result;
      }
      
      public function getRecipeById(id:String) : RecipeItem
      {
         if(this.m_recipeHash == null)
         {
            this.init();
         }
         return this.m_recipeHash.hasOwnProperty(id) ? this.m_recipeHash[id] : null;
      }
      
      public function getRecipeByMasterySign(sign:String) : RecipeItem
      {
         if(this.m_recipeMasterySignHash == null)
         {
            this.init();
         }
         return this.m_recipeMasterySignHash.hasOwnProperty(sign) ? this.m_recipeMasterySignHash[sign] : null;
      }
      
      public function getRecipeXml(id:String) : XML
      {
         return this.getRecipeXMLFromCachedXML(id);
      }
      
      private function getRecipeXMLFromCachedXML(id:String) : XML
      {
         if(!this.m_recipeLevelsXML)
         {
            this.initRecipeHash(this.m_xml);
         }
         return Boolean(this.m_recipeLevelsXML) && this.m_recipeLevelsXML.hasOwnProperty(id) ? this.m_recipeLevelsXML[id] : this.getRecipeXMLFromRawXML(id);
      }
      
      private function getRecipeXMLFromRawXML(id:String) : XML
      {
         var recipe:XML = null;
         var result:XML = null;
         for each(recipe in this.m_xml.descendants("CraftingRecipe"))
         {
            if(id == recipe.@id)
            {
               result = recipe;
            }
         }
         return result;
      }
      
      public function getRecipeByProductItemCode(itemCode:String) : RecipeItem
      {
         var recipe:RecipeItem = null;
         var errorMessage:String = null;
         var result:RecipeItem = null;
         if(this.m_recipeHash == null)
         {
            this.init();
         }
         for each(recipe in this.m_recipeHash)
         {
            if(recipe.productItemCode == itemCode)
            {
               result = recipe;
               break;
            }
         }
         if(!result)
         {
            errorMessage = "CraftConfigSettings.getRecipeByProductItemCode - Could not find recipe.";
            errorMessage += ",itemCode=" + itemCode;
            ErrorManager.addError(errorMessage);
         }
         return result;
      }
      
      public function getSpecializations(craftType:String) : Array
      {
         var specId:String = null;
         var result:Array = new Array();
         if(this.m_craftTypesHash[craftType] != null && Boolean(this.m_craftTypesHash[craftType].hasOwnProperty("specializations")))
         {
            for(specId in this.m_craftTypesHash[craftType]["specializations"])
            {
               result.push(specId);
            }
         }
         return result;
      }
      
      public function getAskForBushelsBundle(craftType:String) : String
      {
         var result:String = "AskForHelpWithBushels";
         var key:String = "askForHelpWithBushelsBundle";
         var hash:Object = this.m_craftTypesHash;
         if(this.m_craftExpansionsHash[craftType] != null)
         {
            hash = this.m_craftExpansionsHash;
         }
         if(hash[craftType].hasOwnProperty(key))
         {
            result = hash[craftType][key];
         }
         return result;
      }
      
      public function getSmartSystemTuningTable(craftType:String) : String
      {
         var result:String = "";
         var key:String = "smartSystemTuningTable";
         var hash:Object = this.m_craftTypesHash;
         if(hash[craftType].hasOwnProperty(key))
         {
            result = hash[craftType][key];
         }
         return result;
      }
      
      public function getCraftSkillDataForKey(craftType:String, key:String) : Array
      {
         var result:Array = new Array();
         var hash:Object = this.m_craftTypesHash;
         if(this.m_craftExpansionsHash[craftType] != null)
         {
            hash = this.m_craftExpansionsHash;
         }
         if(hash[craftType].hasOwnProperty(key))
         {
            result = hash[craftType][key];
         }
         return result;
      }
      
      public function getAskForHelpWithBushelsUseItemForFeedImage(craftType:String) : Boolean
      {
         var result:Boolean = false;
         var key:String = "askForHelpWithBushelsUseItemForFeedImage";
         var hash:Object = this.m_craftTypesHash;
         if(this.m_craftExpansionsHash[craftType] != null)
         {
            hash = this.m_craftExpansionsHash;
         }
         if(hash[craftType].hasOwnProperty(key))
         {
            result = hash[craftType][key] == "true";
         }
         return result;
      }
      
      public function getThankYouFeedBundle(craftType:String) : String
      {
         var result:String = "CraftingThankYou";
         if(this.m_craftTypesHash[craftType].hasOwnProperty("thankYouFeedBundle"))
         {
            result = this.m_craftTypesHash[craftType]["thankYouFeedBundle"];
         }
         return result;
      }
      
      public function getAddCrewFeedBundle(craftType:String) : String
      {
         var result:String = "CraftingAddHelper";
         if(this.m_craftTypesHash[craftType].hasOwnProperty("addCrewFeedBundle"))
         {
            result = this.m_craftTypesHash[craftType]["addCrewFeedBundle"];
         }
         return result;
      }
      
      public function getAddCrewFeedIcon(craftType:String) : String
      {
         var result:String = null;
         if(this.m_craftTypesHash[craftType].hasOwnProperty("addCrewFeedIcon"))
         {
            result = this.m_craftTypesHash[craftType]["addCrewFeedIcon"];
         }
         return result;
      }
      
      public function getRecipeIdsForSpecialization(craftType:String, specializationId:String) : Array
      {
         var result:Array = null;
         if(Boolean(this.m_craftTypesHash[craftType].hasOwnProperty("specializations")) && Boolean(this.m_craftTypesHash[craftType]["specializations"].hasOwnProperty(specializationId)))
         {
            result = this.m_craftTypesHash[craftType]["specializations"][specializationId];
         }
         else
         {
            result = new Array();
         }
         return result;
      }
      
      public function getMaxCraftLevel() : int
      {
         var maxLevel:int = 0;
         var levelXml:XML = null;
         if(this.m_maxCottageLevel < 0)
         {
            maxLevel = 1;
            if(this.m_xml.craftTypeLevels.level)
            {
               for each(levelXml in this.m_xml.craftTypeLevels.level)
               {
                  if(levelXml.@num > maxLevel)
                  {
                     maxLevel = int(levelXml.@num);
                  }
               }
            }
            this.m_maxCottageLevel = maxLevel;
         }
         return this.m_maxCottageLevel;
      }
      
      private function getRecipeLevels(recipeId:String) : XMLList
      {
         var craftType:String = null;
         var craftTypeObj:Object = null;
         var recipeLevelsXml:XMLList = null;
         var recipeXml:XML = this.getRecipeXml(recipeId);
         if(recipeXml)
         {
            if(recipeXml.hasOwnProperty("recipeLevels"))
            {
               recipeLevelsXml = recipeXml.recipeLevels.level;
            }
         }
         if(!recipeLevelsXml)
         {
            craftType = recipeXml["craft"];
            craftTypeObj = this.m_craftTypesHash[craftType];
            if(Boolean(craftTypeObj) && craftTypeObj.hasOwnProperty("recipeLevels"))
            {
               recipeLevelsXml = craftTypeObj["recipeLevels"].level;
            }
            if(!recipeLevelsXml && this.m_xml.hasOwnProperty("recipeLevels"))
            {
               recipeLevelsXml = this.m_xml.recipeLevels.level;
            }
         }
         return recipeLevelsXml;
      }
      
      public function getMaxRecipeLevel(recipeId:String) : Number
      {
         var levelXml:XML = null;
         var levelNum:int = 0;
         var maxLevel:int = -1;
         var recipeLevelsXml:XMLList = this.getRecipeLevels(recipeId);
         for each(levelXml in recipeLevelsXml)
         {
            if(levelXml.@num != "max")
            {
               levelNum = int(levelXml.@num);
               if(levelNum > maxLevel)
               {
                  maxLevel = levelNum;
               }
            }
            else if(levelXml.@xp != 0)
            {
               maxLevel = this.MAX_RECIPE_LEVEL;
            }
         }
         if(maxLevel < 0)
         {
            maxLevel = this.MAX_RECIPE_LEVEL;
         }
         return maxLevel;
      }
      
      public function getCottageItemNameForSkill(skill:String) : String
      {
         var skillXml:XML = null;
         var building:XML = null;
         var cottageName:String = null;
         for each(skillXml in this.m_xml.craftSkills.craftSkill)
         {
            if(skillXml.@id == skill)
            {
               var _loc7_:int = 0;
               var _loc8_:* = skillXml.cottageBuilding;
               for each(building in _loc8_)
               {
                  cottageName = building.@name.toString();
               }
               break;
            }
         }
         return cottageName;
      }
      
      public function getCottageItemForSkill(skill:String) : FarmItem
      {
         var item:FarmItem = null;
         var itemName:String = this.getCottageItemNameForSkill(skill);
         if(itemName != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         return item;
      }
      
      public function getCraftVersion(craftType:String) : int
      {
         var version:int = 0;
         var craftSkill:Object = null;
         version = CRAFT_VERSION_INITIAL;
         craftSkill = this.m_xml.craftSkills.craftSkill.(@id == craftType);
         if(craftSkill.hasOwnProperty("@version"))
         {
            version = int(craftSkill.@version);
         }
         return version;
      }
      
      public function getCraftLevel(level:int, craftType:String = "") : CraftLevel
      {
         var craftLevel:CraftLevel = null;
         var craftSkillXml:XMLList = null;
         var levels:XMLList = null;
         craftLevel = null;
         craftSkillXml = this.m_xml.craftSkills.craftSkill.(@id == craftType).craftTypeLevels;
         if(craftType != "" && Boolean(craftSkillXml.length()))
         {
            if(craftSkillXml.level)
            {
               levels = craftSkillXml.level.(@num == level);
               if(levels.length())
               {
                  craftLevel = new CraftLevel(levels[0]);
               }
            }
         }
         else if(this.m_xml.craftTypeLevels.level)
         {
            levels = this.m_xml.craftTypeLevels.level.(@num == level);
            if(levels.length())
            {
               craftLevel = new CraftLevel(levels[0]);
            }
         }
         return craftLevel;
      }
      
      public function getTutorialAssetPath(craftType:String) : String
      {
         var tutorialAssetPath:String = null;
         var craftSkillXml:XMLList = null;
         tutorialAssetPath = "";
         craftSkillXml = this.m_xml.craftSkills.craftSkill.(@id == craftType);
         if(craftType != "" && Boolean(craftSkillXml.length()))
         {
            if(craftSkillXml.tutorialAssetPath)
            {
               tutorialAssetPath = craftSkillXml.tutorialAssetPath.toString();
            }
         }
         return tutorialAssetPath;
      }
      
      public function getXpIncForRecipeLevel(level:int, recipeId:String) : int
      {
         var maxXp:int = 0;
         var levelXml:XML = null;
         var errorMessage:String = null;
         var xp:int = -1;
         var recipeLevelsXml:XMLList = this.getRecipeLevels(recipeId);
         if(recipeLevelsXml)
         {
            maxXp = -1;
            for each(levelXml in recipeLevelsXml)
            {
               if(levelXml.@num == level)
               {
                  xp = int(levelXml.@xp);
                  break;
               }
               if(levelXml.@num == "max")
               {
                  maxXp = int(levelXml.@xp);
               }
            }
            if(xp < 0 && maxXp >= 0)
            {
               xp = maxXp;
            }
         }
         if(xp < 0)
         {
            errorMessage = "CraftConfigSettings.getXpIncForRecipeLevel - Could not get xp reward.";
            errorMessage += ",level=" + level;
            errorMessage += ",recipeId=" + recipeId;
            ErrorManager.addError(errorMessage);
         }
         return xp;
      }
      
      public function getFuelRewardForGood(level:Number, recipeItem:RecipeItem) : Number
      {
         var recipeLevelsXml:XMLList = null;
         var maxFuel:Number = NaN;
         var levelXml:XML = null;
         var errorMessage:String = null;
         var fuel:Number = -1;
         if(recipeItem != null)
         {
            recipeLevelsXml = this.getRecipeLevels(recipeItem.id);
            if(recipeLevelsXml)
            {
               maxFuel = -1;
               for each(levelXml in recipeLevelsXml)
               {
                  if(Boolean(levelXml) && Boolean(levelXml.hasOwnProperty("@num")) && levelXml.hasOwnProperty("@fuel"))
                  {
                     if(levelXml.@num == level)
                     {
                        fuel = Number(levelXml.@fuel);
                        break;
                     }
                     if(levelXml.@num == "max")
                     {
                        maxFuel = Number(levelXml.@fuel);
                     }
                  }
               }
               if(fuel < 0 && maxFuel >= 0)
               {
                  fuel = maxFuel;
               }
               if(fuel < 0)
               {
                  fuel = 0;
               }
               fuel *= recipeItem.onUseFuelMultiplier;
            }
         }
         if(fuel < 0)
         {
            errorMessage = "CraftConfigSettings.getFuelRewardForGood - Could not get fuel reward.";
            errorMessage += ",level=" + level;
            errorMessage += ",recipeId=" + (recipeItem ? recipeItem.id : "");
            ErrorManager.addError(errorMessage);
         }
         return fuel;
      }
      
      public function isValidRecipe(recipeConfig:XML) : Boolean
      {
         return Boolean(recipeConfig) && recipeConfig.hasOwnProperty("@id") && recipeConfig.hasOwnProperty("craft") && recipeConfig.hasOwnProperty("Ingredients");
      }
      
      public function getBonusRecipe(craftType:String) : RecipeItem
      {
         var bonusRecipeXML:XML = null;
         var recipeItem:RecipeItem = null;
         var serverTime:Number = NaN;
         var bonusRecipeId:String = this.m_xml.craftSkills.craftSkill.(@id == craftType).defaultRecipe[0];
         bonusRecipeXML = this.m_xml.recipes.CraftingRecipe.(@id == bonusRecipeId)[0].copy();
         bonusRecipeXML.MinutesToCook = 0.1;
         recipeItem = RecipeItem.fromXML(bonusRecipeXML);
         serverTime = Global.world == null ? 0 : Global.worldTime;
         serverTime = Math.floor(serverTime / 1000);
         recipeItem.overrideStartState(1,serverTime + 5);
         return recipeItem;
      }
      
      public function getTutorialRecipeItem(craftType:String) : FarmItem
      {
         var recipeId:String = null;
         recipeId = this.m_xml.craftSkills.craftSkill.(@id == craftType).tutorialRecipe[0];
         return Global.farmGameSettingsManager.getFarmItemByCode(recipeId);
      }
      
      public function getTutorialBushelItem(craftType:String) : FarmItem
      {
         var bushelId:String = null;
         bushelId = this.m_xml.craftSkills.craftSkill.(@id == craftType).tutorialBushel[0];
         return Global.farmGameSettingsManager.getFarmItemByCode(bushelId);
      }
      
      public function getDefaultReward(craftType:String, rewardLevel:String) : Object
      {
         var rewardObject:Object = null;
         var rewardXML:XMLList = null;
         rewardObject = null;
         rewardXML = this.m_xml.craftSkills.craftSkill.(@id == craftType).defaultReward.(@type == rewardLevel);
         if(rewardXML != null)
         {
            rewardObject = new Object();
            rewardObject.item = String(rewardXML.@item);
            rewardObject.quantity = int(rewardXML.@quantity);
            rewardObject.craftedGoodLevel = int(rewardXML.@craftedGoodLevel);
         }
         return rewardObject;
      }
      
      public function getDefaultSellPrice(recipeLevel:Number) : Number
      {
         var basePrice:Number = Number(this.m_xml.priceFormula.basePrice);
         var lvlBonus:Number = Number(this.m_xml.priceFormula.lvlMultiplier);
         var maxPrice:Number = Number(this.m_xml.priceFormula.maxPrice);
         var price:Number = basePrice + lvlBonus * recipeLevel;
         return price > maxPrice ? maxPrice : price;
      }
      
      public function getBushelRequestFeedLimitSeconds() : Number
      {
         return this.m_xml.featureConfig["hoursToGetBushelsFeedReset"] * FarmGameUtil.NUM_SECS_IN_HOUR;
      }
      
      public function getRecipeIngredientRequestFeedLimitSeconds() : Number
      {
         return this.m_xml.featureConfig["hoursToGetRecipeIngredientFeedReset"] * FarmGameUtil.NUM_SECS_IN_HOUR;
      }
      
      public function get v2FeatureReleaseDate() : Date
      {
         var dateStr:String = String(this.m_xml.featureConfig["ui2_featuredate"]);
         var dateParts:Array = dateStr.split("-");
         return new Date(Number(dateParts[0]),Number(dateParts[1]) - 1,Number(dateParts[2]));
      }
      
      public function get taxRate() : Number
      {
         var result:Number = DEFAULT_TAX_RATE;
         if(this.m_xml.featureConfig.hasOwnProperty("taxRate"))
         {
            result = Number(this.m_xml.featureConfig["taxRate"]);
         }
         return result;
      }
      
      public function getCraftingBackgroundStyle(craftType:String) : String
      {
         var result:String = "";
         var craftTypeData:Object = this.getCraftingTypeData(craftType);
         if(Boolean(craftTypeData) && craftTypeData.hasOwnProperty("recipeFrame"))
         {
            result = craftTypeData.craftingBGStyle;
         }
         return result;
      }
      
      public function getCraftingBackgroundImage(craftType:String) : String
      {
         var result:String = "";
         var craftTypeData:Object = this.getCraftingTypeData(craftType);
         if(Boolean(craftTypeData) && craftTypeData.hasOwnProperty("recipeFrame"))
         {
            result = craftTypeData.recipeFrame;
         }
         return result;
      }
      
      public function getCraftingSlotIcon(craftType:String) : String
      {
         var result:String = "";
         var craftTypeData:Object = this.getCraftingTypeData(craftType);
         if(Boolean(craftTypeData) && craftTypeData.hasOwnProperty("recipeSlotIcon"))
         {
            result = craftTypeData.recipeSlotIcon;
         }
         return result;
      }
      
      public function getRecipeQueueClass(craftType:String) : String
      {
         var result:String = "";
         var craftTypeData:Object = this.getCraftingTypeData(craftType);
         if(Boolean(craftTypeData) && craftTypeData.hasOwnProperty("recipeQueueClass"))
         {
            result = craftTypeData.recipeQueueClass;
         }
         return result;
      }
      
      private function getCraftingTypeData(craftType:String) : Object
      {
         var result:Object = null;
         if(Boolean(this.m_craftTypesHash) && this.m_craftTypesHash.hasOwnProperty(craftType))
         {
            result = this.m_craftTypesHash[craftType];
         }
         return result;
      }
      
      public function getAllCraftTypes() : Array
      {
         return this.m_craftTypes;
      }
      
      public function getFeatureParam(key:String) : String
      {
         var result:String = "";
         if(this.m_xml.featureConfig.hasOwnProperty(key))
         {
            result = this.m_xml.featureConfig[key];
         }
         return result;
      }
      
      public function getCraftingWorkshopBuildable() : Array
      {
         var building:String = null;
         if(this.m_craftshopbuildables == null)
         {
            this.m_craftshopbuildables = [];
            if(this.m_xml.featureConfig.hasOwnProperty("buildingNameCraftingWorkshopBuildable"))
            {
               for each(building in this.m_xml.featureConfig["buildingNameCraftingWorkshopBuildable"]["buildingName"])
               {
                  this.m_craftshopbuildables.push(building);
               }
            }
         }
         return this.m_craftshopbuildables;
      }
      
      public function getCraftingWorkshopFinished() : Array
      {
         var building:String = null;
         if(this.m_craftshopfinished == null)
         {
            this.m_craftshopfinished = [];
            if(this.m_xml.featureConfig.hasOwnProperty("buildingNameCraftingWorkshopFinished"))
            {
               for each(building in this.m_xml.featureConfig["buildingNameCraftingWorkshopFinished"]["buildingName"])
               {
                  this.m_craftshopfinished.push(building);
               }
            }
         }
         return this.m_craftshopfinished;
      }
   }
}

