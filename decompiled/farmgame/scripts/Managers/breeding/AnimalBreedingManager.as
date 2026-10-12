package Managers.breeding
{
   import Classes.AnimalBreedingConfigSettings;
   import Classes.FarmGameObject;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.AnimalBreedingState;
   import Classes.MapResource;
   import Classes.UGC.UGCFeedImage;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.breeding.MutableAnimalState;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.Breeding.BreedingLevelupDialog;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.BreedingXpGrantEvent;
   import Managers.UserContentManager;
   import Transactions.BreedingProjects.TAnimalAskForBreedItem;
   import Transactions.BreedingProjects.TAnimalBeginBreeding;
   import Transactions.BreedingProjects.TAnimalFinishBreeding;
   import Transactions.BreedingProjects.TAnimalFinishBreedingNow;
   import Transactions.BreedingProjects.TAnimalGiveUpForAdoption;
   import Transactions.BreedingProjects.TAnimalSetName;
   import Transactions.BreedingProjects.TGetBreedingLevelUpShareLink;
   import com.adobe.serialization.json.JSON;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class AnimalBreedingManager extends EventDispatcher
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:AnimalBreedingManager = null;
      
      public static const fallbackBreedTimes:Array = [24,12,6,3,1,0];
      
      public static const MAX_NUM_POTIONS:Number = 5;
      
      public static const MAX_POTION_LIMIT:Number = 50;
      
      public static const LOVE_POTION_ITEM_NAME_1:String = "pkg_xuk_animal_love_potion_1";
      
      public static const LOVE_POTION_ITEM_NAME_5:String = "pkg_xuk_animal_love_potion_5";
      
      public static const LOVE_POTION_ITEM_CODE:String = "gk";
      
      public static const MAX_BREED_SESSIONS:Number = 3;
      
      public static const LOVE_POTION_FEATURE_KEY:String = "BreedingAsk_" + LOVE_POTION_ITEM_CODE;
      
      public static const FIRST_MILESTONE:String = "first_milestone";
      
      public static const PIGS_FEATURE_NAME:String = "pigpenv2_finished";
      
      public static const SHEEP_FEATURE_NAME:String = "xuk_sheep_pen_finished";
      
      public static const BASE_BREEDING_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_Support/FV_BreedingLevels/";
      
      private var m_breedStates:Dictionary = new Dictionary();
      
      private var m_dataSession:Object = {};
      
      private var m_breedData:AnimalBreedingSession = null;
      
      public function AnimalBreedingManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use AnimalBreedingManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : AnimalBreedingManager
      {
         if(m_instance == null)
         {
            m_instance = new AnimalBreedingManager();
         }
         return m_instance;
      }
      
      public static function getDefaultBreedTimes(featureName:String) : Array
      {
         var breedTimesArray:Array = null;
         var num:String = null;
         var result:Array = null;
         var breedTimesData:String = Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"defaultBreedTimes") as String;
         if(breedTimesData != null)
         {
            breedTimesArray = breedTimesData.replace(" ","").split(",");
            if(breedTimesArray != null && breedTimesArray.length > 0)
            {
               result = new Array();
               for each(num in breedTimesArray)
               {
                  result.push(Number(num));
               }
            }
            else
            {
               result = AnimalBreedingManager.fallbackBreedTimes;
            }
         }
         else
         {
            result = AnimalBreedingManager.fallbackBreedTimes;
         }
         return result;
      }
      
      public static function canAddUGCToWorld(featureName:String) : Boolean
      {
         var animalName:String = null;
         var maxAnimalCount:Number = NaN;
         var animalPen:FeatureBuilding = null;
         var animalNameList:Array = Global.animalBreedingSettings.getMutableAnimals(featureName);
         var count:Number = 0;
         var worldCount:Number = 0;
         var giftBoxCount:Number = 0;
         var inPenCount:Number = 0;
         var farmItem:FarmItem = null;
         var animalPens:Array = Global.world.getObjectsByName(featureName);
         for each(animalName in animalNameList)
         {
            if(Global.animalBreedingSettings.isLimitedItem(animalName))
            {
               worldCount = Global.world.getObjectsByName(animalName).length;
               giftBoxCount = Global.player.getGiftCountForItem(animalName);
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(animalName);
               for each(animalPen in animalPens)
               {
                  inPenCount = animalPen.contents[farmItem.code] != null ? Number(animalPen.contents[farmItem.code]) : 0;
               }
               count += worldCount + giftBoxCount + inPenCount;
            }
         }
         maxAnimalCount = AnimalBreedingManager.getInstance().getMaxAnimalsCount(featureName);
         if(count < maxAnimalCount)
         {
            return true;
         }
         return false;
      }
      
      public static function getMutableAnimalCountInInventory(inventoryId:Number) : Number
      {
         var storageKey:String = null;
         var keys:Array = null;
         var inventoryItem:StorageItem = null;
         var count:Number = 0;
         var inventory:Dictionary = Global.player.getInventory(inventoryId);
         if(inventory)
         {
            for(storageKey in inventory)
            {
               keys = storageKey.split(":");
               inventoryItem = inventory[storageKey] as StorageItem;
               if(keys.length > 1 && isMutableAnimal(inventoryItem.item))
               {
                  count += inventoryItem.quantity;
               }
            }
         }
         return count;
      }
      
      public static function isMutableAnimal(item:FarmItem) : Boolean
      {
         var flag:Boolean = false;
         if(item.className == "MutableAnimal" && Global.animalBreedingSettings.isLimitedItem(item.name))
         {
            flag = true;
         }
         return flag;
      }
      
      private static function getRandomValueRange(current:Number, min:Number, max:Number, variant:Number, useRandom:Boolean = false, shouldBounceInsteadOfWrap:Boolean = false) : String
      {
         var randomVariant:Number = NaN;
         var negate:Boolean = false;
         var result:Number = current;
         var getRandom:Boolean = true;
         if(useRandom == true)
         {
            getRandom = Math.round(Math.random() * 5) == 3;
         }
         if(getRandom == true)
         {
            randomVariant = Math.round(Math.random() * variant);
            negate = Math.round(Math.random() * variant) % 2 == 0;
            if(negate == true)
            {
               randomVariant *= -1;
            }
            result += randomVariant;
            if(shouldBounceInsteadOfWrap)
            {
               if(result < min)
               {
                  result = min + 2;
               }
               if(result > max)
               {
                  result = max + 2;
               }
            }
            else
            {
               if(result < min)
               {
                  result = max - result * -1;
               }
               if(result > max)
               {
                  result = min + (result - max);
               }
            }
         }
         return result.toString(16);
      }
      
      public function loadData(rawData:Object) : void
      {
         if(rawData.breedStates != null)
         {
            this.m_breedStates = rawData.breedStates;
         }
      }
      
      public function canBreed(featureBuilding:FeatureBuilding, enforceLimit:Boolean = false) : Boolean
      {
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var totalCount:int = 0;
         var breedingItemName:String = null;
         var maxAnimalCount:int = 0;
         var result:Boolean = false;
         var uniqueAnimalCount:Number = 0;
         var tempUniqueCheck:Dictionary = new Dictionary();
         var numBreedingSessions:Number = this.getNumBreedingSessions(featureBuilding);
         var asexualBreeding:Boolean = Global.animalBreedingSettings.getItemNameFromGender(featureBuilding.getItemName(),MutableAnimalState.GENDER_CODE_FEMALE) == Global.animalBreedingSettings.getItemNameFromGender(featureBuilding.getItemName(),MutableAnimalState.GENDER_CODE_MALE);
         if(!asexualBreeding)
         {
            for(itemCode in featureBuilding.contents)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(null != farmItem && featureBuilding.contents[itemCode] > 0)
               {
                  if(null == tempUniqueCheck[farmItem.keyword])
                  {
                     tempUniqueCheck[farmItem.keyword] = 0;
                  }
                  if(tempUniqueCheck[farmItem.keyword] <= numBreedingSessions)
                  {
                     tempUniqueCheck[farmItem.keyword] += featureBuilding.contents[itemCode];
                     if(tempUniqueCheck[farmItem.keyword] > numBreedingSessions)
                     {
                        uniqueAnimalCount++;
                     }
                  }
                  if(uniqueAnimalCount > 1)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         else
         {
            totalCount = 0;
            breedingItemName = Global.animalBreedingSettings.getItemNameFromGender(featureBuilding.getItemName(),MutableAnimalState.GENDER_CODE_MALE);
            for(itemCode in featureBuilding.contents)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(farmItem.keyword == breedingItemName)
               {
                  totalCount += featureBuilding.contents[itemCode];
                  if(totalCount >= 2)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         if(enforceLimit)
         {
            maxAnimalCount = this.getMaxAnimalsCount(featureBuilding.getItemName());
            if(this.getMutableAnimalCount(featureBuilding) >= maxAnimalCount)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function getMaxAnimalsCount(featureName:String) : int
      {
         var maxAnimalCount:Number = Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"maxAnimals"));
         if(Global.flashHotParams[featureName.toUpperCase() + "_MAXANIMALS"] != null)
         {
            maxAnimalCount = Number(Global.flashHotParams[featureName.toUpperCase() + "_MAXANIMALS"]);
         }
         var skillState:AnimalBreedingSkillState = Global.player.getBreedingSkillStateForFeature(featureName);
         var capacityIncreaseLevel:int = 0;
         while(Global.animalBreedingSettings.haveRewardForFeature("capacityIncrease",(capacityIncreaseLevel + 1).toString(),featureName) && skillState.hasUnlockedReward("capacityIncrease",(capacityIncreaseLevel + 1).toString()))
         {
            capacityIncreaseLevel++;
         }
         return maxAnimalCount + capacityIncreaseLevel * Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"maxIncreasePerRewardLevel"));
      }
      
      public function beginBreed(breedSession:AnimalBreedingSession, callback:Function) : void
      {
         var breedObj:MutableAnimalState = null;
         Global.player.removeGiftWithKey(LOVE_POTION_ITEM_CODE,breedSession.numPotions);
         TransactionManager.addTransaction(new TAnimalBeginBreeding(breedSession,callback),true);
         var featureName:String = breedSession.owner.getItem().name;
         for each(breedObj in breedSession.getBreedObjects())
         {
            StatsManager.count(featureName,"breeding","pattern",Global.animalBreedingSettings.getPatternTrait(featureName,breedObj.pattern));
         }
      }
      
      public function finishBreed(breedSession:AnimalBreedingSession, callback:Function) : void
      {
         TransactionManager.addTransaction(new TAnimalFinishBreeding(breedSession,callback),true);
      }
      
      public function finishBreedNow(breedSession:AnimalBreedingSession, cashNeeded:Number, callback:Function) : void
      {
         Global.player.cash -= cashNeeded;
         TransactionManager.addTransaction(new TAnimalFinishBreedingNow(breedSession,callback),true);
      }
      
      public function askForLovePotions(featureName:String, source:String = "UI") : void
      {
         if(this.canAskForLovePotions())
         {
            TransactionManager.addTransaction(new TAnimalAskForBreedItem(LOVE_POTION_ITEM_CODE,function(rewardLink:String):void
            {
               var item:* = Global.farmGameSettingsManager.getFarmItemByCode(LOVE_POTION_ITEM_CODE);
               var bundle:* = featureName + "_AskLovePotion_" + source;
               var bundleData:* = {};
               bundleData["reward_link"] = rewardLink;
               bundleData["itemName"] = item.friendlyName;
               bundleData["images"] = [{
                  "src":item.icon,
                  "href":Config.SN_APP_URL + rewardLink
               }];
               GlobalEngine.socialNetwork.publishFeedStory(bundle,bundleData,[],false);
               Global.player.setFeatureLastShown(LOVE_POTION_FEATURE_KEY,GlobalEngine.serverTime / 1000,true);
            }),true);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",featureName + "_LovePotion_Disabled"),0,null,"",true);
         }
      }
      
      public function createBabyImage(mapResource:MapResource, featureName:String) : void
      {
         var ugcImage:UGCFeedImage = new UGCFeedImage(mapResource,featureName);
         ugcImage.applyConfigTransforms(mapResource.getItem().ugcTransforms);
         UserContentManager.getInstance().createFeedImage(ugcImage,this.showAdoptionFeed);
      }
      
      public function giveUpForAdoption(itemCode:String, metaHash:String, featureName:String, animalName:String) : void
      {
         var storageItem:StorageItem = Global.player.getGiftStorageItem(itemCode);
         var extraData:Array = storageItem.getAllExtraData();
         var muteState:MutableAnimalState = null;
         for(var index:Number = 0; index < extraData.length; index++)
         {
            muteState = MutableAnimalState.createFromPhpString("",extraData[index]);
            if(muteState.getHashKey() == metaHash)
            {
               Global.player.removeGiftWithKey(itemCode,1,index);
               break;
            }
         }
         this.m_dataSession.adoptionCode = itemCode;
         this.m_dataSession.featureName = featureName;
         this.m_dataSession.animalName = animalName;
         TransactionManager.addTransaction(new TAnimalGiveUpForAdoption(itemCode,metaHash,this.showAdoptionFeed),true);
      }
      
      public function showAdoptionFeed(result:Object) : void
      {
         var item:FarmItem = null;
         var bundle:String = null;
         var bundleData:Object = null;
         if(result.hasOwnProperty("rewardLink"))
         {
            this.m_dataSession.rewardLink = result.rewardLink;
         }
         if(result.hasOwnProperty("imagePath"))
         {
            this.m_dataSession.imagePath = result.imagePath;
         }
         if(this.m_dataSession.hasOwnProperty("rewardLink") && this.m_dataSession.hasOwnProperty("imagePath"))
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_dataSession.adoptionCode);
            bundle = this.m_dataSession.featureName + "_Adopt";
            bundleData = {};
            bundleData["reward_link"] = this.m_dataSession.rewardLink;
            bundleData["itemName"] = item.friendlyName;
            bundleData["animalName"] = this.m_dataSession.animalName;
            bundleData["images"] = [{
               "src":this.m_dataSession.imagePath,
               "href":Config.SN_APP_URL + this.m_dataSession.rewardLink
            }];
            GlobalEngine.socialNetwork.publishFeedStory(bundle,bundleData,[],false);
            this.m_dataSession = {};
         }
      }
      
      private function canAskForLovePotions() : Boolean
      {
         var result:Boolean = false;
         var interval:Number = Global.farmGameSettingsManager.getAttribute("BreedingAskLovePotionsTimeLimit",14400);
         if(GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(LOVE_POTION_FEATURE_KEY) >= interval)
         {
            result = true;
         }
         return result;
      }
      
      public function setAnimalName(itemCode:String, metaHash:String, name:String, worldId:Number = -1, building:FeatureBuilding = null, callback:Function = null) : void
      {
         var mutableState:MutableAnimalState = null;
         var itemHasMetadata:Boolean = false;
         var storageHash:String = null;
         var storageMetadata:Object = null;
         var newHash:String = null;
         var giftData:StorageItem = null;
         var extraData:Array = null;
         var farmItem:FarmItem = null;
         var index:String = null;
         var worldObj:FarmGameObject = null;
         if(building)
         {
            itemHasMetadata = false;
            storageHash = FeatureBuilding.buildMetaDataHash(itemCode,metaHash);
            storageMetadata = building.storageMetaData;
            if(Boolean(storageMetadata[storageHash]) && Boolean(storageMetadata[storageHash][0]))
            {
               mutableState = new MutableAnimalState(metaHash,com.adobe.serialization.json.JSON.decode(storageMetadata[storageHash][0]),storageMetadata[storageHash][0]);
            }
            else
            {
               mutableState = new MutableAnimalState("",{},"");
            }
            mutableState.name = name;
            newHash = FeatureBuilding.buildMetaDataHash(itemCode,mutableState.getHashKey());
            if(newHash != storageHash)
            {
               delete storageMetadata[storageHash];
               storageMetadata[newHash] = new Array(mutableState.getPackedMutableState());
            }
            else
            {
               storageMetadata[storageHash][0] = mutableState.getPackedMutableState();
            }
         }
         else if(worldId < 0)
         {
            giftData = Global.player.gifts[itemCode];
            if(giftData != null)
            {
               extraData = giftData.getAllExtraData();
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               for(index in extraData)
               {
                  mutableState = MutableAnimalState.createFromPhpString("",String(extraData[index]));
                  if(mutableState != null && mutableState.getHashKey() == metaHash)
                  {
                     mutableState.dna[MutableAnimalState.NAME_DATA_KEY] = name;
                     extraData[index] = mutableState.getPackedMutableState();
                     break;
                  }
               }
            }
         }
         else
         {
            worldObj = Global.world.getObjectById(worldId) as FarmGameObject;
            if(worldObj != null)
            {
               worldObj.updatePersonalName(name);
            }
         }
         TransactionManager.addTransaction(new TAnimalSetName(itemCode,metaHash,name,worldId,building,callback),false);
      }
      
      public function findFreeSlot(breedSession:AnimalBreedingSession) : Number
      {
         var expandLevel:Number = NaN;
         var i:Number = NaN;
         var freeSlot:Number = -1;
         var animalState:AnimalBreedingState = breedSession.owner.extraDataState as AnimalBreedingState;
         if(animalState != null)
         {
            expandLevel = breedSession.owner.storageLevel;
            for(i = 0; i < expandLevel; i++)
            {
               if(animalState.getBreedSession(i) == null)
               {
                  freeSlot = i;
                  break;
               }
            }
         }
         return freeSlot;
      }
      
      public function getNumBreedingSessions(featureBuilding:FeatureBuilding) : Number
      {
         var expandLevel:Number = NaN;
         var i:Number = NaN;
         var sessions:Number = 0;
         var animalState:AnimalBreedingState = featureBuilding.extraDataState as AnimalBreedingState;
         if(null != animalState)
         {
            expandLevel = featureBuilding.storageLevel;
            for(i = 0; i < expandLevel; i++)
            {
               if(null != animalState.getBreedSession(i))
               {
                  sessions++;
               }
            }
         }
         return sessions;
      }
      
      public function processBreedResult(breedingSession:AnimalBreedingSession, result:Object) : void
      {
         var item:FarmItem = null;
         if(breedingSession != null && breedingSession.owner != null)
         {
            this.updateBreedingState(breedingSession,result);
            if(result.reward != null && result.reward.itemName != null)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(result.reward.itemName);
               if(item != null)
               {
                  Global.player.addMutableItemToGiftbox(item.code,result.reward.mutableState);
                  this.grantBreedingXpForAction(breedingSession.owner.getItem().name,AnimalBreedingConfigSettings.XP_ACTION_BREED_SUCCESS);
               }
            }
         }
      }
      
      public function updateBreedingState(breedingSession:AnimalBreedingSession, result:Object) : void
      {
         if(breedingSession != null && breedingSession.owner != null)
         {
            breedingSession.owner.extraDataState.loadObject(result);
         }
      }
      
      public function getNumPotions() : Number
      {
         var numPotions:Number = 0;
         var lovePotions:StorageItem = Global.player.gifts[AnimalBreedingManager.LOVE_POTION_ITEM_CODE];
         if(lovePotions != null)
         {
            numPotions = lovePotions.quantity;
         }
         return numPotions;
      }
      
      public function getMutableAnimalCount(featureBuilding:FeatureBuilding) : Number
      {
         var animalName:String = null;
         var animalNameList:Array = Global.animalBreedingSettings.getMutableAnimals(featureBuilding.getItem().name);
         var count:Number = 0;
         var worldCount:Number = 0;
         var giftBoxCount:Number = 0;
         var inPenCount:Number = 0;
         var farmItem:FarmItem = null;
         for each(animalName in animalNameList)
         {
            if(Global.animalBreedingSettings.isLimitedItem(animalName))
            {
               worldCount = Global.world.getObjectsByName(animalName).length;
               giftBoxCount = Global.player.getGiftCountForItem(animalName);
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(animalName);
               inPenCount = featureBuilding.contents[farmItem.code] != null ? Number(featureBuilding.contents[farmItem.code]) : 0;
               count += worldCount + giftBoxCount + inPenCount;
            }
         }
         return count;
      }
      
      public function getColorName(metadata:Object, metadataKey:String = "B") : String
      {
         var key:String = null;
         var metadataConfig:Object = null;
         var metadataColor:Object = null;
         var result:String = null;
         var colors:Dictionary = Global.animalBreedingSettings.colors;
         for(key in colors)
         {
            if(metadata.hasOwnProperty("data"))
            {
               metadataConfig = com.adobe.serialization.json.JSON.decode(metadata.data);
               if(metadataConfig.hasOwnProperty(metadataKey))
               {
                  metadataColor = metadataConfig[metadataKey];
                  if(metadataColor[MutableAnimalState.HUE_DATA_KEY][0] == colors[key][MutableAnimalState.HUE_DATA_KEY][0] && metadataColor[MutableAnimalState.HUE_DATA_KEY][1] == colors[key][MutableAnimalState.HUE_DATA_KEY][1] && metadataColor[MutableAnimalState.SATURATION_DATA_KEY][0] == colors[key][MutableAnimalState.SATURATION_DATA_KEY][0] && metadataColor[MutableAnimalState.SATURATION_DATA_KEY][1] == colors[key][MutableAnimalState.SATURATION_DATA_KEY][1] && metadataColor[MutableAnimalState.INTENSITY_DATA_KEY][0] == colors[key][MutableAnimalState.INTENSITY_DATA_KEY][0] && metadataColor[MutableAnimalState.INTENSITY_DATA_KEY][1] == colors[key][MutableAnimalState.INTENSITY_DATA_KEY][1])
                  {
                     result = key;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getPatternCodeFromMetadata(metadata:Object) : String
      {
         var metadataObj:Object = null;
         var result:String = null;
         if(metadata.hasOwnProperty("data"))
         {
            metadataObj = com.adobe.serialization.json.JSON.decode(metadata.data);
            result = metadataObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY];
         }
         return result;
      }
      
      public function generateFixedBreedItemState(breedData:AnimalBreedingSession) : Vector.<MutableAnimalState>
      {
         var breedingObject:MutableAnimalState = null;
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         var breedingMetadata:Object = null;
         var jsonString:String = null;
         var duplicate:Boolean = false;
         var itemHash:String = null;
         var resultState:MutableAnimalState = null;
         var result:Vector.<MutableAnimalState> = new Vector.<MutableAnimalState>();
         var jsonStrings:Array = new Array();
         var breedItemObj:Object = new Object();
         this.m_breedData = breedData;
         var breedingObjects:Array = breedData.getBreedObjects().slice();
         var baseColors:Array = new Array();
         var basePatternStyles:Array = new Array();
         var basePatternColors:Array = new Array();
         var featureName:String = breedData.owner.getItemName();
         var breedHistory:Object = (breedData.owner.extraDataState as AnimalBreedingState).getBreedingHistory();
         breedItemObj[MutableAnimalState.NAME_DATA_KEY] = "";
         var breedGender:String = this.generateBreedGender(featureName,breedHistory.hasOwnProperty("gender") && breedHistory.gender != null ? breedHistory.gender : "");
         breedItemObj[MutableAnimalState.GENDER_DATA_KEY] = breedGender;
         for each(breedingObject in breedingObjects)
         {
            baseColors.push(breedingObject.dna[MutableAnimalState.BASE_COLOR_DATA_KEY]);
            basePatternColors.push(breedingObject.dna[MutableAnimalState.PATTERN_DATA_KEY]);
            basePatternStyles.push(breedingObject.dna[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY]);
         }
         for(i = 0; i < baseColors.length; i++)
         {
            for(j = 0; j < basePatternColors.length; j++)
            {
               for(k = 0; k < basePatternStyles.length; k++)
               {
                  breedingMetadata = {};
                  breedingMetadata[MutableAnimalState.NAME_DATA_KEY] = "";
                  breedingMetadata[MutableAnimalState.GENDER_DATA_KEY] = breedItemObj[MutableAnimalState.GENDER_DATA_KEY];
                  breedingMetadata[MutableAnimalState.BASE_COLOR_DATA_KEY] = baseColors[i];
                  breedingMetadata[MutableAnimalState.PATTERN_DATA_KEY] = basePatternColors[j];
                  breedingMetadata[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY] = basePatternStyles[k];
                  jsonString = com.adobe.serialization.json.JSON.encode(breedingMetadata);
                  jsonStrings.push(jsonString);
               }
            }
         }
         var tmp:Array = new Array();
         for(i = 0; i < jsonStrings.length; i++)
         {
            duplicate = false;
            j = 0;
            while(j < tmp.length && !duplicate)
            {
               if(jsonStrings[i] == tmp[j])
               {
                  duplicate = true;
               }
               j++;
            }
            if(!duplicate)
            {
               tmp.push(jsonStrings[i]);
            }
         }
         jsonStrings = tmp;
         for(i = 0; i < jsonStrings.length; i++)
         {
            jsonString = jsonStrings[i];
            itemHash = Global.farmGameSettingsManager.getFarmItemCodeByName(Global.animalBreedingSettings.getItemNameFromGender(featureName,breedGender)) + ":";
            resultState = MutableAnimalState.createFromPhpString(itemHash,jsonString);
            result.push(resultState);
         }
         var startingParentIndex:int = Math.round(Math.random() * (breedingObjects.length - 1));
         var baseColor:Object = null;
         baseColor = (breedingObjects[startingParentIndex] as MutableAnimalState).dna[MutableAnimalState.BASE_COLOR_DATA_KEY];
         baseColor = this.generateHSV(baseColor);
         breedItemObj[MutableAnimalState.BASE_COLOR_DATA_KEY] = this.generateBreedBase(breedingObjects,featureName);
         breedItemObj[MutableAnimalState.PATTERN_DATA_KEY] = this.generateBreedPattern(breedingObjects,featureName);
         jsonString = com.adobe.serialization.json.JSON.encode(breedItemObj);
         itemHash = Global.farmGameSettingsManager.getFarmItemCodeByName(Global.animalBreedingSettings.getItemNameFromGender(featureName,breedGender)) + ":";
         resultState = MutableAnimalState.createFromPhpString(itemHash,jsonString);
         return result;
      }
      
      public function generateBreedItemState(breedData:AnimalBreedingSession) : MutableAnimalState
      {
         var breedItemObj:Object = new Object();
         this.m_breedData = breedData;
         var breedingObjects:Array = breedData.getBreedObjects().slice();
         var featureName:String = breedData.owner.getItemName();
         var breedHistory:Object = (breedData.owner.extraDataState as AnimalBreedingState).getBreedingHistory();
         breedItemObj[MutableAnimalState.NAME_DATA_KEY] = "";
         var breedGender:String = this.generateBreedGender(featureName,breedHistory.hasOwnProperty("gender") && breedHistory.gender != null ? breedHistory.gender : "");
         breedItemObj[MutableAnimalState.GENDER_DATA_KEY] = breedGender;
         breedItemObj[MutableAnimalState.BASE_COLOR_DATA_KEY] = this.generateBreedBase(breedingObjects,featureName);
         breedItemObj[MutableAnimalState.PATTERN_DATA_KEY] = this.generateBreedPattern(breedingObjects,featureName);
         var jsonString:String = com.adobe.serialization.json.JSON.encode(breedItemObj);
         var itemHash:String = Global.farmGameSettingsManager.getFarmItemCodeByName(Global.animalBreedingSettings.getItemNameFromGender(featureName,breedGender)) + ":";
         return MutableAnimalState.createFromPhpString(itemHash,jsonString);
      }
      
      private function generateBreedGender(featureName:String, breedingGenderHistory:String) : String
      {
         var breedingGenderHistoryAtIndex:String = null;
         var femaleChance:Number = Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"genderFemaleChance"));
         var selectedGender:String = "";
         if(Math.random() <= femaleChance)
         {
            selectedGender = MutableAnimalState.GENDER_CODE_FEMALE;
         }
         else
         {
            selectedGender = MutableAnimalState.GENDER_CODE_MALE;
         }
         var currentGender:String = "";
         var dupeCount:int = 0;
         for(var historyIndex:int = 0; historyIndex < breedingGenderHistory.length; historyIndex++)
         {
            breedingGenderHistoryAtIndex = breedingGenderHistory.charAt(historyIndex);
            if(breedingGenderHistoryAtIndex != currentGender)
            {
               currentGender = breedingGenderHistoryAtIndex;
               dupeCount = 1;
            }
            if(dupeCount >= AnimalBreedingState.HISTORY_GENDER_MAX_DUPES)
            {
               if(currentGender == MutableAnimalState.GENDER_CODE_FEMALE)
               {
                  selectedGender = MutableAnimalState.GENDER_CODE_MALE;
               }
               else
               {
                  selectedGender = MutableAnimalState.GENDER_CODE_FEMALE;
               }
            }
            dupeCount++;
         }
         return selectedGender;
      }
      
      private function generateHSV(baseColor:Object) : Object
      {
         var resultObject:Object = new Object();
         var generatedHue:String = getRandomValueRange(parseInt(baseColor[MutableAnimalState.HUE_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX],16),0,MutableAnimalState.HUE_RANGE - 1,MutableAnimalState.HUE_MAX_VARIANCE);
         var generatedSaturation:String = getRandomValueRange(parseInt(baseColor[MutableAnimalState.SATURATION_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX],16),0,MutableAnimalState.SATURATION_RANGE - 1,MutableAnimalState.SATURATION_MAX_VARIANCE,true,true);
         var generatedIntensity:String = getRandomValueRange(parseInt(baseColor[MutableAnimalState.INTENSITY_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX],16),0,MutableAnimalState.INTENSITY_RANGE - 1,MutableAnimalState.INTENSITY_MAX_VARIANCE,true,true);
         resultObject[MutableAnimalState.HUE_DATA_KEY] = new Array(generatedHue,generatedHue);
         resultObject[MutableAnimalState.SATURATION_DATA_KEY] = new Array(generatedSaturation,generatedSaturation);
         resultObject[MutableAnimalState.INTENSITY_DATA_KEY] = new Array(generatedIntensity,generatedIntensity);
         return resultObject;
      }
      
      private function generateColorChangingHSV() : Object
      {
         var resultObject:Object = {};
         resultObject[MutableAnimalState.HUE_DATA_KEY] = new Array(MutableAnimalState.HUE_RANGE,MutableAnimalState.HUE_RANGE);
         resultObject[MutableAnimalState.SATURATION_DATA_KEY] = new Array("f","f");
         resultObject[MutableAnimalState.INTENSITY_DATA_KEY] = new Array("f","f");
         return resultObject;
      }
      
      private function generateFailedColorChaningHSV() : Object
      {
         var resultObject:Object = {};
         resultObject[MutableAnimalState.HUE_DATA_KEY] = new Array("c7","c7");
         resultObject[MutableAnimalState.SATURATION_DATA_KEY] = new Array("f","f");
         resultObject[MutableAnimalState.INTENSITY_DATA_KEY] = new Array("f","f");
         return resultObject;
      }
      
      private function generateBreedBase(breedingObjects:Array, featureName:String) : Object
      {
         var breedingObject:MutableAnimalState = null;
         var baseColor:Object = null;
         var isBreedingChaningColorMale:Boolean = false;
         for each(breedingObject in breedingObjects)
         {
            if(breedingObject.isMale() && breedingObject.hue() >= MutableAnimalState.HUE_RANGE)
            {
               isBreedingChaningColorMale = true;
               break;
            }
         }
         baseColor = null;
         if(isBreedingChaningColorMale)
         {
            baseColor = this.generateBreedBaseFromColorChangingParents(breedingObjects,featureName);
         }
         else
         {
            baseColor = this.generateGenericBreedBase(breedingObjects);
         }
         return baseColor;
      }
      
      private function generateGenericBreedBase(breedingObjects:Array) : Object
      {
         var baseColor:Object = null;
         var startingParentIndex:int = Math.round(Math.random() * (breedingObjects.length - 1));
         baseColor = (breedingObjects[startingParentIndex] as MutableAnimalState).dna[MutableAnimalState.BASE_COLOR_DATA_KEY];
         return this.generateHSV(baseColor);
      }
      
      private function generateBreedBaseFromColorChangingParents(breedingObjects:Array, featureName:String) : Object
      {
         var breedingObject:MutableAnimalState = null;
         var startingParentIndex:int = 0;
         var baseColor:Object = null;
         var parentsHaveSamePattern:Boolean = false;
         var isBreedingWithColorChangingFemale:Boolean = false;
         var femaleBreedingData:MutableAnimalState = null;
         for each(breedingObject in breedingObjects)
         {
            if(breedingObject.isMale() == false)
            {
               if(breedingObject.hue() >= MutableAnimalState.HUE_RANGE)
               {
                  isBreedingWithColorChangingFemale = true;
                  parentsHaveSamePattern = true;
               }
               femaleBreedingData = breedingObject;
               break;
            }
         }
         if(femaleBreedingData)
         {
            baseColor = this.generateHSV(femaleBreedingData.dna[MutableAnimalState.BASE_COLOR_DATA_KEY]);
            if(this.shouldInheritPattern(featureName,parentsHaveSamePattern) == true)
            {
               baseColor = this.generateColorChangingHSV();
            }
            else if(isBreedingWithColorChangingFemale == true)
            {
               baseColor = this.generateFailedColorChaningHSV();
            }
         }
         else
         {
            startingParentIndex = Math.round(Math.random() * (breedingObjects.length - 1));
            baseColor = (breedingObjects[startingParentIndex] as MutableAnimalState).dna[MutableAnimalState.BASE_COLOR_DATA_KEY];
         }
         return baseColor;
      }
      
      private function generateBreedPattern(breedingObjects:Array, featureName:String) : Object
      {
         var parentObject:MutableAnimalState = null;
         var currentPattern:String = null;
         var startingParentIndex:int = Math.round(Math.random() * (breedingObjects.length - 1));
         var breedingObject:MutableAnimalState = breedingObjects[startingParentIndex] as MutableAnimalState;
         var baseColor:Object = breedingObject.dna[MutableAnimalState.PATTERN_DATA_KEY];
         var patternType:String = null;
         var parentsSamePattern:Boolean = false;
         var samePatternHash:Object = new Object();
         for each(parentObject in breedingObjects)
         {
            if(parentObject.gender == MutableAnimalState.GENDER_CODE_MALE)
            {
               patternType = parentObject.pattern;
            }
            currentPattern = parentObject.pattern;
            if(samePatternHash.hasOwnProperty(currentPattern) == false)
            {
               samePatternHash[currentPattern] = 0;
            }
            ++samePatternHash[currentPattern];
            if(samePatternHash[currentPattern] > 1)
            {
               parentsSamePattern = true;
            }
         }
         if(this.shouldInheritPattern(featureName,parentsSamePattern) == false)
         {
            patternType = String(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"defaultPatternCode"));
         }
         if(breedingObject.hue(true) >= MutableAnimalState.HUE_RANGE)
         {
            baseColor = this.generateColorChangingHSV();
         }
         else
         {
            baseColor = this.generateHSV(baseColor);
         }
         baseColor[MutableAnimalState.TYPE_DATA_KEY] = patternType;
         return baseColor;
      }
      
      protected function shouldInheritPattern(featureName:String, areParentsSamePattern:Boolean) : Boolean
      {
         var result:Boolean = true;
         var patternChance:Number = this.getPatternChance(featureName);
         if(areParentsSamePattern)
         {
            patternChance *= Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"samePatternMultiplier"));
         }
         var randomNum:Number = Math.random();
         if(randomNum > patternChance)
         {
            result = false;
         }
         return result;
      }
      
      private function getPatternChance(featureName:String) : Number
      {
         var result:Number = 0;
         if(this.m_breedData.hasOwnProperty("patternGuarantee") && this.m_breedData.patternGuarantee == true)
         {
            result = 1;
         }
         else
         {
            result = this.getRuntimePatternChance(featureName);
            if(result == 0)
            {
               result = Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"patternChance"));
            }
         }
         return result;
      }
      
      public function getRuntimePatternChance(featureName:String) : Number
      {
         var result:Number = 0;
         switch(featureName)
         {
            case SHEEP_FEATURE_NAME:
               result = Number(Global.flashHotParams["SHEEP_PATTERN_INHERIT_CHANCE"]);
               break;
            case PIGS_FEATURE_NAME:
               result = Number(Global.flashHotParams["PIGS_PATTERN_INHERIT_CHANCE"]);
         }
         return result / 100;
      }
      
      public function grantBreedingXp(featureName:String, xpAmount:int) : void
      {
         var skillState:AnimalBreedingSkillState = null;
         var rewards:Object = null;
         var milestoneRewards:Array = null;
         if(Global.animalBreedingSettings.haveLevelDefinitionsForFeature(featureName))
         {
            skillState = Global.player.getBreedingSkillStateForFeature(featureName);
            rewards = new Object();
            skillState.grantXp(xpAmount);
            milestoneRewards = skillState.checkAndAwardMilestones();
            rewards = skillState.checkAndAwardLevel();
            if(milestoneRewards.length > 0 && !rewards.hasOwnProperty("milestones"))
            {
               rewards["milestones"] = milestoneRewards;
            }
            else if(rewards.hasOwnProperty("milestones"))
            {
               rewards["milestones"] = (rewards["milestones"] as Array).concat(milestoneRewards);
            }
            if(rewards != null)
            {
               this.checkAndShowDialog(featureName,rewards);
            }
            dispatchEvent(new BreedingXpGrantEvent(BreedingXpGrantEvent.BREEDING_XP_GRANT,xpAmount,rewards));
         }
      }
      
      public function grantBreedingXpForAction(featureName:String, action:String) : void
      {
         var xpToAdd:int = 0;
         if(Global.animalBreedingSettings.haveLevelDefinitionsForFeature(featureName))
         {
            xpToAdd = int(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,action));
            this.grantBreedingXp(featureName,xpToAdd);
         }
      }
      
      public function checkAndShowDialog(featureName:String, rewards:Object) : void
      {
         var skillState:AnimalBreedingSkillState = Global.player.getBreedingSkillStateForFeature(featureName);
         if(skillState.level == 1 && skillState.getNumMilestonesAcheived() == 1)
         {
            if(!Global.player.getSeenFlag(FIRST_MILESTONE))
            {
               Global.player.setSeenFlag(FIRST_MILESTONE);
               this.showFirstMilestoneDialog();
            }
         }
         else if(skillState.level == 2 && rewards.hasOwnProperty("levelups"))
         {
            this.showOnboardingLevelUpDialog(featureName);
         }
         else if(skillState.level == 30 && rewards.hasOwnProperty("levelups"))
         {
            this.showLevelThirtyDialog(featureName,rewards);
         }
         else if(rewards.hasOwnProperty("levelups"))
         {
            this.showLevelUpDialog(featureName);
         }
      }
      
      public function showLevelUpDialog(featureName:String) : void
      {
         var dialog:FarmDynamicDialog = FarmDynamicDialog.createDialog("BreedingLevelUpDialog",BreedingLevelupDialog) as FarmDynamicDialog;
         if(dialog)
         {
            dialog.addImport(BreedingLevelupDialog.IMPORT_FEATURE_NAME,featureName);
            dialog.setup();
            dialog.show();
         }
      }
      
      public function showFirstMilestoneDialog() : void
      {
         var dialog:FarmDynamicDialog = FarmDynamicDialog.createDialog("BreedingLevelMilestone",FarmDynamicDialog);
         if(dialog)
         {
            dialog.setup();
            dialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_Milestone_Title"));
            dialog.setShortcutAttribute("BreedingMilestoneHead",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_Milestone_Header"));
            dialog.setShortcutAttribute("BreedingMilestoneBody",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_Milestone_Body"));
            dialog.setShortcutAttribute("okayButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
            dialog.show();
         }
      }
      
      public function showOnboardingLevelUpDialog(featureName:String) : void
      {
         var dialog:FarmDynamicDialog = null;
         var skillState:AnimalBreedingSkillState = null;
         var reward:Object = null;
         var breedingLevelBurstAsset:String = null;
         var tutorial1Asset:String = null;
         var tutorial2Asset:String = null;
         var descriptionKey:String = null;
         var pane2TextKey:String = null;
         var rewardItem:FarmItem = null;
         dialog = FarmDynamicDialog.createDialog("BreedingOnboarding",FarmDynamicDialog);
         skillState = Global.player.getBreedingSkillStateForFeature(featureName);
         var bigRewardLevel:int = Global.animalBreedingSettings.getNextBigReward(skillState.level);
         var bigReward:Array = Global.animalBreedingSettings.getRewardsForLevel(bigRewardLevel,featureName);
         if(dialog)
         {
            dialog.setup();
            for each(reward in bigReward)
            {
               if(reward.hasOwnProperty("bigReward") && reward["bigReward"] == "true")
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
                  if(rewardItem != null)
                  {
                     dialog.setShortcutAttribute("NextLevelNum",TextFieldView.ATTRIBUTE_TEXT,bigRewardLevel < 10 ? " " + bigRewardLevel.toString() : bigRewardLevel.toString());
                     dialog.setShortcutAttribute("NextRewardImage",ImageController.ATTRIBUTE_SOURCE,rewardItem.icon);
                     dialog.setShortcutAttribute("NextRewardName",TextFieldView.ATTRIBUTE_TEXT,rewardItem.friendlyTitle);
                  }
               }
            }
            breedingLevelBurstAsset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + featureName + "/breedingLevelBurst.png";
            dialog.setShortcutAttribute("levelIcon",ImageController.ATTRIBUTE_SOURCE,breedingLevelBurstAsset);
            tutorial1Asset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + featureName + "/LevelUpTut_img1.png";
            dialog.setShortcutAttribute("pane2Image",ImageController.ATTRIBUTE_SOURCE,tutorial1Asset);
            tutorial2Asset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + featureName + "/LevelUpTut_img2.png";
            dialog.setShortcutAttribute("pane3Image",ImageController.ATTRIBUTE_SOURCE,tutorial2Asset);
            dialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_Onboarding_Title"));
            descriptionKey = "Breeding_" + featureName + "_Onboarding_Description";
            dialog.setShortcutAttribute("Description",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",descriptionKey));
            pane2TextKey = "Breeding_" + featureName + "_Onboarding_Pane2";
            dialog.setShortcutAttribute("pane2Text",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",pane2TextKey));
            dialog.setShortcutAttribute("pane3Text",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_Onboarding_Pane3"));
            dialog.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","BreedingShareButton"));
            dialog.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,function(event:WidgetControllerEvent):void
            {
               dialog.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_DISABLED,true);
               TransactionManager.addTransaction(new TGetBreedingLevelUpShareLink(featureName,skillState.level));
            });
            dialog.show();
         }
      }
      
      public function showLevelThirtyDialog(featureName:String, rewards:Object) : void
      {
         var dialog:FarmDynamicDialog = null;
         var skillState:AnimalBreedingSkillState = null;
         var reward:Object = null;
         var breedingLevelBurstAsset:String = null;
         var nextRewardAsset:String = null;
         dialog = FarmDynamicDialog.createDialog("BreedingLevelThirtyDialog",FarmDynamicDialog);
         skillState = Global.player.getBreedingSkillStateForFeature(featureName);
         var rewardItem:FarmItem = null;
         if(dialog)
         {
            dialog.setup();
            for each(reward in rewards["levelups"])
            {
               if(reward.hasOwnProperty("bigReward") && reward["bigReward"] == "true")
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
                  break;
               }
            }
            breedingLevelBurstAsset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + featureName + "/breedingLevelBurst.png";
            dialog.setShortcutAttribute("levelIcon",ImageController.ATTRIBUTE_SOURCE,breedingLevelBurstAsset);
            nextRewardAsset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + featureName + "/blackoutIcon.png";
            dialog.setShortcutAttribute("NextRewardImage",ImageController.ATTRIBUTE_SOURCE,nextRewardAsset);
            dialog.setShortcutAttribute("RewardImage1",ImageController.ATTRIBUTE_SOURCE,rewardItem.icon);
            dialog.setShortcutAttribute("RewardName1",TextFieldView.ATTRIBUTE_TEXT,rewardItem.friendlyTitle);
            dialog.setShortcutAttribute("LevelNum",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",skillState.level.toString()));
            dialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_LevelThirty_Title"));
            dialog.setShortcutAttribute("LevelUpText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_" + featureName + "_LevelThirty_Body"));
            dialog.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","BreedingShareButton"));
            dialog.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,function(event:WidgetControllerEvent):void
            {
               dialog.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_DISABLED,true);
               TransactionManager.addTransaction(new TGetBreedingLevelUpShareLink(featureName,skillState.level));
            });
            dialog.show();
         }
      }
      
      public function isInGuaranteePatternExperiment() : Boolean
      {
         return true;
      }
      
      public function get guaranteePatternPrice() : int
      {
         return 5;
      }
   }
}

