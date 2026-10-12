package Classes.FeatureComponents
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.FeatureBuilding;
   import Classes.HarvestYieldsGroup;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleHarvestableResource;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.feed.ShareHarvestNeighborRewardFeed;
   import Classes.feed.ShareHarvestOwnRewardFeed;
   import Classes.storage.StorageItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.BuySeedPackages;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.ToasterManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.ToasterWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class HarvestFManager extends FeatureManager implements IHarvestComponent
   {
      
      private static const COIN_HARVEST_MESSAGE_FLAG:String = "_coinsHarvestMsg";
      
      private static const EXPIRE_COIN_HARVEST_MESSAGE_FLAG:String = "_expireCoinsHarvestMsg";
      
      protected static const TOAST_ASSET:String = "assets/dialogs/FV_Craft_BannerAd.swf";
      
      protected static const TOAST_ASSET_SCALEFACTOR:Number = 0.75;
      
      private static const EXPAND_IMAGE_ICON_URL_SUFFIX:String = "_icon.png";
      
      private static const EXPAND_IMAGE_ICON_URL_PREFIX:String = "assets/buildings/building_";
      
      private static const REWARDMULT_STORAGELEVEL_POW:String = "storageLevelPow";
      
      private static const REWARDMULT_STORAGELEVEL:String = "storageLevel";
      
      private static const REWARDMULT_STORAGELEVEL_STUTTER:String = "storageLevelStutter";
      
      private static const REWARDMULT_STORAGELEVEL_FIXED:String = "storageLevelFixed";
      
      private static const REWARDMULT_STORAGELEVEL_DOUBLE:String = "storageLevelDouble";
      
      private static const REWARDMULT_ONE_FIXED:String = "oneFixed";
      
      private var m_isBusy:Boolean = false;
      
      private var m_postHarvestActions:Array;
      
      private var m_needItemsForHarvest:Boolean = false;
      
      private var m_canHarvestOwn:Boolean = true;
      
      private var m_canHarvestNeighbor:Boolean = true;
      
      private var m_limitedCurrency:String = null;
      
      private var m_limitedCoinYield:int = 0;
      
      private var m_limitedCoinMultipler:String = "";
      
      private var m_limitedCoinMultiplerOverride:int;
      
      private var m_useCoinMultiplerOverride:Boolean = false;
      
      private var m_limitedStartOwn:String = "";
      
      private var m_limitedStartNeighbor:String = "";
      
      private var m_limitedEndOwn:String = "";
      
      private var m_limitedEndNeighbor:String = "";
      
      private var m_harvestExtraParams:Object = null;
      
      private var m_surfaceBasket:Boolean = false;
      
      private var m_harvestReward:FarmItem = null;
      
      protected var m_questTechRewards:XMLList = null;
      
      protected var m_questTechRewardsDataArray:Array = null;
      
      protected var m_creditsBuildingName:String = "";
      
      public function HarvestFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var postHarvestActionsDataArray:Array = null;
         var canHarvestData:BaseDataSource = null;
         var harvestRewardArr:Array = null;
         var postHarvestActionData:BaseDataSource = null;
         var actionType:String = null;
         var postHarvestActionObject:Object = null;
         var toasterAssetUrl:String = null;
         var iconURL:String = null;
         var toasterTitle:String = null;
         var toasterBody:String = null;
         var harvestReward:String = null;
         var featuresXML:XMLList = null;
         var harvestFeature:XMLList = null;
         var postHarvestActions:XMLList = null;
         var postHarvestActionList:XMLList = null;
         var postHarvestAction:XML = null;
         var type:String = null;
         var toasterAsset:String = null;
         var iconUrl:String = null;
         var title:String = null;
         var body:String = null;
         this.m_postHarvestActions = new Array();
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData)
            {
               postHarvestActionsDataArray = featureData.getArray("postHarvestActions","postHarvestAction");
               if(postHarvestActionsDataArray.length > 0)
               {
                  for each(postHarvestActionData in postHarvestActionsDataArray)
                  {
                     actionType = postHarvestActionData.getString("type");
                     postHarvestActionObject = {};
                     postHarvestActionObject.type = actionType;
                     switch(actionType)
                     {
                        case "toaster":
                           toasterAssetUrl = postHarvestActionData.getString("toasterAsset");
                           iconURL = postHarvestActionData.getString("icon");
                           if(iconURL.length > 0)
                           {
                              iconURL = Global.getAssetURL(iconURL);
                           }
                           toasterTitle = ZLocUtils.t("Dialogs",owner.getItem().name + "_PostHarvestToasterTitle");
                           toasterBody = ZLocUtils.t("Dialogs",owner.getItem().name + "_PostHarvestToasterBody");
                           postHarvestActionObject.data = {
                              "toasterAsset":toasterAssetUrl,
                              "icon":iconURL,
                              "title":toasterTitle,
                              "body":toasterBody
                           };
                           break;
                        case "surfaceBuilding":
                           postHarvestActionObject.data = {"surfacingKeyword":postHarvestActionData.getString("surfacingKeyword")};
                     }
                     if(postHarvestActionObject.hasOwnProperty("data"))
                     {
                        this.m_postHarvestActions.push(postHarvestActionObject);
                     }
                  }
               }
               this.m_needItemsForHarvest = featureData.getBoolean("needItemsForHarvest");
               canHarvestData = featureData.getData("canHarvest");
               if(canHarvestData)
               {
                  this.m_canHarvestOwn = canHarvestData.toString() == "true";
                  this.m_canHarvestNeighbor = canHarvestData.getBoolean("neighbor");
               }
               if(featureData.hasProperty("limitedCoinCurrency"))
               {
                  this.m_limitedCurrency = featureData.getString("limitedCoinCurrency");
               }
               if(featureData.hasProperty("limitedCoinYield"))
               {
                  this.m_limitedCoinYield = featureData.getInt("limitedCoinYield");
               }
               if(featureData.hasProperty("rewardMultiplier"))
               {
                  this.m_limitedCoinMultipler = featureData.getString("rewardMultiplier");
               }
               if(featureData.hasProperty("rewardMultiplierOverride"))
               {
                  this.m_useCoinMultiplerOverride = true;
                  this.m_limitedCoinMultiplerOverride = featureData.getInt("rewardMultiplierOverride");
               }
               if(featureData.hasProperty("limitedStartOwn"))
               {
                  this.m_limitedStartOwn = featureData.getString("limitedStartOwn");
               }
               if(featureData.hasProperty("limitedStartNeighbor"))
               {
                  this.m_limitedStartNeighbor = featureData.getString("limitedStartNeighbor");
               }
               if(featureData.hasProperty("limitedEndOwn"))
               {
                  this.m_limitedEndOwn = featureData.getString("limitedEndOwn");
               }
               if(featureData.hasProperty("limitedEndNeighbor"))
               {
                  this.m_limitedEndNeighbor = featureData.getString("limitedEndNeighbor");
               }
               this.m_surfaceBasket = featureData.getBoolean("surfaceBasket");
               harvestRewardArr = featureData.getArray("harvestReward");
               if(harvestRewardArr.length > 0)
               {
                  harvestReward = (harvestRewardArr[0] as BaseDataSource).getString("name");
                  if(harvestReward.length > 0)
                  {
                     this.m_harvestReward = Global.farmGameSettingsManager.getFarmItemByName(harvestReward);
                  }
               }
               if(featureData.hasProperty("rewards"))
               {
                  this.m_questTechRewardsDataArray = featureData.getArray("rewards");
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            harvestFeature = featuresXML.(@name == FeatureManager.HARVEST_FEATURE_NAME);
            if(harvestFeature != null)
            {
               postHarvestActions = harvestFeature.postHarvestActions;
               if(postHarvestActions != null)
               {
                  postHarvestActionList = postHarvestActions.postHarvestAction;
                  if(postHarvestActionList)
                  {
                     for each(postHarvestAction in postHarvestActionList)
                     {
                        type = postHarvestAction.@type;
                        switch(type)
                        {
                           case "toaster":
                              toasterAsset = "";
                              if(postHarvestAction.hasOwnProperty("@toasterAsset"))
                              {
                                 toasterAsset = postHarvestAction.@toasterAsset;
                              }
                              iconUrl = "";
                              if(postHarvestAction.hasOwnProperty("@icon"))
                              {
                                 iconUrl = Global.getAssetURL(postHarvestAction.@icon);
                              }
                              title = ZLocUtils.t("Dialogs",owner.getItem().name + "_PostHarvestToasterTitle");
                              body = ZLocUtils.t("Dialogs",owner.getItem().name + "_PostHarvestToasterBody");
                              this.m_postHarvestActions.push({
                                 "type":"toaster",
                                 "data":{
                                    "toasterAsset":toasterAsset,
                                    "icon":iconUrl,
                                    "title":title,
                                    "body":body
                                 }
                              });
                              break;
                           case "surfaceBuilding":
                              this.m_postHarvestActions.push({
                                 "type":"surfaceBuilding",
                                 "data":{"surfacingKeyword":postHarvestAction.@surfacingKeyword}
                              });
                        }
                     }
                  }
               }
               if(harvestFeature.hasOwnProperty("needItemsForHarvest"))
               {
                  this.m_needItemsForHarvest = Boolean(harvestFeature.needItemsForHarvest);
               }
               if(harvestFeature.hasOwnProperty("canHarvest"))
               {
                  this.m_canHarvestOwn = harvestFeature.canHarvest.@own.toString() == "true";
                  this.m_canHarvestNeighbor = harvestFeature.canHarvest.@neighbor.toString() == "true";
               }
               if(harvestFeature.hasOwnProperty("limitedCoinCurrency"))
               {
                  this.m_limitedCurrency = harvestFeature.limitedCoinCurrency;
               }
               if(harvestFeature.hasOwnProperty("limitedCoinYield"))
               {
                  this.m_limitedCoinYield = harvestFeature.limitedCoinYield;
               }
               if(harvestFeature.hasOwnProperty("rewardMultiplier"))
               {
                  this.m_limitedCoinMultipler = harvestFeature.rewardMultiplier;
               }
               if(harvestFeature.hasOwnProperty("rewardMultiplierOverride"))
               {
                  this.m_useCoinMultiplerOverride = true;
                  this.m_limitedCoinMultiplerOverride = harvestFeature.rewardMultiplierOverride;
               }
               if(harvestFeature.hasOwnProperty("limitedStartOwn"))
               {
                  this.m_limitedStartOwn = harvestFeature.limitedStartOwn;
               }
               if(harvestFeature.hasOwnProperty("limitedStartNeighbor"))
               {
                  this.m_limitedStartNeighbor = harvestFeature.limitedStartNeighbor;
               }
               if(harvestFeature.hasOwnProperty("limitedEndOwn"))
               {
                  this.m_limitedEndOwn = harvestFeature.limitedEndOwn;
               }
               if(harvestFeature.hasOwnProperty("limitedEndNeighbor"))
               {
                  this.m_limitedEndNeighbor = harvestFeature.limitedEndNeighbor;
               }
               if(harvestFeature.hasOwnProperty("surfaceBasket") && harvestFeature.surfaceBasket == "true")
               {
                  this.m_surfaceBasket = true;
               }
               if(harvestFeature.hasOwnProperty("harvestReward") && harvestFeature.harvestReward.@name.toString() != "")
               {
                  this.m_harvestReward = Global.farmGameSettingsManager.getFarmItemByName(harvestFeature.harvestReward.@name.toString());
               }
               if(harvestFeature.hasOwnProperty("rewards"))
               {
                  this.m_questTechRewards = harvestFeature.rewards;
               }
            }
         }
      }
      
      public function getHarvestArrow() : Class
      {
         return SimpleHarvestableResource.PINK_ARROW;
      }
      
      public function canAcceptHarvestReward() : Boolean
      {
         return true;
      }
      
      public function displayMessageForUnclaimableHarvestReward() : void
      {
      }
      
      private function getOutOfDateHarvestAmount() : int
      {
         var outOfDateGoldHarvest:int = 0;
         var result:int = 0;
         if(!FarmGameUtil.checkDateGate(owner.getItem().limitedStartDate,owner.getItem().limitedEndDate))
         {
            outOfDateGoldHarvest = Global.farmGameSettingsManager.getInt("outOfDateGoldHarvest",100);
            result = owner.storageLevel * outOfDateGoldHarvest;
         }
         return result;
      }
      
      public function getHarvestCurrency() : String
      {
         var result:String = Currency.COINS;
         if(this.m_limitedCurrency != null)
         {
            result = this.m_limitedCurrency;
         }
         return result;
      }
      
      public function getHarvestAmount() : int
      {
         var key:String = null;
         var total:int = 0;
         total = this.getOutOfDateHarvestAmount();
         var contents:Dictionary = owner.contents;
         if(total <= 0)
         {
            if(contents)
            {
               for(key in contents)
               {
                  if(contents[key] > 0)
                  {
                     total += contents[key] * (Global.farmGameSettingsManager.getFarmItemByCode(key) as HarvestableItem).coinYield;
                  }
               }
            }
            if(Boolean(this.m_harvestExtraParams) && Boolean(this.m_harvestExtraParams.limitedCoinYield))
            {
               total += this.m_harvestExtraParams.limitedCoinYield;
            }
         }
         return total;
      }
      
      protected function getHarvestTooltip() : String
      {
         var growPercentage:int = 0;
         var toolTip:String = null;
         var capacityText:String = owner.getToolTipCapacityText();
         if(!owner.isFullyBuilt())
         {
            capacityText = ZLocUtils.t("Items",owner.getItem().name + "_mats",{
               "quantity":owner.count,
               "maximum":owner.capacity
            });
         }
         switch(owner.getState())
         {
            case FeatureBuilding.STATE_RIPE:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                  "item":ZLocUtils.tk_pk(owner.getItem().friendlyName),
                  "capacityStr":capacityText
               });
               break;
            case FeatureBuilding.STATE_BARE:
               growPercentage = owner.getGrowPercentage();
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_toolTip",{
                  "item":ZLocUtils.tk_pk(owner.getItem().friendlyName),
                  "quantity":growPercentage,
                  "capacityStr":capacityText
               });
               break;
            case FeatureBuilding.STATE_CONSTRUCTION:
            case FeatureBuilding.STATE_BUILT:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                  "item":ZLocUtils.tk_pk(owner.getItem().friendlyName),
                  "capacityStr":capacityText
               });
               break;
            default:
               toolTip = owner.getItem().friendlyTitle;
         }
         return toolTip;
      }
      
      public function getTHarvestExtraParams() : Object
      {
         return this.m_harvestExtraParams;
      }
      
      public function getHarvestArrowOffset() : Point
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:Point = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasProperty("harvestArrowOffset"))
            {
               result = new Point(featureData.getInt("harvestArrowOffset","x"),featureData.getInt("harvestArrowOffset","y"));
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestArrowOffset"))
            {
               result = new Point(featureXML.harvestArrowOffset.@x,featureXML.harvestArrowOffset.@y);
            }
         }
         if(result == null)
         {
            result = new Point(0,0);
         }
         return result;
      }
      
      public function getHarvestWindowClassName() : String
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasData("harvestWindow","className"))
            {
               result = featureData.getString("harvestWindow","className");
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestWindow") && featureXML.harvestWindow.hasOwnProperty("@className"))
            {
               result = featureXML.harvestWindow.@className;
            }
         }
         return result;
      }
      
      public function getHarvestWindowDialogUrl() : String
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasData("harvestWindow","dialogUrl"))
            {
               result = featureData.getString("harvestWindow","dialogUrl");
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestWindow") && featureXML.harvestWindow.hasOwnProperty("@dialogUrl"))
            {
               result = featureXML.harvestWindow.@dialogUrl;
            }
         }
         return result;
      }
      
      public function getHarvestWindowNpcUrl() : String
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasData("harvestWindow","npcUrl"))
            {
               result = featureData.getString("harvestWindow","npcUrl");
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestWindow") && featureXML.harvestWindow.hasOwnProperty("@npcUrl"))
            {
               result = featureXML.harvestWindow.@npcUrl;
            }
         }
         return result;
      }
      
      public function getHarvestWindowDialogBgUrl() : String
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasData("harvestWindow","dialogBgUrl"))
            {
               result = featureData.getString("harvestWindow","dialogBgUrl");
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestWindow") && featureXML.harvestWindow.hasOwnProperty("@dialogBgUrl"))
            {
               result = featureXML.harvestWindow.@dialogBgUrl;
            }
         }
         return result;
      }
      
      public function getHarvestWindowLocPrefix() : String
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(featureData.hasData("harvestWindow","locPrefix"))
            {
               result = featureData.getString("harvestWindow","locPrefix");
            }
         }
         else
         {
            featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
            if(featureXML.hasOwnProperty("harvestWindow") && featureXML.harvestWindow.hasOwnProperty("@locPrefix"))
            {
               result = featureXML.harvestWindow.@locPrefix;
            }
         }
         return result;
      }
      
      public function onPreHarvest() : void
      {
         var questTechRewardsData:BaseDataSource = null;
         var passesPrereqs:Boolean = false;
         var questTechReward:XML = null;
         var passPrereqs:Boolean = false;
         if(this.useLimitedCoinYield())
         {
            this.m_harvestExtraParams = new Object();
            this.m_harvestExtraParams.limitedCoinYield = this.getLimitedCoinYield();
         }
         else
         {
            this.m_harvestExtraParams = null;
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.m_questTechRewardsDataArray)
            {
               for each(questTechRewardsData in this.m_questTechRewardsDataArray)
               {
                  passesPrereqs = true;
                  if(questTechRewardsData.hasProperty("prereqs"))
                  {
                     passesPrereqs = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseDataSourcePrereqs(questTechRewardsData.getArray("prereqs","prereq")),this.owner);
                  }
                  if(passesPrereqs)
                  {
                     UserRewardUtil.grantUserRewardsFromDataSource(questTechRewardsData,this.getMultiplier(),this.owner);
                  }
               }
            }
         }
         else if(this.m_questTechRewards)
         {
            for each(questTechReward in this.m_questTechRewards)
            {
               passPrereqs = true;
               if(questTechReward.hasOwnProperty("prereqs"))
               {
                  passPrereqs = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(questTechReward.prereqs.prereq),this.owner);
               }
               if(passPrereqs)
               {
                  UserRewardUtil.grantUserRewardsFromXml(questTechReward,this.getMultiplier(),this.owner);
               }
            }
         }
      }
      
      public function onHarvestComplete(result:Object) : void
      {
         var action:Object = null;
         var shouldUseSeenFlag:Boolean = false;
         var seenFlag:String = null;
         var limitedEnd:String = null;
         var endExpired:Boolean = false;
         var endPosition:int = 0;
         var seedName:String = null;
         var seed:FarmItem = null;
         var seedsHarvested:Number = NaN;
         var storedSeed:StorageItem = null;
         var neighborFeed:ShareHarvestNeighborRewardFeed = null;
         var rewardName:String = null;
         var feed:ShareHarvestOwnRewardFeed = null;
         var featureData:BaseDataSource = null;
         var rewardDataArray:Array = null;
         var rewardData:BaseDataSource = null;
         var featureXML:XML = null;
         var reward:XML = null;
         var defaultFeed:ShareHarvestOwnRewardFeed = null;
         var popupZLocPrefix:String = null;
         var building:FarmItem = null;
         this.m_harvestExtraParams = null;
         if(owner.getFarmItem().harvestType == "coinsMessage" && result.rewardItem == null)
         {
            shouldUseSeenFlag = !Global.worldManager.isVisiting();
            if(!Global.worldManager.isVisiting() || shouldUseSeenFlag && !Global.player.getSeenFlag(seenFlag))
            {
               limitedEnd = Global.worldManager.isVisiting() ? this.m_limitedEndNeighbor : this.m_limitedEndOwn;
               endExpired = "" != limitedEnd && !FarmGameUtil.checkEndDateGate(limitedEnd);
               seenFlag = endExpired ? owner.getFarmItem().name + EXPIRE_COIN_HARVEST_MESSAGE_FLAG : owner.getFarmItem().name + COIN_HARVEST_MESSAGE_FLAG;
               this.popHarvestMessage(endExpired);
               if(shouldUseSeenFlag)
               {
                  Global.player.setSeenFlag(seenFlag);
               }
            }
         }
         else if(result.rewardItem)
         {
            endPosition = int(result.rewardItem.indexOf("_seedpackage"));
            seedName = "";
            if(endPosition > 0)
            {
               seedName = result.rewardItem.substr(0,endPosition);
               seed = BuySeedPackages.getSeedFromSeedPackageName(result.rewardItem);
               seedsHarvested = int(result.numRewards) * Global.farmGameSettingsManager.getInt(result.seedPackageSizeKey,5);
               storedSeed = StorageItem.getStorageItem(Global.farmGameSettingsManager.getFarmItemCodeByName(result.rewardItem),[seedsHarvested]);
               if(Boolean(storedSeed && !storedSeed.isEmpty() && storedSeed.item) && Boolean(storedSeed.item.className) && storedSeed.item.className == "CSeedPackage")
               {
                  Global.player.addSeedItem(storedSeed);
               }
            }
            else if(!result.foundBushel)
            {
               Global.player.addGift(result.rewardItem,"0",int(result.numRewards));
            }
            if(Boolean(result.rewardLink) && owner.isShareFeedHandledByHarvester())
            {
               if(result.rewardType)
               {
                  switch(result.rewardType)
                  {
                     case ShareHarvestNeighborRewardFeed.getRewardType(this.owner):
                        neighborFeed = new ShareHarvestNeighborRewardFeed(this.owner,result);
                        if(FarmGameSettingsManager.isInDataSourceExperiment())
                        {
                           if(Global.worldManager.isVisiting())
                           {
                              featureData = this.owner.getFarmItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
                              rewardDataArray = featureData.getArray("friendRewards","friendReward");
                              for each(rewardData in rewardDataArray)
                              {
                                 rewardName = rewardData.getString("rewardName");
                                 if(rewardName == ShareHarvestNeighborRewardFeed.getRewardType(this.owner))
                                 {
                                    if(rewardData.getBoolean("isW2W"))
                                    {
                                       neighborFeed.setTargetUids([Global.worldManager.getVisiting()]);
                                       break;
                                    }
                                 }
                              }
                           }
                        }
                        else
                        {
                           featureXML = this.owner.getFarmItem().getFeatureXMLByName("harvester");
                           for each(reward in featureXML.friendRewards.friendReward)
                           {
                              rewardName = reward.@rewardName;
                              if(rewardName == ShareHarvestNeighborRewardFeed.getRewardType(this.owner))
                              {
                                 if(Boolean(Global.worldManager.isVisiting()) && Boolean(reward.hasOwnProperty("@isW2W")) && reward.@isW2W == "true")
                                 {
                                    neighborFeed.setTargetUids([Global.worldManager.getVisiting()]);
                                    break;
                                 }
                              }
                           }
                        }
                        neighborFeed.startFeedFlow();
                        break;
                     default:
                        feed = new ShareHarvestOwnRewardFeed(this.owner,result);
                        feed.startFeedFlow();
                  }
               }
               else if(this.owner.getItem().name.indexOf("witchincauldron") == -1 || !result["foundBushel"])
               {
                  defaultFeed = new ShareHarvestOwnRewardFeed(this.owner,result);
                  defaultFeed.startFeedFlow();
               }
            }
         }
         if(!Global.worldManager.isVisiting() && this.m_surfaceBasket && Boolean(result.rewardItem))
         {
            this.tryForcePlacement(result.rewardItem);
         }
         for each(action in this.m_postHarvestActions)
         {
            switch(action.type)
            {
               case "toaster":
                  if(action.data.hasOwnProperty("toasterAsset"))
                  {
                     ToasterManager.getInstance().add(new ToasterWindow(action.data.toasterAsset));
                  }
                  else
                  {
                     ToasterManager.getInstance().add(new IconTitleToasterWindow(action.data.title,action.data.body,action.data.icon,TOAST_ASSET,TOAST_ASSET_SCALEFACTOR));
                  }
                  break;
               case "surfaceBuilding":
                  popupZLocPrefix = null;
                  building = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(owner,action.data.surfacingKeyword);
                  if(building == null)
                  {
                     building = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(owner,action.data.surfacingKeyword,true);
                     if(building != null)
                     {
                        popupZLocPrefix = "StorageAlreadyFullSurfacing";
                     }
                  }
                  if(building != null)
                  {
                     UI.displayPopup(new BuildingSurfaceWindow(building,owner,true,null,null,popupZLocPrefix),true);
                  }
            }
         }
         if(Global.worldManager.isVisiting())
         {
            VisitorManager.getInstance().updateBuildingsFeedGlow();
         }
      }
      
      private function popHarvestMessage(expired:Boolean = false) : void
      {
         var titleMsg:String = null;
         var failoverEntries:Array = null;
         var owner:FeatureBuilding = m_owner as FeatureBuilding;
         var msg:String = "";
         var buildingItem:FarmItem = owner.getFarmItem();
         var expDialogKey:String = buildingItem.name + "_ExpireCoinHarvestMessage";
         var expFallbackDialogKey:String = FeatureBuilding.FALLBACK_KEY + "ExpireCoinHarvestMessage";
         var dialogKey:String = owner.getFarmItem().name + "_CoinHarvestMessage";
         var fallbackDialogKey:String = FeatureBuilding.FALLBACK_KEY + "CoinHarvestMessage";
         var rewardName:String = owner.getHarvestRewardName();
         if(rewardName == "")
         {
            fallbackDialogKey += "_noReward";
         }
         if(expired)
         {
            failoverEntries = [new ZLocFailoverEntry("Dialogs",expDialogKey),new ZLocFailoverEntry("Dialogs",expFallbackDialogKey),new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)];
         }
         else
         {
            failoverEntries = [new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)];
         }
         msg = ZLocUtils.getFailoverLocString(failoverEntries,{
            "building":ZLocUtils.tk_pk(buildingItem.friendlyName),
            "building2":ZLocUtils.tk_pk(buildingItem.friendlyName),
            "item":ZLocUtils.tk_pk(rewardName),
            "item2":ZLocUtils.tk_pk(rewardName)
         });
         if(ZLocUtils.hasString("Dialogs",buildingItem.name + "_CoinsHarvestTitle"))
         {
            titleMsg = ZLocUtils.t("Dialogs",buildingItem.name + "_CoinsHarvestTitle",{
               "quantity":this.getHarvestAmount(),
               "coinword":ZLocUtils.tk("Dialogs","Coin_word","",this.getHarvestAmount())
            });
         }
         else
         {
            titleMsg = ZLocUtils.t("Dialogs","harvest_finished_CoinsHarvestTitle",{
               "quantity":this.getHarvestAmount(),
               "coinword":ZLocUtils.tk("Dialogs","Coin_word","",this.getHarvestAmount())
            });
         }
         var iconUrl:String = EXPAND_IMAGE_ICON_URL_PREFIX + owner.getImageIcon() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,iconUrl,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),new Point(4,4),null));
      }
      
      public function canHarvest() : Boolean
      {
         var canHarvest:Boolean = true;
         var canHarvestFromPerson:Boolean = Global.worldManager.isVisiting() ? this.m_canHarvestNeighbor && owner.canBeClickedOnVisit() : this.m_canHarvestOwn;
         if(this.m_needItemsForHarvest && owner.count <= 0 || !canHarvestFromPerson)
         {
            canHarvest = false;
         }
         return canHarvest;
      }
      
      public function get needItemsForHarvest() : Boolean
      {
         return this.m_needItemsForHarvest;
      }
      
      public function get harvestReward() : FarmItem
      {
         return this.m_harvestReward;
      }
      
      protected function useLimitedCoinYield() : Boolean
      {
         var result:Boolean = false;
         var limitedStart:String = Global.worldManager.isVisiting() ? this.m_limitedStartNeighbor : this.m_limitedStartOwn;
         var limitedEnd:String = Global.worldManager.isVisiting() ? this.m_limitedEndNeighbor : this.m_limitedEndOwn;
         var startExpired:Boolean = "" != limitedStart && !FarmGameUtil.checkStartDateGate(limitedStart);
         var endExpired:Boolean = "" != limitedEnd && !FarmGameUtil.checkEndDateGate(limitedEnd);
         return 0 != this.m_limitedCoinYield && (startExpired || endExpired);
      }
      
      private function getMultiplier() : int
      {
         var multiplierAmount:int = this.m_useCoinMultiplerOverride ? this.m_limitedCoinMultiplerOverride : owner.storageLevel;
         switch(this.m_limitedCoinMultipler)
         {
            case REWARDMULT_STORAGELEVEL_FIXED:
               multiplierAmount--;
               break;
            case REWARDMULT_STORAGELEVEL_DOUBLE:
               if(multiplierAmount > 0)
               {
                  multiplierAmount--;
               }
               multiplierAmount *= 2;
               break;
            case REWARDMULT_STORAGELEVEL_STUTTER:
               multiplierAmount = owner.hasReachedMaxExpansionLevel() ? int(Math.ceil(multiplierAmount / 2) + 1) : int(Math.ceil(multiplierAmount / 2));
               break;
            case REWARDMULT_STORAGELEVEL_POW:
               multiplierAmount = Math.pow(2,multiplierAmount - 1);
               break;
            case REWARDMULT_ONE_FIXED:
               multiplierAmount = 1;
               break;
            case REWARDMULT_STORAGELEVEL:
            default:
               multiplierAmount = multiplierAmount;
         }
         return multiplierAmount;
      }
      
      protected function getLimitedCoinYield() : int
      {
         return this.m_limitedCoinYield * this.getMultiplier();
      }
      
      public function getHarvestYieldMultiplier(harvestYieldsGroup:HarvestYieldsGroup, item:FarmItem) : int
      {
         return this.getMultiplier();
      }
      
      protected function tryForcePlacement(harvestGift:String) : void
      {
         var worldObjects:Array = null;
         var popup:GenericIconPopup = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestGift);
         var buildingItem:FarmItem = null;
         var message:String = "";
         if(Boolean(farmItem) && Boolean(farmItem.basket))
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(farmItem.basket);
            if(Boolean(buildingItem) && Boolean(buildingItem.isInExperiment) && buildingItem.checkDateGate())
            {
               this.m_creditsBuildingName = buildingItem.name;
               worldObjects = Global.world.getObjectsByName(buildingItem.name);
               if(worldObjects.length == 0)
               {
                  if(ZLocUtils.hasString(buildingItem.name,"CreditsNoBuilding_placeNow"))
                  {
                     message = ZLocUtils.t(buildingItem.name,"CreditsNoBuilding_placeNow",{"item":buildingItem.friendlyTitle});
                  }
                  else
                  {
                     message = ZLocUtils.t("Dialogs","CreditsNoBuilding_placeNow",{"item":buildingItem.friendlyTitle});
                  }
                  popup = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onEnterForcedPlacement,buildingItem.icon,false,false);
                  popup.setAcceptTextName("GenericPlaceButton");
                  UI.displayPopup(popup);
               }
            }
         }
      }
      
      private function onEnterForcedPlacement(event:GenericPopupEvent) : void
      {
         var hasGift:Boolean = false;
         if(this.m_creditsBuildingName != "")
         {
            hasGift = Global.player.getGiftCountForItem(this.m_creditsBuildingName) > 0;
            Global.world.addGameMode(new GMBuild(this.m_creditsBuildingName,hasGift,0,true,null));
            UI.closeGifts();
         }
      }
   }
}

