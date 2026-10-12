package Classes.crafting
{
   import Classes.*;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   
   public class RecipeItem
   {
      
      public static const QUANTITY_REQUIRED:String = "quantityRequired";
      
      public static const ITEM_CODE:String = "itemCode";
      
      public static const GET_BY_FEED:String = "getByFeed";
      
      public static const SWAPPABLE:String = "swappable";
      
      public static const REWARDS_MODERN:String = "rewardsModern";
      
      protected static const INVALID_VALUE:int = 3735929069;
      
      private static var m_regionImagePrefix:String = "assets/newsfeed/regionIcon45_";
      
      private var m_id:String = "";
      
      private var m_name:String;
      
      private var m_rewardItemCode:String;
      
      private var m_craft:String;
      
      private var m_recipeType:String;
      
      private var m_specialization:String;
      
      private var m_skillLevelRequired:int;
      
      private var m_initialRecipeLevel:int;
      
      private var m_secondsToCook:Number;
      
      private var m_deprecated:int;
      
      private var m_requiredRecipeMastery:int = 0;
      
      private var m_comingSoon:int = 0;
      
      private var m_image:String;
      
      private var m_image70:String;
      
      private var m_rushCostCoins:Number;
      
      private var m_rushCostCash:Number;
      
      private var m_limitedStartDate:String = null;
      
      private var m_limitedEndDate:String = null;
      
      private var m_rewards:Object = {};
      
      private var m_rewardsModern:Object = {};
      
      private var m_worldCurrencyReward:Object = {};
      
      private var m_unlockWithItems:Array = new Array();
      
      private var m_serverStartTS:int = 0;
      
      private var m_serverFinishTS:int = 0;
      
      private var m_ingredients:Array;
      
      private var m_masteryLevels:Array;
      
      private var m_signCode:String;
      
      private var m_serverStarted:Boolean = false;
      
      public var ovenSlot:int = -1;
      
      public var worldType:String = "";
      
      private var m_promptCoOp:Boolean = true;
      
      private var m_prereqsList:XMLList = null;
      
      private var m_prereqsUnlockList:XMLList = null;
      
      private var m_prereqsUnlockListParsed:Array = new Array();
      
      private var m_friendlyTitle:String = "";
      
      private var m_sharedMastery:String = "";
      
      private var m_bushelCountPrice:Boolean = false;
      
      private var m_instantFinishWithTime:Boolean = false;
      
      private var m_recipeOfTheWeek:Boolean = false;
      
      private const CRAFT_MASTERY_BUFF:String = "buff_permanent_mastery_craft";
      
      protected var m_limitedEndTime:Number = -559038227;
      
      private var m_regionSufix:String;
      
      private var m_regionImage:String;
      
      public function RecipeItem()
      {
         super();
      }
      
      public static function fromXML(xml:XML) : RecipeItem
      {
         var rewardXML:XML = null;
         var ingredientXML:XML = null;
         var unlockXML:XML = null;
         var childrensChild:XML = null;
         var childType:String = null;
         var worldCurrencyUnit:String = null;
         var worldCurrencyValue:int = 0;
         var ingredientConfig:Object = null;
         var unlockItemCode:String = null;
         var recipe:RecipeItem = new RecipeItem();
         recipe.m_id = xml.@id;
         recipe.m_name = xml.name;
         recipe.m_craft = xml.craft;
         if(xml.hasOwnProperty("recipeType"))
         {
            recipe.m_recipeType = xml.recipeType;
         }
         if(xml.hasOwnProperty("bushelCountPrice"))
         {
            recipe.m_bushelCountPrice = xml.bushelCountPrice == "true";
         }
         if(xml.hasOwnProperty("instantFinishWithTime"))
         {
            recipe.m_instantFinishWithTime = xml.instantFinishWithTime == "true";
         }
         if(xml.hasOwnProperty("recipeOfTheWeek"))
         {
            recipe.m_recipeOfTheWeek = xml.recipeOfTheWeek == "true";
         }
         recipe.m_rewardItemCode = xml.Reward.OnFinish.@itemCode;
         recipe.m_skillLevelRequired = xml.SkillLevelRequired;
         recipe.m_initialRecipeLevel = xml.InitialRecipeLevel;
         recipe.m_rushCostCoins = xml.RushCostCoins;
         recipe.m_rushCostCash = xml.RushCostCash;
         recipe.m_rewards = {};
         for each(rewardXML in xml.Reward.children())
         {
            recipe.m_rewards[rewardXML.name()] = RecipeReward.fromXML(rewardXML);
            for each(childrensChild in rewardXML.rewards.reward)
            {
               childType = childrensChild.@type;
               recipe.m_rewardsModern[childType] = childrensChild;
               if(childType == CraftingConstants.CRAFTSHOP_WORLD_CURRENCY)
               {
                  worldCurrencyUnit = childrensChild.@unit;
                  worldCurrencyValue = int(childrensChild.@value);
                  recipe.m_worldCurrencyReward["unit"] = worldCurrencyUnit;
                  recipe.m_worldCurrencyReward["value"] = worldCurrencyValue;
               }
            }
         }
         recipe.m_secondsToCook = xml.MinutesToCook * 60;
         recipe.m_deprecated = xml.Deprecated;
         if(xml.hasOwnProperty("ComingSoon"))
         {
            recipe.m_comingSoon = xml.ComingSoon;
         }
         recipe.m_image = xml.image.@url;
         recipe.m_image70 = recipe.m_image.substr(0,recipe.m_image.length - 4) + "70.png";
         recipe.m_ingredients = new Array();
         for each(ingredientXML in xml.Ingredients.descendants("Ingredient"))
         {
            ingredientConfig = {};
            ingredientConfig[ITEM_CODE] = String(ingredientXML.@itemCode);
            ingredientConfig[QUANTITY_REQUIRED] = int(ingredientXML.@quantityRequired);
            if(ingredientXML.@getByFeed == "true")
            {
               ingredientConfig[GET_BY_FEED] = true;
            }
            if(ingredientXML.@swappable == "true")
            {
               ingredientConfig[SWAPPABLE] = true;
            }
            recipe.m_ingredients.push(ingredientConfig);
         }
         for each(unlockXML in xml.unlockWith.descendants("Item"))
         {
            unlockItemCode = unlockXML.@itemCode;
            recipe.m_unlockWithItems.push(unlockItemCode);
         }
         recipe.populateMasteryFromXML(xml);
         if(xml.hasOwnProperty("specialization"))
         {
            recipe.m_specialization = xml.specialization;
         }
         if(xml.hasOwnProperty("limitedStart"))
         {
            recipe.m_limitedStartDate = xml.limitedStart;
         }
         if(xml.hasOwnProperty("limitedEnd"))
         {
            recipe.m_limitedEndDate = xml.limitedEnd;
         }
         if(xml.hasOwnProperty("PromptCoOp"))
         {
            recipe.m_promptCoOp = xml.promptCoOp > 0;
         }
         if(xml.hasOwnProperty("RequiredRecipeMastery"))
         {
            recipe.m_requiredRecipeMastery = xml.RequiredRecipeMastery;
         }
         if(xml.hasOwnProperty("prereqs"))
         {
            recipe.m_prereqsList = xml.prereqs.prereq;
         }
         if(xml.hasOwnProperty("sharedMastery"))
         {
            recipe.m_sharedMastery = xml.sharedMastery;
         }
         if(xml.hasOwnProperty("unlockPrereqs"))
         {
            recipe.m_prereqsUnlockList = xml.unlockPrereqs.prereq;
            recipe.m_prereqsUnlockListParsed = PrerequisiteUtility.parseXmlNodePrereqs(recipe.m_prereqsUnlockList);
         }
         if(xml.hasOwnProperty("RegionSufix"))
         {
            recipe.m_regionSufix = xml.RegionSufix;
            recipe.m_regionImage = m_regionImagePrefix + recipe.craft.substr(0,3) + "_" + recipe.m_regionSufix + ".png";
         }
         return recipe;
      }
      
      public static function fromPhpObject(obj:Object) : RecipeItem
      {
         var rewardType:String = null;
         var ingredient:Object = null;
         var itemCode:String = null;
         var qtyRequired:int = 0;
         var recipe:RecipeItem = new RecipeItem();
         recipe.m_id = obj.id;
         recipe.m_name = obj.recipe.name;
         recipe.m_craft = obj.recipe.craft;
         recipe.m_skillLevelRequired = obj.recipe.SkillLevelRequired;
         recipe.m_initialRecipeLevel = obj.recipeInitialRecipeLevel;
         recipe.m_rushCostCoins = obj.recipe.RushCostCoins;
         recipe.m_rushCostCash = obj.recipe.RushCostCash;
         recipe.ovenSlot = obj.hasOwnProperty("ovenSlot") ? int(obj.ovenSlot) : -1;
         recipe.worldType = obj.hasOwnProperty("worldType") ? obj.worldType : "";
         if(obj.recipe.hasOwnProperty("specialization"))
         {
            recipe.m_specialization = obj.recipe.specialization;
         }
         var defaultRecipe:RecipeItem = Global.craftConfigSettings.getRecipeById(obj.id);
         var useDefaultRewards:Boolean = false;
         recipe.m_rewards = {};
         for(rewardType in obj.recipe.Reward)
         {
            if(obj.recipe.Reward[rewardType].hasOwnProperty("@attributes"))
            {
               recipe.m_rewards[rewardType] = RecipeReward.fromObject(obj.recipe.Reward[rewardType]["@attributes"]);
            }
            else
            {
               useDefaultRewards = true;
            }
         }
         if(useDefaultRewards)
         {
            recipe.m_rewards = defaultRecipe.m_rewards;
         }
         recipe.m_secondsToCook = obj.recipe.MinutesToCook * 60;
         recipe.m_deprecated = obj.recipe.Deprecated;
         if(obj.hasOwnProperty("ComingSoon"))
         {
            recipe.m_comingSoon = obj.recipe.ComingSoon;
         }
         if(obj.recipe.image.hasOwnProperty("@attributes"))
         {
            recipe.m_image = obj.recipe.image["@attributes"].url;
         }
         else
         {
            recipe.m_image = defaultRecipe.m_image;
         }
         recipe.m_ingredients = new Array();
         recipe.m_serverStartTS = obj.hasOwnProperty("start_ts") ? int(obj["start_ts"]) : 0;
         recipe.m_serverFinishTS = obj.hasOwnProperty("finish_ts") ? int(obj["finish_ts"]) : 0;
         recipe.m_serverStarted = recipe.m_serverStartTS > 0 ? true : false;
         var useDefaultIngredients:Boolean = false;
         for each(ingredient in obj.recipe.Ingredients.Ingredient)
         {
            if(ingredient.hasOwnProperty("@attributes"))
            {
               itemCode = ingredient["@attributes"]["itemCode"];
               qtyRequired = int(ingredient["@attributes"]["quantityRequired"]);
               recipe.m_ingredients.push({
                  "itemCode":itemCode,
                  "quantityRequired":qtyRequired
               });
            }
            else
            {
               useDefaultIngredients = true;
            }
         }
         if(useDefaultIngredients)
         {
            recipe.m_ingredients = defaultRecipe.m_ingredients;
         }
         recipe.populateMasteryFromXML(Global.craftConfigSettings.getRecipeXml(recipe.id));
         return recipe;
      }
      
      public function get useBushelCountPrice() : Boolean
      {
         return this.m_bushelCountPrice;
      }
      
      public function get useInstantFinishWithTime() : Boolean
      {
         return this.m_instantFinishWithTime;
      }
      
      public function isRecipeOfTheWeek() : Boolean
      {
         return this.m_recipeOfTheWeek;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyName() : String
      {
         return "Items:" + this.m_name + "_friendlyName";
      }
      
      public function get friendlyTitle() : String
      {
         if(this.m_friendlyTitle == "")
         {
            this.m_friendlyTitle = ZLocUtils.tk_pk_asTitle(this.friendlyName);
         }
         return this.m_friendlyTitle;
      }
      
      public function get craft() : String
      {
         return this.m_craft;
      }
      
      public function get recipeType() : String
      {
         return this.m_recipeType;
      }
      
      public function get unlockWithItems() : Array
      {
         return this.m_unlockWithItems;
      }
      
      public function get rewardItemCode() : String
      {
         return this.m_rewardItemCode;
      }
      
      public function get specialization() : String
      {
         return this.m_specialization;
      }
      
      public function get skillLevelRequired() : int
      {
         return this.m_skillLevelRequired;
      }
      
      public function get initialRecipeLevel() : int
      {
         return this.m_initialRecipeLevel;
      }
      
      public function get requiredRecipeMastery() : int
      {
         return this.m_requiredRecipeMastery;
      }
      
      public function get secondsToCook() : int
      {
         return this.m_secondsToCook;
      }
      
      public function get sharedMastery() : String
      {
         return this.m_sharedMastery;
      }
      
      public function getCookTimeText(timeRemaining:int, locPackage:String = "Crafting", locKeyHoursLeft:String = "CraftingMain_ReadyInHoursMins", locKeyMinutesLeft:String = "CraftingMain_ReadyInMinsSecs", locKeySecondsLeft:String = "CraftingMain_ReadyInSecs") : String
      {
         var hoursRemaining:int = int(timeRemaining / 3600);
         var minutesRemaining:int = int(timeRemaining / 60 % 60);
         var secondsRemaining:int = int(timeRemaining % 60);
         var finishTimeString:String = "";
         if(timeRemaining > 3600)
         {
            finishTimeString = ZLocUtils.t(locPackage,locKeyHoursLeft,{
               "hourNum":hoursRemaining,
               "minuteNum":minutesRemaining
            });
         }
         else if(timeRemaining > 60)
         {
            finishTimeString = ZLocUtils.t(locPackage,locKeyMinutesLeft,{
               "minuteNum":minutesRemaining,
               "secondNum":secondsRemaining
            });
         }
         else
         {
            finishTimeString = ZLocUtils.t(locPackage,locKeySecondsLeft,{"secondNum":secondsRemaining});
         }
         return finishTimeString;
      }
      
      public function get deprecated() : int
      {
         return this.m_deprecated;
      }
      
      public function get comingSoon() : int
      {
         return this.m_comingSoon;
      }
      
      public function get image() : String
      {
         return this.m_image;
      }
      
      public function get image70() : String
      {
         return this.m_image70;
      }
      
      public function get regionSufix() : String
      {
         return this.m_regionSufix;
      }
      
      public function get regionImage() : String
      {
         return this.m_regionImage;
      }
      
      public function get isLimited() : Boolean
      {
         return this.m_limitedStartDate != null && this.m_limitedEndDate != null;
      }
      
      public function get limitedEndTime() : Number
      {
         if(GlobalEngine.isServerTimeValid() && this.m_limitedEndTime == INVALID_VALUE)
         {
            this.m_limitedEndTime = FarmGameUtil.synchronizedDateToNumber(this.limitedEndDate);
         }
         return this.m_limitedEndTime;
      }
      
      public function get limitedTimeLeft() : Number
      {
         return this.limitedEndTime - GlobalEngine.serverTime;
      }
      
      public function isLimitedValid() : Boolean
      {
         var result:Boolean = false;
         if(this.m_limitedStartDate == null && this.m_limitedEndDate == null)
         {
            result = true;
         }
         else if(this.m_limitedStartDate == null)
         {
            result = this.isEndDateValid();
         }
         else if(this.m_limitedEndDate == null)
         {
            result = this.isStartDateValid();
         }
         else
         {
            result = FarmGameUtil.checkDateGate(this.m_limitedStartDate,this.m_limitedEndDate);
         }
         return result;
      }
      
      public function isStartDateValid() : Boolean
      {
         return FarmGameUtil.checkStartDateGate(this.m_limitedStartDate);
      }
      
      public function isEndDateValid() : Boolean
      {
         return FarmGameUtil.checkEndDateGate(this.m_limitedEndDate);
      }
      
      public function isExpiring(bufferTimeMs:Number = 0) : Boolean
      {
         var limitedEndTimestamp:Number = NaN;
         var result:Boolean = false;
         if(this.m_limitedEndDate)
         {
            limitedEndTimestamp = FarmGameUtil.synchronizedDateToNumber(this.m_limitedEndDate);
            if(limitedEndTimestamp - bufferTimeMs < Global.worldTime && this.isLimitedValid())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get limitedStartDate() : String
      {
         return this.m_limitedStartDate;
      }
      
      public function get limitedEndDate() : String
      {
         return this.m_limitedEndDate;
      }
      
      public function getRecipeMasteryRequirement(level:int) : int
      {
         var result:int = 0;
         for(var idx:int = 0; idx < this.m_masteryLevels.length; idx++)
         {
            if(this.m_masteryLevels[idx].level == level)
            {
               result = int(this.m_masteryLevels[idx].count);
               break;
            }
         }
         return result;
      }
      
      public function getRecipeMasteryCoins(level:int) : int
      {
         var result:int = 0;
         for(var idx:int = 0; idx < this.m_masteryLevels.length; idx++)
         {
            if(this.m_masteryLevels[idx].level == level)
            {
               result = int(this.m_masteryLevels[idx].coins);
               break;
            }
         }
         return result;
      }
      
      public function getRecipeMasteryXp(level:int) : int
      {
         var result:int = 0;
         for(var idx:int = 0; idx < this.m_masteryLevels.length; idx++)
         {
            if(this.m_masteryLevels[idx].level == level)
            {
               result = int(this.m_masteryLevels[idx].xp);
               break;
            }
         }
         return result;
      }
      
      public function getMasterySignIcon(level:int) : String
      {
         var result:String = "";
         var sign:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_signCode);
         if(sign)
         {
            result = sign.getImageByName("icon_" + level);
         }
         return result;
      }
      
      public function get canMake() : Boolean
      {
         var totalEarnedMastery:int = 0;
         var result:Boolean = this.isPlayerEligible();
         if(result == true)
         {
            if(CraftingManager.getInstance().shouldUseSmartCrafting(this.craft))
            {
               result = this.meetsIngredientsRequirments();
            }
            else if(this.getNumIngredientsLeft() > 0)
            {
               result = false;
            }
            if(true == result && this.requiredRecipeMastery > 0)
            {
               totalEarnedMastery = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType(this.craft);
               if(totalEarnedMastery < this.requiredRecipeMastery)
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      public function get canUnlock() : Boolean
      {
         var result:Boolean = false;
         var unlockPrereqs:Array = this.unlockPrerequisites;
         if(Boolean(unlockPrereqs) && unlockPrereqs.length > 0)
         {
            result = PrerequisiteUtility.arePrerequisitesMet(unlockPrereqs);
         }
         else if(unlockPrereqs.length == 0)
         {
            result = true;
         }
         return result;
      }
      
      public function usesUnsharableIngredients() : Boolean
      {
         var ingredient:Object = null;
         var itemCode:String = null;
         var item:FarmItem = null;
         var result:Boolean = false;
         for each(ingredient in this.m_ingredients)
         {
            if(ingredient.hasOwnProperty("itemCode") && ingredient["itemCode"] != null)
            {
               itemCode = ingredient["itemCode"];
               item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(item.type == FarmItemType.BUSHEL && item.subType == CraftingManager.CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isRecursiveRecipe() : Boolean
      {
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var result:Boolean = false;
         if(this.m_rewardsModern.hasOwnProperty(QuestConstants.REWARD_GRANT_BUSHEL_ITEM) && this.m_rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM] != null)
         {
            itemCode = this.m_rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM].@value;
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(farmItem.type == FarmItemType.BUSHEL && farmItem.subType == CraftingManager.CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getNumIngredientsLeft(bushelType:String = null) : int
      {
         var newIngredient:Object = null;
         var item:FarmItem = null;
         var quantity:int = 0;
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         for(var ingredIndex:int = 0; ingredIndex < this.ingredients.length; ingredIndex++)
         {
            newIngredient = this.m_ingredients[ingredIndex];
            if(newIngredient)
            {
               numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(newIngredient.itemCode);
               quantityRequired = int(newIngredient.quantityRequired);
               if(quantityRequired > numIngredients)
               {
                  if(bushelType != null)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(newIngredient.itemCode);
                     if(Boolean(item) && bushelType == item.subsubtype)
                     {
                        quantity += quantityRequired - numIngredients;
                     }
                  }
                  else
                  {
                     quantity += quantityRequired - numIngredients;
                  }
               }
            }
         }
         return quantity;
      }
      
      private function meetsIngredientsRequirments() : Boolean
      {
         var ingredientsLength:int = 0;
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         var ingredientIndex:int = 0;
         var newIngredient:Object = null;
         var result:Boolean = true;
         var modifiedRequirements:Array = this.smartModifiedRequirements;
         if(modifiedRequirements.length > 0)
         {
            ingredientsLength = int(modifiedRequirements.length);
            numIngredients = 0;
            quantityRequired = 0;
            for(ingredientIndex = 0; ingredientIndex < ingredientsLength; ingredientIndex++)
            {
               newIngredient = this.m_ingredients[ingredientIndex];
               if(newIngredient)
               {
                  numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(newIngredient.itemCode);
                  quantityRequired = int(modifiedRequirements[ingredientIndex].quantityRequired);
                  if(quantityRequired > numIngredients)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         else
         {
            result = this.getNumIngredientsLeft() == 0;
         }
         return result;
      }
      
      public function get sign() : String
      {
         return this.m_signCode;
      }
      
      public function get onUseItemCode() : String
      {
         return this.m_rewards.hasOwnProperty(CraftingConstants.REWARD_ON_USE) && Boolean(this.m_rewards[CraftingConstants.REWARD_ON_USE].hasOwnProperty("itemCode")) ? this.m_rewards[CraftingConstants.REWARD_ON_USE].itemCode : null;
      }
      
      public function get onUseQuantity() : Number
      {
         return this.m_rewards.hasOwnProperty(CraftingConstants.REWARD_ON_USE) && Boolean(this.m_rewards[CraftingConstants.REWARD_ON_USE].hasOwnProperty("giftQty")) ? Number(this.m_rewards[CraftingConstants.REWARD_ON_USE].giftQty) : 1;
      }
      
      public function get onFinishQuantity() : Number
      {
         return this.m_rewards.hasOwnProperty(CraftingConstants.REWARD_ON_FINISH) && Boolean(this.m_rewards[CraftingConstants.REWARD_ON_FINISH].hasOwnProperty("giftQty")) ? Number(this.m_rewards[CraftingConstants.REWARD_ON_FINISH].giftQty) : 1;
      }
      
      public function get onUseFuelMultiplier() : Number
      {
         return this.m_rewards.hasOwnProperty(CraftingConstants.REWARD_ON_USE) && Boolean(this.m_rewards[CraftingConstants.REWARD_ON_USE].hasOwnProperty("fuel")) ? Number(this.m_rewards[CraftingConstants.REWARD_ON_USE].fuel) : 1;
      }
      
      public function get productItemCode() : String
      {
         return this.m_rewards[CraftingConstants.REWARD_ON_FINISH].itemCode;
      }
      
      public function get productQuantity() : int
      {
         return this.m_rewards[CraftingConstants.REWARD_ON_FINISH].sellQty;
      }
      
      public function get ingredients() : Array
      {
         return this.m_ingredients;
      }
      
      public function get smartModifiedRequirements() : Array
      {
         var smartSystemHelp:int = 0;
         var quantityRequired:int = 0;
         var itemCode:String = null;
         var inventoryQuantity:int = 0;
         var quantityDifference:int = 0;
         var multiplier:Number = NaN;
         var requirement:Object = null;
         var currentRequirements:Array = this.m_ingredients;
         var modifiedRequirements:Array = new Array();
         var smartSystemConfig:SmartSystemData = CraftingManager.getInstance().getSmartSystemConfigByType(this.m_craft);
         if(Boolean(currentRequirements) && Boolean(smartSystemConfig) && smartSystemConfig.hasOwnProperty(SmartSystemData.KEY_SMART_SYSTEM_MULTIPLIER))
         {
            smartSystemHelp = 0;
            quantityRequired = 0;
            itemCode = "";
            inventoryQuantity = 0;
            quantityDifference = 0;
            multiplier = smartSystemConfig.multiplier;
            for each(requirement in currentRequirements)
            {
               quantityRequired = int(requirement.quantityRequired);
               itemCode = requirement.itemCode;
               smartSystemHelp = Math.floor(multiplier * quantityRequired);
               if(smartSystemHelp < quantityRequired)
               {
                  inventoryQuantity = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
                  quantityDifference = quantityRequired - inventoryQuantity;
                  if(quantityDifference <= 0)
                  {
                     smartSystemHelp = 0;
                  }
                  else if(smartSystemHelp > quantityDifference)
                  {
                     smartSystemHelp = quantityDifference;
                  }
               }
               quantityRequired -= smartSystemHelp;
               modifiedRequirements.push({
                  "itemCode":itemCode,
                  "quantityRequired":quantityRequired
               });
            }
         }
         return modifiedRequirements;
      }
      
      public function get serverStartTS() : Number
      {
         return this.m_serverStartTS;
      }
      
      public function get serverFinishTS() : Number
      {
         return this.m_serverFinishTS;
      }
      
      public function get serverStarted() : Boolean
      {
         return this.m_serverStarted;
      }
      
      public function get rewardRecipeXp() : Number
      {
         return this.m_rewards[CraftingConstants.REWARD_ON_MAKE].recipeXp;
      }
      
      public function get rewardPlayerXp() : Number
      {
         return this.m_rewards[CraftingConstants.REWARD_ON_MAKE].playerXp;
      }
      
      public function get rushCostCoins() : Number
      {
         return this.m_rushCostCoins;
      }
      
      public function get rushCostCash() : Number
      {
         return this.m_rushCostCash;
      }
      
      public function get rewards() : Object
      {
         return this.m_rewards;
      }
      
      public function get rewardsModern() : Object
      {
         return this.m_rewardsModern;
      }
      
      public function get worldCurrencyRewards() : Object
      {
         return this.m_worldCurrencyReward;
      }
      
      public function overrideStartState(startTS:Number, endTS:Number) : void
      {
         this.m_serverStartTS = startTS;
         this.m_serverFinishTS = endTS;
         this.m_serverStarted = true;
      }
      
      public function isPlayerEligible() : Boolean
      {
         return PrerequisiteUtility.evalPrereqsXML(this.m_prereqsList);
      }
      
      public function get prerequisites() : Array
      {
         return PrerequisiteUtility.parseXmlNodePrereqs(this.m_prereqsList);
      }
      
      public function get unlockPrerequisites() : Array
      {
         if(!this.m_prereqsUnlockListParsed)
         {
            this.m_prereqsUnlockListParsed = PrerequisiteUtility.parseXmlNodePrereqs(this.m_prereqsUnlockList);
         }
         return this.m_prereqsUnlockListParsed;
      }
      
      protected function populateMasteryFromXML(xml:XML) : void
      {
         var masteryXML:XML = null;
         var level:String = null;
         var qtyReq:int = 0;
         var coins:int = 0;
         var xp:int = 0;
         this.m_masteryLevels = new Array();
         if(xml != null)
         {
            for each(masteryXML in xml.Mastery.descendants("MasteryLevel"))
            {
               level = masteryXML.@level;
               qtyReq = int(masteryXML.@count);
               coins = int(masteryXML.@coins);
               xp = int(masteryXML.@xp);
               this.m_masteryLevels.push({
                  "level":level,
                  "count":qtyReq,
                  "coins":coins,
                  "xp":xp
               });
            }
            this.m_signCode = String(xml.Mastery.@sign);
         }
      }
      
      public function getMasteryLevelForRecipeLevel(goodLevel:int) : int
      {
         var result:int = 0;
         for(var idx:int = 0; idx < this.m_masteryLevels.length; idx++)
         {
            if(this.m_masteryLevels[idx].count > goodLevel)
            {
               break;
            }
            result = int(this.m_masteryLevels[idx].level);
         }
         return result;
      }
      
      public function get masterySignCode() : String
      {
         return this.m_signCode;
      }
      
      public function get isComplete() : Boolean
      {
         return this.m_serverStartTS > 0 && this.timeRemaining <= 0;
      }
      
      public function onRushComplete() : void
      {
         this.m_serverFinishTS = this.m_serverStartTS - 300;
      }
      
      public function get realTimeRemaining() : Number
      {
         var realTime:Number = NaN;
         var result:Number = 0;
         if(!this.m_serverStarted)
         {
            result = this.secondsToCook;
         }
         else
         {
            realTime = GlobalEngine.serverTime;
            realTime = Math.floor(realTime / 1000);
            if(this.m_serverFinishTS > realTime)
            {
               result = this.m_serverFinishTS - realTime;
            }
         }
         return result;
      }
      
      public function get timeRemaining() : Number
      {
         var worldTime:Number = NaN;
         var result:Number = 0;
         if(!this.m_serverStarted)
         {
            result = this.secondsToCook;
         }
         else if(Global.flashHotParams["FARM104370_FIX_ENABLED"])
         {
            result = this.realTimeRemaining;
         }
         else
         {
            worldTime = Global.world == null ? 0 : Global.worldTime;
            worldTime = Math.floor(worldTime / 1000);
            if(this.m_serverFinishTS > worldTime)
            {
               result = this.m_serverFinishTS - worldTime;
            }
         }
         return result;
      }
      
      public function grantMakeReward(player:Player) : void
      {
         var multiplier:int = 1;
         if(Global.player.buffs[this.CRAFT_MASTERY_BUFF] != null)
         {
            multiplier++;
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_CRAFT) > 1)
         {
            multiplier += Mastery.getTimedCraftingMasteryMult();
         }
         player.craftingState.craftingSkillState.getRecipeStateById(this.id).addExperience(this.rewardRecipeXp * multiplier);
         if(this.rewardPlayerXp > 0)
         {
            player.xp += this.rewardPlayerXp;
         }
      }
      
      public function get promptCoOpJob() : Boolean
      {
         return this.m_promptCoOp;
      }
   }
}

