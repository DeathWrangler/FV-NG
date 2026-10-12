package Classes
{
   import Classes.Avatar.AvatarItem;
   import Classes.Avatar.AvatarItemState;
   import Classes.Avatar.AvatarManager;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.XMLKeys;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.MasteredSuperEnabledCropToasterIdleTask;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.UGC.UGCItemData;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemState;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.ContentAccessSettings;
   import Classes.ZItem.CurrencyData;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.ZItem.PetFarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.breeding.BreedingState;
   import Classes.buffs.*;
   import Classes.consumables.CBushel;
   import Classes.crafting.CraftingState;
   import Classes.feed.FriendSetGoalAchievementFeed;
   import Classes.storage.MasterySignStorageFilter;
   import Classes.storage.StorageItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.AchievementPopup;
   import Display.Dialogs.InGameCurrencyConversion;
   import Display.FriendBar.FriendBarSlot;
   import Display.GenericPopup;
   import Display.HUD.StatsDropDown;
   import Display.ImpulseBuy;
   import Display.InventoryWithdrawal;
   import Display.MasterySuperCropPopup;
   import Display.UI;
   import Engine.Classes.SavedObject;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Managers.AltGraphicUtility;
   import Managers.BreedingManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FeaturePresentsManager;
   import Managers.FestivalOfColorManager;
   import Managers.FriendRewardsManager;
   import Managers.InfiniteTurboManager;
   import Managers.LeaderboardManager;
   import Managers.LicenseManager;
   import Managers.LimitedSaleUtility;
   import Managers.LoyaltyProgramManager;
   import Managers.NPCManager;
   import Managers.PartyManager;
   import Managers.SpendometerManager;
   import Managers.ToasterManager;
   import Managers.TurboPPHManager;
   import Managers.WorldManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TActionCount;
   import Transactions.TBuyConsumables;
   import Transactions.TBuyItemPutGiftbox;
   import Transactions.TFreeCoins;
   import Transactions.TGenericTransaction;
   import Transactions.TIntervalActionCount;
   import Transactions.TRefreshGifts;
   import Transactions.TResetSeenFlag;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Transactions.TSetFeatureFrequencyWithBackoff;
   import Transactions.TSetItemFlag;
   import Transactions.TSetSeenFlag;
   import Transactions.TSurpassFriendStat;
   import Transactions.TUserName;
   import Transactions.TWorldScoreLevelUp;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.Mastery.MasteryLevelupWindow;
   import Widgets.Windows.OrganicCertificationRewardWindow;
   import Widgets.Windows.TravelWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class Player extends SavedObject implements IUser
   {
      
      private static var m_shouldBackOffHarvester:Boolean;
      
      protected static var FemaleAvatarThumbs:Array = ["14714","14717","147110","147112","147120","147122","147136","147148","147194","147158"];
      
      protected static var MaleAvatarThumbs:Array = ["14716","147159","147162","147163","147177","14717495","5594845","1471080"];
      
      public static const GOLD_LIMIT:Number = Number.MAX_VALUE;
      
      public static const NO_PROFILE_PIC_URL:String = "assets/hud/Friendbar/FV_Main_FriendBar_No_Profile_Img.png";
      
      public static const BALANCE_TOTAL:String = "total";
      
      public static const SWAP_DECO_XAS_SHIP_BUILDABLE:String = "xas_coming_soon_sign";
      
      public static const BALANCE_EARNED:String = "earned";
      
      public static const BALANCE_PURCHASED:String = "purchased";
      
      private static const DEFAULT_BUSHEL_AMOUNT:int = 0;
      
      public static const SCORE:String = "score";
      
      public static const LEVEL:String = "level";
      
      private static const MINIMUM_HARVESTABLE_ITEM_COUNT:int = 5;
      
      public static const FARMHAND_ITEM_NAME:String = "Farmhand";
      
      public static const ARBORIST_ITEM_NAME:String = "Arborist";
      
      public static const FARMHAND_XML_ITEM_NAME:String = "consume_farm_hands";
      
      public static const ARBORIST_XML_ITEM_NAME:String = "consume_arborists";
      
      private static const EXPIRE_BUFFS_INTERVAL:Number = 60000;
      
      public static const INVALID_META_DATA_INDEX:Number = -1;
      
      public const SEEN_EXTENDED_PERMISSIONS_ANY:String = "any";
      
      public const SECONDS_IN_EIGHTEEN_HOURS:Number = 64800;
      
      private const MAXIMUM_OPEN_MASTERY_DIALOGS:int = 5;
      
      protected var m_isInitUserDone:Boolean = false;
      
      protected var m_isPostInitUserDone:Boolean = false;
      
      protected var m_name:String;
      
      protected var m_needSaveNameToServer:Boolean = false;
      
      protected var m_snUser:SocialNetworkUser;
      
      protected var m_level:Number;
      
      protected var m_xp:Number;
      
      protected var m_lastLoginDay:Number;
      
      protected var m_worldCurrencies:Object = new Object();
      
      protected var m_worldScores:Object = new Object();
      
      protected var m_gold:Number;
      
      protected var m_miniGames:Object;
      
      protected var m_cash:Number;
      
      protected var m_cashPurchasedTotal:Number;
      
      protected var m_initialCashPurchaseTransactions:int;
      
      protected var m_initialCPATransactions:int;
      
      protected var m_featureCredits:Object = new Object();
      
      protected var m_worldFeatureCredits:Object = new Object();
      
      private var m_breedingStats:Object = new Object();
      
      protected var m_fertilizer:int = -1;
      
      protected var m_queuedFertilizer:int = -1;
      
      protected var m_totalFertilizer:int = 0;
      
      protected var m_animalFood:int = -1;
      
      protected var m_turboChargers:int = 0;
      
      protected var m_queuedAnimalFood:int = -1;
      
      public var hasSeenFertPopup:Boolean = false;
      
      public var previousCSYellowBoxMsg:String = "";
      
      public var previousMarketingBlueBoxMsg:String = "";
      
      public var previousIssueBoxMsg:String = "";
      
      public var hasSeenUnwitherPopupWorlds:Array = new Array();
      
      public var hasSeenUnwitherPopup:Boolean = false;
      
      protected var m_energy:Number = 0;
      
      protected var m_energyMax:Number;
      
      protected var m_nanPid:String = null;
      
      public var fuelDiscovery:Object;
      
      protected var m_hasUnlimitedLights:Boolean = false;
      
      protected var m_altGraphicCredits:Object = {};
      
      protected var m_farmServiceCredits:Object = {};
      
      private var m_numOpenedPresents:int = 0;
      
      public var lastStorageFullMsg:Number = 0;
      
      protected var m_progressBarData:Object = {};
      
      public var isSharingFlowers:Boolean = false;
      
      protected var m_limitedItems:Object = {};
      
      protected var m_avatar:FarmAvatar;
      
      protected var m_unparsedNeighborsData:Array;
      
      protected var m_neighbors:Array = [];
      
      protected var m_inactiveExp:int = 0;
      
      private var m_inFeedCheckboxV2Exp:Boolean = false;
      
      private var m_feedCheckboxV2ExpFlag:Boolean = true;
      
      protected var m_communityNeighbor:int = 0;
      
      public var topFriends:Array = [];
      
      protected var m_missionItemInventory:Array = [];
      
      protected var m_seedWishData:Object = {};
      
      protected var m_seeds:Dictionary = new Dictionary();
      
      protected var m_gifts:Dictionary = new Dictionary();
      
      private var m_giftsVersion:int = 0;
      
      protected var m_promos:Object = new Object();
      
      protected var m_inventory:Dictionary = new Dictionary();
      
      protected var m_pendingUpgrades:Object = new Object();
      
      protected var m_incrementalFriendChecks:Dictionary = new Dictionary();
      
      private var m_chatLastMessageReadTime:Object = new Object();
      
      protected var m_options:Object = {};
      
      private var m_isNew:Boolean = false;
      
      private var m_isFirstDay:Boolean = false;
      
      private var m_firstDayTimestamp:Number = 0;
      
      private var m_seenRequestEmail:int = 0;
      
      private var m_craftingState:CraftingState = new CraftingState();
      
      private var m_breedingState:BreedingState = new BreedingState();
      
      private var m_breedingSkillStates:Object = {};
      
      private var m_avatarState:AvatarItemState = new AvatarItemState();
      
      private var m_w2wState:W2WFeatureState = new W2WFeatureState();
      
      private var m_seenRevampEmail:int = 0;
      
      private var m_timeLastSeenRevampEmail:int = -1;
      
      private var m_seenRevampProxyEmail:int = 0;
      
      private var m_timeLastSeenRevampProxyEmail:int = -1;
      
      private var m_seenRevampLockedboxEmail:int = 0;
      
      private var m_timeLastSeenRevampLockedboxEmail:int = -1;
      
      private var m_hourLastSeenRequestEmail:int = 0;
      
      private var m_hasReceivedGiftForEmailPermissions:Boolean = false;
      
      private var m_hasVisitFriend:Number = 0;
      
      private var m_achievements:Object = {};
      
      private var m_achCounters:Object = {};
      
      private var m_shownAchievementDialogs:Object = {};
      
      private var m_mastery:Object = {};
      
      private var m_masteryCounters:Object = {};
      
      private var m_pendingMasteryCounters:Object = {};
      
      private var m_organicCounters:Object = {};
      
      private var m_organicCertificationTotal:int = 0;
      
      private var m_masteredTypeCounters:Object = {};
      
      private var m_shownMasteryDialogs:Object = {};
      
      protected var m_collectionCounters:Object = {};
      
      protected var m_storedCollections:Object = {};
      
      protected var m_collectionLevels:Object = {};
      
      private var m_hasSeenNoPottingShedFlow:Boolean = false;
      
      private var m_showBuyHarvestBuildingFeed:Object = {};
      
      private var m_seenFlags:Object = {};
      
      private var m_itemFlags:Object = {};
      
      private var m_seenSessionFlags:Object = {};
      
      private var m_featureFrequency:Object = {};
      
      private var m_gaveCoins:Boolean = false;
      
      private var m_inGaveCoins:Boolean = false;
      
      private var m_isFarmvilleFan:int = 0;
      
      private var m_fanPages:Object = {};
      
      private var m_externalLevels:Object = {};
      
      private var m_buffs:Dictionary = new Dictionary();
      
      private var m_lastHorseStableSendTime:Number = 0;
      
      private var m_lastFrenchChateauSendTime:Number = 0;
      
      private var m_lastNurserySendTime:Number = 0;
      
      private var m_actionCounts:Object = null;
      
      private var m_incrementalGateArray:Object = null;
      
      private var m_hasSeenCoinsPopup:Boolean = false;
      
      private var m_nextExpireBuffs:Number = 0;
      
      private var m_neighborPlumbingAddExcludeList:Object = null;
      
      private var m_pendingNeighbors:Object = null;
      
      private var m_isMysteryGameInitialized:Boolean = false;
      
      private var m_mysteryBox2TargetStates:Array = new Array();
      
      private var m_mysteryBox2TileStates:Array = new Array();
      
      private var m_lastSocialPlumbingActionTime:Number;
      
      private var m_adoptedAnimals:Object = null;
      
      private var m_pregnantSow:Object = null;
      
      protected var m_avatarVisible:Boolean = true;
      
      protected var m_avatarArrowIndicatorVisible:Boolean = true;
      
      private var m_avatarSurfacingEnabled:Boolean;
      
      private var m_avatarSurfacingFrequency:int;
      
      private var m_avatarSurfacingItem:String;
      
      protected var m_statW2WTimer:Timer = null;
      
      protected var m_statW2WData:Object = null;
      
      protected var m_playerStatValues:Array = null;
      
      protected var m_cardStats:Object = null;
      
      protected var m_playerSubStatValues:Array = null;
      
      protected var m_isAutomatedQA:Boolean = false;
      
      protected var m_isKeynoteQA:Boolean = false;
      
      public var storageData:Object = null;
      
      public var currentStorageWorldId:int = 0;
      
      public var storageCapacityHash:Object = {};
      
      public var m_feedImage:String;
      
      public var m_fofData:Array = new Array();
      
      public var m_dateOfLastPublishPermissionRequest:int = -1;
      
      public var m_hasPublishPermission:Boolean;
      
      private var m_nextMarketPromos:Array = new Array(0,0,0,0,0);
      
      protected var m_crossGameGiftingData:Object = null;
      
      private var m_limitedSaleTimers:Object = null;
      
      protected var m_superCropsStatus:Array = new Array();
      
      protected var m_lonelyAnimalCode:String = "";
      
      private var m_masteryDialogsCounter:int = 0;
      
      private var m_currentMOTD:Object = null;
      
      private var m_motdSeenFlags:Object = null;
      
      public var extendedPermissionState:ExtendedPermissionState = null;
      
      public var m_lotteryTickets:Array = null;
      
      private var m_prereqDSObject:Object = null;
      
      public var targetingGroups:Array = [];
      
      private var m_purchaseHistory:Object = null;
      
      private var m_ugcItemData:UGCItemData;
      
      public var fbFeedAutopublishCap:int = 0;
      
      public var fbFeedAutopublishCount:int = 0;
      
      public var fbFeedAutopublishCapTimeInterval:int = 0;
      
      public var defaultFbFeedAutopublishCap:int = 25;
      
      public var defaultFbFeedAutopublishCapTimeInterval:int = 86400;
      
      private var m_isLoaded:Boolean = false;
      
      private var m_transactionLog:Array = null;
      
      private var m_thirdPartyID:String = null;
      
      protected var m_farmTalkPermission:Boolean = true;
      
      public var unacceptedFbPermissions:Object = {};
      
      public var acceptedFbPermissions:Object = {};
      
      public var daysInactive:int = 0;
      
      public var reactivating:Boolean = false;
      
      private var m_sentGifts:Object = {};
      
      private var m_seedharvestCountsSinceLastBushelDrop:Object = {};
      
      private var m_leaderboardStates:Object = {};
      
      public var subscriptionStatus:String;
      
      private var m_giftsendBlacklist:Boolean = false;
      
      private var m_socialProofFacepileData:Vector.<Object> = new Vector.<Object>();
      
      private var m_numRecentlyPaidFriends:int = 0;
      
      private var m_fbEventRsvpStatusList:Object = null;
      
      private var m_smartSystemCraftShopConfig:SmartSystemData = null;
      
      private var m_smartSystemCraftingCottageConfig:SmartSystemData = null;
      
      private var m_smartSystemFarmStandConfig:SmartSystemData = null;
      
      private var m_userId:String;
      
      private var m_masterySignCleaned:Boolean = false;
      
      public function Player(newSNUser:SocialNetworkUser)
      {
         super();
         this.snUser = newSNUser;
         this.m_playerStatValues = ["?","?","?","?","?","?"];
         this.m_playerSubStatValues = [[],[],[],[],[],[]];
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.level = this.level;
         obj.gold = this.gold;
         obj.cash = this.cash;
         obj.energyMax = this.energyMax;
         obj.xp = this.xp;
         obj.neighbors = Global.friendManager.neighborUids;
         obj.options = this.options;
         obj.achievements = this.achievements;
         obj.achCounters = this.achCounters;
         obj.mastery = this.mastery;
         obj.masteryCounters = this.masteryCounters;
         obj.collectionCounters = this.collectionCounters;
         obj.storedCollections = this.storedCollections;
         obj.collectionLevels = this.collectionLevels;
         obj.featureCredits = this.m_featureCredits;
         obj.miniGames = this.miniGames;
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         var hashKey:String = null;
         var featureFriendCheck:String = null;
         var neighborActionLimitData:Object = null;
         var neighbors:Array = null;
         var uid:String = null;
         var neighborUid:String = null;
         var neighborUidTrimmed:String = null;
         var neighborUidNum:Number = NaN;
         if(data.nanPid)
         {
            this.nanPid = data.nanPid;
         }
         this.gold = data.gold;
         this.cash = data.cash;
         this.xp = data.xp;
         this.miniGames = data.miniGames;
         this.level = Global.farmGameSettingsManager.getLevelForXP(this.xp);
         this.energyMax = data.energyMax;
         if(data.worldCurrencies)
         {
            this.m_worldCurrencies = data.worldCurrencies;
         }
         if(data.hasOwnProperty("lastLoginDay"))
         {
            this.m_lastLoginDay = data.lastLoginDay;
         }
         if(data.worldScores)
         {
            this.m_worldScores = data.worldScores;
         }
         if(data.hasOwnProperty("masterySignCleaned"))
         {
            this.m_masterySignCleaned = data.masterySignCleaned as Boolean;
         }
         if(data.neighbors is Array)
         {
            Global.friendManager.neighborUids = data.neighbors;
         }
         else
         {
            neighbors = new Array();
            for each(uid in data.neighbors)
            {
               neighbors.push(uid);
            }
            Global.friendManager.neighborUids = neighbors;
         }
         this.options = data.options;
         this.hasVisitFriend = data.hasVisitFriend;
         this.achievements = data.achievements;
         this.achCounters = data.achCounters;
         this.mastery = data.mastery;
         this.masteryCounters = data.masteryCounters;
         this.organicCounters = data.organicCounters;
         this.organicCertificationTotal = data.organicCertificationCount;
         this.collectionCounters = data.collectionCounters;
         this.storedCollections = data.storedCollections;
         this.collectionLevels = data.collectionLevels;
         this.m_hasUnlimitedLights = data.hasUnlimitedLights;
         this.m_farmServiceCredits = data.farmServiceCredits ? data.farmServiceCredits : {};
         this.m_altGraphicCredits = data.altGraphicCredits ? data.altGraphicCredits : {};
         this.m_altGraphicCredits["lights"] = this.hasUnlimitedCredits("lights") ? this.m_altGraphicCredits["lights"] : data.numLightsLeft;
         this.numOpenedPresents = data.numOpenedPresents;
         this.m_dateOfLastPublishPermissionRequest = data.dateOfLastPublishPermissionRequest;
         this.m_hasPublishPermission = data.hasPublishPermission;
         this.lastHorseStableSendTime = data.lastHorseStableSendTime;
         this.lastFrenchChateauSendTime = data.lastFrenchChateauSendTime;
         this.lastNurserySendTime = data.lastNurserySendTime;
         this.m_incrementalGateArray = data.incrementalGateArray;
         this.m_progressBarData = data.progressBarData;
         this.m_neighborPlumbingAddExcludeList = data.neighborPlumbingAddExcludeList;
         this.m_pendingNeighbors = data.pendingNeighbors;
         this.m_lastSocialPlumbingActionTime = data.lastSocialPlumbingTime;
         this.m_adoptedAnimals = data.m_adoptedAnimals;
         this.m_superCropsStatus = data.superCropsStatus;
         this.lotteryTickets = data.lotteryTickets as Array;
         this.m_lonelyAnimalCode = data.lonelyAnimalCode;
         this.m_currentMOTD = data.currentMOTD;
         this.saveMotdSeverArrayAsHash(data.motdSeenFlags);
         this.limitedSaleExpirations = data.limitedSaleInfo;
         this.m_cashPurchasedTotal = data.cashPurchasedTotal;
         this.m_initialCashPurchaseTransactions = int(data.numCashTransactions);
         this.m_initialCPATransactions = int(data.numCPATransactions);
         this.m_avatarSurfacingEnabled = data.avatarSurfacingEnabled as Boolean;
         this.m_avatarSurfacingFrequency = data.avatarSurfacingFrequency as int;
         this.m_avatarSurfacingItem = data.avatarSurfacingItem as String;
         this.m_transactionLog = data.hasOwnProperty("transactionLog") ? data.transactionLog : new Array();
         this.m_farmTalkPermission = data.hasOwnProperty("farmTalkPermission") ? Boolean(data.farmTalkPermission) : true;
         if(data.chatLastMessageReadTime)
         {
            for(neighborUid in data.chatLastMessageReadTime)
            {
               neighborUidTrimmed = neighborUid.replace("_","");
               neighborUidNum = Number(neighborUidTrimmed);
               this.m_chatLastMessageReadTime[neighborUidNum] = data.chatLastMessageReadTime[neighborUid];
            }
         }
         this.storageCapacityHash = {};
         for(hashKey in data.storageCapacityHash)
         {
            this.storageCapacityHash[hashKey.replace("_","")] = data.storageCapacityHash[hashKey];
         }
         if(Boolean(this.m_userId == "-1") && Boolean(GlobalEngine.socialNetwork) && GlobalEngine.socialNetwork.getLoggedInUserId() != "0")
         {
            this.m_userId = GlobalEngine.socialNetwork.getLoggedInUserId();
         }
         this.initFeatureCredits(data.featureCredits);
         this.setFeatureCreditsForWorld(Global.worldManager.currentWorldType);
         FeaturePresentsManager.getInstance().loadObjects(data.featurePresents);
         for(featureFriendCheck in data.incrementalFriendChecks)
         {
            this.m_incrementalFriendChecks[featureFriendCheck] = data.incrementalFriendChecks[featureFriendCheck];
         }
         FriendRewardsManager.getInstance().loadFriendRewards(data.friendRewards);
         Global.hud.setLightIcon();
         this.m_seenFlags = data.seenFlags;
         this.m_itemFlags = data.itemFlags;
         this.m_featureFrequency = data.featureFrequency;
         this.m_externalLevels = data.externalLevels;
         this.m_actionCounts = data.actionCounts;
         neighborActionLimitData = Boolean(data.neighborActionLimits) && Boolean(data.neighborActionLimits.m_neighborActionLimits) ? data.neighborActionLimits.m_neighborActionLimits : null;
         VisitorManager.getInstance().initNeighborActionLimits(neighborActionLimitData,Global.farmGameSettingsManager.actionableFeatureBuildings);
         if(data.hasOwnProperty("patchTimes"))
         {
            Global.farmGameSettingsManager.updatePatchTimes(data.patchTimes);
         }
         var energyMan:Object = data.energyManager;
         this.turboChargers = energyMan.turboChargers;
         Global.hud.lockVisualEffectsForNextUpdate();
         this.conditionallyUpdateHUD();
         this.m_isLoaded = true;
      }
      
      public function set numRecentlyPaidFriends(numFriends:int) : void
      {
         if(numFriends > 0)
         {
            this.m_numRecentlyPaidFriends = numFriends;
         }
      }
      
      public function get numRecentlyPaidFriends() : int
      {
         return this.m_numRecentlyPaidFriends;
      }
      
      public function setSocialProofFacepileData(facepileData:Array) : void
      {
         var facepileDatum:Object = null;
         var tempFriendData:Object = null;
         if(facepileData != null)
         {
            for each(facepileDatum in facepileData)
            {
               tempFriendData = new Object();
               if(facepileDatum != null && facepileDatum.hasOwnProperty(MFSConstants.FIRST_NAME) && facepileDatum[MFSConstants.FIRST_NAME] != null)
               {
                  tempFriendData.firstName = facepileDatum[MFSConstants.FIRST_NAME];
               }
               if(facepileDatum != null && facepileDatum.hasOwnProperty(MFSConstants.LAST_NAME) && facepileDatum[MFSConstants.LAST_NAME] != null)
               {
                  tempFriendData.lastName = facepileDatum[MFSConstants.LAST_NAME];
               }
               if(facepileDatum != null && facepileDatum.hasOwnProperty(MFSConstants.PIC_SQUARE) && facepileDatum[MFSConstants.PIC_SQUARE] != null)
               {
                  tempFriendData.picUrl = facepileDatum[MFSConstants.PIC_SQUARE];
               }
               if(tempFriendData.picUrl != "" && tempFriendData.firstName != "" && tempFriendData.lastName != "")
               {
                  this.m_socialProofFacepileData.push(tempFriendData);
               }
            }
         }
      }
      
      public function get socialProofFacepileData() : Vector.<Object>
      {
         return this.m_socialProofFacepileData;
      }
      
      public function get thirdPartyID() : String
      {
         return this.m_thirdPartyID;
      }
      
      public function set thirdPartyID(id:String) : void
      {
         this.m_thirdPartyID = id;
      }
      
      public function get isDataLoaded() : Boolean
      {
         return this.m_isLoaded;
      }
      
      public function get masterySignCleaned() : Boolean
      {
         return this.m_masterySignCleaned;
      }
      
      public function loadUGCItemData(ugcItemData:Object) : void
      {
         if(this.m_ugcItemData == null)
         {
            this.m_ugcItemData = new UGCItemData();
         }
         this.m_ugcItemData.loadData(ugcItemData);
      }
      
      public function get ugcItemData() : UGCItemData
      {
         if(this.m_ugcItemData == null)
         {
            this.m_ugcItemData = new UGCItemData();
         }
         return this.m_ugcItemData;
      }
      
      public function setFanPageStatuses(data:Object) : void
      {
         this.m_fanPages = data;
      }
      
      public function get craftingState() : CraftingState
      {
         return this.m_craftingState;
      }
      
      public function clearCraftingState() : void
      {
         this.m_craftingState = new CraftingState();
      }
      
      public function get breedingState() : BreedingState
      {
         return this.m_breedingState;
      }
      
      public function getBreedingSkillStateForFeature(featureName:String) : AnimalBreedingSkillState
      {
         if(this.m_breedingSkillStates.hasOwnProperty(featureName) == false)
         {
            this.m_breedingSkillStates[featureName] = new AnimalBreedingSkillState(featureName);
         }
         return this.m_breedingSkillStates[featureName];
      }
      
      public function getDragonBreedingSkillStateForFeature(featureName:String) : DragonBreedingSkillState
      {
         if(this.m_breedingSkillStates.hasOwnProperty(featureName) == false)
         {
            this.m_breedingSkillStates[featureName] = new DragonBreedingSkillState(featureName);
         }
         return this.m_breedingSkillStates[featureName] as DragonBreedingSkillState;
      }
      
      public function getBaseLineFriendsForFeature(featureName:String) : int
      {
         return IncrementalFriendGateManager.getInstance().getBaseLineFriendsForFeature(featureName,this);
      }
      
      public function get incrementalFriendChecks() : Dictionary
      {
         return this.m_incrementalFriendChecks;
      }
      
      public function get dateOfLastPublishPermissionRequest() : Number
      {
         return this.m_dateOfLastPublishPermissionRequest;
      }
      
      public function set dateOfLastPublishPermissionRequest(value:Number) : void
      {
         this.m_dateOfLastPublishPermissionRequest = value;
      }
      
      public function get hasPublishPermission() : Boolean
      {
         return this.m_hasPublishPermission;
      }
      
      public function set hasPublishPermission(value:Boolean) : void
      {
         this.m_hasPublishPermission = value;
      }
      
      public function isFanOfPage(pageId:Number) : Boolean
      {
         var fieldName:String = null;
         var pageInfo:Object = null;
         var isFan:Boolean = false;
         for(fieldName in this.m_fanPages)
         {
            pageInfo = this.m_fanPages[fieldName];
            if(pageInfo.pageId == pageId)
            {
               isFan = Boolean(pageInfo.isFan);
               break;
            }
         }
         return isFan;
      }
      
      public function setInitUserDone() : void
      {
         this.m_isInitUserDone = true;
      }
      
      public function get initFinished() : Boolean
      {
         return this.m_isInitUserDone;
      }
      
      public function setPostInitUserDone() : void
      {
         this.m_isPostInitUserDone = true;
      }
      
      public function get postInitFinished() : Boolean
      {
         return this.m_isPostInitUserDone;
      }
      
      public function getGifts() : Array
      {
         var key:String = null;
         var giftArray:Array = new Array();
         for(key in this.m_gifts)
         {
            giftArray.push(this.m_gifts[key]);
         }
         return giftArray;
      }
      
      public function getGiftCount() : int
      {
         var giftArr:Array = this.getGifts();
         var numTypes:int = int(giftArr.length);
         var result:int = 0;
         for(var idx:int = 0; idx < numTypes; idx++)
         {
            result += Number(giftArr[idx].quantity);
         }
         return result;
      }
      
      public function hasGiftBoxCapacity(quantity:int = 1, item:FarmItem = null) : Boolean
      {
         var result:Boolean = true;
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_LIMIT_CHECK_EXPT) == 2)
         {
            result &&= this.getGifts().length + 1 <= Global.farmGameSettingsManager.getInt("maxGiftLimit");
            if(item != null && item.hasOwnProperty("code"))
            {
               result &&= this.getGiftCountForItemKey(item.code) + quantity <= GiftBoxWindow.PER_ITEM_QUANTITY_LIMIT;
            }
         }
         else
         {
            result &&= this.getGifts().length + 1 <= Global.farmGameSettingsManager.getInt("maxGiftLimit") && this.getGiftCount() + quantity <= GlobalEngine.getFlashVar("GIFTBOX_TOTAL_ITEM_LIMIT");
         }
         return result;
      }
      
      public function getGiftCountForItem(itemName:String = "") : int
      {
         var result:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(item)
         {
            result = this.getGiftCountForItemKey(item.code);
         }
         return result;
      }
      
      public function getGiftCountForItems(itemNames:Array) : int
      {
         var itemsLength:int = 0;
         var index:int = 0;
         var item:FarmItem = null;
         var result:int = 0;
         if(itemNames != null)
         {
            itemsLength = int(itemNames.length);
            for(index = 0; index < itemsLength; index++)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemNames[index]);
               if(item)
               {
                  result += this.getGiftCountForItemKey(item.code);
               }
            }
         }
         return result;
      }
      
      public function getGiftCountForItemKey(key:String = "") : int
      {
         var result:int = 0;
         var storageItem:StorageItem = this.gifts[key];
         if(storageItem)
         {
            result = storageItem.quantity;
         }
         return result;
      }
      
      public function get feedImage() : String
      {
         return this.m_feedImage;
      }
      
      public function set feedImage(imageLink:String) : void
      {
         this.m_feedImage = imageLink;
      }
      
      public function populatePromos(data:Object) : void
      {
         var result:Object = new Object();
         if(data != null)
         {
            result = data;
         }
         this.m_promos = result;
      }
      
      public function getWorldMaxInventoryCapacity(inventoryId:Number = 0) : int
      {
         inventoryId = inventoryId != 0 ? inventoryId : Global.worldManager.getCurrentWorldStorageId();
         return Global.storageSettings.getMaxInventoryCapById(inventoryId);
      }
      
      public function getInventoryCapacity(returnTrueCap:Boolean = false, inventoryId:Number = 0) : int
      {
         inventoryId = inventoryId != 0 ? inventoryId : Global.worldManager.getCurrentWorldStorageId();
         var existingCapacity:int = 0;
         var objs:Array = Global.world.getObjects();
         for(var idx:int = 0; idx < objs.length; idx++)
         {
            if(Boolean(objs[idx] is StorageBuilding) && Boolean(objs[idx].isInventoryBuilding()) && Boolean(objs[idx].capacity))
            {
               existingCapacity += objs[idx].capacity;
            }
         }
         var cap:int = Global.storageSettings.getMaxInventoryCapById(inventoryId);
         if(cap <= existingCapacity && !returnTrueCap)
         {
            if(!this.getSeenFlag("maxCapacityExceeded"))
            {
               this.setSeenFlag("maxCapacityExceeded");
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","CapacityOvershot",{"quantity":cap})));
            }
            existingCapacity = cap;
         }
         this.storageCapacityHash[Global.worldManager.getCurrentWorldStorageId()] = existingCapacity;
         return this.storageCapacityHash[inventoryId];
      }
      
      public function isGarageUnderConstruction() : Boolean
      {
         return Global.world.getObjectsByClass(GarageConstructionBuilding).length > 0;
      }
      
      public function getInventoryUsage(inventoryId:Number = 0) : int
      {
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var usage:int = 0;
         var inventory:Dictionary = this.getInventory(inventoryId);
         if(inventory)
         {
            for(key in inventory)
            {
               inventoryItem = inventory[key] as StorageItem;
               if(inventoryItem)
               {
                  usage += inventoryItem.quantity;
               }
            }
         }
         return usage;
      }
      
      public function hasInventorySpace(inventoryId:Number = 0) : Boolean
      {
         var result:Boolean = true;
         var capacity:int = this.getInventoryCapacity(false,inventoryId);
         var usage:int = this.getInventoryUsage(inventoryId);
         return usage < capacity;
      }
      
      public function set hasVisitFriend(hasVisitFriend:Number) : void
      {
         this.m_hasVisitFriend = hasVisitFriend;
      }
      
      public function get hasVisitFriend() : Number
      {
         return this.m_hasVisitFriend;
      }
      
      public function get firstName() : String
      {
         return this.snUser.firstName;
      }
      
      public function setNameFromServer(userName:String) : void
      {
         this.name = userName;
         if("" == userName || null == userName)
         {
            this.m_needSaveNameToServer = true;
         }
      }
      
      public function updateNameFromSNUser() : void
      {
         var newSnUser:SocialNetworkUser = GlobalEngine.socialNetwork.getLoggedInUser();
         var hasReceivedSNUserData:Boolean = newSnUser != null && "" != newSnUser.firstName;
         var hasSetPlayerName:Boolean = "" != this.name && null != this.name;
         if(this.m_isInitUserDone && (hasReceivedSNUserData || hasSetPlayerName))
         {
            if(!hasSetPlayerName)
            {
               this.name = newSnUser.firstName;
            }
            else if("" == newSnUser.firstName || null == newSnUser.firstName)
            {
               newSnUser.firstName = this.name;
            }
            this.snUser = newSnUser;
            if(Global.ui)
            {
               Global.ui.m_friendBar.updatePlayerSocialData(this.snUser);
            }
            if(this.m_needSaveNameToServer)
            {
               TransactionManager.addTransaction(new TUserName(this.name));
            }
         }
      }
      
      public function set level(amount:Number) : void
      {
         this.m_level = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function get level() : Number
      {
         return this.m_level;
      }
      
      public function get mafiaWarsLevel() : int
      {
         return this.m_externalLevels["mafiawars"];
      }
      
      public function get gaveCoins() : Boolean
      {
         return this.m_gaveCoins;
      }
      
      private function hasUnlimitedLights() : Boolean
      {
         return this.m_hasUnlimitedLights || this.numAltGraphicCredits("lights") == AltGraphicUtility.UNLIMITED_LICENSE;
      }
      
      public function hasUnlimitedCredits(credit:String) : Boolean
      {
         var result:Boolean = false;
         var licIndex:int = credit.indexOf("_unlimited");
         if(licIndex > -1)
         {
            credit = credit.slice(0,licIndex);
         }
         result = this.numAltGraphicCredits(credit) == AltGraphicUtility.UNLIMITED_LICENSE;
         if(!result)
         {
            if(credit == "lights")
            {
               result = this.hasUnlimitedLights();
            }
         }
         return result;
      }
      
      public function setUnlimitedAltGraphicsCredits(name:String, isUnlimited:Boolean) : void
      {
         if(isUnlimited)
         {
            this.m_altGraphicCredits[name] = AltGraphicUtility.UNLIMITED_LICENSE;
         }
         else
         {
            this.m_altGraphicCredits[name] = 0;
         }
      }
      
      public function turnOnUnlimitedLights() : void
      {
         this.m_hasUnlimitedLights = true;
      }
      
      public function numAltGraphicCredits(name:String) : int
      {
         return this.m_altGraphicCredits[name];
      }
      
      public function incAltGraphicCredits(name:String) : void
      {
         name = AltGraphicUtility.getAltGraphicCreditKey(name);
         if(!this.hasUnlimitedCredits(name))
         {
            if(this.m_altGraphicCredits[name])
            {
               ++this.m_altGraphicCredits[name];
            }
            else
            {
               this.m_altGraphicCredits[name] = 1;
            }
         }
      }
      
      public function decAltGraphicCredits(name:String) : void
      {
         name = AltGraphicUtility.getAltGraphicCreditKey(name);
         if(Boolean(this.m_altGraphicCredits[name]) && this.m_altGraphicCredits[name] > 0)
         {
            if(!this.hasUnlimitedCredits(name))
            {
               --this.m_altGraphicCredits[name];
            }
         }
      }
      
      public function useFarmServiceCredit(serviceName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getFarmServiceCredits(serviceName) > 0)
         {
            --this.m_farmServiceCredits[serviceName];
            result = true;
         }
         return result;
      }
      
      public function addFarmServiceCredit(serviceName:String, amount:int) : void
      {
         if(this.m_farmServiceCredits[serviceName])
         {
            this.m_farmServiceCredits[serviceName] += amount;
         }
         else
         {
            this.m_farmServiceCredits[serviceName] = amount;
         }
      }
      
      public function getFarmServiceCredits(serviceName:String) : int
      {
         return int(this.m_farmServiceCredits[serviceName]);
      }
      
      public function get xpBonus() : int
      {
         return BPermanentTypeGain.getCurrentGainBonus(BPermanentTypeGain.SUBTYPE_XP);
      }
      
      public function calculateAndAddXp(delta:int, useBuff:Boolean = true) : int
      {
         var deltaXp:int = this.calculateXp(delta,useBuff);
         this.updateXp(this.xp + deltaXp);
         return deltaXp;
      }
      
      public function calculateXp(delta:int, useBuff:Boolean = true) : int
      {
         var multiplier:int = useBuff ? this.xpBonus : 1;
         return delta * multiplier;
      }
      
      public function set xp(amount:Number) : void
      {
         var deltaXp:Number = this.calculateXp(amount - this.xp);
         var newAmount:Number = isNaN(this.xp) ? amount : this.xp + deltaXp;
         this.updateXp(newAmount);
      }
      
      private function updateXp(amount:Number) : void
      {
         var currentLevel:Number = NaN;
         var levelUpCashRewardLevelCap:int = 0;
         var deltaXp:Number = amount - this.m_xp;
         if(amount > this.m_xp)
         {
            currentLevel = 1;
            if(amount > 0)
            {
               currentLevel = Global.farmGameSettingsManager.getLevelForXP(amount);
               if(this.level < currentLevel && currentLevel > 1)
               {
                  TransactionManager.sendAllTransactions(true);
                  levelUpCashRewardLevelCap = Global.farmGameSettingsManager.getLevelUpCashRewardLevelCap();
                  if(this.level < levelUpCashRewardLevelCap)
                  {
                     this.cash += Math.min(currentLevel,levelUpCashRewardLevelCap) - this.level;
                  }
                  this.level = currentLevel;
                  UI.displayLevelUpDialog(this.m_level);
                  AvatarManager.conditionallyShowOnboarding();
                  Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
                  this.updatePlayerStat(StatsDropDown.INDEX_LEVEL,this.level);
                  if(CIPStartNow.canShowGDPAtLevel(currentLevel))
                  {
                     CIPStartNow.showStarterPack();
                  }
               }
            }
         }
         this.m_xp = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function get xp() : Number
      {
         return this.m_xp;
      }
      
      public function get lastLoginDayTimestamp() : Number
      {
         return this.m_lastLoginDay;
      }
      
      public function get worldScores() : Object
      {
         return this.m_worldScores;
      }
      
      public function get currentWorldScore() : Number
      {
         var result:Number = 0;
         var worldScoreId:String = Global.worldManager.currentWorldScoreId;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.SCORE]);
            }
         }
         return result;
      }
      
      public function get currentWorldScore2() : Number
      {
         var result:Number = 0;
         var worldScoreId:String = Global.worldManager.currentWorldScoreId;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.SCORE]);
            }
         }
         return result;
      }
      
      public function get currentWorldLevel() : Number
      {
         var result:Number = 1;
         var worldScoreId:String = Global.worldManager.currentWorldScoreId;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.LEVEL]);
            }
         }
         return result;
      }
      
      public function get currentWorldLevel2() : Number
      {
         var result:Number = 1;
         var worldScoreId:String = Global.worldManager.currentWorldScore2Id;
         if(worldScoreId != "")
         {
            if(Boolean(this.m_worldScores) && Boolean(this.m_worldScores[worldScoreId]))
            {
               result = Number(this.m_worldScores[worldScoreId][Player.LEVEL]);
            }
         }
         return result;
      }
      
      public function getWorldScore(scoreUnit:String) : Number
      {
         var result:int = 0;
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(Player.SCORE)))
         {
            result = int(this.m_worldScores[scoreUnit][Player.SCORE]);
         }
         return result;
      }
      
      public function adminResetWorldScore(scoreUnit:String) : void
      {
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(Player.SCORE)))
         {
            delete this.m_worldScores[scoreUnit];
         }
      }
      
      public function set gold(amount:Number) : void
      {
         if(amount < 0 || amount > GOLD_LIMIT)
         {
            amount = GOLD_LIMIT;
         }
         this.m_gold = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function get gold() : Number
      {
         return this.m_gold;
      }
      
      public function set miniGames(obj:Object) : void
      {
         this.m_miniGames = obj;
      }
      
      public function get miniGames() : Object
      {
         return this.m_miniGames;
      }
      
      public function set cash(amount:int) : void
      {
         this.m_cash = amount;
         this.conditionallyUpdateHUD();
         SpendometerManager.instance.checkAndUpdateCashCount(amount);
      }
      
      public function get cash() : int
      {
         return this.m_cash;
      }
      
      public function getWorldCurrencyMultiplier(unit:String) : int
      {
         var currency:CurrencyData = null;
         var index:int = 0;
         var result:int = 1;
         if(unit == Currency.COINS || unit == Currency.GOLD)
         {
            result = BPermanentTypeGain.getCurrentGainBonus(BPermanentTypeGain.SUBTYPE_COIN);
         }
         else
         {
            currency = Global.farmGameSettingsManager.getCurrencyData(unit);
            if(currency)
            {
               for(index = 0; index < currency.buffs.length; index++)
               {
                  result *= BPermanentTypeGain.getCurrentGainBonus(currency.buffs[index]);
               }
            }
         }
         return result;
      }
      
      public function updateWorldCurrency(unit:String, delta:int, useBuff:Boolean = false) : Boolean
      {
         var currency:CurrencyData = null;
         var balance:Number = NaN;
         var newBalance:Number = NaN;
         var result:Boolean = false;
         if(useBuff && delta > 0)
         {
            delta *= this.getWorldCurrencyMultiplier(unit);
         }
         if(unit == Currency.COINS || unit == Currency.GOLD)
         {
            this.gold += delta;
         }
         else
         {
            currency = Global.farmGameSettingsManager.getCurrencyData(unit);
            if(currency)
            {
               balance = 0;
               if(this.m_worldCurrencies.hasOwnProperty(unit))
               {
                  balance = this.m_worldCurrencies[unit][Player.BALANCE_TOTAL] as Number;
               }
               else
               {
                  this.m_worldCurrencies[unit] = {};
               }
               delta = Math.floor(delta);
               newBalance = balance + delta;
               if(newBalance >= 0)
               {
                  this.m_worldCurrencies[unit][Player.BALANCE_TOTAL] = newBalance;
                  this.conditionallyUpdateHUD();
                  result = true;
               }
               else
               {
                  ErrorManager.addError("Invalid attempt to overdraw currency [unit=" + unit + ", delta=" + delta + ", balance=" + balance + "]");
               }
            }
            else
            {
               ErrorManager.addError("Attempt to update undefined currency: " + unit);
            }
         }
         return result;
      }
      
      public function getWorldCurrencyTotal(unit:String) : Number
      {
         var result:Number = 0;
         if(unit == Currency.GOLD || unit == Currency.COINS)
         {
            result = this.gold;
         }
         else if(null != this.m_worldCurrencies[unit] && null != this.m_worldCurrencies[unit][Player.BALANCE_TOTAL])
         {
            result = Number(this.m_worldCurrencies[unit][Player.BALANCE_TOTAL]);
         }
         return result;
      }
      
      public function deductWorldCurrencyCount(unit:String, count:Number) : void
      {
         var currCount:Number = 0;
         if(null != this.m_worldCurrencies[unit] && null != this.m_worldCurrencies[unit][Player.BALANCE_TOTAL])
         {
            currCount = Number(this.m_worldCurrencies[unit][Player.BALANCE_TOTAL]);
            this.m_worldCurrencies[unit][Player.BALANCE_TOTAL] = currCount - count;
         }
         this.conditionallyUpdateHUD();
      }
      
      public function resetWorldCurrency(unit:String) : void
      {
         if(this.m_worldCurrencies != null && this.m_worldCurrencies[unit] != null)
         {
            this.m_worldCurrencies[unit][Player.BALANCE_TOTAL] = 0;
            this.m_worldCurrencies[unit][Player.BALANCE_EARNED] = 0;
            this.m_worldCurrencies[unit][Player.BALANCE_PURCHASED] = 0;
         }
      }
      
      public function get currentWorldCurrencyTotal() : Number
      {
         var currencyUnit:String = Global.worldManager.getCurrentHudCurrencyUnit();
         return this.getWorldCurrencyTotal(currencyUnit);
      }
      
      public function addWorldScore(scoreUnit:String, delta:int, applyBuff:Boolean = false) : int
      {
         var currentLevel:int = 0;
         var maxLevel:int = 0;
         var nextLevel:int = 0;
         var multiplier:int = 0;
         var levelData:LevelData = null;
         var levelPointer:int = 0;
         var result:int = -1;
         if(Global.worldScoreSettingsManager.isEnabled(scoreUnit))
         {
            if(delta > -1)
            {
               if(applyBuff)
               {
                  multiplier = BPermanentTypeGain.getCurrentGainBonus(scoreUnit + BPermanentTypeGain.SUBTYPE_SUFIX);
                  delta *= multiplier;
               }
               if(!this.m_worldScores.hasOwnProperty(scoreUnit))
               {
                  this.m_worldScores[scoreUnit] = {};
                  this.m_worldScores[scoreUnit][Player.SCORE] = 0;
                  this.m_worldScores[scoreUnit][Player.LEVEL] = 1;
               }
               this.m_worldScores[scoreUnit][Player.SCORE] += delta;
               currentLevel = int(this.m_worldScores[scoreUnit][Player.LEVEL]);
               maxLevel = Global.farmGameSettingsManager.getInt("maxWorldLevel",150);
               nextLevel = Global.worldScoreSettingsManager.getLevelForScore(scoreUnit,this.m_worldScores[scoreUnit][Player.SCORE],currentLevel);
               if(nextLevel > currentLevel)
               {
                  for(levelPointer = currentLevel + 1; levelPointer <= nextLevel; levelPointer++)
                  {
                     levelData = Global.worldScoreSettingsManager.getLevelDataForScoreUnit(scoreUnit,levelPointer);
                     levelData.applyRewards();
                     this.m_worldScores[scoreUnit][Player.LEVEL] = levelData.levelNumber;
                     result = levelData.levelNumber;
                  }
                  TransactionManager.addTransaction(new TWorldScoreLevelUp(scoreUnit,result),true);
                  if(result <= maxLevel)
                  {
                     UI.displayWorldScoreLevelUpDialog(scoreUnit,result);
                  }
               }
               if(Global.flashHotParams["MP_NEW_WORLD_SCORE_LEADERBOARD_UPDATE"])
               {
                  LeaderboardManager.updateWorldScoreTasks(scoreUnit,delta);
               }
               Global.hud.conditionallyRefreshHUD(true);
            }
            else
            {
               ErrorManager.addError("Attempt to add a negative amount to " + scoreUnit);
            }
         }
         else if(this.m_worldScores.hasOwnProperty(scoreUnit))
         {
            result = int(this.m_worldScores[scoreUnit][Player.LEVEL]);
         }
         return result;
      }
      
      public function resetWorldScore(scoreUnit:String) : void
      {
         if(this.m_worldScores != null && this.m_worldScores.hasOwnProperty(scoreUnit))
         {
            this.m_worldScores[scoreUnit] = {};
            this.m_worldScores[scoreUnit][Player.SCORE] = 0;
            this.m_worldScores[scoreUnit][Player.LEVEL] = 1;
         }
      }
      
      public function getWorldLevel(scoreUnit:String) : int
      {
         var result:int = WorldManager.INVALID_EXP_SCORE_LEVEL;
         if(this.m_worldScores.hasOwnProperty(scoreUnit) && Boolean(this.m_worldScores[scoreUnit].hasOwnProperty(Player.LEVEL)))
         {
            result = int(this.m_worldScores[scoreUnit][Player.LEVEL]);
         }
         return result;
      }
      
      public function get currentMOTD() : Object
      {
         return this.m_currentMOTD;
      }
      
      public function set currentMOTD(motd:Object) : void
      {
         this.m_currentMOTD = motd;
      }
      
      private function saveMotdSeverArrayAsHash(severMotdsObject:Object) : void
      {
         var seenFlag:String = null;
         this.m_motdSeenFlags = {};
         for each(seenFlag in severMotdsObject)
         {
            this.m_motdSeenFlags[seenFlag] = true;
         }
      }
      
      public function isMotdSeenFlagSet(motdSeenFlag:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_motdSeenFlags) && this.m_motdSeenFlags.hasOwnProperty(motdSeenFlag))
         {
            result = true;
         }
         return result;
      }
      
      public function setMotdSeenFlag(motdSeenFlag:String) : void
      {
         if(Boolean(this.m_motdSeenFlags) && !this.m_motdSeenFlags.hasOwnProperty(motdSeenFlag))
         {
            this.m_motdSeenFlags[motdSeenFlag] = true;
         }
      }
      
      public function get totalCashPurchased() : int
      {
         return this.m_cashPurchasedTotal;
      }
      
      public function get initialCashPurchasedTransactions() : int
      {
         return this.m_initialCashPurchaseTransactions;
      }
      
      public function get initialCPATransactions() : int
      {
         return this.m_initialCPATransactions;
      }
      
      public function set fertilizer(amount:int) : void
      {
         this.m_fertilizer = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function set queuedFertilizer(amount:int) : void
      {
         this.m_queuedFertilizer = amount;
      }
      
      public function set totalFertilizer(amount:int) : void
      {
         this.m_totalFertilizer = amount;
      }
      
      public function get fertilizer() : int
      {
         return this.m_fertilizer;
      }
      
      public function get queuedFertilizer() : int
      {
         return this.m_queuedFertilizer;
      }
      
      public function get totalFertilizer() : int
      {
         return this.m_totalFertilizer;
      }
      
      public function set animalFood(amount:int) : void
      {
         this.m_animalFood = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function set queuedAnimalFood(amount:int) : void
      {
         this.m_queuedAnimalFood = amount;
      }
      
      public function get animalFood() : int
      {
         return this.m_animalFood;
      }
      
      public function get turboChargers() : int
      {
         return this.m_turboChargers;
      }
      
      public function get lonelyAnimalCode() : String
      {
         return this.m_lonelyAnimalCode;
      }
      
      public function set turboChargers(amount:int) : void
      {
         if(amount > this.m_turboChargers || !InfiniteTurboManager.isEnabledInCurrentWorld())
         {
            this.m_turboChargers = amount;
         }
         TurboPPHManager.getInstance().turboCountChanged();
      }
      
      public function hasEnoughTurbos(amount:int) : Boolean
      {
         return this.m_turboChargers >= amount || InfiniteTurboManager.isEnabledInCurrentWorld();
      }
      
      public function get queuedAnimalFood() : int
      {
         return this.m_queuedAnimalFood;
      }
      
      public function set energy(amount:int) : void
      {
         this.m_energy = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function get energy() : int
      {
         return this.m_energy;
      }
      
      public function set nanPid(id:String) : void
      {
         this.m_nanPid = id;
      }
      
      public function get nanPid() : String
      {
         return this.m_nanPid;
      }
      
      public function set energyMax(amount:int) : void
      {
         this.m_energyMax = amount;
         this.conditionallyUpdateHUD();
      }
      
      public function get energyMax() : int
      {
         return this.m_energyMax;
      }
      
      public function set fbEventStatusList(statusList:Object) : void
      {
         this.m_fbEventRsvpStatusList = statusList;
      }
      
      public function hasJoinedFbEvent(eventId:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_fbEventRsvpStatusList) && this.m_fbEventRsvpStatusList.hasOwnProperty(eventId))
         {
            result = Boolean(this.m_fbEventRsvpStatusList.eventId);
         }
         return result;
      }
      
      public function set smartSystemCraftShopConfig(config:Object) : void
      {
         if(config != null)
         {
            this.m_smartSystemCraftShopConfig = new SmartSystemData(config);
         }
      }
      
      public function getSmartSystemCraftShopConfig() : SmartSystemData
      {
         return this.m_smartSystemCraftShopConfig;
      }
      
      public function set smartSystemCraftingCottageConfig(config:Object) : void
      {
         if(config != null)
         {
            this.m_smartSystemCraftingCottageConfig = new SmartSystemData(config);
         }
      }
      
      public function getSmartSystemCraftingCottageConfig() : SmartSystemData
      {
         return this.m_smartSystemCraftingCottageConfig;
      }
      
      public function getSmartSystemFarmStandConfig() : SmartSystemData
      {
         return this.m_smartSystemFarmStandConfig;
      }
      
      public function set smartSystemFarmStandConfig(config:Object) : void
      {
         if(config != null)
         {
            this.m_smartSystemFarmStandConfig = new SmartSystemData(config);
         }
      }
      
      public function get progressBarData() : Object
      {
         return this.m_progressBarData;
      }
      
      public function set progressBarData(obj:Object) : void
      {
         this.m_progressBarData = obj;
      }
      
      public function get options() : Object
      {
         return this.m_options;
      }
      
      public function set options(obj:Object) : void
      {
         this.m_options = obj;
      }
      
      public function isSfxDisabled() : Boolean
      {
         return !this.options.hasOwnProperty("sfxDisabled") || Boolean(Global.player.options.sfxDisabled);
      }
      
      public function isMusicDisabled() : Boolean
      {
         return !this.options.hasOwnProperty("musicDisabled") || Boolean(Global.player.options.musicDisabled);
      }
      
      public function isAnimationDisabled() : Boolean
      {
         return !this.options.hasOwnProperty("animationDisabled") || Boolean(Global.player.options.animationDisabled);
      }
      
      public function get buffs() : Dictionary
      {
         return this.m_buffs;
      }
      
      public function set buffs(buffs:Dictionary) : void
      {
         this.m_buffs = buffs;
      }
      
      public function get inInactiveExp() : int
      {
         return this.m_inactiveExp;
      }
      
      public function set incrementalGateArray(obj:Object) : void
      {
         this.m_incrementalGateArray = obj;
      }
      
      public function get incrementalGateArray() : Object
      {
         return this.m_incrementalGateArray;
      }
      
      public function get neighborPlumbingAddExcludeList() : Object
      {
         return this.m_neighborPlumbingAddExcludeList;
      }
      
      public function hasBuffApplied(buff:Buff) : Boolean
      {
         var buffName:String = null;
         var result:Boolean = false;
         var buffItem:FarmItem = buff.getItem();
         if(buffItem != null)
         {
            buffName = buffItem.name;
            if(Boolean(this.m_buffs) && Boolean(this.m_buffs.hasOwnProperty(buffName)) && Boolean(this.m_buffs[buffName].hasOwnProperty("time")) && this.m_buffs[buffName].time > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function applyAllBuffs() : void
      {
         var buffItemName:String = null;
         var buffItem:FarmItem = null;
         var buffClass:String = null;
         var tempClass:Class = null;
         var buff:Buff = null;
         for(buffItemName in this.m_buffs)
         {
            buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
            if(buffItem != null)
            {
               buffClass = buffItem.className;
               tempClass = getDefinitionByName("Classes.buffs." + buffClass) as Class;
               buff = new tempClass(buffItemName);
               if(buff)
               {
                  buff.apply();
               }
               GlobalEngine.log("Buffs",buffClass + ": " + this.m_buffs[buffItemName]);
            }
         }
      }
      
      public function expireBuffs() : void
      {
         var buffItemName:String = null;
         var buffItem:FarmItem = null;
         var buffClass:String = null;
         var tempClass:Class = null;
         var buff:Buff = null;
         if(GlobalEngine.isServerTimeValid() && GlobalEngine.serverTime > this.m_nextExpireBuffs)
         {
            this.m_nextExpireBuffs = GlobalEngine.serverTime + EXPIRE_BUFFS_INTERVAL;
            for(buffItemName in this.m_buffs)
            {
               buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
               if(buffItem != null)
               {
                  buffClass = buffItem.className;
                  tempClass = getDefinitionByName("Classes.buffs." + buffClass) as Class;
                  buff = new tempClass(buffItemName);
                  if(Boolean(buff) && buff.isExpired())
                  {
                     buff.unapply();
                  }
                  else
                  {
                     buff.tick();
                  }
               }
            }
         }
      }
      
      public function getBuffItemsByClass(desiredBuffClass:Class, subtype:String = null) : Array
      {
         var buffItemName:String = null;
         var buffItem:FarmItem = null;
         var buffClassName:String = null;
         var buffClass:Class = null;
         var result:Array = new Array();
         for(buffItemName in this.m_buffs)
         {
            buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
            buffClassName = buffItem.className;
            buffClass = getDefinitionByName("Classes.buffs." + buffClassName) as Class;
            if(buffClass == desiredBuffClass && this.checkBuffSubType(subtype,buffItem))
            {
               result.push(buffItem);
            }
         }
         return result;
      }
      
      public function checkBuffSubType(subtype:String, buffItem:FarmItem) : Boolean
      {
         var itemSubtype:String = FarmGameSettingsManager.isInDataSourceExperiment() ? buffItem.getStringFromDataSource("subtype") : buffItem.xml.attribute("subtype");
         var subtypeDefined:Boolean = Boolean(subtype) && Boolean(itemSubtype);
         return subtypeDefined ? itemSubtype == subtype : true;
      }
      
      public function getBuffsByClass(desiredBuffClass:Class) : Array
      {
         var buffItemName:String = null;
         var buffItem:FarmItem = null;
         var buffClassName:String = null;
         var buffClass:Class = null;
         var buff:Buff = null;
         var result:Array = new Array();
         for(buffItemName in this.m_buffs)
         {
            buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
            buffClassName = buffItem.className;
            buffClass = getDefinitionByName("Classes.buffs." + buffClassName) as Class;
            if(buffClass == desiredBuffClass)
            {
               buff = new buffClass(buffItemName);
               result.push(buff);
            }
         }
         return result;
      }
      
      public function set hasSeenNoPottingShedFlow(hasSeen:Boolean) : void
      {
         this.m_hasSeenNoPottingShedFlow = hasSeen;
      }
      
      public function get hasSeenNoPottingShedFlow() : Boolean
      {
         return this.m_hasSeenNoPottingShedFlow;
      }
      
      public function canShowHarvestBuildingFeed(buildingName:String) : Boolean
      {
         return this.m_showBuyHarvestBuildingFeed[buildingName];
      }
      
      public function setCanShowHarvestBuildingFeed(buildingName:String, show:Boolean) : void
      {
         this.m_showBuyHarvestBuildingFeed[buildingName] = show;
      }
      
      public function resetSeenFlags() : void
      {
         this.m_seenFlags = {};
      }
      
      public function getSeenFlag(flagName:String) : Boolean
      {
         return this.m_seenFlags[flagName];
      }
      
      public function setSeenFlag(flagName:String, performImmediately:Boolean = false, setOnClientOnly:Boolean = false) : void
      {
         if(this.m_seenFlags[flagName] != true)
         {
            if(!setOnClientOnly)
            {
               TransactionManager.addTransaction(new TSetSeenFlag(flagName),performImmediately);
            }
            this.m_seenFlags[flagName] = true;
         }
      }
      
      public function resetSeenFlag(flagName:String, performImmediately:Boolean = false, setOnClientOnly:Boolean = false) : void
      {
         if(this.m_seenFlags[flagName] == true)
         {
            if(!setOnClientOnly)
            {
               TransactionManager.addTransaction(new TResetSeenFlag(flagName),performImmediately);
            }
            this.m_seenFlags[flagName] = false;
         }
      }
      
      public function resetSeenFlagTravelWindowSorting() : void
      {
         if(this.m_seenFlags[TravelWindow.TRAVEL_WINDOW_SORTING_KEY] == true)
         {
            TransactionManager.addTransaction(new TGenericTransaction("UserService","resetSeenFlagTravelWindowSorting",null));
            this.m_seenFlags[TravelWindow.TRAVEL_WINDOW_SORTING_KEY] = false;
         }
      }
      
      public function setSeenFlagAdmin(flagName:String, seen:Boolean = true) : void
      {
         if(seen)
         {
            this.m_seenFlags[flagName] = true;
         }
         else
         {
            delete this.m_seenFlags[flagName];
         }
      }
      
      public function getItemFlag(flagName:String) : String
      {
         return this.m_itemFlags[flagName];
      }
      
      public function get itemFlags() : Object
      {
         return this.m_itemFlags;
      }
      
      public function setItemFlag(flagName:String, flagValue:String, performImmediately:Boolean = false) : void
      {
         if(this.m_itemFlags[flagName] != flagValue)
         {
            TransactionManager.addTransaction(new TSetItemFlag(flagName,flagValue),performImmediately);
            this.m_itemFlags[flagName] = flagValue;
         }
      }
      
      public function getSeenSessionFlag(flag:String) : Boolean
      {
         return this.m_seenSessionFlags[flag];
      }
      
      public function setSeenSessionFlag(flag:String, value:Boolean = true) : void
      {
         this.m_seenSessionFlags[flag] = value;
      }
      
      public function getFeatureLastShown(feature:String) : Number
      {
         var lastShownTime:Number = 0;
         if(this.m_featureFrequency.hasOwnProperty(feature))
         {
            lastShownTime = Number(this.m_featureFrequency[feature]);
         }
         return lastShownTime;
      }
      
      public function resetFeaturesLastShown() : void
      {
         this.m_featureFrequency = new Object();
      }
      
      public function setFeatureLastShown(feature:String, time:Number, updateServer:Boolean) : void
      {
         this.m_featureFrequency[feature] = time;
         if(updateServer)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(feature));
         }
      }
      
      public function canShowFeatureWithFeatureFrequency(feature:String, timeInteval:int) : Boolean
      {
         return this.canShowFeatureWithFeatureFrequencyInSeconds(feature,timeInteval * FarmGameUtil.NUM_SECS_IN_DAY);
      }
      
      public function canShowFeatureWithFeatureFrequencyInSeconds(feature:String, timeInterval:Number) : Boolean
      {
         var lastShownTimeStamp:Number = Global.player.getFeatureLastShown(feature);
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShownTimeStamp >= timeInterval;
      }
      
      public function checkSeenExtendedPermissions(category:String, updateSeenFlag:Boolean = true) : Boolean
      {
         var seenPermissions:Boolean = true;
         var flag:String = "perm_" + category;
         if(!this.getSeenFlag(flag))
         {
            seenPermissions = false;
            if(updateSeenFlag)
            {
               this.setSeenFlag(flag);
            }
         }
         return seenPermissions;
      }
      
      public function numLimitedItems(type:String) : int
      {
         return this.m_limitedItems[type];
      }
      
      public function hasLimitedItem(type:String) : Boolean
      {
         return this.m_limitedItems[type] != undefined && this.m_limitedItems[type] > 0;
      }
      
      public function addLimitedItem(itemName:String, addItemsFromGroup:Boolean = true) : void
      {
         if(this.m_limitedItems.hasOwnProperty(itemName) && this.m_limitedItems[itemName] > 0)
         {
            this.m_limitedItems[itemName] += 1;
         }
         else
         {
            this.m_limitedItems[itemName] = 1;
         }
      }
      
      public function removeLimitedItem(type:String, removeItemsFromGroup:Boolean = true) : void
      {
         if(Boolean(this.m_limitedItems[type]) && this.m_limitedItems[type] > 0)
         {
            this.m_limitedItems[type] = this.m_limitedItems[type] - 1;
         }
      }
      
      public function addGiftData(data:Array, key:String) : void
      {
         var storageItem:StorageItem = StorageItem.getStorageItem(key,data);
         if(Boolean(storageItem) && !storageItem.isEmpty())
         {
            if(Boolean(storageItem.item) && Boolean(storageItem.item.className) && storageItem.item.className == "CSeedPackage")
            {
               this.addSeedItem(storageItem);
            }
            else
            {
               this.addGiftItem(storageItem);
            }
         }
      }
      
      public function getGiftStorageItem(itemCode:String) : StorageItem
      {
         return this.m_gifts[itemCode] as StorageItem;
      }
      
      public function getLastGiftMetadataIndex(itemCode:String) : Number
      {
         var index:Number = INVALID_META_DATA_INDEX;
         var storageItem:StorageItem = this.m_gifts[itemCode] as StorageItem;
         if(storageItem != null)
         {
            index = storageItem.getAllExtraData().length - 1;
         }
         return index;
      }
      
      public function removeLastGiftMetadataIndex(itemCode:String) : void
      {
         var storageItem:StorageItem = this.m_gifts[itemCode] as StorageItem;
         if(storageItem != null)
         {
            storageItem.getAllExtraData().pop();
            ++this.m_giftsVersion;
         }
      }
      
      public function addGiftItem(storageItem:StorageItem) : void
      {
         var existingItem:StorageItem = null;
         if(this.m_gifts[storageItem.itemKey] != null)
         {
            existingItem = this.m_gifts[storageItem.itemKey] as StorageItem;
            existingItem.adjustQuantity(storageItem.quantity);
         }
         else
         {
            this.m_gifts[storageItem.itemKey] = storageItem;
         }
         ++this.m_giftsVersion;
      }
      
      public function addMutableItemToGiftbox(itemCode:String, mutableState:String, quantity:Number = 1) : void
      {
         var existingItem:StorageItem = null;
         var storageItem:StorageItem = new StorageItem(itemCode);
         storageItem.adjustQuantity(quantity);
         if(this.m_gifts[storageItem.itemKey] != null)
         {
            existingItem = this.m_gifts[storageItem.itemKey] as StorageItem;
            existingItem.adjustQuantity(storageItem.quantity);
         }
         else
         {
            this.m_gifts[storageItem.itemKey] = storageItem;
         }
         if(mutableState != null)
         {
            (this.m_gifts[storageItem.itemKey] as StorageItem).addExtraData(mutableState);
         }
         ++this.m_giftsVersion;
      }
      
      public function addUgcItemToGiftbox(name:String, senderId:String, ugcUuid:String, ugcState:String) : void
      {
         var ugcItemDef:UGCItemDefinition = null;
         var ugcItemState:UGCItemState = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         var itemCode:String = item.code;
         if(Boolean(ugcState) && ugcState.length > 0)
         {
            ugcItemState = UGCItemState.createFromServerState(ugcState);
         }
         else
         {
            ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(name);
            ugcItemState = UGCItemState.createFromDefinition(ugcItemDef);
            ugcItemState.insertInitialUuid(ugcUuid);
         }
         this.ugcItemData.addUGCItemState(ugcItemState);
         var storageItem:StorageItem = this.m_gifts[itemCode] as StorageItem;
         if(storageItem == null)
         {
            storageItem = new StorageItem(itemCode);
            this.m_gifts[itemCode] = storageItem;
         }
         storageItem.add([senderId],[ugcUuid]);
         ++this.m_giftsVersion;
         Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
      }
      
      public function addUgcDragonToGiftbox(ugcState:Object) : void
      {
         var itemCode:String = null;
         var ugcUUID:String = null;
         var storageItem:StorageItem = null;
         var ugcItemState:UGCItemState = null;
         if(ugcState)
         {
            ugcItemState = UGCItemState.createFromServerState(ugcState);
            this.ugcItemData.addUGCItemState(ugcItemState);
            itemCode = ugcItemState.itemCode;
            ugcUUID = ugcItemState.uuid;
            storageItem = this.m_gifts[itemCode] as StorageItem;
            if(storageItem == null)
            {
               storageItem = new StorageItem(itemCode);
               storageItem.quantity = 1;
               this.m_gifts[itemCode] = storageItem;
            }
            else
            {
               storageItem.adjustQuantity(1);
            }
            storageItem.addExtraData(ugcUUID);
            ++this.m_giftsVersion;
            Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
         }
      }
      
      public function addSeedItem(storageItem:StorageItem) : void
      {
         var existingItem:StorageItem = null;
         if(this.m_seeds[storageItem.itemKey])
         {
            existingItem = this.m_seeds[storageItem.itemKey] as StorageItem;
            existingItem.adjustQuantity(storageItem.quantity);
         }
         else
         {
            this.m_seeds[storageItem.itemKey] = storageItem;
         }
      }
      
      public function useSeed(seedName:String) : void
      {
         var seedPackageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(seedName + "_seedpackage");
         if(seedPackageItem)
         {
            if(Boolean(this.seeds[seedPackageItem.code]) && this.seeds[seedPackageItem.code].quantity > 1)
            {
               (this.seeds[seedPackageItem.code] as StorageItem).adjustQuantity(-1);
            }
            else if(this.seeds[seedPackageItem.code])
            {
               delete this.seeds[seedPackageItem.code];
            }
         }
      }
      
      public function hasSeed(seedName:String) : Boolean
      {
         var hasSeed:Boolean = false;
         var seedPackageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(seedName + "_seedpackage");
         if(Boolean(seedPackageItem) && Boolean(this.seeds[seedPackageItem.code]) && this.seeds[seedPackageItem.code].quantity > 0)
         {
            hasSeed = true;
         }
         return hasSeed;
      }
      
      public function countSeeds(seedName:String) : int
      {
         var result:int = 0;
         var seedPackageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(seedName + "_seedpackage");
         if(Boolean(seedPackageItem) && Boolean(this.seeds[seedPackageItem.code]))
         {
            result = int(this.seeds[seedPackageItem.code].quantity);
         }
         return result;
      }
      
      public function getPromo(promotion:String) : Object
      {
         var result:Object = null;
         if(Boolean(promotion != "") && Boolean(this.m_promos) && Boolean(this.m_promos[promotion]))
         {
            result = this.m_promos[promotion];
         }
         return result;
      }
      
      public function getAllPromos() : Object
      {
         return this.m_promos;
      }
      
      public function set seedWishData(data:Object) : void
      {
         this.m_seedWishData = data;
      }
      
      public function get seedWishData() : Object
      {
         return this.m_seedWishData;
      }
      
      public function set seeds(seeds:Dictionary) : void
      {
         this.m_seeds = seeds;
      }
      
      public function get seeds() : Dictionary
      {
         return this.m_seeds;
      }
      
      public function set gifts(gifts:Dictionary) : void
      {
         this.m_gifts = gifts;
         ++this.m_giftsVersion;
      }
      
      public function get gifts() : Dictionary
      {
         return this.m_gifts;
      }
      
      public function get giftsVersion() : int
      {
         return this.m_giftsVersion;
      }
      
      public function loadInventoryFromStorageData(storageDataIn:Object) : void
      {
         var inventoryId:Number = NaN;
         var currentInventory:Dictionary = null;
         var rawInventoryData:Object = null;
         var itemCode:String = null;
         var metaData:Array = null;
         var rawInventoryItemData:Object = null;
         var inventoryItem:StorageItem = null;
         var index:String = null;
         var inventoryIds:Array = WorldManager.WORLD_INVENTORY_IDS;
         this.m_inventory = new Dictionary();
         for each(inventoryId in inventoryIds)
         {
            currentInventory = new Dictionary();
            rawInventoryData = storageDataIn[inventoryId];
            if(rawInventoryData)
            {
               for(itemCode in rawInventoryData)
               {
                  rawInventoryItemData = rawInventoryData[itemCode];
                  if(rawInventoryItemData is Array)
                  {
                     metaData = rawInventoryItemData as Array;
                  }
                  else
                  {
                     metaData = new Array();
                     for(index in rawInventoryItemData)
                     {
                        metaData[Number(index)] = rawInventoryItemData[index];
                     }
                  }
                  inventoryItem = StorageItem.getStorageItem(itemCode,metaData);
                  if(!inventoryItem)
                  {
                     FarmStatsManager.count("FLASH_ERROR","badInventoryCode",itemCode);
                  }
                  else if(inventoryItem.quantity > 0)
                  {
                     currentInventory[inventoryItem.itemKey] = inventoryItem;
                  }
               }
            }
            this.m_inventory[inventoryId] = currentInventory;
         }
      }
      
      public function set achievements(achievements:Object) : void
      {
         this.m_achievements = achievements;
      }
      
      public function get achievements() : Object
      {
         return this.m_achievements;
      }
      
      public function set achCounters(achCounters:Object) : void
      {
         this.m_achCounters = achCounters;
      }
      
      public function get achCounters() : Object
      {
         return this.m_achCounters;
      }
      
      public function set mastery(mastery:Object) : void
      {
         this.m_mastery = mastery;
      }
      
      public function get mastery() : Object
      {
         return this.m_mastery;
      }
      
      public function set masteryCounters(masteryCounters:Object) : void
      {
         this.m_masteryCounters = masteryCounters;
      }
      
      public function get masteryCounters() : Object
      {
         return this.m_masteryCounters;
      }
      
      public function set organicCounters(organicCounters:Object) : void
      {
         this.m_organicCounters = organicCounters;
      }
      
      public function get organicCounters() : Object
      {
         return this.m_organicCounters;
      }
      
      public function set organicCertificationTotal(total:int) : void
      {
         this.m_organicCertificationTotal = total;
      }
      
      public function get organicCertificationTotal() : int
      {
         return this.m_organicCertificationTotal;
      }
      
      public function set pendingMasteryCounters(pendingMasteryCounters:Object) : void
      {
         this.m_pendingMasteryCounters = pendingMasteryCounters;
      }
      
      public function get pendingMasteryCounters() : Object
      {
         return this.m_pendingMasteryCounters;
      }
      
      public function get upgradeStatus() : Object
      {
         return this.m_pendingUpgrades;
      }
      
      public function set upgradeStatus(info:Object) : void
      {
         this.m_pendingUpgrades = info;
      }
      
      public function set collectionCounters(collectionCounters:Object) : void
      {
         this.m_collectionCounters = collectionCounters;
      }
      
      public function get collectionCounters() : Object
      {
         return this.m_collectionCounters;
      }
      
      public function set storedCollections(stored:Object) : void
      {
         this.m_storedCollections = stored;
      }
      
      public function set collectionLevels(stored:Object) : void
      {
         this.m_collectionLevels = stored;
      }
      
      public function get storedCollections() : Object
      {
         return this.m_storedCollections;
      }
      
      public function get collectionLevels() : Object
      {
         return this.m_collectionLevels;
      }
      
      public function get numOpenedPresents() : int
      {
         return this.m_numOpenedPresents;
      }
      
      public function set numOpenedPresents(amount:int) : void
      {
         this.m_numOpenedPresents = amount;
      }
      
      public function set isFarmvilleFan(isFan:int) : void
      {
         this.m_isFarmvilleFan = isFan;
      }
      
      public function get isFarmvilleFan() : int
      {
         return this.m_isFarmvilleFan;
      }
      
      public function get lastHorseStableSendTime() : Number
      {
         return this.m_lastHorseStableSendTime;
      }
      
      public function set lastHorseStableSendTime(time:Number) : void
      {
         this.m_lastHorseStableSendTime = time;
      }
      
      public function get lastFrenchChateauSendTime() : Number
      {
         return this.m_lastFrenchChateauSendTime;
      }
      
      public function set lastFrenchChateauSendTime(time:Number) : void
      {
         this.m_lastFrenchChateauSendTime = time;
      }
      
      public function get lastNurserySendTime() : Number
      {
         return this.m_lastNurserySendTime;
      }
      
      public function set lastNurserySendTime(time:Number) : void
      {
         this.m_lastNurserySendTime = time;
      }
      
      public function get picture() : String
      {
         return this.snUser.picture;
      }
      
      public function get avatar() : FarmAvatar
      {
         return this.m_avatar;
      }
      
      public function set avatar(newAvatar:FarmAvatar) : void
      {
         this.m_avatar = newAvatar;
         this.determineAvatarVisibility();
      }
      
      public function determineAvatarVisibility() : void
      {
         if(this.m_avatar != null)
         {
            if(!this.m_avatarVisible || NPCManager.getInstance().isVisitingNPC)
            {
               this.m_avatar.hideAvatar();
            }
            else
            {
               this.m_avatar.showAvatar();
            }
         }
      }
      
      public function get avatarData() : Object
      {
         var result:Object = null;
         if(this.m_avatar)
         {
            result = this.m_avatar.getAvatarCustomizationData();
         }
         else
         {
            result = FarmAvatar.getDefaultAvatarCustomizationData();
         }
         return result;
      }
      
      public function set avatarData(data:Object) : void
      {
         this.m_avatar.setAvatarCustomizationData(data);
      }
      
      public function get snUser() : SocialNetworkUser
      {
         return this.m_snUser;
      }
      
      public function set snUser(user:SocialNetworkUser) : void
      {
         if(user)
         {
            this.name = user.name;
            this.m_snUser = user;
            this.m_userId = user.uid;
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set name(newName:String) : void
      {
         this.m_name = newName;
      }
      
      public function get uid() : String
      {
         return this.m_userId;
      }
      
      public function set nextMarketPromos(nextPromoIndexes:Array) : void
      {
         this.m_nextMarketPromos = nextPromoIndexes;
      }
      
      public function get nextMarketPromos() : Array
      {
         return this.m_nextMarketPromos;
      }
      
      public function addAchievement(code:String, difficulty:int, link:String, updateHud:Boolean, rewardMessage:String = "", addRewardHandler:Function = null) : void
      {
         var achievement:Achievement = null;
         var giveReward:Boolean = false;
         if(this.m_shownAchievementDialogs.hasOwnProperty(code) == false || this.m_shownAchievementDialogs[code] < difficulty)
         {
            this.m_shownAchievementDialogs[code] = difficulty;
            if(this.achievements.hasOwnProperty(code) == false || this.achievements[code] < difficulty)
            {
               Global.player.updatePlayerStat(StatsDropDown.INDEX_RIBBONS,difficulty);
               this.achievements[code] = difficulty;
               if(updateHud == true)
               {
                  giveReward = true;
               }
            }
            if(TutController.hasFinishedTutorial())
            {
               achievement = Global.farmGameSettingsManager.getAchievementByCode(code);
               Global.popupManager.addInactiveUserPopup(new AchievementPopup(achievement,link,difficulty,giveReward,rewardMessage,addRewardHandler));
            }
         }
      }
      
      public function addMastery(code:String, difficulty:int, link:String, fromMultiAction:Boolean = false) : void
      {
         var masteryObject:Mastery = null;
         var seedItem:SeedItem = null;
         var superCrop:SeedItem = null;
         var showToaster:Boolean = false;
         var hasAllMasteries:Boolean = false;
         var requirement:SuperCropRequirement = null;
         var giveReward:Boolean = false;
         if(this.m_shownMasteryDialogs.hasOwnProperty(code) == false || this.m_shownMasteryDialogs[code] < difficulty)
         {
            this.m_shownMasteryDialogs[code] = difficulty;
            if(this.mastery.hasOwnProperty(code) == false || this.mastery[code] < difficulty)
            {
               Global.player.updatePlayerStat(StatsDropDown.INDEX_MASTERIES,difficulty);
               this.mastery[code] = difficulty;
               giveReward = true;
            }
            masteryObject = Global.farmGameSettingsManager.getMasteryByCode(code);
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(masteryObject.name) as SeedItem;
            if(Boolean(seedItem) && seedItem.isSuperCrop())
            {
               Global.popupManager.addInactiveUserPopup(new MasterySuperCropPopup(masteryObject,link,difficulty,giveReward));
            }
            else
            {
               if(seedItem)
               {
                  superCrop = seedItem.superCropSeedItem;
               }
               showToaster = false;
               if(superCrop)
               {
                  requirement = superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
                  if(Boolean(requirement) && Boolean(Global.player.mastery.hasOwnProperty(code)) && Global.player.mastery[code] >= requirement.level)
                  {
                     showToaster = true;
                  }
               }
               if(showToaster)
               {
                  IdleTaskQueue.getInstance().addTask(new MasteredSuperEnabledCropToasterIdleTask(seedItem,superCrop));
               }
               hasAllMasteries = masteryObject.hasAllMasteries();
               if(!fromMultiAction && this.m_masteryDialogsCounter < this.MAXIMUM_OPEN_MASTERY_DIALOGS || hasAllMasteries == true)
               {
                  if(hasAllMasteries == false)
                  {
                     ++this.m_masteryDialogsCounter;
                  }
                  Global.popupManager.addInactiveUserPopup(new MasteryLevelupWindow(masteryObject,link,difficulty,giveReward,this.decrementMasteryDialogCounter));
               }
               else
               {
                  Global.player.xp += masteryObject.xp;
                  Global.player.gold += masteryObject.gold;
               }
            }
         }
      }
      
      public function isItemOrganicCertified(itemXml:XML, itemCode:String) : Boolean
      {
         var result:Boolean = false;
         if(itemXml != null && itemXml.hasOwnProperty("organicCert"))
         {
            result = itemXml.organicCert.attribute("orgCount") <= Global.player.organicCounters[itemCode];
         }
         return result;
      }
      
      public function isItemOrganicCertifiedData(item:FarmItem, itemCode:String) : Boolean
      {
         var result:Boolean = false;
         if(item.hasPropertyInDataSource("organicCert"))
         {
            result = item.getIntFromDataSource("orgCount") <= Global.player.organicCounters[itemCode];
         }
         return result;
      }
      
      public function addOrganic(code:String, rewardLink:String = null) : void
      {
         var masteryCode:String = null;
         var itemXml:XML = null;
         var organicTag:XMLList = null;
         var dialogRewards:Array = null;
         var dialogRewardQuantities:Array = null;
         var masteryItem:FarmItem = null;
         var organicCertRewardsString:String = null;
         var organicCertRewards:Array = null;
         var numDialogRewardItems:int = 0;
         var itemExists:Boolean = false;
         var rewardItemInfoString:String = null;
         var rewardItemInfo:Array = null;
         var rewardItemCode:String = null;
         var rewardItem:FarmItem = null;
         var rewardItemCount:int = 0;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            masteryCode = Global.farmGameSettingsManager.getFarmItemByCode(code).orgReward;
         }
         else
         {
            itemXml = Global.farmGameSettingsManager.getItemXMLByCode(code);
            organicTag = itemXml.child("organicCert");
            masteryCode = organicTag.attribute("orgReward");
         }
         var organicTotal:int = ++Global.player.organicCertificationTotal;
         if(masteryCode != "")
         {
            dialogRewards = new Array();
            dialogRewardQuantities = new Array();
            dialogRewards.push(masteryCode);
            dialogRewardQuantities.push(1);
            masteryItem = Global.farmGameSettingsManager.getFarmItemByCode(masteryCode);
            if(masteryItem != null)
            {
               this.addGift(masteryItem.name);
            }
            organicCertRewardsString = Global.flashHotParams["ORGANIC_CERT_REWARDS"];
            if(organicCertRewardsString)
            {
               organicCertRewards = organicCertRewardsString.split(",");
               if(organicCertRewards)
               {
                  numDialogRewardItems = 0;
                  itemExists = false;
                  for each(rewardItemInfoString in organicCertRewards)
                  {
                     rewardItemInfo = rewardItemInfoString.split(":");
                     if(isInDataSourceExperiment)
                     {
                        itemExists = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemInfo[0]) != null;
                     }
                     else
                     {
                        itemExists = Global.farmGameSettingsManager.getItemXMLByCode(rewardItemInfo[0]) != null;
                     }
                     rewardItemCode = rewardItemInfo[0];
                     rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
                     if(itemExists && rewardItem != null && numDialogRewardItems < Global.flashHotParams["ORGANIC_CERT_TOTAL_REWARDS"])
                     {
                        rewardItemCount = int(rewardItemInfo[1]);
                        dialogRewards.push(rewardItemCode);
                        dialogRewardQuantities.push(rewardItemCount);
                        this.addGift(rewardItem.name,"0",rewardItemCount);
                        numDialogRewardItems++;
                     }
                  }
               }
            }
            UI.displayPopup(new OrganicCertificationRewardWindow(organicTotal,dialogRewards,dialogRewardQuantities));
         }
         else
         {
            ErrorManager.addError("Player.as::AddOrganic === Problem Adding organic certification to the front end organic counters in Player.as the code provided does not exist");
         }
      }
      
      public function openOrganicMiniMarket() : void
      {
         var itemList:Array = [];
         itemList.push("strawberry");
         itemList.push("blueberry");
         itemList.push("broccoli");
         itemList.push("cloud");
         itemList.push("carrot");
         itemList.push("cotton");
         itemList.push("eggplant");
         itemList.push("balletqueenflower");
         itemList.push("grapes");
         itemList.push("spinach");
         itemList.push("onion");
         itemList.push("peas");
         itemList.push("peppers");
         itemList.push("pinkbow");
         itemList.push("pumpkin");
         itemList.push("raspberry");
         itemList.push("redcorn");
         itemList.push("soybeans");
         itemList.push("tomato");
         itemList.push("wheat");
         UI.displayMiniMarketDialog(itemList,"toaster","",null,true,false,false,true);
      }
      
      public function decrementMasteryDialogCounter(decrementCounter:Boolean) : void
      {
         if(decrementCounter == true)
         {
            --this.m_masteryDialogsCounter;
         }
      }
      
      public function getMasteredCountByType(itemType:String) : Number
      {
         var masteryCount:Number = NaN;
         var item:FarmItem = null;
         var itemCode:String = null;
         if(!this.m_masteredTypeCounters[itemType])
         {
            masteryCount = 0;
            if(itemType == MasterySignStorageFilter.RECIPE_MASTERY)
            {
               masteryCount = CraftingManager.getInstance().getMasteryCount();
            }
            else
            {
               for(itemCode in this.m_mastery)
               {
                  if(this.m_mastery[itemCode] == Mastery.MASTERED_LEVEL)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     if(Boolean(item) && item.type == itemType)
                     {
                        masteryCount++;
                     }
                  }
               }
            }
            this.m_masteredTypeCounters[itemType] = masteryCount;
         }
         return this.m_masteredTypeCounters[itemType];
      }
      
      public function handleFriendSetGoal(friendSetGoals:Array) : void
      {
         var fsgObject:Object = null;
         var rewardItem:FarmItem = null;
         var itemXML:XML = null;
         var rewardName:String = null;
         var rewardCode:String = null;
         var rewardType:String = null;
         var isRewardPlaceable:Boolean = false;
         var rewardLicense:String = null;
         var avatarItem:AvatarItem = null;
         var duration:Number = NaN;
         var expirationTime:Number = NaN;
         var reward:FarmItem = null;
         var dialogMessageKey:String = null;
         var fsg:FriendSetGoal = null;
         for(var idx:int = 0; idx < friendSetGoals.length; idx++)
         {
            fsgObject = friendSetGoals[idx];
            fsg = PartyManager.getInstance().getPartyObjectByCode(fsgObject.code).goal;
            if(fsg)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  rewardName = fsg.getRewardNameForLevel(fsgObject.difficulty);
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
                  rewardCode = rewardItem.code;
                  rewardType = rewardItem.type;
                  isRewardPlaceable = rewardItem.placeable;
                  rewardLicense = rewardItem.license;
               }
               else
               {
                  rewardName = fsg.getRewardForLevel(fsgObject.difficulty).@name;
                  itemXML = Global.farmGameSettingsManager.getItemXMLByName(rewardName);
                  rewardCode = itemXML.@code;
                  rewardType = itemXML.@type;
                  isRewardPlaceable = itemXML.@placeable == true;
                  rewardLicense = itemXML.@license;
               }
               if(Boolean(itemXML) || Boolean(rewardItem))
               {
                  if(rewardType == "clothes")
                  {
                     avatarItem = Global.avatarConfigSettings.getItemById(rewardCode);
                     if(avatarItem)
                     {
                        Global.player.avatarState.grantItem(avatarItem.itemId);
                     }
                  }
                  else if(isRewardPlaceable)
                  {
                     Global.player.addGift(rewardName);
                  }
                  else if(rewardLicense)
                  {
                     duration = Global.farmGameSettingsManager.getLicenseXML(rewardLicense).duration * FarmGameUtil.NUM_MSECS_IN_DAY;
                     expirationTime = (GlobalEngine.serverTime + duration) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                     LicenseManager.getInstance().addLicense(rewardCode,expirationTime);
                  }
               }
               if(idx == friendSetGoals.length - 1)
               {
                  reward = fsg.rewardFeedItem;
                  if(null != reward)
                  {
                     dialogMessageKey = fsg.xml.@name;
                     new FriendSetGoalAchievementFeed(fsg.xml.goalFeedBundle,fsgObject.link,reward,fsg.getRequirementByLevel(fsgObject.difficulty),null,dialogMessageKey);
                  }
               }
            }
         }
      }
      
      public function initFeatureCredits(featureCredits:Object) : void
      {
         var featureName:String = null;
         var creditField:String = null;
         var worldId:String = null;
         for(worldId in featureCredits)
         {
            this.m_featureCredits[worldId] = {};
            for(featureName in featureCredits[worldId])
            {
               this.m_featureCredits[worldId][featureName] = {};
               for(creditField in featureCredits[worldId][featureName])
               {
                  this.m_featureCredits[worldId][featureName][creditField] = Number(featureCredits[worldId][featureName][creditField]);
               }
            }
         }
      }
      
      public function getFeatureCreditsData() : Object
      {
         return this.m_worldFeatureCredits;
      }
      
      public function setFeatureCreditsForWorld(worldId:String) : void
      {
         if(this.m_featureCredits[worldId] != null)
         {
            this.m_worldFeatureCredits = this.m_featureCredits[worldId];
         }
         else
         {
            this.m_worldFeatureCredits = {};
            this.m_featureCredits[worldId] = {};
         }
      }
      
      public function getFeatureCredits(featureName:String, globalCount:Boolean = false) : int
      {
         var world:String = null;
         var count:int = 0;
         if(this.m_featureCredits[Global.worldManager.currentWorldType][featureName] == null)
         {
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName] = new Object();
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName].current = 0;
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName].received = 0;
         }
         if(this.m_worldFeatureCredits[featureName] == null)
         {
            this.m_worldFeatureCredits[featureName] = new Object();
            this.m_worldFeatureCredits[featureName].current = 0;
            this.m_worldFeatureCredits[featureName].received = 0;
         }
         if(!globalCount)
         {
            if(this.m_worldFeatureCredits[featureName])
            {
               count = int(this.m_worldFeatureCredits[featureName].current);
            }
         }
         else
         {
            for each(world in WorldsConstants.ALL_WORLDS)
            {
               if(this.m_featureCredits != null && null != this.m_featureCredits[world] && Boolean(this.m_featureCredits[world][featureName]))
               {
                  count += this.m_featureCredits[world][featureName].current;
               }
            }
         }
         return count;
      }
      
      public function getFeatureCreditsReceived(featureName:String, globalCount:Boolean = false) : int
      {
         var world:String = null;
         var count:int = 0;
         if(!globalCount)
         {
            if(this.m_worldFeatureCredits[featureName])
            {
               count = int(this.m_worldFeatureCredits[featureName].received);
            }
         }
         else if(this.m_featureCredits)
         {
            for each(world in WorldsConstants.ALL_WORLDS)
            {
               if(this.m_featureCredits.hasOwnProperty(world) && Boolean(this.m_featureCredits[world].hasOwnProperty(featureName)))
               {
                  if(this.m_featureCredits[world][featureName].hasOwnProperty("received"))
                  {
                     count += this.m_featureCredits[world][featureName]["received"];
                  }
               }
            }
         }
         return count;
      }
      
      public function addFeatureCredits(featureName:String, count:int) : void
      {
         if(this.m_worldFeatureCredits[featureName])
         {
            this.m_worldFeatureCredits[featureName].current += count;
            this.m_worldFeatureCredits[featureName].received += count;
         }
         else
         {
            this.m_worldFeatureCredits[featureName] = new Object();
            this.m_worldFeatureCredits[featureName].current = count;
            this.m_worldFeatureCredits[featureName].received = count;
         }
         this.refreshFeatureCredits(featureName);
      }
      
      public function refreshFeatureCredits(featureName:String) : void
      {
         if(this.m_featureCredits[Global.worldManager.currentWorldType] == null)
         {
            this.m_featureCredits[Global.worldManager.currentWorldType] = {};
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName] = {};
         }
         if(this.m_featureCredits[Global.worldManager.currentWorldType][featureName] != null && this.m_worldFeatureCredits[featureName] != null)
         {
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName].current = this.m_worldFeatureCredits[featureName].current;
            this.m_featureCredits[Global.worldManager.currentWorldType][featureName].received = this.m_worldFeatureCredits[featureName].received;
         }
      }
      
      public function useFeatureCredits(featureName:String, count:int, globalCount:Boolean = false) : void
      {
         var world:String = null;
         var tempCount:int = 0;
         var worldArray:Array = null;
         if(!globalCount)
         {
            if(this.m_worldFeatureCredits[featureName])
            {
               this.m_worldFeatureCredits[featureName].current -= count;
            }
         }
         else
         {
            world = "";
            tempCount = count;
            worldArray = new Array();
            for each(world in WorldsConstants.ALL_WORLDS)
            {
               worldArray.push(world);
            }
            worldArray.sort(Array.CASEINSENSITIVE);
            for each(world in worldArray)
            {
               if(this.m_featureCredits != null && null != this.m_featureCredits[world] && Boolean(this.m_featureCredits[world][featureName]))
               {
                  if(this.m_featureCredits[world][featureName].current >= count)
                  {
                     this.m_featureCredits[world][featureName].current -= count;
                  }
                  else
                  {
                     count -= this.m_featureCredits[world][featureName].current;
                     this.m_featureCredits[world][featureName].current = 0;
                  }
               }
            }
         }
      }
      
      public function removeFeatureCreditsReceived(featureName:String, count:int) : void
      {
         if(this.m_worldFeatureCredits[featureName])
         {
            this.m_worldFeatureCredits[featureName].received -= count;
         }
      }
      
      public function addGift(name:String, sender:String = "0", count:int = 1) : void
      {
         var autoConsumable:AutoConsumable = null;
         var packagedItems:Object = null;
         var itemName:String = null;
         var code:String = null;
         var storageItem:StorageItem = null;
         var seedsPurchased:Number = NaN;
         var storedSeed:StorageItem = null;
         var i:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(item)
         {
            if(item is ConsumableItem && (item as ConsumableItem).isAutoConsumable())
            {
               autoConsumable = AutoConsumable.createAutoConsumable(item.name);
               for(i = 0; i < count; i++)
               {
                  autoConsumable.consume();
               }
            }
            else if(!Global.player.checkItemLimit(name) && CraftingManager.GIFTBOX_BLACKLIST_CLASSNAMES.indexOf(item.className) == -1)
            {
               packagedItems = item.getItemPackageHash();
               if(packagedItems != null)
               {
                  for(itemName in packagedItems)
                  {
                     this.addGift(itemName,sender,count * packagedItems[itemName]);
                  }
               }
               else
               {
                  code = item.code;
                  if(item.type == CBushel.BUSHEL)
                  {
                     CraftingManager.getInstance().addItemToInventory(item.code,count);
                  }
                  else if(item.className == "CSeedPackage")
                  {
                     seedsPurchased = count * Global.farmGameSettingsManager.getDefaultSeedPackageSize();
                     storedSeed = StorageItem.getStorageItem(item.code,[seedsPurchased]);
                     if(Boolean(storedSeed) && !storedSeed.isEmpty())
                     {
                        Global.player.addSeedItem(storedSeed);
                     }
                  }
                  else
                  {
                     if(this.gifts[code])
                     {
                        storageItem = this.gifts[code] as StorageItem;
                     }
                     else
                     {
                        storageItem = new StorageItem(code);
                        this.gifts[code] = storageItem;
                     }
                     storageItem.adjustQuantity(count);
                     if(sender != "0")
                     {
                        storageItem.addSenderId(sender);
                     }
                     this.setGiftItemsRecentList(code);
                     FestivalOfColorManager.getInstance().registerAnimalByCode(code);
                  }
                  Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
               }
            }
         }
      }
      
      private function setGiftItemsRecentList(code:String) : void
      {
         var newGiftItemsRecentObject:Object = null;
         var giftItemsRecent:String = null;
         var giftItemsRecentObject:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.ITEMS_RECENT,FeatureOptionsManager.GIFT_ITEMS_RECENT);
         var recentItemObj:RecentItems = new RecentItems();
         if(!giftItemsRecentObject)
         {
            recentItemObj.addRecent(code);
         }
         else
         {
            giftItemsRecentObject.push(code);
            for each(giftItemsRecent in giftItemsRecentObject)
            {
               recentItemObj.addRecent(giftItemsRecent);
            }
         }
         newGiftItemsRecentObject = recentItemObj.getRecentItems();
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.ITEMS_RECENT,FeatureOptionsManager.GIFT_ITEMS_RECENT,newGiftItemsRecentObject);
      }
      
      public function hasGiftItem(key:String) : Boolean
      {
         return this.getGiftCountForItemKey(key) > 0;
      }
      
      public function getGiftMetadata(key:String) : Object
      {
         var storageItem:StorageItem = null;
         var result:Object = null;
         if(this.gifts[key])
         {
            storageItem = this.m_gifts[key] as StorageItem;
            result = storageItem.getExtraData();
         }
         return result;
      }
      
      public function removeGift(gift:MapResource, itemName:String = "") : Boolean
      {
         var code:String = null;
         var name:String = null;
         if(gift)
         {
            if(gift is SimpleHarvestableResource)
            {
               name = (gift as SimpleHarvestableResource).getOriginalItemName();
            }
            else
            {
               name = gift.getItemName();
            }
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(name);
         }
         else
         {
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         }
         return this.removeGiftWithKey(code);
      }
      
      public function getGiftboxTrace() : Array
      {
         var result:Array = null;
         var output:Array = null;
         var gifts:Dictionary = null;
         var giftCode:Object = null;
         var storageItem:StorageItem = null;
         var farmItem:FarmItem = null;
         var line:Array = null;
         result = [];
         if(this.gifts)
         {
            try
            {
               output = [];
               gifts = Global.player.gifts;
               for(giftCode in gifts)
               {
                  if(Boolean(gifts[giftCode]) && giftCode is String)
                  {
                     storageItem = gifts[giftCode] as StorageItem;
                     farmItem = Global.farmGameSettingsManager ? Global.farmGameSettingsManager.getFarmItemByCode(giftCode as String) : null;
                     line = [giftCode,storageItem.quantity];
                     if(farmItem)
                     {
                        line.push(farmItem.name);
                     }
                     output.push(line);
                  }
               }
               result = output;
            }
            catch(e:Error)
            {
               result.push("error saving giftbox:" + e.message);
            }
         }
         return result;
      }
      
      public function removeGiftWithKey(key:String, quantity:int = 1, metaIndex:Number = -1) : Boolean
      {
         var storageItem:StorageItem = null;
         var result:Boolean = false;
         if(this.gifts[key])
         {
            result = true;
            storageItem = this.m_gifts[key] as StorageItem;
            if(metaIndex >= 0)
            {
               storageItem.adjustQuantity(-quantity,false);
               storageItem.removeExtraData(metaIndex);
            }
            else
            {
               storageItem.adjustQuantity(-quantity,true);
            }
            if(storageItem.isEmpty())
            {
               delete this.m_gifts[key];
            }
            else
            {
               storageItem.shiftSenderId();
            }
            ++this.m_giftsVersion;
            Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
         }
         return result;
      }
      
      public function removeAllGifts() : void
      {
         this.m_gifts = new Dictionary();
         ++this.m_giftsVersion;
         Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
      }
      
      protected function conditionallyUpdateHUD() : void
      {
         if(Global.hud)
         {
            Global.hud.currentWorldCurrencyAmount = this.currentWorldCurrencyTotal;
            Global.hud.cash = this.cash;
            Global.hud.level = this.level;
            Global.hud.xp = this.xp;
            Global.hud.energy = this.energy;
            Global.hud.energyMax = this.energyMax;
         }
      }
      
      public function getInventory(inventoryId:Number = 0) : Dictionary
      {
         inventoryId = inventoryId != 0 ? inventoryId : Global.worldManager.getCurrentWorldStorageId();
         var result:Dictionary = null;
         if(Boolean(this.m_inventory) && Boolean(this.m_inventory[inventoryId]))
         {
            result = this.m_inventory[inventoryId];
         }
         return result;
      }
      
      public function getInventoryItem(itemCode:String, inventoryId:Number = 0) : StorageItem
      {
         var result:StorageItem = null;
         var inventory:Dictionary = this.getInventory(inventoryId);
         if(inventory)
         {
            result = inventory[itemCode] as StorageItem;
         }
         return result;
      }
      
      public function getInventoryItemQuantity(inventoryCode:String, inventoryId:Number = 0) : int
      {
         var result:int = 0;
         var inventoryItem:StorageItem = this.getInventoryItem(inventoryCode,inventoryId);
         if(inventoryItem)
         {
            result = inventoryItem.quantity;
         }
         return result;
      }
      
      public function getInventoryItemExtraData(itemCode:String, extraDataIndex:Number = 0, inventoryId:Number = 0) : Object
      {
         var result:Object = null;
         var inventoryItem:StorageItem = this.getInventoryItem(itemCode,inventoryId);
         if(inventoryItem)
         {
            result = inventoryItem.getExtraData(extraDataIndex);
         }
         return result;
      }
      
      public function addInventoryItem(itemCode:String, extraData:Object, quantity:int = 1, inventoryId:Number = 0) : void
      {
         var storageItem:StorageItem = null;
         var existingItem:StorageItem = null;
         var text:String = null;
         var callback:Function = null;
         var inventory:Dictionary = this.getInventory(inventoryId);
         if(inventory)
         {
            storageItem = new StorageItem(itemCode);
            storageItem.adjustQuantity(quantity);
            storageItem.addExtraData(extraData);
            existingItem = this.getInventoryItem(itemCode,inventoryId);
            if(existingItem)
            {
               existingItem.adjustQuantity(storageItem.quantity);
               extraData = storageItem.getExtraData();
               if(extraData)
               {
                  existingItem.addExtraData(extraData);
               }
            }
            else
            {
               inventory[itemCode] = storageItem;
            }
            if(this.getInventoryUsage() < this.getWorldMaxInventoryCapacity() && this.getInventoryUsage() == this.getInventoryCapacity(true))
            {
               if(InventoryWithdrawal.hasUpgradableStorage())
               {
                  text = ZLocUtils.t("Dialogs","StorageTryUpgrade");
                  callback = Global.ui.onUpgradePromptClose;
               }
               else
               {
                  text = ZLocUtils.t("Dialogs","BuyMoreStoragePrompt");
                  callback = Global.ui.onBuyStoragePromptClose;
               }
               UI.displayMessage(text,GenericPopup.TYPE_YESNO,callback,"expand_prompt",true);
            }
            Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
         }
      }
      
      public function removeInventoryItem(itemCode:String, quantity:int = 1, inventoryId:int = 0) : void
      {
         var inventory:Dictionary = null;
         var inventoryItem:StorageItem = this.getInventoryItem(itemCode,inventoryId);
         if(Boolean(inventoryItem) && inventoryItem.quantity >= quantity)
         {
            inventoryItem.adjustQuantity(-quantity,true);
            if(inventoryItem.quantity <= 0)
            {
               inventory = this.getInventory(inventoryId);
               delete inventory[inventoryItem.itemKey];
            }
            Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
         }
      }
      
      public function hasInventoryItem(itemCode:String, inventoryId:int = 0) : Boolean
      {
         var result:Boolean = false;
         if(this.getInventoryItemQuantity(itemCode,inventoryId) > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function set newPlayer(isNew:Boolean) : void
      {
         this.m_isNew = isNew;
      }
      
      public function get isNewPlayer() : Boolean
      {
         return this.m_isNew;
      }
      
      public function set firstDay(isFirstDay:Boolean) : void
      {
         this.m_isFirstDay = isFirstDay;
      }
      
      public function get isFirstDay() : Boolean
      {
         return this.m_isFirstDay;
      }
      
      public function get avatarSurfacingEnabled() : Boolean
      {
         return this.m_avatarSurfacingEnabled;
      }
      
      public function get avatarSurfacingFrequency() : int
      {
         return this.m_avatarSurfacingFrequency;
      }
      
      public function get avatarSurfacingItem() : String
      {
         return this.m_avatarSurfacingItem;
      }
      
      public function set firstDayTimestamp(aFirstDayTimestamp:Number) : void
      {
         this.m_firstDayTimestamp = aFirstDayTimestamp;
      }
      
      public function get firstDayTimestamp() : Number
      {
         return this.m_firstDayTimestamp;
      }
      
      public function get accountAge() : Number
      {
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.firstDayTimestamp;
      }
      
      public function set seenRequestEmail(numSeenRequestEmail:int) : void
      {
         this.m_seenRequestEmail = numSeenRequestEmail;
      }
      
      public function get timesSeenRequestEmail() : int
      {
         return this.m_seenRequestEmail;
      }
      
      public function set hourLastSeenRequestEmail(hourSeenRequestEmail:int) : void
      {
         this.m_hourLastSeenRequestEmail = hourSeenRequestEmail;
      }
      
      public function get hoursSinceLastSeenRequestEmail() : int
      {
         return GlobalEngine.serverTime / 1000 / 60 / 60 - this.m_hourLastSeenRequestEmail;
      }
      
      public function set seenRevampEmail(numSeenRevampEmail:int) : void
      {
         this.m_seenRevampEmail = numSeenRevampEmail;
      }
      
      public function get seenRevampEmail() : int
      {
         return this.m_seenRevampEmail;
      }
      
      public function set timeLastSeenRevampEmail(timeSeenRevampEmail:int) : void
      {
         this.m_timeLastSeenRevampEmail = timeSeenRevampEmail;
      }
      
      public function get timeLastSeenRevampEmail() : int
      {
         return this.m_timeLastSeenRevampEmail;
      }
      
      public function set seenRevampProxyEmail(numSeenRevampProxyEmail:int) : void
      {
         this.m_seenRevampProxyEmail = numSeenRevampProxyEmail;
      }
      
      public function get seenRevampProxyEmail() : int
      {
         return this.m_seenRevampProxyEmail;
      }
      
      public function set timeLastSeenRevampProxyEmail(timeSeenRevampProxyEmail:int) : void
      {
         this.m_timeLastSeenRevampProxyEmail = timeSeenRevampProxyEmail;
      }
      
      public function get timeLastSeenRevampProxyEmail() : int
      {
         return this.m_timeLastSeenRevampProxyEmail;
      }
      
      public function set seenRevampLockedboxEmail(numSeenRevampLockedboxEmail:int) : void
      {
         this.m_seenRevampLockedboxEmail = numSeenRevampLockedboxEmail;
      }
      
      public function get seenRevampLockedboxEmail() : int
      {
         return this.m_seenRevampLockedboxEmail;
      }
      
      public function set timeLastSeenRevampLockedboxEmail(timeSeenRevampLockedboxEmail:int) : void
      {
         this.m_timeLastSeenRevampLockedboxEmail = timeSeenRevampLockedboxEmail;
      }
      
      public function get timeLastSeenRevampLockedboxEmail() : int
      {
         return this.m_timeLastSeenRevampLockedboxEmail;
      }
      
      public function get canRequestEmailPermission() : Boolean
      {
         return Global.experimentManager.getExperimentVariant("fv_email_permission_test") == 1;
      }
      
      public function set hasReceivedGiftForEmailPermissions(receivedGiftForEmailPermissions:Boolean) : void
      {
         this.m_hasReceivedGiftForEmailPermissions = receivedGiftForEmailPermissions;
      }
      
      public function get hasReceivedGiftForEmailPermissions() : Boolean
      {
         return this.m_hasReceivedGiftForEmailPermissions;
      }
      
      public function get farmTalkPermission() : Boolean
      {
         return this.m_farmTalkPermission;
      }
      
      public function set farmTalkPermission(givesPermission:Boolean) : void
      {
         this.m_farmTalkPermission = givesPermission;
         TransactionManager.addTransaction(new TGenericTransaction("ChatService","setChatPermission",null,[this.m_farmTalkPermission]));
      }
      
      public function setChatLastMessageReadTime(uid:String, timeStamp:Number) : void
      {
         this.m_chatLastMessageReadTime[uid] = timeStamp;
      }
      
      public function getChatLastMessageReadTime(uid:String) : Number
      {
         var timeStamp:Number = 0;
         if(this.m_chatLastMessageReadTime.hasOwnProperty(String(uid)))
         {
            timeStamp = Number(this.m_chatLastMessageReadTime[uid]);
         }
         return timeStamp;
      }
      
      public function hasEnergy(cost:int = 1, showMessage:Boolean = true) : Boolean
      {
         var canBuy:Boolean = true;
         if(!this.hasUnlimitedFuelOfferActivated())
         {
            canBuy = this.energy - cost >= 0;
         }
         if(!canBuy && showMessage)
         {
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","NotEnoughEnergy"));
         }
         return canBuy;
      }
      
      public function hasUnlimitedFuelOfferActivated() : Boolean
      {
         return LoyaltyProgramManager.getInstance().isGoldenFarmer() || this.hasNoFuelDayActive();
      }
      
      public function hasNoFuelDayActive() : Boolean
      {
         var currentTime:Number = NaN;
         var featureStartTime:Number = NaN;
         var featureEndTime:Number = NaN;
         var worldString:String = null;
         var worldList:Array = null;
         var worldArray:String = null;
         var worldDetails:Array = null;
         var worldName:String = null;
         var worldSeason:int = 0;
         var result:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_NO_FUEL_DAY);
         if(variant == 1)
         {
            currentTime = GlobalEngine.serverTime / 1000;
            featureStartTime = Number(GlobalEngine.getFlashVar("NO_FUEL_DAY_START_TIME"));
            if(!isNaN(featureStartTime) && Boolean(featureStartTime))
            {
               featureEndTime = this.noFuelEndTime();
               if(currentTime > featureStartTime && currentTime < featureEndTime)
               {
                  worldString = String(GlobalEngine.getFlashVar("NO_FUEL_DAY_WORLDS"));
                  worldList = worldString.split(",");
                  if(worldList.length > 0 && worldString != "")
                  {
                     for each(worldArray in worldList)
                     {
                        worldDetails = worldArray.split(":");
                        worldName = worldDetails[0];
                        if(Global.worldManager.currentWorldType == worldName)
                        {
                           if(!worldDetails[1])
                           {
                              result = true;
                              break;
                           }
                           worldSeason = int(worldDetails[1]);
                           if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldName) > 1)
                           {
                              if(worldSeason == WorldSeasonsManager.getInstance().getCurrentSeason(worldName))
                              {
                                 result = true;
                                 break;
                              }
                           }
                        }
                     }
                  }
                  else
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public function noFuelEndTime() : Number
      {
         var featureStartTime:Number = Number(GlobalEngine.getFlashVar("NO_FUEL_DAY_START_TIME"));
         var featureEndTimeParam:Number = Number(GlobalEngine.getFlashVar("NO_FUEL_DAY_END_TIME"));
         var featureEndTime:Number = featureStartTime + FarmGameUtil.NUM_SECS_IN_DAY;
         if(!isNaN(featureEndTimeParam) && featureEndTimeParam != 0)
         {
            featureEndTime = featureEndTimeParam;
         }
         return featureEndTime;
      }
      
      public function buyFarmItem(item:FarmItem, currency:String, quantity:int = 1, putInGiftbox:Boolean = false, giftboxShowPopup:Boolean = true, forceGift:Boolean = false, giftboxSuccessCallback:Function = null, giftboxAssumeSuccess:Boolean = false, isFromMarket:Boolean = false) : Boolean
      {
         var cash:int = 0;
         var cost:int = 0;
         var itemName:String = null;
         var popupObj:DisplayObject = null;
         var canBuy:Boolean = false;
         if(item is PetFarmItem && item.customizable)
         {
            canBuy = true;
         }
         else
         {
            switch(currency)
            {
               case Currency.CASH:
                  cash = item.realCashCost;
                  canBuy = Global.player.canBuyCash(cash * quantity,false);
                  break;
               default:
                  cost = item.saleCost > 0 ? item.saleCost : item.cost;
                  canBuy = Global.player.canBuyWithCurrency(currency,cost * quantity,true);
            }
         }
         if(canBuy)
         {
            switch(currency)
            {
               case Currency.CASH:
                  itemName = item.hasSale && Boolean(item.saleXML) ? item.saleName : item.cashName;
                  break;
               default:
                  itemName = item.hasSale && Boolean(item.saleXML) ? item.saleName : item.name;
            }
            if(putInGiftbox)
            {
               TransactionManager.addTransaction(new TBuyItemPutGiftbox(item,currency,quantity,giftboxShowPopup,forceGift,giftboxSuccessCallback,giftboxAssumeSuccess),true);
            }
            else
            {
               UI.marketTerrainCodes = item.getTerrainCodes();
               item.onBuy(itemName,{
                  "currency":currency,
                  "isFromMarket":isFromMarket
               });
            }
         }
         else if(currency == Currency.CASH)
         {
            FarmStatsManager.count("payment","in_app","mp_out_of_cash",item.type);
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",cash * quantity,item.type);
            FarmStatsManager.count("fv_cash_buy_fail","view_popup");
         }
         else if(currency == Currency.COINS)
         {
            popupObj = Global.stage.getChildByName("impulseBuyPopup");
            if(popupObj == null)
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyMarket",0,item.type);
            }
         }
         else
         {
            InGameCurrencyConversion.showImpulseBuy(currency);
         }
         return canBuy;
      }
      
      public function canBuy(cost:int, showMessage:Boolean = true, attemptedPurchaseName:String = "Other") : Boolean
      {
         var popupObj:DisplayObject = null;
         var canBuy:Boolean = this.gold >= cost;
         if(!canBuy && showMessage)
         {
            if(GlobalEngine.getFlashVar("freeCash") == 1 && Global.player.level <= Global.farmGameSettingsManager.getNumber("freeCoinsMaxLevel") && this.gold <= Global.farmGameSettingsManager.getNumber("freeCoinsCoinQualifier") && !this.m_gaveCoins)
            {
               TransactionManager.addTransaction(new TFreeCoins());
               UI.displayMessage(ZLocUtils.t("FarmGame","FreeCoinsMessage",{"quantity":Global.farmGameSettingsManager.getNumber("freeCoins")}),GenericPopup.TYPE_OK,this.freeCoinsMessageOK);
               this.m_gaveCoins = true;
               this.m_inGaveCoins = true;
            }
            else if(!this.m_inGaveCoins)
            {
               Global.player.avatar.getStateMachine().removeAllStates();
               if(!this.m_hasSeenCoinsPopup)
               {
                  popupObj = Global.stage.getChildByName("impulseBuyPopup");
                  if(popupObj == null)
                  {
                     this.setHasSeenCoinsPopup(true);
                     UI.displayPopup(new ImpulseBuy(ImpulseBuy.TYPE_COINS,attemptedPurchaseName),false,"impulseBuyPopup",true);
                  }
               }
               else
               {
                  Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","NotEnoughMoney"));
               }
            }
         }
         return canBuy;
      }
      
      public function canBuyWithCurrency(currencyUnit:String, cost:int, showMessage:Boolean = true, attemptedPurchaseName:String = "Other") : Boolean
      {
         var result:Boolean = false;
         if(currencyUnit == Currency.GOLD || currencyUnit == Currency.COINS)
         {
            result = this.canBuy(cost,showMessage,attemptedPurchaseName);
         }
         else if(this.getWorldCurrencyTotal(currencyUnit) >= cost)
         {
            result = true;
         }
         else if(showMessage)
         {
            InGameCurrencyConversion.showImpulseBuy(currencyUnit);
         }
         return result;
      }
      
      public function setHasSeenCoinsPopup(hasSeen:Boolean) : void
      {
         this.m_hasSeenCoinsPopup = hasSeen;
      }
      
      protected function freeCoinsMessageOK(event:GenericPopupEvent) : void
      {
         Global.player.gold += Global.farmGameSettingsManager.getNumber("freeCoins");
         UI.displayMessage(ZLocUtils.t("FarmGame","HarvestReminder"),GenericPopup.TYPE_OK,this.freeCoinsMessageDone);
      }
      
      protected function freeCoinsMessageDone(event:GenericPopupEvent) : void
      {
         this.m_inGaveCoins = false;
      }
      
      public function loadStatsFromPlayerObject(playa:Object) : void
      {
         var RibbonLevel:String = null;
         var MasteryLevel:String = null;
         var ribbonsSubValues:Array = null;
         var masterySubValues:Array = null;
         var medalsSubValues:Array = null;
         var statObj:Object = playa.stats;
         if(statObj)
         {
            statObj.ribbons = new Object();
            statObj.ribbons.yellow = statObj.ribbons.white = statObj.ribbons.red = statObj.ribbons.blue = statObj.ribbons.total = 0;
            statObj.masteries = new Object();
            statObj.masteries.level1 = statObj.masteries.level2 = statObj.masteries.level3 = statObj.masteries.total = 0;
            for(RibbonLevel in playa.achievements)
            {
               switch(playa.achievements[RibbonLevel])
               {
                  case 3:
                     ++statObj.ribbons.blue;
                  case 2:
                     ++statObj.ribbons.red;
                  case 1:
                     ++statObj.ribbons.white;
                  case 0:
                     ++statObj.ribbons.yellow;
               }
               statObj.ribbons.total += playa.achievements[RibbonLevel] + 1;
            }
            for(MasteryLevel in playa.mastery)
            {
               switch(playa.mastery[MasteryLevel])
               {
                  case 2:
                     ++statObj.masteries.level3;
                  case 1:
                     ++statObj.masteries.level2;
                  case 0:
                     ++statObj.masteries.level1;
               }
               statObj.masteries.total += playa.mastery[MasteryLevel] + 1;
            }
            this.m_cardStats = statObj;
            this.m_playerStatValues = [Global.farmGameSettingsManager.getLevelForXP(playa.xp),int(statObj.ribbons.total),int(statObj.masteries.total),int(statObj.medals.total),int(statObj.collections),int(statObj.buildings)];
            ribbonsSubValues = [statObj.ribbons.yellow,statObj.ribbons.white,statObj.ribbons.red,statObj.ribbons.blue];
            masterySubValues = [statObj.masteries.level1,statObj.masteries.level2,statObj.masteries.level3];
            medalsSubValues = [statObj.medals.bronze,statObj.medals.silver,statObj.medals.gold];
            this.m_playerSubStatValues = [[],ribbonsSubValues,masterySubValues,medalsSubValues,[],[]];
            if(Global.hud.m_statsDropDown != null)
            {
               Global.hud.m_statsDropDown.updateCellDisplay();
            }
         }
      }
      
      public function constructStatObject() : Object
      {
         var statObj:Object = new Object();
         statObj.collections = this.m_playerStatValues[StatsDropDown.INDEX_COLLECTIONS];
         statObj.buildings = this.m_playerStatValues[StatsDropDown.INDEX_BUILDINGS];
         statObj.ribbons = new Object();
         statObj.masteries = new Object();
         statObj.medals = new Object();
         statObj.ribbons.total = this.m_playerStatValues[StatsDropDown.INDEX_RIBBONS];
         statObj.masteries.total = this.m_playerStatValues[StatsDropDown.INDEX_MASTERIES];
         statObj.medals.total = this.m_playerStatValues[StatsDropDown.INDEX_MEDALS];
         if(this.m_playerSubStatValues[StatsDropDown.INDEX_RIBBONS].length != 0)
         {
            statObj.ribbons.yellow = this.m_playerSubStatValues[StatsDropDown.INDEX_RIBBONS][StatsDropDown.INDEX_RIBBONS_YELLOW];
            statObj.ribbons.white = this.m_playerSubStatValues[StatsDropDown.INDEX_RIBBONS][StatsDropDown.INDEX_RIBBONS_WHITE];
            statObj.ribbons.red = this.m_playerSubStatValues[StatsDropDown.INDEX_RIBBONS][StatsDropDown.INDEX_RIBBONS_RED];
            statObj.ribbons.blue = this.m_playerSubStatValues[StatsDropDown.INDEX_RIBBONS][StatsDropDown.INDEX_RIBBONS_BLUE];
            statObj.masteries.level1 = this.m_playerSubStatValues[StatsDropDown.INDEX_MASTERIES][StatsDropDown.INDEX_MASTERIES_LEVEL1];
            statObj.masteries.level2 = this.m_playerSubStatValues[StatsDropDown.INDEX_MASTERIES][StatsDropDown.INDEX_MASTERIES_LEVEL2];
            statObj.masteries.level3 = this.m_playerSubStatValues[StatsDropDown.INDEX_MASTERIES][StatsDropDown.INDEX_MASTERIES_LEVEL3];
            statObj.medals.bronze = this.m_playerSubStatValues[StatsDropDown.INDEX_MEDALS][StatsDropDown.INDEX_MEDALS_BRONZE];
            statObj.medals.silver = this.m_playerSubStatValues[StatsDropDown.INDEX_MEDALS][StatsDropDown.INDEX_MEDALS_SILVER];
            statObj.medals.gold = this.m_playerSubStatValues[StatsDropDown.INDEX_MEDALS][StatsDropDown.INDEX_MEDALS_GOLD];
         }
         else
         {
            statObj.ribbons.yellow = -1;
            statObj.ribbons.white = -1;
            statObj.ribbons.red = -1;
            statObj.ribbons.blue = -1;
            statObj.masteries.level1 = -1;
            statObj.masteries.level2 = -1;
            statObj.masteries.level3 = -1;
            statObj.medals.bronze = -1;
            statObj.medals.silver = -1;
            statObj.medals.gold = -1;
         }
         return statObj;
      }
      
      public function get statValues() : Array
      {
         return this.m_playerStatValues;
      }
      
      public function get subStatValues() : Array
      {
         return this.m_playerSubStatValues;
      }
      
      public function get cardStats() : Object
      {
         return this.m_cardStats;
      }
      
      public function get fake() : Boolean
      {
         return false;
      }
      
      public function get empty() : Boolean
      {
         return false;
      }
      
      public function get usedPhotoContest() : Boolean
      {
         return false;
      }
      
      protected function compareNeighborsStat(indexOfStat:int, indexOfSubStat:int = -1) : void
      {
         var fbs:FriendBarSlot = null;
         var friendName:String = null;
         var allStatTypes:Array = null;
         var allStatSubTypes:Array = null;
         var statType:String = null;
         var statSubType:String = null;
         for each(fbs in Global.ui.m_friendBar.slots)
         {
            if(Boolean(fbs.uid) && fbs.uid != this.snUser.uid)
            {
               if(this.m_playerStatValues[indexOfStat] != null && fbs.stats[indexOfStat] == this.m_playerStatValues[indexOfStat] - 1 || indexOfSubStat != -1 && fbs.subStats.length >= indexOfStat && fbs.subStats[indexOfStat].length >= indexOfSubStat && fbs.subStats[indexOfStat][indexOfSubStat] == this.m_playerSubStatValues[indexOfStat][indexOfSubStat] - 1)
               {
                  friendName = fbs.m_label.text;
                  allStatTypes = new Array();
                  allStatSubTypes = new Array();
                  allStatTypes = ["level","ribbons","masteries","medals","collections","buildings"];
                  allStatSubTypes = [[],["yellow","white","red","blue"],["level 1","level 2","level 3"],["bronze","silver","gold"],[],[]];
                  statType = allStatTypes[indexOfStat];
                  statSubType = "";
                  if(indexOfSubStat != -1)
                  {
                     if(fbs.stats[indexOfStat] == this.m_playerStatValues[indexOfStat] - 1)
                     {
                        indexOfSubStat = -1;
                     }
                     else
                     {
                        statSubType = allStatSubTypes[indexOfStat][indexOfSubStat];
                     }
                  }
                  if(this.m_statW2WData == null || this.m_statW2WData.statIndex as int > indexOfStat || this.m_statW2WData.statSubIndex != -1 && this.m_statW2WData.statIndex as int == indexOfStat && this.m_statW2WData.statSubIndex as int < indexOfSubStat)
                  {
                     this.m_statW2WData = new Object();
                     this.m_statW2WData.friendID = fbs.uid;
                     this.m_statW2WData.friendName = friendName;
                     this.m_statW2WData.statType = statType;
                     this.m_statW2WData.statSubType = statSubType;
                     this.m_statW2WData.statIndex = indexOfStat;
                     this.m_statW2WData.statSubIndex = indexOfSubStat;
                     if(this.m_statW2WTimer == null)
                     {
                        this.m_statW2WTimer = new Timer(5000,1);
                        this.m_statW2WTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.statsW2WTimer);
                        this.m_statW2WTimer.start();
                     }
                  }
                  break;
               }
            }
         }
      }
      
      protected function statsW2WTimer(event:Event) : void
      {
         this.m_statW2WTimer.stop();
         TransactionManager.addTransaction(new TSurpassFriendStat(this.m_statW2WData,false));
         this.m_statW2WData = null;
         this.m_statW2WTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.statsW2WTimer);
         this.m_statW2WTimer = null;
      }
      
      public function updatePlayerStat(indexOfStat:int, extraData:Number) : void
      {
         var subCellIndex:Number = -1;
         switch(indexOfStat)
         {
            case StatsDropDown.INDEX_LEVEL:
               this.m_playerStatValues[indexOfStat] = extraData;
               break;
            case StatsDropDown.INDEX_RIBBONS:
            case StatsDropDown.INDEX_MASTERIES:
            case StatsDropDown.INDEX_MEDALS:
               subCellIndex = extraData;
               this.m_playerSubStatValues[indexOfStat][subCellIndex] += 1;
               this.m_playerStatValues[indexOfStat] += 1;
               break;
            case StatsDropDown.INDEX_COLLECTIONS:
            case StatsDropDown.INDEX_BUILDINGS:
               this.m_playerStatValues[indexOfStat] += 1;
         }
         if(Global.hud.m_statsDropDown != null)
         {
            Global.hud.m_statsDropDown.updateCellDisplay();
         }
         this.compareNeighborsStat(indexOfStat,subCellIndex);
      }
      
      public function canBuyCash(cash:int, showMessage:Boolean = true, attemptedPurchaseName:String = "Other") : Boolean
      {
         var popupObj:DisplayObject = null;
         var canBuy:Boolean = this.cash - cash >= 0;
         if(!canBuy && showMessage)
         {
            popupObj = Global.stage.getChildByName("impulseBuyPopup");
            if(popupObj == null)
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",cash,attemptedPurchaseName);
            }
         }
         return canBuy;
      }
      
      public function getItemXml(worldObject:MapResource, item:FarmItem = null, itemName:String = "") : XML
      {
         var offset:int = 0;
         var itemXml:XML = null;
         if(worldObject)
         {
            if(item is BuildingItem && item.className == "CraftingCottageBuilding")
            {
               offset = Global.player.getGlobalItemInstances("CraftingCottageBuilding");
               itemXml = BuildingItem(item).getActiveXmlWithTierOffset(worldObject.getItemName(),offset);
            }
            else
            {
               itemXml = item.getActiveXml(worldObject.getItemName());
            }
         }
         else
         {
            itemXml = item.getActiveXml(itemName);
         }
         return itemXml;
      }
      
      public function getItemData(worldObject:MapResource, item:FarmItem = null, itemName:String = "") : BaseDataSource
      {
         var offset:int = 0;
         var itemData:BaseDataSource = null;
         if(worldObject)
         {
            if(item is BuildingItem && item.className == "CraftingCottageBuilding")
            {
               offset = Global.player.getGlobalItemInstances("CraftingCottageBuilding");
               itemData = BuildingItem(item).getActiveDSWithTierOffset(worldObject.getItemName(),offset);
            }
            else
            {
               itemData = item.getActiveDS(worldObject.getItemName());
            }
         }
         else
         {
            itemData = item.getActiveDS(itemName);
         }
         return itemData;
      }
      
      public function getItemCurrency(costXml:XML, costData:BaseDataSource = null) : String
      {
         var result:String = Currency.COINS;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(costData) && costData.hasProperty("market"))
            {
               result = costData.getString("market");
            }
         }
         else if(costXml.hasOwnProperty(XMLKeys.ATTR_MARKET))
         {
            result = costXml.@market.toString();
         }
         return result;
      }
      
      public function canBuyFarmItem(item:FarmItem) : Boolean
      {
         var cashCost:Number = NaN;
         var currencyUnit:String = null;
         var result:Boolean = false;
         if(item.isCash)
         {
            cashCost = item.saleCash ? item.saleCash : item.cash;
            result = this.canBuyCash(cashCost);
         }
         else
         {
            currencyUnit = item.market ? item.market : Currency.COINS;
            result = this.canBuyWithCurrency(currencyUnit,item.cost);
         }
         return result;
      }
      
      public function canBuyItem(worldObject:MapResource, gift:Boolean = false, item:FarmItem = null, discount:int = 0, currencyUnit:String = "", showMessage:Boolean = true) : Boolean
      {
         var cost:int = 0;
         var currency:String = null;
         var cash:int = 0;
         var canBuy:Boolean = false;
         if(item != null)
         {
            cost = item.realCost - discount;
            showMessage &&= gift == false;
            if(currencyUnit)
            {
               currency = currencyUnit;
            }
            else if(item.market)
            {
               currency = item.market;
            }
            else
            {
               currency = Currency.COINS;
            }
            switch(currency)
            {
               case Currency.CASH:
                  cash = item.realCashCost - discount;
                  canBuy = Global.player.canBuyCash(cash,showMessage,item.type);
                  break;
               case Currency.COINS:
               case Currency.BOTH:
                  canBuy = Global.player.canBuy(cost,showMessage,item.type);
                  break;
               default:
                  canBuy = Global.player.canBuyWithCurrency(currency,cost,showMessage);
            }
         }
         return canBuy;
      }
      
      public function tryBuy(object:MapResource, gift:Boolean = false, farmItem:FarmItem = null, discount:int = 0, itemName:String = "", currency:String = "") : Boolean
      {
         var item:FarmItem = farmItem;
         if(item == null)
         {
            item = object.getItem();
         }
         var buyXpString:String = "";
         var costXml:XML = null;
         var costData:BaseDataSource = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            costData = this.getItemData(object,item,itemName);
            if(Boolean(costData) && costData.hasProperty("buyXp"))
            {
               buyXpString = costData.getString("buyXp");
            }
         }
         else
         {
            costXml = this.getItemXml(object,item,itemName);
            buyXpString = costXml.buyXp;
         }
         var currencyType:String = currency ? currency : this.getItemCurrency(costXml,costData);
         var itemCashCost:int = 0;
         var itemCoinsCost:int = 0;
         if(DealOfDayHelper.inExperiment() && DealOfDayHelper.isDealOfDayItem(item.code))
         {
            currencyType = DealOfDayHelper.getDealOfDayItemCurrency(item.code);
         }
         switch(currencyType)
         {
            case Currency.CASH:
               itemCashCost = Math.max(0,item.realCashCost - discount);
               break;
            case Currency.COINS:
            default:
               itemCoinsCost = item.realCost - discount;
         }
         var costForXpCalculation:int = item.cost;
         var xp:Number = Math.floor(costForXpCalculation * Global.farmGameSettingsManager.getNumber("buyXpGainRatio"));
         var realXp:Number = Math.max(xp,Global.farmGameSettingsManager.getNumber("buyXpGainMin"));
         if(item.isTiered && buyXpString != "")
         {
            realXp = Number(buyXpString);
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(item.hasPropertyInDataSource("buyXp"))
            {
               realXp = item.getNumberFromDataSource("buyXp");
            }
         }
         else if(Boolean(item.xml.buyXp) && item.xml.buyXp.toString() != "")
         {
            realXp = Number(item.xml.buyXp);
         }
         realXp = Global.player.calculateAndAddXp(realXp);
         var canBuy:Boolean = this.canBuyItem(object,gift,item,discount,currencyType);
         if(itemCashCost > 0)
         {
            Global.player.cash -= itemCashCost;
            if(object != null)
            {
               object.displayStatus(ZLocUtils.t("FarmGame","Status_BuyCash",{
                  "cashNum":itemCashCost,
                  "xpNum":realXp
               }));
            }
         }
         else if(itemCoinsCost > 0)
         {
            Global.player.updateWorldCurrency(currencyType,-itemCoinsCost);
            if(object != null)
            {
               object.displayStatus(ZLocUtils.t("FarmGame","Status_BuyObject",{
                  "coinNum":itemCoinsCost,
                  "currency":ZLocUtils.t("FarmGame",currencyType),
                  "xpNum":realXp
               }));
            }
         }
         else if(object != null)
         {
            object.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":realXp}));
         }
         return canBuy;
      }
      
      public function checkLevel(reqLevel:int) : Boolean
      {
         return this.level >= reqLevel;
      }
      
      public function checkNeighbors(reqNeighbors:int) : Boolean
      {
         return Global.friendManager.neighborCount >= reqNeighbors;
      }
      
      public function getPendingNeighbors() : Object
      {
         return this.m_pendingNeighbors;
      }
      
      public function set pregnantSow(pregnantSowObj:Object) : void
      {
         this.m_pregnantSow = pregnantSowObj;
      }
      
      public function get pregnantSow() : Object
      {
         return this.m_pregnantSow;
      }
      
      public function getGlobalItemInstances(className:String) : int
      {
         var gifts:Array = null;
         var i:int = 0;
         var instances:Array = null;
         var thisGift:StorageItem = null;
         var thisGiftItem:FarmItem = null;
         var count:int = 0;
         var objectClass:Class = getDefinitionByName("Classes." + className) as Class;
         try
         {
            if(objectClass == null)
            {
               throw new Error("Building Type Not Found " + className);
            }
            instances = Global.world.getObjectsByClass(objectClass);
            count += instances.length;
            gifts = this.getGifts();
            for(i = 0; i < gifts.length; i++)
            {
               thisGift = gifts[i];
               if(thisGift.item)
               {
                  thisGiftItem = thisGift.item;
                  if(thisGiftItem.className == className)
                  {
                     count += int(thisGift.quantity);
                  }
               }
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error getGlobalItemInstances: " + err.message + " className=" + className);
         }
         return count;
      }
      
      public function getUnlockStartLevel(itemName:String) : int
      {
         return this.m_externalLevels[itemName];
      }
      
      public function checkMafiaLevel(reqLevel:int) : Boolean
      {
         return this.mafiaWarsLevel >= reqLevel;
      }
      
      public function checkMafiaLevelChange(minReqLevel:int, reqLevelChange:int, itemName:String) : Boolean
      {
         var startLevel:int = this.getUnlockStartLevel(itemName);
         var reqLevel:int = Math.max(startLevel + reqLevelChange,minReqLevel);
         return this.mafiaWarsLevel >= reqLevel;
      }
      
      public function checkMastery(reqMastery:String) : Boolean
      {
         var result:Boolean = false;
         if(reqMastery != "")
         {
            result = Global.farmGameSettingsManager.getMasteryByCode(reqMastery).hasAllMasteries();
         }
         return result;
      }
      
      public function checkItemLimit(itemName:String, includeGiftbox:Boolean = true) : Boolean
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         return item.checkItemLimit(includeGiftbox);
      }
      
      public function checkGate(gateType:String, itemName:String, itemXMLIn:XML = null, itemReference:FarmItem = null) : Boolean
      {
         var result:Boolean = false;
         var farmItem:FarmItem = null;
         var itemXML:XML = null;
         var itemCode:String = null;
         var itemLicenseLimit:String = null;
         var itemRequiredLevel:int = 0;
         var itemMinNeighbors:int = 0;
         var itemLimitedLocale:String = null;
         var masterySuccess:Boolean = false;
         var mafiaLevelSuccess:Boolean = false;
         var mafiaLevelChangeSuccess:Boolean = false;
         var purchasePrereqSuccess:Boolean = false;
         var buildingItem:BuildingItem = null;
         var gated:Boolean = true;
         if(itemReference != null)
         {
            itemName = itemReference.name;
            itemCode = itemReference.code;
            itemLicenseLimit = itemReference.licenseLimit;
            itemRequiredLevel = itemReference.requiredLevel;
            itemMinNeighbors = itemReference.minNeighbors;
            itemLimitedLocale = itemReference.limitedLocale;
            masterySuccess = false;
            mafiaLevelSuccess = false;
            mafiaLevelChangeSuccess = false;
         }
         else
         {
            if(itemXMLIn != null)
            {
               itemXML = itemXMLIn;
            }
            else
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               itemXML = farmItem.xml ? farmItem.xml : (farmItem.cashXML ? farmItem.cashXML : farmItem.saleXML);
               if(itemXML == null)
               {
                  throw new Error("no item reference passed in to checkGate and XML is not set");
               }
            }
            itemCode = itemXML.@code;
            itemLicenseLimit = itemXML.@licenseLimit;
            itemRequiredLevel = int(itemXML.requiredLevel);
            itemMinNeighbors = int(itemXML.minNeighbors);
            itemLimitedLocale = itemXML.limitedLocale.toString();
            masterySuccess = this.checkMastery(itemXML.requiredMastery);
            mafiaLevelSuccess = this.checkMafiaLevel(itemXML.requiredMafiaLevel);
            mafiaLevelChangeSuccess = this.checkMafiaLevelChange(itemXML.requiredMafiaLevel,itemXML.requiredMafiaLevelChange,itemXML.@name);
         }
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         var deltaTime:Number = currentTime - Global.player.getFeatureLastShown("Bought" + itemName);
         var licenseSuccess:Boolean = LicenseManager.getInstance().hasCurrentLicense(itemCode) && (!itemLicenseLimit || deltaTime > this.SECONDS_IN_EIGHTEEN_HOURS);
         var levelSuccess:Boolean = this.checkLevel(itemRequiredLevel);
         var neighborSuccess:Boolean = this.checkNeighbors(itemMinNeighbors);
         switch(gateType)
         {
            case FarmItemLock.SWEETSEEDS:
               gated = licenseSuccess;
               break;
            case FarmItemLock.LICENSE:
               gated = licenseSuccess;
               break;
            case FarmItemLock.LOCKED:
               gated = false;
               break;
            case FarmItemLock.PURCHASE_PREREQ:
               purchasePrereqSuccess = true;
               if(itemReference)
               {
                  purchasePrereqSuccess = itemReference.checkPurchasePrereqs();
               }
               else if(itemXML.hasOwnProperty("purchasePrereqs"))
               {
                  if(farmItem == null)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                  }
                  purchasePrereqSuccess = farmItem.checkPurchasePrereqs();
               }
               gated = purchasePrereqSuccess;
               break;
            case FarmItemLock.LEVEL:
               gated = levelSuccess;
               break;
            case FarmItemLock.NEIGHBOR:
               gated = neighborSuccess;
               break;
            case FarmItemLock.MASTERY:
               gated = masterySuccess;
               break;
            case FarmItemLock.INSTANCE_TIERED:
               buildingItem = null;
               if(itemReference)
               {
                  buildingItem = itemReference as BuildingItem;
               }
               else
               {
                  buildingItem = Global.farmGameSettingsManager.getFarmItemByName(itemName) as BuildingItem;
               }
               if(buildingItem)
               {
                  gated = levelSuccess && buildingItem.checkTiers();
               }
               break;
            case FarmItemLock.LEVEL_AND_NEIGHBOR:
               gated = levelSuccess && neighborSuccess;
               break;
            case FarmItemLock.LEVEL_OR_NEIGHBOR:
               gated = levelSuccess || neighborSuccess;
               break;
            case FarmItemLock.MAFIA_LEVEL:
            case FarmItemLock.MAFIA_BANGKOK:
               gated = levelSuccess && mafiaLevelSuccess;
               break;
            case FarmItemLock.MAFIA_LEVEL_CHANGE:
               gated = levelSuccess && mafiaLevelChangeSuccess;
               break;
            case FarmItemLock.EMAIL:
               gated = GlobalEngine.socialNetwork.userHasEmailPermission();
               break;
            case FarmItemLock.LOCALE:
               gated = this.snUser.locale == itemLimitedLocale;
               break;
            default:
               gated = levelSuccess;
         }
         return gated || licenseSuccess;
      }
      
      public function incrementActionCount(actionName:String, sendTransaction:Boolean = true) : void
      {
         if(this.m_actionCounts[actionName])
         {
            ++this.m_actionCounts[actionName];
         }
         else
         {
            this.m_actionCounts[actionName] = 1;
         }
         if(sendTransaction)
         {
            TransactionManager.addTransaction(new TActionCount(actionName));
         }
      }
      
      public function setActionCount(actionName:String, value:int = 0, sendTransaction:Boolean = false) : void
      {
         this.m_actionCounts[actionName] = value;
         if(sendTransaction)
         {
            TransactionManager.addTransaction(new TGenericTransaction("UserService","setActionCount",null,[actionName,value]));
         }
      }
      
      public function resetActionCounts() : void
      {
         this.m_actionCounts = new Object();
      }
      
      public function resetActionCount(actionName:String, sendTransaction:Boolean = false) : void
      {
         this.m_actionCounts[actionName] = 0;
         if(sendTransaction)
         {
            TransactionManager.addTransaction(new TGenericTransaction("UserService","resetActionCount",null,[actionName]));
         }
      }
      
      public function getActionCount(actionName:String) : int
      {
         var count:int = 0;
         if(this.actionCountsLoaded())
         {
            if(this.m_actionCounts[actionName])
            {
               count = int(this.m_actionCounts[actionName]);
            }
         }
         return count;
      }
      
      public function getIntervalActionCount(actionName:String, timeInterval:int = 86400) : int
      {
         var result:int = 0;
         if(this.shouldIntervalActionCountRollOver(actionName,timeInterval) == false)
         {
            result = this.getActionCount(actionName);
         }
         else
         {
            this.setActionCount(actionName,result);
         }
         return result;
      }
      
      public function incrementIntervalActionCount(actionName:String, timeInterval:int = 86400, sendTransaction:Boolean = false) : void
      {
         if(this.shouldIntervalActionCountRollOver(actionName,timeInterval) == false)
         {
            this.incrementActionCount(actionName,false);
         }
         else
         {
            this.setActionCount(actionName,1);
         }
         if(sendTransaction === true)
         {
            TransactionManager.addTransaction(new TIntervalActionCount(actionName,timeInterval));
         }
         this.setFeatureLastShown(actionName,GlobalEngine.serverTime / 1000,false);
      }
      
      public function getTimeForIntervalActionCount(actionName:String, timeInterval:int = 86400) : Number
      {
         var result:Number = 0;
         var currentTimeInSec:int = GlobalEngine.serverTime / 1000;
         var lastSeenTimeInSec:int = this.getFeatureLastShown(actionName);
         return timeInterval + lastSeenTimeInSec - currentTimeInSec;
      }
      
      private function shouldIntervalActionCountRollOver(actionName:String, timeInterval:int = 86400) : Boolean
      {
         var result:Boolean = false;
         var featureLastShown:Number = this.getFeatureLastShown(actionName);
         if(featureLastShown == 0)
         {
            result = false;
         }
         else if(GlobalEngine.serverTime / 1000 - featureLastShown > timeInterval)
         {
            result = true;
         }
         return result;
      }
      
      public function actionCountsLoaded() : Boolean
      {
         return this.m_actionCounts != null;
      }
      
      public function update() : void
      {
         this.expireBuffs();
         Global.hud.update();
      }
      
      public function getNumSuperAvatarActions(resourceAction:int) : int
      {
         return 0;
      }
      
      public function set isMysteryGameInitialized(bool:Boolean) : void
      {
         this.m_isMysteryGameInitialized = bool;
      }
      
      public function get isMysteryGameInitialized() : Boolean
      {
         return this.m_isMysteryGameInitialized;
      }
      
      public function get mysteryBox2TargetStates() : Array
      {
         return this.m_mysteryBox2TargetStates;
      }
      
      public function set mysteryBox2TargetStates(val:Array) : void
      {
         this.m_mysteryBox2TargetStates = val;
      }
      
      public function get mysteryBox2TileStates() : Array
      {
         return this.m_mysteryBox2TileStates;
      }
      
      public function set mysteryBox2TileStates(val:Array) : void
      {
         this.m_mysteryBox2TileStates = val;
      }
      
      public function get lastSocialPlumbingActionTime() : Number
      {
         return this.m_lastSocialPlumbingActionTime;
      }
      
      public function get adoptedAnimals() : Object
      {
         return this.m_adoptedAnimals;
      }
      
      public function hasAdoptedAnimal(animalCode:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_adoptedAnimals != null)
         {
            result = this.m_adoptedAnimals.hasOwnProperty(animalCode);
         }
         return result;
      }
      
      public function addAdoptedAnimal(animalCode:String) : void
      {
         if(this.m_adoptedAnimals != null)
         {
            if(this.m_adoptedAnimals.hasOwnProperty(animalCode))
            {
               this.m_adoptedAnimals[animalCode] += 1;
            }
            else
            {
               this.m_adoptedAnimals[animalCode] = 1;
            }
         }
         else
         {
            this.m_adoptedAnimals = {};
            this.m_adoptedAnimals[animalCode] = 1;
         }
      }
      
      public function get avatarVisible() : Boolean
      {
         return this.m_avatarVisible;
      }
      
      public function get avatarArrowIndicatorVisible() : Boolean
      {
         return this.m_avatarArrowIndicatorVisible;
      }
      
      public function get avatarState() : AvatarItemState
      {
         return this.m_avatarState;
      }
      
      public function get w2wState() : W2WFeatureState
      {
         return this.m_w2wState;
      }
      
      public function set fofData(fd:Array) : void
      {
         this.m_fofData = fd;
      }
      
      public function get fofData() : Array
      {
         return this.m_fofData;
      }
      
      public function set prereqDSObject(data:Object) : void
      {
         this.m_prereqDSObject = data;
      }
      
      public function get prereqDSObject() : Object
      {
         return this.m_prereqDSObject;
      }
      
      public function refreshGiftBox(storageDataIn:Object) : void
      {
         var itemCode:String = null;
         var giftData:Array = null;
         if(storageDataIn)
         {
            this.m_seeds = new Dictionary();
            this.m_gifts = new Dictionary();
            itemCode = "";
            if(storageDataIn[Global.world.GIFTBOX_ID])
            {
               for(itemCode in storageDataIn[Global.world.GIFTBOX_ID])
               {
                  giftData = storageDataIn[Global.world.GIFTBOX_ID][itemCode] as Array;
                  if(giftData)
                  {
                     this.addGiftData(giftData,itemCode);
                  }
               }
            }
            if(storageDataIn[Global.world.CONSUME_ID])
            {
               for(itemCode in storageDataIn[Global.world.CONSUME_ID])
               {
                  this.addGiftData(storageDataIn[Global.world.CONSUME_ID][itemCode],itemCode);
               }
            }
            ++this.m_giftsVersion;
         }
      }
      
      public function get isAutomatedQA() : Boolean
      {
         return this.m_isAutomatedQA;
      }
      
      public function setIsAutomatedQA(isAQA:Boolean) : void
      {
         this.m_isAutomatedQA = isAQA;
         if(this.m_isAutomatedQA)
         {
            Global.suppressAllInitUserDialogs = true;
            Global.suppressAllToasters = true;
         }
      }
      
      public function get isKeynoteQA() : Boolean
      {
         return this.m_isKeynoteQA;
      }
      
      public function setIsKeynoteQA(isAQA:Boolean) : void
      {
         this.m_isKeynoteQA = isAQA;
         if(this.m_isKeynoteQA)
         {
            Global.suppressAllInitUserDialogs = true;
            Global.suppressAllToasters = true;
         }
      }
      
      public function setAvatarVisible(isVisible:Boolean) : void
      {
         this.m_avatarVisible = isVisible;
         if(!this.m_avatarVisible && this.avatar != null)
         {
            this.avatar.hideAvatar();
         }
      }
      
      public function setAvatarArrowIndicatorVisible(isVisible:Boolean) : void
      {
         this.m_avatarArrowIndicatorVisible = isVisible;
      }
      
      public function getBreedingStatsByFeatureName(featureName:String) : int
      {
         return BreedingManager.getInstance().getPvPStatByFeatureName(featureName);
      }
      
      public function set crossGameGiftingStateData(crossGameData:Object) : void
      {
         this.m_crossGameGiftingData = crossGameData;
      }
      
      public function getCrossGameGiftingStateData(gameID:String) : Object
      {
         var result:Object = null;
         if(this.m_crossGameGiftingData != null && this.m_crossGameGiftingData.hasOwnProperty(gameID))
         {
            result = this.m_crossGameGiftingData[gameID];
         }
         return result;
      }
      
      public function getlimitedSaleExpirationForVersion(saleVersion:int) : int
      {
         var result:int = LimitedSaleUtility.NO_EXPIRATION_SPECIFIED;
         if(this.m_limitedSaleTimers.hasOwnProperty(String(saleVersion)))
         {
            result = int(this.m_limitedSaleTimers[saleVersion]);
         }
         return result;
      }
      
      private function set limitedSaleExpirations(saleExpirations:Object) : void
      {
         this.m_limitedSaleTimers = saleExpirations;
      }
      
      public function isSuperCropUnlocked(cropCode:String) : Boolean
      {
         return this.m_superCropsStatus.indexOf(cropCode) >= 0;
      }
      
      public function get lotteryTickets() : Array
      {
         return this.m_lotteryTickets;
      }
      
      public function set lotteryTickets(tickets:Array) : void
      {
         this.m_lotteryTickets = tickets;
      }
      
      public function addLotteryTicket(ticket:Object) : void
      {
         this.m_lotteryTickets.push(ticket);
      }
      
      public function updateTransactionLog(deltaGold:int, deltaCash:int) : void
      {
         var date:Date = new Date(GlobalEngine.serverTime);
         var transactionTimestamp:String = date.fullYearUTC + "-" + date.monthUTC + "-" + date.dateUTC + " " + date.hoursUTC + ":" + date.minutesUTC + ":" + date.secondsUTC;
         var transactionObject:Object = new Object();
         transactionObject.timestamp = transactionTimestamp;
         transactionObject.gold = deltaGold;
         transactionObject.cash = deltaCash;
         this.m_transactionLog.push(transactionObject);
      }
      
      public function getCashTransactionsFromDate(timestamp:Number = -1) : Array
      {
         var result:Array = null;
         var transaction:Object = null;
         var regex:RegExp = null;
         var fixedTimestamp:String = null;
         var transactionUTCTimestamp:Number = NaN;
         result = new Array();
         if(timestamp >= 0)
         {
            for each(transaction in this.m_transactionLog)
            {
               if(transaction.hasOwnProperty("timestamp"))
               {
                  regex = /-/g;
                  fixedTimestamp = transaction.timestamp.replace(regex,"/");
                  transactionUTCTimestamp = Date.parse(fixedTimestamp);
                  if(transactionUTCTimestamp / FarmGameUtil.NUM_MSECS_IN_SECOND - timestamp >= 0)
                  {
                     result.push(transaction);
                  }
               }
            }
         }
         else
         {
            result = this.m_transactionLog;
         }
         return result;
      }
      
      public function unlockSuperCrop(cropCode:String) : void
      {
         if(!this.isSuperCropUnlocked(cropCode))
         {
            this.m_superCropsStatus.push(cropCode);
         }
      }
      
      public function set purchaseHistory(purchaseHistory:Object) : void
      {
         this.m_purchaseHistory = purchaseHistory;
      }
      
      public function get purchaseHistory() : Object
      {
         return this.m_purchaseHistory;
      }
      
      public function canShowFeatureWithBackoff(featureName:String, neverShowAfter:int = -1) : Boolean
      {
         var nextTime:Number = NaN;
         nextTime = this.getFeatureLastShown(featureName);
         return (neverShowAfter == -1 || this.getBackoffInterval(featureName) < neverShowAfter) && GlobalEngine.serverTime > nextTime;
      }
      
      public function incrementBackoffInterval(featureName:String) : void
      {
         var backoffIncrementDays:Number = NaN;
         var backoffFrequenceName:String = null;
         var backoffIncrements:int = 0;
         var nextTime:Number = NaN;
         backoffIncrementDays = Global.farmGameSettingsManager.getAttribute(featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_INCREMENT_VARIABLE_POSTFIX,1);
         backoffFrequenceName = featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_POSTFIX;
         Global.player.incrementActionCount(backoffFrequenceName);
         backoffIncrements = this.getBackoffInterval(featureName);
         nextTime = GlobalEngine.serverTime + backoffIncrements * backoffIncrementDays * FarmGameUtil.NUM_MSECS_IN_DAY;
         this.setFeatureLastShown(featureName,nextTime,false);
         this.setFeatureLastShown(backoffFrequenceName,backoffIncrements,false);
         TransactionManager.addTransaction(new TSetFeatureFrequencyWithBackoff(featureName,backoffIncrements));
      }
      
      public function backoffCallback(featureName:String) : Function
      {
         return function():void
         {
            if(m_shouldBackOffHarvester)
            {
               switch(featureName)
               {
                  case ARBORIST_ITEM_NAME:
                     FarmStatsManager.count("toaster","arborist_prompt",(hasMassHarvester(featureName) ? "use" : "buy").toString(),"X","",Global.worldManager.currentWorldType);
                     break;
                  case FARMHAND_ITEM_NAME:
                     FarmStatsManager.count("toaster","farmhand_prompt",(hasMassHarvester(featureName) ? "use" : "buy").toString(),"X","",Global.worldManager.currentWorldType);
               }
               incrementBackoffInterval(featureName);
            }
         };
      }
      
      public function resetBackoffInterval(featureName:String) : void
      {
         var backoffBaseName:String = null;
         var backoffFrequenceName:String = null;
         var newBase:int = 0;
         var oldBase:int = 0;
         var index:int = 0;
         backoffBaseName = featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_BASE_POSTFIX;
         backoffFrequenceName = featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_POSTFIX;
         newBase = this.getFeatureLastShown(backoffFrequenceName);
         oldBase = Global.player.getActionCount(backoffBaseName);
         if(newBase > 0)
         {
            for(index = oldBase; index < newBase; index++)
            {
               Global.player.incrementActionCount(backoffBaseName);
            }
         }
      }
      
      public function getBackoffInterval(featureName:String) : int
      {
         var backoffFrequenceName:String = null;
         var backoffBaseName:String = null;
         var backoffBase:int = 0;
         var unadjustedIncrement:int = 0;
         var backoffIncrements:int = 0;
         backoffFrequenceName = featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_POSTFIX;
         backoffBaseName = featureName + TSetFeatureFrequencyWithBackoff.FF_BACKOFF_BASE_POSTFIX;
         backoffBase = Global.player.getActionCount(backoffBaseName);
         if(backoffBase > 0)
         {
            backoffBase = backoffBase;
         }
         unadjustedIncrement = Global.player.getActionCount(backoffFrequenceName);
         return int(unadjustedIncrement - backoffBase);
      }
      
      private function generateTrackingKingdom(harvesterItemName:String) : String
      {
         var kingdom:String = null;
         kingdom = "";
         switch(harvesterItemName)
         {
            case FARMHAND_ITEM_NAME:
               kingdom = "farmhand_prompt";
               break;
            case ARBORIST_ITEM_NAME:
               kingdom = "arborist_prompt";
         }
         return kingdom;
      }
      
      public function shouldDisplayMassHarvesterToaster(harvesterItemName:String, harvestableClass:Class) : Boolean
      {
         var experimentEnabled:Boolean = false;
         var lastShown:Number = NaN;
         var currentlyBackedOff:Boolean = false;
         experimentEnabled = false;
         switch(harvesterItemName)
         {
            case ARBORIST_ITEM_NAME:
               experimentEnabled = Global.experimentManager.getExperimentVariant("fv_arborist_prompt") == 1;
               break;
            case FARMHAND_ITEM_NAME:
               experimentEnabled = true;
         }
         lastShown = this.getFeatureLastShown(harvesterItemName + "_prompt");
         currentlyBackedOff = !this.canShowFeatureWithBackoff(harvesterItemName);
         return !Global.worldManager.isVisiting() && (lastShown + FarmGameUtil.NUM_SECS_IN_DAY) * 1000 <= GlobalEngine.serverTime && experimentEnabled && !currentlyBackedOff && WorldAnalyzer.getHarvestableCountByClass(harvestableClass) >= MINIMUM_HARVESTABLE_ITEM_COUNT;
      }
      
      public function inExperimentFeedCheckBoxV2() : Boolean
      {
         if(this.m_feedCheckboxV2ExpFlag)
         {
            this.m_feedCheckboxV2ExpFlag = false;
            this.m_inFeedCheckboxV2Exp = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_CHECKBOX_FLOW_V2) == 2;
         }
         return this.m_inFeedCheckboxV2Exp;
      }
      
      private function getMassHarvesterXMLName(harvesterItemName:String) : String
      {
         var returnString:String = null;
         returnString = "";
         switch(harvesterItemName)
         {
            case ARBORIST_ITEM_NAME:
               returnString = ARBORIST_XML_ITEM_NAME;
               break;
            case FARMHAND_ITEM_NAME:
               returnString = FARMHAND_XML_ITEM_NAME;
         }
         return returnString;
      }
      
      private function hasMassHarvester(harvesterItemName:String) : Boolean
      {
         return this.getGiftCountForItem(this.getMassHarvesterXMLName(harvesterItemName)) > 0;
      }
      
      public function displayMassHarvesterToaster(harvesterItemName:String) : void
      {
         var hasHelper:String = null;
         var harvestableItemName:String = null;
         var titleMsg:String = null;
         var msg:String = null;
         var acceptText:String = null;
         var icon:String = null;
         hasHelper = this.hasMassHarvester(harvesterItemName) ? "Has" : "Has_No";
         harvestableItemName = this.getHarvestableItemName(harvesterItemName);
         titleMsg = ZLocUtils.t("Dialogs","Consumable_Harvest_" + harvestableItemName + "s_Surfacing_Toaster_Title");
         msg = ZLocUtils.t("Dialogs","Consumable_Harvest_" + harvestableItemName + "s_Surfacing_Toaster_" + hasHelper + "_Harvester_Body");
         acceptText = ZLocUtils.t("Dialogs","Consumable_Harvest_Items_Surfacing_Toaster_" + hasHelper + "_Harvester_Button");
         icon = this.getHarvestableToasterIcon(harvesterItemName);
         m_shouldBackOffHarvester = true;
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,icon,"",ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),new Point(15,0),this.massHarvesterClickCallback(harvesterItemName),false,false,null,this.backoffCallback(harvesterItemName),acceptText));
         this.setFeatureLastShown(harvesterItemName + "_prompt",GlobalEngine.serverTime / 1000,true);
         FarmStatsManager.count("toaster",this.generateTrackingKingdom(harvesterItemName),(this.hasMassHarvester(harvesterItemName) ? "use" : "buy").toString(),"view","",Global.worldManager.currentWorldType);
      }
      
      public function massHarvesterClickCallback(harvesterItemName:String) : Function
      {
         return function(e:Event):void
         {
            m_shouldBackOffHarvester = false;
            ToasterManager.getInstance().closeCurrentToaster();
            if(hasMassHarvester(harvesterItemName))
            {
               useMassHarvester(harvesterItemName);
               FarmStatsManager.count("toaster",generateTrackingKingdom(harvesterItemName),"use","action","",Global.worldManager.currentWorldType);
            }
            else if(Global.player.canBuyCash(5,true,harvesterItemName))
            {
               purchaseAndUseMassHarvester(harvesterItemName);
            }
            resetBackoffInterval(harvesterItemName);
         };
      }
      
      private function useMassHarvester(harvesterItemName:String) : void
      {
         var consumableName:String = null;
         var consumable:Consumable = null;
         consumableName = this.getMassHarvesterXMLName(harvesterItemName);
         if(consumableName != "")
         {
            consumable = Consumable.createConsumable(consumableName);
            consumable.consume(true,false);
         }
      }
      
      public function contentAccessHasAccess(contentName:String) : Boolean
      {
         var result:Boolean = false;
         var featureOptionData:Object = null;
         result = false;
         featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName);
         if(featureOptionData != null && featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_ACCESS] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function contentAccessHasSeenOnboarding(contentName:String) : Boolean
      {
         var result:Boolean = false;
         var featureOptionData:Object = null;
         result = false;
         featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName);
         if(featureOptionData != null && featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_SEEN_ONBOARDING] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function contentAccessSetSeenOnboarding(contentName:String) : void
      {
         var featureOptionData:Object = null;
         featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName);
         if(featureOptionData != null && featureOptionData.hasOwnProperty(FeatureOptionsManager.CONTENT_ACCESS_HAS_ACCESS) && featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_ACCESS] == true && featureOptionData.hasOwnProperty(FeatureOptionsManager.CONTENT_ACCESS_HAS_SEEN_ONBOARDING) && featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_SEEN_ONBOARDING] == false)
         {
            featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_SEEN_ONBOARDING] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName,featureOptionData);
            TransactionManager.addTransaction(new TGenericTransaction("UserService","setSeenOnboardingContentAccess",null,[contentName]));
         }
      }
      
      public function purchaseContentAccess(contentName:String) : Boolean
      {
         var result:Boolean = false;
         var featureOptionData:Object = null;
         var contentAccessSettings:ContentAccessSettings = null;
         result = false;
         featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName);
         if(featureOptionData == null || featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_ACCESS] == false)
         {
            contentAccessSettings = Global.farmGameSettingsManager.getContentAccessSettings(contentName);
            if(Boolean(contentAccessSettings) && contentAccessSettings.cash > 0)
            {
               if(Global.player.canBuyCash(contentAccessSettings.cash,true,contentAccessSettings.name))
               {
                  result = true;
                  Global.player.cash -= contentAccessSettings.cash;
                  if(featureOptionData == null)
                  {
                     featureOptionData = new Object();
                  }
                  featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_ACCESS] = true;
                  featureOptionData[FeatureOptionsManager.CONTENT_ACCESS_HAS_SEEN_ONBOARDING] = false;
                  FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CONTENT_ACCESS,contentName,featureOptionData);
                  contentAccessSettings.grantRewards();
                  contentAccessSettings.handleSwapDeco();
                  contentAccessSettings.hideHudIcons();
                  UI.closeAndLockGifts();
                  TransactionManager.addTransaction(new TGenericTransaction("UserService","purchaseContentAccess",this.purchaseContentAccessOnComplete,[contentName]));
               }
            }
         }
         return result;
      }
      
      protected function purchaseContentAccessOnComplete(result:Object) : void
      {
         var swapDeco:SwapDecoration = null;
         var contentAccessSettings:ContentAccessSettings = null;
         if(result.success == true)
         {
            if(result.previously_owned == false && result.granted == true)
            {
               swapDeco = null;
               if(result.hasOwnProperty("contentName") && result.contentName != null && result.contentName != "")
               {
                  contentAccessSettings = Global.farmGameSettingsManager.getContentAccessSettings(result.contentName);
                  contentAccessSettings.handleSwapDeco();
                  contentAccessSettings.openMiniMarket();
                  contentAccessSettings.hideHudIcons();
               }
            }
            else if(result.previously_owned == true && result.granted == false)
            {
               Global.player.cash += result.cash_cost;
            }
            UI.unlockGifts();
            TransactionManager.addTransaction(new TRefreshGifts(),true);
         }
      }
      
      private function useAndCongratsForMassHarvesterCallback(harvesterItemName:String) : Function
      {
         return function():void
         {
            useMassHarvester(harvesterItemName);
            displayCongratsToaster(harvesterItemName);
         };
      }
      
      public function isEligibleGiftRecipient(friendUid:String) : Boolean
      {
         var result:Boolean = false;
         var timeLimit:int = 0;
         var now:Number = NaN;
         var timeDiff:Number = NaN;
         result = true;
         if(this.m_sentGifts.hasOwnProperty(friendUid.toString()))
         {
            timeLimit = Global.farmGameSettingsManager.getInt("giftingPerUserTimeLimit",900000);
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timeDiff = now - this.m_sentGifts[friendUid.toString()];
            if(timeDiff < timeLimit)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function sentGiftToUser(friendUid:String) : void
      {
         this.m_sentGifts[friendUid] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function set sentGifts(sentGiftList:Object) : void
      {
         var prop:String = null;
         this.m_sentGifts = {};
         for(prop in sentGiftList)
         {
            this.m_sentGifts[prop.replace(/^\s+|\s+$/g,"")] = sentGiftList[prop];
         }
      }
      
      public function incrementHarvestCountForSeedSinceLastBushelDrop(seedItemCode:String, increment:int = 1) : void
      {
         var newQuantity:int = 0;
         newQuantity = this.getHarvestCountForSeedSinceLastBushelDrop(seedItemCode) + increment;
         this.setHarvestCountForSeedSinceLastBushelDrop(seedItemCode,newQuantity);
      }
      
      public function setHarvestCountForSeedSinceLastBushelDrop(seedItemCode:String, quantity:int) : void
      {
         this.m_seedharvestCountsSinceLastBushelDrop[seedItemCode] = quantity;
      }
      
      public function setAllSeedHarvestCountsSinceLastBushelDrop(harvestCount:Object) : void
      {
         this.m_seedharvestCountsSinceLastBushelDrop = harvestCount;
      }
      
      public function getAllSeedHarvestCountsSinceLastBushelDrop() : Object
      {
         return this.m_seedharvestCountsSinceLastBushelDrop;
      }
      
      public function getHarvestCountForSeedSinceLastBushelDrop(seedItemCode:String) : int
      {
         var harvestCount:int = 0;
         var allSeedHarvestCounts:Object = null;
         harvestCount = 0;
         allSeedHarvestCounts = this.getAllSeedHarvestCountsSinceLastBushelDrop();
         if(allSeedHarvestCounts[seedItemCode])
         {
            harvestCount = int(allSeedHarvestCounts[seedItemCode]);
         }
         return harvestCount;
      }
      
      private function purchaseAndUseMassHarvester(harvesterItemName:String) : void
      {
         var pkgName:String = null;
         var purchaseTransaction:TBuyConsumables = null;
         FarmStatsManager.count("toaster",this.generateTrackingKingdom(harvesterItemName),"buy",(this.cash > 5 ? "enough_fc" : "insufficient_fc").toString(),"",Global.worldManager.currentWorldType);
         pkgName = "";
         switch(harvesterItemName)
         {
            case ARBORIST_ITEM_NAME:
               pkgName = "pkg_arborists";
               break;
            case FARMHAND_ITEM_NAME:
               pkgName = "pkg_farm_hands";
         }
         if(pkgName != "")
         {
            purchaseTransaction = new TBuyConsumables(pkgName,false,null,function():void
            {
            },this.useAndCongratsForMassHarvesterCallback(harvesterItemName));
            TransactionManager.addTransaction(purchaseTransaction);
            FarmStatsManager.count("fv_cash_buy","consumable",pkgName,"5","",Global.worldManager.currentWorldType);
         }
      }
      
      private function getHarvestableItemName(harvesterItemName:String) : String
      {
         switch(harvesterItemName)
         {
            case ARBORIST_ITEM_NAME:
               return "Tree";
            case FARMHAND_ITEM_NAME:
               return "Animal";
            default:
               return "";
         }
      }
      
      private function getHarvestableToasterIcon(harvesterItemName:String) : String
      {
         var icon:String = null;
         icon = "";
         switch(harvesterItemName)
         {
            case ARBORIST_ITEM_NAME:
               icon = ToasterIconPaths.ARBOTRIST_ICON;
               break;
            case FARMHAND_ITEM_NAME:
               icon = ToasterIconPaths.FARMHAND_ICON;
         }
         return icon;
      }
      
      private function displayCongratsToaster(harvesterItemName:String) : void
      {
         var harvestableItemName:String = null;
         var titleMsg:String = null;
         var msg:String = null;
         var acceptText:String = null;
         var icon:String = null;
         harvestableItemName = this.getHarvestableItemName(harvesterItemName);
         titleMsg = ZLocUtils.t("Dialogs","Consumable_Harvest_" + harvestableItemName + "s_Surfacing_Toaster_Title");
         msg = ZLocUtils.t("Dialogs","Consumable_Harvest_" + harvestableItemName + "s_Surfacing_Toaster_Use_Harvester_Body");
         acceptText = ZLocUtils.t("Dialogs","Consumable_Harvest_Items_Surfacing_Toaster_Use_Harvester_Button");
         icon = this.getHarvestableToasterIcon(harvesterItemName);
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,icon,"",ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),new Point(15,0),function():void
         {
            ToasterManager.getInstance().closeCurrentToaster();
         },false,false,null,null,acceptText));
         FarmStatsManager.count("toaster",this.generateTrackingKingdom(harvesterItemName),"view_buy_success","","",Global.worldManager.currentWorldType);
      }
      
      public function initLeaderboardStates(leaderboardsData:Object) : void
      {
         var leaderboardName:String = null;
         for(leaderboardName in leaderboardsData)
         {
            this.m_leaderboardStates[leaderboardName] = new LeaderboardState(leaderboardsData[leaderboardName]);
         }
      }
      
      public function getLeaderboardStates() : Object
      {
         return this.m_leaderboardStates;
      }
      
      public function getLeaderboardState(leaderboardName:String) : LeaderboardState
      {
         var result:LeaderboardState = null;
         result = null;
         if(this.m_leaderboardStates.hasOwnProperty(leaderboardName))
         {
            result = this.m_leaderboardStates[leaderboardName] as LeaderboardState;
         }
         return result;
      }
      
      public function setLeaderboardState(leaderboardName:String, leaderboardState:LeaderboardState) : void
      {
         this.m_leaderboardStates[leaderboardName] = leaderboardState;
      }
      
      public function get isGiftsendBlacklist() : Boolean
      {
         return this.m_giftsendBlacklist;
      }
      
      public function set giftsendBlacklist(value:Boolean) : void
      {
         this.m_giftsendBlacklist = value;
      }
      
      public function hasWorldOfType(worldType:String) : Boolean
      {
         var result:Boolean = false;
         var worldSummaryData:Object = null;
         result = false;
         worldSummaryData = Global.worldManager.getWorldSummaryData();
         if(Boolean(worldSummaryData) && Boolean(worldSummaryData[worldType]))
         {
            result = true;
         }
         return result;
      }
      
      public function masterySignEnabled() : Boolean
      {
         var ret:Boolean = false;
         var inExp:int = 0;
         ret = true;
         inExp = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MASTERYSIGNS);
         if(inExp == 1)
         {
            ret = false;
         }
         return ret;
      }
   }
}

