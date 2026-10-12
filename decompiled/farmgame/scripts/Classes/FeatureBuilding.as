package Classes
{
   import AvatarMode.AMFeedAnimals;
   import AvatarMode.AMHarvest;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FeatureComponents.*;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.TimedActions.FeatureBuildingDeprecationTimedAction;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.CachedPrereqChecker;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ConstructionBuildingWithdrawal;
   import Display.ContextMenuItem;
   import Display.FarmDynamicDialog;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.StorageWithdrawalDynamicDialog;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import GameMode.GameMode;
   import Managers.DragonBreedingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingGiftContentDataManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsManager;
   import Managers.FeatureTrackingManager;
   import Managers.FlowerShackManager;
   import Managers.MFSRequestManager;
   import Managers.RetentionMasterManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TCompleteNow;
   import Transactions.THarvestReadyNow;
   import Transactions.TSetFeaturedItem;
   import Transactions.TSetMultipleFeaturedItems;
   import Transactions.TSetOverlayOverride;
   import Widgets.Constants.Market.Currency;
   import com.urbansquall.ginger.AnimationPlayer;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class FeatureBuilding extends AnimalStorageBuilding implements IMessagingFeature
   {
      
      protected static const TRANSFORM_OVERLAY_URL:String = "assets/overlays/snow_test.swf";
      
      public static const STATE_CONSTRUCTION:String = "construction";
      
      public static const STATE_BUILT:String = "built";
      
      public static const STATE_RIPE:String = "ripe";
      
      public static const STATE_BARE:String = "bare";
      
      public static const STATE_DISPLAY:String = "display";
      
      public static const STATE_WITHERED:String = "withered";
      
      public static const INVENTORY_CLASSNAME:String = "Inventory";
      
      public static const FALLBACK_KEY:String = "featureBuilding_";
      
      public static const CHOOSEVISUAL_ACTION:String = "choosevisual";
      
      public static const ACTION_SOURCE_UNKNOWN:int = 0;
      
      public static const ACTION_SOURCE_CONTEXT_MENU:int = 1;
      
      public static const ACTION_SOURCE_LOOK_INSIDE_UI:int = 2;
      
      public static const PART_ASK_METHOD_R4R:String = "R4R";
      
      public static const ASK_PARTS_MFS_ASKITEMS_REACTS:String = "MFSAskItemsReacts";
      
      public static const PART_ASK_METHOD_FEED:String = "feed";
      
      public static const PART_ASK_METHOD_CRAFT:String = "craft";
      
      public static const DEFAULT_PART_ASK_METHOD:String = PART_ASK_METHOD_R4R;
      
      public static const DRAGON_BREEDING:String = "dragon_pen_finished";
      
      public static const METADATA_KEY:String = "metadata";
      
      public static const METADATA_INDEX_KEY:String = "metadataIndex";
      
      private static var m_classCompilingArray:Array = [ContextMenuFManager,ExpandFManager,HarvestFManager,RewardHarvestFManager,MoneyTree2017HarvestFManager,AmexHarvestFManager,FeaturedRenderFManager,FeaturedRenderDecalFManager,TileRenderManager,NeighborActionFManager,PigPenHarvestFManager,FarmVillageResourceBuildingHarvestFManager,AnimalBreedingHarvestFManager,SeedDispenserHarvestFManager,StorageFManager,LimitedHarvestTimeTooltipFManager,SocialRaffleTooltipFManager,ImageProgressionFManager,GiftedContentsStorageFManager,InitializerFManager,AmexInitFManager,WitherManager,UpgradeManager,StorageLevelNameManager,TutorialFManager,ContaineeFManager,InstantGrowFManager,WaterHarvestFManager,IrrigationWellTooltipFManager,GivingBuildingTooltipFManager];
      
      public const EXPAND_ACTION:String = "expand";
      
      protected var m_featureManagers:Dictionary = new Dictionary();
      
      protected var m_featurePrereqs:Dictionary = new Dictionary();
      
      protected var m_localizationMap:Dictionary = new Dictionary();
      
      protected var m_assetKey:String = "";
      
      protected var m_featuredItems:Object = {};
      
      private var m_storageDialog:ConstructionBuildingWithdrawal;
      
      private var m_currentFeatureXML:XML = null;
      
      private var m_stageStartingPartCount:int = 0;
      
      private var m_lastMetaHashRemoved:String = "";
      
      private var m_lastMetadataRemoved:String = "";
      
      protected var m_disableBuildOnPlace:Boolean;
      
      protected var m_bundleData:Array = new Array();
      
      protected var m_feedAction:Array = new Array();
      
      protected var m_feedStatsKingdom:Array = new Array();
      
      protected var m_feedStatsClass:Array = new Array();
      
      protected var m_callbackFunction:Function = null;
      
      protected var m_callbackFunctionOnAccept:Function = null;
      
      private var m_storageMetadata:Object = {};
      
      protected const ADDTOKEN_OBJECT:String = "openSlotMachine";
      
      protected const FLOWERSHACK_OBJECT:String = "flowershack";
      
      protected const OVERLAY_OVERRIDE_NONE:int = -1;
      
      protected var m_overlayOverride:int = -1;
      
      protected var m_dialogConfig:Object = null;
      
      private var m_dialogTemplateXML:Object = null;
      
      protected var m_expandCompleteCallback:Function = null;
      
      public function FeatureBuilding(itemName:String = null)
      {
         super(itemName);
         this.storageLevel = 1;
         this.attachFeatureManagers();
         if(this.expand)
         {
            this.expand.initialize(this.frictionlessExpand,this.beginCompleteExpansionFlow);
            this.expand.storageLevel = this.storageLevel;
         }
         var thisItem:FarmItem = this.getItem();
         this.m_assetKey = thisItem.assetKey === null ? thisItem.name : thisItem.assetKey;
         setNumImageStates();
         if(this.m_featureManagers != null && this.m_featureManagers.expand != null && this.m_featureManagers.expand.maxExpansionLevel() >= 0)
         {
            this.setOverlayOverride(this.m_featureManagers.expand.maxExpansionLevel());
         }
         else
         {
            m_overlayVersion = this.storageLevel - 1;
         }
         var farmGameSettingsManager:FarmGameSettingsManager = Global.farmGameSettingsManager;
         this.m_dialogConfig = farmGameSettingsManager.getBuildingDialogConfig(thisItem.name);
         this.m_dialogTemplateXML = farmGameSettingsManager.getBuildableDialogXml(thisItem.name);
         if(thisItem.type != "building")
         {
            m_surfacingKeyword = thisItem.type;
         }
         if(farmGameSettingsManager.getDeprecatorSettings(this.getItemName()) != null)
         {
            Global.world.addTimedActionToQueue(new FeatureBuildingDeprecationTimedAction(Number(GlobalEngine.getFlashVar("TIMED_ACTION_MILLISECONDS_OPS")),this));
         }
      }
      
      public static function buildMetaDataHash(itemCode:String, hash:String) : String
      {
         return itemCode + ":" + hash;
      }
      
      public static function parseMetaDataHash(hash:String) : Array
      {
         var newArray:Array = new Array();
         if(hash != "" && hash != null)
         {
            newArray = hash.split(":",2);
         }
         return newArray;
      }
      
      public static function getFarmItemForHash(hash:String) : FarmItem
      {
         var hashSplit:Array = parseMetaDataHash(hash);
         return Global.farmGameSettingsManager.getFarmItemByCode(hashSplit[0]);
      }
      
      public static function renderBackgroundAnimation() : void
      {
         var overlayURL:String = "assets/overlays/effect_sapling_sparkling.swf";
      }
      
      override public function refreshExpansionParts(parts:Object) : void
      {
         if(this.expand)
         {
            this.expand.refreshPartData({"expansionParts":parts});
         }
         else
         {
            super.refreshExpansionParts(parts);
         }
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         super.createDisplayObject();
         this.setState(state);
         return m_displayObject;
      }
      
      override public function move() : void
      {
         FarmStatsManager.count(this.getItem().name,"level1","move");
         super.move();
      }
      
      override public function sell() : void
      {
         var featureMessagingName:String = null;
         FarmStatsManager.count(this.getItem().name,"level1","sell");
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(buildingItem)
         {
            featureMessagingName = buildingItem.buildingName;
         }
         else
         {
            featureMessagingName = m_itemName;
         }
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(featureMessagingName);
         super.sell();
      }
      
      public function setFeaturedItem(slot:Number, itemCode:String, metaHash:String, removeOrAdd:Boolean, sendTransaction:Boolean) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.renderer) && slot >= 0)
         {
            if(removeOrAdd)
            {
               this.m_featuredItems[slot] = {};
               this.m_featuredItems[slot].itemCode = itemCode;
               this.m_featuredItems[slot].metaHash = metaHash;
            }
            else
            {
               delete this.m_featuredItems[slot];
            }
            if(sendTransaction)
            {
               addTransaction(new TSetFeaturedItem(this,slot,itemCode,metaHash,removeOrAdd),true);
            }
            this.setState(FeatureBuilding.STATE_BARE);
            result = true;
         }
         return result;
      }
      
      override public function shouldCopyPlantTimeWhenReplacing() : Boolean
      {
         return true;
      }
      
      public function saveFeaturedItems() : void
      {
         addTransaction(new TSetMultipleFeaturedItems(this,this.m_featuredItems),true);
      }
      
      public function get lastMetaHashRemoved() : String
      {
         return this.m_lastMetaHashRemoved;
      }
      
      public function set lastMetaHashRemoved(value:String) : void
      {
         this.m_lastMetaHashRemoved = value;
      }
      
      public function get lastMetadataRemoved() : String
      {
         return this.m_lastMetadataRemoved;
      }
      
      public function set lastMetadataRemoved(value:String) : void
      {
         this.m_lastMetadataRemoved = value;
      }
      
      public function getFeaturedItems() : Object
      {
         return this.renderer ? this.m_featuredItems : null;
      }
      
      public function get currentFeatureXML() : XML
      {
         return this.m_currentFeatureXML;
      }
      
      public function set expandCompleteCallback(callback:Function) : void
      {
         this.m_expandCompleteCallback = callback;
      }
      
      public function displayDialog(name:String, params:Object = null) : void
      {
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         var buildingDialog:* = undefined;
         var popupName:String = null;
         var dialogConfig:Object = getItem().getDialogConfig(name);
         if(ObjectUtil.pathExists(dialogConfig,"className"))
         {
            dialogClassName = dialogConfig.className;
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            if(ObjectUtil.objectHasProperties(params))
            {
               buildingDialog = new dialogClass(params);
            }
            else
            {
               buildingDialog = new dialogClass();
            }
            if(params.popupName)
            {
               popupName = params.popupName;
            }
            else
            {
               popupName = dialogClassName;
            }
            UI.displayPopup(buildingDialog,true,popupName,true);
         }
      }
      
      protected function attachFeatureManagers() : void
      {
         var featuresDataArray:Array = null;
         var featureData:BaseDataSource = null;
         var name:String = null;
         var className:String = null;
         var featureManagerClass:Class = null;
         var featuresXML:XMLList = null;
         var featureXML:XML = null;
         var featureName:String = null;
         var featureClassName:String = null;
         var managerClass:Class = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featuresDataArray = this.getFarmItem().getFeaturesData();
            if(featuresDataArray != null)
            {
               for each(featureData in featuresDataArray)
               {
                  name = featureData.getString("name");
                  className = featureData.getString("className");
                  try
                  {
                     featureManagerClass = getDefinitionByName("Classes.FeatureComponents." + className) as Class;
                     this.featureManagers[name] = new featureManagerClass(this);
                     if(featureData.hasProperty("prereq"))
                     {
                        this.m_featurePrereqs[name] = new CachedPrereqChecker(PrerequisiteUtility.parseDataSourcePrereqs(featureData.getArray("prereq")),this);
                     }
                  }
                  catch(e:ReferenceError)
                  {
                     ErrorManager.addError("Type is not found " + className,ErrorManager.ERROR_REMOTEOBJECT_FAULT);
                  }
               }
            }
         }
         else
         {
            featuresXML = this.getFarmItem().getFeaturesXML();
            if(featuresXML)
            {
               for each(featureXML in featuresXML)
               {
                  try
                  {
                     this.m_currentFeatureXML = featureXML;
                     featureName = this.m_currentFeatureXML.@name;
                     featureClassName = this.m_currentFeatureXML.@className;
                     managerClass = getDefinitionByName("Classes.FeatureComponents." + featureClassName) as Class;
                     this.featureManagers[featureName] = new managerClass(this);
                     if(featureXML.hasOwnProperty("prereq"))
                     {
                        this.m_featurePrereqs[featureName] = new CachedPrereqChecker(PrerequisiteUtility.parseXmlNodePrereqs(featureXML.prereq),this);
                     }
                  }
                  catch(e:ReferenceError)
                  {
                     ErrorManager.addError("Type is not found " + featureClassName,ErrorManager.ERROR_REMOTEOBJECT_FAULT);
                  }
               }
            }
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         var buildingItem:FarmItem = null;
         var feedName:String = null;
         var expansionComponent:IExpandComponent = null;
         super.onBuildComplete(result);
         this.setState(STATE_BUILT);
         var statsKingdom:String = this.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM;
         var feedIcon:String = getItem().getImageByName("startIcon",false);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            feedIcon = getItem().getImageByName("feed",false);
         }
         else if(!feedIcon)
         {
            feedIcon = getItem().getImageByName("icon",false);
         }
         if(Boolean(result.rewardLink) && result.rewardLink != "")
         {
            buildingItem = getItem();
            feedName = this.bldgName + "BeginBuilding";
            if(!ZLocUtils.hasString("Dialogs",feedName))
            {
               feedName = buildingItem.type + "_BeginBuilding";
            }
            this.createPlacementFeed(feedName,statsKingdom,result.rewardLink,feedIcon,this.onBuildFeedComplete,buildingItem.icon,this.onBuildFeedComplete,null,{"building":ZLocUtils.tk_pk(m_item.friendlyName)},StatsTrackingConstants.DIALOG_STATE_PLACE_KINGDOM,FALLBACK_KEY + "BeginBuilding",{"subcategory":m_item.name});
         }
         else
         {
            expansionComponent = this.expand;
            if(expansionComponent != null && !expansionComponent.hasReachedMaxExpansionLevel())
            {
               if(expansionComponent.showExpansionOnBuild)
               {
                  this.displayExpandDialog();
               }
            }
         }
         var initializerComponent:IInitializeComponent = this.initializer;
         if(initializerComponent != null)
         {
            initializerComponent.initializeOnPlace();
         }
      }
      
      protected function createPlacementFeed(feedActionName:String, statsKingdom:String, rewardLink:String, iconURL:String, postFeedCallback:Function = null, dialogIconURL:String = null, postFeedCallbackAccept:Function = null, friendlyItemName:String = null, locParams:Object = null, statsClass:String = "", fallbackAction:String = null, fallbackStats:Object = null) : void
      {
         var messageLocalizationKey:String = null;
         var bundleItem:Object = null;
         var localizedText:String = null;
         var message:GenericIconPopup = null;
         var hasLocalization:Boolean = false;
         if(ZLocUtils.hasString("Dialogs",feedActionName))
         {
            messageLocalizationKey = feedActionName;
            hasLocalization = true;
         }
         else if(Boolean(fallbackAction) && ZLocUtils.hasString("Dialogs",fallbackAction))
         {
            messageLocalizationKey = fallbackAction;
            hasLocalization = true;
         }
         if(Boolean(rewardLink) && hasLocalization)
         {
            this.m_feedAction.push(feedActionName);
            this.m_feedStatsKingdom.push(statsKingdom);
            this.m_feedStatsClass.push(statsClass);
            this.m_callbackFunction = postFeedCallback;
            this.m_callbackFunctionOnAccept = postFeedCallbackAccept;
            iconURL = Global.getAssetURL(iconURL);
            bundleItem = {
               "first_name":Global.player.firstName,
               "reward_link":rewardLink,
               "building":m_item.friendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":iconURL
               }]
            };
            if(fallbackAction)
            {
               bundleItem["fallbackAction"] = fallbackAction;
            }
            if(fallbackStats)
            {
               bundleItem["fallbackStats"] = fallbackStats;
            }
            if(friendlyItemName != null)
            {
               bundleItem["item"] = friendlyItemName;
            }
            this.m_bundleData.push(bundleItem);
            if(!dialogIconURL)
            {
               dialogIconURL = iconURL;
            }
            if(locParams)
            {
               localizedText = ZLocUtils.t("Dialogs",messageLocalizationKey,locParams);
            }
            else
            {
               localizedText = ZLocUtils.t("Dialogs",messageLocalizationKey);
            }
            message = new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,dialogIconURL);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.getItem().name,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            UI.displayPopup(message,true);
         }
         else if(Config.DEBUG_MODE)
         {
            if(hasLocalization)
            {
               if(rewardLink)
               {
               }
            }
         }
      }
      
      protected function onConfirmShareFeed(event:GenericPopupEvent) : void
      {
         var feedAction:String = this.m_feedAction.pop();
         var statsKingdom:String = this.m_feedStatsKingdom.pop();
         var statsClass:String = this.m_feedStatsClass.pop();
         var bundleData:Object = this.m_bundleData.pop();
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.getItem().name,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            if(this.m_callbackFunctionOnAccept != null)
            {
               this.m_callbackFunctionOnAccept();
            }
         }
         else
         {
            addTransaction(new TCancelFriendReward([bundleData["reward_link"]]));
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.getItem().name,"level1",statsClass,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            if(this.m_callbackFunction != null)
            {
               this.m_callbackFunction();
            }
         }
         this.m_callbackFunction = null;
      }
      
      public function requestExpansionPart(farmItem:FarmItem, callback:Function = null, overrideAskType:String = "", feedBundleName:String = "featureBuildingAskPart") : void
      {
         var expandAskType:String = null;
         var friendSpec:Object = null;
         var friendTabOrder:Array = null;
         var askType:String = DEFAULT_PART_ASK_METHOD;
         if(overrideAskType)
         {
            askType = overrideAskType;
         }
         else if(this.expand)
         {
            expandAskType = this.expand.getPartAskMethod(farmItem.code);
            if(expandAskType)
            {
               askType = expandAskType;
            }
         }
         var buildingItem:BuildingItem = this.getItem() as BuildingItem;
         switch(askType)
         {
            case PART_ASK_METHOD_FEED:
               generateRequestExpansionPartFeed(farmItem,callback,feedBundleName);
               if(buildingItem)
               {
                  FeatureTrackingManager.instance.postFeed(buildingItem.buildingName);
               }
               break;
            case ASK_PARTS_MFS_ASKITEMS_REACTS:
               friendSpec = {"tabNameRecommended":[MFSConstants.TYPE_TRIPLE_PARTS,MFSConstants.TYPE_REACTIVATION]};
               friendTabOrder = ["tabNameRecommended"];
               MFSRequestManager.getInstance().makeAskItemsRequest(this.getItem().name,farmItem.name,"","","",friendSpec,friendTabOrder);
               if(buildingItem)
               {
                  FeatureTrackingManager.instance.sendR4R(buildingItem.buildingName);
               }
               if(callback != null)
               {
                  callback(true);
               }
               break;
            case PART_ASK_METHOD_R4R:
            default:
               MFSRequestManager.getInstance().makeAskMatsRequest(this.getItem().name,farmItem.name,"","1",MFSConstants.SOURCE_DIALOG_CLICKED);
               if(buildingItem)
               {
                  FeatureTrackingManager.instance.sendR4R(buildingItem.buildingName);
               }
               if(callback != null)
               {
                  callback(true);
               }
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         var featureName:String = null;
         var featureMessagingName:String = null;
         var contents:Array = null;
         var family:String = null;
         var storedItem:Object = null;
         super.loadObject(data);
         var item:FarmItem = this.getItem();
         var animalsDisappearedRuntimeKey:String = "FEATURE_FLASHPARAM_PEN_CONTENTS_SAMPLE";
         if(GlobalEngine.getFlashVar(animalsDisappearedRuntimeKey) != null && item != null && item.subType == "storage")
         {
            contents = data["contents"] as Array;
            family = "";
            for each(storedItem in contents)
            {
               family += storedItem.itemCode + ":" + storedItem.numItem + " ";
            }
            FarmStatsManager.sample(int(GlobalEngine.getFlashVar(animalsDisappearedRuntimeKey)),"ItemsInPenStorage",this.getItemName(),contents.length.toString(),family);
         }
         if(data.hasOwnProperty("storageMetadata"))
         {
            this.m_storageMetadata = data.storageMetadata;
         }
         if(data.featuredItems)
         {
            this.m_featuredItems = data.featuredItems;
         }
         if(data.hasOwnProperty("overlayOverride"))
         {
            this.setOverlayOverride(data.overlayOverride);
         }
         for(featureName in this.featureManagers)
         {
            this.featureManagers[featureName].loadObject(data);
         }
         if(this.witherer)
         {
            m_witherTime = getWitherTime(data.plantTime,data.position.x,data.position.y,FarmGameUtil.NUM_MSECS_IN_DAY * this.witherer.witherDays);
         }
         setNumImageStates();
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(buildingItem)
         {
            featureMessagingName = buildingItem.buildingName;
         }
         else
         {
            featureMessagingName = m_itemName;
         }
         FeatureMessagingManager.getInstance().registerFeatureInitialized(featureMessagingName,this.displayStorageDialog,this);
         if(Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"])
         {
            if(data.startingPartCount)
            {
               this.m_stageStartingPartCount = data.startingPartCount;
            }
         }
      }
      
      public function isFeatureProgressComplete() : Boolean
      {
         return !this.expand || this.hasReachedMaxExpansionLevel();
      }
      
      public function getStorageMetaDataForCode(itemCode:String) : Array
      {
         var key:String = null;
         var dataObj:Object = null;
         var storageObjs:Array = new Array();
         for(key in this.m_storageMetadata)
         {
            if(key.indexOf(itemCode) >= 0)
            {
               for each(dataObj in this.m_storageMetadata[key])
               {
                  storageObjs.push({
                     "key":key,
                     "data":dataObj
                  });
               }
            }
         }
         return storageObjs;
      }
      
      public function getFarmItem() : FarmItem
      {
         return m_item as FarmItem;
      }
      
      public function get content() : DisplayObject
      {
         return m_content;
      }
      
      public function witherTime(buildingWitherTime:Number) : Number
      {
         var position:Vector3 = getPosition();
         return this.getWitherTime(this.m_plantTime,position.x,position.y,buildingWitherTime);
      }
      
      override public function onClick() : void
      {
         var state:AMHarvest = null;
         this.onMouseOut();
         if(this.arrowIndicator != null && this.getState() != this.STATE_BUSY)
         {
            if(!this.arrowIndicator.indicatorCurrentlyHidden)
            {
               this.arrowIndicator.hide();
               if(this.arrowIndicator.lookInsideOnClick && Boolean(this.getState()))
               {
                  this.arrowIndicator.onClick();
                  this.displayStorageDialog();
                  return;
               }
            }
         }
         if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(this.isWithered())
         {
            this.witherer.onClick();
         }
         else if(this.isReadyForHarvest())
         {
            state = Global.selectedAvatar.getStateMachine().getState() as AMHarvest;
            if(state != null && state.getResource() != this || state == null)
            {
               Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
               m_isInHarvestQueue = true;
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      public function hideIndicator() : void
      {
         if(this.arrowIndicator != null && !this.arrowIndicator.indicatorCurrentlyHidden)
         {
            this.arrowIndicator.hide();
         }
      }
      
      public function showIndicator() : void
      {
         if(this.arrowIndicator != null && this.arrowIndicator.indicatorCurrentlyHidden)
         {
            this.arrowIndicator.show();
         }
      }
      
      private function isReadyForHarvest() : Boolean
      {
         return this.isHarvestable() && state == STATE_RIPE && Global.selectedAvatar != null && !Global.worldManager.isVisiting();
      }
      
      override public function isHarvestEnabled() : Boolean
      {
         return this.harvester != null && (!this.witherer || !this.witherer.isWithered());
      }
      
      public function isWithered() : Boolean
      {
         return this.isWitheredState() && Global.selectedAvatar != null && !Global.worldManager.isVisiting() && Boolean(this.witherer) && this.witherer.isWithered();
      }
      
      public function isWitheredState() : Boolean
      {
         return state == STATE_WITHERED;
      }
      
      public function isWitherEnabled() : Boolean
      {
         return this.witherer != null;
      }
      
      override public function isBuilt() : Boolean
      {
         return state == STATE_BUILT || state == STATE_CONSTRUCTION || state == STATE_RIPE || state == STATE_BARE || state == STATE_WITHERED || state.search(STATE_BUILT) >= 0;
      }
      
      public function get featuredItems() : Object
      {
         var result:Object = null;
         if(this.renderer)
         {
            result = this.m_featuredItems;
         }
         return result;
      }
      
      public function get featureManagers() : Dictionary
      {
         return this.m_featureManagers;
      }
      
      override public function get storageLevel() : int
      {
         return m_storageLevel;
      }
      
      override public function set storageLevel(storageLevel:int) : void
      {
         m_storageLevel = storageLevel;
         if(this.expand)
         {
            this.expand.storageLevel = storageLevel;
         }
      }
      
      override public function get contents() : Dictionary
      {
         return m_contents;
      }
      
      public function set contents(contents:Dictionary) : void
      {
         m_contents = contents;
      }
      
      override public function get capacity() : Number
      {
         return m_capacity;
      }
      
      public function set capacity(capacity:Number) : void
      {
         m_capacity = capacity;
      }
      
      override public function get count() : Number
      {
         return m_count;
      }
      
      public function set count(count:Number) : void
      {
         m_count = count;
      }
      
      public function get bldgName() : String
      {
         var nameString:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nameString = this.m_item.getStringFromDataSource("buildingName");
         }
         else
         {
            nameString = this.m_item.xml.@buildingName;
         }
         return nameString;
      }
      
      override public function updateAnimation(delta:int) : void
      {
         super.updateAnimation(delta);
         if(m_overlay != null && m_overlayXML.@hasAnimation == "true" && m_overlay is AnimationPlayer && Global.playOverlayEffects)
         {
            (m_overlay as AnimationPlayer).update(delta);
         }
      }
      
      public function get assetKey() : String
      {
         return this.m_assetKey;
      }
      
      override public function set isBusy(busy:Boolean) : void
      {
         m_isBusy = busy;
      }
      
      override public function get isBusy() : Boolean
      {
         return m_isBusy;
      }
      
      public function get isInHarvestQueue() : Boolean
      {
         return m_isInHarvestQueue;
      }
      
      public function set isInHarvestQueue(isInHarvestQueue:Boolean) : void
      {
         m_isInHarvestQueue = isInHarvestQueue;
      }
      
      public function get storageDialog() : ConstructionBuildingWithdrawal
      {
         return this.m_storageDialog;
      }
      
      public function getDialogConfig() : Object
      {
         return this.m_dialogConfig;
      }
      
      public function getDialogTemplateXML() : Object
      {
         return this.m_dialogTemplateXML;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         var suppressDialog:Boolean = Boolean(this.storage) && !this.storage.showStorageContextMenu();
         if(!suppressDialog)
         {
            if(Boolean(this.storage) && Boolean(this.capacity <= 0) && this.m_item.getFinishedName() != "")
            {
               this.showConstructionDialog(defaultAction);
            }
            else
            {
               this.showLookInsideDialog(defaultAction);
            }
            FeatureTrackingManager.instance.uiOpen(this.bldgName);
         }
      }
      
      private function showConstructionDialog(defaultAction:String = "") : void
      {
         if(!this.showStorageContextMenu())
         {
            return;
         }
         var storage4DDialog:StorageWithdrawalDynamicDialog = FarmDynamicDialog.createDialog("AnimalBreedingWildlife",StorageWithdrawalDynamicDialog) as StorageWithdrawalDynamicDialog;
         if(storage4DDialog != null)
         {
            storage4DDialog.addImport("building",this);
            storage4DDialog.addImport("defaultAction",defaultAction);
            storage4DDialog.addImport("title",this.getItem().friendlyTitle);
            storage4DDialog.addImport("keepOpenAfterBuy",true);
            storage4DDialog.setup();
            storage4DDialog.show(true);
         }
      }
      
      public function showLookInsideDialogFromConfig(dialogConfig:Object, defaultAction:String = "") : void
      {
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         var buildingDialog:* = undefined;
         if(dialogConfig.className)
         {
            dialogClassName = dialogConfig.className;
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            buildingDialog = new dialogClass(this);
            if(defaultAction == this.EXPAND_ACTION && "setExpansionViewActive" in buildingDialog)
            {
               buildingDialog.setExpansionViewActive();
            }
            UI.displayPopup(buildingDialog,true,dialogClassName,true);
         }
      }
      
      private function showLookInsideDialog(defaultAction:String = "") : void
      {
         var dialogConfig:Object = null;
         var classStringArray:Array = null;
         var shouldCreateNewDialog:Boolean = false;
         var isFeedFixEnabled:Boolean = false;
         var dialog:* = undefined;
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         if(this.m_dialogConfig != null)
         {
            this.showLookInsideDialogFromConfig(this.m_dialogConfig,defaultAction);
         }
         else
         {
            dialogConfig = this.getItem().getDialogConfig("storage");
            if(dialogConfig)
            {
               dialogClassName = dialogConfig.className;
               classStringArray = dialogClassName.split(".");
               if(classStringArray[0] == "Display")
               {
                  dialogClassName = classStringArray[1];
               }
               if(dialogClassName.indexOf(".") < 1)
               {
                  dialogClass = getDefinitionByName("Display." + dialogClassName) as Class;
                  shouldCreateNewDialog = true;
                  isFeedFixEnabled = Boolean(Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"]);
                  if(isFeedFixEnabled)
                  {
                     shouldCreateNewDialog = !this.m_storageDialog || UI.getCurrentPopup() != this.m_storageDialog;
                  }
                  if(shouldCreateNewDialog)
                  {
                     this.m_storageDialog = new dialogClass(this);
                  }
                  if(isFeedFixEnabled)
                  {
                     this.m_storageDialog.addEventListener(Event.CLOSE,this.onStorageDialogClosed);
                  }
                  if(defaultAction == CHOOSEVISUAL_ACTION)
                  {
                     this.m_storageDialog.useChooseVisualDialog();
                  }
                  else if(defaultAction == this.EXPAND_ACTION && "setExpansionViewActive" in this.m_storageDialog)
                  {
                     (this.m_storageDialog as dialogClass).setExpansionViewActive();
                  }
                  if(shouldCreateNewDialog)
                  {
                     UI.displayStorageDialog(this.m_storageDialog,true,dialogClassName,true);
                  }
               }
               else
               {
                  dialogClass = getDefinitionByName(dialogClassName) as Class;
                  dialog = new dialogClass(this);
                  if(defaultAction == this.EXPAND_ACTION && "setExpansionViewActive" in dialog)
                  {
                     dialog.setExpansionViewActive();
                  }
                  UI.displayPopup(dialog,true,dialogClassName,true);
               }
            }
         }
      }
      
      public function onSelectOverlay(level:int) : void
      {
         this.setOverlayOverride(level);
         addTransaction(new TSetOverlayOverride(this,level,null));
      }
      
      public function setOverlayOverride(level:int, reload:Boolean = true) : void
      {
         this.m_overlayOverride = level;
         if(reload)
         {
            reloadImage();
         }
      }
      
      override public function getCurrentSuffix() : int
      {
         var numImageStates:int = 0;
         var capacity:int = 0;
         var initialExpansionLevel:int = 0;
         var curDataSource:BaseDataSource = null;
         var result:int = 0;
         if(this.OVERLAY_OVERRIDE_NONE != this.m_overlayOverride)
         {
            result = this.m_overlayOverride - 1;
         }
         else
         {
            numImageStates = m_numImageStates;
            capacity = m_capacity;
            if(!m_isFullyBuilt)
            {
               numImageStates = m_numConstructImageStates;
               capacity = getMaterialsNeeded();
               if(m_count < capacity)
               {
                  numImageStates++;
               }
            }
            if(numImageStates > 1)
            {
               if(m_storageLevel)
               {
                  result = m_storageLevel - 1;
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_item.hasPropertyInDataSource("initialExpansionLevel"))
               {
                  initialExpansionLevel = m_item.getIntFromDataSource("initialExpansionLevel");
                  result = Math.max(result,initialExpansionLevel - 1);
               }
               curDataSource = m_item.getFeatureDataByName(FeatureManager.EXPAND_FEATURE_NAME);
               if(curDataSource != null && curDataSource.hasProperty("infiniteUpgradeData") && m_storageLevel > numImageStates)
               {
                  result = numImageStates - 1;
               }
            }
            else
            {
               if(m_item.xml.hasOwnProperty("initialExpansionLevel"))
               {
                  initialExpansionLevel = int(m_item.xml.initialExpansionLevel);
                  result = Math.max(result,initialExpansionLevel - 1);
               }
               if(m_item.xml.descendants("infiniteUpgradeData").length() > 0 && m_storageLevel > numImageStates)
               {
                  result = numImageStates - 1;
               }
            }
         }
         return result;
      }
      
      override protected function getConstructionImageName() : String
      {
         return "built_" + this.getCurrentSuffix();
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         var result:Boolean = super.showStorageContextMenu();
         if(result && Boolean(this.storage))
         {
            result = this.storage.showStorageContextMenu();
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         if(this.state == STATE_BUSY || !Global.worldManager.isWorldSwapStable)
         {
            showObjectBusy();
         }
         else
         {
            if(this.getItem().getExpansion() != "")
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Items","storage_expand"),
                  "action":EXPAND_OBJECT
               });
            }
            if(this.slotmachine)
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Items","openSlotMachine"),
                  "action":this.ADDTOKEN_OBJECT
               });
            }
            if(this.contextMenu)
            {
               m_menuItems = this.contextMenu.appendMenuItems(m_menuItems);
            }
            super.showMenu();
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ADDTOKEN_OBJECT:
                  this.slotmachine.displayWindow();
                  break;
               case this.FLOWERSHACK_OBJECT:
                  FlowerShackManager.getInstance(FlowerShackManager.FEATURE_NAME).showUI();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
         if(this.contextMenu != null)
         {
            this.contextMenu.onMenuClick(event);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var capacityText:String = null;
         var mode:GameMode = null;
         var partName:String = null;
         var growPercentage:int = 0;
         var harvestTimeVariant:int = 0;
         var expander:IExpandComponent = null;
         var extraTooltip:String = null;
         var toolTip:String = null;
         if(Global.worldManager.isWorldSwapStable)
         {
            if(isHighlighted() && Global.worldManager.isVisiting() == false)
            {
               capacityText = "";
               mode = Global.world.getTopGameMode();
               if(mode is GMBuildingPart)
               {
                  if((mode as GMBuildingPart).buildingPart)
                  {
                     partName = (mode as GMBuildingPart).buildingPart.itemName;
                     if(!this.containeeManager || !this.containeeManager.isValidContaineePart(partName))
                     {
                        capacityText = getBuildingPartCapacityToolTipText(partName);
                     }
                  }
               }
               else if(!isFullyBuilt())
               {
                  capacityText = ZLocUtils.t("Items",m_item.name + "_mats",{
                     "quantity":m_count,
                     "maximum":this.capacity
                  });
               }
               else if(Boolean(this.storage) && this.storage.capacity > 0)
               {
                  capacityText = ZLocUtils.t("Items",m_item.name + "_storageCapacity",{
                     "quantity":this.count,
                     "maximum":this.capacity
                  });
               }
               switch(state)
               {
                  case STATE_RIPE:
                     if(Boolean(this.harvester) && this.harvester.canHarvest())
                     {
                        toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                           "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                           "capacityStr":capacityText
                        });
                     }
                     else
                     {
                        toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                           "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                           "capacityStr":capacityText
                        });
                     }
                     break;
                  case STATE_BARE:
                     if(this.harvester)
                     {
                        if(this.harvester.canHarvest())
                        {
                           growPercentage = getGrowPercentage();
                           if(ZLocUtils.hasString("Dialogs",this.bldgName + "_toolTip"))
                           {
                              toolTip = ZLocUtils.t("Dialogs",this.bldgName + "_toolTip",{
                                 "building":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                                 "percent":growPercentage,
                                 "maximum":capacityText,
                                 "dateStr":getItem().limitedEndDate
                              });
                           }
                           else
                           {
                              harvestTimeVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_TIME_2);
                              if(RetentionMasterManager.inMasterExperiment() && (harvestTimeVariant == 2 || harvestTimeVariant == 4))
                              {
                                 toolTip = getHarvestTimeText("AnimalBuilding_toolTip_time") + "\n" + capacityText;
                              }
                              else
                              {
                                 toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_toolTip",{
                                    "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                                    "quantity":growPercentage,
                                    "capacityStr":capacityText
                                 });
                              }
                           }
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                              "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                              "capacityStr":capacityText
                           });
                        }
                     }
                     else
                     {
                        expander = this.expand;
                        if(Boolean(ZLocUtils.hasString("Dialogs",m_item.type + "_mats")) && Boolean(expander) && !expander.hasReachedMaxExpansionLevel())
                        {
                           toolTip = ZLocUtils.t("Dialogs",m_item.type + "_mats",{
                              "item":ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName()),
                              "quantity":expander.getTotalExpansionPartCount(),
                              "maximum":expander.getTotalExpansionLimitCount(),
                              "part":ZLocUtils.tk_pk_asTitle("Items:" + expander.getExpansionPartString() + "_friendlyName")
                           });
                        }
                        else
                        {
                           toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
                        }
                     }
                     break;
                  case STATE_CONSTRUCTION:
                  case STATE_BUILT:
                     toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                        "item":ZLocUtils.tk_pk(this.getItemFriendlyName()),
                        "capacityStr":capacityText
                     });
                     break;
                  case STATE_WITHERED:
                     toolTip = ZLocUtils.t("Dialogs","toolTip_Withered",{"item":ZLocUtils.tk_pk(this.getItemFriendlyName())});
                     break;
                  default:
                     toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
               }
            }
            else if(isHighlighted() && Global.worldManager.isVisiting() == true)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
            }
            if(this.tooltipText != null)
            {
               extraTooltip = this.tooltipText.getTooltip();
               toolTip += "\n" + extraTooltip;
            }
         }
         else
         {
            toolTip = ZLocUtils.t("FarmGame","LoadingFarm");
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function setState(value:String) : void
      {
         if(value == STATE_BUILT)
         {
            value = STATE_BARE;
         }
         if(this.renderer != null)
         {
            this.renderer.setState(value,this.m_featuredItems);
         }
         super.setState(value);
      }
      
      override public function getState() : String
      {
         return state;
      }
      
      override public function getToolTipCapacityText() : String
      {
         return ZLocUtils.t("Items",m_item.name + "_capacity",{
            "quantity":m_count,
            "maximum":this.capacity
         });
      }
      
      override public function getActionText() : String
      {
         var actionText:String = this.getFarmItem().actionText !== null ? this.getFarmItem().actionText : "Harvesting";
         return ZLocUtils.t("FarmGame",actionText);
      }
      
      override public function getHarvestCurrency() : String
      {
         return this.harvester != null ? this.harvester.getHarvestCurrency() : Currency.COINS;
      }
      
      override public function getHarvestAmount() : int
      {
         return this.harvester != null ? this.harvester.getHarvestAmount() : 0;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         if(!this.isHarvestable())
         {
            this.setState(FeatureBuilding.STATE_BARE);
            reloadImage();
         }
         if(this.m_bonusMultipliers != null)
         {
            this.m_bonusMultipliers.featureMultiplier = this.harvester.getHarvestYieldMultiplier(m_harvestYieldsGroup,this.m_item);
         }
         else
         {
            this.m_bonusMultipliers = {
               "coin":1,
               "xp":1,
               "mastery":1,
               "harvestYield":1,
               "featureMultiplier":1
            };
         }
         return super.doHarvestDropOff(avatar,showStatus);
      }
      
      private function addItemHelper(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false, number:int = 1) : Boolean
      {
         var success:Boolean = this.storage ? this.storage.addItemUsingCurrency(resource,fromStorage,isGift,sendStoreItem,force,m_purchaseCurrencyUnit,number) : false;
         if(!this.isValidContaineePart(resource))
         {
            if(this.getId() != 0 && this.getId() == fromStorage)
            {
               super.updatePlantTimeOnStore(m_count,resource);
            }
            else if(!this.isValidExpansionPart(resource))
            {
               updatePlantTimeOnStore(m_count,resource);
            }
            if(this.renderer != null)
            {
               this.renderer.addItem(resource);
            }
            if(!m_completeNowInProgress)
            {
               if(Boolean(this.storage) && Boolean(this.capacity <= 0) && !isGift)
               {
                  this.displayStorageDialog();
               }
               else if(isFullyBuilt() && Boolean(this.expand))
               {
                  if(this.contextMenu != null && this.contextMenu.getSpecificEntry(ContextMenuFManager.MENU_ACTION_CHOOSEVISUAL,ContextMenuFManager.MENU_GATE_FULLYEXPANDED) != null)
                  {
                     this.displayStorageDialog(FeatureBuilding.CHOOSEVISUAL_ACTION);
                  }
               }
            }
         }
         return success;
      }
      
      public function multiAddItem(resource:MapResource, number:int = 1, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var count:int = 0;
         var result:Boolean = true;
         if(!Global.flashHotParams["MULTISTORE_COMPLETENOW"])
         {
            count = 0;
            while(result && count < number)
            {
               result = this.addItemHelper(resource,fromStorage,isGift,sendStoreItem,force);
               count++;
            }
         }
         else
         {
            result = this.addItemHelper(resource,fromStorage,isGift,sendStoreItem,force,number);
         }
         return result;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var addClosure:Function = null;
         var popup:GenericIconPopup = null;
         var success:Boolean = false;
         if(resource.hasStorageDialog())
         {
            addClosure = function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.ACCEPT)
               {
                  success = addItemHelper(resource,fromStorage,isGift,sendStoreItem,force);
               }
            };
            popup = new GenericIconPopup(ZLocUtils.t("Dialogs",resource.getStorageDialogText()),GenericPopup.TYPE_ACCEPTCANCEL,addClosure,resource.getItem().icon,true,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true,false,"");
            UI.displayPopup(popup,false);
         }
         else
         {
            success = this.addItemHelper(resource,fromStorage,isGift,sendStoreItem,force);
         }
         return success;
      }
      
      override public function isInventoryBuilding() : Boolean
      {
         var result:Boolean = false;
         if(this.storage)
         {
            result = this.getStorageItemClass() == INVENTORY_CLASSNAME;
         }
         return result;
      }
      
      override public function isStorageBuilding() : Boolean
      {
         var result:Boolean = false;
         if(this.storage)
         {
            result = true;
         }
         return result;
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = false;
         var eachAnimalItem:FarmItem = null;
         var animal:String = null;
         result = super.isSellable();
         if(m_contents)
         {
            for(animal in m_contents)
            {
               eachAnimalItem = Global.farmGameSettingsManager.getFarmItemByCode(animal);
               if(Boolean(eachAnimalItem) && Boolean(m_contents.hasOwnProperty(animal)) && m_contents[animal] > 0)
               {
                  if(!eachAnimalItem.sellable)
                  {
                     result = false;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      override public function isHarvestable() : Boolean
      {
         var item:FarmItem = null;
         var isInExperiment:Boolean = false;
         var harvesterComponent:IHarvestComponent = null;
         var canHarvest:Boolean = false;
         var withererComponent:IWitherComponent = null;
         var isWithered:Boolean = false;
         var result:Boolean = false;
         if(super.isHarvestable())
         {
            item = getItem();
            if(!item)
            {
               GlobalEngine.error("FeatureBuilding","getItem returned null");
            }
            isInExperiment = item ? item.isInExperiment : false;
            if(isInExperiment)
            {
               harvesterComponent = this.harvester;
               canHarvest = harvesterComponent ? harvesterComponent.canHarvest() : false;
               if(canHarvest)
               {
                  withererComponent = this.witherer;
                  isWithered = withererComponent ? withererComponent.isWithered() : false;
                  if(!isWithered)
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      override protected function determineState(delta:Number) : void
      {
         var visit:Boolean = Global.worldManager.isVisiting();
         if((!visit && this.isHarvestable() || this.canFeedOnVisit() && visit) && state == STATE_BARE)
         {
            this.setState(STATE_RIPE);
         }
         else if(Boolean(this.witherer) && this.witherer.isWithered())
         {
            this.setState(STATE_WITHERED);
         }
      }
      
      private function getFeatureManagerIfPassesPrereq(featureName:String) : Object
      {
         var result:Object = null;
         if(this.m_featurePrereqs[featureName])
         {
            if(this.m_featurePrereqs[featureName].passesPrereqs(true))
            {
               result = this.m_featureManagers[featureName];
            }
         }
         else
         {
            result = this.m_featureManagers[featureName];
         }
         return result;
      }
      
      override protected function calculateCoinYield(itemXML:XML, item:FarmItem = null) : int
      {
         var result:int = 0;
         if(item)
         {
            result = item.getIntFromDataSource("coinYield");
         }
         else
         {
            result = int(itemXML.coinYield);
         }
         return result;
      }
      
      override public function isFull() : Boolean
      {
         return this.count >= this.capacity;
      }
      
      public function refreshStorageDialog(defaultAction:String = "") : void
      {
         if(this.m_storageDialog)
         {
            this.m_storageDialog.close();
            this.displayStorageDialog(defaultAction);
         }
      }
      
      override public function getStorageKeyFromMapResource(resource:MapResource) : String
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(resource.getItemName());
      }
      
      override protected function onBuilt() : void
      {
         var item:XML = null;
         var canAddItems:Boolean = false;
         var addDefaultItemsOnce:Boolean = false;
         var flagName:String = null;
         var itemName:String = null;
         var amount:int = 0;
         var defaultItem:FarmItem = null;
         var itemIdx:int = 0;
         var partIndex:int = 0;
         var expansionPart:MapResource = null;
         var classType:Class = null;
         var mapResource:MapResource = null;
         var defaultItemArr:Array = null;
         var curDefaultDS:BaseDataSource = null;
         this.setState(STATE_BUSY);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         var hasDefaultItem:Boolean = false;
         if(isInDataSourceExperiment)
         {
            hasDefaultItem = m_item.hasPropertyInDataSource("defaultItem");
         }
         else
         {
            item = m_item.xml;
            hasDefaultItem = item.defaultItem != null;
         }
         if(hasDefaultItem)
         {
            canAddItems = true;
            addDefaultItemsOnce = false;
            if(isInDataSourceExperiment)
            {
               addDefaultItemsOnce = m_item.getBoolFromDataSource("addDefaultItemsOnce");
            }
            else
            {
               addDefaultItemsOnce = "true" == item.addDefaultItemsOnce;
            }
            if(this.hasReachedMaxExpansionLevel())
            {
               canAddItems = false;
            }
            else if(addDefaultItemsOnce)
            {
               if(isInDataSourceExperiment)
               {
                  flagName = "defaultItems_" + m_item.code;
               }
               else
               {
                  flagName = "defaultItems_" + item["@code"];
               }
               if(Global.player.getSeenFlag(flagName))
               {
                  canAddItems = false;
               }
               else
               {
                  Global.player.setSeenFlag(flagName);
               }
            }
            if(canAddItems)
            {
               itemIdx = 0;
               if(isInDataSourceExperiment)
               {
                  defaultItemArr = m_item.getArrayFromDataSource("defaultItem");
                  for(itemIdx = 0; itemIdx < defaultItemArr.length; itemIdx++)
                  {
                     curDefaultDS = defaultItemArr[itemIdx] as BaseDataSource;
                     itemName = curDefaultDS.getString("name");
                     amount = curDefaultDS.getInt("amount");
                     defaultItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(defaultItem)
                     {
                        if(curDefaultDS.getBoolean("giftbox"))
                        {
                           Global.player.addGift(itemName,"0",amount);
                        }
                        else if(curDefaultDS.getBoolean("expansion"))
                        {
                           for(partIndex = 0; partIndex < amount; partIndex++)
                           {
                              expansionPart = new MapResource(itemName);
                              this.addExpansionPart(expansionPart);
                           }
                        }
                        else
                        {
                           this.addDefaultItems(defaultItem,amount);
                        }
                        if(curDefaultDS.getBoolean("render"))
                        {
                           classType = defaultItem.getMapResourceClass();
                           mapResource = new classType(defaultItem.name);
                           if(this.canTakeItem(mapResource))
                           {
                              if(this.renderer != null)
                              {
                                 this.renderer.addItem(mapResource);
                              }
                           }
                        }
                     }
                  }
               }
               else
               {
                  for(itemIdx = 0; itemIdx < item.defaultItem.length(); itemIdx++)
                  {
                     itemName = item.defaultItem[itemIdx]["@name"];
                     amount = int(item.defaultItem[itemIdx]["@amount"]);
                     defaultItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(defaultItem)
                     {
                        if(item.defaultItem[itemIdx]["@giftbox"] == "true")
                        {
                           Global.player.addGift(itemName,"0",amount);
                        }
                        else if(item.defaultItem[itemIdx]["@expansion"] == "true")
                        {
                           for(partIndex = 0; partIndex < amount; partIndex++)
                           {
                              expansionPart = new MapResource(itemName);
                              this.addExpansionPart(expansionPart);
                           }
                        }
                        else
                        {
                           this.addDefaultItems(defaultItem,amount);
                        }
                        if(item.defaultItem[itemIdx]["@render"] == "true")
                        {
                           classType = defaultItem.getMapResourceClass();
                           mapResource = new classType(defaultItem.name);
                           if(this.canTakeItem(mapResource))
                           {
                              if(this.renderer != null)
                              {
                                 this.renderer.addItem(mapResource);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      override protected function addDefaultItems(defaultItem:FarmItem, amount:int) : void
      {
         var instance:Object = null;
         var resourceMetaData:Object = null;
         var metaKey:String = null;
         var i:int = 0;
         super.addDefaultItems(defaultItem,amount);
         if(this.containeeManager)
         {
            instance = this.containeeManager.createResidentInstance(defaultItem.code);
            resourceMetaData = null;
            if(Boolean(instance) && instance.hasOwnProperty("getDefaultMetadata"))
            {
               resourceMetaData = instance.getDefaultMetadata();
            }
            if(resourceMetaData != null)
            {
               metaKey = instance.getMetadataKey();
               if(this.storageMetaData[metaKey] == null)
               {
                  this.storageMetaData[metaKey] = new Array();
               }
               while(i < amount)
               {
                  (this.storageMetaData[metaKey] as Array).push(resourceMetaData);
                  i++;
               }
            }
         }
      }
      
      public function get buildingReady() : BuildingReadyFManager
      {
         return this.m_featureManagers.buildingReady;
      }
      
      public function getFeatureReadyState() : void
      {
         this.buildingReady.getReadyState();
      }
      
      public function get expand() : IExpandComponent
      {
         return this.m_featureManagers.expand;
      }
      
      override public function onStoreExpandable(event:GenericPopupEvent) : void
      {
         return this.expand.onStoreExpandable(event);
      }
      
      public function get initializer() : IInitializeComponent
      {
         return this.m_featureManagers.initializer;
      }
      
      override public function isValidExpansionPart(resource:MapResource) : Boolean
      {
         var result:Boolean = false;
         if(this.expand)
         {
            result = this.expand.isValidExpansionPart(resource);
         }
         return result;
      }
      
      override public function isValidContaineePart(resource:MapResource) : Boolean
      {
         return this.containeeManager ? this.containeeManager.isValidContaineePart(resource.getItem().name) : false;
      }
      
      override public function getNextExpansionData() : XML
      {
         var result:XML = null;
         if(this.expand)
         {
            result = this.expand.getNextExpansionData();
         }
         return result;
      }
      
      override public function getNextExpansionDataSource() : BaseDataSource
      {
         var result:BaseDataSource = null;
         if(this.expand)
         {
            result = this.expand.getNextExpansionDataSource();
         }
         return result;
      }
      
      override public function getNextBuildingExpansionData() : BuildingExpansionData
      {
         var result:BuildingExpansionData = null;
         if(this.expand)
         {
            result = this.expand.getNextBuildingExpansionData();
         }
         return result;
      }
      
      override public function getExpansionPartCount(itemCode:String) : int
      {
         var result:int = 0;
         if(this.expand)
         {
            result = this.expand.getExpansionPartCount(itemCode);
         }
         return result;
      }
      
      public function getNumberOfPartsNeeded() : int
      {
         var result:int = 0;
         if(this.expand)
         {
            result = this.expand.getTotalExpansionLimitCount();
         }
         return result;
      }
      
      override public function getTotalExpansionPartCount() : int
      {
         var result:int = 0;
         if(this.expand)
         {
            result = this.expand.getTotalExpansionPartCount();
         }
         return result;
      }
      
      override public function getExpansionPartLimit(itemCode:String) : int
      {
         var result:int = 0;
         if(this.expand)
         {
            result = this.expand.getExpansionPartLimit(itemCode);
         }
         return result;
      }
      
      override public function hasReachedMaxExpansionLevel() : Boolean
      {
         var result:Boolean = false;
         if(this.expand)
         {
            result = this.expand.hasReachedMaxExpansionLevel();
         }
         return result;
      }
      
      override public function addExpansionPart(resource:MapResource) : Boolean
      {
         return this.expand.addExpansionPart(resource);
      }
      
      override public function getCurrentLevelConstructionItemCount(itemCode:String) : int
      {
         return this.getExpansionPartCount(itemCode);
      }
      
      public function get witherer() : IWitherComponent
      {
         var result:IWitherComponent = null;
         if(this.m_featurePrereqs.witherer)
         {
            if(this.m_featurePrereqs.witherer.passesPrereqs(true))
            {
               result = this.m_featureManagers.witherer;
            }
         }
         else
         {
            result = this.m_featureManagers.witherer;
         }
         return result;
      }
      
      public function get upgrader() : IUpgradeComponent
      {
         var result:IUpgradeComponent = null;
         if(this.m_featurePrereqs.upgrader)
         {
            if(this.m_featurePrereqs.upgrader.passesPrereqs(true))
            {
               result = this.m_featureManagers.upgrader;
            }
         }
         else
         {
            result = this.m_featureManagers.upgrader;
         }
         return result;
      }
      
      public function get containeeManager() : ContaineeFManager
      {
         return this.m_featureManagers.containeeManager;
      }
      
      public function dispatchTutorialEvent(eventName:String) : Boolean
      {
         var tutorialShown:Boolean = false;
         var tutorialFeature:TutorialFManager = this.m_featureManagers[FeatureManager.TUTORIAL_MENU_FEATURE_NAME];
         if(tutorialFeature != null)
         {
            tutorialShown = tutorialFeature.onTutorialEvent(eventName);
         }
         return tutorialShown;
      }
      
      public function get harvester() : IHarvestComponent
      {
         return this.getFeatureManagerIfPassesPrereq("harvester") as IHarvestComponent;
      }
      
      public function get tutorial() : TutorialFManager
      {
         return this.getFeatureManagerIfPassesPrereq("tutorial") as TutorialFManager;
      }
      
      override protected function getTHarvestExtraParams() : Object
      {
         return this.harvester != null ? this.harvester.getTHarvestExtraParams() : {};
      }
      
      public function getHarvestRewardName() : String
      {
         var reward:FarmItem = null;
         var result:String = "";
         if(this.harvester)
         {
            reward = this.harvester.harvestReward;
            if(reward != null)
            {
               result = reward.friendlyName;
            }
         }
         return result;
      }
      
      protected function getHarvestArrowOffset() : Point
      {
         var result:Point = null;
         if(this.harvester)
         {
            result = this.harvester.getHarvestArrowOffset();
         }
         else
         {
            result = new Point(0,0);
         }
         return result;
      }
      
      protected function getHarvestWindowClassName() : String
      {
         var result:String = null;
         if(this.harvester)
         {
            result = this.harvester.getHarvestWindowClassName();
         }
         return result;
      }
      
      protected function getHarvestWindowDialogUrl() : String
      {
         var result:String = null;
         if(this.harvester)
         {
            result = this.harvester.getHarvestWindowDialogUrl();
         }
         return result;
      }
      
      protected function getHarvestWindowNpcUrl() : String
      {
         var result:String = null;
         if(this.harvester)
         {
            result = this.harvester.getHarvestWindowNpcUrl();
         }
         return result;
      }
      
      protected function getHarvestWindowDialogBgUrl() : String
      {
         var result:String = null;
         if(this.harvester)
         {
            result = this.harvester.getHarvestWindowDialogBgUrl();
         }
         return result;
      }
      
      protected function getHarvestWindowLocPrefix() : String
      {
         var result:String = "";
         if(this.harvester)
         {
            result = this.harvester.getHarvestWindowLocPrefix();
         }
         return result;
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var result:Boolean = false;
         if(!this.harvester || this.harvester.canAcceptHarvestReward())
         {
            if(this.harvester)
            {
               this.harvester.onPreHarvest();
            }
            result = super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
         }
         else
         {
            this.harvester.displayMessageForUnclaimableHarvestReward();
         }
         return result;
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         var currentSuffixNum:int = this.getCurrentSuffix();
         switch(state)
         {
            case STATE_DISPLAY:
               imageName = "built_" + currentSuffixNum;
               break;
            case STATE_WITHERED:
               imageName = "built_" + currentSuffixNum;
               if(m_arrow == null || m_arrowArt != BLUE_ARROW)
               {
                  m_arrowArt = BLUE_ARROW;
                  m_arrow = generateHarvestArrow();
               }
               break;
            case STATE_RIPE:
               if(m_item.hideHarvestPick)
               {
                  imageName = "built_" + currentSuffixNum;
                  m_arrow = null;
                  break;
               }
               if(this.harvester)
               {
                  m_arrowArt = this.harvester.getHarvestArrow();
               }
               else
               {
                  m_arrowArt = PINK_ARROW;
               }
            default:
               imageName = super.getCurrentImageName();
         }
         if(Boolean(Global.flashHotParams["TOY_MANSION_RED_BOX_FIX"]) && Global.flashHotParams["TOY_MANSION_RED_BOX_FIX"] == true)
         {
            if(m_item.code == "08vg" && currentSuffixNum == 9)
            {
               imageName = "built_8";
            }
         }
         return imageName;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         super.onHarvestComplete(result);
         if(this.harvester)
         {
            this.harvester.onHarvestComplete(result);
         }
      }
      
      public function isShareFeedHandledByHarvester() : Boolean
      {
         return true;
      }
      
      public function get flowershack() : FlowerShackFManager
      {
         var result:FlowerShackFManager = null;
         if(Boolean(this.m_featureManagers) && Boolean(this.m_featureManagers.flowershack))
         {
            result = this.m_featureManagers.flowershack;
         }
         return result;
      }
      
      public function get slotmachine() : SlotMachineFManager
      {
         var result:SlotMachineFManager = null;
         if(Boolean(this.m_featureManagers) && Boolean(this.m_featureManagers.slotmachine2))
         {
            result = this.m_featureManagers.slotmachine2;
         }
         return result;
      }
      
      public function get tooltipText() : ITooltipComponent
      {
         var result:ITooltipComponent = null;
         if(Boolean(this.m_featureManagers) && Boolean(this.m_featureManagers.tooltipText))
         {
            result = this.m_featureManagers.tooltipText;
         }
         return result;
      }
      
      public function get arrowIndicator() : ArrowIndicatorFManager
      {
         var result:ArrowIndicatorFManager = null;
         if(Boolean(this.m_featureManagers) && Boolean(this.m_featureManagers.overrideArrowIndicator) && GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") != 0)
         {
            result = this.m_featureManagers.overrideArrowIndicator;
         }
         else if(Boolean(this.m_featureManagers) && Boolean(this.m_featureManagers.arrowIndicator))
         {
            result = this.getFeatureManagerIfPassesPrereq(FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME) as ArrowIndicatorFManager;
         }
         return result;
      }
      
      public function set overrideArrowIndicator(arrowIndicator:ArrowIndicatorFManager) : void
      {
         if(this.m_featureManagers)
         {
            this.m_featureManagers.overrideArrowIndicator = arrowIndicator;
         }
      }
      
      public function get neighborActionManager() : INeighborActionComponent
      {
         return this.m_featureManagers[FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME];
      }
      
      override public function canFeedOnVisit() : Boolean
      {
         var result:Boolean = false;
         var actionKey:String = (m_item as BuildingItem).neighborActionKey;
         if(Boolean(!m_animalsFed && actionKey && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_DYNAMIC,actionKey) && getItem().checkDateGate()) && Boolean(getItem().isInExperiment) && Boolean(this.harvester))
         {
            result = true;
         }
         return result;
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return this.canFeedOnVisit() || (getItem() as BuildingItem).neighborLookInside;
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return this.canFeedOnVisit();
      }
      
      override public function feedAnimals() : void
      {
         m_animalsFed = true;
         VisitorManager.getInstance().doAction(this.neighborActionManager.getAction());
      }
      
      override protected function onVisitClick() : void
      {
         var featureManager:* = undefined;
         var actionKey:String = null;
         if(this.canFeedOnVisit())
         {
            actionKey = (m_item as BuildingItem).neighborActionKey;
            VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_DYNAMIC,actionKey);
            Global.selectedAvatar.getStateMachine().addState(new AMFeedAnimals(Global.selectedAvatar,this),true);
         }
         else if((getItem() as BuildingItem).neighborLookInside)
         {
            this.displayStorageDialog();
         }
         for each(featureManager in this.m_featureManagers)
         {
            if(featureManager is FeatureManager)
            {
               featureManager.onVisitClick();
            }
         }
      }
      
      public function get storageMetaData() : Object
      {
         return this.m_storageMetadata;
      }
      
      public function getStorageMetaDataForHash(hash:String) : Object
      {
         var data:Object = null;
         if(this.m_storageMetadata.hasOwnProperty(hash) && this.m_storageMetadata[hash] != null && this.m_storageMetadata[hash].length >= 1)
         {
            data = this.m_storageMetadata[hash][0];
         }
         return data;
      }
      
      public function get storage() : IStorageComponent
      {
         return this.getFeatureManagerIfPassesPrereq("storage") as IStorageComponent;
      }
      
      override public function getStorageItemClass() : String
      {
         return this.storage ? this.storage.getStorageItemClass() : null;
      }
      
      override public function buildContainedItem(key:String) : Object
      {
         return this.storage.buildContainedItem(key);
      }
      
      override public function getContents() : Array
      {
         var result:Array = null;
         var storageComponent:IStorageComponent = this.storage;
         if(this.storage)
         {
            result = this.storage.getContents();
         }
         else
         {
            result = new Array();
         }
         return result;
      }
      
      override public function getStorageTypes() : Array
      {
         return this.storage.getStorageTypes();
      }
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         FarmStatsManager.featureSample("farm_world_action","remove_item_from_storage",getItem().name,getItem().name);
         var metadata:Array = null;
         if(this.m_storageMetadata.hasOwnProperty(this.m_lastMetaHashRemoved))
         {
            metadata = this.m_storageMetadata[this.m_lastMetaHashRemoved] as Array;
         }
         var tempArray:Array = new Array();
         var index:String = "";
         var found:Boolean = false;
         if(this.m_lastMetadataRemoved != "" && Boolean(this.m_storageMetadata[this.m_lastMetaHashRemoved]))
         {
            for(index in metadata)
            {
               if(found == false && metadata[index] == this.lastMetadataRemoved)
               {
                  found = true;
               }
               else
               {
                  tempArray.push(metadata[index]);
               }
            }
            if(tempArray.length)
            {
               this.m_storageMetadata[this.m_lastMetaHashRemoved] = tempArray;
            }
            else
            {
               delete this.m_storageMetadata[this.m_lastMetaHashRemoved];
            }
         }
         else if(metadata != null)
         {
            metadata.pop();
            if(metadata.length == 0)
            {
               delete this.m_storageMetadata[this.m_lastMetaHashRemoved];
            }
            else
            {
               for(index in metadata)
               {
                  tempArray.push(metadata[index]);
               }
               this.m_storageMetadata[this.m_lastMetaHashRemoved] = tempArray;
            }
         }
         else if(this.m_storageMetadata.hasOwnProperty(this.m_lastMetaHashRemoved) && Boolean(this.m_storageMetadata[this.m_lastMetaHashRemoved]))
         {
            delete this.m_storageMetadata[this.m_lastMetaHashRemoved];
         }
         this.storage.removeContents(itemCode,itemCount,itemParts);
         if(this.renderer != null)
         {
            this.renderer.removeContents(itemCode,itemCount,itemParts,this.m_lastMetaHashRemoved);
         }
         this.m_lastMetaHashRemoved = "";
      }
      
      override public function matchesOrigin(originId:int) : Boolean
      {
         var result:Boolean = false;
         if(this.storage)
         {
            result = this.storage.matchesOrigin(originId);
         }
         return result;
      }
      
      override public function setAmount(itemCode:String, amount:int) : void
      {
         if(this.storage)
         {
            this.storage.setAmount(itemCode,amount);
         }
      }
      
      override public function getAmount(itemCode:String) : Number
      {
         var amount:Number = Number(this.featureManagers.storage.getAmount(itemCode));
         if(amount == 0)
         {
            if(this.featureManagers.expand)
            {
               amount = Number(this.featureManagers.expand.getExpansionPartCount(itemCode));
            }
         }
         return amount;
      }
      
      override public function getItemLimit(item:FarmItem) : Number
      {
         var amount:Number = 0;
         if(this.storage)
         {
            amount = this.storage.getItemLimit(item);
         }
         return amount;
      }
      
      override public function get maxPotentialCapacity() : Number
      {
         var amount:Number = 0;
         if(this.storage)
         {
            amount = this.storage.maxPotentialCapacity;
         }
         return amount;
      }
      
      override public function showStorageFullDialog() : void
      {
         if(this.storage)
         {
            this.storage.showStorageFullDialog();
         }
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var result:Boolean = false;
         if(this.storage != null)
         {
            result = this.storage.canTakeItem(item,isMouseOver);
            if(item is FeatureBuilding)
            {
               result &&= !(item as FeatureBuilding).isWithered();
            }
         }
         return result;
      }
      
      override public function showItemStorageLimitFullDialog(item:MapResource) : void
      {
         this.showItemStorageLimitFullDialog(item);
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         if(result["updatedPlantTime"])
         {
            this.plantTime = parseFloat(result["updatedPlantTime"]);
            this.setState(STATE_BARE);
         }
         if(Boolean(result["successAddContainee"]) && Boolean(this.containeeManager))
         {
            this.containeeManager.onStoreComplete(result);
         }
         else
         {
            if(this.storage != null)
            {
               this.storage.onStoreComplete(result);
            }
            if(this.expand != null)
            {
               this.expand.onStoreComplete(result);
            }
         }
         if(result["fromMarket"])
         {
            DragonBreedingManager.getInstance(DRAGON_BREEDING).updateParentDragonItemCount(result["fromMarket"]);
            DragonBreedingManager.getInstance(DRAGON_BREEDING).openDragonBreedingUI();
         }
      }
      
      override public function grantUpgradeAwards(result:Object) : void
      {
         var dataArray:Array = null;
         var i:int = 0;
         var award:Object = null;
         var newData:NextExpandAwardData = null;
         if(this.expand != null)
         {
            if(result.hasOwnProperty("upgradeAward") && result.upgradeAward != null && result.upgradeAward != "")
            {
               dataArray = [];
               for(i = 0; i < result.upgradeAward.length; i++)
               {
                  award = result.upgradeAward[i];
                  if(award.hasOwnProperty("itemName") && award.itemName != null && award.itemName != "" && award.hasOwnProperty("number") && award.number != null && award.number != "")
                  {
                     newData = new NextExpandAwardData(null);
                     newData.itemName = award.itemName;
                     newData.quantity = award.number;
                     if(award.hasOwnProperty("addToBuilding"))
                     {
                        newData.addToBuilding = award.addToBuilding;
                     }
                     dataArray.push(newData);
                  }
               }
               this.expand.grantUpgradeAwards(dataArray);
            }
         }
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         if(messageData.length < 2)
         {
            return " ";
         }
         return ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":messageData[0],
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var imageName:String = null;
         var result:ItemImage = super.getCurrentImage();
         if(result == null)
         {
            imageName = postProcessImageName(state);
            result = m_item.getCachedImage(state);
         }
         return result;
      }
      
      override public function getItemFriendlyName() : String
      {
         var result:String = "";
         var override:INamingComponent = this.namingOverride;
         if(override)
         {
            result = override.getName();
         }
         else
         {
            result = super.getItemFriendlyName();
         }
         return result;
      }
      
      public function get renderer() : IRenderComponent
      {
         return this.getFeatureManagerIfPassesPrereq("renderer") as IRenderComponent;
      }
      
      public function get namingOverride() : INamingComponent
      {
         return this.getFeatureManagerIfPassesPrereq("nameOverride") as INamingComponent;
      }
      
      override public function drawDisplayObject() : void
      {
         if(this.imageProgression)
         {
            this.imageProgression.setProgression();
         }
         super.drawDisplayObject();
         if(this.renderer != null)
         {
            this.renderer.render();
         }
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         super.updateDisplayObjectTransform();
         if(this.renderer != null)
         {
            this.renderer.updateTransforms();
         }
      }
      
      override public function updateCulling() : void
      {
         super.updateCulling();
         if(this.renderer != null)
         {
            this.renderer.updateCulling();
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.arrowIndicator != null)
         {
            this.arrowIndicator.update();
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         var featureManager:* = undefined;
         var maskedContent:DisplayObject = null;
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var arrowFeature:XMLList = null;
         if(newContent is MovieClip)
         {
            maskedContent = this.getForegroundDisplayObject(newContent);
            if(maskedContent != null)
            {
               (newContent as DisplayObjectContainer).addChild(maskedContent);
            }
         }
         super.replaceContent(newContent,shouldRedrawMask);
         if(newContent is MovieClip && this.renderer != null)
         {
            this.renderer.updateDisplay();
         }
         if(this.arrowIndicator != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               featureData = this.getFarmItem().getFeatureDataByName(FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
               if(featureData.getString("onbydefault") == "no")
               {
                  this.arrowIndicator.hide();
               }
               else
               {
                  this.arrowIndicator.show();
               }
            }
            else
            {
               featuresXML = this.getFarmItem().getFeaturesXML();
               arrowFeature = featuresXML.(@name == FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
               if(arrowFeature.onbydefault != null)
               {
                  if(arrowFeature.onbydefault == "no")
                  {
                     this.arrowIndicator.hide();
                  }
                  else
                  {
                     this.arrowIndicator.show();
                  }
               }
               else
               {
                  this.arrowIndicator.show();
               }
            }
         }
         for each(featureManager in this.m_featureManagers)
         {
            if(featureManager is FeatureManager)
            {
               featureManager.replaceContent();
            }
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         if(this.arrowIndicator != null)
         {
            this.arrowIndicator.onMouseOver();
         }
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         if(this.arrowIndicator != null)
         {
            this.arrowIndicator.onMouseOut();
         }
      }
      
      override public function onObjectDrop() : void
      {
         var featureMessagingName:String = null;
         super.onObjectDrop();
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(buildingItem)
         {
            featureMessagingName = buildingItem.buildingName;
         }
         else
         {
            featureMessagingName = m_itemName;
         }
         FeatureMessagingManager.getInstance().registerFeatureInitialized(featureMessagingName,this.displayStorageDialog,this);
         this.dispatchTutorialEvent(TutorialFManager.TUTORIAL_EVENT_PLACEMENT);
      }
      
      override protected function replaceContentWithBitmap(shouldRedrawMask:Boolean = false) : void
      {
         if(!(m_itemImage.image is MovieClip))
         {
            super.replaceContentWithBitmap(shouldRedrawMask);
         }
      }
      
      protected function getForegroundDisplayObject(content:DisplayObject) : DisplayObject
      {
         var result:DisplayObject = null;
         var transparencyMask:DisplayObject = null;
         var newObject:Object = null;
         var itemImage:ItemImage = m_item.getCachedImage("foreground");
         if(itemImage != null)
         {
            result = itemImage.image as Bitmap;
         }
         if(result == null)
         {
            transparencyMask = null;
            if(m_image != null)
            {
               itemImage = m_item.getCachedImage("alpha");
               if(itemImage != null)
               {
                  transparencyMask = itemImage.image as DisplayObject;
               }
            }
            if(transparencyMask != null && !(transparencyMask is Loader))
            {
               result = DisplayObjectUtils.generateMaskedBitmap(content,transparencyMask);
               if(result is Bitmap)
               {
                  newObject = new Object();
                  newObject.name = "foreground";
                  newObject.url = null;
                  newObject.bitmapData = (result as Bitmap).bitmapData;
                  newObject.lowResBitmapData = null;
                  newObject.loader = null;
                  newObject.loaded = true;
                  newObject.loadClass = null;
                  newObject.boxWidth = m_itemImage.boxWidth;
                  m_item.addImageToCache(newObject);
               }
            }
         }
         return result;
      }
      
      public function get extraDataState() : ExtraDataFManager
      {
         return this.m_featureManagers.extraDataState;
      }
      
      public function get contextMenu() : IContextMenuComponent
      {
         return this.m_featureManagers.contextMenu;
      }
      
      public function get imageProgression() : IImageProgressionComponent
      {
         return this.m_featureManagers.imageProgression;
      }
      
      public function nextExpansionCashNeeded() : Number
      {
         var totalCashNeed:Number = 0;
         if(this.expand)
         {
            totalCashNeed = this.expand.getExpandCashNeeded();
         }
         else
         {
            totalCashNeed = this.getRawExpansionPartsCost();
         }
         return totalCashNeed;
      }
      
      public function getRawExpansionPartsCost() : Number
      {
         var code:String = null;
         var needed:Number = NaN;
         var partItem:FarmItem = null;
         var cashCost:Number = NaN;
         var totalCashNeed:int = 0;
         var expansionParts:Object = nextExpansionPartsNeeded();
         if(expansionParts)
         {
            for(code in expansionParts)
            {
               needed = Number(expansionParts[code]);
               partItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
               cashCost = partItem.cash;
               totalCashNeed += needed * cashCost;
            }
         }
         return totalCashNeed;
      }
      
      public function displayExpandDialog() : void
      {
         this.displayStorageDialog(this.EXPAND_ACTION);
      }
      
      public function onBuildFeedComplete() : void
      {
         var expansionComponent:IExpandComponent = this.expand;
         if(expansionComponent != null && !expansionComponent.hasReachedMaxExpansionLevel())
         {
            if(expansionComponent.showExpansionOnBuild)
            {
               this.displayExpandDialog();
            }
         }
      }
      
      public function getInitialPlantTimeKey() : String
      {
         return Global.worldManager.currentWorldType + "_" + this.getId();
      }
      
      public function getInitialPlantTime() : Number
      {
         var result:Number = 0;
         var optionKey:String = this.getInitialPlantTimeKey();
         var options:Object = FeatureOptionsManager.getInstance().getFeatureOption("limitedHarvestTime","items");
         if(options != null && options.hasOwnProperty(optionKey))
         {
            result = options[optionKey]["originalPlantTime"] as Number;
         }
         return result;
      }
      
      public function beginCompleteExpansionFlow(source:int = 0, forceExpansionFlow:Boolean = false) : void
      {
         var buildingName:String = null;
         var expansionCashNeeded:Number = this.nextExpansionCashNeeded();
         if(expansionCashNeeded > 0 || forceExpansionFlow)
         {
            FarmStatsManager.count("Constructable","ui_button_click",getItemName() + this.storageLevel.toString(),"complete_now");
            if(!this.isFrictionLessExpansionCompleteFlow(source))
            {
               buildingName = this.getItemFriendlyName();
               if(ZLocUtils.hasString("Dialogs","FinishConstructionBuildingPopup" + "_" + getItemName()))
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup" + "_" + getItemName(),{
                     "cashQuantity":expansionCashNeeded,
                     "item":ZLocUtils.tk_pk(buildingName)
                  }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteExpansionFlowCallback,"",true);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
                     "cashQuantity":expansionCashNeeded,
                     "item":ZLocUtils.tk_pk(buildingName)
                  }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteExpansionFlowCallback,"",true);
               }
            }
            else
            {
               this.frictionlessExpand(null);
            }
         }
      }
      
      public function frictionlessHarvestReadyNow(callBack:Function = null) : void
      {
         var cashCost:Number = this.getHarvestReadyNowCashPrice();
         if(cashCost > 0)
         {
            if(Global.player.canBuyCash(cashCost,true,"harvest_ready_now"))
            {
               if(!this.isHarvestable())
               {
                  this.setState(STATE_BUSY);
                  TransactionManager.addTransaction(new THarvestReadyNow(this,callBack));
                  Global.player.cash -= cashCost;
               }
            }
         }
         else
         {
            ErrorManager.addError(getItemName() + " does not support instant harvest now or it is missing the value in game settings.");
         }
      }
      
      public function getHarvestReadyNowCashPrice() : Number
      {
         return Global.farmGameSettingsManager.getNumber(getItemName() + "HarvestReadyNowCashPrice",-1);
      }
      
      public function isFrictionLessExpansionCompleteFlow(source:int = 0) : Boolean
      {
         return false;
      }
      
      public function frictionlessExpand(callBack:Function = null) : void
      {
         var numPartsNeeded:int = this.getNumberOfPartsNeeded() - this.getTotalExpansionPartCount();
         var expansionCashNeeded:Number = this.nextExpansionCashNeeded();
         if(expansionCashNeeded > 0 || numPartsNeeded <= 0)
         {
            if(Global.player.canBuyCash(expansionCashNeeded))
            {
               m_completeNowInProgress = true;
               if(this.expandToNextStorageLevel() == true)
               {
                  addTransaction(new TCompleteNow(this,null,callBack,1,true));
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
                  {
                     FarmStatsManager.sample(100,"complete_now_spend","building",getItemName() + this.storageLevel.toString(),"complete_now",expansionCashNeeded.toString());
                  }
                  Global.player.cash -= expansionCashNeeded;
               }
               if(this.expand)
               {
                  this.expand.conditionallySwapOnFullyExpanded();
               }
               m_completeNowInProgress = false;
            }
         }
      }
      
      public function expandBuildingUsingCurrencyOrCash() : Boolean
      {
         var result:Boolean = false;
         if(this.expand != null)
         {
            result = this.expand.expandBuildingUsingCurrencyOrCash();
         }
         return result;
      }
      
      public function getPriceForExpansion() : Object
      {
         var result:Object = null;
         if(this.expand != null)
         {
            result = this.expand.getPriceForExpansion();
         }
         return result;
      }
      
      override protected function completeExpansionLevel() : void
      {
         if(this.expand)
         {
            this.expand.completeExpansionLevel();
         }
         if(Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"])
         {
            this.m_stageStartingPartCount = 0;
         }
      }
      
      protected function onAcceptCompleteExpansionFlowCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.frictionlessExpand();
            if(this.m_expandCompleteCallback != null)
            {
               this.m_expandCompleteCallback();
               this.m_expandCompleteCallback = null;
            }
         }
         else
         {
            this.displayStorageDialog();
         }
      }
      
      override public function conditionallyRedraw(force:Boolean = false) : void
      {
         if(force && this.renderer != null)
         {
            this.renderer.render();
         }
         super.conditionallyRedraw(force);
      }
      
      override public function stop() : void
      {
         pause();
      }
      
      override protected function get needItemsForHarvest() : Boolean
      {
         return Boolean(this.harvester) && this.harvester.needItemsForHarvest;
      }
      
      override public function onSell() : void
      {
         super.onSell();
         FeatureBuildingGiftContentDataManager.sellBuilding(this);
      }
      
      override public function detach() : void
      {
         var featureMessagingName:String = null;
         var featureManager:* = undefined;
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(buildingItem)
         {
            featureMessagingName = buildingItem.buildingName;
         }
         else
         {
            featureMessagingName = m_itemName;
         }
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(featureMessagingName);
         for each(featureManager in this.m_featureManagers)
         {
            if(featureManager is FeatureManager)
            {
               featureManager.onDetatch();
            }
         }
         super.detach();
      }
      
      override public function setFullGrown() : void
      {
         super.setFullGrown();
         this.update();
         this.reloadImage();
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         super.onFinishPlace(transactionResult);
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(Boolean(buildingItem) && buildingItem.lookInsideOnFinishPlace)
         {
            this.displayStorageDialog();
         }
         var expansionManager:IExpandComponent = this.expand;
         if(expansionManager)
         {
            expansionManager.refreshAskMethods();
         }
         FeatureTrackingManager.instance.placement(this.bldgName);
      }
      
      public function getImageIcon() : String
      {
         var result:String = this.assetKey + "_";
         if(this.OVERLAY_OVERRIDE_NONE != this.m_overlayOverride)
         {
            result += this.m_overlayOverride - 1;
         }
         else
         {
            result += this.storageLevel.toString();
         }
         return result;
      }
      
      public function getStageStartingPartCount() : int
      {
         return this.m_stageStartingPartCount;
      }
      
      override public function applySmartSystems(result:Object) : int
      {
         var partsAdded:int = super.applySmartSystems(result);
         if(Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"])
         {
            this.m_stageStartingPartCount = partsAdded;
         }
         return partsAdded;
      }
      
      private function onStorageDialogClosed(event:Event) : void
      {
         if(this.m_storageDialog)
         {
            this.m_storageDialog.removeEventListener(Event.CLOSE,this.onStorageDialogClosed);
            this.m_storageDialog = null;
         }
      }
      
      public function get instantGrow() : InstantGrowFManager
      {
         return this.getFeatureManagerIfPassesPrereq("instantGrow") as InstantGrowFManager;
      }
   }
}

