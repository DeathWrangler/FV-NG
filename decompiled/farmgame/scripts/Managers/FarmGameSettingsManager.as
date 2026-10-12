package Managers
{
   import Classes.Achievement;
   import Classes.AdItem;
   import Classes.Avatar.AvatarItem;
   import Classes.Collections.Collection;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.XMLKeys;
   import Classes.DataSources.OptItemDataSource;
   import Classes.DataSources.XMLDataSource;
   import Classes.FactoryItem;
   import Classes.FactoryItemLevel;
   import Classes.FarmGameObject;
   import Classes.FriendSetGoal;
   import Classes.GrowableAnimalItem;
   import Classes.LockedExplanations.ExpansionItemLockedExplanationHandler;
   import Classes.LockedExplanations.MOTDLockedExplanationHandler;
   import Classes.MOTD.BirthdayFreeGiftsMOTDHandler;
   import Classes.MOTD.BreedingBuildingExpansionsMOTDHandler;
   import Classes.MOTD.CategorySpecificSaleMOTDHandler;
   import Classes.MOTD.ChristmasCharityBundleMOTDHandler;
   import Classes.MOTD.CollectionsOffBoardMOTDHandler;
   import Classes.MOTD.CollectionsOnboardingMOTDHandler;
   import Classes.MOTD.CommunityGoalsMOTDHandler;
   import Classes.MOTD.CommunityNeighborsMOTDHandler;
   import Classes.MOTD.CraftingV2MOTDHandler;
   import Classes.MOTD.CraftingV4MOTDHandler;
   import Classes.MOTD.CropBonanzaV2MOTDHandler;
   import Classes.MOTD.CustomActionMOTDHandler;
   import Classes.MOTD.CustomWindowActionMOTDHandler;
   import Classes.MOTD.CustomWindowMOTDHandler;
   import Classes.MOTD.DialogMOTDHandler;
   import Classes.MOTD.EarlyAccessRepopMOTDHandler;
   import Classes.MOTD.ExpansionAccessMotdHandler;
   import Classes.MOTD.ExpansionContentEarlyAccessMotdHandler;
   import Classes.MOTD.ExpansionEASeasonMotdHandler;
   import Classes.MOTD.ExpansionEarlyAccessChristmasPatchMotdHandler;
   import Classes.MOTD.ExpansionEarlyAccessMotdHandler;
   import Classes.MOTD.ExpansionFestivalOfColorMotdHandler;
   import Classes.MOTD.ExpansionGASeasonMotdHandler;
   import Classes.MOTD.ExpansionTeaserMotdHandler;
   import Classes.MOTD.FarmRunQuestsMOTDHandler;
   import Classes.MOTD.FeatureFrequencyMOTDHandler;
   import Classes.MOTD.FinishAllBuildingsMOTDHandler;
   import Classes.MOTD.FlashUpgradeMOTDHandler;
   import Classes.MOTD.ForcePlaceMOTDHandler;
   import Classes.MOTD.GenericCharityMOTDHandler;
   import Classes.MOTD.HolidayCountdownMOTDHandler;
   import Classes.MOTD.ItemByWorldMOTDHandler;
   import Classes.MOTD.LELastChanceMOTDHandler;
   import Classes.MOTD.LaunchAmexURLMotdHandler;
   import Classes.MOTD.LaunchRTURLMotdHandler;
   import Classes.MOTD.LaunchSurveyURLMotdHandler;
   import Classes.MOTD.LaunchURLMotdHandler;
   import Classes.MOTD.LimitedQuantityBundleMOTDHandler;
   import Classes.MOTD.LimitedSalePostInitAction;
   import Classes.MOTD.LongWeekEndDelightMOTDHandler;
   import Classes.MOTD.MarketFlashSaleMOTDHandler;
   import Classes.MOTD.MultiStageQuestMOTDHandler;
   import Classes.MOTD.MultiTaskLeaderboardMOTDHandler;
   import Classes.MOTD.MysteryCrateMOTDHandler;
   import Classes.MOTD.MystreeBabiesMOTDHandler;
   import Classes.MOTD.NeighborCleanupMOTDHandler;
   import Classes.MOTD.OlyInnovationMOTDHandler;
   import Classes.MOTD.OpenMarketMOTDHandler;
   import Classes.MOTD.OpenQuestManagerMOTDHandler;
   import Classes.MOTD.PigPenBreedingMOTDHandler;
   import Classes.MOTD.PremarketingEarlyAccessMotdHandler;
   import Classes.MOTD.PremarketingGeneralAccessMotdHandler;
   import Classes.MOTD.SeasonEAMOTDHandler;
   import Classes.MOTD.SeasonGAMOTDHandler;
   import Classes.MOTD.SeasonUnlockMotdHandler;
   import Classes.MOTD.SheepPenBreedingMOTDHandler;
   import Classes.MOTD.SocialRaffleMOTDHandler;
   import Classes.MOTD.SpendometerMOTDHandler;
   import Classes.MOTD.SubscriptionRevampMOTDHandler;
   import Classes.MOTD.SubscriptionsMOTDHandler;
   import Classes.MOTD.SubscriptionsV2BenefitsMOTDHandler;
   import Classes.MOTD.SubscriptionsV2MOTDHandler;
   import Classes.MOTD.TopPhotosMOTDHandler;
   import Classes.MOTD.TrickOrTreatMOTDHandler;
   import Classes.MOTD.UltimateStarterPackMOTDHandler;
   import Classes.MOTD.UnlimitedPacksMOTDHandler;
   import Classes.MOTD.WorldSpecificSaleMOTDHandler;
   import Classes.MOTD.ZCacheMOTDHandler;
   import Classes.ManagedSale;
   import Classes.MarketMapping;
   import Classes.Mastery;
   import Classes.Minigames.MinigameData;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleHarvestableItem;
   import Classes.StarterPack.StarterPack;
   import Classes.StarterPack.StarterPackUtility;
   import Classes.SuperCropRequirement;
   import Classes.TernaryTree;
   import Classes.Terrain.TerrainUtil;
   import Classes.UGC.UGCItemDefinition;
   import Classes.ZItem.AnimalItem;
   import Classes.ZItem.BuffItem;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.BushelItem;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.ClothingItem;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.ContentAccessSettings;
   import Classes.ZItem.CurrencyData;
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.EquipmentItem;
   import Classes.ZItem.EvolutionAnimalItem;
   import Classes.ZItem.ExchangeCurrencyItem;
   import Classes.ZItem.ExpansionAccessItem;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.ExpansionEarlyAccessGiftingData;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.ZItem.FuelItem;
   import Classes.ZItem.GopherItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.ItemLicense;
   import Classes.ZItem.MarketStallBuildingItem;
   import Classes.ZItem.MultiRewardTreasureConstructionBuildingItem;
   import Classes.ZItem.MutableDragonItem;
   import Classes.ZItem.PetFarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.ZItem.StarterPackItem;
   import Classes.ZItem.StencilPortalItem;
   import Classes.ZItem.TreeItem;
   import Classes.ZItem.TurboItem;
   import Classes.ZItem.UGCAnimalItem;
   import Classes.ZItem.UGCDecorationItem;
   import Classes.ZItem.ZItemBase;
   import Classes.consumables.CPigoGameToken;
   import Classes.util.FarmGameUtil;
   import Classes.util.FarmLoadPhaseMonitor;
   import Classes.util.UserRewardUtil;
   import DataObjects.DataObjectsRegistrar;
   import DataObjects.Items.BaseItemDO;
   import DataSources.BaseDataSource;
   import DataSources.DataObjectDataSource;
   import Display.QueuedIcon;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Init.FarmGameSettingsInit;
   import MyLife.MyLifeUtils;
   import Widgets.Constants.Market.Currency;
   import ZQuest.Init.QuestSettingsInit;
   import flash.net.registerClassAlias;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import flash.utils.getTimer;
   
   public class FarmGameSettingsManager extends ZGameSettingsManager implements IExternalizable
   {
      
      private static const MAX_QUEST_CATEGORIES:Number = 64;
      
      private static const DEFAULT_SEED_PACKAGE_SIZE_KEY:String = "CSeedPackageSize";
      
      private static const MOTD_ICON_BACKLOG_MAX:int = 3;
      
      private static const PREREQ_KEY_WORLD_SCORE_LEVEL_MIN:String = "world_level_min";
      
      private static const IN_MAX:int = 1;
      
      private static const IN_MIN:int = -1;
      
      private static const RANK_ANIMAL_TYPE:int = 2;
      
      private static const RANK_TREE_TYPE:int = 1;
      
      private static const ANIMAL_TYPE:String = "animal";
      
      private static const TREE_TYPE:String = "tree";
      
      private static const CASH_MULTIPLIER:Number = 10000000;
      
      private static const ITEMS_AMF_FORCE_OFF:String = "ITEMS_AMF_FORCE_OFF";
      
      public static const ALL:String = "all";
      
      public static const ANY_WORLD:String = "";
      
      public static const TYPE_LIMITED:String = "limited";
      
      public static const TYPE_VAULT:String = "vault";
      
      public static const TYPE_VILLAGE:String = "village";
      
      public static const TYPE_MANAGED_SALE:String = "sale";
      
      public static const TYPE_VIP:String = "vip";
      
      public static const TYPE_WORLD_SPECIFIC_SALE:String = "sale";
      
      public static const TYPE_CATEGORY_SPECIFIC_SALE:String = "sale";
      
      public static const TYPE_LOYALTY:String = "loyalty";
      
      public static const TYPE_BOBS_FARM:String = "bobsFarm";
      
      private static const WORLD_BUSHEL_BOOST:String = "WORLD_BUSHEL_BOOST";
      
      public static const TYPE_NEW:String = "new";
      
      public static const SUBTYPE_CHARITY:String = "charity";
      
      public static const TYPE_BRANDED:String = "branded";
      
      public static const TYPE_GAME_TOKEN:String = "gametoken";
      
      public static const ASCENDING:String = "asc";
      
      public static const DESCENDING:String = "desc";
      
      public static const REQUIRED_LEVEL:String = "level";
      
      public static const NAME:String = "name";
      
      public static const PRICE:String = "price";
      
      public static const MASTERY:String = "mastery";
      
      public static const MASTERY_PROGRESS:String = "masteryProgress";
      
      public static const SUPER_CROP:String = "superCrop";
      
      public static const SELL_FOR:String = "sellFor";
      
      public static const SIZE:String = "size";
      
      public static const COIN_YIELD:String = "coinYield";
      
      public static const XP_GAINED:String = "xpGained";
      
      public static const HARVEST_TIME:String = "harvestTime";
      
      public static const COLOR_GROUP:String = "colorGroup";
      
      public static const THEME:String = "theme";
      
      public static const KEYWORD:String = "keyword";
      
      public static const DEFAULT:String = "default";
      
      public static const WORLD_SORT:String = "world";
      
      public static const CURRENT_WORLD_SORT:String = "currentWorldDefault";
      
      public static const XML_CHILDREN_FIELD:String = "children_from_xml";
      
      public static const LE_START:String = "limitedStart";
      
      public static const MOTD_CONTEXT_ON_GAME_INIT:String = "on_game_init";
      
      public static const MOTD_CONTEXT_ON_LEVEL_UP:String = "on_level_up";
      
      public static const MOTD_CONDITION_ITEM_NOT_OWNED:String = "itemNotOwned";
      
      public static const MOTD_CONDITION_ITEM_OWNED:String = "itemOwned";
      
      public static const TERRAIN_DEFAULT:String = "default";
      
      public static const TERRAIN_GROUND:String = "ground";
      
      public static const TERRAIN_LAND:String = "land";
      
      public static const TERRAIN_WATER:String = "water";
      
      public static const TERRAIN_SHORELINE:String = "shoreline";
      
      public static const TERRAIN_TERRACE:String = "terrace";
      
      public static const TERRAIN_EARTH:String = "earth";
      
      public static const TERRAIN_UNDERWATER:String = "underwater";
      
      public static const TERRAIN_TURTLE:String = "turtle";
      
      public static const TERRAIN_DREAM:String = "dream";
      
      public static const TERRAIN_BORABORA:String = "borabora";
      
      public static const TERRAIN_PLOWABLE:String = "plowable";
      
      public static const TERRAIN_ZEN:String = "zen";
      
      public static const TERRAIN_SNOW:String = "snow";
      
      private static const SORT_BY_CURRENT_WORLD_DEFAULT_RANKS:Object = {
         "animal":7,
         "tree":6,
         "decoration":5,
         "building":4,
         "seed":3,
         "aide":2,
         "landExpansion":1
      };
      
      private static const SORT_BY_WORLD_SEASONs:Object = {
         "JapanPPMarketPrereq":1,
         "JapanRBMarketPrereq":2,
         "JapanMSMarketPrereq":3,
         "JapanZVMarketPrereq":4
      };
      
      public static var m_marketSearchTernaryTree:TernaryTree = new TernaryTree();
      
      private static const MIN_PARSE_ITEMS_BATCH_DURATION:int = 8;
      
      private static var m_isItemsAMFExperimentInitialized:Boolean = false;
      
      private static var m_isItemsAMFPristineExperimentInitialized:Boolean = false;
      
      private static var m_isInItemsAMFPristineExperiment:Boolean = false;
      
      private static var m_isInItemsAMFExperiment:Boolean = false;
      
      private static var m_isDataSourceExperimentInitialized:Boolean = false;
      
      private static var m_isMarketDataAssetCallExperimentInitialized:Boolean = false;
      
      private static var m_isInDataSourceExperiment:Boolean = false;
      
      private static var m_isInMarketDataAssetCallExperiment:Boolean = false;
      
      private static var m_isFgsmAmfGenerator:Boolean = false;
      
      private static const ITEMS_ACCESS_COUNTER:String = "items_access";
      
      private var m_sortFunctionHash:Object = {
         "superCrop":sortBySuperCrop,
         "level":sortByRequiredLevel,
         "name":sortByName,
         "price":sortByPrice,
         "mastery":sortByMasteryStars,
         "masteryProgress":sortByMasteryProgress,
         "sellFor":sortBySellFor,
         "coinYield":sortByCoinYield,
         "xpGained":sortByXpGained,
         "harvestTimeShortest":sortByHarvestTimeShortest,
         "harvestTimeLongest":sortByHarvestTimeLongest,
         "colorGroup":sortByColorGroup,
         "theme":sortByTheme,
         "keyword":sortByKeyword,
         "default":sortByDefault,
         "currentWorldDefault":sortByCurrentWorldDefault,
         "size":sortBySize,
         "timeRemaining":sortByTimeRemaining,
         "timeStart":sortByTimeStart,
         "patchTime":sortByPatchTime,
         "world":sortByWorld
      };
      
      private var m_typesHash:Object = {};
      
      private var m_market3TypesHash:Object = {};
      
      private var m_allItemsArray:Array = [];
      
      private var m_classNameHash:Object = {};
      
      private var m_itemLicenseHash:Object = {};
      
      private var m_licenseItemHash:Object = {};
      
      private var m_buildingLevelCreditsHash:Object = {};
      
      private var m_buildingRewardItemsHash:Object = {};
      
      private var m_buildingArrowOffsetHash:Object = {};
      
      private var m_buildingOffBoardHash:Object = {};
      
      private var m_buildingExperimentHash:Object = {};
      
      private var m_starterPackHash:Object = null;
      
      private var m_factoriesHash:Object = null;
      
      private var m_farmVillageHash:Object = null;
      
      private var m_prereqsHash:Object = null;
      
      private var m_expansionDataHash:Object = null;
      
      private var m_deprecatorSettingsHash:Object = null;
      
      private var m_contentAccessSettingsHash:Array = null;
      
      private var m_worldCurrencyHash:Object = null;
      
      private var m_minigameHash:Dictionary = null;
      
      private var m_ugcItemDefinitionHash:Object = null;
      
      private var m_aoeTargetKeywordHash:Object = {};
      
      private var m_attributes:Dictionary = new Dictionary();
      
      private var m_inGameDaySeconds:Number;
      
      private var m_growMultiplier:Number;
      
      private var m_lastGender:int = 0;
      
      private var m_farmingXml:XMLList = null;
      
      private var m_rawXml:XML = null;
      
      private var m_itemsXMLParsingComplete:Boolean = false;
      
      private var m_itemsByCodeHash:Object = {};
      
      private var m_itemsByNameHash:Object = {};
      
      private var m_itemsXMLList:Vector.<XML> = new Vector.<XML>();
      
      private var m_optItemsAMFList:Vector.<Object> = new Vector.<Object>();
      
      private var m_itemsAMFList:Object = {"length":0};
      
      private var m_itemsListCounter:int = 0;
      
      private var m_numItemsXMLParsed:int = 0;
      
      private var m_blockProgressionPopupItemsHash:Object = null;
      
      private var m_itemsNameToIndexHash:Object = {};
      
      private var m_incrementalGateItemsArray:Object = null;
      
      private var m_allExpansionPromoData:Object = new Object();
      
      private var m_hadValidServerTime:Boolean = false;
      
      private var m_postProcessArray:Array = [];
      
      private var m_actionableFeatureBuildings:Array = [];
      
      private var m_friendlyNameArray:Array = null;
      
      private var m_superCrops:Array;
      
      private var m_displaySettings:Object = null;
      
      private var m_terrainToCodes:Dictionary = null;
      
      private var m_primaryTerrains:Array = null;
      
      private var m_primaryTerrainToCode:Dictionary = null;
      
      private var m_masterySignMap:Object = new Object();
      
      private var m_masterySignMapArray:Array = new Array();
      
      private var m_marketSearchOptimizationCachedExperimentVariant:int = -1;
      
      private var m_buildingProgressionData:Dictionary = new Dictionary();
      
      private var m_allItemsCount:int;
      
      private var m_isUsingFgsmAmf:Boolean = false;
      
      private var m_itemCategories:Object;
      
      private var m_itemsCalled:Dictionary;
      
      private var m_numItemsAccessed:Number = 0;
      
      private var ClassCompilingArray:Array = [PigPenBreedingMOTDHandler,SheepPenBreedingMOTDHandler,CollectionsOffBoardMOTDHandler,CollectionsOnboardingMOTDHandler,CraftingV2MOTDHandler,CommunityNeighborsMOTDHandler,ZCacheMOTDHandler,FlashUpgradeMOTDHandler,ItemByWorldMOTDHandler,LimitedSalePostInitAction,CraftingV4MOTDHandler,CustomWindowMOTDHandler,DialogMOTDHandler,CraftingV4MOTDHandler,BreedingBuildingExpansionsMOTDHandler,ExpansionAccessMotdHandler,ExpansionEarlyAccessMotdHandler,ExpansionFestivalOfColorMotdHandler,ExpansionEarlyAccessChristmasPatchMotdHandler,ExpansionContentEarlyAccessMotdHandler,ExpansionTeaserMotdHandler,TrickOrTreatMOTDHandler,MultiStageQuestMOTDHandler,ForcePlaceMOTDHandler,LaunchURLMotdHandler,LaunchRTURLMotdHandler,LaunchAmexURLMotdHandler,MultiTaskLeaderboardMOTDHandler,SubscriptionsMOTDHandler,CustomActionMOTDHandler,FinishAllBuildingsMOTDHandler,HolidayCountdownMOTDHandler,BirthdayFreeGiftsMOTDHandler,CustomWindowActionMOTDHandler,MOTDLockedExplanationHandler
      ,ExpansionItemLockedExplanationHandler,OpenMarketMOTDHandler,TopPhotosMOTDHandler,FeatureFrequencyMOTDHandler,OpenQuestManagerMOTDHandler,MarketFlashSaleMOTDHandler,CropBonanzaV2MOTDHandler,MysteryCrateMOTDHandler,LELastChanceMOTDHandler,CategorySpecificSaleMOTDHandler,WorldSpecificSaleMOTDHandler,LimitedQuantityBundleMOTDHandler,ChristmasCharityBundleMOTDHandler,FarmRunQuestsMOTDHandler,NeighborCleanupMOTDHandler,MystreeBabiesMOTDHandler,LongWeekEndDelightMOTDHandler,UltimateStarterPackMOTDHandler,SubscriptionsV2MOTDHandler,GenericCharityMOTDHandler,SubscriptionsV2BenefitsMOTDHandler,CommunityGoalsMOTDHandler,SpendometerMOTDHandler,UnlimitedPacksMOTDHandler,ExpansionEASeasonMotdHandler,ExpansionGASeasonMotdHandler,SeasonEAMOTDHandler,SeasonGAMOTDHandler,EarlyAccessRepopMOTDHandler,LaunchSurveyURLMotdHandler,OlyInnovationMOTDHandler,SocialRaffleMOTDHandler,PremarketingEarlyAccessMotdHandler,PremarketingGeneralAccessMotdHandler,SubscriptionRevampMOTDHandler,SeasonUnlockMotdHandler];
      
      public function FarmGameSettingsManager()
      {
         super();
      }
      
      public static function registerFarmSettingsClassesForSerialization() : void
      {
         DataObjectsRegistrar.registerAll();
         registerClassAlias("ZItem.AnimalItem",AnimalItem);
         registerClassAlias("ZItem.BuffItem",BuffItem);
         registerClassAlias("ZItem.BuildingItem",BuildingItem);
         registerClassAlias("ZItem.BushelItem",BushelItem);
         registerClassAlias("ZItem.ChangeFarmItem",ChangeFarmItem);
         registerClassAlias("ZItem.ConsumableItem",ConsumableItem);
         registerClassAlias("ZItem.DecorationItem",DecorationItem);
         registerClassAlias("ZItem.EquipmentItem",EquipmentItem);
         registerClassAlias("ZItem.EvolutionAnimalItem",EvolutionAnimalItem);
         registerClassAlias("ZItem.ExchangeCurrencyItem",ExchangeCurrencyItem);
         registerClassAlias("ZItem.ExpansionAccessItem",ExpansionAccessItem);
         registerClassAlias("ZItem.StencilPortalItem",StencilPortalItem);
         registerClassAlias("ZItem.FarmItem",FarmItem);
         registerClassAlias("ZItem.FuelItem",FuelItem);
         registerClassAlias("ZItem.GopherItem",GopherItem);
         registerClassAlias("ZItem.GrowableAnimalItem",GrowableAnimalItem);
         registerClassAlias("ZItem.HarvestableItem",HarvestableItem);
         registerClassAlias("ZItem.MarketStallBuildingItem",MarketStallBuildingItem);
         registerClassAlias("ZItem.MultiRewardTreasureConstructionBuildingItem",MultiRewardTreasureConstructionBuildingItem);
         registerClassAlias("ZItem.PetFarmItem",PetFarmItem);
         registerClassAlias("ZItem.SeedItem",SeedItem);
         registerClassAlias("ZItem.SimpleHarvestableItem",SimpleHarvestableItem);
         registerClassAlias("ZItem.StarterPackItem",StarterPackItem);
         registerClassAlias("ZItem.TreeItem",TreeItem);
         registerClassAlias("ZItem.TurboItem",TurboItem);
         registerClassAlias("ZItem.UGCAnimalItem",UGCAnimalItem);
         registerClassAlias("ZItem.MutableDragonItem",MutableDragonItem);
         registerClassAlias("ZItem.UGCDecorationItem",UGCDecorationItem);
         registerClassAlias("ZItem.ZItemBase",ZItemBase);
         registerClassAlias("Managers.FarmGameSettingsManager",FarmGameSettingsManager);
         DataObjectDataSource.registerAlias();
      }
      
      public static function parseXmlAttributesToObject(xml:XML, includeChildren:Boolean = false) : Object
      {
         var xmlAttribute:XML = null;
         var attributeName:String = null;
         var children:XMLList = null;
         var childrenArray:Array = null;
         var child:XML = null;
         var result:Object = new Object();
         for each(xmlAttribute in xml.attributes())
         {
            attributeName = xmlAttribute.name();
            result[attributeName] = String(xmlAttribute);
         }
         if(includeChildren)
         {
            children = xml.children();
            childrenArray = new Array();
            for each(child in children)
            {
               childrenArray.push(parseXmlAttributesToObject(child,includeChildren));
            }
            if(childrenArray.length > 0)
            {
               result[XML_CHILDREN_FIELD] = childrenArray;
            }
         }
         return result;
      }
      
      public static function sortSuperCrops(type:String, sortBy:String, searchString:String, returnArray:Array) : Array
      {
         var farmItem:FarmItem = null;
         var superCrop:FarmItem = null;
         var superCropRequirmement:SuperCropRequirement = null;
         var superCrops:Array = null;
         var i:* = 0;
         var insertIndex:int = 0;
         if(type == "seed")
         {
            superCrops = new Array();
            if("" == searchString)
            {
               for(i = 0; i < returnArray.length; i++)
               {
                  superCrop = returnArray[i];
                  if(superCrop is SeedItem && (superCrop as SeedItem).isSuperCrop())
                  {
                     superCropRequirmement = superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(superCropRequirmement.masteryCropName);
                     if(returnArray.indexOf(farmItem) < 0)
                     {
                        returnArray.splice(i,1);
                        i--;
                     }
                  }
               }
            }
            if(sortBy != SUPER_CROP)
            {
               for(i = 0; i < returnArray.length; i++)
               {
                  superCrop = returnArray[i];
                  if(superCrop is SeedItem && (superCrop as SeedItem).isSuperCrop())
                  {
                     returnArray.splice(i,1);
                     i--;
                     superCrops.push(superCrop);
                  }
               }
               for each(superCrop in superCrops)
               {
                  superCropRequirmement = superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(superCropRequirmement.masteryCropName);
                  insertIndex = returnArray.indexOf(farmItem) + 1;
                  returnArray.splice(insertIndex,0,superCrop);
               }
            }
         }
         return returnArray;
      }
      
      private static function removeInvisibleItems(arrayIn:Array) : Array
      {
         var item:FarmItem = null;
         var arrayOut:Array = [];
         for each(item in arrayIn)
         {
            if(item.isVisible)
            {
               arrayOut.push(item);
            }
         }
         return arrayOut;
      }
      
      public static function applyTerrainRestriction(arrayIn:Array, terrainCodes:Array) : Array
      {
         var arrayOut:Array = null;
         var item:FarmItem = null;
         if(terrainCodes != null)
         {
            arrayOut = [];
            for each(item in arrayIn)
            {
               if(TerrainUtil.intersectTerrainCodeArrays(item.getTerrainCodes(),terrainCodes))
               {
                  arrayOut.push(item);
               }
            }
         }
         else
         {
            arrayOut = arrayIn;
         }
         return arrayOut;
      }
      
      protected static function sortByRequiredLevel(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).requiredLevel;
         var score2:Number = (obj2 as FarmItem).requiredLevel;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByName(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = (obj1 as FarmItem).friendlyTitle;
         var score2:String = (obj2 as FarmItem).friendlyTitle;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         return result;
      }
      
      protected static function sortByPrice(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var cash1:int = (obj1 as FarmItem).cash * CASH_MULTIPLIER;
         var cash2:int = (obj2 as FarmItem).cash * CASH_MULTIPLIER;
         var saleCash1:int = (obj1 as FarmItem).saleCash * CASH_MULTIPLIER;
         var saleCash2:int = (obj2 as FarmItem).saleCash * CASH_MULTIPLIER;
         var saleCost1:int = (obj1 as FarmItem).saleCost;
         var saleCost2:int = (obj2 as FarmItem).saleCost;
         var cost1:int = (obj1 as FarmItem).cost;
         var cost2:int = (obj2 as FarmItem).cost;
         var score1:Number = cash1 != 0 ? cash1 : (saleCash1 != 0 ? saleCash1 : (saleCost1 != 0 ? saleCost1 : cost1));
         var score2:Number = cash2 != 0 ? cash2 : (saleCash2 != 0 ? saleCash2 : (saleCost2 != 0 ? saleCost2 : cost2));
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByXpGained(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? ((obj1 as HarvestableItem).plantXp > 0 ? (obj1 as HarvestableItem).plantXp : (obj1 as HarvestableItem).xpGained) : -1;
         var score2:Number = !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? ((obj2 as HarvestableItem).plantXp > 0 ? (obj2 as HarvestableItem).plantXp : (obj2 as HarvestableItem).xpGained) : -1;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByMasteryStars(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? Math.max((obj1 as HarvestableItem).masteryStars,0) : -1;
         var score2:Number = !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? Math.max((obj2 as HarvestableItem).masteryStars,0) : -1;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByMasteryProgress(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByMasteryProgress(obj1:Object, obj2:Object) : int
      {
         var score1:Number = NaN;
         var score2:Number = NaN;
         var result:int = 0;
         if(!(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" && (obj1 as HarvestableItem).hasMastery)
         {
            score1 = (obj1 as HarvestableItem).masteryStars != 2 ? (obj1 as HarvestableItem).masteryProgress : 9000000;
         }
         else
         {
            score1 = !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? 9500000 : 10000000;
         }
         if(!(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" && (obj2 as HarvestableItem).hasMastery)
         {
            score2 = (obj2 as HarvestableItem).masteryStars != 2 ? (obj2 as HarvestableItem).masteryProgress : 9000000;
         }
         else
         {
            score2 = !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? 9500000 : 10000000;
         }
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortBySellFor(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).sellPrice;
         var score2:Number = (obj2 as FarmItem).sellPrice;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByCoinYield(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? (obj1 as HarvestableItem).coinYield : 0;
         var score2:Number = !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? (obj2 as HarvestableItem).coinYield : 0;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByHarvestTimeShortest(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = obj1 is HarvestableItem && !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? (obj1 as HarvestableItem).growTime : 10000000;
         var score2:Number = obj2 is HarvestableItem && !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? (obj2 as HarvestableItem).growTime : 10000000;
         if(score1 == 0)
         {
            score1 = 9000000;
         }
         if(score2 == 0)
         {
            score2 = 9000000;
         }
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByHarvestTimeLongest(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = obj1 is HarvestableItem && !(obj1 is BuildingItem) && (obj1 as FarmItem).code != "XX" ? (obj1 as HarvestableItem).growTime : -1;
         var score2:Number = obj2 is HarvestableItem && !(obj2 is BuildingItem) && (obj2 as FarmItem).code != "XX" ? (obj2 as HarvestableItem).growTime : -1;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByColorGroup(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = (obj1 as FarmItem).colorGroup;
         var score2:String = (obj2 as FarmItem).colorGroup;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByTimeRemaining(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).isLimitedItem() && Boolean((obj1 as FarmItem).getLimitedEndDate()) ? (obj1 as FarmItem).limitedTimeLeft : Number.MAX_VALUE;
         var score2:Number = (obj2 as FarmItem).isLimitedItem() && Boolean((obj2 as FarmItem).getLimitedEndDate()) ? (obj2 as FarmItem).limitedTimeLeft : Number.MAX_VALUE;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByTimeStart(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).getLimitedStartDate() ? (obj1 as FarmItem).timeSinceStarted : Number.MAX_VALUE;
         var score2:Number = (obj2 as FarmItem).getLimitedStartDate() ? (obj2 as FarmItem).timeSinceStarted : Number.MAX_VALUE;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = sortByName(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByLimitedStart(obj1:Object, obj2:Object) : int
      {
         var score1:Number = NaN;
         var score2:Number = NaN;
         var result:int = 0;
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_OPTIM_SORTING) <= 1)
         {
            score1 = (obj1 as FarmItem).isLimitedItem() ? FarmGameUtil.synchronizedDateToNumber((obj1 as FarmItem).getLimitedStartDate()) : Number.MAX_VALUE;
            score2 = (obj2 as FarmItem).isLimitedItem() ? FarmGameUtil.synchronizedDateToNumber((obj2 as FarmItem).getLimitedStartDate()) : Number.MAX_VALUE;
            if(score1 > score2)
            {
               result = IN_MIN;
            }
            else if(score1 < score2)
            {
               result = IN_MAX;
            }
         }
         else
         {
            score1 = (obj1 as FarmItem).isLimitedItem() ? FarmGameUtil.synchronizedDateToNumber((obj1 as FarmItem).getLimitedStartDate()) : Number.MIN_VALUE;
            score2 = (obj2 as FarmItem).isLimitedItem() ? FarmGameUtil.synchronizedDateToNumber((obj2 as FarmItem).getLimitedStartDate()) : Number.MIN_VALUE;
            if(score1 > score2)
            {
               result = IN_MAX;
            }
            else if(score1 < score2)
            {
               result = IN_MIN;
            }
         }
         if(result == 0)
         {
            result = sortByTimeRemaining(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByLimitedStartAndPriority(obj1:Object, obj2:Object) : int
      {
         var scoreForType:Number = NaN;
         var result:int = 0;
         var farmItem1:FarmItem = obj1 as FarmItem;
         var farmItem2:FarmItem = obj2 as FarmItem;
         if(farmItem1 != null && farmItem2 != null)
         {
            result = sortByLimitedStart(obj1,obj2);
            if(result == 0)
            {
               scoreForType = sortByType(obj1,obj2);
               result = scoreForType == 0 ? sortByPrice(obj1,obj2) : int(scoreForType);
            }
         }
         return result;
      }
      
      protected static function sortByType(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var type1:String = (obj1 as FarmItem).category != "" ? (obj1 as FarmItem).category : (obj1 as FarmItem).type;
         var type2:String = (obj2 as FarmItem).category != "" ? (obj2 as FarmItem).category : (obj2 as FarmItem).type;
         var score1:Number = getRankForItemType(type1);
         var score2:Number = getRankForItemType(type2);
         if(score1 > score2)
         {
            result = IN_MIN;
         }
         else if(score1 < score2)
         {
            result = IN_MAX;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      private static function getRankForItemType(type:String) : int
      {
         var score:int = 0;
         switch(type)
         {
            case ANIMAL_TYPE:
               score = RANK_ANIMAL_TYPE;
               break;
            case TREE_TYPE:
               score = RANK_TREE_TYPE;
               break;
            default:
               score = 0;
         }
         return score;
      }
      
      protected static function sortByTheme(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = "~";
         var score2:String = "~";
         var obj1FarmItem:FarmItem = obj1 as FarmItem;
         var obj2FarmItem:FarmItem = obj2 as FarmItem;
         if(obj1FarmItem != null && obj1FarmItem.marketCardDescriptor != null && obj1FarmItem.marketCardDescriptor.name != "default")
         {
            score1 = obj1FarmItem.marketCardDescriptor.name;
         }
         if(obj2FarmItem != null && obj2FarmItem.marketCardDescriptor != null && obj2FarmItem.marketCardDescriptor.name != "default")
         {
            score2 = obj2FarmItem.marketCardDescriptor.name;
         }
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByTimeRemaining(obj1,obj2);
         }
         return result;
      }
      
      protected static function sortByKeyword(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = (obj1 as FarmItem).keyword;
         var score2:String = (obj2 as FarmItem).keyword;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            sortByName(obj1,obj2);
         }
         return result;
      }
      
      private static function calcScoreByType(farmItem:FarmItem, typeIn:String, subtypeIn:String, subsubtypeIn:String) : String
      {
         var score:String = null;
         var cash:Number = NaN;
         var cost:Number = NaN;
         var saleCash:Number = NaN;
         var saleCost:Number = NaN;
         var keyword:String = null;
         var time:String = null;
         var timeLeft:String = null;
         if(subtypeIn == "consumable")
         {
            score = "{" + typeIn + subsubtypeIn;
         }
         else if(farmItem.isNew)
         {
            score = "#" + typeIn + subtypeIn;
         }
         else if(farmItem.isLimitedItem())
         {
            time = farmItem.timeSinceStarted.toFixed().toString();
            while(time.length < 13)
            {
               time = "0" + time;
            }
            timeLeft = farmItem.limitedTimeLeft.toFixed().toString();
            while(timeLeft.length < 13)
            {
               timeLeft = "0" + timeLeft;
            }
            score = "!" + time + timeLeft + farmItem.marketCardName + typeIn + subtypeIn;
         }
         else
         {
            switch(typeIn)
            {
               case "change_farm":
                  if(subtypeIn == "expand_farm")
                  {
                     score = "$" + String(farmItem.size);
                  }
                  else
                  {
                     cash = farmItem.cash * CASH_MULTIPLIER;
                     cost = farmItem.cost;
                     saleCash = farmItem.saleCash * CASH_MULTIPLIER;
                     saleCost = farmItem.saleCost;
                     keyword = "";
                     if(subtypeIn == "tile_set")
                     {
                        keyword = farmItem.isLicenseGated ? "#" : "$";
                     }
                     score = "%" + keyword + String(cash != 0 ? cash : (saleCash != 0 ? saleCash : (saleCost != 0 ? saleCost : cost)));
                  }
                  break;
               case "seed":
                  score = "&" + typeIn + ((farmItem as SeedItem).isHybrid ? "15" + farmItem.requiredLevel : farmItem.requiredLevel.toString()) + (farmItem as HarvestableItem).growTime;
                  break;
               case "tree":
                  score = "&" + typeIn + farmItem.requiredLevel + (farmItem as HarvestableItem).growTime;
                  break;
               case "animal":
                  keyword = farmItem.keyword != "" ? farmItem.keyword : (subtypeIn != "" ? subtypeIn : farmItem.name);
                  score = "(" + keyword + farmItem.name;
                  break;
               default:
                  score = typeIn + subtypeIn + subsubtypeIn;
            }
         }
         return score;
      }
      
      protected static function sortByWorldScoreRequired(obj1:Object, obj2:Object) : int
      {
         var lastPreReqTested1:Object = null;
         var lastPreReqTested2:Object = null;
         var worldScoreRequired1:int = 0;
         var worldScoreRequired2:int = 0;
         var result:int = 0;
         var purchasePrereqSuccessObj1:Boolean = (obj1 as FarmItem).checkPurchasePrereqs();
         var purchasePrereqSuccessObj2:Boolean = (obj2 as FarmItem).checkPurchasePrereqs();
         if(purchasePrereqSuccessObj1 && !purchasePrereqSuccessObj2)
         {
            result = 1;
         }
         else if(!purchasePrereqSuccessObj1 && purchasePrereqSuccessObj2)
         {
            result = -1;
         }
         else if(!purchasePrereqSuccessObj1 && !purchasePrereqSuccessObj2)
         {
            lastPreReqTested1 = (obj1 as FarmItem).diagnoseFailedPurchasePrereqs();
            lastPreReqTested2 = (obj2 as FarmItem).diagnoseFailedPurchasePrereqs();
            worldScoreRequired1 = getQuantityOnFailedPreReqWorldScoreLevel(lastPreReqTested1);
            worldScoreRequired2 = getQuantityOnFailedPreReqWorldScoreLevel(lastPreReqTested2);
            if(worldScoreRequired1 > worldScoreRequired2)
            {
               result = -1;
            }
            else if(worldScoreRequired1 < worldScoreRequired2)
            {
               result = 1;
            }
            else
            {
               result = 0;
            }
         }
         return result;
      }
      
      private static function getQuantityOnFailedPreReqWorldScoreLevel(lastPreReqTested:Object) : int
      {
         var lastType:String = null;
         var levelWorldScoreRequired:int = -1;
         if(lastPreReqTested)
         {
            lastType = "";
            if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_TYPE))
            {
               lastType = lastPreReqTested[PrerequisiteConstants.KEY_TYPE];
               if(lastType == PREREQ_KEY_WORLD_SCORE_LEVEL_MIN)
               {
                  if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY))
                  {
                     levelWorldScoreRequired = int(lastPreReqTested[PrerequisiteConstants.KEY_QUANTITY]);
                  }
               }
            }
         }
         return levelWorldScoreRequired;
      }
      
      protected static function sortByDefault(obj1:Object, obj2:Object) : int
      {
         var score1:String = null;
         var score2:String = null;
         var result:int = 0;
         var type1:String = (obj1 as FarmItem).category != "" ? (obj1 as FarmItem).category : (obj1 as FarmItem).type;
         var type2:String = (obj2 as FarmItem).category != "" ? (obj2 as FarmItem).category : (obj2 as FarmItem).type;
         var subtype1:String = (obj1 as FarmItem).subType != "" ? (obj1 as FarmItem).subType : (obj1 as FarmItem).keyword;
         var subtype2:String = (obj2 as FarmItem).subType != "" ? (obj2 as FarmItem).subType : (obj2 as FarmItem).keyword;
         var subsubtype1:String = (obj1 as FarmItem).subsubtype != "" ? (obj1 as FarmItem).subsubtype : (obj1 as FarmItem).className;
         var subsubtype2:String = (obj2 as FarmItem).subsubtype != "" ? (obj2 as FarmItem).subsubtype : (obj2 as FarmItem).className;
         var farmItem1:FarmItem = obj1 as FarmItem;
         var farmItem2:FarmItem = obj2 as FarmItem;
         if(farmItem1 != null && farmItem2 != null)
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_OPTIM_SORTING) <= 1)
            {
               if(result == 0)
               {
                  if(farmItem1.isLimitedItem() && farmItem2.isLimitedItem())
                  {
                     result = sortByLimitedStartAndPriority(obj1,obj2);
                  }
               }
               if(result == 0)
               {
                  if(farmItem1.isLimitedItem() && !farmItem2.isLimitedItem())
                  {
                     result = 1;
                  }
                  if(farmItem2.isLimitedItem() && !farmItem1.isLimitedItem())
                  {
                     result = -1;
                  }
               }
            }
            else
            {
               if(farmItem1.hasSale && !farmItem2.hasSale)
               {
                  result = 1;
               }
               else if(farmItem2.hasSale && !farmItem1.hasSale)
               {
                  result = -1;
               }
               if(result == 0)
               {
                  if(farmItem1.isLEItem() && farmItem2.isLEItem())
                  {
                     result = sortByLimitedStartAndPriority(obj1,obj2);
                  }
               }
               if(result == 0)
               {
                  if(farmItem1.isLEItem() && !farmItem2.isLEItem())
                  {
                     result = 1;
                  }
                  if(farmItem2.isLEItem() && !farmItem1.isLEItem())
                  {
                     result = -1;
                  }
               }
               if(result == 0)
               {
                  if(farmItem1.hasLimitedStartEnd() && farmItem2.hasLimitedStartEnd())
                  {
                     result = sortByLimitedStartAndPriority(obj1,obj2);
                  }
                  else if(farmItem1.hasLimitedStartEnd() && !farmItem2.hasLimitedStartEnd())
                  {
                     result = 1;
                  }
                  else if(farmItem2.hasLimitedStartEnd() && !farmItem1.hasLimitedStartEnd())
                  {
                     result = -1;
                  }
                  else if(farmItem1.hasLimitedStart() && farmItem2.hasLimitedStart())
                  {
                     result = sortByLimitedStartAndPriority(obj1,obj2);
                  }
                  else if(farmItem1.hasLimitedStart() && !farmItem2.hasLimitedStart())
                  {
                     result = 1;
                  }
                  else if(farmItem2.hasLimitedStart() && !farmItem1.hasLimitedStart())
                  {
                     result = -1;
                  }
               }
            }
            if(result == 0)
            {
               result = sortByWorldScoreRequired(obj1,obj2);
            }
            if(result == 0)
            {
               score1 = calcScoreByType(farmItem1,type1,subtype1,subsubtype1);
               score2 = calcScoreByType(farmItem2,type2,subtype2,subsubtype2);
               if(score1 > score2)
               {
                  result = -1;
               }
               else if(score1 < score2)
               {
                  result = 1;
               }
               else if(farmItem1.isLimitedItem())
               {
                  result = sortByLimitedStart(obj1,obj2);
               }
               else
               {
                  switch(type1)
                  {
                     case "change_farm":
                        if(subtype1 == "expand_farm")
                        {
                           result = sortBySize(obj1,obj2);
                        }
                        else
                        {
                           result = sortByPrice(obj1,obj2);
                        }
                        break;
                     case "seed":
                        result = sortByRequiredLevel(obj1,obj2);
                        break;
                     case "animal":
                        result = sortByKeyword(obj1,obj2);
                        break;
                     default:
                     case "tree":
                     case "consumable":
                     case "fuel":
                     case "vehicle":
                        result = sortByPrice(obj1,obj2);
                  }
               }
            }
         }
         return result;
      }
      
      protected static function sortByCurrentWorldDefault(obj1:Object, obj2:Object) : int
      {
         var newItem1:Boolean = false;
         var newItem2:Boolean = false;
         var type1:String = null;
         var type2:String = null;
         var score1:Number = NaN;
         var score2:Number = NaN;
         var result:int = 0;
         var item1:FarmItem = obj1 as FarmItem;
         var item2:FarmItem = obj2 as FarmItem;
         if(item1 != null && item2 != null)
         {
            newItem1 = item1.worldRestrictions != null && item1.worldRestrictions.indexOf(Global.worldManager.currentWorldType) != -1;
            newItem2 = item2.worldRestrictions != null && item2.worldRestrictions.indexOf(Global.worldManager.currentWorldType) != -1;
            if(newItem1 && !newItem2)
            {
               result = 1;
            }
            else if(newItem2 && !newItem1)
            {
               result = -1;
            }
            if(result == 0)
            {
               type1 = item1.category != "" ? item1.category : item1.type;
               type2 = item2.category != "" ? item2.category : item2.type;
               score1 = getSortByCurrentWorldDefaultTypeRank(type1);
               score2 = getSortByCurrentWorldDefaultTypeRank(type2);
               if(score1 > score2)
               {
                  result = 1;
               }
               else if(score1 < score2)
               {
                  result = -1;
               }
            }
         }
         if(result == 0)
         {
            result = sortByDefault(obj1,obj2);
         }
         return result;
      }
      
      private static function getSortByCurrentWorldDefaultTypeRank(type:String) : int
      {
         var score:int = 0;
         if(SORT_BY_CURRENT_WORLD_DEFAULT_RANKS.hasOwnProperty(type))
         {
            score = int(SORT_BY_CURRENT_WORLD_DEFAULT_RANKS[type]);
         }
         return score;
      }
      
      protected static function sortBySize(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).size;
         var score2:Number = (obj2 as FarmItem).size;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         return result;
      }
      
      protected static function sortByPatchTime(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as FarmItem).patchTime;
         var score2:Number = (obj2 as FarmItem).patchTime;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         return result;
      }
      
      protected static function sortByWorld(obj1:Object, obj2:Object) : int
      {
         var score1:Number = NaN;
         var score2:Number = NaN;
         var result:int = 0;
         var item1WorldRestrictions:Array = (obj1 as FarmItem).worldRestrictions;
         var item2WorldRestrictions:Array = (obj2 as FarmItem).worldRestrictions;
         var item1InWorldRestrictions:Boolean = item1WorldRestrictions.indexOf(Global.worldManager.currentWorldType) != -1;
         var item2InWorldRestrictions:Boolean = item2WorldRestrictions.indexOf(Global.worldManager.currentWorldType) != -1;
         var item1Background:String = (obj1 as FarmItem).marketPrereqName;
         var item2Background:String = (obj2 as FarmItem).marketPrereqName;
         if(item1InWorldRestrictions && !item2InWorldRestrictions)
         {
            result = 1;
         }
         else if(item2InWorldRestrictions && !item1InWorldRestrictions)
         {
            result = -1;
         }
         if(result == 0)
         {
            score1 = getSortByWorldSeason(item1Background);
            score2 = getSortByWorldSeason(item2Background);
            if(score1 > score2)
            {
               result = 1;
            }
            else if(score1 < score2)
            {
               result = -1;
            }
         }
         if(result == 0)
         {
            result = sortByDefault(obj1,obj2);
         }
         return result;
      }
      
      private static function getSortByWorldSeason(type:String) : int
      {
         var season:int = 0;
         if(SORT_BY_WORLD_SEASONs.hasOwnProperty(type))
         {
            season = int(SORT_BY_WORLD_SEASONs[type]);
         }
         return season;
      }
      
      protected static function sortBySuperCrop(obj1:Object, obj2:Object) : int
      {
         var seedItem:SeedItem = null;
         var result:int = 0;
         var cropOneSuper:Boolean = false;
         var cropTwoSuper:Boolean = false;
         seedItem = obj1 as SeedItem;
         cropOneSuper = Boolean(seedItem) && seedItem.isSuperCrop();
         seedItem = obj2 as SeedItem;
         cropTwoSuper = Boolean(seedItem) && seedItem.isSuperCrop();
         if(cropOneSuper && !cropTwoSuper)
         {
            result = -1;
         }
         else if(cropTwoSuper && !cropOneSuper)
         {
            result = 1;
         }
         else
         {
            result = sortByDefault(obj1,obj2);
         }
         return result;
      }
      
      private static function parseTerrainHierarchyRecursively(terrainNode:XML, terrainToCodes:Dictionary) : Array
      {
         var terrain:XML = null;
         var tmpCodes:Array = null;
         var i:int = 0;
         var terrainName:String = null;
         var tmpArray:Array = null;
         var j:int = 0;
         var codes:Array = new Array();
         if(terrainNode.hasOwnProperty("terrain"))
         {
            for each(terrain in terrainNode.terrain)
            {
               tmpCodes = parseTerrainHierarchyRecursively(terrain,terrainToCodes);
               for(i = 0; i < tmpCodes.length; i++)
               {
                  if(codes.indexOf(tmpCodes[i] == -1))
                  {
                     codes.push(tmpCodes[i]);
                  }
               }
            }
         }
         if(terrainNode.name().toString() == "terrain")
         {
            terrainName = terrainNode.@name.toString();
            if(terrainToCodes.hasOwnProperty(terrainName))
            {
               tmpArray = terrainToCodes[terrainName];
               for(j = 0; j < tmpArray.length; j++)
               {
                  if(codes.indexOf(tmpArray[j] == -1))
                  {
                     codes.push(tmpArray[j]);
                  }
               }
            }
            terrainToCodes[terrainName] = codes;
         }
         return codes;
      }
      
      public static function isInItemAMFPristineExperiment() : Boolean
      {
         if(!m_isItemsAMFPristineExperimentInitialized)
         {
            m_isInItemsAMFPristineExperiment = isInItemsAMFExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ITEMS_AMF_PRISTINE) > 1;
            m_isItemsAMFPristineExperimentInitialized = true;
         }
         return m_isInItemsAMFPristineExperiment;
      }
      
      public static function isInOptItemsAMFExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MEMORY_OPTIMIZATION) == Experiments.VARIANT_MEMORY_OPTIMIZATION;
      }
      
      public static function isInItemsAMFExperiment() : Boolean
      {
         if(!m_isItemsAMFExperimentInitialized)
         {
            m_isInItemsAMFExperiment = m_isFgsmAmfGenerator || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ITEMS_AMF) > 1 && isInDataSourceExperiment() && !GlobalEngine.getFlashVar(ITEMS_AMF_FORCE_OFF);
            m_isItemsAMFExperimentInitialized = true;
         }
         return m_isInItemsAMFExperiment;
      }
      
      public static function isInMarketDataAssetCallExperiment() : Boolean
      {
         if(!m_isMarketDataAssetCallExperimentInitialized)
         {
            m_isInMarketDataAssetCallExperiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_MARKETDATAASSETCALL) == 1;
            m_isMarketDataAssetCallExperimentInitialized = true;
         }
         return m_isInMarketDataAssetCallExperiment;
      }
      
      public static function isInDataSourceExperiment() : Boolean
      {
         if(!m_isDataSourceExperimentInitialized)
         {
            m_isInDataSourceExperiment = m_isFgsmAmfGenerator || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DATASOURCE_API) > 1;
            m_isDataSourceExperimentInitialized = true;
         }
         return m_isInDataSourceExperiment;
      }
      
      public static function isInMemLeakExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BYTEARRAY_MEMLEAK) > 0;
      }
      
      public static function isInItemsAMFBuildTimeReduction() : Boolean
      {
         return GlobalEngine.isFlashVarSetAndTrue("ITEMS_AMF_BUILD_TIME_REDUCTION");
      }
      
      public static function shouldUseMasteryAMF() : Boolean
      {
         var masteryCleaned:Boolean = GlobalEngine.isFlashVarSetAndTrue("IS_MASTERY_CLEANED");
         var inMasteryAMFExp:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INMASTERYSIGN_AMF) == 1;
         return isInDataSourceExperiment() && !masteryCleaned && inMasteryAMFExp;
      }
      
      public static function isInWorldScoreAMFExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WORLDSCORE_AMF) == Experiments.VARIANT_USE_WORLDSCORE_AMF;
      }
      
      public static function isInStorageConfigAMFExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_STORAGECONFIG_AMF) == Experiments.VARIANT_USE_STORAGECONFIG_AMF;
      }
      
      public function writeExternal(output:IDataOutput) : void
      {
         output.writeObject(m_idHash);
         output.writeObject(m_nameHash);
         output.writeObject(this.m_allItemsArray);
         output.writeObject(this.m_postProcessArray);
         output.writeObject(this.m_actionableFeatureBuildings);
         output.writeObject(this.m_itemCategories);
      }
      
      public function readExternal(input:IDataInput) : void
      {
         m_idHash = input.readObject();
         m_nameHash = input.readObject();
         this.m_allItemsArray = input.readObject();
         this.m_postProcessArray = input.readObject();
         this.m_actionableFeatureBuildings = input.readObject();
         if(GlobalEngine.isFlashVarSetAndTrue(FarmGame.OPS_FGSM_QUEST_ITEM_CAT_ENABLED_FLASH_VAR))
         {
            this.m_itemCategories = input.readObject();
         }
      }
      
      public function get itemCategories() : Object
      {
         return this.m_itemCategories;
      }
      
      public function set itemCategories(iCategories:Object) : void
      {
         this.m_itemCategories = iCategories;
      }
      
      public function serializeToByteArray() : ByteArray
      {
         registerFarmSettingsClassesForSerialization();
         var serializedBytes:ByteArray = new ByteArray();
         serializedBytes.writeObject(this);
         return serializedBytes;
      }
      
      public function loadPropertiesFromConfigSWF(swf:Object) : void
      {
         var i:int = 0;
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment)
         {
            if(swf.hasOwnProperty("classNameHash") && swf["classNameHash"] != null)
            {
               this.m_classNameHash = swf["classNameHash"];
            }
            if(swf.hasOwnProperty("licenseItemHash") && swf["licenseItemHash"] != null)
            {
               this.m_licenseItemHash = swf["licenseItemHash"];
            }
            if(swf.hasOwnProperty("masterySignMap") && swf["masterySignMap"] != null)
            {
               this.m_masterySignMap = swf["masterySignMap"];
            }
            if(swf.hasOwnProperty("masterySignMapArray") && swf["masterySignMapArray"] != null)
            {
               this.m_masterySignMapArray = swf["masterySignMapArray"];
            }
            if(swf.hasOwnProperty("superCrops") && swf["superCrops"] != null)
            {
               this.m_superCrops = swf["superCrops"];
            }
            if(swf.hasOwnProperty("questManagerCacheMap") && swf["questManagerCacheMap"] != null)
            {
               FarmQuestSettingsInit.getInstance().questManagerCacheFromConfigSWF = swf["questManagerCacheMap"];
            }
            if(swf.hasOwnProperty("typesHash") && swf["typesHash"] != null)
            {
               this.m_typesHash = swf["typesHash"];
            }
            if(swf.hasOwnProperty("market3TypesHash") && swf["market3TypesHash"] != null)
            {
               this.m_market3TypesHash = swf["market3TypesHash"];
            }
            if(swf.hasOwnProperty("aoeTargetKeywordHash") && swf["aoeTargetKeywordHash"] != null)
            {
               this.m_aoeTargetKeywordHash = swf["aoeTargetKeywordHash"];
            }
            if(PerformanceExperimentManager.isInQuestCategoriesExperiment)
            {
               if(swf.hasOwnProperty("questCategories") && swf["questCategories"] != null)
               {
                  FarmQuestSettingsInit.getInstance().questCategoryCacheFromConfigSWF = swf["questCategories"];
               }
               for(i = 2; i < MAX_QUEST_CATEGORIES; i++)
               {
                  if(!(swf.hasOwnProperty("questCategories" + i.toString()) && swf["questCategories" + i.toString()] != null))
                  {
                     break;
                  }
                  FarmQuestSettingsInit.getInstance().appendQuestCategoryCacheFromConfigSWF(swf["questCategories" + i.toString()]);
               }
            }
         }
      }
      
      public function addConfigXML(xml:XML) : void
      {
         var len:int = 0;
         var i:int = 0;
         var child:XML = null;
         var entry:XML = null;
         if(this.m_rawXml == null)
         {
            this.m_rawXml = xml;
         }
         else
         {
            for each(child in xml.*)
            {
               this.m_rawXml.appendChild(child);
            }
         }
         this.m_farmingXml = this.m_rawXml.farming.farmingEntry;
         len = this.m_farmingXml.length();
         for(i = 0; i < len; i++)
         {
            entry = this.m_farmingXml[i];
            this.m_attributes[entry.@key.toString()] = entry.@value.toString();
         }
         this.populateVariables();
      }
      
      public function populateVariables() : void
      {
         if(this.m_farmingXml)
         {
            this.m_inGameDaySeconds = Number(this.getAttribute("inGameDaySeconds"));
            this.m_growMultiplier = Number(this.getAttribute("growMultiplier"));
            FarmGameObject.WALK_SPEED = Number(this.getAttribute("walkSpeed",300));
         }
      }
      
      public function getAttribute(name:String, defaultValue:* = null) : *
      {
         var result:* = undefined;
         if(this.m_attributes[name] != null && this.m_attributes[name] != undefined)
         {
            result = this.m_attributes[name];
         }
         else
         {
            result = defaultValue;
         }
         if(result is XMLList && (result as XMLList).length() > 1)
         {
            result = result[0];
         }
         return result;
      }
      
      public function getString(name:String, defaultValue:String = "") : String
      {
         return this.getAttribute(name,defaultValue).toString();
      }
      
      public function getInt(name:String, defaultValue:int = 0) : int
      {
         return parseInt(this.getAttribute(name,defaultValue));
      }
      
      public function getNumber(name:String, defaultValue:Number = 0) : Number
      {
         return Number(this.getAttribute(name,defaultValue));
      }
      
      public function get inGameDaySeconds() : Number
      {
         return this.m_inGameDaySeconds;
      }
      
      public function get growMultiplier() : Number
      {
         return this.m_growMultiplier;
      }
      
      public function getXML() : XML
      {
         return this.m_rawXml;
      }
      
      public function getAchievements() : XMLList
      {
         return this.m_rawXml.achievements.achievement;
      }
      
      public function getBuildingCreditsXml(featureName:String) : XML
      {
         var buildingXml:XML = null;
         var buildingCreditsXml:XML = null;
         var buildings:XMLList = this.m_rawXml.buildingCredits.building;
         for each(buildingXml in buildings)
         {
            if(buildingXml.@name == featureName)
            {
               buildingCreditsXml = buildingXml;
               break;
            }
         }
         return buildingCreditsXml;
      }
      
      public function getBuildableDialogXml(buildingName:String) : XML
      {
         var buildingXml:XML = null;
         var buildableXml:XML = null;
         var buildings:XMLList = this.m_rawXml.buildableDialogs.building;
         for each(buildingXml in buildings)
         {
            if(buildingXml.@name == buildingName)
            {
               buildableXml = buildingXml;
               break;
            }
         }
         return buildableXml;
      }
      
      public function getBuildingDialogConfig(buildingName:String) : Object
      {
         var dialogs:XMLList = null;
         var index:uint = 0;
         var result:Object = null;
         var constructionBuildingXml:XML = this.getBuildableDialogXml(buildingName);
         if(Boolean(constructionBuildingXml) && Boolean(constructionBuildingXml.dialog))
         {
            dialogs = constructionBuildingXml.dialog;
            for(index = 0; index < dialogs.length(); index++)
            {
               if(dialogs[index].@name == "lookInsideDialog" && Boolean(dialogs[index].@className))
               {
                  result = new Object();
                  result.className = dialogs[index].@className.toString();
                  result.path = dialogs[index].@path.toString();
                  result.bgPath = dialogs[index].@bgPath.toString();
                  result.bgImage = dialogs[index].@bgImage.toString();
                  result.slotCount = 0;
                  result.levelCount = 0;
                  result.width = 0;
                  result.height = 0;
                  result.autoWhatIsThis = false;
                  result.showOwned = true;
                  result.showBuyButton = false;
                  result.showUnownedMarket = false;
                  result.showUnownedNoMarket = false;
                  result.buildingPreview = false;
                  result.tutorialBundlePrefix = "";
                  result.tutorialAssetPrefix = "";
                  if(dialogs[index].hasOwnProperty("@slotCount"))
                  {
                     result.slotCount = parseInt(dialogs[index].@slotCount.toString());
                  }
                  if(dialogs[index].hasOwnProperty("@levelCount"))
                  {
                     result.levelCount = parseInt(dialogs[index].@levelCount.toString());
                  }
                  if(dialogs[index].hasOwnProperty("@width"))
                  {
                     result.width = parseInt(dialogs[index].@width.toString());
                  }
                  if(dialogs[index].hasOwnProperty("@height"))
                  {
                     result.height = parseInt(dialogs[index].@height.toString());
                  }
                  if(dialogs[index].hasOwnProperty("@autoWhatIsThis"))
                  {
                     result.autoWhatIsThis = dialogs[index].@autoWhatIsThis == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@showOwned"))
                  {
                     result.showOwned = dialogs[index].@showOwned == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@showBuyButton"))
                  {
                     result.showBuyButton = dialogs[index].@showBuyButton == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@showUnownedMarket"))
                  {
                     result.showUnownedMarket = dialogs[index].@showUnownedMarket == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@showUnownedNoMarket"))
                  {
                     result.showUnownedNoMarket = dialogs[index].@showUnownedNoMarket == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@redirectClassName"))
                  {
                     result.redirectClassName = dialogs[index].@redirectClassName.toString();
                  }
                  if(dialogs[index].hasOwnProperty("@cameFromBuilding"))
                  {
                     result.cameFromBuilding = dialogs[index].@cameFromBuilding == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@buildingPreview"))
                  {
                     result.buildingPreview = dialogs[index].@buildingPreview == "true";
                  }
                  if(dialogs[index].hasOwnProperty("@tutorialBundlePrefix"))
                  {
                     result.tutorialBundlePrefix = dialogs[index].@tutorialBundlePrefix.toString();
                  }
                  if(dialogs[index].hasOwnProperty("@tutorialAssetPrefix"))
                  {
                     result.tutorialAssetPrefix = dialogs[index].@tutorialAssetPrefix.toString();
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBuildingLevelItems(featureName:String) : Array
      {
         var creditsXml:XML = null;
         var levelsXML:XMLList = null;
         var levelIndex:uint = 0;
         var cost:Dictionary = null;
         var creditsNeededXML:XMLList = null;
         var index:uint = 0;
         var creditType:XML = null;
         var credit:Object = null;
         var result:Array = this.m_buildingLevelCreditsHash[featureName];
         if(result == null)
         {
            result = new Array();
            creditsXml = this.getBuildingCreditsXml(featureName);
            levelsXML = new XMLList();
            if(Boolean(creditsXml) && Boolean(creditsXml.level))
            {
               levelsXML = creditsXml.level;
            }
            for(levelIndex = 0; levelIndex < levelsXML.length(); levelIndex++)
            {
               cost = new Dictionary();
               creditsNeededXML = levelsXML[levelIndex].creditsNeeded;
               for(index = 0; index < creditsNeededXML.length(); index++)
               {
                  creditType = creditsNeededXML[index];
                  credit = new Object();
                  cost[String(creditType.@type)] = parseInt(creditType.@amount);
               }
               result.push(cost);
            }
         }
         return result;
      }
      
      public function getBuildingRewardItems(featureName:String, startIndex:int = 0, endIndex:int = 0, tagName:String = "redeemItem") : Array
      {
         if(this.m_buildingRewardItemsHash[featureName] == null)
         {
            this.m_buildingRewardItemsHash[featureName] = new Object();
         }
         var creditsXml:XML = this.getBuildingCreditsXml(featureName);
         var result:Array = this.m_buildingRewardItemsHash[featureName][tagName];
         if(result == null)
         {
            result = this.getRewardItemsFromXML(creditsXml,tagName);
            this.m_buildingRewardItemsHash[featureName][tagName] = result;
         }
         if(endIndex > 0)
         {
            result = result.slice(startIndex,endIndex);
         }
         return result;
      }
      
      public function getRewardItemsFromXML(xml:XML, tagName:String = "redeemItem") : Array
      {
         var redeemItemXML:XML = null;
         var redeemItemData:Object = null;
         var cost:Dictionary = null;
         var costOrdered:Array = null;
         var redeemItemName:String = null;
         var redeemItem:FarmItem = null;
         var creditTypes:XMLList = null;
         var i:int = 0;
         var creditType:XML = null;
         var temp:Object = null;
         var result:Array = new Array();
         var redeemItemsXML:XMLList = new XMLList();
         if(Boolean(xml) && Boolean(xml[tagName]))
         {
            redeemItemsXML = xml[tagName];
         }
         for(var index:uint = 0; index < redeemItemsXML.length(); index++)
         {
            redeemItemXML = redeemItemsXML[index];
            redeemItemData = new Object();
            redeemItemData.locked = redeemItemXML.@locked && redeemItemXML.@locked.toString() == "true";
            if(redeemItemXML.hasOwnProperty("@index"))
            {
               redeemItemData.index = parseInt(redeemItemXML.@index.toString());
            }
            if(redeemItemXML.hasOwnProperty("@voteIndex"))
            {
               redeemItemData.voteIndex = parseInt(redeemItemXML.@voteIndex.toString());
            }
            if(redeemItemXML.hasOwnProperty("@crewSize"))
            {
               redeemItemData.crewSize = parseInt(redeemItemXML.@crewSize.toString());
            }
            if(redeemItemXML.hasOwnProperty("@unlockCost"))
            {
               redeemItemData.unlockCost = parseInt(redeemItemXML.@unlockCost.toString());
            }
            cost = new Dictionary();
            costOrdered = new Array();
            if("@creditCost" in redeemItemXML)
            {
               cost["feature"] = parseInt(redeemItemXML.@creditCost);
            }
            else
            {
               creditTypes = redeemItemXML.creditCost;
               for(i = 0; i < creditTypes.length(); i++)
               {
                  creditType = creditTypes[i];
                  cost[String(creditType.@type)] = parseInt(creditType.@amount);
                  temp = new Object();
                  temp["type"] = String(creditType.@type);
                  temp["amount"] = parseInt(creditType.@amount);
                  temp["meterFilledReward"] = parseInt(creditType.@meterFilledReward);
                  redeemItemData.horizontalOffset = this.getNumberOrZero(creditType.@horizontalOffset);
                  redeemItemData.verticalOffset = this.getNumberOrZero(creditType.@verticalOffset);
                  redeemItemData.scale = this.getNumberOrZero(creditType.@scale);
                  costOrdered.push(temp);
               }
            }
            redeemItemData.costOrdered = costOrdered;
            redeemItemData.cost = cost;
            if(redeemItemXML.hasOwnProperty("@buyCost"))
            {
               redeemItemData.buyCost = parseInt(redeemItemXML.@buyCost.toString());
            }
            redeemItemData.whatIsThis = redeemItemXML.@whatIsThis;
            redeemItemName = redeemItemXML.@name.toString();
            redeemItem = Global.farmGameSettingsManager.getFarmItemByName(redeemItemName);
            redeemItemData.avatarItemCode = null;
            if(redeemItem is AvatarItem)
            {
               redeemItem = FarmItem(Global.avatarConfigSettings.getItemById(redeemItemXML.@itemId.toString()));
               redeemItemData.avatarItemCode = redeemItemXML.@itemId;
            }
            if(redeemItem)
            {
               redeemItemData.name = redeemItem.name;
               redeemItemData.friendlyName = redeemItem.friendlyName;
               redeemItemData.icon = Global.farmGameSettingsManager.getImageByName(redeemItem.name,"icon");
               redeemItemData.sendPresentLimit = redeemItemXML.@sendPresentLimit.toString();
               if(redeemItem is AvatarItem)
               {
                  redeemItemData.icon = AvatarItem(redeemItem).iconPath;
               }
            }
            redeemItemData.startDate = String(redeemItemXML.@startDate);
            redeemItemData.experiment = String(redeemItemXML.@experimentGate);
            result.push(redeemItemData);
         }
         return result;
      }
      
      private function getNumberOrZero(number:String) : Number
      {
         return isNaN(parseFloat(number)) ? 0 : parseFloat(number);
      }
      
      public function getBuildingArrowOffsets(featureName:String, tagName:String = "arrowOffset") : Array
      {
         var creditsXml:XML = null;
         var arrowOffsetsXML:XMLList = null;
         var index:uint = 0;
         var arrowOffsetXML:XML = null;
         var arrowOffsetData:Object = null;
         if(this.m_buildingArrowOffsetHash[featureName] == null)
         {
            this.m_buildingArrowOffsetHash[featureName] = new Object();
         }
         var result:Array = this.m_buildingArrowOffsetHash[featureName][tagName];
         if(result == null)
         {
            result = new Array();
            creditsXml = this.getBuildingCreditsXml(featureName);
            arrowOffsetsXML = new XMLList();
            if(Boolean(creditsXml) && Boolean(creditsXml[tagName]))
            {
               arrowOffsetsXML = creditsXml[tagName];
            }
            for(index = 0; index < arrowOffsetsXML.length(); index++)
            {
               arrowOffsetXML = arrowOffsetsXML[index];
               arrowOffsetData = new Object();
               if(arrowOffsetXML.hasOwnProperty("@name"))
               {
                  arrowOffsetData.name = arrowOffsetXML.@name.toString();
               }
               if(arrowOffsetXML.hasOwnProperty("@value"))
               {
                  arrowOffsetData.value = parseInt(arrowOffsetXML.@value.toString());
               }
               result.push(arrowOffsetData);
            }
            this.m_buildingArrowOffsetHash[featureName][tagName] = result;
         }
         return result;
      }
      
      public function getDefaultSeedPackageSize() : int
      {
         return this.getInt(DEFAULT_SEED_PACKAGE_SIZE_KEY,50);
      }
      
      public function getShowBasketStages(featureName:String, tagName:String = "showBasketStages") : Boolean
      {
         var result:Boolean = false;
         var creditsXml:XML = this.getBuildingCreditsXml(featureName);
         if(Boolean(creditsXml) && creditsXml.attribute("showBasketStages").toString() == "true")
         {
            result = true;
         }
         return result;
      }
      
      public function xmlHelperCheckAndGetTagValue(result:Array, xmlObj:XMLList, key:String, defaultValue:String = null) : Boolean
      {
         var resValue:Boolean = false;
         if(xmlObj.hasOwnProperty(key) && Boolean(xmlObj[key]))
         {
            result[key] = xmlObj[key].toString();
            resValue = true;
         }
         else if(defaultValue != null)
         {
            result[key] = defaultValue;
            resValue = true;
         }
         return resValue;
      }
      
      public function getBuildingOffBoardData(featureName:String) : Array
      {
         var creditsXml:XML = null;
         var isPreOffBoard:Boolean = false;
         var isOffBoard:Boolean = false;
         var preOffBoardDate:Date = null;
         var endDate:Number = NaN;
         var decorations:Array = null;
         var index:uint = 0;
         var childNode:XML = null;
         var result:Array = this.m_buildingOffBoardHash[featureName];
         if(result == null)
         {
            creditsXml = this.getBuildingCreditsXml(featureName);
            if(!creditsXml)
            {
               creditsXml = Global.farmGameSettingsManager.getFeatureXML(featureName);
            }
            if(Boolean(creditsXml) && Boolean(creditsXml.hasOwnProperty("offboard")) && Boolean(creditsXml.offboard))
            {
               result = new Array();
               if(this.xmlHelperCheckAndGetTagValue(result,creditsXml.offboard,"daysNotice"))
               {
                  result["daysNotice"] = parseInt(result["daysNotice"]);
               }
               if(this.xmlHelperCheckAndGetTagValue(result,creditsXml.offboard,"forceOffboard"))
               {
                  result["forceOffboard"] = result["forceOffboard"] == "true";
               }
               if(this.xmlHelperCheckAndGetTagValue(result,creditsXml.offboard,"date"))
               {
                  isPreOffBoard = false;
                  isOffBoard = false;
                  if(FarmGameUtil.checkStartDateGate(result["date"]))
                  {
                     isOffBoard = true;
                  }
                  else if(result.hasOwnProperty("daysNotice") && result["daysNotice"] != null && result["daysNotice"] > 0)
                  {
                     preOffBoardDate = new Date(result["date"]);
                     preOffBoardDate.setDate(preOffBoardDate.getDate() - result["daysNotice"]);
                     if(FarmGameUtil.checkStartDateGate(preOffBoardDate.getMonth() + 1 + "/" + preOffBoardDate.getDate() + "/" + preOffBoardDate.getFullYear()))
                     {
                        isPreOffBoard = true;
                     }
                  }
                  result["isPreOffBoard"] = isPreOffBoard;
                  result["isOffBoard"] = isOffBoard;
                  if(result["isPreOffBoard"] == true)
                  {
                     endDate = FarmGameUtil.synchronizedDateToNumber(result["date"]);
                     result["timeLeftText"] = FarmGameUtil.getTimeLeftText(endDate / 1000);
                  }
               }
               if(this.xmlHelperCheckAndGetTagValue(result,creditsXml.offboard,"tradeInItemName"))
               {
                  result["tradeInItem"] = Global.farmGameSettingsManager.getFarmItemByName(result["tradeInItemName"]);
               }
               if(this.xmlHelperCheckAndGetTagValue(new Array(),creditsXml.offboard,"offboardReplaceDeco"))
               {
                  decorations = new Array();
                  index = 0;
                  for each(childNode in creditsXml.offboard.offboardReplaceDeco.descendants("decoration"))
                  {
                     decorations[index] = childNode.toString();
                     index++;
                  }
                  if(Boolean(decorations) && decorations.length > 0)
                  {
                     result["offboardReplaceDeco"] = decorations;
                  }
               }
               if(Global.player.isDataLoaded)
               {
                  this.m_buildingOffBoardHash[featureName] = result;
               }
            }
         }
         return result;
      }
      
      public function getBuildingExperimentData(featureName:String) : Array
      {
         var creditsXml:XML = null;
         var experiments:XMLList = null;
         var index:uint = 0;
         var result:Array = this.m_buildingExperimentHash[featureName];
         if(result == null)
         {
            result = new Array();
            creditsXml = this.getBuildingCreditsXml(featureName);
            if(Boolean(creditsXml) && Boolean(creditsXml.hasOwnProperty("experiments")) && Boolean(creditsXml.experiments))
            {
               experiments = creditsXml.experiments.children();
               for(index = 0; index < experiments.length(); index++)
               {
                  if(Boolean(experiments[index].name().toString() == "experiment") && Boolean(experiments[index].hasOwnProperty("@key")) && Boolean(experiments[index].hasOwnProperty("@value")))
                  {
                     result[experiments[index].@key.toString()] = experiments[index].@value.toString();
                  }
               }
               this.m_buildingExperimentHash[featureName] = result;
            }
         }
         return result;
      }
      
      public function getCollections() : XMLList
      {
         return this.m_rawXml.collections.collection;
      }
      
      public function getGeoIpAreas() : XMLList
      {
         return this.m_rawXml.geoipAreas;
      }
      
      public function getItemNameFromMasterySign(masterySignName:String) : String
      {
         var i:int = 0;
         var itemName:String = null;
         if(this.m_masterySignMap.hasOwnProperty(masterySignName))
         {
            itemName = this.m_masterySignMap[masterySignName];
         }
         else
         {
            for(i = 0; i < this.m_masterySignMapArray.length; i++)
            {
               if(this.m_masterySignMapArray[i].hasOwnProperty(masterySignName))
               {
                  itemName = this.m_masterySignMapArray[i][masterySignName];
                  break;
               }
            }
         }
         return itemName;
      }
      
      public function getBuildingProgressionData(buildingName:String) : Object
      {
         var result:Object = null;
         var levels:Array = null;
         var buildingProgressionList:XMLList = null;
         var xmlLevels:XMLList = null;
         var itemXML:XML = null;
         var level:int = 0;
         if(!this.m_buildingProgressionData.hasOwnProperty(buildingName))
         {
            result = {};
            levels = new Array();
            buildingProgressionList = this.m_rawXml.buildingProgressionLevels.buildingProgression.(@name == buildingName);
            if(Boolean(buildingProgressionList) && buildingProgressionList.length() > 0)
            {
               xmlLevels = buildingProgressionList[0].level;
               for each(itemXML in xmlLevels)
               {
                  level = parseInt(itemXML.@value);
                  levels.push(level);
               }
               result.levels = levels;
               if(buildingProgressionList[0].hasOwnProperty("@countMethod"))
               {
                  result.countMethod = String(buildingProgressionList[0]["@countMethod"]);
               }
               if(buildingProgressionList[0].hasOwnProperty("@compareMethod"))
               {
                  result.compareMethod = String(buildingProgressionList[0]["@compareMethod"]);
               }
            }
            this.m_buildingProgressionData[buildingName] = result;
         }
         return this.m_buildingProgressionData[buildingName];
      }
      
      public function getSurfacingStorageBuildingSet(keyword:String) : Array
      {
         var buildingSurfaceXML:XMLList = null;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         var result:Array = new Array();
         if(keyword != null && keyword != "")
         {
            buildingSurfaceXML = xml.featureBuildingSurfacing.storageBuildingSet.(@name == keyword);
            if(buildingSurfaceXML != null)
            {
               this.getStorageBuildingSetFromXML(buildingSurfaceXML[0],result);
            }
         }
         return result;
      }
      
      public function getStorageBuildingSetFromXML(buildingSetXML:XML, buildings:Array) : void
      {
         var node:XML = null;
         var listPrereqs:Array = null;
         if(buildingSetXML.hasOwnProperty("prereqs"))
         {
            listPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(buildingSetXML.child("prereqs").prereq);
         }
         if(listPrereqs == null || PrerequisiteUtility.arePrerequisitesMet(listPrereqs))
         {
            for each(node in buildingSetXML.children())
            {
               switch(node.localName())
               {
                  case "building":
                     buildings.push(node.@name.toString());
                     break;
                  case "storageBuildingSet":
                     this.getStorageBuildingSetFromXML(node,buildings);
               }
            }
         }
      }
      
      public function getCollectionXMLByCode(code:String) : XML
      {
         var result:XML = null;
         var list:XMLList = null;
         result = null;
         list = this.m_rawXml.collections.collection.(@code == code);
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getCollectionByCode(code:String) : Collection
      {
         return new Collection(this.getCollectionXMLByCode(code));
      }
      
      public function getCollectionXMLByCollectableCode(code:String) : XML
      {
         var collectionIdx:int;
         var collectable:XMLList = null;
         var result:XML = null;
         var list:XMLList = this.getCollections();
         for(collectionIdx = 0; collectionIdx < list.length(); collectionIdx++)
         {
            collectable = list[collectionIdx].collectable.(@code == code);
            if(collectable.length())
            {
               result = list[collectionIdx];
               break;
            }
         }
         return result;
      }
      
      public function getSubscriptions() : XML
      {
         var list:XMLList = this.m_rawXml.subscriptions.subscription;
         return list[0];
      }
      
      public function getSubscriptionByItemCode(itemCode:String) : XML
      {
         var result:XML = null;
         var list:XMLList = null;
         var subscriptionXML:XML = null;
         var experimentString:String = null;
         var variant:Number = NaN;
         result = null;
         list = this.m_rawXml.subscriptions.subscription.(@itemCode == itemCode);
         if(list.length())
         {
            subscriptionXML = list[0];
            experimentString = String(subscriptionXML.@experiment);
            if(experimentString != null && experimentString != "")
            {
               variant = Number(subscriptionXML.attribute("variant"));
               if(Global.experimentManager.getExperimentVariant(experimentString) >= variant)
               {
                  result = subscriptionXML;
               }
            }
            else
            {
               result = subscriptionXML;
            }
         }
         return result;
      }
      
      public function getIconCategoryDefinitions() : XMLList
      {
         var iconCategoryDefinitions:XMLList = null;
         var xmlList:XMLList = this.m_rawXml.Slots.Slot;
         if(xmlList.length() > 0)
         {
            iconCategoryDefinitions = xmlList;
         }
         return iconCategoryDefinitions;
      }
      
      public function getIconsByMOTD(PlayerMOTD:int, newMOTD:int) : Array
      {
         var motd:int;
         var list:XMLList = null;
         var index:int = 0;
         var result:Array = new Array();
         for(motd = Math.max(PlayerMOTD + 1,newMOTD - MOTD_ICON_BACKLOG_MAX); motd <= newMOTD; )
         {
            list = this.m_rawXml.icons.icon.(@motd == motd);
            for(index = 0; index < list.length(); index++)
            {
               if(list[index].@motd == newMOTD || list[index].@motd != newMOTD && list[index].@motdExpirable != "true")
               {
                  result.push(new QueuedIcon(list[index]));
               }
            }
            motd++;
         }
         return result;
      }
      
      public function getIconByCodeOrName(codeOrName:String) : QueuedIcon
      {
         var xml:XML = this.getIconXMLByCode(codeOrName);
         var icon:QueuedIcon = null;
         if(xml == null)
         {
            xml = this.getIconXMLByName(codeOrName);
         }
         if(xml != null)
         {
            icon = new QueuedIcon(xml);
         }
         return icon;
      }
      
      public function checkPrereqNode(parentXML:XML, includeParent:Boolean = false) : Boolean
      {
         var prereqs:Array = null;
         var result:Boolean = true;
         if(parentXML.hasOwnProperty("prereqs"))
         {
            prereqs = new Array();
            if(includeParent)
            {
               prereqs = PrerequisiteUtility.parseXmlNodePrereqs(parentXML.prereqs);
            }
            else
            {
               prereqs = PrerequisiteUtility.parseXmlNodePrereqs(parentXML.prereqs.children());
            }
            result = PrerequisiteUtility.arePrerequisitesMet(prereqs);
         }
         return result;
      }
      
      public function getIconXMLByCode(iconCode:String) : XML
      {
         var iconXML:XML = null;
         var iconFound:Boolean = false;
         var iconsXMLList:XMLList = this.m_rawXml.icons.icon;
         for each(iconXML in iconsXMLList)
         {
            if(iconXML.attribute("code") == iconCode)
            {
               iconFound = this.checkPrereqNode(iconXML,true);
               if(iconFound == true)
               {
                  break;
               }
            }
         }
         return iconFound ? iconXML : null;
      }
      
      public function getIconXMLByName(iconName:String) : XML
      {
         var iconXML:XML = null;
         var iconFound:Boolean = false;
         var iconsXMLList:XMLList = this.m_rawXml.icons.icon;
         for each(iconXML in iconsXMLList)
         {
            if(iconXML.attribute("name") == iconName)
            {
               iconFound = this.checkPrereqNode(iconXML,true);
               if(iconFound == true)
               {
                  break;
               }
            }
         }
         return iconFound ? iconXML : null;
      }
      
      public function getCollectionByCollectableCode(code:String) : Collection
      {
         return new Collection(this.getCollectionXMLByCollectableCode(code));
      }
      
      public function getFertilizerData(setting:String) : int
      {
         var fert:XML = null;
         var cutOff:int = 0;
         var result:int = 0;
         var level:int = Global.player.level;
         var curLevel:int = 0;
         var fertData:XMLList = this.m_rawXml.child("fertilizer").children();
         if(fertData)
         {
            for each(fert in fertData)
            {
               cutOff = Number(fert.@levelCutoff);
               if(level >= cutOff && cutOff > curLevel)
               {
                  result = Number(fert.attribute(setting));
                  curLevel = cutOff;
               }
            }
         }
         return result;
      }
      
      public function getHarvestStorageBuildings(type:String, subType:String) : Array
      {
         var harvestStorage:XML = null;
         var buildingGroup:XMLList = null;
         var building:XML = null;
         var buildings:Array = [];
         var buildingGroups:XMLList = this.m_rawXml.harvestStorageBuildings.harvestStorage;
         for each(harvestStorage in buildingGroups)
         {
            if(harvestStorage.@type == type && harvestStorage.@subtype == subType)
            {
               buildingGroup = harvestStorage.building;
               for each(building in buildingGroup)
               {
                  buildings.push(String(building.@name));
               }
               break;
            }
         }
         return buildings;
      }
      
      public function get itemsXMLParsingComplete() : Boolean
      {
         return this.m_itemsXMLParsingComplete;
      }
      
      public function get numItemsXMLParsed() : int
      {
         return this.m_numItemsXMLParsed;
      }
      
      public function initItemsFromRawAmf(itemsAmfRaw:ByteArray) : void
      {
         DataObjectsRegistrar.registerAll();
         DataObjectDataSource.registerAlias();
         m_isFgsmAmfGenerator = true;
         Global.farmGameSettingsManager = this;
         var itemsObject:* = itemsAmfRaw.readObject();
         this.initItems(null,itemsObject);
         this.parseItemsBatch(true);
      }
      
      public function loadFromAmf(fgsmAmfRaw:ByteArray) : void
      {
         registerFarmSettingsClassesForSerialization();
         var localFgsm:FarmGameSettingsManager = fgsmAmfRaw.readObject();
         this.m_idHash = localFgsm.m_idHash;
         this.m_nameHash = localFgsm.m_nameHash;
         this.m_allItemsArray = localFgsm.m_allItemsArray;
         this.m_postProcessArray = localFgsm.m_postProcessArray;
         this.m_actionableFeatureBuildings = localFgsm.m_actionableFeatureBuildings;
         if(GlobalEngine.isFlashVarSetAndTrue(FarmGame.OPS_FGSM_QUEST_ITEM_CAT_ENABLED_FLASH_VAR))
         {
            (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).itemCategories = localFgsm.m_itemCategories;
         }
         this.m_allItemsCount = this.m_allItemsArray.length;
         this.m_isUsingFgsmAmf = true;
      }
      
      public function initItems(itemsXMLList:XMLList, itemsAMFObject:Object = null, optItemsAMFObject:Object = null) : void
      {
         var itemAMF:Object = null;
         var numItems:int = 0;
         var itemDO:BaseItemDO = null;
         var index:String = null;
         var itemXML:XML = null;
         FarmStatsManager.count("perf","background_parse_items","start");
         var counter:int = 0;
         if(optItemsAMFObject)
         {
            this.m_optItemsAMFList = new Vector.<Object>(optItemsAMFObject.length);
            for each(itemAMF in optItemsAMFObject)
            {
               this.m_itemsByCodeHash[itemAMF.code] = itemAMF;
               this.m_itemsByNameHash[itemAMF.name] = itemAMF;
               this.m_optItemsAMFList[counter] = itemAMF;
               this.m_itemsNameToIndexHash[itemAMF.name] = counter;
               counter++;
            }
         }
         else if(itemsAMFObject)
         {
            numItems = int(this.m_itemsAMFList.length);
            for(index in itemsAMFObject)
            {
               if(index != "length")
               {
                  itemDO = itemsAMFObject[index];
                  this.m_itemsByCodeHash[itemDO.code] = itemDO;
                  this.m_itemsByNameHash[itemDO.name] = itemDO;
                  this.m_itemsNameToIndexHash[itemDO.name] = index;
                  this.m_itemsAMFList[index] = itemDO;
                  if(int(index) >= numItems)
                  {
                     ++this.m_itemsAMFList.length;
                  }
               }
            }
         }
         else
         {
            this.m_itemsXMLList = new Vector.<XML>(itemsXMLList.length());
            for each(itemXML in itemsXMLList)
            {
               this.m_itemsByCodeHash[itemXML.@code] = itemXML;
               this.m_itemsByNameHash[itemXML.@name] = itemXML;
               this.m_itemsXMLList[counter] = itemXML;
               this.m_itemsNameToIndexHash[itemXML.@name] = counter;
               counter++;
            }
         }
         FarmLoadPhaseMonitor.updateLoadPhase(FarmLoadPhaseMonitor.ITEMS_PARSED);
      }
      
      public function initItemsMultipleAmfs(itemsXMLList:XMLList, itemsAMFObject:Object = null) : void
      {
         var numItems:int = 0;
         var itemDO:BaseItemDO = null;
         var index:String = null;
         var oldIndex:int = 0;
         var itemXML:XML = null;
         FarmStatsManager.count("perf","background_parse_items","start");
         var counter:int = 0;
         if(itemsAMFObject)
         {
            numItems = int(this.m_itemsAMFList.length);
            for(index in itemsAMFObject)
            {
               if(index != "length")
               {
                  itemDO = itemsAMFObject[index];
                  this.m_itemsByCodeHash[itemDO.code] = itemDO;
                  this.m_itemsByNameHash[itemDO.name] = itemDO;
                  if(this.m_itemsNameToIndexHash[itemDO.name])
                  {
                     oldIndex = int(this.m_itemsNameToIndexHash[itemDO.name]);
                     this.m_itemsAMFList[oldIndex] = itemDO;
                  }
                  else
                  {
                     if(this.m_itemsAMFList.hasOwnProperty(index) && Boolean(this.m_itemsAMFList[index]))
                     {
                        index = this.m_itemsAMFList.length.toString();
                     }
                     this.m_itemsNameToIndexHash[itemDO.name] = index;
                     this.m_itemsAMFList[index] = itemDO;
                     if(int(index) >= numItems)
                     {
                        ++this.m_itemsAMFList.length;
                     }
                  }
               }
            }
         }
         else
         {
            this.m_itemsXMLList = new Vector.<XML>(itemsXMLList.length());
            for each(itemXML in itemsXMLList)
            {
               this.m_itemsByCodeHash[itemXML.@code] = itemXML;
               this.m_itemsByNameHash[itemXML.@name] = itemXML;
               this.m_itemsXMLList[counter] = itemXML;
               this.m_itemsNameToIndexHash[itemXML.@name] = counter;
               counter++;
            }
         }
      }
      
      public function parseItemsBatch(completeNow:Boolean = false, completeNowStatTrackers:Array = null) : void
      {
         var batchEndTime:int = 0;
         var itemsListLength:uint = 0;
         var tracker1:String = null;
         var tracker2:String = null;
         var tracker3:String = null;
         var farmItem:FarmItem = null;
         var baseName:String = null;
         var itemAMF:Object = null;
         var itemDO:BaseItemDO = null;
         var itemXML:XML = null;
         var curMemory:Number = NaN;
         if(!this.m_itemsXMLParsingComplete)
         {
            if(completeNow)
            {
               tracker1 = Boolean(completeNowStatTrackers) && completeNowStatTrackers.length > 0 ? completeNowStatTrackers[0] : "";
               tracker2 = Boolean(completeNowStatTrackers) && completeNowStatTrackers.length > 1 ? completeNowStatTrackers[1] : "";
               tracker3 = Boolean(completeNowStatTrackers) && completeNowStatTrackers.length > 2 ? completeNowStatTrackers[2] : "";
               FarmStatsManager.count("perf","background_parse_items","complete_now",tracker1,tracker2,tracker3);
               GlobalEngine.warning("perf","An action triggered the immediate completion of background parsing of items.xml.  " + "If this action was not user generated, it should be postponed using the FarmItemDependentPostInitIdleTask.");
               batchEndTime = int.MAX_VALUE;
            }
            else
            {
               batchEndTime = getTimer() + MIN_PARSE_ITEMS_BATCH_DURATION;
            }
            if(this.m_isUsingFgsmAmf)
            {
               itemsListLength = uint(this.m_allItemsCount);
               while(this.m_itemsListCounter < itemsListLength)
               {
                  farmItem = this.m_allItemsArray[this.m_itemsListCounter];
                  baseName = farmItem.name.replace(FarmItem.ITEM_POSTFIX_CASH,"");
                  baseName = baseName.replace(FarmItem.ITEM_POSTFIX_SALE,"");
                  if(baseName == farmItem.name)
                  {
                     this.addFarmItem(farmItem);
                  }
                  ++this.m_itemsListCounter;
                  ++this.m_numItemsXMLParsed;
                  if(!completeNow && getTimer() >= batchEndTime)
                  {
                     break;
                  }
               }
            }
            else if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
            {
               itemsListLength = this.m_optItemsAMFList.length;
               if(this.m_itemsListCounter < itemsListLength)
               {
                  while(this.m_itemsListCounter < itemsListLength)
                  {
                     itemAMF = this.m_optItemsAMFList[this.m_itemsListCounter];
                     if(itemAMF)
                     {
                        this.parseItem(null,true,null,itemAMF);
                     }
                     ++this.m_itemsListCounter;
                     if(!completeNow && getTimer() >= batchEndTime)
                     {
                        break;
                     }
                  }
               }
            }
            else if(FarmGameSettingsManager.isInItemsAMFExperiment())
            {
               itemsListLength = uint(this.m_itemsAMFList.length);
               while(this.m_itemsListCounter < itemsListLength)
               {
                  itemDO = this.m_itemsAMFList[this.m_itemsListCounter];
                  if(itemDO)
                  {
                     this.parseItem(null,true,itemDO);
                  }
                  ++this.m_itemsListCounter;
                  if(!completeNow && getTimer() >= batchEndTime)
                  {
                     break;
                  }
               }
            }
            else
            {
               itemsListLength = this.m_itemsXMLList.length;
               if(this.m_itemsListCounter < itemsListLength)
               {
                  while(this.m_itemsListCounter < itemsListLength)
                  {
                     itemXML = this.m_itemsXMLList[this.m_itemsListCounter] as XML;
                     if(itemXML)
                     {
                        this.parseItem(itemXML);
                     }
                     ++this.m_itemsListCounter;
                     if(!completeNow && getTimer() >= batchEndTime)
                     {
                        break;
                     }
                  }
               }
            }
            if(this.m_itemsListCounter >= itemsListLength)
            {
               curMemory = System.totalMemoryNumber;
               if(curMemory < 0)
               {
                  Global.loadingMetricsRecorder.addOptionalMetric(Global.loadingMetricsRecorder.OPT_MEM_NUM_ITEMS_PARSED,System.totalMemoryNumber);
               }
               Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_ITEMS_PARSED,curMemory);
               Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_PVT_ITEMS_PARSED,System.privateMemory);
               Global.loadingMetricsRecorder.addMemoryTimestampMetric(Global.loadingMetricsRecorder.KEY_MEM_MILESTONE_ITEMS_PARSED,GlobalEngine.currentTime.toString());
               this.m_itemsXMLParsingComplete = true;
               this.m_itemsXMLList = new Vector.<XML>();
               this.m_itemsListCounter = 0;
               if(!completeNow)
               {
                  FarmStatsManager.count("perf","background_parse_items","complete");
               }
            }
         }
      }
      
      private function splunkItemsTrackingEnabled() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SPLUNK_ITEMS_TRACKING) > 1;
      }
      
      private function logItemCall(item:FarmItem, source:String = "") : void
      {
         if(this.splunkItemsTrackingEnabled())
         {
            if(!this.m_itemsCalled)
            {
               this.m_itemsCalled = new Dictionary();
            }
            if(!this.m_itemsCalled[item.name])
            {
               ++this.m_numItemsAccessed;
               StatsManager.count(ITEMS_ACCESS_COUNTER,item.name,item.code,this.m_numItemsAccessed.toString());
               this.m_itemsCalled[item.name] = true;
            }
         }
      }
      
      private function parseItem(itemXML:XML, alsoParseItemsWithCommonBaseName:Boolean = true, itemData:BaseItemDO = null, optItem:Object = null) : FarmItem
      {
         var item:FarmItem = null;
         var name:String = null;
         var code:String = null;
         var itemDataSource:BaseDataSource = null;
         if(optItem)
         {
            name = optItem.name;
         }
         else if(itemData)
         {
            name = itemData.name;
         }
         else
         {
            name = itemXML.@name;
         }
         if(optItem)
         {
            code = optItem.code;
         }
         else if(itemData)
         {
            code = itemData.code;
         }
         else
         {
            code = itemXML.@code;
         }
         var baseName:String = name.replace(FarmItem.ITEM_POSTFIX_CASH,"");
         baseName = baseName.replace(FarmItem.ITEM_POSTFIX_SALE,"");
         var appendName:String = name.replace(baseName,"");
         this.m_itemsByCodeHash[code] = null;
         this.m_itemsByNameHash[name] = null;
         if(optItem)
         {
            this.m_optItemsAMFList[this.m_itemsNameToIndexHash[name]] = null;
         }
         else if(itemData)
         {
            this.m_itemsAMFList[this.m_itemsNameToIndexHash[name]] = null;
         }
         else
         {
            this.m_itemsXMLList[this.m_itemsNameToIndexHash[name]] = null;
         }
         if(name != baseName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(baseName);
         }
         var mergedItemFlag:Boolean = false;
         if(item)
         {
            mergedItemFlag = true;
         }
         else
         {
            item = FarmGameSettingsInit.createItemConfigInstance(itemXML,itemData,optItem);
         }
         if(item)
         {
            itemDataSource = null;
            if(!mergedItemFlag)
            {
               itemDataSource = item.getDataSource();
            }
            if(!itemDataSource)
            {
               if(optItem)
               {
                  itemDataSource = new OptItemDataSource(optItem);
               }
               else if(itemData)
               {
                  itemDataSource = new DataObjectDataSource(itemData);
               }
               else if(isInDataSourceExperiment())
               {
                  itemDataSource = new XMLDataSource(itemXML);
               }
            }
            Global.farmGameSettingsManager.addFarmItem(item,itemXML,appendName,mergedItemFlag,itemDataSource);
            ++this.m_numItemsXMLParsed;
            if(alsoParseItemsWithCommonBaseName && name == baseName)
            {
               this.parseItemByName(name + FarmItem.ITEM_POSTFIX_CASH);
               this.parseItemByName(name + FarmItem.ITEM_POSTFIX_SALE);
            }
         }
         else if((Global.toolMode || Global.player.isAutomatedQA) && Boolean(itemXML))
         {
            ErrorManager.addError("FarmGameSettingsInit :: missing xml for item named " + name);
         }
         return item;
      }
      
      private function parseItemByCode(itemCode:String) : FarmItem
      {
         var item:FarmItem = null;
         var itemXML:XML = null;
         var itemDO:BaseItemDO = null;
         var optItem:Object = null;
         if(this.m_itemsByCodeHash)
         {
            if(isInOptItemsAMFExperiment())
            {
               optItem = this.m_itemsByCodeHash[itemCode];
            }
            else if(isInItemsAMFExperiment())
            {
               itemDO = this.m_itemsByCodeHash[itemCode];
            }
            else
            {
               itemXML = this.m_itemsByCodeHash[itemCode] as XML;
            }
            if(Boolean(itemXML) || Boolean(itemDO) || Boolean(optItem))
            {
               item = this.parseItem(itemXML,true,itemDO,optItem);
            }
         }
         if(item)
         {
            this.logItemCall(item,"byCode");
         }
         return item;
      }
      
      private function parseItemByName(itemName:String) : FarmItem
      {
         var item:FarmItem = null;
         var itemXML:XML = null;
         var itemDO:BaseItemDO = null;
         var optItem:Object = null;
         if(this.m_itemsByNameHash)
         {
            if(isInOptItemsAMFExperiment())
            {
               optItem = this.m_itemsByNameHash[itemName];
            }
            else if(isInItemsAMFExperiment())
            {
               itemDO = this.m_itemsByNameHash[itemName];
            }
            else
            {
               itemXML = this.m_itemsByNameHash[itemName] as XML;
            }
            if(Boolean(itemXML) || Boolean(itemDO) || Boolean(optItem))
            {
               item = this.parseItem(itemXML,true,itemDO,optItem);
            }
         }
         if(item)
         {
            this.logItemCall(item,"byName");
         }
         return item;
      }
      
      private function addFarmItemToTypeHashes(farmItem:FarmItem, commands:Array, typeHashToAdd:Object = null) : void
      {
         var worldId:String = null;
         var command:Array = null;
         var type:String = null;
         var typeHash:Object = null;
         var typeArray:Array = null;
         var subType:String = null;
         var subTypeArray:Array = null;
         var subSubType:String = null;
         var subSubTypeArray:Array = null;
         if(typeHashToAdd == null)
         {
            typeHashToAdd = this.m_typesHash;
         }
         var worldRestrictions:Array = farmItem.worldRestrictions;
         if(worldRestrictions.length == 0)
         {
            worldRestrictions.push(ANY_WORLD);
         }
         for each(worldId in worldRestrictions)
         {
            for each(command in commands)
            {
               type = command[0];
               typeHash = typeHashToAdd[type];
               if(!typeHash)
               {
                  typeHash = {};
                  typeHashToAdd[type] = typeHash;
               }
               typeArray = typeHash[type + worldId];
               if(!typeArray)
               {
                  typeArray = [];
                  typeHash[type + worldId] = typeArray;
               }
               if(typeArray[typeArray.length - 1] != farmItem)
               {
                  typeArray.push(farmItem);
               }
               if(command.length > 1 && Boolean(command[1]))
               {
                  subType = command[1];
                  subTypeArray = typeHash[type + subType + worldId];
                  if(!subTypeArray)
                  {
                     subTypeArray = [];
                     typeHash[type + subType + worldId] = subTypeArray;
                  }
                  if(subTypeArray[subTypeArray.length - 1] != farmItem)
                  {
                     subTypeArray.push(farmItem);
                  }
                  if(command.length > 2 && Boolean(command[2]))
                  {
                     subSubType = command[2];
                     subSubTypeArray = typeHash[type + subType + subSubType + worldId];
                     if(!subSubTypeArray)
                     {
                        subSubTypeArray = [];
                        typeHash[type + subType + subSubType + worldId] = subSubTypeArray;
                     }
                     subSubTypeArray.push(farmItem);
                  }
               }
            }
         }
      }
      
      public function addFarmItem(farmItem:FarmItem, itemXML:XML = null, appendName:String = "", mergedItemFlag:Boolean = false, itemDataSource:BaseDataSource = null) : void
      {
         var itemName:String = null;
         var itemMarketType:String = null;
         var isImplicitCashItem:Boolean = false;
         var type:String = null;
         var isClothing:Boolean = false;
         if(farmItem)
         {
            if(!this.m_isUsingFgsmAmf)
            {
               if(itemDataSource)
               {
                  itemName = itemDataSource.getString("name");
                  itemMarketType = itemDataSource.getString("market");
                  isImplicitCashItem = itemDataSource.hasProperty("market") && itemDataSource.hasProperty("cash");
               }
               else
               {
                  itemName = itemXML.@name;
                  itemMarketType = itemXML.@market;
                  isImplicitCashItem = itemXML.hasOwnProperty(XMLKeys.ATTR_MARKET) && itemXML.hasOwnProperty("cash");
               }
               if(appendName == FarmItem.ITEM_POSTFIX_SALE)
               {
                  farmItem.saleXML = itemXML;
                  farmItem.saleData = itemDataSource;
                  addZItem(farmItem,itemName,farmItem.saleCode);
               }
               else if(itemMarketType == Currency.CASH || itemMarketType == Currency.BOTH || appendName == FarmItem.ITEM_POSTFIX_CASH || isImplicitCashItem)
               {
                  farmItem.cashXML = itemXML;
                  farmItem.cashData = itemDataSource;
                  addZItem(farmItem,itemName,farmItem.cashCode);
               }
               else
               {
                  farmItem.xml = itemXML;
                  addZItem(farmItem,itemName,farmItem.code);
               }
               type = farmItem.type;
               if(type == FarmItemType.BUILDING)
               {
                  if(farmItem.className == "FeatureBuilding" && Boolean((farmItem as BuildingItem).neighborAction))
                  {
                     Global.farmGameSettingsManager.addActionableFeatureBuilding(farmItem);
                  }
               }
            }
            if(!mergedItemFlag)
            {
               if(!this.m_isUsingFgsmAmf)
               {
                  this.m_allItemsArray.push(farmItem);
                  this.m_postProcessArray.push(farmItem);
               }
               if(!m_isFgsmAmfGenerator)
               {
                  this.addOptimizedSearchEntry(farmItem,itemXML);
                  isClothing = farmItem is ClothingItem;
                  if(isClothing || !PerformanceExperimentManager.isInBuildtimeConfigExperiment)
                  {
                     this.addMarketConfigInfo(farmItem,itemXML);
                  }
               }
            }
         }
         else
         {
            ErrorManager.addError("null farmItem passed to addFarmItem");
         }
      }
      
      private function addOptimizedSearchEntry(farmItem:FarmItem, itemXML:XML) : void
      {
         var isBuyable:Boolean = false;
         if(this.m_marketSearchOptimizationCachedExperimentVariant == -1)
         {
            this.m_marketSearchOptimizationCachedExperimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SEARCH_OPTIMIZATION);
         }
         if(Config.DEBUG_MODE || this.m_marketSearchOptimizationCachedExperimentVariant == Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(isInDataSourceExperiment())
            {
               isBuyable = farmItem.buyable;
            }
            else
            {
               isBuyable = itemXML.@buyable == "true";
            }
            if(isBuyable)
            {
               m_marketSearchTernaryTree.addNewString(farmItem.friendlyTitle,farmItem.name);
            }
         }
      }
      
      private function addMarketConfigInfo(farmItem:FarmItem, itemXML:XML) : void
      {
         var hasMarketEntries:Boolean = false;
         var marketCardDescriptor:String = null;
         var type:String = null;
         var subtype:String = null;
         var subsubtype:String = null;
         var market3Type:String = null;
         var market3Subtype:String = null;
         var market3Subsubtype:String = null;
         var marketMappings:Array = null;
         var marketMapping:MarketMapping = null;
         var marketEntriesArray:Array = null;
         var marketEntryData:BaseDataSource = null;
         var marketEntries:XMLList = null;
         var marketEntry:XML = null;
         var classNameArray:Array = null;
         var keyword:String = null;
         var licenseArray:Array = null;
         var levelArray:Array = null;
         var finalLevelData:BaseDataSource = null;
         var levels:XMLList = null;
         var level:XML = null;
         var commandArray:Array = [];
         var market3CommandArray:Array = [];
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            hasMarketEntries = farmItem.hasPropertyInDataSource("marketEntries");
         }
         else
         {
            hasMarketEntries = itemXML.hasOwnProperty("marketEntries");
         }
         if(hasMarketEntries)
         {
            if(isInDataSourceExperiment)
            {
               marketEntriesArray = farmItem.getArrayFromDataSource("marketEntries","marketEntry");
               for each(marketEntryData in marketEntriesArray)
               {
                  type = market3Type = marketEntryData.getString("type");
                  subtype = market3Subtype = marketEntryData.getString("subtype");
                  subsubtype = market3Subsubtype = marketEntryData.getString("subsubtype");
                  if(subsubtype)
                  {
                     commandArray.push([type,subtype,subsubtype]);
                     farmItem.marketEntriesHash[type + subtype + subsubtype] = true;
                     farmItem.marketEntriesHash[type + subtype] = true;
                     farmItem.marketEntriesHash[type] = true;
                  }
                  else if(subtype)
                  {
                     commandArray.push([type,subtype]);
                     farmItem.marketEntriesHash[type + subtype] = true;
                     farmItem.marketEntriesHash[type] = true;
                  }
                  else
                  {
                     commandArray.push([type]);
                     farmItem.marketEntriesHash[type] = true;
                  }
                  marketMappings = Global.marketConfigSettings.getMarketMappings(type,subtype,subsubtype,farmItem);
                  if(marketMappings.length == 0)
                  {
                     if(market3Subsubtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else if(market3Subtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else
                     {
                        market3CommandArray.push([market3Type]);
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                  }
                  for each(marketMapping in marketMappings)
                  {
                     market3Type = marketMapping.outputType;
                     market3Subtype = marketMapping.outputSubtype;
                     market3Subsubtype = marketMapping.outputSubsubtype;
                     if(market3Subsubtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else if(market3Subtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else
                     {
                        market3CommandArray.push([market3Type]);
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                  }
               }
            }
            else
            {
               marketEntries = itemXML.marketEntries.marketEntry;
               for each(marketEntry in marketEntries)
               {
                  type = "";
                  subtype = "";
                  subsubtype = "";
                  market3Type = "";
                  market3Subtype = "";
                  market3Subsubtype = "";
                  type = market3Type = marketEntry.@type.toString();
                  if(marketEntry.@subsubtype.toString() != "")
                  {
                     subtype = market3Subtype = marketEntry.@subtype.toString();
                     subsubtype = market3Subsubtype = marketEntry.@subsubtype.toString();
                     commandArray.push([type,subtype,subsubtype]);
                     farmItem.marketEntriesHash[type + subtype + subsubtype] = true;
                     farmItem.marketEntriesHash[type + subtype] = true;
                     farmItem.marketEntriesHash[type] = true;
                  }
                  else if(marketEntry.@subtype.toString() != "")
                  {
                     subtype = market3Subtype = marketEntry.@subtype.toString();
                     commandArray.push([type,subtype]);
                     farmItem.marketEntriesHash[type + subtype] = true;
                     farmItem.marketEntriesHash[type] = true;
                  }
                  else
                  {
                     commandArray.push([type]);
                     farmItem.marketEntriesHash[type] = true;
                  }
                  marketMappings = Global.marketConfigSettings.getMarketMappings(type,subtype,subsubtype,farmItem);
                  if(marketMappings.length == 0)
                  {
                     if(market3Subsubtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else if(market3Subtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else
                     {
                        market3CommandArray.push([market3Type]);
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                  }
                  for each(marketMapping in marketMappings)
                  {
                     market3Type = marketMapping.outputType;
                     market3Subtype = marketMapping.outputSubtype;
                     market3Subsubtype = marketMapping.outputSubsubtype;
                     if(market3Subsubtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else if(market3Subtype != "")
                     {
                        market3CommandArray.push([market3Type,market3Subtype]);
                        farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                     else
                     {
                        market3CommandArray.push([market3Type]);
                        farmItem.market3EntriesHash[market3Type] = true;
                     }
                  }
               }
            }
         }
         else
         {
            type = subtype = subsubtype = "";
            market3Type = market3Subtype = market3Subsubtype = "";
            if(farmItem.category == "")
            {
               type = farmItem.type;
               subtype = farmItem.subType;
            }
            else
            {
               type = farmItem.category;
               subtype = farmItem.subType;
            }
            commandArray.push([type,subtype]);
            farmItem.marketEntriesHash[type + subtype] = true;
            farmItem.marketEntriesHash[type] = true;
            market3Type = type;
            market3Subtype = subtype;
            marketMappings = Global.marketConfigSettings.getMarketMappings(type,subtype,"",farmItem);
            if(marketMappings.length == 0)
            {
               if(market3Subsubtype != "")
               {
                  market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                  farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                  farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                  farmItem.market3EntriesHash[market3Type] = true;
               }
               else if(market3Subtype != "")
               {
                  market3CommandArray.push([market3Type,market3Subtype]);
                  farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                  farmItem.market3EntriesHash[market3Type] = true;
               }
               else
               {
                  market3CommandArray.push([market3Type]);
                  farmItem.market3EntriesHash[market3Type] = true;
               }
            }
            for each(marketMapping in marketMappings)
            {
               market3Type = marketMapping.outputType;
               market3Subtype = marketMapping.outputSubtype;
               market3Subsubtype = marketMapping.outputSubsubtype;
               if(market3Subsubtype != "")
               {
                  market3CommandArray.push([market3Type,market3Subtype,market3Subsubtype]);
                  farmItem.market3EntriesHash[market3Type + market3Subtype + market3Subsubtype] = true;
                  farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                  farmItem.market3EntriesHash[market3Type] = true;
               }
               else if(market3Subtype != "")
               {
                  market3CommandArray.push([market3Type,market3Subtype]);
                  farmItem.market3EntriesHash[market3Type + market3Subtype] = true;
                  farmItem.market3EntriesHash[market3Type] = true;
               }
               else
               {
                  market3CommandArray.push([market3Type]);
                  farmItem.market3EntriesHash[market3Type] = true;
               }
            }
         }
         if(isInDataSourceExperiment)
         {
            marketCardDescriptor = farmItem.getStringFromDataSource("marketCardDescriptor");
         }
         else
         {
            marketCardDescriptor = itemXML.marketCardDescriptor;
         }
         if(marketCardDescriptor)
         {
            commandArray.push([marketCardDescriptor,type]);
            market3CommandArray.push([marketCardDescriptor,market3Type]);
         }
         if(farmItem.type == "seed")
         {
            commandArray.push([farmItem.type,"seeds"]);
            market3CommandArray.push([farmItem.type,"seeds"]);
         }
         this.addFarmItemToTypeHashes(farmItem,commandArray);
         this.addFarmItemToTypeHashes(farmItem,market3CommandArray,this.m_market3TypesHash);
         if(farmItem.className != "")
         {
            classNameArray = this.m_classNameHash[farmItem.className];
            if(!classNameArray)
            {
               classNameArray = [];
               this.m_classNameHash[farmItem.className] = classNameArray;
            }
            classNameArray.push(farmItem);
         }
         if(farmItem.aoeTargetKeywords.length != 0)
         {
            for each(keyword in farmItem.aoeTargetKeywords)
            {
               if(this.m_aoeTargetKeywordHash.hasOwnProperty(keyword))
               {
                  this.m_aoeTargetKeywordHash[keyword].push(farmItem);
               }
               else
               {
                  this.m_aoeTargetKeywordHash[keyword] = [farmItem];
               }
            }
         }
         if(farmItem.license != "")
         {
            licenseArray = this.m_licenseItemHash[farmItem.license];
            if(!licenseArray)
            {
               licenseArray = [];
               this.m_licenseItemHash[farmItem.license] = licenseArray;
            }
            licenseArray.push(farmItem);
         }
         if(farmItem is SeedItem && (farmItem as SeedItem).isSuperCrop())
         {
            if(!this.m_superCrops)
            {
               this.m_superCrops = new Array();
            }
            this.m_superCrops.push(farmItem as SeedItem);
         }
         if(isInDataSourceExperiment)
         {
            if(farmItem.getBoolFromDataSource("mastery") && farmItem.hasPropertyInDataSource("masteryLevel"))
            {
               levelArray = farmItem.getArrayFromDataSource("masteryLevel");
               if(levelArray.length > 0)
               {
                  finalLevelData = levelArray[levelArray.length - 1];
                  this.m_masterySignMap[finalLevelData.getString("gift")] = farmItem.name;
               }
            }
         }
         else if(itemXML.@mastery == "true" && itemXML.hasOwnProperty("masteryLevel"))
         {
            try
            {
               levels = itemXML.masteryLevel;
               level = levels[levels.length() - 1];
               this.m_masterySignMap[String(level.@gift)] = farmItem.name;
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public function getSuperCropForSeedItem(baseSeedItem:SeedItem) : SeedItem
      {
         var requirement:SuperCropRequirement = null;
         var result:SeedItem = null;
         var superSeed:SeedItem = null;
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment && this.m_superCrops.length > 0 && this.m_superCrops[0] is String)
         {
            this.m_superCrops = this.getFarmItemsArrayByNames(this.m_superCrops,true);
         }
         for each(superSeed in this.m_superCrops)
         {
            requirement = superSeed.getRequirement("SuperCropRequirement") as SuperCropRequirement;
            if(Boolean(requirement) && requirement.masteryCropName == baseSeedItem.name)
            {
               result = superSeed;
               break;
            }
         }
         return result;
      }
      
      public function addActionableFeatureBuilding(farmItem:FarmItem) : void
      {
         this.m_actionableFeatureBuildings.push(farmItem);
      }
      
      public function get actionableFeatureBuildings() : Array
      {
         return this.m_actionableFeatureBuildings;
      }
      
      private function createSpecialMarketTypes() : void
      {
         var farmItem:FarmItem = null;
         var commandArray:Array = null;
         var market3CommandArray:Array = null;
         var managedSalePrice:int = 0;
         var worldSalePrice:int = 0;
         var categorySalePrice:int = 0;
         var vipSalePrice:int = 0;
         var market3ManagedCommandArray:Array = null;
         var managedCommandArray:Array = null;
         var market3WorldCommandArray:Array = null;
         var worldCommandArray:Array = null;
         var market3CategoryCommandArray:Array = null;
         var categoryCommandArray:Array = null;
         var market3VIPCommandArray:Array = null;
         var vipCommandArray:Array = null;
         var market3EntriesTypeArray:Object = null;
         var typeArray:Array = null;
         var minPrice:int = 0;
         var managedSale:ManagedSale = null;
         var vipSale:ManagedSale = null;
         this.parseItemsBatch(true,["createSpecialMarketTypes"]);
         while(this.m_postProcessArray.length > 0)
         {
            farmItem = this.m_postProcessArray.pop();
            commandArray = [];
            market3CommandArray = [];
            if(farmItem.isLimitedItem())
            {
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_3_LIMITED_TAB) < 2)
               {
                  market3CommandArray.push([TYPE_LIMITED]);
                  commandArray.push([TYPE_LIMITED]);
               }
            }
            managedSalePrice = 100000;
            worldSalePrice = 100000;
            categorySalePrice = 100000;
            vipSalePrice = 100000;
            market3ManagedCommandArray = [];
            managedCommandArray = [];
            market3WorldCommandArray = [];
            worldCommandArray = [];
            market3CategoryCommandArray = [];
            categoryCommandArray = [];
            market3VIPCommandArray = [];
            vipCommandArray = [];
            typeArray = [];
            if(Global.managedSalesManager.isEnabled() && Boolean(Global.managedSalesManager.getSaleObject(farmItem)))
            {
               managedSale = Global.managedSalesManager.getSaleObject(farmItem);
               managedSalePrice = managedSale.price;
               market3EntriesTypeArray = farmItem.market3EntriesTypeArray;
               for each(typeArray in market3EntriesTypeArray)
               {
                  if(typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX] != "")
                  {
                     market3ManagedCommandArray.push([TYPE_MANAGED_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                     managedCommandArray.push([TYPE_MANAGED_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                  }
               }
            }
            typeArray = [];
            if(Global.worldSpecificSalesManager.isActive() && Global.worldSpecificSalesManager.inSale(farmItem))
            {
               worldSalePrice = Global.worldSpecificSalesManager.price(farmItem.cash);
               market3EntriesTypeArray = farmItem.market3EntriesTypeArray;
               for each(typeArray in market3EntriesTypeArray)
               {
                  if(typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX] != "")
                  {
                     market3WorldCommandArray.push([TYPE_WORLD_SPECIFIC_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                     worldCommandArray.push([TYPE_WORLD_SPECIFIC_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                  }
               }
            }
            typeArray = [];
            if(Global.categorySpecificSalesManager.isActive() && Global.categorySpecificSalesManager.inSale(farmItem))
            {
               categorySalePrice = Global.categorySpecificSalesManager.price(farmItem.cash);
               market3EntriesTypeArray = farmItem.market3EntriesTypeArray;
               for each(typeArray in market3EntriesTypeArray)
               {
                  if(typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX] != "")
                  {
                     market3CategoryCommandArray.push([TYPE_CATEGORY_SPECIFIC_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                     categoryCommandArray.push([TYPE_CATEGORY_SPECIFIC_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                  }
               }
            }
            typeArray = [];
            if(Global.vipSalesManager.isEnabled())
            {
               vipSale = Global.vipSalesManager.getSaleObject(farmItem);
               if(vipSale)
               {
                  vipSalePrice = vipSale.price;
                  market3EntriesTypeArray = farmItem.market3EntriesTypeArray;
                  for each(typeArray in market3EntriesTypeArray)
                  {
                     if(typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX] != "")
                     {
                        market3VIPCommandArray.push([TYPE_MANAGED_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                        vipCommandArray.push([TYPE_MANAGED_SALE,typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX]]);
                     }
                  }
                  market3VIPCommandArray.push([TYPE_MANAGED_SALE,"VIP"]);
                  vipCommandArray.push([TYPE_MANAGED_SALE,"VIP"]);
               }
            }
            minPrice = Math.min(worldSalePrice,Math.min(managedSalePrice,categorySalePrice,vipSalePrice));
            if(minPrice != 100000 && minPrice == worldSalePrice)
            {
               market3CommandArray = market3CommandArray.concat(market3WorldCommandArray);
               commandArray = commandArray.concat(worldCommandArray);
               Global.worldSpecificSalesManager.setSaleSubType(farmItem);
            }
            else if(minPrice != 100000 && minPrice == managedSalePrice)
            {
               market3CommandArray = market3CommandArray.concat(market3ManagedCommandArray);
               commandArray = commandArray.concat(managedCommandArray);
            }
            else if(minPrice != 100000 && minPrice == categorySalePrice)
            {
               market3CommandArray = market3CommandArray.concat(market3CategoryCommandArray);
               commandArray = commandArray.concat(categoryCommandArray);
               Global.categorySpecificSalesManager.setSaleSubType(farmItem);
            }
            else if(minPrice != 100000 && minPrice == vipSalePrice)
            {
               market3CommandArray = market3CommandArray.concat(market3VIPCommandArray);
               commandArray = commandArray.concat(vipCommandArray);
            }
            if(farmItem.isNew)
            {
               commandArray.push([TYPE_NEW]);
               market3CommandArray.push([TYPE_NEW]);
            }
            if(farmItem.isGameToken)
            {
               commandArray.push([TYPE_GAME_TOKEN]);
               market3CommandArray.push([TYPE_NEW]);
            }
            this.addFarmItemToTypeHashes(farmItem,commandArray);
            this.addFarmItemToTypeHashes(farmItem,market3CommandArray,this.m_market3TypesHash);
         }
      }
      
      public function getFarmItemsArray(type:String, subtype:String = "all", subsubtype:String = "all", sortBy:String = "level", sortDirection:String = "desc", removeInvisible:Boolean = true, searchString:String = "", terrainCodes:Array = null, isMarket3:Boolean = false) : Array
      {
         var farmItem:FarmItem = null;
         var sortFunction:Function = null;
         var presorts:XMLList = null;
         var presortManagedSales:Boolean = false;
         var presort:XML = null;
         var indexOf:int = 0;
         var standardPresorts:XMLList = null;
         var presortNumber:int = 0;
         var presortNode:XML = null;
         var managedSales:Array = null;
         var managedSaleItems:Array = null;
         var sale:String = null;
         var saleItem:FarmItem = null;
         var name:String = null;
         var j:int = 0;
         var superCrop:FarmItem = null;
         var superCropRequirmement:SuperCropRequirement = null;
         var superCrops:Array = null;
         var insertIndex:int = 0;
         this.parseItemsBatch(true,["getFarmItemsArray",type,subtype]);
         var returnArray:Array = [];
         var i:* = 0;
         if(searchString == "")
         {
            if(!this.m_hadValidServerTime && GlobalEngine.isServerTimeValid())
            {
               this.m_hadValidServerTime = true;
               this.createSpecialMarketTypes();
            }
            returnArray = this.getFarmItemsMergedByWorld(type,subtype,subsubtype,isMarket3);
            returnArray = applyTerrainRestriction(returnArray,terrainCodes);
            if(removeInvisible)
            {
               returnArray = removeInvisibleItems(returnArray);
            }
            sortFunction = this.m_sortFunctionHash[DEFAULT];
            if(this.m_sortFunctionHash.hasOwnProperty(sortBy))
            {
               sortFunction = this.m_sortFunctionHash[sortBy];
            }
            returnArray.sort(sortFunction);
            if(sortDirection == ASCENDING)
            {
               returnArray.reverse();
            }
            presorts = null;
            presortManagedSales = false;
            switch(sortBy)
            {
               case WORLD_SORT:
                  presorts = Global.marketConfigSettings.getPresortAllWorldXMLList(type);
                  standardPresorts = Global.marketConfigSettings.getPresortXMLList(type);
                  presortNumber = 0;
                  for each(presortNode in standardPresorts)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(presortNode.@name);
                     if(Boolean(farmItem) && (presortNumber < Global.flashHotParams["MARKET_PRESORT_FIX_OPS"] && farmItem.isVisible || farmItem.marketCardName == Global.worldManager.currentWorldUniqueMarketCard || farmItem.marketCardName == Global.worldManager.currentWorldUniqueMarketCard2))
                     {
                        if(!presorts)
                        {
                           presorts = XMLList(presortNode);
                        }
                        else
                        {
                           presorts += presortNode;
                        }
                        presortNumber++;
                     }
                  }
                  break;
               case DEFAULT:
               case LE_START:
                  presorts = Global.marketConfigSettings.getPresortXMLList(type);
                  presortManagedSales = true;
            }
            if(presorts)
            {
               for(i = int(presorts.length() - 1); i >= 0; i--)
               {
                  presort = presorts[i];
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(presort.@name);
                  if(farmItem)
                  {
                     indexOf = returnArray.indexOf(farmItem);
                     if(indexOf >= 0)
                     {
                        returnArray.splice(indexOf,1);
                        returnArray.unshift(farmItem);
                     }
                  }
               }
            }
            if(presortManagedSales == true)
            {
               managedSales = Global.managedSalesManager.getPresortList();
               if(managedSales)
               {
                  managedSaleItems = new Array();
                  for each(sale in managedSales)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(sale);
                     if(farmItem)
                     {
                        managedSaleItems.push(farmItem);
                     }
                     else
                     {
                        StatsManager.count("errors","invalid_managed_sale","sale");
                     }
                  }
                  managedSaleItems.sort(sortFunction);
                  for each(saleItem in managedSaleItems)
                  {
                     indexOf = returnArray.indexOf(saleItem);
                     if(indexOf >= 0)
                     {
                        returnArray.splice(indexOf,1);
                        returnArray.unshift(saleItem);
                     }
                  }
               }
            }
         }
         else
         {
            for(j = 0; j < this.friendlyNameArray.length; j++)
            {
               farmItem = this.friendlyNameArray[j][0];
               name = this.friendlyNameArray[j][1];
               if(farmItem.isVisible)
               {
                  if(name.search(searchString) != -1)
                  {
                     returnArray.push(farmItem);
                  }
               }
            }
            returnArray = applyTerrainRestriction(returnArray,terrainCodes);
         }
         if(type == "seed")
         {
            superCrops = new Array();
            if("" == searchString)
            {
               for(i = 0; i < returnArray.length; i++)
               {
                  superCrop = returnArray[i];
                  if(superCrop is SeedItem && (superCrop as SeedItem).isSuperCrop())
                  {
                     superCropRequirmement = superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(superCropRequirmement.masteryCropName);
                     if(returnArray.indexOf(farmItem) < 0)
                     {
                        returnArray.splice(i,1);
                        i--;
                     }
                  }
               }
            }
            if(sortBy != SUPER_CROP)
            {
               for(i = 0; i < returnArray.length; i++)
               {
                  superCrop = returnArray[i];
                  if(superCrop is SeedItem && (superCrop as SeedItem).isSuperCrop())
                  {
                     returnArray.splice(i,1);
                     i--;
                     superCrops.push(superCrop);
                  }
               }
               for each(superCrop in superCrops)
               {
                  superCropRequirmement = superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(superCropRequirmement.masteryCropName);
                  insertIndex = returnArray.indexOf(farmItem) + 1;
                  returnArray.splice(insertIndex,0,superCrop);
               }
            }
         }
         return returnArray;
      }
      
      private function getFarmItemsMergedByWorld(type:String, subType:String = "all", subSubType:String = "all", isMarket3:Boolean = false) : Array
      {
         var worldId:String = null;
         var hashKey:String = null;
         var worldLicensedItems:Array = null;
         var item:FarmItem = null;
         var result:Array = [];
         var maxNumberOfLockedItems:int = Global.farmGameSettingsManager.getInt("maxWorldLockedItems",0);
         var excludedHashKeys:Array = ["aideexpansion","aide"];
         var currentWorldId:String = Global.worldManager.currentWorldType;
         var items:Array = this.getFarmItemsArrayByType(type,subType,subSubType,currentWorldId,isMarket3);
         if(Boolean(items) && items.length > 0)
         {
            result = result.concat(items);
         }
         if(Global.worldSpecificSalesManager.isActive() && type == TYPE_WORLD_SPECIFIC_SALE && currentWorldId != Global.worldSpecificSalesManager.worldName)
         {
            items = this.getFarmItemsArrayByType(type,subType,subSubType,Global.worldSpecificSalesManager.worldName,isMarket3);
            if(Boolean(items) && items.length > 0)
            {
               result = result.concat(items);
            }
         }
         for each(worldId in WorldsConstants.ALL_WORLDS)
         {
            if(worldId != currentWorldId)
            {
               items = this.getFarmItemsArrayByType(type,subType,subSubType,worldId,isMarket3);
               if(Boolean(items) && items.length > 0)
               {
                  hashKey = this.getTypeHashKey(type,subType,subSubType);
                  if(worldId != WorldsConstants.WORLD_ID_HOME && excludedHashKeys.indexOf(hashKey) < 0)
                  {
                     result = result.concat(items.slice(0,maxNumberOfLockedItems));
                  }
                  worldLicensedItems = [];
                  for each(item in items)
                  {
                     if(item.meetsWorldLicenseRequirements() == true && result.indexOf(item) < 0)
                     {
                        worldLicensedItems.push(item);
                     }
                  }
                  result = result.concat(worldLicensedItems);
               }
            }
         }
         items = this.getFarmItemsArrayByType(type,subType,subSubType,ANY_WORLD,isMarket3);
         if(Boolean(items) && items.length > 0)
         {
            result = result.concat(items);
         }
         return result;
      }
      
      public function getFarmItemsArrayByNames(itemNames:Array, uniqueItems:Boolean = false) : Array
      {
         var uniqueItemLookup:Object = null;
         var itemName:String = null;
         var item:FarmItem = null;
         var mergedName:String = null;
         var result:Array = new Array();
         if(uniqueItems)
         {
            uniqueItemLookup = {};
         }
         for each(itemName in itemNames)
         {
            item = this.getFarmItemByName(itemName);
            if(item)
            {
               mergedName = item.name;
               if(!uniqueItems || !uniqueItemLookup[mergedName])
               {
                  if(uniqueItems)
                  {
                     uniqueItemLookup[mergedName] = true;
                  }
                  result.push(item);
               }
            }
         }
         return result;
      }
      
      public function getFarmItemByCode(code:String) : FarmItem
      {
         var item:FarmItem = m_idHash[code] as FarmItem;
         if(!item)
         {
            item = this.parseItemByCode(code);
         }
         return item;
      }
      
      public function getFarmItemByName(name:String) : FarmItem
      {
         var item:FarmItem = m_nameHash[name] as FarmItem;
         if(!item)
         {
            item = this.parseItemByName(name);
         }
         return item;
      }
      
      public function getFarmItemCodeByName(itemName:String) : String
      {
         var saleCode:String = null;
         var cashCode:String = null;
         var itemCode:String = "";
         var farmItem:FarmItem = this.getFarmItemByName(itemName);
         if(farmItem)
         {
            saleCode = farmItem.saleCode;
            cashCode = farmItem.cashCode;
            if(itemName.indexOf(FarmItem.ITEM_POSTFIX_SALE) >= 0 && saleCode != null)
            {
               itemCode = saleCode;
            }
            else if(itemName.indexOf(FarmItem.ITEM_POSTFIX_CASH) >= 0 && cashCode != null)
            {
               itemCode = cashCode;
            }
            else
            {
               itemCode = farmItem.code;
            }
         }
         return itemCode;
      }
      
      public function getFarmItemNameByCode(itemCode:String) : String
      {
         var itemName:String = "";
         var farmItem:FarmItem = this.getFarmItemByCode(itemCode);
         if(farmItem)
         {
            if(itemCode == farmItem.saleCode)
            {
               itemName = farmItem.saleName;
            }
            else if(itemCode == farmItem.cashCode)
            {
               itemName = farmItem.cashName;
            }
            else
            {
               itemName = farmItem.name;
            }
         }
         return itemName;
      }
      
      public function getTypeHashKey(type:String, subType:String = "all", subSubType:String = "all", worldId:String = "") : String
      {
         return type + (subType == ALL ? "" : subType) + (subSubType == ALL ? "" : subSubType) + worldId;
      }
      
      private function mergeTypeHashArray(typeHash:Object, hashKey:String) : void
      {
         var shouldCollateArray:Boolean = true;
         var splitNumber:Number = 1;
         while(shouldCollateArray && Boolean(splitNumber))
         {
            if(typeHash[hashKey + splitNumber])
            {
               typeHash[hashKey] = (typeHash[hashKey] as Array).concat(typeHash[hashKey + splitNumber]);
               typeHash[hashKey + splitNumber] = null;
               splitNumber++;
            }
            else
            {
               shouldCollateArray = false;
            }
         }
      }
      
      public function getFarmItemsArrayByType(type:String, subType:String = "all", subSubType:String = "all", worldId:String = "", market3Hash:Boolean = false) : Array
      {
         var hashKey:String = null;
         var result:Array = [];
         var typeHashToUse:Object = this.m_typesHash;
         if(market3Hash)
         {
            typeHashToUse = this.m_market3TypesHash;
         }
         var typeHash:Object = typeHashToUse[type];
         if(typeHash)
         {
            hashKey = this.getTypeHashKey(type,subType,subSubType,worldId);
            this.mergeTypeHashArray(typeHash,hashKey);
            if(hashKey == "decoration")
            {
            }
            result = typeHash[hashKey];
            if(!result)
            {
               result = [];
            }
            if(PerformanceExperimentManager.isInBuildtimeConfigExperiment && result.length > 0 && result[0] is String)
            {
               result = typeHash[hashKey] = this.getFarmItemsArrayByNames(result,true);
            }
         }
         return result;
      }
      
      public function getWorldBushelChanceScale(worldId:String) : Number
      {
         var runtimeName:String = null;
         var timeCheck:Boolean = false;
         var nowTime:Number = NaN;
         var runtimeValue:int = 0;
         var currentSeason:int = 0;
         var expansionData:ExpansionData = null;
         var result:Number = 1;
         if(worldId)
         {
            runtimeName = worldId.toUpperCase() + "_" + WORLD_BUSHEL_BOOST;
            timeCheck = true;
            nowTime = GlobalEngine.serverTime;
            runtimeValue = 0;
            if(Boolean(Global.flashHotParams[runtimeName + "_START"]) && nowTime < FarmGameUtil.synchronizedDateTimeToNumber(Global.flashHotParams[runtimeName + "_START"]))
            {
               timeCheck = false;
            }
            else if(Boolean(Global.flashHotParams[runtimeName + "_END"]) && nowTime > FarmGameUtil.synchronizedDateTimeToNumber(Global.flashHotParams[runtimeName + "_END"]))
            {
               timeCheck = false;
            }
            if(Global.flashHotParams[runtimeName])
            {
               runtimeValue = int(Global.flashHotParams[runtimeName]);
            }
            else if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldId) > 1)
            {
               currentSeason = WorldSeasonsManager.getInstance().getCurrentSeason(worldId);
               runtimeName = worldId.toUpperCase() + "_" + currentSeason + "_" + WORLD_BUSHEL_BOOST;
               if(Global.flashHotParams[runtimeName])
               {
                  runtimeValue = int(Global.flashHotParams[runtimeName]);
               }
            }
            if(runtimeValue > 0 && timeCheck)
            {
               result = runtimeValue;
            }
            else
            {
               expansionData = this.getExpansionData(worldId);
               if(expansionData)
               {
                  result = expansionData.bushelChanceScale;
               }
            }
         }
         return result;
      }
      
      public function getExpansionFarmItemsForCurrentWorld() : Array
      {
         return this.getFarmItemsArrayByType("landExpansion","expansion",ALL,Global.worldManager.currentWorldType);
      }
      
      public function generateAvatarClothesMenu(force:Boolean = false) : void
      {
         var startTime:Number = NaN;
         var farmItem:FarmItem = null;
         var name:String = null;
         var basename:String = null;
         var appendname:String = null;
         var avatarItemArray:Array = null;
         var avatarItem:AvatarItem = null;
         var itemXML:XML = null;
         var itemDataSource:XMLDataSource = null;
         if(force || Boolean(Global.player.avatar) && Boolean(this.m_lastGender != Global.player.avatar.gender))
         {
            startTime = getTimer();
            avatarItemArray = Global.avatarConfigSettings.itemList;
            this.m_lastGender = Global.player.avatar.gender;
            delete this.m_typesHash["clothes"];
            delete this.m_market3TypesHash["clothes"];
            for each(avatarItem in avatarItemArray)
            {
               if(avatarItem.isClothesItem())
               {
                  itemXML = avatarItem.toItemXML();
                  name = itemXML.@name;
                  basename = name.replace("_cash","");
                  basename = basename.replace("_sale","");
                  appendname = name.replace(basename,"");
                  farmItem = this.getFarmItemByName(basename);
                  if(farmItem == null)
                  {
                     farmItem = new ClothingItem(itemXML);
                  }
                  this.addFarmItem(farmItem,itemXML,appendname);
               }
            }
            GlobalEngine.info("GameSettings","generateAvatarClothesMenu: " + (GlobalEngine.currentTime - startTime) + "ms");
         }
      }
      
      public function getDefaultSortType() : String
      {
         var result:String = null;
         if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            result = FarmGameSettingsManager.DEFAULT;
         }
         else
         {
            result = FarmGameSettingsManager.WORLD_SORT;
         }
         return result;
      }
      
      public function getItemLicenseByCode(code:String) : ItemLicense
      {
         var list:XMLList = null;
         var itemLicense:ItemLicense = this.m_itemLicenseHash[code];
         if(itemLicense == null)
         {
            list = this.m_rawXml.licenses.itemLicense.(@code == code);
            if(list.length())
            {
               itemLicense = new ItemLicense(list[0]);
               this.m_itemLicenseHash[code] = itemLicense;
            }
         }
         return itemLicense;
      }
      
      public function getLicenseItemsByCode(licenseCode:String) : Array
      {
         var returnArray:Array = null;
         returnArray = this.m_licenseItemHash[licenseCode];
         if(!returnArray)
         {
            returnArray = [];
         }
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment && returnArray.length > 0 && returnArray[0] is String)
         {
            returnArray = this.m_licenseItemHash[licenseCode] = this.getFarmItemsArrayByNames(returnArray,true);
         }
         return returnArray;
      }
      
      private function getMasteryXMLByCode(code:String) : XML
      {
         var returnXML:XML = null;
         var item:FarmItem = null;
         returnXML = null;
         item = this.getFarmItemByCode(code);
         if(item)
         {
            if(item.xml != null)
            {
               returnXML = item.xml;
            }
            else if(item.cashXML != null)
            {
               returnXML = item.cashXML;
            }
            else
            {
               returnXML = item.saleXML;
            }
         }
         return returnXML;
      }
      
      public function getMasteryByCode(code:String) : Mastery
      {
         var masteryXml:XML = null;
         var masteryItem:FarmItem = null;
         var mastery:Mastery = null;
         if(isInDataSourceExperiment())
         {
            masteryItem = this.getFarmItemByCode(code);
         }
         else
         {
            masteryXml = this.getMasteryXMLByCode(code);
         }
         if(Boolean(masteryXml) || Boolean(masteryItem))
         {
            mastery = new Mastery(masteryXml,masteryItem);
         }
         return mastery;
      }
      
      public function updateItemByName(name:String) : void
      {
         this.getFarmItemByName(name).flush();
      }
      
      public function updatePatchTimes(patchTimes:Object) : void
      {
         var itemCode:String = null;
         var patchTime:Number = NaN;
         var seedItem:FarmItem = null;
         for(itemCode in patchTimes)
         {
            patchTime = Number(patchTimes[itemCode]);
            seedItem = this.getFarmItemByCode(itemCode);
            if(seedItem)
            {
               seedItem.patchTime = patchTime * FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
         }
      }
      
      public function getPromoItemData(featureName:String) : Object
      {
         var expansionPromoData:Object = null;
         var expansionPromoDataXML:XMLList = null;
         var item:Object = null;
         var promoData:XML = null;
         expansionPromoData = new Object();
         if(this.m_allExpansionPromoData != null && this.m_allExpansionPromoData.hasOwnProperty(featureName))
         {
            expansionPromoData = this.m_allExpansionPromoData[featureName];
         }
         else
         {
            expansionPromoDataXML = this.m_rawXml.expansionPromotions.expansionPromotion.(@name == featureName).level;
            for each(promoData in expansionPromoDataXML)
            {
               item = new Object();
               item.levelNumber = promoData.@number.toString();
               item.rewardItemCode = promoData.@rewardItemCode.toString();
               item.rewardType = promoData.@rewardType.toString();
               item.postCardIcon = promoData.@postcardIcon.toString();
               if(promoData.hasOwnProperty("@rewardAmount"))
               {
                  item.rewardAmount = promoData.@rewardAmount.toString();
               }
               item.dialogAsset = promoData.@dialogAsset.toString();
               if(!expansionPromoData.hasOwnProperty(item.levelNumber))
               {
                  expansionPromoData[item.levelNumber] = new Object();
               }
               expansionPromoData[item.levelNumber]["rewardItemCode"] = item.rewardItemCode;
               expansionPromoData[item.levelNumber]["postCardIcon"] = item.postCardIcon;
               expansionPromoData[item.levelNumber]["rewardType"] = item.rewardType;
               expansionPromoData[item.levelNumber]["dialogAsset"] = item.dialogAsset;
               expansionPromoData[item.levelNumber]["rewardAmount"] = item.rewardAmount ? item.rewardAmount : 1;
            }
            this.m_allExpansionPromoData[featureName] = new Object();
            this.m_allExpansionPromoData[featureName] = expansionPromoData;
         }
         return expansionPromoData;
      }
      
      public function getIncrementalGateItemByGateCode(gateCodeIn:String) : Object
      {
         var gateItems:XMLList = null;
         var item:Object = null;
         var gateItem:XML = null;
         if(!this.m_incrementalGateItemsArray)
         {
            this.m_incrementalGateItemsArray = new Object();
            gateItems = this.m_rawXml.incrementalGateItems.incrementalGateItem;
            for each(gateItem in gateItems)
            {
               item = new Object();
               item.gateType = gateItem.@gateType.toString();
               item.minValue = Number(gateItem.@minValue.toString());
               item.maxValue = Number(gateItem.@maxValue.toString());
               item.addsRequired = Number(gateItem.@addsRequired.toString());
               this.m_incrementalGateItemsArray[gateItem.@gateCode.toString()] = item;
            }
         }
         return this.m_incrementalGateItemsArray[gateCodeIn];
      }
      
      public function getItemsFromSameLimitGroup(name:String) : Array
      {
         var items:Array = null;
         var xml:XML = null;
         var limitedItems:XMLList = null;
         var listIndex:int = 0;
         var itemGroup:XMLList = null;
         var itemsToLimit:Array = null;
         var foundItem:Boolean = false;
         var itemIdx:int = 0;
         var item:XML = null;
         var itemName:String = null;
         items = new Array();
         xml = this.m_rawXml;
         limitedItems = xml.limitItemOwnership.itemLimit;
         for(listIndex = 0; listIndex < limitedItems.length(); listIndex++)
         {
            itemGroup = limitedItems[listIndex].item;
            itemsToLimit = new Array();
            foundItem = false;
            for(itemIdx = 0; itemIdx < itemGroup.length(); itemIdx++)
            {
               item = itemGroup[itemIdx];
               itemName = item.@name;
               if(itemName == name)
               {
                  foundItem = true;
               }
               else
               {
                  itemsToLimit.push(itemName);
               }
            }
            if(foundItem)
            {
               items = itemsToLimit;
               break;
            }
         }
         return items;
      }
      
      public function checkDateGate(objectXML:XML, serverTime:Number) : Boolean
      {
         var result:Boolean = false;
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         result = true;
         if(Boolean(objectXML.limitedStart) && objectXML.limitedStart.toString() != "")
         {
            startDate = FarmGameUtil.synchronizedDateToNumber(objectXML.limitedStart.toString());
            if(startDate > serverTime)
            {
               result = false;
            }
         }
         if(Boolean(objectXML.limitedEnd) && objectXML.limitedEnd.toString() != "")
         {
            endDate = FarmGameUtil.synchronizedDateToNumber(objectXML.limitedEnd.toString());
            if(endDate < serverTime)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function checkDateGateDS(item:FarmItem, serverTime:Number) : Boolean
      {
         var result:Boolean = false;
         var limitedStartStr:String = null;
         var startDate:Number = NaN;
         var limitedEndStr:String = null;
         var endDate:Number = NaN;
         result = true;
         limitedStartStr = item.getStringFromDataSource("limitedStart");
         if(limitedStartStr)
         {
            startDate = FarmGameUtil.synchronizedDateToNumber(limitedStartStr);
            if(startDate > serverTime)
            {
               result = false;
            }
         }
         if(result)
         {
            limitedEndStr = item.getStringFromDataSource("limitedEnd");
            if(limitedEndStr)
            {
               endDate = FarmGameUtil.synchronizedDateToNumber(limitedEndStr);
               if(endDate < serverTime)
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      public function getRandomAd() : AdItem
      {
         var ads:XMLList = null;
         var result:AdItem = null;
         var rand:int = 0;
         ads = this.m_rawXml.ads;
         result = null;
         if(ads.length())
         {
            rand = Math.round(Math.random() * (ads.ad.length() - 1));
            result = new AdItem(ads.ad[rand]);
         }
         return result;
      }
      
      public function getRandomAdBySN() : AdItem
      {
         var snURL:String = null;
         var sn:int = 0;
         var allAds:XMLList = null;
         var potentialAds:Array = null;
         var ad:XML = null;
         var result:AdItem = null;
         var selectedAdName:String = null;
         var rand:int = 0;
         snURL = String(GlobalEngine.getFlashVar("sn_app_url"));
         sn = 0;
         if(snURL.search("apps.facebook.com") != -1)
         {
            sn = 1;
         }
         allAds = this.m_rawXml.ads.ad;
         potentialAds = new Array();
         for each(ad in allAds)
         {
            if(ad.@sn == sn)
            {
               potentialAds.push(ad);
            }
         }
         result = null;
         var modInt:int = 0;
         if(potentialAds.length > 0)
         {
            rand = Math.floor(Math.random() * potentialAds.length);
            result = new AdItem(potentialAds[rand]);
         }
         return result;
      }
      
      public function getAllPromotionsSettings() : XMLList
      {
         var results:XMLList = null;
         return this.m_rawXml.promotions.promotion;
      }
      
      public function getPromotionSettings(promoName:String) : XML
      {
         var promoList:XMLList = null;
         var results:XML = null;
         promoList = this.m_rawXml.promotions.promotion.(@promoName == promoName);
         results = new XML();
         if(promoList.length() > 0)
         {
            results = promoList[0];
         }
         return results;
      }
      
      public function checkTimeGate(startSetting:Number, endSetting:Number) : Boolean
      {
         var currTime:Number = NaN;
         var result:Boolean = false;
         currTime = GlobalEngine.serverTime;
         result = false;
         if(startSetting < currTime && currTime < endSetting)
         {
            result = true;
         }
         return result;
      }
      
      public function getExpansionData(worldId:String) : ExpansionData
      {
         if(this.m_expansionDataHash == null)
         {
            this.parseExpansionConfig();
         }
         return this.m_expansionDataHash[worldId] as ExpansionData;
      }
      
      public function getDialogUrlBySeason(seasonId:int, worldType:String, accessType:String) : String
      {
         var expansionData:ExpansionData = null;
         expansionData = null;
         if(this.m_expansionDataHash == null)
         {
            expansionData = this.getExpansionData(worldType);
         }
         else
         {
            expansionData = this.m_expansionDataHash[worldType];
         }
         return expansionData.seasons[seasonId].dialog[accessType];
      }
      
      public function getFTUEPathByAccessType(worldType:String, accessType:String) : String
      {
         var expansionData:ExpansionData = null;
         var result:String = null;
         expansionData = null;
         result = null;
         if(this.m_expansionDataHash == null)
         {
            expansionData = this.getExpansionData(worldType);
         }
         else
         {
            expansionData = this.m_expansionDataHash[worldType];
         }
         if(Boolean(expansionData && expansionData.motdAssets) && Boolean(expansionData.motdAssets[accessType] != null) && expansionData.motdAssets[accessType][ExpansionData.KEY_FTUE] != null)
         {
            result = expansionData.motdAssets[accessType][ExpansionData.KEY_FTUE];
         }
         return result;
      }
      
      protected function parseExpansionConfig() : void
      {
         var expansionsList:XMLList = null;
         var expansionData:ExpansionData = null;
         var expansionXML:XML = null;
         this.m_expansionDataHash = new Object();
         expansionsList = this.m_rawXml.expansions.expansion;
         for each(expansionXML in expansionsList)
         {
            try
            {
               expansionData = new ExpansionData(expansionXML);
               this.m_expansionDataHash[expansionData.worldId] = expansionData;
            }
            catch(err:Error)
            {
               ErrorManager.addError("Could not parse expansion data, name = " + expansionXML["@name"]);
            }
         }
      }
      
      public function getEarlyAccessGiftingExpansion() : ExpansionEarlyAccessGiftingData
      {
         var data:ExpansionData = null;
         var result:ExpansionEarlyAccessGiftingData = null;
         var expansion:String = null;
         if(this.m_expansionDataHash == null)
         {
            this.parseExpansionConfig();
         }
         for(expansion in this.m_expansionDataHash)
         {
            data = this.m_expansionDataHash[expansion] as ExpansionData;
            if(data.earlyAccessGifting != null)
            {
               if(PrerequisiteUtility.arePrerequisitesMet(data.earlyAccessGifting.prereqs))
               {
                  result = data.earlyAccessGifting;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getDeprecatorSettings(deprecatorName:String) : DeprecatorSettings
      {
         var deprecators:XMLList = null;
         var deprecatorSettings:DeprecatorSettings = null;
         var deprecator:XML = null;
         if(this.m_deprecatorSettingsHash == null)
         {
            this.m_deprecatorSettingsHash = new Object();
            deprecators = this.m_rawXml.itemDeprecationSettings.item;
            for each(deprecator in deprecators)
            {
               try
               {
                  deprecatorSettings = new DeprecatorSettings(deprecator);
                  this.m_deprecatorSettingsHash[deprecatorSettings.name] = deprecatorSettings;
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Could not parse deprecator settings, name = " + deprecator["@name"]);
               }
            }
         }
         return this.m_deprecatorSettingsHash[deprecatorName] as DeprecatorSettings;
      }
      
      public function getContentAccessSettings(contentAccessName:String) : ContentAccessSettings
      {
         this.initContentAccessSettingsHash();
         return this.m_contentAccessSettingsHash[contentAccessName] as ContentAccessSettings;
      }
      
      public function getAllContentAccessSettingsHash() : Object
      {
         this.initContentAccessSettingsHash();
         return this.m_contentAccessSettingsHash;
      }
      
      private function initContentAccessSettingsHash() : void
      {
         var settings:XMLList = null;
         var newEntry:ContentAccessSettings = null;
         var xmlItem:XML = null;
         if(this.m_contentAccessSettingsHash == null)
         {
            this.m_contentAccessSettingsHash = new Array();
            settings = this.m_rawXml.contentAccessSettings.contentAccess;
            for each(xmlItem in settings)
            {
               try
               {
                  newEntry = new ContentAccessSettings(xmlItem);
                  this.m_contentAccessSettingsHash[newEntry.name] = newEntry;
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Could not parse content access settings, name = " + xmlItem["@name"] + " msg: " + err.message);
               }
            }
         }
      }
      
      public function getCurrencyData(currencyName:String) : CurrencyData
      {
         var currencyList:XMLList = null;
         var currencyData:CurrencyData = null;
         var currencyXML:XML = null;
         if(this.m_worldCurrencyHash == null)
         {
            this.m_worldCurrencyHash = new Object();
            currencyList = this.m_rawXml.currencies.currency;
            for each(currencyXML in currencyList)
            {
               try
               {
                  currencyData = new CurrencyData(currencyXML);
                  this.m_worldCurrencyHash[currencyData.name] = currencyData;
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Could not parse currency data, name = " + currencyXML["@name"]);
               }
            }
         }
         return this.m_worldCurrencyHash[currencyName] as CurrencyData;
      }
      
      public function getMiniGameData(minigameName:String) : MinigameData
      {
         var minigameList:XMLList = null;
         var minigameData:MinigameData = null;
         var minigameXML:XML = null;
         if(this.m_minigameHash == null)
         {
            this.m_minigameHash = new Dictionary();
            minigameList = this.m_rawXml.minigameSettings.minigame;
            for each(minigameXML in minigameList)
            {
               try
               {
                  minigameData = new MinigameData(minigameXML);
                  this.m_minigameHash[minigameData.name] = minigameData;
               }
               catch(e:Error)
               {
                  ErrorManager.addError("Could not parse minigame data, name = " + minigameXML["@name"] + ". " + e.toString());
               }
            }
         }
         return this.m_minigameHash[minigameName] as MinigameData;
      }
      
      public function getUGCItemDefinition(itemName:String) : UGCItemDefinition
      {
         var result:UGCItemDefinition = null;
         var ugcItemsList:XMLList = null;
         var ugcItemDefinition:UGCItemDefinition = null;
         var ugcItemXML:XML = null;
         if(this.m_ugcItemDefinitionHash == null)
         {
            this.m_ugcItemDefinitionHash = new Object();
            ugcItemsList = this.m_rawXml.ugcItems.ugcItem;
            for each(ugcItemXML in ugcItemsList)
            {
               try
               {
                  ugcItemDefinition = new UGCItemDefinition(ugcItemXML);
                  this.m_ugcItemDefinitionHash[ugcItemDefinition.itemName] = ugcItemDefinition;
               }
               catch(err:Error)
               {
                  GlobalEngine.error("UGC","Error parsing ugcItemXML[" + ugcItemXML["@itemName"] + "], cause: " + err.message + "\n" + err.getStackTrace());
                  ErrorManager.addError("Could not parse ugcItem definition, name=" + ugcItemXML["@itemName"]);
               }
            }
         }
         result = null;
         if(this.m_ugcItemDefinitionHash[itemName])
         {
            result = this.m_ugcItemDefinitionHash[itemName] as UGCItemDefinition;
         }
         return result;
      }
      
      public function getDragonBreedingData(featureName:String) : XML
      {
         var result:XML = null;
         var xmlConfig:XMLList = null;
         var featureConfig:XML = null;
         xmlConfig = this.m_rawXml.dragonbreeding.feature;
         if(xmlConfig)
         {
            for each(featureConfig in xmlConfig)
            {
               if(featureConfig.hasOwnProperty("@name"))
               {
                  if(featureName == featureConfig["@name"])
                  {
                     result = featureConfig[0];
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getJMInnovationRewardData(featureName:String) : XML
      {
         var result:XML = null;
         var xmlConfig:XMLList = null;
         var featureConfig:XML = null;
         xmlConfig = this.m_rawXml.JMInnovationRewardTable.feature;
         if(xmlConfig)
         {
            for each(featureConfig in xmlConfig)
            {
               if(featureConfig.hasOwnProperty("@name"))
               {
                  if(featureName == featureConfig["@name"])
                  {
                     result = featureConfig[0];
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getRegionAchievementData(featureName:String) : XML
      {
         var result:XML = null;
         var xmlConfig:XMLList = null;
         var featureConfig:XML = null;
         xmlConfig = this.m_rawXml.regionAchievements.regionAchievement;
         if(xmlConfig)
         {
            for each(featureConfig in xmlConfig)
            {
               if(featureConfig.hasOwnProperty("@name"))
               {
                  if(featureName == featureConfig["@name"])
                  {
                     result = featureConfig[0];
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getUITemplatizationData(worldId:String) : XML
      {
         var result:XML = null;
         var xmlConfig:XMLList = null;
         var featureConfig:XML = null;
         xmlConfig = this.m_rawXml.templateDataTable.templateData;
         if(xmlConfig)
         {
            for each(featureConfig in xmlConfig)
            {
               if(featureConfig.hasOwnProperty("@name"))
               {
                  if(worldId == featureConfig["@name"])
                  {
                     result = featureConfig[0];
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getFarmExpansionData(worldName:String) : Dictionary
      {
         var result:Dictionary = null;
         var list:XMLList = null;
         var worldFarmExpansionXml:XML = null;
         var configName:String = null;
         var farmExpansionDataList:XMLList = null;
         var child:XML = null;
         var addedItems:Object = null;
         var addedItemsNode:XML = null;
         var squaresKey:String = null;
         var addedItemNode:XML = null;
         var addedItem:Object = null;
         result = new Dictionary();
         list = this.m_rawXml.farmExpansions.world;
         for each(worldFarmExpansionXml in list)
         {
            if(worldFarmExpansionXml.hasOwnProperty("@name"))
            {
               configName = worldFarmExpansionXml["@name"];
               if(configName == worldName)
               {
                  farmExpansionDataList = worldFarmExpansionXml.children();
                  for each(child in farmExpansionDataList)
                  {
                     if(child.name() == "farmExpansionAddedItems")
                     {
                        addedItems = new Object();
                        for each(addedItemsNode in child..addedItems)
                        {
                           if(addedItemsNode.hasOwnProperty("@squares"))
                           {
                              squaresKey = addedItemsNode["@squares"];
                              addedItems[squaresKey] = new Array();
                              for each(addedItemNode in addedItemsNode.addedItem)
                              {
                                 addedItem = new Object();
                                 addedItem["code"] = String(addedItemNode["@code"]);
                                 addedItem["state"] = String(addedItemNode["@state"]);
                                 addedItem["position"] = {
                                    "x":parseInt(addedItemNode["@x"]),
                                    "y":parseInt(addedItemNode["@y"]),
                                    "z":parseInt(addedItemNode["@z"])
                                 };
                                 addedItems[squaresKey].push(addedItem);
                              }
                           }
                        }
                        result[child.name()] = addedItems;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getFarmExpansionAddedItemsForWorldAndSize(worldName:String, farmSquareSize:int) : Array
      {
         var addedItems:Array = null;
         var list:XMLList = null;
         var worldFarmExpansionXml:XML = null;
         var configName:String = null;
         var farmExpansionDataList:XMLList = null;
         var child:XML = null;
         var addedItemsNode:XML = null;
         var squaresKey:int = 0;
         var addedItemNode:XML = null;
         var addedItem:Object = null;
         addedItems = new Array();
         list = this.m_rawXml.farmExpansions.world;
         for each(worldFarmExpansionXml in list)
         {
            if(worldFarmExpansionXml.hasOwnProperty("@name"))
            {
               configName = worldFarmExpansionXml["@name"];
               if(configName == worldName)
               {
                  farmExpansionDataList = worldFarmExpansionXml.children();
                  for each(child in farmExpansionDataList)
                  {
                     if(child.name() == "farmExpansionAddedItems")
                     {
                        for each(addedItemsNode in child..addedItems)
                        {
                           if(addedItemsNode.hasOwnProperty("@squares"))
                           {
                              squaresKey = parseInt(addedItemsNode["@squares"]);
                              if(farmSquareSize == squaresKey)
                              {
                                 for each(addedItemNode in addedItemsNode.addedItem)
                                 {
                                    addedItem = new Object();
                                    addedItem["code"] = String(addedItemNode["@code"]);
                                    addedItem["state"] = String(addedItemNode["@state"]);
                                    addedItem["position"] = {
                                       "x":parseInt(addedItemNode["@x"]),
                                       "y":parseInt(addedItemNode["@y"]),
                                       "z":parseInt(addedItemNode["@z"])
                                    };
                                    addedItems.push(addedItem);
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return addedItems;
      }
      
      public function getOverlayByName(itemName:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.objectOverlay.overlay.(@name == itemName);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function isAltGraphicAvailable(name:String) : Boolean
      {
         var list:XMLList = null;
         var result:Boolean = false;
         var xml:XML = null;
         list = this.m_rawXml.objectOverlay.altGraphic.(@name == name);
         result = true;
         if(list.length())
         {
            xml = list[0];
            if(String(xml.limitedStart) != "" || String(xml.limitedEnd) != "")
            {
               result = this.checkDateGate(xml,GlobalEngine.serverTime);
            }
            if(Boolean(xml.visiting) && String(xml.visiting) == "true")
            {
               result &&= Global.worldManager.isVisiting();
            }
         }
         return result;
      }
      
      public function getAltGraphicByName(graphicName:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.objectOverlay.altGraphic.(@name == graphicName);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getCurrentAltGraphic() : String
      {
         var list:XMLList = null;
         var result:String = null;
         var altGraphic:XML = null;
         list = this.m_rawXml.objectOverlay.altGraphic;
         result = "";
         if(list.length())
         {
            for each(altGraphic in list)
            {
               if(this.isAltGraphicAvailable(altGraphic.@name))
               {
                  result = altGraphic.@name;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getCurrentAltGraphics() : Array
      {
         var list:XMLList = null;
         var result:Array = null;
         var altGraphic:XML = null;
         list = this.m_rawXml.objectOverlay.altGraphic;
         result = [];
         if(list.length())
         {
            for each(altGraphic in list)
            {
               if(this.isAltGraphicAvailable(altGraphic.@name))
               {
                  result.push(altGraphic.@name);
               }
            }
         }
         return result;
      }
      
      public function getUpgradedFriendlyName(friendlyName:String, equipmentLevel:int, itemCode:String) : String
      {
         var upgradefriendlyName:String = null;
         var result:int = 0;
         var level:Object = null;
         var index:int = 0;
         var pkg:String = null;
         var key:String = null;
         upgradefriendlyName = friendlyName;
         if(equipmentLevel > 0)
         {
            result = 0;
            level = EquipmentSettingsManager.getInstance().getLevelById(equipmentLevel,itemCode);
            if(Boolean(level) && Boolean(level.titlePrefix))
            {
               index = friendlyName.indexOf(":");
               if(0 < index)
               {
                  pkg = friendlyName.substr(0,index);
                  key = level.titlePrefix + friendlyName.substr(index + 1,friendlyName.length);
                  upgradefriendlyName = pkg + ":" + key;
               }
            }
         }
         return upgradefriendlyName;
      }
      
      public function getRawEquipmentDataXml() : XMLList
      {
         return this.m_rawXml.equipmentData;
      }
      
      public function getCurrentMarketIndicatorConfig() : Object
      {
         var result:Object = null;
         var indicatorXmlList:XMLList = null;
         var indicatorXml:XML = null;
         result = null;
         if(this.m_rawXml.marketIndicator)
         {
            indicatorXmlList = this.m_rawXml.marketIndicator;
            if(indicatorXmlList.length() > 0)
            {
               indicatorXml = indicatorXmlList[0];
               result = new Object();
               result.statsName = indicatorXml["@statsName"].toString();
               result.experiment = indicatorXml["@experiment"].toString();
               result.variant = indicatorXml["@variant"].toString();
               result.limitedStart = indicatorXml.limitedStart.toString();
               result.limitedEnd = indicatorXml.limitedEnd.toString();
               result.icon = indicatorXml.icon.toString();
               result.marketCategory = indicatorXml.marketCategory.toString();
               result.marketSubcategory = indicatorXml.marketSubcategory.toString();
            }
         }
         return result;
      }
      
      public function getPetDataXml() : XMLList
      {
         return this.m_rawXml.petData;
      }
      
      public function getLevelXML(level:Number) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.levels.level.(@num == level);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getXPForLevel(level:Number) : Number
      {
         var result:Number = NaN;
         var levelXML:XML = null;
         var higherLevelXp:Number = NaN;
         var higherLevelStep:Number = NaN;
         var higherLevelBegin:Number = NaN;
         var overLevels:Number = NaN;
         result = 0;
         levelXML = this.getLevelXML(level);
         if(levelXML)
         {
            result = Number(levelXML.@requiredXP);
         }
         else
         {
            higherLevelXp = Global.farmGameSettingsManager.getNumber("higherLevelXp",1500000);
            higherLevelStep = Global.farmGameSettingsManager.getNumber("higherLevelStep",100000);
            higherLevelBegin = Global.farmGameSettingsManager.getNumber("higherLevelBegin",101);
            if(level >= higherLevelBegin)
            {
               overLevels = level - higherLevelBegin;
               result = higherLevelXp + overLevels * higherLevelStep;
            }
         }
         return result;
      }
      
      public function getLevelForXP(xp:Number) : Number
      {
         var result:Number = NaN;
         var levels:XMLList = null;
         var higherLevelXp:Number = NaN;
         var higherLevelStep:Number = NaN;
         var higherLevelBegin:Number = NaN;
         var delta:Number = NaN;
         var bonusLevels:Number = NaN;
         var foundLevel:Boolean = false;
         var levelIdx:Number = NaN;
         var level:XML = null;
         result = 1;
         levels = this.m_rawXml.levels.level;
         higherLevelXp = Global.farmGameSettingsManager.getNumber("higherLevelXp",1500000);
         higherLevelStep = Global.farmGameSettingsManager.getNumber("higherLevelStep",100000);
         higherLevelBegin = Global.farmGameSettingsManager.getNumber("higherLevelBegin",101);
         if(xp >= higherLevelXp)
         {
            if(xp < higherLevelXp + higherLevelStep)
            {
               result = higherLevelBegin;
            }
            else
            {
               delta = xp - higherLevelXp;
               bonusLevels = Math.floor(delta / higherLevelStep);
               result = higherLevelBegin + bonusLevels;
            }
         }
         else
         {
            foundLevel = false;
            for(levelIdx = 0; levelIdx < levels.length(); levelIdx++)
            {
               level = levels[levelIdx];
               if(xp >= level.@requiredXP)
               {
                  result = levelIdx + 1;
                  foundLevel = true;
               }
            }
            if(foundLevel == false)
            {
               result = levels.length();
            }
         }
         return result;
      }
      
      public function getLevelUpCashRewardLevelCap() : int
      {
         var levelCap:int = 0;
         levelCap = Global.farmGameSettingsManager.getNumber("highestLevel",100);
         return int(Global.farmGameSettingsManager.getNumber("highestLevelForFCReward",250));
      }
      
      public function getLevelProgressForXP(xp:Number) : Number
      {
         var result:Number = NaN;
         var currentLevel:Number = NaN;
         var currentLevelXP:Number = NaN;
         var nextLevelXP:Number = NaN;
         result = 0;
         currentLevel = this.getLevelForXP(xp);
         currentLevelXP = this.getXPForLevel(currentLevel);
         nextLevelXP = this.getXPForLevel(currentLevel + 1);
         return (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
      }
      
      private function getAchievementXMLByCode(code:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.achievements.achievement.(@code == code);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getAchievementByCode(code:String) : Achievement
      {
         var achievement:Achievement = null;
         return new Achievement(this.getAchievementXMLByCode(code));
      }
      
      public function getFriendSetXMLByCode(code:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.friendSets.feature.(@code == code);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getFriendSetGoalByCode(code:String) : FriendSetGoal
      {
         var friendSet:FriendSetGoal = null;
         return new FriendSetGoal(this.getFriendSetXMLByCode(code));
      }
      
      public function getActiveFriendSets() : Array
      {
         var result:Array = null;
         var list:XMLList = null;
         var idx:int = 0;
         var feature:XML = null;
         var code:String = null;
         var startDate:String = null;
         var endDate:String = null;
         result = new Array();
         list = this.m_rawXml.friendSets.feature;
         for(idx = 0; idx < list.length(); idx++)
         {
            feature = list[idx];
            if(feature)
            {
               code = feature[XMLKeys.ATTR_CODE];
               if(code)
               {
                  startDate = feature["listStartDate"];
                  endDate = feature["listEndDate"];
                  if(FarmGameUtil.isTimeWithinDateRange(startDate,endDate,GlobalEngine.serverTime))
                  {
                     result.push(code);
                  }
               }
            }
         }
         return result;
      }
      
      public function getImageByName(itemName:String, imageName:String, asAbsoluteUrl:Boolean = true) : String
      {
         return this.getFarmItemByName(itemName).getImageByName(imageName,asAbsoluteUrl);
      }
      
      public function getImageByNameAndItemCode(itemCode:String, imageName:String) : String
      {
         var result:String = null;
         var farmItem:FarmItem = null;
         var item:XML = null;
         var images:XMLList = null;
         result = null;
         if(isInDataSourceExperiment())
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(farmItem)
            {
               result = farmItem.getImageByName(imageName);
            }
         }
         else
         {
            item = Global.farmGameSettingsManager.getItemXMLByCode(itemCode);
            if(item)
            {
               images = item.image.(@name == imageName);
               if(images.length())
               {
                  result = Global.getAssetURL(images[0].@url);
               }
            }
         }
         return result;
      }
      
      public function getItemCodeFromInventoryKey(inventoryKey:String, extraData:Array = null) : String
      {
         var itemCode:String = null;
         var tempArray:Array = null;
         itemCode = inventoryKey;
         if(itemCode.search(":") > 0)
         {
            if(!extraData)
            {
               extraData = new Array();
            }
            tempArray = itemCode.split(":");
            extraData.push(tempArray[0]);
            extraData.push(tempArray[1]);
            itemCode = extraData[0];
         }
         return itemCode;
      }
      
      public function findCurrentMysteryGame() : FarmItem
      {
         var returnItem:FarmItem = null;
         var items:Array = null;
         var item:FarmItem = null;
         returnItem = null;
         items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_GAME_TOKEN);
         if(Boolean(items) && items.length > 0)
         {
            for each(item in items)
            {
               if(item.isMysteryItem && item.checkDateGate())
               {
                  returnItem = item;
                  break;
               }
            }
         }
         return returnItem;
      }
      
      public function getActiveVipItems() : Array
      {
         var result:Array = null;
         var subtypeArray:Array = null;
         var item:FarmItem = null;
         result = new Array();
         var count:int = 0;
         subtypeArray = this.getFarmItemsArray(TYPE_VIP);
         if(subtypeArray)
         {
            for each(item in subtypeArray)
            {
               if(item.isInExperiment && item.checkDateGate())
               {
                  result.push(item);
                  if(++count > 2)
                  {
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getActivePigoGameItem() : FarmItem
      {
         var result:FarmItem = null;
         var subtypeArray:Array = null;
         var item:FarmItem = null;
         subtypeArray = this.getFarmItemsArrayByType("decoration","decor_misc");
         if(subtypeArray)
         {
            for each(item in subtypeArray)
            {
               if(item.isGameToken && item.promoMode == CPigoGameToken.PROMO_MODE && item.isInExperiment && item.checkDateGate())
               {
                  result = item;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getNewLevelItems(newLevel:int, giftableItems:Array, buyableItems:Array, type:String = null) : void
      {
         var subtypeArray:Array = null;
         var farmItem:FarmItem = null;
         var buyableTitle:String = null;
         var limitedTitle:String = null;
         if(type)
         {
            subtypeArray = this.getFarmItemsArrayByType(type);
         }
         else
         {
            this.parseItemsBatch(true,["getNewLevelItems"]);
            subtypeArray = this.m_allItemsArray;
         }
         for each(farmItem in subtypeArray)
         {
            if(farmItem.requiredLevel == newLevel)
            {
               if(farmItem.buyable && farmItem.limitedEndDate != null)
               {
                  buyableTitle = farmItem.friendlyTitle;
                  if(buyableItems.indexOf(buyableTitle) == -1)
                  {
                     buyableItems.push(buyableTitle);
                  }
               }
            }
            if(farmItem.giftable)
            {
               if(Boolean(farmItem.limitedGiftStart) || Boolean(farmItem.limitedGiftEnd))
               {
                  limitedTitle = farmItem.friendlyTitle;
                  if(giftableItems.indexOf(limitedTitle) == -1)
                  {
                     giftableItems.push(limitedTitle);
                  }
               }
            }
         }
      }
      
      public function checkDateGateLicense(licenseXML:XML, serverTime:Number) : Boolean
      {
         var result:Boolean = false;
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         result = true;
         if(Boolean(licenseXML.startDate) && licenseXML.startDate.toString() != "")
         {
            startDate = FarmGameUtil.synchronizedDateToNumber(licenseXML.startDate.toString());
            if(serverTime < startDate)
            {
               result = false;
            }
         }
         if(Boolean(licenseXML.endDate) && licenseXML.endDate.toString() != "")
         {
            endDate = FarmGameUtil.synchronizedDateToNumber(licenseXML.endDate.toString());
            if(serverTime > endDate)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function getWindowThemeXMLByCode(themeCode:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.windowThemes.windowTheme.(@code == themeCode);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getGameMessage(version:Number) : Object
      {
         var message:Object = null;
         var serverTime:Number = NaN;
         var item:XML = null;
         message = null;
         serverTime = GlobalEngine.getTimer();
         for each(item in this.m_rawXml.gameMessages.message)
         {
            if(this.checkDateGate(item,serverTime))
            {
               item["version"] = item["@version"];
               message = item;
               break;
            }
         }
         return message;
      }
      
      public function getGiftboxSettings() : Array
      {
         var giftboxSettings:Array = null;
         var setting:XML = null;
         giftboxSettings = new Array();
         for each(setting in this.m_rawXml.giftboxSettings.group)
         {
            giftboxSettings.push({
               "groupBy":setting["@groupBy"],
               "value":setting["@value"]
            });
         }
         return giftboxSettings;
      }
      
      public function getItemXMLByName(itemName:String) : XML
      {
         var farmItem:FarmItem = null;
         var itemXML:XML = null;
         farmItem = this.getFarmItemByName(itemName);
         itemXML = null;
         if(farmItem)
         {
            itemXML = farmItem.xml ? farmItem.xml : (farmItem.cashXML ? farmItem.cashXML : farmItem.saleXML);
         }
         return itemXML;
      }
      
      public function getItemXMLByCode(itemCode:String) : XML
      {
         var farmItem:FarmItem = null;
         var itemXML:XML = null;
         farmItem = this.getFarmItemByCode(itemCode);
         itemXML = null;
         if(farmItem)
         {
            itemXML = farmItem.xml ? farmItem.xml : (farmItem.cashXML ? farmItem.cashXML : farmItem.saleXML);
         }
         return itemXML;
      }
      
      public function getCraftingConfig() : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.crafting;
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getItemsByClassArray(className:String) : Array
      {
         var result:Array = null;
         result = this.m_classNameHash[className];
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment)
         {
            if(result.length > 0 && result[0] is String)
            {
               result = this.m_classNameHash[className] = this.getFarmItemsArrayByNames(result,true);
            }
         }
         else if(!this.m_itemsXMLParsingComplete)
         {
            this.parseItemsBatch(true,["getItemsByClassArray",className]);
            result = this.m_classNameHash[className];
         }
         return result;
      }
      
      public function getItemsByAoeTargetKeyword(keyword:String) : Array
      {
         var result:Array = null;
         result = this.m_aoeTargetKeywordHash[keyword];
         if(PerformanceExperimentManager.isInBuildtimeConfigExperiment && result.length > 0 && result[0] is String)
         {
            result = this.m_aoeTargetKeywordHash[keyword] = this.getFarmItemsArrayByNames(result,true);
         }
         return result;
      }
      
      public function getLicenseXML(code:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         list = this.m_rawXml.licenses.itemLicense.(@code == code);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getPromotionItemCodesBySponsor(sponsor:String) : Array
      {
         var promotionItems:Array = null;
         var sponsorDataXml:XMLList = null;
         var code:XML = null;
         promotionItems = [];
         sponsorDataXml = this.m_rawXml.sponsors.sponsor.(@name == sponsor).code;
         for each(code in sponsorDataXml)
         {
            promotionItems.push(code.@id.toString());
         }
         return promotionItems;
      }
      
      public function getItemFlagAction(flag:String) : String
      {
         var result:String = null;
         var itemFlags:XMLList = null;
         result = "";
         itemFlags = this.m_rawXml.itemFlags.itemFlag.(@name == flag);
         if(itemFlags.length())
         {
            result = String(itemFlags[0].@handler);
         }
         return result;
      }
      
      public function getW2WRolloverSeconds(featureName:String) : Number
      {
         var result:Number = NaN;
         var list:XMLList = null;
         result = 0;
         list = this.m_rawXml.w2wFeatures.w2wFeature.(@name == featureName);
         if(list.length())
         {
            result = Number((list[0] as XML).attribute("rolloverSeconds"));
         }
         return result;
      }
      
      public function getW2WMissPercentage(featureName:String) : Number
      {
         var result:Number = NaN;
         var list:XMLList = null;
         result = 0;
         list = this.m_rawXml.w2wFeatures.w2wFeature.(@name == featureName);
         if(list.length())
         {
            result = Number((list[0] as XML).attribute("missPercentage"));
         }
         return result;
      }
      
      public function getMusicByWorldType(worldId:String) : Array
      {
         var result:Array = null;
         var backgroundMusicSet:XMLList = null;
         var musicSet:XML = null;
         var music:XML = null;
         result = null;
         backgroundMusicSet = this.m_rawXml.backgroundMusic.musicSet;
         if(backgroundMusicSet.length() > 0)
         {
            for each(musicSet in backgroundMusicSet)
            {
               if(musicSet.@location.toString() == worldId)
               {
                  result = new Array();
                  for each(music in musicSet.music)
                  {
                     result.push(music.@url.toString());
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public function getAmbientMusicByWorldType(worldId:String) : String
      {
         var result:String = null;
         var ambientMusic:XMLList = null;
         var music:XML = null;
         result = null;
         ambientMusic = this.m_rawXml.ambientMusic;
         if(ambientMusic.music.length() > 0)
         {
            for each(music in ambientMusic.music)
            {
               if(music.@location.toString() == worldId)
               {
                  result = music.@url.toString();
                  break;
               }
            }
         }
         if(!result)
         {
            if(ambientMusic.hasOwnProperty("@defaultUrl"))
            {
               result = ambientMusic.@defaultUrl.toString();
            }
         }
         return result;
      }
      
      public function getFeatureXML(featureKey:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var i:Number = NaN;
         var node:XML = null;
         list = this.m_rawXml.featureConfig.feature;
         result = null;
         for(i = 0; i < list.length(); i++)
         {
            if(list[i].@name == featureKey)
            {
               node = list[i];
               if(FeatureConfigManager.featureConfigMatchesCurrentUser(node))
               {
                  result = node;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getFeatureXMLByName(featureMasterKey:String, featureKey:String, featureName:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var i:Number = NaN;
         var node:XML = null;
         var giveaways:XMLList = null;
         var giveawayData:XML = null;
         list = this.m_rawXml.featureConfig.feature;
         result = null;
         for(i = 0; i < list.length(); i++)
         {
            if(list[i].@name == featureMasterKey)
            {
               node = list[i];
               giveaways = null;
               if(Boolean(node) && node.hasOwnProperty(featureKey))
               {
                  giveaways = node[featureKey];
               }
               if(giveaways)
               {
                  for each(giveawayData in giveaways)
                  {
                     if(Boolean(giveawayData.attribute("name").toString()) && giveawayData.attribute("name").toString() == featureName)
                     {
                        return giveawayData;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getFeatureXMLWithType(featureKey:String, featureType:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var listLength:int = 0;
         var i:int = 0;
         var node:XML = null;
         list = this.m_rawXml.featureConfig.feature;
         result = null;
         if(list != null)
         {
            listLength = list.length();
            for(i = 0; i < listLength; i++)
            {
               node = list[i];
               if(Boolean(node.@name == featureKey) && Boolean(node.hasOwnProperty("@type")) && node.@type == featureType)
               {
                  if(FeatureConfigManager.featureConfigMatchesCurrentUser(node))
                  {
                     result = node;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getFeatureNamesByType(featureType:String) : Array
      {
         var list:XMLList = null;
         var result:Array = null;
         var i:Number = NaN;
         var node:XML = null;
         list = this.m_rawXml.featureConfig.feature;
         result = new Array();
         for(i = 0; i < list.length(); i++)
         {
            if(list[i].attribute("type") == featureType)
            {
               node = list[i];
               if(FeatureConfigManager.featureConfigMatchesCurrentUser(node))
               {
                  result.push(list[i].attribute("name").toString());
               }
            }
         }
         return result;
      }
      
      public function getAllFeatureXMLMaterials() : XMLList
      {
         return this.m_rawXml.featureConfig.feature.materials.material;
      }
      
      public function getWeeklyWeatherXML() : XMLList
      {
         var result:XMLList = null;
         result = null;
         return this.m_rawXml.weeklyWeather.weekDay;
      }
      
      public function getWeatherTypeAssetURL(type:String) : String
      {
         var result:String = null;
         var list:XMLList = null;
         var i:Number = NaN;
         result = "";
         list = this.m_rawXml.weeklyWeather.weatherConfig;
         for(i = 0; i < list.length(); i++)
         {
            if(list[i].@name.toString() == type)
            {
               result = list[i].assetUrl.toString();
            }
         }
         return result;
      }
      
      public function get friendlyNameArray() : Array
      {
         var farmItem:FarmItem = null;
         this.parseItemsBatch(true,["friendlyNameArray"]);
         if(this.m_friendlyNameArray == null)
         {
            this.m_friendlyNameArray = [];
            for each(farmItem in this.m_allItemsArray)
            {
               farmItem.flush();
               if(farmItem.buyableWithoutDateCheck)
               {
                  this.m_friendlyNameArray.push([farmItem,farmItem.friendlyTitle.toLocaleLowerCase()]);
               }
            }
         }
         return this.m_friendlyNameArray;
      }
      
      public function clearFriendlyNameArray() : void
      {
         this.m_friendlyNameArray = null;
      }
      
      public function getIntegratedCrossGameData(gameID:String, action:String) : Array
      {
         var list:XMLList = null;
         var result:Array = null;
         var itemXML:XML = null;
         var item:Object = null;
         list = this.m_rawXml.integratedCrossGameGifting.targetGame.(@id == gameID).action.(@name == action).gift;
         result = new Array();
         for each(itemXML in list)
         {
            item = new Object();
            item["name"] = itemXML.@name.toString();
            item["icon"] = itemXML.@icon.toString();
            item["requiredLevel"] = itemXML.@requiredLevel.toString();
            result.push(item);
         }
         return result;
      }
      
      public function getInGameItemByGameID(gameID:String) : String
      {
         var result:String = null;
         var list:XMLList = null;
         var gameXML:XML = null;
         result = "";
         list = this.m_rawXml.integratedCrossGameGifting.targetGame;
         for each(gameXML in list)
         {
            if(gameXML.@id == gameID)
            {
               result = gameXML.@inGameItem;
               break;
            }
         }
         return result;
      }
      
      public function getGameIDByItemName(itemName:String) : String
      {
         var result:String = null;
         var list:XMLList = null;
         var gameXML:XML = null;
         result = "";
         list = this.m_rawXml.integratedCrossGameGifting.targetGame;
         for each(gameXML in list)
         {
            if(gameXML.@inGameItem == itemName)
            {
               result = gameXML.@id;
               break;
            }
         }
         return result;
      }
      
      private function parseFarmVillageXml() : void
      {
         var ingredientsList:XMLList = null;
         var ingredientHash:Array = null;
         var ingredientObject:Object = null;
         var ingredientXML:XML = null;
         this.m_farmVillageHash = new Object();
         ingredientsList = null;
         if(Boolean(this.m_rawXml) && Boolean(this.m_rawXml.farmVillage) && Boolean(this.m_rawXml.farmVillage.ingredients) && Boolean(this.m_rawXml.farmVillage.ingredients.ingredient))
         {
            ingredientsList = this.m_rawXml.farmVillage.ingredients.ingredient;
            ingredientHash = new Array();
            ingredientObject = new Object();
            for each(ingredientXML in ingredientsList)
            {
               ingredientObject = new Object();
               ingredientObject.buildingName = String(ingredientXML.@building);
               ingredientObject.name = String(ingredientXML.@name);
               ingredientHash.push(ingredientObject);
            }
            this.m_farmVillageHash[FarmVillageManager.INGREDIENTS_KEY] = ingredientHash;
         }
      }
      
      public function getFarmVillageIngredientsMapping() : Array
      {
         if(this.m_farmVillageHash == null)
         {
            this.parseFarmVillageXml();
         }
         return this.m_farmVillageHash[FarmVillageManager.INGREDIENTS_KEY];
      }
      
      private function parseFactoriesXml() : void
      {
         var factoriesList:XMLList = null;
         var factoryHash:Object = null;
         var factory:FactoryItem = null;
         var factoryName:String = null;
         var factoryCostPerHarvest:int = 0;
         var levelXMLList:XMLList = null;
         var levelsArray:Array = null;
         var level:FactoryItemLevel = null;
         var levelId:int = 0;
         var levelRewards:Vector.<Object> = null;
         var levelHarvestTime:int = 0;
         var levelRushPrice:Number = NaN;
         var levelHarvestToNextLevel:int = 0;
         var levelInstantLevelCostPerHarvest:int = 0;
         var factoryXml:XML = null;
         var levelXml:XML = null;
         this.m_factoriesHash = new Object();
         factoriesList = null;
         if(Boolean(this.m_rawXml) && Boolean(this.m_rawXml.factories) && Boolean(this.m_rawXml.factories.factory))
         {
            factoriesList = this.m_rawXml.factories.factory;
            factoryHash = new Object();
            factory = null;
            factoryName = "";
            factoryCostPerHarvest = 0;
            levelsArray = null;
            level = null;
            levelId = 0;
            levelRewards = null;
            levelHarvestTime = 0;
            levelRushPrice = 0;
            levelHarvestToNextLevel = -1;
            levelInstantLevelCostPerHarvest = -1;
            for each(factoryXml in factoriesList)
            {
               factoryName = String(factoryXml.@name);
               factoryCostPerHarvest = int(factoryXml.costPerHarvest);
               if(Boolean(factoryXml.levels) && Boolean(factoryXml.levels.level))
               {
                  levelXMLList = factoryXml.levels.level;
                  levelsArray = new Array();
                  for each(levelXml in levelXMLList)
                  {
                     levelId = int(levelXml.@id);
                     levelRewards = UserRewardUtil.getRewardsVectorFromXml(levelXml.rewards[0]);
                     levelHarvestTime = int(levelXml.harvestTime);
                     levelRushPrice = Number(levelXml.rushPrice);
                     if(levelXml.harvestToNextLevel)
                     {
                        levelHarvestToNextLevel = int(levelXml.harvestToNextLevel);
                     }
                     else
                     {
                        levelHarvestToNextLevel = -1;
                     }
                     if(levelXml.instantLevelCostPerHarvest)
                     {
                        levelInstantLevelCostPerHarvest = int(levelXml.instantLevelCostPerHarvest);
                     }
                     else
                     {
                        levelInstantLevelCostPerHarvest = -1;
                     }
                     level = new FactoryItemLevel(levelId,levelRewards,levelHarvestTime,levelRushPrice,levelHarvestToNextLevel,levelInstantLevelCostPerHarvest);
                     levelsArray.push(level);
                  }
                  factory = new FactoryItem(factoryName,factoryCostPerHarvest,levelsArray);
                  factoryHash[factoryName] = factory;
               }
            }
            this.m_factoriesHash = factoryHash;
         }
      }
      
      public function getFactoryConfigByName(name:String) : FactoryItem
      {
         var result:FactoryItem = null;
         result = null;
         if(this.m_factoriesHash == null)
         {
            this.parseFactoriesXml();
         }
         if(this.m_factoriesHash.hasOwnProperty(name))
         {
            result = this.m_factoriesHash[name];
         }
         return result;
      }
      
      private function parseStarterPackXml() : void
      {
         var packHash:Object = null;
         var starterPackList:XMLList = null;
         var spXml:XML = null;
         var campaigns:Array = null;
         var campaignList:XMLList = null;
         var campaignXml:XML = null;
         var packName:String = null;
         var packCost:Number = NaN;
         var packValue:Number = NaN;
         var packPurchaseCode:String = null;
         var starterPack:StarterPack = null;
         var giftList:XMLList = null;
         var giftXml:XML = null;
         var campaign:Object = null;
         var requirements:Array = null;
         var requirementXml:XML = null;
         this.m_starterPackHash = new Object();
         packHash = new Object();
         starterPackList = this.m_rawXml.starterPackConfig.starterPacks.starterPack;
         for each(spXml in starterPackList)
         {
            packName = String(spXml.@name);
            packCost = Number(spXml.@cost);
            packValue = Number(spXml.@value);
            packPurchaseCode = String(spXml.@purchaseCode);
            starterPack = new StarterPack(packName,packCost,packValue,packPurchaseCode);
            giftList = spXml.gift;
            for each(giftXml in giftList)
            {
               starterPack.addGift(parseXmlAttributesToObject(giftXml));
            }
            packHash[packName] = starterPack;
         }
         this.m_starterPackHash.starterPacks = packHash;
         campaigns = new Array();
         campaignList = this.m_rawXml.starterPackConfig.starterPackCampaigns.starterPackCampaign;
         for each(campaignXml in campaignList)
         {
            campaign = new Object();
            campaign["pack"] = String(campaignXml.@pack);
            requirements = new Array();
            for each(requirementXml in campaignXml[PrerequisiteConstants.PREREQ_XML_TAG])
            {
               requirements.push(parseXmlAttributesToObject(requirementXml,true));
            }
            campaign[StarterPackUtility.KEY_REQUIREMENTS] = requirements;
            campaigns.push(campaign);
         }
         this.m_starterPackHash.campaigns = campaigns;
      }
      
      public function getStarterPackByName(name:String) : StarterPack
      {
         var result:StarterPack = null;
         if(this.m_starterPackHash == null)
         {
            this.parseStarterPackXml();
         }
         result = null;
         if(this.m_starterPackHash.starterPacks.hasOwnProperty(name))
         {
            result = this.m_starterPackHash.starterPacks[name];
         }
         return result;
      }
      
      public function getStarterPackCampaigns() : Array
      {
         if(this.m_starterPackHash == null)
         {
            this.parseStarterPackXml();
         }
         return this.m_starterPackHash.campaigns;
      }
      
      private function parsePrereqsXml() : void
      {
         var prereqsList:XMLList = null;
         var prereqXml:XML = null;
         var node:XML = null;
         var reqObject:Object = null;
         Global.farmTimingModule.start("parse_prereq_xml");
         this.m_prereqsHash = new Object();
         prereqsList = this.m_rawXml.prereqs;
         for each(prereqXml in prereqsList)
         {
            for each(node in prereqXml[PrerequisiteConstants.PREREQ_XML_TAG])
            {
               reqObject = FarmGameSettingsManager.parseXmlAttributesToObject(node,true);
               if(Boolean(reqObject) && Boolean(reqObject[PrerequisiteConstants.KEY_NAME]) && reqObject[PrerequisiteConstants.KEY_NAME] != "")
               {
                  this.m_prereqsHash[reqObject[PrerequisiteConstants.KEY_NAME]] = reqObject;
               }
            }
         }
         Global.farmTimingModule.end("parse_prereq_xml",true);
      }
      
      public function getPrereqByName(name:String) : Object
      {
         var result:Object = null;
         result = null;
         if(!this.m_prereqsHash)
         {
            this.parsePrereqsXml();
         }
         if(Boolean(this.m_prereqsHash) && this.m_prereqsHash.hasOwnProperty(name))
         {
            result = MyLifeUtils.cloneObject(this.m_prereqsHash[name]);
         }
         return result;
      }
      
      public function getAutoConsumeGiftBoxItems() : XMLList
      {
         return this.m_rawXml.autoConsumeGiftBoxItems.giftBoxItem;
      }
      
      private function getBlockProgressionPopupItems() : Object
      {
         var xmlItem:XML = null;
         var itemName:String = null;
         if(this.m_blockProgressionPopupItemsHash == null)
         {
            this.m_blockProgressionPopupItemsHash = new Object();
            if(this.m_rawXml.blockProgressionPopupItems)
            {
               for each(xmlItem in this.m_rawXml.blockProgressionPopupItems.item)
               {
                  itemName = xmlItem.@name;
                  this.m_blockProgressionPopupItemsHash[itemName] = true;
               }
            }
         }
         return this.m_blockProgressionPopupItemsHash;
      }
      
      public function shouldBlockProgressionPopupForItem(farmItem:FarmItem) : Boolean
      {
         var result:Boolean = false;
         var blockedItems:Object = null;
         result = false;
         blockedItems = this.getBlockProgressionPopupItems();
         if(farmItem != null && farmItem.name != null)
         {
            result = Boolean(blockedItems[farmItem.name]);
         }
         return result;
      }
      
      public function getFarmItemNamesByClassName(className:String) : Array
      {
         var items:Array = null;
         var availableItemsNames:Array = null;
         var availableItems:Array = null;
         var item:Object = null;
         var index:Number = NaN;
         items = Global.farmGameSettingsManager.getItemsByClassArray(className);
         availableItemsNames = new Array();
         availableItems = new Array();
         for each(item in items)
         {
            if(item.isVisible)
            {
               if(item.haveWorldLicenseRequirements())
               {
                  if(item.meetsWorldLicenseRequirements())
                  {
                     availableItems.push(item);
                  }
               }
               else
               {
                  availableItems.push(item);
               }
            }
         }
         availableItems.sort(Global.farmGameSettingsManager.getItemSortFunction(FarmGameSettingsManager.WORLD_SORT));
         for(index = availableItems.length - 1; index >= 0; index--)
         {
            availableItemsNames.push(availableItems[index].name);
         }
         return availableItemsNames;
      }
      
      private function parseDisplaySettings() : void
      {
         var displaySettingList:XMLList = null;
         var displaySetting:XML = null;
         var itemName:String = null;
         var dialog:XML = null;
         var dialogName:String = null;
         var slot:XML = null;
         var slotName:String = null;
         var attributes:XMLList = null;
         var attribute:XML = null;
         if(this.m_displaySettings == null)
         {
            this.m_displaySettings = new Object();
            displaySettingList = this.m_rawXml.displaySettings.displaySetting;
            for each(displaySetting in displaySettingList)
            {
               itemName = displaySetting.@name;
               this.m_displaySettings[itemName] = new Object();
               for each(dialog in displaySetting.dialog)
               {
                  dialogName = dialog.@name;
                  this.m_displaySettings[itemName][dialogName] = new Object();
                  if(dialog.hasOwnProperty("slots"))
                  {
                     for each(slot in dialog.slots.slot)
                     {
                        slotName = slot.@name;
                        this.m_displaySettings[itemName][dialogName][slotName] = new Object();
                        if(slot.hasOwnProperty("image"))
                        {
                           this.m_displaySettings[itemName][dialogName][slotName]["image"] = new Object();
                           attributes = slot.image.attributes();
                           for each(attribute in attributes)
                           {
                              this.m_displaySettings[itemName][dialogName][slotName]["image"][String(attribute.name())] = String(attribute);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function getDialogDisplaySettings(objectName:String, dialogName:String) : Object
      {
         var result:Object = null;
         this.parseDisplaySettings();
         result = null;
         if(this.m_displaySettings.hasOwnProperty(objectName) && Boolean(this.m_displaySettings[objectName].hasOwnProperty(dialogName)))
         {
            result = this.m_displaySettings[objectName][dialogName];
         }
         return result;
      }
      
      protected function parseTerrainHierarchy() : void
      {
         var terrains:XMLList = null;
         var primaryTerrainsNode:XML = null;
         var terrain:XML = null;
         var terrainName:String = null;
         var terrainCode:int = 0;
         var tmpCodes:Array = null;
         this.m_terrainToCodes = new Dictionary();
         this.m_primaryTerrains = new Array();
         this.m_primaryTerrainToCode = new Dictionary();
         terrains = this.m_rawXml.terrains;
         if(terrains.children().length() > 0)
         {
            if(terrains.hasOwnProperty("primaryTerrains"))
            {
               primaryTerrainsNode = terrains.primaryTerrains[0];
               for each(terrain in primaryTerrainsNode.terrain)
               {
                  terrainName = terrain.@name.toString();
                  terrainCode = int(terrain.@code);
                  this.m_primaryTerrains[terrainCode] = terrainName;
                  this.m_primaryTerrainToCode[terrainName] = terrainCode;
                  tmpCodes = new Array();
                  tmpCodes.push(terrainCode);
                  this.m_terrainToCodes[terrainName] = tmpCodes;
               }
            }
            if(terrains.hasOwnProperty("terrainHierarchy"))
            {
               parseTerrainHierarchyRecursively(terrains.terrainHierarchy[0],this.m_terrainToCodes);
            }
         }
      }
      
      protected function get terrainNameToCodes() : Dictionary
      {
         if(this.m_terrainToCodes == null)
         {
            this.parseTerrainHierarchy();
         }
         return this.m_terrainToCodes;
      }
      
      public function getTerrainCodes(terrainName:String) : Array
      {
         return this.terrainNameToCodes[terrainName];
      }
      
      public function convertArrayTerrainNamesToCodes(terrainNames:Array) : Array
      {
         var resultArray:Array = null;
         var codes:Array = null;
         var name:String = null;
         var code:String = null;
         resultArray = new Array();
         codes = null;
         for each(name in terrainNames)
         {
            codes = this.getTerrainCodes(name);
            for each(code in codes)
            {
               resultArray[int(code)] = int(code);
            }
         }
         return resultArray;
      }
      
      public function getPrimaryTerrainNameFromCode(terrainCode:int) : String
      {
         if(this.m_primaryTerrains == null)
         {
            this.parseTerrainHierarchy();
         }
         return this.m_primaryTerrains[terrainCode];
      }
      
      public function getPrimaryTerrainCodeFromName(terrainName:String) : int
      {
         if(this.m_primaryTerrainToCode == null)
         {
            this.parseTerrainHierarchy();
         }
         return this.m_primaryTerrainToCode[terrainName];
      }
      
      public function selectPrimaryTerrainNameFromGivenCodes(codes:Array) : String
      {
         var terrainName:String = null;
         var terrainIndex:int = 0;
         var i:int = 0;
         var tmpString:String = null;
         var tmpIndex:int = 0;
         terrainName = null;
         if(codes != null && codes.length > 0)
         {
            terrainName = this.getPrimaryTerrainNameFromCode(codes[0]);
            terrainIndex = this.getTerrainPriorityIndex(terrainName);
            for(i = 1; i < codes.length; i++)
            {
               tmpString = this.getPrimaryTerrainNameFromCode(codes[i]);
               tmpIndex = this.getTerrainPriorityIndex(tmpString);
               if(terrainIndex > tmpIndex)
               {
                  terrainIndex = tmpIndex;
                  terrainName = tmpString;
               }
            }
         }
         return terrainName;
      }
      
      private function getTerrainPriorityIndex(terrainName:String) : int
      {
         var index:int = 0;
         index = -1;
         switch(terrainName)
         {
            case TERRAIN_LAND:
               index = 0;
               break;
            case TERRAIN_WATER:
               index = 1;
               break;
            case TERRAIN_TERRACE:
               index = 2;
               break;
            case TERRAIN_EARTH:
               index = 3;
               break;
            case TERRAIN_ZEN:
               index = 4;
               break;
            case TERRAIN_SNOW:
               index = 5;
               break;
            case TERRAIN_TURTLE:
               index = 6;
               break;
            case TERRAIN_DREAM:
               index = 7;
               break;
            case TERRAIN_BORABORA:
               index = 8;
               break;
            case TERRAIN_DEFAULT:
               index = int.MAX_VALUE;
               break;
            default:
               index = 5;
         }
         return index;
      }
      
      public function selectPrimaryTerrainCodeFromGivenCodes(codes:Array) : int
      {
         var terrainCode:int = 0;
         terrainCode = -1;
         if(codes != null && codes.length > 0)
         {
            terrainCode = this.getPrimaryTerrainCodeFromName(this.selectPrimaryTerrainNameFromGivenCodes(codes));
         }
         return terrainCode;
      }
      
      public function getItemSortFunction(sortBy:String) : Function
      {
         var sortFunction:Function = null;
         sortFunction = this.m_sortFunctionHash[DEFAULT];
         if(sortBy != null && sortBy != "" && this.m_sortFunctionHash.hasOwnProperty(sortBy))
         {
            sortFunction = this.m_sortFunctionHash[sortBy];
         }
         return sortFunction;
      }
      
      public function getNewOrExpiringLEItems(daysOfDefinition:int, isNew:Boolean) : Array
      {
         var result:Array = null;
         var leItems:Array = null;
         var item:FarmItem = null;
         var days:Number = NaN;
         result = [];
         leItems = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_LIMITED,FarmGameSettingsManager.ALL,FarmGameSettingsManager.ALL,FarmGameSettingsManager.REQUIRED_LEVEL,FarmGameSettingsManager.DESCENDING,true,"",null,true);
         for each(item in leItems)
         {
            if(item.isWithinLimitedStartDate() && item.isWithinLimitedEndDate() && item.isCash && item.isLimitedItem())
            {
               days = NaN;
               if(isNew)
               {
                  days = item.numOfDaysSinceLENew;
               }
               else
               {
                  days = item.numOfDaysToLEExpire;
               }
               if(!isNaN(days) && days >= 0 && days <= daysOfDefinition)
               {
                  result.push(item);
               }
            }
         }
         if(isNew)
         {
            result.sortOn("numOfDaysSinceLENew",Array.NUMERIC);
         }
         else
         {
            result.sortOn("numOfDaysToLEExpire",Array.NUMERIC);
         }
         return result;
      }
   }
}

