package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import com.adobe.serialization.json.JSON;
   import flash.utils.Dictionary;
   
   public class AnimalBreedingConfigSettings
   {
      
      public static const PATTERN_TRAIT_NAME:String = "pattern";
      
      public static const HSV_CHILD_INDEX:Number = 0;
      
      public static const HSV_PARENT_INDEX:Number = 1;
      
      public static const DEFAULT_HEX_RADIX:Number = 16;
      
      public static const XP_ACTION_BREED_SUCCESS:String = "xpBreedSuccess";
      
      public static const XP_ACTION_ADOPTION_SUCCESS:String = "xpAdoptionSuccess";
      
      public static const REWARD_TYPE_PATTERN_UNLOCK:String = "pattern_unlock";
      
      private var m_xml:XML;
      
      private var m_colorsDictionary:Dictionary;
      
      private var m_featureHash:Object = {};
      
      private var m_colorDataHash:Object = {};
      
      private var m_itemNameToFeatureHash:Object = {};
      
      private var m_isLimitedHash:Object = {};
      
      private var m_rewardToLevelHash:Object = {};
      
      private var m_bigRewards:Array = [];
      
      public function AnimalBreedingConfigSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
         this.init();
      }
      
      private function parseHSV(variantHSV:XMLList) : Array
      {
         var parsedString:Array = null;
         parsedString = String(variantHSV).split(",",2);
         return [Number(parsedString[HSV_CHILD_INDEX]).toString(16),Number(parsedString[HSV_PARENT_INDEX]).toString(16)];
      }
      
      private function init() : void
      {
         var color:XML = null;
         var feature:XML = null;
         var colorObject:Object = null;
         var featureConfigHash:Object = null;
         var dialogConfigArray:Array = null;
         var featureName:String = null;
         var featureConfig:XML = null;
         var tabConfig:XML = null;
         var traits:Object = null;
         var traitName:String = null;
         var trait:XML = null;
         var mutableAnimalItems:Array = null;
         var mutableAnimalItem:XML = null;
         var itemColorData:XML = null;
         var variantName:String = null;
         var variantObj:Object = null;
         var variantsJSON:Object = null;
         var variant:XML = null;
         var gene:XML = null;
         var itemName:String = null;
         var isLimited:Boolean = false;
         var coloringItemName:String = null;
         var colorData:Object = null;
         var channelData:XML = null;
         var channelType:String = null;
         var splitChannel:Array = null;
         var i:Number = NaN;
         var levelData:Object = null;
         var milestoneRewards:Array = null;
         var milestoneRewardsXml:XMLList = null;
         var mileRewIdx:int = 0;
         this.m_colorsDictionary = new Dictionary();
         for each(color in this.m_xml.color)
         {
            colorObject = {};
            colorObject[MutableAnimalState.HUE_DATA_KEY] = this.parseHSV(color.@hue);
            colorObject[MutableAnimalState.SATURATION_DATA_KEY] = this.parseHSV(color.@saturation);
            colorObject[MutableAnimalState.INTENSITY_DATA_KEY] = this.parseHSV(color.@intensity);
            this.m_colorsDictionary[String(color.@name)] = colorObject;
         }
         for each(feature in this.m_xml.feature)
         {
            featureConfigHash = {};
            dialogConfigArray = new Array();
            featureName = String(feature.@name);
            for each(featureConfig in feature.featureConfig.*)
            {
               featureConfigHash[String(featureConfig.name())] = String(featureConfig.valueOf());
            }
            for each(tabConfig in feature.dialogConfig.*)
            {
               dialogConfigArray.push({
                  "name":String(tabConfig.@name),
                  "className":String(tabConfig.@className),
                  "elementName":String(tabConfig.@elementName)
               });
            }
            traits = {};
            traitName = "";
            for each(trait in feature.traits.trait)
            {
               traitName = String(trait.@name);
               traits[traitName] = {};
               for each(gene in trait.gene)
               {
                  traits[traitName][String(gene.@code)] = String(gene.@value);
               }
            }
            mutableAnimalItems = [];
            for each(mutableAnimalItem in feature.mutableAnimals.item)
            {
               itemName = String(mutableAnimalItem.@name);
               isLimited = String(mutableAnimalItem.@limited) == "true" ? true : false;
               mutableAnimalItems.push(itemName);
               this.m_itemNameToFeatureHash[itemName] = featureName;
               this.m_isLimitedHash[itemName] = isLimited;
            }
            this.m_colorDataHash[featureName] = {};
            for each(itemColorData in feature.coloring.item)
            {
               coloringItemName = String(itemColorData.@name);
               colorData = {};
               colorData.desaturateFactor = Number(itemColorData.desaturateFactor);
               colorData.colorMatrix = [];
               for each(channelData in itemColorData.colorMatrix.channel)
               {
                  channelType = String(channelData.@type);
                  splitChannel = String(channelData.@value).split(",");
                  for(i = 0; i < splitChannel.length; i++)
                  {
                     splitChannel[i] = Number(splitChannel[i]);
                  }
                  colorData.colorMatrix[channelType] = splitChannel;
               }
               this.m_colorDataHash[featureName][coloringItemName] = colorData;
            }
            variantName = "";
            variantObj = {};
            variantsJSON = {};
            for each(variant in feature.variants.variant)
            {
               variantName = String(variant.@name);
               variantObj[MutableAnimalState.NAME_DATA_KEY] = variantName;
               variantObj[MutableAnimalState.GENDER_DATA_KEY] = String(variant.@gender);
               variantObj[MutableAnimalState.BASE_COLOR_DATA_KEY] = {};
               variantObj[MutableAnimalState.BASE_COLOR_DATA_KEY][MutableAnimalState.HUE_DATA_KEY] = this.parseHSV(variant.base.@hue);
               variantObj[MutableAnimalState.BASE_COLOR_DATA_KEY][MutableAnimalState.SATURATION_DATA_KEY] = this.parseHSV(variant.base.@saturation);
               variantObj[MutableAnimalState.BASE_COLOR_DATA_KEY][MutableAnimalState.INTENSITY_DATA_KEY] = this.parseHSV(variant.base.@intensity);
               variantObj[MutableAnimalState.PATTERN_DATA_KEY] = {};
               variantObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY] = [String(variant.pattern.@type)];
               variantObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.HUE_DATA_KEY] = this.parseHSV(variant.pattern.@hue);
               variantObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.SATURATION_DATA_KEY] = this.parseHSV(variant.pattern.@saturation);
               variantObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.INTENSITY_DATA_KEY] = this.parseHSV(variant.pattern.@intensity);
               variantsJSON[variantName] = com.adobe.serialization.json.JSON.encode(variantObj);
               this.m_itemNameToFeatureHash[variantName] = featureName;
            }
            this.m_featureHash[featureName] = {};
            this.m_featureHash[featureName].traits = traits;
            this.m_featureHash[featureName].variantsJSON = variantsJSON;
            this.m_featureHash[featureName].featureConfigHash = featureConfigHash;
            this.m_featureHash[featureName].dialogConfigArray = dialogConfigArray;
            this.m_featureHash[featureName].mutableAnimalItems = mutableAnimalItems;
            if(feature.hasOwnProperty("levels"))
            {
               levelData = this.initLevels(feature["levels"][0],featureName);
               this.m_featureHash[featureName]["levels"] = levelData;
               this.m_featureHash[featureName]["levelMilestones"] = {};
               this.m_featureHash[featureName]["levelMilestones"]["quantity"] = parseInt(feature..milestone[0]["@quantity"]);
               milestoneRewards = [];
               milestoneRewardsXml = feature.levels.milestone.reward;
               for(mileRewIdx = 0; mileRewIdx < milestoneRewardsXml.length(); mileRewIdx++)
               {
                  milestoneRewards.push(this.processRewardData(milestoneRewardsXml[mileRewIdx]));
               }
               this.m_featureHash[featureName]["levelMilestones"]["rewards"] = milestoneRewards;
            }
         }
      }
      
      private function initLevels(featureLevelData:XML, featureName:String) : Object
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
            levelValue = int(levelData["@value"]);
            levelObj = {};
            if(!levelData.hasOwnProperty("@xp"))
            {
               throw new Error("AnimalBreedingConfigManager::initLevels - XP is not defineed for level: " + levelValue);
            }
            levelObj["xp"] = parseInt(levelData["@xp"]);
            rewards = [];
            for each(levelReward in levelData..reward)
            {
               rewardObj = this.processRewardData(levelReward);
               rewards.push(rewardObj);
               this.addToRewardToLevelHash(rewardObj,levelValue,featureName);
               if(rewardObj.hasOwnProperty("bigReward") && rewardObj["bigReward"] == "true")
               {
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
      
      private function addToRewardToLevelHash(rewardObj:Object, levelValue:int, featureName:String) : void
      {
         if(!this.m_rewardToLevelHash.hasOwnProperty(featureName))
         {
            this.m_rewardToLevelHash[featureName] = {};
         }
         if(!this.m_rewardToLevelHash[featureName].hasOwnProperty(rewardObj["type"]))
         {
            this.m_rewardToLevelHash[featureName][rewardObj["type"]] = {};
         }
         if(!this.m_rewardToLevelHash[featureName][rewardObj["type"]].hasOwnProperty(rewardObj["value"]))
         {
            this.m_rewardToLevelHash[featureName][rewardObj["type"]][rewardObj["value"]] = levelValue;
         }
      }
      
      public function isLimitedItem(itemName:String) : Boolean
      {
         var result:Boolean = false;
         if(null != this.m_isLimitedHash[itemName])
         {
            result = Boolean(this.m_isLimitedHash[itemName]);
         }
         return result;
      }
      
      public function getFeatureNames() : Array
      {
         var featureName:String = null;
         var result:Array = new Array();
         for(featureName in this.m_featureHash)
         {
            result.push(featureName);
         }
         return result;
      }
      
      public function getColorObj(colorName:String) : Object
      {
         return this.m_colorsDictionary[colorName];
      }
      
      public function get colors() : Dictionary
      {
         return this.m_colorsDictionary;
      }
      
      public function isReservedAnimalName(animalName:String) : Boolean
      {
         var isReserved:Boolean = false;
         if(null != this.m_itemNameToFeatureHash[animalName])
         {
            isReserved = true;
         }
         return isReserved;
      }
      
      public function getFeatureNameByItem(itemName:String) : String
      {
         return this.m_itemNameToFeatureHash[itemName];
      }
      
      public function getFeatureConfigAttr(featureName:String, attrName:String) : Object
      {
         var result:Object = null;
         if(this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].featureConfigHash[attrName];
         }
         return result;
      }
      
      public function getDialogConfig(featureName:String) : Array
      {
         var result:Array = null;
         if(this.m_featureHash != null && this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].dialogConfigArray;
         }
         return result;
      }
      
      public function getColoringByItemName(itemName:String) : Object
      {
         var featureName:String = Global.animalBreedingSettings.getFeatureNameByItem(itemName);
         var result:Object = null;
         if(this.m_colorDataHash[featureName] != null)
         {
            result = this.m_colorDataHash[featureName][itemName];
         }
         return result;
      }
      
      public function getVariantJSONByItemName(itemName:String, variantName:String) : String
      {
         var featureName:String = Global.animalBreedingSettings.getFeatureNameByItem(itemName);
         var result:String = "";
         if(this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].variantsJSON[variantName];
         }
         return result;
      }
      
      public function getVariantJSON(featureName:String, variantName:String) : String
      {
         var result:String = "";
         if(this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].variantsJSON[variantName];
         }
         return result;
      }
      
      public function getPatternTrait(featureName:String, patternCode:String) : String
      {
         var result:String = "";
         if(this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].traits[PATTERN_TRAIT_NAME][patternCode];
         }
         return result;
      }
      
      public function getPatternTraitByName(featureName:String, patternName:String) : String
      {
         var geneCode:String = null;
         var result:String = "";
         if(this.m_featureHash != null && this.m_featureHash[featureName] != null)
         {
            for(geneCode in this.m_featureHash[featureName].traits[PATTERN_TRAIT_NAME])
            {
               if(this.m_featureHash[featureName].traits[PATTERN_TRAIT_NAME][geneCode] == patternName)
               {
                  result = geneCode;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isAsexualBreeding(featureName:String) : Boolean
      {
         return Global.animalBreedingSettings.getItemNameFromGender(featureName,MutableAnimalState.GENDER_CODE_FEMALE) == Global.animalBreedingSettings.getItemNameFromGender(featureName,MutableAnimalState.GENDER_CODE_MALE);
      }
      
      public function canRenameBaby(itemName:String) : Boolean
      {
         var featureName:String = null;
         var babyName:String = null;
         var preventNaming:Object = null;
         var result:Boolean = true;
         for(featureName in this.m_featureHash)
         {
            babyName = Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"defaultBreedItem").toString();
            if(babyName == itemName)
            {
               preventNaming = Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"preventNaming");
               if(preventNaming != null)
               {
                  result = !Boolean(preventNaming);
               }
               break;
            }
         }
         return result;
      }
      
      public function getMutableAnimals(featureName:String) : Array
      {
         var result:Array = null;
         if(this.m_featureHash[featureName] != null)
         {
            result = this.m_featureHash[featureName].mutableAnimalItems;
         }
         return result;
      }
      
      public function getItemNameFromGender(featureName:String, gender:String) : String
      {
         var itemName:String = "";
         if(gender == MutableAnimalState.GENDER_CODE_MALE)
         {
            itemName = this.getFeatureConfigAttr(featureName,"maleItemName").toString();
         }
         else
         {
            itemName = this.getFeatureConfigAttr(featureName,"femaleItemName").toString();
         }
         return itemName;
      }
      
      public function getXpForLevel(level:int, featureName:String) : int
      {
         var result:int = int.MAX_VALUE;
         if(null != this.m_featureHash[featureName] && null != this.m_featureHash[featureName]["levels"] && null != this.m_featureHash[featureName]["levels"][level] && null != this.m_featureHash[featureName]["levels"][level]["xp"])
         {
            result = int(this.m_featureHash[featureName]["levels"][level]["xp"]);
         }
         return result;
      }
      
      public function haveLevelDefinitionsForFeature(featureName:String) : Boolean
      {
         var haveLevels:Boolean = false;
         if(this.m_featureHash[featureName].hasOwnProperty("levels"))
         {
            haveLevels = true;
         }
         return haveLevels;
      }
      
      public function getMaxLevel(featureName:String) : int
      {
         var maxLevel:int = 1;
         while(this.m_featureHash[featureName]["levels"].hasOwnProperty(maxLevel))
         {
            maxLevel++;
         }
         return maxLevel - 1;
      }
      
      public function getTotalXpForLevel(level:int, featureName:String) : int
      {
         var result:int = 0;
         for(var levelCounter:int = 1; levelCounter <= level; levelCounter++)
         {
            result += this.getXpForLevel(levelCounter,featureName);
         }
         return result;
      }
      
      public function getTotalXpForMaxLevel(featureName:String) : int
      {
         return this.getTotalXpForLevel(this.getMaxLevel(featureName),featureName);
      }
      
      public function getRewardsForLevel(level:int, featureName:String) : Array
      {
         var result:Array = [];
         if(null != this.m_featureHash[featureName]["levels"] && null != this.m_featureHash[featureName]["levels"][level] && null != this.m_featureHash[featureName]["levels"][level]["rewards"])
         {
            result = this.m_featureHash[featureName]["levels"][level]["rewards"];
         }
         return result;
      }
      
      public function getLevelForReward(rewardType:String, value:String, featureName:String) : int
      {
         var result:int = 0;
         if(null != this.m_rewardToLevelHash[featureName] && null != this.m_rewardToLevelHash[featureName][rewardType] && null != this.m_rewardToLevelHash[featureName][rewardType][value])
         {
            result = int(this.m_rewardToLevelHash[featureName][rewardType][value]);
         }
         return result;
      }
      
      public function haveRewardForFeature(rewardType:String, value:String, featureName:String) : Boolean
      {
         var result:Boolean = false;
         if(null != this.m_rewardToLevelHash[featureName] && null != this.m_rewardToLevelHash[featureName][rewardType] && null != this.m_rewardToLevelHash[featureName][rewardType][value])
         {
            result = true;
         }
         return result;
      }
      
      public function getNumMilestonesPerLevel(featureName:String) : int
      {
         var result:int = 0;
         if(null != this.m_featureHash[featureName] && null != this.m_featureHash[featureName]["levelMilestones"] && null != this.m_featureHash[featureName]["levelMilestones"]["quantity"])
         {
            result = int(this.m_featureHash[featureName]["levelMilestones"]["quantity"]);
         }
         return result;
      }
      
      public function getMilestoneRewards(featureName:String) : Array
      {
         var result:Array = [];
         if(null != this.m_featureHash[featureName] && null != this.m_featureHash[featureName]["levelMilestones"] && null != this.m_featureHash[featureName]["levelMilestones"]["rewards"])
         {
            result = this.m_featureHash[featureName]["levelMilestones"]["rewards"];
         }
         return result;
      }
      
      public function getXpForNextMilestone(level:int, featureName:String) : int
      {
         var result:int = 0;
         var nextLevelXp:int = this.getXpForLevel(level + 1,featureName);
         var getNumMilestones:int = this.getNumMilestonesPerLevel(featureName);
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
      
      public function getPatternLevelFromItem(item:FarmItem, metadata:String = null) : int
      {
         var featureName:String = this.getFeatureNameByItem(item.name);
         if(null == metadata)
         {
            metadata = this.getVariantJSONByItemName(item.name,item.name);
         }
         var tempState:MutableAnimalState = MutableAnimalState.createFromPhpString("",metadata);
         var patternName:String = this.getPatternTrait(featureName,tempState.pattern);
         return this.getLevelForReward(AnimalBreedingConfigSettings.REWARD_TYPE_PATTERN_UNLOCK,patternName,featureName);
      }
   }
}

