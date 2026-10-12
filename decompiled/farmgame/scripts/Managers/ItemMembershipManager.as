package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FeatureBuilding;
   import Classes.IFeatureMessagingCustomInit;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.RewardCard;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.MOTD;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGetMOTD;
   import Transactions.TRefreshBalance;
   import Widgets.Windows.ItemMembershipLevelUpWindow;
   import Widgets.Windows.ItemMembershipOutOfCashWindow;
   import Widgets.Windows.ItemMembershipToasterWindow;
   import Widgets.Windows.ItemMembershipWelcomeWindow;
   import Widgets.Windows.ItemMembershipWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   
   public class ItemMembershipManager implements IFeatureMessagingCustomInit
   {
      
      private static var s_featureNames:Array;
      
      private static var s_hasCachedLimitedRedemptionExperiment:Boolean;
      
      private static var s_isInLimitedRedemptionExperiment:Boolean;
      
      private static const NOT_IN_RUNTIME:int = 0;
      
      private static const BLACKLISTED:int = -1;
      
      private static const WHITELISTED:int = 1;
      
      private static var s_configs:Object = {};
      
      private static var s_featureConfigManagers:Object = {};
      
      private static var s_MOTDs:Object = {};
      
      private static var s_bonusItemNamesMap:Object = {};
      
      private static var s_runtimeMap:Object = {};
      
      public static var s_outOfCashFeatureName:String = "";
      
      public static const RUNTIME_KEY_ONBOARD_CHANCE:String = "ITEM_MEMBERSHIP_ONBOARD_CHANCE";
      
      public static const KEY_FEATURE_NAME:String = "featureName";
      
      public static const MAIN_UI_ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_v2.swf";
      
      private static const TOASTER_ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_toaster.swf";
      
      public static const KEY_NUM_BONUS_ITEMS:String = "numBonusItems";
      
      public static const PAYMENTS_REF:String = "itemMembershipPurchase";
      
      private static const NUM_TIMES_TO_ONBOARD_BEFORE_WEEK_WAIT:int = 3;
      
      private static const NUM_TIMES_TO_ONBOARD_BEFORE_MONTH_WAIT:int = 5;
      
      private static const NUM_DAYS_IN_MONTH_APPROXIMATE:int = 30;
      
      public static const DATE_JOINED:String = "dateJoined";
      
      public static const NUM_MONTHS_SUBSCRIBED:String = "numMonthsSubscribed";
      
      public static const NUM_CREDITS:String = "numCredits";
      
      public static const SHOULD_RENEW:String = "shouldRenew";
      
      public static const SUBSCRIPTION_LENGTH:String = "subscriptionLength";
      
      public static const CONTEXTUAL_ONBOARDING_COUNT:String = "contextualOnboardingCount";
      
      public static const DATE_LAST_CONTEXTUALLY_ONBOARDED:String = "dateLastContextuallyOnboarded";
      
      public static const SUBSCRIPTION_OPTIONS:String = "subscriptionOptions";
      
      public static const NUM_MONTHS:String = "numMonths";
      
      public static const PRICE:String = "price";
      
      public static const PERCENT_DISCOUNT:String = "percentDiscount";
      
      public static const VARIANT:String = "variant";
      
      public static const MEMBERSHIP_LEVELS:String = "membershipLevels";
      
      public static const MEMBERSHIP_LEVEL:String = "membershipLevel";
      
      public static const FEATURE_TYPE:String = "item_membership";
      
      public static const ZLOC_KEY_CLUB_NAME:String = "_club_name";
      
      public static const ZLOC_KEY_ITEM_SINGULAR:String = "_item_singular";
      
      public static const ZLOC_KEY_ITEM_PLURAL:String = "_item_plural";
      
      public static const ZLOC_KEY_CREDITS_NAME:String = "_credits_name";
      
      public static const ZLOC_KEY_REDEEM:String = "_redeem";
      
      public static const CONSTANTS_KEY_MAIN_WINDOW_BACKGROUND_IMAGE:String = "mainWindowBackgroundImage";
      
      public static const CONSTANTS_KEY_WELCOME_WINDOW_BACKGROUND_IMAGE:String = "welcomeWindowBackgroundImage";
      
      public static const CONSTANTS_KEY_NUM_CREDITS_PER_MONTH:String = "numCreditsPerMonth";
      
      public static const CONSTANTS_KEY_PRIORITY:String = "priority";
      
      public static const CONSTANTS_KEY_MARKET_TYPE:String = "marketType";
      
      public static const CONSTANTS_KEY_MARKET_SUBTYPE:String = "marketSubtype";
      
      public static const CONSTANTS_KEY_MARKET_SUBSUBTYPE:String = "marketSubsubtype";
      
      public static const CONSTANTS_KEY_STATUE_NAME:String = "statueName";
      
      public static const CONSTANTS_KEY_MOTD_SEEN_FLAG:String = "motdSeenFlag";
      
      public static const CONSTANTS_KEY_BUILDING_KEY_NAME:String = "buildingKeyName";
      
      public static const CONSTANTS_KEY_EXPERIMENT:String = "experiment";
      
      public static const CONSTANTS_KEY_PREREQ:String = "prereq";
      
      public static const FEATURE_NAME_TREE:String = "item_membership_tree";
      
      public static const FEATURE_NAME_HORSE:String = "item_membership_horse";
      
      private var m_customInitFeatureName:String;
      
      public function ItemMembershipManager(xml:XML)
      {
         super();
         this.m_customInitFeatureName = xml.attribute("name").toString();
      }
      
      public static function getFeatureNames() : Array
      {
         var featureNames:Array = null;
         var result:Array = null;
         var featureName:String = null;
         var arrLength:int = 0;
         var i:int = 0;
         var priority:int = 0;
         if(!s_featureNames)
         {
            s_featureNames = [];
            featureNames = Global.farmGameSettingsManager.getFeatureNamesByType(FEATURE_TYPE);
            if(Boolean(featureNames) && featureNames.length > 0)
            {
               result = [featureNames.length];
               for each(featureName in featureNames)
               {
                  priority = getConstantsIntWithKey(featureName,CONSTANTS_KEY_PRIORITY);
                  if(priority < 0)
                  {
                     throw new Error("Feature \'" + featureName + "\' needs a \'priority\' attribute in its \'constants\' tag.");
                  }
                  result[priority] = featureName;
               }
               arrLength = int(result.length);
               for(i = 0; i < arrLength; i++)
               {
                  if(result[i] is String)
                  {
                     s_featureNames.push(result[i]);
                  }
               }
            }
         }
         return s_featureNames;
      }
      
      public static function getFeatureOption(featureName:String) : Object
      {
         var featureOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,featureName);
         if(!featureOption)
         {
            featureOption = {};
            setFeatureOption(featureName,featureOption);
         }
         return featureOption;
      }
      
      public static function setFeatureOption(featureName:String, featureData:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(featureName,featureName,featureData);
      }
      
      public static function getConfig(featureName:String) : XML
      {
         var config:XML = null;
         if(s_configs[featureName])
         {
            config = s_configs[featureName];
         }
         else
         {
            config = Global.farmGameSettingsManager.getFeatureXML(featureName);
            if(Boolean(config) && Boolean(config.toString()))
            {
               s_configs[featureName] = config;
            }
         }
         return config;
      }
      
      private static function getFeatureConfigManager(featureName:String) : FeatureConfigManager
      {
         var featureConfigManager:FeatureConfigManager = null;
         if(s_featureConfigManagers[featureName])
         {
            featureConfigManager = s_featureConfigManagers[featureName];
         }
         else
         {
            featureConfigManager = FeatureConfigManager.getFeatureConfiguration(featureName);
            if(featureConfigManager is FeatureConfigManager)
            {
               s_featureConfigManagers[featureName] = featureConfigManager;
            }
         }
         return featureConfigManager;
      }
      
      public static function getConstantsStringWithKey(featureName:String, key:String) : String
      {
         var result:String = "";
         var featureConfigManager:FeatureConfigManager = getFeatureConfigManager(featureName);
         if(Boolean(featureConfigManager) && featureConfigManager.hasConstant(key))
         {
            result = featureConfigManager.getStringConstant(key);
         }
         return result;
      }
      
      public static function getConstantsIntWithKey(featureName:String, key:String) : int
      {
         var result:int = int.MIN_VALUE;
         var featureConfigManager:FeatureConfigManager = getFeatureConfigManager(featureName);
         if(Boolean(featureConfigManager) && featureConfigManager.hasConstant(key))
         {
            result = featureConfigManager.getNumberConstant(key);
         }
         return result;
      }
      
      public static function getSubscriptionOptions(featureName:String) : XMLList
      {
         var result:XMLList = null;
         var configData:XML = getConfig(featureName);
         if(Boolean(configData) && Boolean(configData.child(SUBSCRIPTION_OPTIONS).toString()))
         {
            result = configData[SUBSCRIPTION_OPTIONS];
         }
         return result;
      }
      
      public static function getCostForMembershipLength(featureName:String, length:int) : int
      {
         var subscriptionOption:XML = null;
         var attributes:Object = null;
         var result:int = 0;
         var subscriptionOptions:XMLList = getSubscriptionOptions(featureName);
         for each(subscriptionOption in subscriptionOptions[0].children())
         {
            attributes = FarmGameUtil.xmlNodeToAttributes(subscriptionOption);
            if(Boolean(attributes && !isNaN(parseInt(attributes[NUM_MONTHS]))) && Boolean(parseInt(attributes[NUM_MONTHS]) === length) && !isNaN(parseInt(attributes[PRICE])))
            {
               result = parseInt(attributes[PRICE]);
            }
         }
         return result;
      }
      
      public static function getMembershipOptionSlotData(featureName:String) : Array
      {
         var experimentVariant:int = 0;
         var experimentVariantString:String = null;
         var subscriptionOption:XML = null;
         var slotData:Object = null;
         var attributes:Object = null;
         var validVariantsString:String = null;
         var validVariants:Array = null;
         var numBonusItems:int = 0;
         var resultData:Array = [];
         var experiment:String = getConstantsStringWithKey(featureName,CONSTANTS_KEY_EXPERIMENT);
         if(experiment)
         {
            experimentVariant = Global.experimentManager.getExperimentVariant(experiment);
            experimentVariantString = experimentVariant.toString();
         }
         var subscriptionOptions:XMLList = getSubscriptionOptions(featureName);
         for each(subscriptionOption in subscriptionOptions[0].children())
         {
            slotData = {};
            slotData[KEY_FEATURE_NAME] = featureName;
            attributes = FarmGameUtil.xmlNodeToAttributes(subscriptionOption);
            validVariantsString = attributes[VARIANT];
            validVariants = validVariantsString.split(",");
            if(validVariants.indexOf(experimentVariantString) != -1)
            {
               if(Boolean(attributes) && !isNaN(parseInt(attributes[NUM_MONTHS])))
               {
                  slotData[NUM_MONTHS] = parseInt(attributes[NUM_MONTHS]);
                  numBonusItems = getNumCumulativeBonusItemsForMembershipLevel(featureName,slotData[NUM_MONTHS]);
                  if(numBonusItems > 0)
                  {
                     slotData[KEY_NUM_BONUS_ITEMS] = numBonusItems;
                  }
               }
               if(Boolean(attributes) && !isNaN(parseInt(attributes[PRICE])))
               {
                  slotData[PRICE] = parseInt(attributes[PRICE]);
               }
               if(Boolean(attributes) && !isNaN(parseInt(attributes[PERCENT_DISCOUNT])))
               {
                  slotData[PERCENT_DISCOUNT] = parseInt(attributes[PERCENT_DISCOUNT]);
               }
               resultData.push(slotData);
            }
         }
         return resultData;
      }
      
      private static function getNumCumulativeBonusItemsForMembershipLevel(featureName:String, membershipLevel:int) : int
      {
         var membershipLevelXML:XML = null;
         var result:int = 0;
         var membershipLevels:XML = getMembershipLevelsConfig(featureName);
         if(Boolean(membershipLevels) && membershipLevels.length() > 0)
         {
            for each(membershipLevelXML in membershipLevels[0].children())
            {
               if(parseInt(membershipLevelXML.attribute("requiredMonths").toString()) <= membershipLevel)
               {
                  result += membershipLevelXML.children().length();
               }
            }
         }
         return result;
      }
      
      private static function getMembershipLevelsConfig(featureName:String) : XML
      {
         var memberLevels:XMLList = null;
         var result:XML = null;
         var configData:XML = getConfig(featureName);
         if(Boolean(configData) && configData.child(MEMBERSHIP_LEVELS).length() > 0)
         {
            memberLevels = configData[MEMBERSHIP_LEVELS];
            result = memberLevels[0];
         }
         return result;
      }
      
      public static function getBonusSlotData(featureName:String) : Array
      {
         var membershipLevel:XML = null;
         var slotDatum:Object = null;
         var numRequiredMonths:int = 0;
         var bonusItems:XMLList = null;
         var zLocObj:Object = null;
         var slotData:Array = [];
         var numMonthsSubscribed:int = getFeatureOptionWithKeys(featureName,NUM_MONTHS_SUBSCRIBED);
         var membershipLevels:XML = getMembershipLevelsConfig(featureName);
         var orderedMembershipLevels:Array = [];
         if(Boolean(membershipLevels) && membershipLevels.length() > 0)
         {
            for each(membershipLevel in membershipLevels[0].children())
            {
               orderedMembershipLevels.push(membershipLevel);
            }
         }
         orderedMembershipLevels.sortOn("@requiredMonths",Array.NUMERIC);
         for each(membershipLevel in orderedMembershipLevels)
         {
            slotDatum = {};
            numRequiredMonths = int(membershipLevel.attribute("requiredMonths"));
            slotDatum.numRequiredMonths = numRequiredMonths;
            if(numMonthsSubscribed >= numRequiredMonths)
            {
               bonusItems = membershipLevel.bonusItem;
               if(bonusItems.length())
               {
                  slotDatum.bonusItemName = bonusItems[0].attribute("name").toString();
               }
            }
            else
            {
               zLocObj = {
                  "numMonths":numRequiredMonths,
                  "numBonusItems":membershipLevel.children().length(),
                  "itemNamePlural":ZLocUtils.t("Dialogs",featureName + ZLOC_KEY_ITEM_PLURAL)
               };
               slotDatum.tooltipText = ZLocUtils.t("Dialogs",FEATURE_TYPE + "_bonus_item_tooltip",zLocObj);
            }
            slotData.push(slotDatum);
         }
         return slotData;
      }
      
      public static function isFirstTimeSubscribing(featureName:String) : Boolean
      {
         return parseInt(getFeatureOptionWithKeys(featureName,NUM_MONTHS_SUBSCRIBED)) === 1;
      }
      
      public static function subscribe(featureName:String, numMonths:int, price:int, wasOutOfCash:Boolean = false) : void
      {
         Global.player.cash -= price;
         updateFeatureDataOnSubscribe(featureName,numMonths);
         TransactionManager.addTransaction(new TGenericTransaction("ItemMembershipService","subscribe",null,[featureName,numMonths]));
         if(wasOutOfCash)
         {
            ItemMembershipWindow.showStatic(featureName);
         }
         if(isFirstTimeSubscribing(featureName))
         {
            ItemMembershipWelcomeWindow.showStatic(featureName);
         }
         else
         {
            conditionallyShowLevelUpWindow(featureName);
         }
      }
      
      public static function conditionallyShowLevelUpWindow(featureName:String) : Boolean
      {
         var windowShown:Boolean = false;
         var bonusItemNames:Array = getBonusItemNamesForNumMonthsSubscribed(featureName);
         if(Boolean(bonusItemNames) && bonusItemNames.length > 0)
         {
            ItemMembershipLevelUpWindow.showStatic(featureName,bonusItemNames);
            windowShown = true;
         }
         return windowShown;
      }
      
      public static function getFeatureOptionWithKeys(featureName:String, ... keys) : *
      {
         return FeatureOptionsManager.getInstance().getFeatureOptionPath(featureName,featureName,keys);
      }
      
      public static function isSubscribed(featureName:String) : Boolean
      {
         var result:Boolean = false;
         var subscribedTimestamp:uint = getFeatureOptionWithKeys(featureName,DATE_JOINED);
         var subscriptionLength:uint = getFeatureOptionWithKeys(featureName,SUBSCRIPTION_LENGTH);
         var subscribedDate:Date = new Date(subscribedTimestamp * FarmGameUtil.NUM_MSECS_IN_SECOND);
         subscribedDate.setHours(0,0,0,0);
         var endDate:Date = new Date(subscribedTimestamp * FarmGameUtil.NUM_MSECS_IN_SECOND);
         var endMonth:int = endDate.month + subscriptionLength;
         endDate.setMonth(endMonth % FarmGameUtil.NUM_MONTHS_IN_YEAR);
         endDate.setFullYear(endDate.fullYear + endMonth / FarmGameUtil.NUM_MONTHS_IN_YEAR);
         endDate.setHours(0,0,0,0);
         var currentTime:Date = new Date(GlobalEngine.serverTime);
         if(currentTime.time >= subscribedDate.time && currentTime.time < endDate.time)
         {
            result = true;
         }
         return result;
      }
      
      private static function updateFeatureDataOnSubscribe(featureName:String, numMonths:int) : void
      {
         var featureData:Object = getFeatureOption(featureName);
         if(!featureData[NUM_MONTHS_SUBSCRIBED])
         {
            featureData[NUM_MONTHS_SUBSCRIBED] = 0;
         }
         if(!featureData[NUM_CREDITS])
         {
            featureData[NUM_CREDITS] = 0;
         }
         if(!featureData[CONTEXTUAL_ONBOARDING_COUNT])
         {
            featureData[CONTEXTUAL_ONBOARDING_COUNT] = 0;
         }
         featureData[DATE_JOINED] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         featureData[NUM_MONTHS_SUBSCRIBED] += 1;
         featureData[SHOULD_RENEW] = true;
         featureData[SUBSCRIPTION_LENGTH] = numMonths;
         var numCreditsPerMonth:int = ItemMembershipManager.getConstantsIntWithKey(featureName,CONSTANTS_KEY_NUM_CREDITS_PER_MONTH);
         featureData[NUM_CREDITS] += numCreditsPerMonth > 0 ? numCreditsPerMonth : 0;
         setFeatureOption(featureName,featureData);
      }
      
      public static function getItemsToRedeem(featureName:String) : Array
      {
         var item:FarmItem = null;
         var slotDatum:Object = null;
         var result:Array = [];
         var type:String = FarmGameSettingsManager.ALL;
         var subtype:String = FarmGameSettingsManager.ALL;
         var subsubtype:String = FarmGameSettingsManager.ALL;
         var featureConfigType:String = ItemMembershipManager.getConstantsStringWithKey(featureName,CONSTANTS_KEY_MARKET_TYPE);
         if(featureConfigType)
         {
            type = featureConfigType;
         }
         var featureConfigSubtype:String = ItemMembershipManager.getConstantsStringWithKey(featureName,CONSTANTS_KEY_MARKET_SUBTYPE);
         if(featureConfigSubtype)
         {
            subtype = featureConfigSubtype;
         }
         var featureConfigSubsubtype:String = ItemMembershipManager.getConstantsStringWithKey(featureName,CONSTANTS_KEY_MARKET_SUBSUBTYPE);
         if(featureConfigSubsubtype)
         {
            subsubtype = featureConfigSubsubtype;
         }
         var itemsByType:Array = Global.farmGameSettingsManager.getFarmItemsArray(type,subtype,subsubtype,FarmGameSettingsManager.REQUIRED_LEVEL,FarmGameSettingsManager.ASCENDING,true,"",null,true);
         for each(item in itemsByType)
         {
            if(isItemMemberOfFeature(featureName,item))
            {
               slotDatum = {};
               slotDatum[ItemMembershipManager.KEY_FEATURE_NAME] = featureName;
               slotDatum["item"] = item;
               result.push(slotDatum);
            }
         }
         return result;
      }
      
      public static function redeem(featureName:String, itemCode:String) : void
      {
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         if(Boolean(itemName) && decrementNumCredits(featureName))
         {
            Global.player.addGift(itemName,"0",1);
            TransactionManager.addTransaction(new TGenericTransaction("ItemMembershipService","redeem",null,[featureName,itemCode]));
            ToasterManager.getInstance().togglePauseQueue(false);
            ToasterManager.getInstance().addImmediate(new ItemMembershipToasterWindow(TOASTER_ASSET_PATH,itemName));
         }
      }
      
      private static function decrementNumCredits(featureName:String) : Boolean
      {
         var numCredits:* = 0;
         var success:Boolean = false;
         var featureOption:Object = getFeatureOption(featureName);
         if(Boolean(featureOption) && Boolean(featureOption[NUM_CREDITS]))
         {
            numCredits = int(featureOption[NUM_CREDITS]);
            if(numCredits > 0)
            {
               numCredits--;
               featureOption[NUM_CREDITS] = numCredits;
               setFeatureOption(featureName,featureOption);
               success = true;
            }
         }
         return success;
      }
      
      public static function isInItemMembershipExperiment() : Boolean
      {
         var featureNames:Array = Global.farmGameSettingsManager.getFeatureNamesByType(FEATURE_TYPE);
         return Boolean(featureNames) && featureNames.length > 0;
      }
      
      public static function onActionMenuIconClicked() : void
      {
         if(Global.player.postInitFinished)
         {
            ItemMembershipWindow.showStatic();
            StatsManager.count("EhButton","Memberships","Click");
         }
      }
      
      public static function unsubscribe(featureName:String) : void
      {
         var featureOption:Object = getFeatureOption(featureName);
         if(ObjectUtil.pathExists(featureOption,SHOULD_RENEW))
         {
            featureOption[SHOULD_RENEW] = false;
            setFeatureOption(featureName,featureOption);
            TransactionManager.addTransaction(new TGenericTransaction("ItemMembershipService","unsubscribe",null,[featureName]));
         }
      }
      
      public static function getBonusItemNamesForNumMonthsSubscribed(featureName:String, offset:int = 0) : Array
      {
         var featureConfig:XML = null;
         var membershipLevel:XMLList = null;
         var bonusItem:XML = null;
         var bonusItemName:String = null;
         var bonusItems:Array = [];
         var numMonthsSubscribed:String = getFeatureOptionWithKeys(featureName,NUM_MONTHS_SUBSCRIBED);
         var numMonthsSubscribedWithOffset:int = parseInt(numMonthsSubscribed) + offset;
         if(numMonthsSubscribedWithOffset)
         {
            featureConfig = getConfig(featureName);
            if(featureConfig.toString())
            {
               membershipLevel = featureConfig.child(MEMBERSHIP_LEVELS).child(MEMBERSHIP_LEVEL).(@requiredMonths == numMonthsSubscribedWithOffset.toString());
               if(membershipLevel.toString())
               {
                  for each(bonusItem in membershipLevel[0].children())
                  {
                     bonusItemName = bonusItem.@name.toString();
                     if(bonusItemName)
                     {
                        bonusItems.push(bonusItemName);
                     }
                  }
               }
            }
         }
         return bonusItems;
      }
      
      private static function getAllBonusItemNames(featureName:String) : Object
      {
         var result:Object = null;
         var featureConfig:XML = null;
         var membershipLevels:XMLList = null;
         var membershipLevel:XML = null;
         var bonusItem:XML = null;
         var bonusItemName:String = null;
         if(!s_bonusItemNamesMap[featureName])
         {
            result = {};
            featureConfig = getConfig(featureName);
            if(featureConfig.toString())
            {
               membershipLevels = featureConfig.child(MEMBERSHIP_LEVELS);
               if(membershipLevels.toString())
               {
                  for each(membershipLevel in membershipLevels[0].children())
                  {
                     for each(bonusItem in membershipLevel.children())
                     {
                        bonusItemName = bonusItem.@name.toString();
                        if(bonusItemName)
                        {
                           result[bonusItemName] = true;
                        }
                     }
                  }
               }
            }
            s_bonusItemNamesMap[featureName] = result;
         }
         return s_bonusItemNamesMap[featureName];
      }
      
      public static function conditionallyOnboardFromBuilding(building:FeatureBuilding) : void
      {
         var featureName:String = null;
         var buildingKeyName:String = null;
         var featureNames:Array = getFeatureNames();
         for each(featureName in featureNames)
         {
            buildingKeyName = getConstantsStringWithKey(featureName,CONSTANTS_KEY_BUILDING_KEY_NAME);
            if(Boolean(buildingKeyName) && building.getItemName().toLowerCase().search(buildingKeyName.toLocaleLowerCase()) != -1)
            {
               conditionallyOnboard(featureName);
               break;
            }
         }
      }
      
      public static function conditionallyOnboardFromItem(item:FarmItem) : void
      {
         var featureName:String = ItemMembershipManager.getOnboardingFeatureNameForItem(item);
         if(featureName)
         {
            conditionallyOnboard(featureName);
         }
      }
      
      public static function conditionallyOnboard(featureName:String, windowNotSurfaced:Boolean = false) : void
      {
         var featureOption:Object = null;
         if(Boolean(!windowNotSurfaced && featureName && s_MOTDs[featureName] is Object && !(s_MOTDs[featureName] is String) && passesExperiment(featureName) && passesBackoffLogic(featureName)) && Boolean(passesOnboardChance()) && !isSubscribed(featureName))
         {
            StatsManager.count(featureName,StatsTrackingConstants.ONBOARD,StatsTrackingConstants.IMPRESSIONS);
            MOTD.displayMOTD(s_MOTDs[featureName],false,onOnboarded,onOnboarded);
            featureOption = getFeatureOption(featureName);
            if(featureOption)
            {
               featureOption[DATE_LAST_CONTEXTUALLY_ONBOARDED] = GlobalEngine.serverTime;
               if(!featureOption[CONTEXTUAL_ONBOARDING_COUNT])
               {
                  featureOption[CONTEXTUAL_ONBOARDING_COUNT] = 0;
               }
               ++featureOption[CONTEXTUAL_ONBOARDING_COUNT];
               setFeatureOption(featureName,featureOption);
               TransactionManager.addTransaction(new TGenericTransaction("ItemMembershipService","updateOnboardingData",null,[featureName]));
            }
         }
      }
      
      public static function onOnboarded(event:Event) : void
      {
         StatsManager.count(FEATURE_TYPE,StatsTrackingConstants.ONBOARD,StatsTrackingConstants.STATS_CLICK);
      }
      
      private static function passesExperiment(featureName:String) : Boolean
      {
         return Global.experimentManager.getExperimentVariant(getConstantsStringWithKey(featureName,CONSTANTS_KEY_EXPERIMENT)) >= Experiments.VARIANT_ITEM_MEMBERSHIP_VALID_VARIANT_START;
      }
      
      private static function passesBackoffLogic(featureName:String) : Boolean
      {
         var currentTime:Number = NaN;
         var dateLastOnboarded:Number = NaN;
         var numsecondsSinceLastOnboard:Number = NaN;
         var numDaysSinceLastOnboarded:int = 0;
         var numTimesOnboarded:int = getFeatureOptionWithKeys(featureName,CONTEXTUAL_ONBOARDING_COUNT);
         var continueFlow:Boolean = false;
         if(numTimesOnboarded < NUM_TIMES_TO_ONBOARD_BEFORE_WEEK_WAIT)
         {
            continueFlow = true;
         }
         else
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            dateLastOnboarded = getFeatureOptionWithKeys(featureName,DATE_LAST_CONTEXTUALLY_ONBOARDED);
            numsecondsSinceLastOnboard = currentTime - dateLastOnboarded;
            numDaysSinceLastOnboarded = numsecondsSinceLastOnboard / FarmGameUtil.NUM_SECS_IN_DAY;
            if(numTimesOnboarded < NUM_TIMES_TO_ONBOARD_BEFORE_MONTH_WAIT && numDaysSinceLastOnboarded >= FarmGameUtil.NUM_DAYS_IN_WEEK)
            {
               continueFlow = true;
            }
            else if(numDaysSinceLastOnboarded >= NUM_DAYS_IN_MONTH_APPROXIMATE)
            {
               continueFlow = true;
            }
         }
         return continueFlow;
      }
      
      private static function passesOnboardChance() : Boolean
      {
         var onboardChance:Number = Number(Global.flashHotParams[RUNTIME_KEY_ONBOARD_CHANCE]);
         return onboardChance >= Math.random();
      }
      
      public static function onboard(featureName:String) : void
      {
         var arrayOfStatues:Array = null;
         var giftItem:FarmItem = null;
         var statueName:String = getConstantsStringWithKey(featureName,CONSTANTS_KEY_STATUE_NAME);
         if(statueName)
         {
            arrayOfStatues = Global.world.getObjectsByName(statueName);
            if(Boolean(arrayOfStatues) && arrayOfStatues.length > 0)
            {
               ItemMembershipWindow.showStatic(featureName);
            }
            else
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByName(statueName);
               if(Boolean(giftItem) && !giftItem.checkItemLimit(false))
               {
                  Global.world.enterForcePlaceMode(giftItem.name);
               }
            }
         }
      }
      
      public static function getOnboardingFeatureNameForItem(item:FarmItem) : String
      {
         var featureName:String = null;
         var result:String = null;
         var featureNames:Array = getFeatureNames();
         for each(featureName in featureNames)
         {
            if(isItemMemberOfFeature(featureName,item))
            {
               result = featureName;
               break;
            }
         }
         return result;
      }
      
      public static function onGetMOTD(motd:Object) : void
      {
         var featureName:String = null;
         for(featureName in s_MOTDs)
         {
            if(s_MOTDs[featureName] == motd["motdSeenFlag"])
            {
               s_MOTDs[featureName] = motd;
               break;
            }
         }
      }
      
      public static function getMOTDs() : void
      {
         var featureName:String = null;
         var motdSeenFlag:String = null;
         var featureNames:Array = getFeatureNames();
         if(featureNames)
         {
            for each(featureName in featureNames)
            {
               motdSeenFlag = getConstantsStringWithKey(featureName,CONSTANTS_KEY_MOTD_SEEN_FLAG);
               if(motdSeenFlag)
               {
                  s_MOTDs[featureName] = motdSeenFlag;
                  TransactionManager.addTransaction(new TGetMOTD(motdSeenFlag,onGetMOTD));
               }
            }
         }
      }
      
      public static function isItemMemberOfFeature(featureName:String, item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         var redeemPrereqName:String = getConstantsStringWithKey(featureName,CONSTANTS_KEY_PREREQ);
         if(Boolean(redeemPrereqName && !isBlacklisted(featureName,item)) && Boolean(!RewardCard.isInRedeemBlacklist(item)) && (isWhitelisted(featureName,item) || PrerequisiteUtility.checkPrereqByName(redeemPrereqName,item)))
         {
            result = true;
         }
         return result;
      }
      
      private static function isBlacklisted(featureName:String, item:FarmItem) : Boolean
      {
         return getRuntimeValForItem(featureName,item) === BLACKLISTED;
      }
      
      private static function isWhitelisted(featureName:String, item:FarmItem) : Boolean
      {
         return getRuntimeValForItem(featureName,item) === WHITELISTED;
      }
      
      private static function getRuntimeValForItem(featureName:String, item:FarmItem) : int
      {
         var encodedRuntimeList:String = null;
         var decodedRuntimeList:Object = null;
         var result:int = NOT_IN_RUNTIME;
         if(!s_runtimeMap[featureName])
         {
            encodedRuntimeList = Global.flashHotParams["ITEM_MEMBERSHIP_EXCEPTIONS"];
            if(encodedRuntimeList)
            {
               decodedRuntimeList = com.adobe.serialization.json.JSON.decode(encodedRuntimeList);
               if(Boolean(decodedRuntimeList) && Boolean(decodedRuntimeList[featureName]))
               {
                  s_runtimeMap[featureName] = decodedRuntimeList[featureName];
               }
            }
         }
         var featureSpecificRuntimeList:Object = s_runtimeMap[featureName];
         if(Boolean(featureSpecificRuntimeList) && item.name in featureSpecificRuntimeList)
         {
            if(featureSpecificRuntimeList[item.name] === true)
            {
               result = WHITELISTED;
            }
            else
            {
               result = BLACKLISTED;
            }
         }
         return result;
      }
      
      public static function isItemRedeemable(item:FarmItem) : Boolean
      {
         var featureName:String = null;
         var result:Boolean = false;
         if(!s_hasCachedLimitedRedemptionExperiment)
         {
            s_hasCachedLimitedRedemptionExperiment = true;
            s_isInLimitedRedemptionExperiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ITEM_MEMBERSHIP_TREES_LIMITED_REDEMPTION) == Experiments.VARIANT_ITEM_MEMBERSHIP_TREES_LIMITED_REDEMPTION_ON;
         }
         var featureNames:Array = getFeatureNames();
         for each(featureName in featureNames)
         {
            if(isItemMemberOfFeature(featureName,item))
            {
               if(getFeatureOptionWithKeys(featureName,NUM_CREDITS) > 0 && (!s_isInLimitedRedemptionExperiment || !isSubscribed(featureName)))
               {
                  result = true;
               }
               break;
            }
         }
         return result;
      }
      
      public static function onPurchaseSuccess(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(onBalanceRefresh),true);
      }
      
      public static function onBalanceRefresh(result:Object) : void
      {
         var featureName:String = s_outOfCashFeatureName;
         var membershipLength:int = getFeatureOptionWithKeys(s_outOfCashFeatureName,SUBSCRIPTION_LENGTH);
         var price:int = getCostForMembershipLength(featureName,membershipLength);
         if(Boolean(featureName) && Boolean(result["cash"]))
         {
            StatsManager.count(featureName,StatsTrackingConstants.NOT_ENOUGH_CASH,StatsTrackingConstants.PURCHASED,result.cash);
         }
         if(price > 0)
         {
            subscribe(featureName,membershipLength,price,true);
         }
      }
      
      public static function doPostInit(result:Object) : void
      {
         var itemMembershipData:Object = null;
         var featureName:String = null;
         var itemMembershipDatum:Object = null;
         if(isInItemMembershipExperiment())
         {
            getMOTDs();
            if(result["itemMembershipData"])
            {
               itemMembershipData = result["itemMembershipData"];
               for(featureName in itemMembershipData)
               {
                  itemMembershipDatum = itemMembershipData[featureName];
                  if(itemMembershipDatum["featureData"])
                  {
                     FeatureOptionsManager.getInstance().setFeatureOption(featureName,featureName,itemMembershipDatum.featureData);
                  }
                  if(!itemMembershipDatum["action"])
                  {
                     continue;
                  }
                  switch(itemMembershipDatum.action)
                  {
                     case "reSubscribed":
                     case "subscriptionUpdated":
                        if(!conditionallyShowLevelUpWindow(featureName))
                        {
                           ItemMembershipWindow.showStatic(featureName);
                        }
                        break;
                     case "notEnoughMoneyForReSubscribe":
                        ItemMembershipOutOfCashWindow.showStatic(featureName);
                  }
               }
            }
         }
      }
      
      public function initialize() : void
      {
         if(this.m_customInitFeatureName)
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_customInitFeatureName,ItemMembershipWindow.showStatic);
         }
      }
   }
}

