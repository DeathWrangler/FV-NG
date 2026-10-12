package Managers
{
   import flash.utils.Dictionary;
   
   public class DragonBreedingConfigManager
   {
      
      public static const BODY_DATA_KEY:String = "B";
      
      public static const FIRE_DATA_KEY:String = "F";
      
      public static const HEAD_DATA_KEY:String = "H";
      
      public static const PATTERN_DATA_KEY:String = "P";
      
      public static const WING_DATA_KEY:String = "W";
      
      public static const NECK_DATA_KEY:String = "N";
      
      public static const SIBLING_ID:String = "S";
      
      public static const ITEM_NAME_DATA_KEY:String = "I";
      
      public static const TYPE_DATA_KEY:String = "T";
      
      public static const GENDER_CODE_FEMALE:String = "F";
      
      public static const GENDER_CODE_MALE:String = "M";
      
      public static const CODE_OFFSPRING:String = "O";
      
      public static const XP_ACTION_BREED_SUCCESS:String = "xpBreedSuccess";
      
      public static const DEFAULT_HEX_RADIX:Number = 16;
      
      private static var m_instances:Array = new Array();
      
      public static const INDEX_TABLE_ID:Number = 0;
      
      private var m_featureName:String;
      
      private var m_featureHash:Object = {};
      
      private var m_marketUnlockItemHash:Object = {};
      
      private var m_bigRewards:Array = [];
      
      private var m_rewardToLevelHash:Object = {};
      
      public function DragonBreedingConfigManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.parseConfig();
      }
      
      public static function getInstance(featureName:String) : DragonBreedingConfigManager
      {
         if(m_instances[featureName] == null)
         {
            m_instances[featureName] = new DragonBreedingConfigManager(featureName);
         }
         return m_instances[featureName];
      }
      
      private function parseConfig() : void
      {
         var featureConfig:XML = null;
         var mutableFemaleAnimalItems:Array = null;
         var isMarketUnlock:Boolean = false;
         var male_couple:Array = null;
         var female_couple:Array = null;
         var male_order:Array = null;
         var female_order:Array = null;
         var progress_dragons:Array = null;
         var mutableFemaleAnimalItem:XML = null;
         var mutableMaleAnimalItems:Array = null;
         var mutableMaleAnimalItem:XML = null;
         var experiment:int = 0;
         var initialParents:Array = null;
         var offspringItems:Array = null;
         var parentTables:XMLList = null;
         var femaleItemName:String = null;
         var maleItemName:String = null;
         var parent:XML = null;
         var offspringList:XMLList = null;
         var offspring:XML = null;
         var buckets:XMLList = null;
         var bucket:XML = null;
         var bucketName:String = null;
         var levelData:Object = null;
         var milestoneRewards:Array = null;
         var milestoneRewardsXml:XMLList = null;
         var mileRewIdx:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getDragonBreedingData(this.m_featureName);
         if(feature == null)
         {
            throw new Error("Feature config xml not found for Dragon Breeding.");
         }
         var featureConfigHash:Object = {};
         for each(featureConfig in feature.breedingConfig.*)
         {
            featureConfigHash[String(featureConfig.name())] = String(featureConfig.valueOf());
         }
         mutableFemaleAnimalItems = [];
         male_couple = [];
         female_couple = [];
         male_order = [];
         female_order = [];
         progress_dragons = [];
         for each(mutableFemaleAnimalItem in feature.mutableAnimals.parentFemale.item)
         {
            femaleItemName = String(mutableFemaleAnimalItem.@name);
            isMarketUnlock = String(mutableFemaleAnimalItem.@marketUnlock) == "true" ? true : false;
            mutableFemaleAnimalItems.push(femaleItemName);
            if(isMarketUnlock)
            {
               this.m_marketUnlockItemHash[femaleItemName] = true;
            }
            if(Boolean(String(mutableFemaleAnimalItem.@order)) && !isMarketUnlock)
            {
               female_order[mutableFemaleAnimalItem.@order] = femaleItemName;
            }
            if(Boolean(String(mutableFemaleAnimalItem.@couple)) && !isMarketUnlock)
            {
               female_couple[mutableFemaleAnimalItem.@couple] = femaleItemName;
            }
         }
         mutableMaleAnimalItems = [];
         for each(mutableMaleAnimalItem in feature.mutableAnimals.parentMale.item)
         {
            maleItemName = String(mutableMaleAnimalItem.@name);
            isMarketUnlock = String(mutableMaleAnimalItem.@marketUnlock) == "true" ? true : false;
            mutableMaleAnimalItems.push(maleItemName);
            if(isMarketUnlock)
            {
               this.m_marketUnlockItemHash[maleItemName] = true;
            }
            if(Boolean(String(mutableMaleAnimalItem.@order)) && !isMarketUnlock)
            {
               male_order[mutableMaleAnimalItem.@order] = maleItemName;
            }
            if(Boolean(String(mutableMaleAnimalItem.@couple)) && !isMarketUnlock)
            {
               male_couple[mutableMaleAnimalItem.@couple] = maleItemName;
            }
         }
         experiment = Global.eosManager.getEosVariant(DragonBreedingManager.EXPERIMENT_NAME);
         initialParents = [];
         initialParents[GENDER_CODE_MALE] = male_couple[(experiment - 1).toString()];
         initialParents[GENDER_CODE_FEMALE] = female_couple[(experiment - 1).toString()];
         offspringItems = new Array();
         parentTables = Global.farmGameSettingsManager.getXML().dragonbreeding.feature.offspringAnimals.parent;
         if(parentTables)
         {
            for each(parent in parentTables)
            {
               offspringList = parent.offspring;
               if(offspringList)
               {
                  offspringItems[parent["@name"]] = {};
                  offspringItems[parent["@name"]][INDEX_TABLE_ID] = parent["@id"];
                  for each(offspring in offspringList)
                  {
                     if(offspring.hasOwnProperty("@id"))
                     {
                        offspringItems[parent["@name"]][offspring["@id"]] = this.createOffspringObj(offspring,parent["@name"],offspring["@id"]);
                     }
                  }
               }
            }
         }
         var craftingItem:String = "";
         var initialGrant:int = 0;
         var bucketPackages:Array = new Array();
         var ftueFlag:String = "";
         var craftingConfig:XMLList = feature.crafting;
         if(craftingConfig)
         {
            if(Boolean(craftingConfig.bucketItem) && craftingConfig.bucketItem.@code != "")
            {
               craftingItem = craftingConfig.bucketItem.@code;
            }
            if(craftingConfig.initialGrant)
            {
               initialGrant = parseInt(craftingConfig.initialGrant.toString());
            }
            buckets = craftingConfig.bucketPackages.bucketPackage;
            if(buckets)
            {
               for each(bucket in buckets)
               {
                  bucketName = bucket.@name;
                  if(bucketName)
                  {
                     bucketPackages.push(bucketName);
                  }
               }
            }
            if(craftingConfig.ftueFlag)
            {
               ftueFlag = String(craftingConfig.ftueFlag);
            }
         }
         progress_dragons = this.getProgressDragonsInOrder(male_order,female_order,initialParents);
         this.m_featureHash[this.m_featureName] = {};
         this.m_featureHash[this.m_featureName].featureConfigHash = featureConfigHash;
         this.m_featureHash[this.m_featureName].mutableFemaleAnimalItems = mutableFemaleAnimalItems;
         this.m_featureHash[this.m_featureName].mutableMaleAnimalItems = mutableMaleAnimalItems;
         this.m_featureHash[this.m_featureName].offspringItems = offspringItems;
         this.m_featureHash[this.m_featureName].defaultCraftingItem = craftingItem;
         this.m_featureHash[this.m_featureName].initialGrant = initialGrant;
         this.m_featureHash[this.m_featureName].bucketPackages = bucketPackages;
         this.m_featureHash[this.m_featureName].ftueFlag = ftueFlag;
         this.m_featureHash[this.m_featureName].maleOrder = male_order;
         this.m_featureHash[this.m_featureName].femaleOrder = female_order;
         this.m_featureHash[this.m_featureName].femaleCouple = female_couple;
         this.m_featureHash[this.m_featureName].maleCouple = male_couple;
         this.m_featureHash[this.m_featureName].initialParents = initialParents;
         this.m_featureHash[this.m_featureName].progress_dragons_in_order = progress_dragons;
         if(feature.hasOwnProperty("levels"))
         {
            levelData = this.initLevels(feature["levels"][0]);
            this.m_featureHash[this.m_featureName]["levels"] = levelData;
            this.m_featureHash[this.m_featureName]["levelMilestones"] = {};
            this.m_featureHash[this.m_featureName]["levelMilestones"]["quantity"] = parseInt(feature..milestone[0]["@quantity"]);
            milestoneRewards = [];
            milestoneRewardsXml = feature.levels.milestone.reward;
            for(mileRewIdx = 0; mileRewIdx < milestoneRewardsXml.length(); mileRewIdx++)
            {
               milestoneRewards.push(this.processRewardData(milestoneRewardsXml[mileRewIdx]));
            }
            this.m_featureHash[this.m_featureName]["levelMilestones"]["rewards"] = milestoneRewards;
         }
      }
      
      public function getProgressDragonsInOrder(maleDragons:Array, femaleDragons:Array, initialParents:Array) : Array
      {
         var i:int = 0;
         var result:Array = new Array();
         var j:* = 0;
         var deletedNode:int = 0;
         i = 1;
         while(i <= maleDragons.length || i <= femaleDragons.length)
         {
            if(Boolean(femaleDragons[i.toString()]) && femaleDragons[i.toString()] != initialParents[GENDER_CODE_FEMALE])
            {
               var _loc8_:Number;
               result[_loc8_ = j++] = femaleDragons[i.toString()];
            }
            else if(femaleDragons[i.toString()] == initialParents[GENDER_CODE_FEMALE] && j > deletedNode)
            {
               deletedNode = j;
            }
            if(Boolean(maleDragons[i.toString()]) && maleDragons[i.toString()] != initialParents[GENDER_CODE_MALE])
            {
               result[_loc8_ = j++] = maleDragons[i.toString()];
            }
            else if(maleDragons[i.toString()] == initialParents[GENDER_CODE_MALE] && j > deletedNode)
            {
               deletedNode = j;
            }
            i++;
         }
         for(i = 1; i < deletedNode + 1; i++)
         {
            result.push(result.shift());
         }
         return result;
      }
      
      private function createOffspringObj(offspring:XML, parent:String = "", id:String = "") : Dictionary
      {
         var result:Dictionary = new Dictionary();
         if(offspring.hasOwnProperty("@b"))
         {
            result[BODY_DATA_KEY] = String(offspring["@b"]);
         }
         if(offspring.hasOwnProperty("@e"))
         {
            result[FIRE_DATA_KEY] = String(offspring["@e"]);
         }
         if(offspring.hasOwnProperty("@h"))
         {
            result[HEAD_DATA_KEY] = String(offspring["@h"]);
         }
         if(offspring.hasOwnProperty("@p"))
         {
            result[PATTERN_DATA_KEY] = String(offspring["@p"]);
         }
         if(offspring.hasOwnProperty("@w"))
         {
            result[WING_DATA_KEY] = String(offspring["@w"]);
         }
         if(offspring.hasOwnProperty("@n"))
         {
            result[NECK_DATA_KEY] = String(offspring["@n"]);
         }
         if(parent != "" && id != "")
         {
            result[SIBLING_ID] = String(parent + "_" + id);
         }
         return result;
      }
      
      public function getRewardFromLevel(level:int) : String
      {
         var rewardName:String = null;
         var progressOrder:Array = this.getOrderedProgressDragons();
         if(level % 5 == 0)
         {
            if(progressOrder[(level / 5 - 1).toString()])
            {
               rewardName = progressOrder[(level / 5 - 1).toString()];
            }
         }
         return rewardName;
      }
      
      private function initLevels(featureLevelData:XML) : Object
      {
         var levelData:XML = null;
         var levelValue:int = 0;
         var levelObj:Object = null;
         var rewards:Array = null;
         var levelReward:XML = null;
         var rewardObj:Object = null;
         var result:Object = {};
         for each(levelData in featureLevelData.level)
         {
            levelValue = int(levelData["@num"]);
            levelObj = {};
            if(!levelData.hasOwnProperty("@xp"))
            {
               throw new Error("DragonBreedingConfigManager::initLevels - XP is not defineed for level: " + levelValue);
            }
            levelObj["xp"] = parseInt(levelData["@xp"]);
            rewards = [];
            for each(levelReward in levelData..reward)
            {
               rewardObj = this.processRewardData(levelReward);
               rewards.push(rewardObj);
               this.addToRewardToLevelHash(rewardObj,levelValue);
               if(rewardObj.hasOwnProperty("bigReward") && rewardObj["bigReward"] == "true")
               {
                  rewardObj["value"] = Global.farmGameSettingsManager.getFarmItemCodeByName(this.getRewardFromLevel(levelValue));
                  if(this.m_bigRewards.length != 0 && this.m_bigRewards[this.m_bigRewards.length] != levelData)
                  {
                     this.m_bigRewards.push(levelValue);
                  }
                  else if(this.m_bigRewards.length == 0)
                  {
                     this.m_bigRewards.push(levelValue);
                  }
               }
            }
            levelObj["rewards"] = rewards;
            if(levelData.hasOwnProperty("rewardView"))
            {
               levelObj["rewardView"] = String(levelData["rewardView"][0]);
            }
            else
            {
               levelObj["rewardView"] = null;
            }
            result[levelValue] = levelObj;
         }
         return result;
      }
      
      private function processRewardData(levelReward:XML) : Object
      {
         var attrName:String = null;
         var rewardObj:Object = {};
         var attributeList:XMLList = levelReward.attributes();
         for(var attrIdx:int = 0; attrIdx < attributeList.length(); attrIdx++)
         {
            attrName = attributeList[attrIdx].name();
            rewardObj[attrName] = attributeList[attrIdx].toString();
         }
         return rewardObj;
      }
      
      private function addToRewardToLevelHash(rewardObj:Object, levelValue:int) : void
      {
         if(!this.m_rewardToLevelHash.hasOwnProperty(this.m_featureName))
         {
            this.m_rewardToLevelHash[this.m_featureName] = {};
         }
         if(!this.m_rewardToLevelHash[this.m_featureName].hasOwnProperty(rewardObj["type"]))
         {
            this.m_rewardToLevelHash[this.m_featureName][rewardObj["type"]] = {};
         }
         if(!this.m_rewardToLevelHash[this.m_featureName][rewardObj["type"]].hasOwnProperty(rewardObj["value"]))
         {
            this.m_rewardToLevelHash[this.m_featureName][rewardObj["type"]][rewardObj["value"]] = levelValue;
         }
      }
      
      public function getVariantJSON(variantName:String) : String
      {
         var result:String = "";
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].variantsJSON[variantName];
         }
         return result;
      }
      
      public function getFeatureConfigAttr(attrName:String) : Object
      {
         var result:Object = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].featureConfigHash[attrName];
         }
         return result;
      }
      
      public function getItemNameFromGender(gender:String) : String
      {
         var itemName:String = "";
         if(gender == GENDER_CODE_MALE)
         {
            itemName = this.getFeatureConfigAttr("maleItemName").toString();
         }
         else
         {
            itemName = this.getFeatureConfigAttr("femaleItemName").toString();
         }
         return itemName;
      }
      
      public function getXpForLevel(level:int) : int
      {
         var result:int = int.MAX_VALUE;
         if(null != this.m_featureHash[this.m_featureName] && null != this.m_featureHash[this.m_featureName]["levels"] && null != this.m_featureHash[this.m_featureName]["levels"][level] && null != this.m_featureHash[this.m_featureName]["levels"][level]["xp"])
         {
            result = int(this.m_featureHash[this.m_featureName]["levels"][level]["xp"]);
         }
         return result;
      }
      
      public function haveLevelDefinitionsForFeature() : Boolean
      {
         var haveLevels:Boolean = false;
         if(this.m_featureHash[this.m_featureName].hasOwnProperty("levels"))
         {
            haveLevels = true;
         }
         return haveLevels;
      }
      
      public function getMaxLevel() : int
      {
         var maxLevel:int = 1;
         while(this.m_featureHash[this.m_featureName]["levels"].hasOwnProperty(maxLevel))
         {
            maxLevel++;
         }
         return maxLevel - 1;
      }
      
      public function getTotalXpForLevel(level:int) : int
      {
         var result:int = 0;
         for(var levelCounter:int = 1; levelCounter < level; levelCounter++)
         {
            result += this.getXpForLevel(levelCounter);
         }
         return result;
      }
      
      public function getTotalXpForMaxLevel() : int
      {
         return this.getTotalXpForLevel(this.getMaxLevel());
      }
      
      public function getRewardsForLevel(level:int) : Array
      {
         var result:Array = [];
         if(null != this.m_featureHash[this.m_featureName]["levels"] && null != this.m_featureHash[this.m_featureName]["levels"][level] && null != this.m_featureHash[this.m_featureName]["levels"][level]["rewards"])
         {
            result = this.m_featureHash[this.m_featureName]["levels"][level]["rewards"];
         }
         return result;
      }
      
      public function getLevelForReward(rewardType:String, value:String) : int
      {
         var result:int = 0;
         if(null != this.m_rewardToLevelHash[this.m_featureName] && null != this.m_rewardToLevelHash[this.m_featureName][rewardType] && null != this.m_rewardToLevelHash[this.m_featureName][rewardType][value])
         {
            result = int(this.m_rewardToLevelHash[this.m_featureName][rewardType][value]);
         }
         return result;
      }
      
      public function haveRewardForFeature(rewardType:String, value:String) : Boolean
      {
         var result:Boolean = false;
         if(null != this.m_rewardToLevelHash[this.m_featureName] && null != this.m_rewardToLevelHash[this.m_featureName][rewardType] && null != this.m_rewardToLevelHash[this.m_featureName][rewardType][value])
         {
            result = true;
         }
         return result;
      }
      
      public function getNumMilestonesPerLevel() : int
      {
         var result:int = 0;
         if(null != this.m_featureHash[this.m_featureName] && null != this.m_featureHash[this.m_featureName]["levelMilestones"] && null != this.m_featureHash[this.m_featureName]["levelMilestones"]["quantity"])
         {
            result = int(this.m_featureHash[this.m_featureName]["levelMilestones"]["quantity"]);
         }
         return result;
      }
      
      public function getMilestoneRewards() : Array
      {
         var result:Array = [];
         if(null != this.m_featureHash[this.m_featureName] && null != this.m_featureHash[this.m_featureName]["levelMilestones"] && null != this.m_featureHash[this.m_featureName]["levelMilestones"]["rewards"])
         {
            result = this.m_featureHash[this.m_featureName]["levelMilestones"]["rewards"];
         }
         return result;
      }
      
      public function getXpForNextMilestone(level:int) : int
      {
         var result:int = 0;
         var nextLevelXp:int = this.getXpForLevel(level + 1);
         var getNumMilestones:int = this.getNumMilestonesPerLevel();
         if(getNumMilestones != -1)
         {
            result = nextLevelXp / (getNumMilestones + 1);
         }
         return result;
      }
      
      public function getNextBigReward(currentLevel:int) : int
      {
         var result:int = 0;
         for(var levelCounter:int = 0; levelCounter < this.m_bigRewards.length; levelCounter++)
         {
            if(this.m_bigRewards[levelCounter] > currentLevel)
            {
               result = int(this.m_bigRewards[levelCounter]);
               break;
            }
         }
         return result;
      }
      
      public function getPreviousBigReward(currentLevel:int) : int
      {
         var result:int = 1;
         for(var levelCounter:int = 0; levelCounter < this.m_bigRewards.length; levelCounter++)
         {
            if(this.m_bigRewards[levelCounter] <= currentLevel)
            {
               result = int(this.m_bigRewards[levelCounter]);
            }
         }
         return result;
      }
      
      public function getLevelByRewardItemCode(itemCode:String) : int
      {
         var i:int = 0;
         var rewards:Array = null;
         var reward:Object = null;
         var level:int = 0;
         if(Boolean(this.m_bigRewards) && this.m_bigRewards.length > 0)
         {
            for(i = 0; i < this.m_bigRewards.length; i++)
            {
               rewards = DragonBreedingConfigManager.getInstance(this.m_featureName).getRewardsForLevel(this.m_bigRewards[i]);
               if(Boolean(rewards) && Boolean(rewards.length))
               {
                  for each(reward in rewards)
                  {
                     if(Boolean(reward && reward.hasOwnProperty("bigReward")) && Boolean(reward.hasOwnProperty("value")) && reward.value != "")
                     {
                        if(reward.value == itemCode)
                        {
                           level = int(this.m_bigRewards[i]);
                           break;
                        }
                     }
                  }
               }
            }
         }
         return level;
      }
      
      public function getBigRewardsLevels() : Array
      {
         return Boolean(this.m_bigRewards) && this.m_bigRewards.length > 0 ? this.m_bigRewards : null;
      }
      
      public function isMarketUnlockItem(name:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_marketUnlockItemHash.hasOwnProperty(name) && Boolean(this.m_marketUnlockItemHash[name]))
         {
            result = true;
         }
         return result;
      }
      
      public function getMutableAnimals() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].mutableAnimalItems;
         }
         return result;
      }
      
      public function getMutableMaleAnimals() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].mutableMaleAnimalItems;
         }
         return result;
      }
      
      public function getMutableFemaleAnimals() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].mutableFemaleAnimalItems;
         }
         return result;
      }
      
      public function getOrderedProgressDragons() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].progress_dragons_in_order;
         }
         return result;
      }
      
      public function getInitialParents() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].initialParents;
         }
         return result;
      }
      
      public function getMaleOrder() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].maleOrder;
         }
         return result;
      }
      
      public function getFemaleOrder() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].femaleOrder;
         }
         return result;
      }
      
      public function getMaleCouple() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].maleCouple;
         }
         return result;
      }
      
      public function getFemaleCouple() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].femaleCouple;
         }
         return result;
      }
      
      public function getParentTableId(maleName:String, femaleName:String) : Number
      {
         var result:Number = 0;
         var parentTables:Array = this.getOffsprings();
         return Number(parentTables[maleName + "_" + femaleName][INDEX_TABLE_ID]);
      }
      
      public function getOffsprings() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].offspringItems;
         }
         return result;
      }
      
      public function getLovePotion() : String
      {
         var result:String = "";
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].defaultCraftingItem;
         }
         return result;
      }
      
      public function getInitialGrantLovePotion() : int
      {
         var result:int = 0;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = int(this.m_featureHash[this.m_featureName].initialGrant);
         }
         return result;
      }
      
      public function getLovePotionBucketItems() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].bucketPackages;
         }
         return result;
      }
      
      public function getFtueFlag() : String
      {
         var result:String = "";
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName].ftueFlag;
         }
         return result;
      }
   }
}

