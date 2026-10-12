package Classes.Quest
{
   import Classes.BuyerPromo.BuyerPromoUtility;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.ExtendedPermissionState;
   import Classes.FeatureBuilding;
   import Classes.Growable.GrowableContest;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.WorldLicenseRequirement;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.ErrorManager;
   import Managers.CommunityGoalsManager;
   import Managers.Crafting.CraftingManager;
   import Managers.DollarBundlesManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.GrowableContestManager;
   import Managers.HolidayCountdownManager;
   import Managers.ItemContestManager;
   import Managers.LESurfacingManager;
   import Managers.LicenseManager;
   import Managers.MiniDartsManager;
   import Managers.PackPurchaseManager;
   import Managers.PostInitSettings;
   import Managers.SpendometerManager;
   import Managers.SubscriptionsManager;
   import Managers.SuperPlotManager;
   import Managers.UGCDecoManager;
   import Managers.UnlimitedPacksManager;
   import Managers.WeekendDelightManager;
   import Managers.WorldSeasonsManager;
   import Replay.ArrayUtils;
   import Widgets.Windows.Promotions.EmailCampaignWindow;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import flash.utils.getDefinitionByName;
   
   public class PrerequisiteUtility
   {
      
      private static var m_lastPrereqTested:Object = null;
      
      public static const PREREQ_DIAGNOSIS_FAILED:String = "FAILED";
      
      public static const PREREQ_DIAGNOSIS_PASSED:String = "OK    ";
      
      public static const PREREQ_FUNCTION_PREFIX:String = "check";
      
      public static const FLASH_RUNTIME_PREFIX:String = "FEATURE_FLASHPARAM_";
      
      public function PrerequisiteUtility()
      {
         super();
      }
      
      public static function parseXmlNodePrereqs(prereqs:XMLList) : Array
      {
         var node:XML = null;
         var result:Array = [];
         if(prereqs)
         {
            for each(node in prereqs)
            {
               result.push(FarmGameSettingsManager.parseXmlAttributesToObject(node,true));
            }
         }
         return result;
      }
      
      public static function parseDataSourcePrereqs(prereqsDataArray:Array) : Array
      {
         var prereqData:BaseDataSource = null;
         var result:Array = [];
         for each(prereqData in prereqsDataArray)
         {
            result.push(prereqData.getAttributesHash(true));
         }
         return result;
      }
      
      public static function mergePrereqObject(primaryReq:Object, secondaryReq:Object) : Object
      {
         var paramField:String = null;
         var result:Object = null;
         if(primaryReq)
         {
            result = primaryReq;
            for(paramField in secondaryReq)
            {
               if(!result.hasOwnProperty(paramField) && paramField != FarmGameSettingsManager.XML_CHILDREN_FIELD && paramField != PrerequisiteConstants.KEY_NAME)
               {
                  result[paramField] = secondaryReq[paramField];
               }
            }
         }
         else
         {
            result = secondaryReq;
         }
         return result;
      }
      
      public static function getPreqreqType(params:Object) : String
      {
         return params[PrerequisiteConstants.KEY_TYPE];
      }
      
      public static function evalPrereqsXML(prereqsXML:XMLList, context:Object = null) : Boolean
      {
         return arePrerequisitesMet(parseXmlNodePrereqs(prereqsXML),context);
      }
      
      public static function evalPrereqsData(prereqsDataArray:Array, context:Object = null) : Boolean
      {
         return arePrerequisitesMet(parseDataSourcePrereqs(prereqsDataArray),context);
      }
      
      public static function checkPrereqByName(name:String, context:Object = null) : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(name);
         if(prereq)
         {
            result = PrerequisiteUtility.isPrerequisiteMet(prereq,context);
         }
         return result;
      }
      
      public static function diagnosePrerequisite(xml:XML) : Object
      {
         var prereqNode:Object = null;
         var prereqXML:XML = null;
         var result:Object = {"result":true};
         if(xml.hasOwnProperty("@type"))
         {
            result["type"] = xml.@type[0].toString();
         }
         if(xml.hasOwnProperty("@value"))
         {
            result["value"] = xml.@value[0].toString();
         }
         if(xml.hasOwnProperty("@op"))
         {
            result["op"] = xml.@op[0].toString();
         }
         if(xml.hasOwnProperty("@variant"))
         {
            result["variant"] = xml.@variant[0].toString();
         }
         var prereqs:XMLList = null;
         if(xml.hasOwnProperty("prereqs"))
         {
            result["result"] = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children()));
            prereqs = xml.prereqs.children();
         }
         else
         {
            if(xml.name().localName == PrerequisiteConstants.PREREQ_XML_TAG)
            {
               prereqNode = FarmGameSettingsManager.parseXmlAttributesToObject(xml,true);
               result["result"] = PrerequisiteUtility.isPrerequisiteMet(prereqNode);
            }
            if(xml.hasOwnProperty("prereq"))
            {
               prereqs = xml.prereq;
            }
         }
         if(prereqs != null)
         {
            result["children"] = [];
            for each(prereqXML in prereqs)
            {
               (result["children"] as Array).push(diagnosePrerequisite(prereqXML));
            }
         }
         return result;
      }
      
      public static function parseConsoleDiagnosis(diagnosis:Object, indent:int = 0) : String
      {
         var child:Object = null;
         var result:String = "";
         if(diagnosis.result)
         {
            result += PREREQ_DIAGNOSIS_PASSED;
         }
         else
         {
            result += PREREQ_DIAGNOSIS_FAILED;
         }
         for(var i:int = 0; i < indent + 1; i++)
         {
            result += "    ";
         }
         if(diagnosis.hasOwnProperty(PrerequisiteConstants.KEY_TYPE))
         {
            result += "<prereq ";
            result += "type=\'" + diagnosis[PrerequisiteConstants.KEY_TYPE] + "\' ";
            if(diagnosis.hasOwnProperty(PrerequisiteConstants.KEY_VALUE))
            {
               result += "value=\'" + diagnosis[PrerequisiteConstants.KEY_VALUE] + "\' ";
            }
            if(diagnosis.hasOwnProperty(PrerequisiteConstants.KEY_VARIANT))
            {
               result += "variant=\'" + diagnosis[PrerequisiteConstants.KEY_VARIANT] + "\' ";
            }
            if(diagnosis.hasOwnProperty(PrerequisiteConstants.KEY_OP))
            {
               result += "op=\'" + diagnosis[PrerequisiteConstants.KEY_OP] + "\' ";
            }
            result += "/>";
         }
         result += "\n";
         if(diagnosis.hasOwnProperty("children"))
         {
            for each(child in diagnosis["children"])
            {
               result += parseConsoleDiagnosis(child,indent + 1);
            }
         }
         return result;
      }
      
      public static function arePrerequisitesMet(prereqs:Array, context:Object = null) : Boolean
      {
         var idx:int = 0;
         var len:int = 0;
         var result:Boolean = true;
         if(prereqs)
         {
            idx = 0;
            len = int(prereqs.length);
            while(result && idx < len)
            {
               if(!isPrerequisiteMet(prereqs[idx],context))
               {
                  result = false;
                  break;
               }
               idx++;
            }
         }
         return result;
      }
      
      public static function diagnoseFailedPrerequisite(params:Object, context:Object = null) : Object
      {
         var result:Object = null;
         PrerequisiteUtility.m_lastPrereqTested = null;
         if(!isPrerequisiteMet(params,context))
         {
            result = PrerequisiteUtility.m_lastPrereqTested;
         }
         return result;
      }
      
      public static function filterPrerequisitesFromVector(vectorOfPrereqObjects:Vector.<Object>, filterList:Array, keepItemsFromFilterList:Boolean) : Array
      {
         return filterPrerequisitesFromArray(ArrayUtils.vectorToArray(vectorOfPrereqObjects),filterList,keepItemsFromFilterList);
      }
      
      public static function filterPrerequisitesFromArray(arrayOfPrereqObjects:Array, filterList:Array, keepItemsFromFilterList:Boolean) : Array
      {
         var filterName:String = null;
         var resultArray:Array = new Array();
         var filter:Boolean = false;
         var prereqType:String = null;
         var prereqLength:int = int(arrayOfPrereqObjects.length);
         for(var index:int = 0; index < prereqLength; index++)
         {
            prereqType = arrayOfPrereqObjects[index].type;
            filter = false;
            for each(filterName in filterList)
            {
               if(filterName == prereqType)
               {
                  filter = true;
                  break;
               }
            }
            if(keepItemsFromFilterList == filter)
            {
               resultArray.push(arrayOfPrereqObjects[index]);
            }
         }
         return resultArray;
      }
      
      public static function isPrerequisiteMet(params:Object, context:Object = null) : Boolean
      {
         var value:String = null;
         var prerequisiteType:String = null;
         var op:String = null;
         var lastShown:int = 0;
         var location:String = null;
         var newPrereq:Object = null;
         var hasSeenFlag:Boolean = false;
         var hasSeenMotd:Boolean = false;
         var scoreUnit:String = null;
         var requiredLevel:int = 0;
         var objectsInWorld:Array = null;
         var days:int = 0;
         var recentlyPurchased:Array = null;
         var variants:Array = null;
         var eosVariants:Array = null;
         var isPayer:Boolean = false;
         var valueBool:Boolean = false;
         var packId:String = null;
         var prereqValues:Object = null;
         var permissions:Array = null;
         var activePromoName:String = null;
         var licenseType:String = null;
         var worldObjects:Array = null;
         var isSubscriber:Boolean = false;
         var isExSubscriber:Boolean = false;
         var cancelledBefore:int = 0;
         var isMasteryCleaned:Boolean = false;
         var isExSub:Boolean = false;
         var cancelled:int = 0;
         var heighestStreak:int = 0;
         var subscriptionStatusActive:String = null;
         var subscriptionStatusCancel:String = null;
         var isSubscribed:Boolean = false;
         var streak:int = 0;
         var limitedItem:FarmItem = null;
         var farmItem:FarmItem = null;
         var count:int = 0;
         var j:int = 0;
         var contextValue:* = undefined;
         var time:int = 0;
         var interval:int = 0;
         var currentTime:int = 0;
         var timeSinceLastSeen:int = 0;
         var userCount:int = 0;
         var shouldBeVisiting:Boolean = false;
         var limitedItems:Object = null;
         var limitedItemName:String = null;
         var giftBoxItems:int = 0;
         var canUnlockNextSeason:Boolean = false;
         var expansionLevel:int = 0;
         var timeSinceLastLogin:Number = NaN;
         var masteryItem:FarmItem = null;
         var level:int = 0;
         var item:FarmItem = null;
         var required:Number = NaN;
         var contestId:String = null;
         var growableContest:GrowableContest = null;
         var completed:Number = NaN;
         var rsvpStatus:Boolean = false;
         var daysSinceLastExpansionAccess:Number = NaN;
         var currentDayOfWeek:int = 0;
         var isMysteryCratePlaceable:Boolean = false;
         var isInitialized:Boolean = false;
         var isActive:Boolean = false;
         var isActiveforTheDay:Boolean = false;
         var isPackAvailable:Boolean = false;
         var functionName:String = null;
         var myclass:Class = null;
         var variant:String = null;
         var eosVariant:String = null;
         var i:int = 0;
         var featureData:Object = null;
         var reactivationVersionFlag:String = null;
         var subscriptionStatus:String = null;
         var specifiedCount:int = 0;
         var specifiedRange:String = null;
         var buildingItem:FarmItem = null;
         var contestManager:ItemContestManager = null;
         var initialPlantTime:Number = NaN;
         var daysSinceInit:Number = NaN;
         var result:Boolean = false;
         value = params[PrerequisiteConstants.KEY_VALUE];
         prerequisiteType = params[PrerequisiteConstants.KEY_TYPE];
         op = PrerequisiteConstants.PREREQ_OP_NOT_SUPPORTED;
         var requirementsArray:Array = params[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         PrerequisiteUtility.m_lastPrereqTested = params;
         lastShown = 0;
         location = "";
         switch(prerequisiteType)
         {
            case PrerequisiteConstants.PREREQUISITE_AND_GROUP:
            case PrerequisiteConstants.PREREQUISITE_OR_GROUP:
               result = handleGroupLogic(params,context);
               break;
            case PrerequisiteConstants.PREREQUISITE_PREREQ_REFERENCE:
               newPrereq = Global.farmGameSettingsManager.getPrereqByName(value);
               if(newPrereq)
               {
                  op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
                  newPrereq = mergePrereqObject(newPrereq,params);
                  result = getComparisonValueBoolean(isPrerequisiteMet(newPrereq,context),true,op);
               }
               else
               {
                  ErrorManager.addError("Named prereq not found: " + value);
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_CASH:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               result = getComparisonValue(Global.player.cash,parseInt(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_COINS:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               result = getComparisonValue(Global.player.gold,parseInt(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_END_TIME:
               if(params.hasOwnProperty(PrerequisiteConstants.META_IGNORE_DATE) && Boolean(params[PrerequisiteConstants.META_IGNORE_DATE]))
               {
                  result = true;
               }
               else
               {
                  op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_LESS_THAN_EQUALS);
                  result = getComparisonValue(GlobalEngine.serverTime,FarmGameUtil.synchronizedDateTimeToNumber(value),op);
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_START_TIME:
               if(params.hasOwnProperty(PrerequisiteConstants.META_IGNORE_DATE) && Boolean(params[PrerequisiteConstants.META_IGNORE_DATE]))
               {
                  result = true;
               }
               else
               {
                  op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
                  result = getComparisonValue(GlobalEngine.serverTime,FarmGameUtil.synchronizedDateTimeToNumber(value),op);
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_LEVEL_MAX:
               result = Global.player.level <= parseInt(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_SEEN_FLAG:
               hasSeenFlag = false;
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               hasSeenFlag = Global.player.getSeenFlag(params[PrerequisiteConstants.KEY_VALUE]);
               result = getComparisonValueBoolean(hasSeenFlag,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_SEEN_MOTD:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               hasSeenMotd = Global.player.isMotdSeenFlagSet(params[PrerequisiteConstants.KEY_VALUE]);
               result = getComparisonValueBoolean(hasSeenMotd,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_LEVEL_MIN:
               result = Global.player.level >= parseInt(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_WORLD_LEVEL_MIN:
               scoreUnit = value;
               requiredLevel = params.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY) ? int(params[PrerequisiteConstants.KEY_QUANTITY]) : 0;
               result = Global.player.getWorldLevel(scoreUnit) >= requiredLevel;
               break;
            case PrerequisiteConstants.PREREQUISITE_LOCATION:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = getComparisonValueString(Global.worldManager.currentWorldType,value,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_UNLOCKED_WORLD:
               result = Global.worldManager.hasUnlockedWorld(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_NOT_UNLOCKED_WORLD:
               result = !Global.worldManager.hasUnlockedWorld(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_VISITED_WORLD:
               result = Global.player.hasWorldOfType(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_ITEM:
               objectsInWorld = Global.world.getObjectsByCode(value);
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = getComparisonValueBoolean(objectsInWorld.length > 0,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_ITEM_CATEGORY:
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_BOUGHT_LE_ITEMS:
               days = value != "" ? int(parseInt(value)) : 30;
               recentlyPurchased = LESurfacingManager.instance.cashItemsPurchasedRecently(days);
               result = recentlyPurchased.length > 0;
               break;
            case PrerequisiteConstants.PREREQUISITE_ACCT_AGE_DAYS_MIN:
               result = Global.player.accountAge / FarmGameUtil.NUM_SECS_IN_DAY >= parseFloat(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_IN_EXPERIMENT:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               variants = (params[PrerequisiteConstants.KEY_VARIANT] as String).split(",");
               result = false;
               for each(variant in variants)
               {
                  if(getComparisonValue(Global.experimentManager.getExperimentVariant(value),parseInt(variant),op))
                  {
                     result = true;
                     break;
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_IN_EOS:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               eosVariants = (params[PrerequisiteConstants.KEY_VARIANT] as String).split(",");
               result = false;
               for each(eosVariant in eosVariants)
               {
                  if(getComparisonValue(Global.eosManager.getEosVariant(value),parseInt(eosVariant),op))
                  {
                     result = true;
                     break;
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_PAYER:
               isPayer = Global.player.initialCashPurchasedTransactions > 0 || Global.player.initialCPATransactions > 0;
               valueBool = value == "true" ? true : false;
               result = isPayer == valueBool;
               break;
            case PrerequisiteConstants.PREREQUISITE_PURCHASE_LIMIT:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_LESS_THAN);
               packId = params[PrerequisiteConstants.KEY_PACK_NAME];
               if(packId)
               {
                  result = getComparisonValue(PackPurchaseManager.getInstance().getNumberOfPackPurchases(packId),parseInt(value),op);
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_DATA_SERVICE_INFO:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               prereqValues = Global.player.prereqDSObject;
               if(Boolean(prereqValues) && prereqValues.hasOwnProperty(value))
               {
                  result = getComparisonValue(prereqValues[value],parseInt(params[PrerequisiteConstants.KEY_TARGET]),op);
               }
               break;
            case ExtendedPermissionState.PREREQUISITE_NO_SN_PERMISSION:
               permissions = value.split(",");
               for(i = 0; i < permissions.count; i++)
               {
                  if(!Global.player.extendedPermissionState.hasExtendedPermission(permissions[i]))
                  {
                     result = true;
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_ACTIVE_PROMO_NAME:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               activePromoName = BuyerPromoUtility.getCurrentPromoName();
               result = getComparisonValueString(activePromoName,value,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_NO_WORLD_LICENSE:
               licenseType = WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE;
               if(params.licenseType != null)
               {
                  licenseType = params.licenseType;
               }
               result = !Global.worldManager.hasWorldContentLicense(value,licenseType);
               break;
            case PrerequisiteConstants.PREREQUISITE_LICENSE:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               if(params.hasOwnProperty("value"))
               {
                  result = LicenseManager.getInstance().hasCurrentLicense(params.value);
               }
               result = getComparisonValueBoolean(result,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_NOT_PLACED_ITEM:
               worldObjects = Global.world.getObjectsByCode(value);
               result = worldObjects.length == 0;
               break;
            case PrerequisiteConstants.PREREQUISITE_SPENDOMETER_ACTIVE:
               result = false;
               if(SpendometerManager.instance.enabled && value == "1")
               {
                  result = true;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_SUBSCRIBER:
               isSubscriber = SubscriptionsManager.instance.isSubscriber();
               result = value == "1" ? isSubscriber : !isSubscriber;
               break;
            case PrerequisiteConstants.PREREQUISITE_EX_SUBSCRIBER:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               isExSubscriber = SubscriptionsManager.instance.isExsubscriber();
               cancelledBefore = parseInt(value);
               if(isExSubscriber && cancelledBefore > 0)
               {
                  isExSubscriber &&= SubscriptionsManager.instance.isCancelledRecently(cancelledBefore);
               }
               result = getComparisonValueBoolean(isExSubscriber,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_MASTERY_CLEANED:
               isMasteryCleaned = Global.player.masterySignCleaned;
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = getComparisonValueBoolean(isMasteryCleaned,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_SUB_REVAMP_EXSUBSCRIBER:
               result = false;
               isExSub = SubscriptionsManager.instance.isExsubscriber();
               cancelled = parseInt(value);
               heighestStreak = SubscriptionsManager.instance.getHeighestStreak();
               if(isExSub && heighestStreak > 2)
               {
                  if(cancelled > 0 && !SubscriptionsManager.instance.isCancelledRecently(cancelled) || cancelled == 0)
                  {
                     result = true;
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_REVAMP_2019_ACTIVE:
               subscriptionStatusActive = Global.player.subscriptionStatus;
               if(subscriptionStatusActive != null && subscriptionStatusActive == SubscriptionsManager.SUBSCRIPTION_ACTIVE)
               {
                  featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_CODE);
                  if(featureData)
                  {
                     reactivationVersionFlag = "subs_react_version_2";
                     if(!featureData.hasOwnProperty(reactivationVersionFlag) || int(featureData[reactivationVersionFlag]) != 1)
                     {
                        result = true;
                     }
                     else
                     {
                        result = false;
                     }
                  }
                  else
                  {
                     result = false;
                  }
               }
               else
               {
                  result = false;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_REVAMP_2019_CANCELED:
               subscriptionStatusCancel = Global.player.subscriptionStatus;
               if(subscriptionStatusCancel != null && subscriptionStatusCancel == SubscriptionsManager.SUBSCRIPTION_CANCELED)
               {
                  result = true;
               }
               else
               {
                  result = false;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_SUBSCRIBER_STATUS:
               isSubscribed = SubscriptionsMainWindow.isSubscriber();
               if(isSubscribed)
               {
                  subscriptionStatus = Global.player.subscriptionStatus;
                  result = Boolean(subscriptionStatus) && subscriptionStatus != "" && subscriptionStatus >= value;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_SUBSCRIBER_STREAK:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               streak = SubscriptionsManager.instance.getSubscriptionStreak();
               result = getComparisonValue(streak,Number(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_CHECK_ITEM_LIMIT:
               limitedItem = Global.farmGameSettingsManager.getFarmItemByCode(value);
               result = !limitedItem.checkItemLimit();
               break;
            case PrerequisiteConstants.PREREQUISITE_NOT_IN_GIFT_BOX:
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(value);
               count = 0;
               if(farmItem)
               {
                  count = Global.player.getGiftCountForItem(farmItem.name);
               }
               else
               {
                  ErrorManager.addError("not_in_gift_box could not get farm item for itemCode: " + value);
               }
               result = count == 0;
               break;
            case PrerequisiteConstants.PREREQUISITE_COMPARE:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               context = getContextValue(params,context);
               try
               {
                  result = compare(context,value,op);
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Error performing context comparison " + "[context=" + context + ", value=" + value + ", op=" + op + ", error=" + err.message + "]");
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_COMPARE_ALL_AND:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               j = 0;
               params.context = params.context.split(PrerequisiteConstants.PREREQUISITE_COMPARE_ALL_AND).join(i);
               contextValue = getContextValue(params,context);
               try
               {
                  result = compare(context,value,op);
                  while(Boolean(contextValue) && result)
                  {
                     result &&= compare(contextValue,value,op);
                     params.context = params.context.split(j).join(++j);
                     contextValue = getContextValue(params,context);
                  }
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Error performing context comparison " + "[context=" + context + ", value=" + value + ", op=" + op + ", error=" + err.message + "]");
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_QUEST_COMPLETE:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = FarmQuestManager.getInstance().isQuestComplete(value);
               result = getComparisonValueBoolean(result,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_QUEST_EXPIRED_PURCHASE:
               result = false;
               break;
            case PrerequisiteConstants.PREREQUISITE_QUEST_ACTIVE:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = FarmQuestManager.getInstance().isQuestActive(value);
               result = getComparisonValueBoolean(result,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_FEATURE_LAST_SHOWN:
               time = parseInt(params[PrerequisiteConstants.KEY_TIME]);
               lastShown = Global.player.getFeatureLastShown(value);
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN);
               result = getComparisonValue(lastShown,time,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_FEATURE_FREQUENCY:
               interval = parseInt(params[PrerequisiteConstants.KEY_INTERVAL]);
               lastShown = Global.player.getFeatureLastShown(value);
               currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeSinceLastSeen = lastShown == 0 ? 0 : int(currentTime - lastShown);
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN);
               result = getComparisonValue(timeSinceLastSeen,interval,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_ACTION_COUNT:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               userCount = Global.player.getActionCount(value);
               if(Boolean(params[PrerequisiteConstants.KEY_COUNT]) && params[PrerequisiteConstants.KEY_COUNT].indexOf(",") == -1)
               {
                  specifiedCount = parseInt(params[PrerequisiteConstants.KEY_COUNT]);
                  result = getComparisonValue(userCount,specifiedCount,op);
               }
               else
               {
                  specifiedRange = params[PrerequisiteConstants.KEY_COUNT];
                  result = getComparisonValueString(userCount.toString(),specifiedRange,op);
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_IS_VISITING:
               shouldBeVisiting = value === "true";
               result = shouldBeVisiting == Global.worldManager.isVisiting();
               break;
            case PrerequisiteConstants.PREREQUISITE_GLOBAL_LIMIT:
               limitedItems = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_LIMITED_ITEMS,FeatureOptionsManager.FEATURE_LIMITED_ITEMS);
               limitedItemName = params[PrerequisiteConstants.KEY_VALUE];
               giftBoxItems = Global.player.getGiftCountForItem(limitedItemName);
               if(limitedItems == null || !limitedItems.hasOwnProperty(limitedItemName) || limitedItems.limitedItemName <= 0 && giftBoxItems <= 0)
               {
                  result = true;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_CAN_UNLOCK_NEXT_SEASON:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               location = params[PrerequisiteConstants.KEY_VALUE];
               canUnlockNextSeason = WorldSeasonsManager.getInstance().canUserUnlockNextSeason(location);
               result = getComparisonValueBoolean(canUnlockNextSeason,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_PURCHASE_SUPER_PLOT_LIMIT:
               result = SuperPlotManager.canPurchase(parseFloat(value));
               break;
            case PrerequisiteConstants.PREREQUISITE_FEATURE_OPTION:
               result = PrerequisiteUtility.isPrerequisiteMet_FeatureOption(params,value,context);
               break;
            case PrerequisiteConstants.PREREQUISITE_GEOIP:
               location = params[PrerequisiteConstants.KEY_VALUE];
               result = Global.geoIpManager.isUserInArea(location);
               break;
            case PrerequisiteConstants.PREREQUISITE_UGC_DECORATION_COMPLETED:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               result = getComparisonValueBoolean(UGCDecoManager.instance.prerequisiteMet(value),true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_BUILDING_EXPANSION_LEVEL:
               expansionLevel = 1;
               if(context)
               {
                  if(context is StorageBuilding)
                  {
                     op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
                     expansionLevel = (context as StorageBuilding).storageLevel;
                     result = getComparisonValue(expansionLevel,Number(value),op);
                  }
                  else if(context is MapResource)
                  {
                     result = false;
                     buildingItem = (context as MapResource).getItem();
                     expansionLevel = StorageBuilding.getInitialExpansionLevelFromItem(buildingItem);
                     op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
                     result = getComparisonValue(expansionLevel,Number(value),op);
                  }
                  else
                  {
                     result = false;
                     ErrorManager.addError("Prereq " + PrerequisiteConstants.PREREQUISITE_BUILDING_EXPANSION_LEVEL + " requires context to be a StorageBuilding or MapResource if coming from the giftbox");
                  }
               }
               else
               {
                  result = false;
                  ErrorManager.addError("Prereq " + PrerequisiteConstants.PREREQUISITE_BUILDING_EXPANSION_LEVEL + " requires a context");
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_TIME_SINCE_LAST_LOGIN:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               timeSinceLastLogin = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.lastLoginDayTimestamp;
               result = getComparisonValue(timeSinceLastLogin,Number(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_CAN_REPEAT_COUNTDOWN:
               result = HolidayCountdownManager.canRestartCountdown();
               break;
            case PrerequisiteConstants.PREREQUISITE_IS_REPEATING_COUNTDOWN:
               result = HolidayCountdownManager.isRepeatingCountdown();
               break;
            case PrerequisiteConstants.PREREQUISITE_HAS_MASTERY:
               masteryItem = Global.farmGameSettingsManager.getFarmItemByName(value);
               level = parseInt(params[PrerequisiteConstants.KEY_MASTERY_LEVEL]);
               if(Boolean(masteryItem) && Boolean(level))
               {
                  if(Global.player.mastery.hasOwnProperty(masteryItem.code))
                  {
                     result = getComparisonValue(Global.player.mastery[masteryItem.code],level,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISISTE_NO_MISSING_REQUIREMENTS:
               item = Global.farmGameSettingsManager.getFarmItemByName(value);
               result = item.allMissingRequirements.length == 0;
               break;
            case PrerequisiteConstants.PREREQUISITE_CONTEST_TIER_FINISHED:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN);
               if(ItemContestManager.inMainExperiment() && ItemContestManager.isInstanciated())
               {
                  contestManager = ItemContestManager.getInstance();
                  if(contestManager.isContestInitialized(params[PrerequisiteConstants.KEY_CONTEST_NAME]))
                  {
                     result = getComparisonValue(contestManager.convertBackendTierToFrontendTier(Number(params[PrerequisiteConstants.KEY_TARGET])),contestManager.getPrizeLevel(value,params[PrerequisiteConstants.KEY_CONTEST_NAME]),op);
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_GROWABLE_CONTEST_FINISHED:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               required = Number(value);
               contestId = params.contestId;
               growableContest = GrowableContestManager.instance.getContest(contestId);
               completed = 0;
               if(growableContest)
               {
                  completed = growableContest.numCompletions;
               }
               result = getComparisonValue(completed,required,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_SIGNED_UP_FOR_FB_EVENT:
               result = false;
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               rsvpStatus = Global.player.hasJoinedFbEvent(value);
               if(op == PrerequisiteConstants.PREREQ_OP_EQUALS)
               {
                  result = rsvpStatus;
               }
               else if(op == PrerequisiteConstants.PREREQ_OP_NOT_EQUALS)
               {
                  result = !rsvpStatus;
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_LAST_EXPANSION_ACCESS:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS);
               daysSinceLastExpansionAccess = Global.worldManager.getDaysSinceLastExpansionAccess();
               result = getComparisonValue(daysSinceLastExpansionAccess,Number(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_DAY_OF_WEEK:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               currentDayOfWeek = new Date(GlobalEngine.serverTime).day;
               result = getComparisonValue(currentDayOfWeek,FarmGameUtil.getNumericDayFromStringDay(value),op);
               break;
            case PrerequisiteConstants.PREREQUISITE_IS_MYSTERY_CRATE_PLACEABLE:
               isMysteryCratePlaceable = canPlaceMysteryCrate();
               result = getComparisonValueBoolean(isMysteryCratePlaceable,Boolean(value),PrerequisiteConstants.PREREQ_OP_EQUALS);
               break;
            case PrerequisiteConstants.PREREQUISITE_IS_FEATURE_MESSAGING_INITIALIZED:
               op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
               isInitialized = FeatureMessagingManager.getInstance().isFeatureInitialized(value);
               result = getComparisonValueBoolean(isInitialized,true,op);
               break;
            case PrerequisiteConstants.PREREQUISITE_DAYS_SINCE_INITIAL_PLANT_TIME:
               if(context != null && context is FeatureBuilding)
               {
                  op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
                  initialPlantTime = (context as FeatureBuilding).getInitialPlantTime();
                  if(initialPlantTime > 0)
                  {
                     daysSinceInit = (GlobalEngine.serverTime - initialPlantTime * 1000) / FarmGameUtil.NUM_MSECS_IN_DAY;
                     result = getComparisonValue(daysSinceInit,Number(value),op);
                  }
               }
               break;
            case PrerequisiteConstants.PREREQUISITE_COMMUNITY_GOALS_TASK_ACTIVE:
               isActive = CommunityGoalsManager.getInstance().shouldTaskBeShown();
               result = isActive;
               break;
            case PrerequisiteConstants.PREREQUISITE_DOLLAR_BUNDLE_TASK_ACTIVE:
               isActive = DollarBundlesManager.getInstance().shouldTaskBeShown();
               result = isActive;
               break;
            case PrerequisiteConstants.PREREQUISITE_WEEKEND_DELIGHT_TASK:
               isActiveforTheDay = WeekendDelightManager.getInstance().shouldTaskBeShown();
               result = isActiveforTheDay;
               break;
            case PrerequisiteConstants.PREREQUISITE_UNLIMITED_PACK:
               isPackAvailable = UnlimitedPacksManager.getInstance().isUnlimitedPackAvailable();
               result = value == "1" ? isPackAvailable : !isPackAvailable;
               break;
            case PrerequisiteConstants.PREREQUISITE_FEATURE_OPTION_LIMIT:
               result = !FeatureOptionsInventoryManager.getInstance().limitReachedForItem(value);
               break;
            case PrerequisiteConstants.PREREQUISITE_MINIDARTS_GAME_ACTIVE:
               result = MiniDartsManager.getInstance(MiniDartsManager.FEATURE_NAME).isFeatureActive();
               break;
            default:
               functionName = PREREQ_FUNCTION_PREFIX + prerequisiteType;
               functionName = functionName.split("_").join("");
               myclass = getDefinitionByName("Classes.Quest.PrerequisiteUtility") as Class;
               if((myclass as Object).hasOwnProperty(functionName))
               {
                  result = Boolean(myclass[functionName](value,params));
               }
               else
               {
                  ErrorManager.addError("PrerequisiteUtility could not find function :" + functionName);
               }
         }
         return result;
      }
      
      private static function isPrerequisiteMet_FeatureOption(params:Object, value:String, context:Object = null) : Boolean
      {
         var option:Object = null;
         var op:String = null;
         var valueType:String = null;
         var len:int = 0;
         var subNameIndex:int = 0;
         var result:Boolean = false;
         var featureName:String = params[PrerequisiteConstants.KEY_FEATURE_NAME] as String;
         var optionNames:Array = (params[PrerequisiteConstants.KEY_OPTION_NAME] as String).split(".");
         if(Boolean(optionNames) && optionNames.length > 0)
         {
            option = FeatureOptionsManager.getInstance().getFeatureOption(featureName,optionNames[0]);
            if(option)
            {
               len = int(optionNames.length);
               for(subNameIndex = 1; subNameIndex < len; subNameIndex++)
               {
                  if(!option[optionNames[subNameIndex]])
                  {
                     option = null;
                     break;
                  }
                  option = option[optionNames[subNameIndex]];
               }
            }
            op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
            valueType = params[PrerequisiteConstants.KEY_VALUE_TYPE] as String;
            if(valueType)
            {
               if(valueType == PrerequisiteConstants.VALUE_TYPE_STRING)
               {
                  result = getComparisonValueString(String(option),value,op);
               }
               else if(valueType == PrerequisiteConstants.VALUE_TYPE_INT)
               {
                  result = getComparisonValue(int(option),int(value),op);
               }
               else if(valueType == PrerequisiteConstants.VALUE_TYPE_FLOAT)
               {
                  result = getComparisonValue(Number(option),Number(value),op);
               }
               else if(valueType == PrerequisiteConstants.VALUE_TYPE_BOOL)
               {
                  result = getComparisonValueBoolean(Boolean(option),value == PrerequisiteConstants.STRING_TRUE,op);
               }
               else
               {
                  ErrorManager.addError("prereq of " + PrerequisiteConstants.KEY_TYPE + "=" + PrerequisiteConstants.PREREQUISITE_FEATURE_OPTION + " " + PrerequisiteConstants.KEY_FEATURE_NAME + "=" + featureName + " " + PrerequisiteConstants.KEY_OPTION_NAME + "=" + (params[PrerequisiteConstants.KEY_OPTION_NAME] as String) + " does not have required " + PrerequisiteConstants.KEY_VALUE_TYPE + "=");
               }
            }
         }
         return result;
      }
      
      private static function canPlaceMysteryCrate() : Boolean
      {
         var timePlaced:int = 0;
         var startDate:String = null;
         var startDateInDays:int = 0;
         var result:Boolean = false;
         var timePlacedFeatureOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.MYSTERY_CRATE,FeatureOptionsManager.MYSTERY_CRATE_PLACED_TIME);
         if(timePlacedFeatureOption != null)
         {
            if(timePlacedFeatureOption is Number)
            {
               timePlaced = (timePlacedFeatureOption as int) / FarmGameUtil.NUM_SECS_IN_DAY;
               try
               {
                  startDate = Global.flashHotParams["MYSTERY_CRATE_START_DATE"];
                  startDateInDays = FarmGameUtil.synchronizedDateToNumber(startDate) / FarmGameUtil.NUM_MSECS_IN_DAY;
                  if(timePlaced < startDateInDays)
                  {
                     result = true;
                  }
               }
               catch(error:Error)
               {
                  ErrorManager.addError("canPlaceMysteryCrate error date error");
               }
            }
            else
            {
               ErrorManager.addError("Mystery Crate feature option is not an int, with value: " + timePlacedFeatureOption);
            }
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      private static function handleGroupLogic(params:Object, context:Object = null) : Boolean
      {
         var reqIndex:int = 0;
         var reqObject:Object = null;
         var result:Boolean = false;
         var prerequisiteType:String = params[PrerequisiteConstants.KEY_TYPE];
         var requirementsArray:Array = params[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         if(requirementsArray)
         {
            for(reqIndex = 0; reqIndex < requirementsArray.length; reqIndex++)
            {
               reqObject = requirementsArray[reqIndex];
               reqObject = mergePrereqObject(reqObject,params);
               result = isPrerequisiteMet(reqObject,context);
               if(!result && prerequisiteType == PrerequisiteConstants.PREREQUISITE_AND_GROUP)
               {
                  break;
               }
               if(result && prerequisiteType == PrerequisiteConstants.PREREQUISITE_OR_GROUP)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getContextValue(params:Object, context:Object) : *
      {
         var pathStr:String = null;
         var path:Array = null;
         var leg:uint = 0;
         var length:uint = 0;
         var value:* = null;
         leg = 0;
         length = 0;
         try
         {
            if(context != null)
            {
               pathStr = params[PrerequisiteConstants.KEY_CONTEXT_PATH];
               if(pathStr != null)
               {
                  path = pathStr.split(".");
                  leg = 0;
                  length = path.length;
                  while(Boolean(leg < length) && Boolean(context) && context.hasOwnProperty(path[leg]))
                  {
                     context = context[path[leg++]];
                  }
                  if(leg == length && context != null)
                  {
                     if(context is Function)
                     {
                        value = (context as Function).call();
                     }
                     else
                     {
                        value = context;
                     }
                  }
               }
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error in getContextValue [" + "context=" + context + ", " + "pathStr=" + pathStr + ", " + "path=" + path + ", " + "leg=" + leg + ", " + "length=" + length + ", " + "error=" + err.message + "]");
         }
         return value;
      }
      
      private static function compare(test:*, value:*, op:String) : Boolean
      {
         var testNum:Number = NaN;
         var testNumStr:String = null;
         var testStr:String = null;
         var result:Boolean = false;
         if(test === true || test === false)
         {
            if(value is String)
            {
               if(value == "false")
               {
                  value = false;
               }
               else if(value == "true")
               {
                  value = true;
               }
            }
            result = getComparisonValueBoolean(test,value,op);
         }
         else if(!isNaN(Number(value)))
         {
            testNum = NaN;
            if(test is int || test is Number)
            {
               testNum = test;
            }
            else if(test is String)
            {
               testNumStr = test as String;
               if(testNumStr != null)
               {
                  try
                  {
                     if(testNumStr.indexOf(".") >= 0)
                     {
                        testNum = parseFloat(test);
                     }
                     else
                     {
                        testNum = parseInt(test);
                     }
                  }
                  catch(err:Error)
                  {
                  }
               }
            }
            if(isNaN(testNum))
            {
               ErrorManager.addError("Invalid test value for number comparison: " + test);
            }
            else
            {
               result = getComparisonValue(testNum,value,op);
            }
         }
         else if(value is String)
         {
            testStr = test as String;
            if(testStr == null && test != null)
            {
               testStr = String(test);
            }
            result = getComparisonValueString(testStr,value,op);
         }
         else
         {
            ErrorManager.addError("Comparison type not supported: " + typeof value);
         }
         return result;
      }
      
      private static function getComparisonOp(params:Object, defaultOp:String) : String
      {
         var desiredOp:String = params[PrerequisiteConstants.KEY_OP];
         var returnOp:String = desiredOp;
         if(Boolean(desiredOp) && defaultOp == PrerequisiteConstants.PREREQ_OP_NOT_SUPPORTED)
         {
            returnOp = defaultOp;
         }
         else if(!desiredOp)
         {
            returnOp = defaultOp;
         }
         return returnOp;
      }
      
      private static function resolveFinalParamValue(params:Object, valueOverrides:Object = null) : String
      {
         var value:String = params[PrerequisiteConstants.KEY_VALUE] ? params[PrerequisiteConstants.KEY_VALUE] : null;
         if(valueOverrides.length != 0 && Boolean(valueOverrides[params[PrerequisiteConstants.KEY_TYPE]]))
         {
            value = valueOverrides[params[PrerequisiteConstants.KEY_TYPE]];
         }
         return value;
      }
      
      private static function getComparisonValue(testValue:Number, targetValue:Number, compareOp:String) : Boolean
      {
         var regEx:RegExp = null;
         var result:Boolean = false;
         switch(compareOp)
         {
            case PrerequisiteConstants.PREREQ_OP_EQUALS:
               result = testValue == targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_NOT_EQUALS:
               result = testValue != targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS:
               result = testValue >= targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_LESS_THAN_EQUALS:
               result = testValue <= targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_LESS_THAN:
               result = testValue < targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_GREATER_THAN:
               result = testValue > targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_CONTAINS:
               result = testValue.toString().search(targetValue.toString()) != -1;
               break;
            case PrerequisiteConstants.PREREQ_OP_REGEX_MATCH:
               regEx = new RegExp(targetValue.toString());
               result = regEx.test(testValue.toString());
         }
         return result;
      }
      
      private static function getComparisonValueBoolean(testValue:Boolean, targetValue:Boolean, compareOp:String) : Boolean
      {
         var result:Boolean = false;
         switch(compareOp)
         {
            case PrerequisiteConstants.PREREQ_OP_EQUALS:
               result = testValue == targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_NOT_EQUALS:
               result = testValue != targetValue;
         }
         return result;
      }
      
      private static function getComparisonValueString(testValue:String, targetValue:String, compareOp:String) : Boolean
      {
         var testValueInt:Number = NaN;
         var regEx:RegExp = null;
         var targetValues:Array = null;
         var firstTargetValue:Number = NaN;
         var secondTargetValue:Number = NaN;
         var result:Boolean = false;
         switch(compareOp)
         {
            case PrerequisiteConstants.PREREQ_OP_EQUALS:
               result = testValue == targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_NOT_EQUALS:
               result = testValue != targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_GREATER_THAN_EQUALS:
               result = testValue >= targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_LESS_THAN_EQUALS:
               result = testValue <= targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_LESS_THAN:
               result = testValue < targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_GREATER_THAN:
               result = testValue > targetValue;
               break;
            case PrerequisiteConstants.PREREQ_OP_BETWEEN:
               testValueInt = parseInt(testValue);
               if(!isNaN(testValueInt))
               {
                  targetValues = targetValue.split(",");
                  firstTargetValue = parseInt(targetValues[0]);
                  secondTargetValue = parseInt(targetValues[1]);
                  if(targetValues.length == 2 && !isNaN(firstTargetValue) && !isNaN(secondTargetValue))
                  {
                     if(firstTargetValue < secondTargetValue)
                     {
                        result = testValueInt >= firstTargetValue && testValueInt <= secondTargetValue;
                     }
                     else
                     {
                        result = testValueInt >= secondTargetValue && testValueInt <= firstTargetValue;
                     }
                  }
                  else
                  {
                     ErrorManager.addError("Prerequisite operation type \'" + compareOp + "\' requires 2 target values (ex. \'1,2\'). Given: \'" + targetValue + "\'");
                  }
               }
               else
               {
                  ErrorManager.addError("Prerequisite operation type \'" + compareOp + "\' requires a test value to be numeric. Given: \'" + testValue + "\'");
               }
               break;
            case PrerequisiteConstants.PREREQ_OP_CONTAINS:
               result = testValue.search(targetValue) != -1;
               break;
            case PrerequisiteConstants.PREREQ_OP_REGEX_MATCH:
               regEx = new RegExp(targetValue);
               result = regEx.test(testValue);
         }
         return result;
      }
      
      public static function checkRuntimeVar(value:String, params:Object) : Boolean
      {
         var op:String = null;
         var result:Boolean = false;
         var runtimeFlag:String = value.split(FLASH_RUNTIME_PREFIX).join("");
         value = null;
         if(params["op"])
         {
            op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
            value = resolveFinalParamValue(params,Global.flashHotParams);
            result = value != null && getComparisonValueString(value,"true",op);
         }
         else if(Global.flashHotParams.hasOwnProperty(runtimeFlag))
         {
            if(Global.flashHotParams[runtimeFlag] == true)
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function checkHasCraftingCottage(craftType:String, params:Object) : Boolean
      {
         var result:Boolean = false;
         if(craftType == "none")
         {
            if(CraftingManager.getInstance().getPlacedCraftingCottages().length == 0)
            {
               result = true;
            }
         }
         else if(!craftType || craftType.length == 0)
         {
            if(CraftingManager.getInstance().getPlacedCraftingCottages().length > 0)
            {
               result = true;
            }
         }
         else if(CraftingManager.getInstance().getCottageByCraft(craftType))
         {
            result = true;
         }
         return result;
      }
      
      public static function checkDaysInactive(dayStr:String, params:Object) : Boolean
      {
         var op:String = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN);
         var days:int = parseInt(dayStr);
         return getComparisonValue(Global.player.daysInactive,days,op);
      }
      
      public static function checkInitDialogsOk(value:String, params:Object) : Boolean
      {
         return PostInitSettings.suppressDialogs == PostInitSettings.DIALOG_SUPPRESS_NONE;
      }
      
      public static function checkHasEmailPermission(value:String, params:Object) : Boolean
      {
         var hasEmailPerms:Boolean = GlobalEngine.socialNetwork.userHasEmailPermission();
         var op:String = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
         return getComparisonValueBoolean(hasEmailPerms,FarmGameUtil.strToBool(value),op);
      }
      
      public static function checkMaxCCEmailInactiveDays(value:String, params:Object) : Boolean
      {
         var op:String = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_GREATER_THAN);
         var lastSendTS:Number = Global.player.getFeatureLastShown(EmailCampaignWindow.EMAIL_PERMANENT_LAST_SEND);
         var lastRecievedTs:Number = Global.player.getFeatureLastShown(EmailCampaignWindow.EMAIL_LAST_RECEIVED_KEY);
         var delta:int = lastSendTS - lastRecievedTs;
         var threshold:int = 24 * 60 * 60 * parseInt(value);
         return getComparisonValue(delta,threshold,op);
      }
      
      public static function checkReactivating(value:String, params:Object) : Boolean
      {
         var op:String = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
         return getComparisonValueBoolean(Global.player.reactivating,FarmGameUtil.strToBool(value),op);
      }
      
      public static function checkcurrencylogcount(value:String, params:Object) : Boolean
      {
         var transactionLogCount:int = 0;
         var postDateTransactions:Array = null;
         var transaction:Object = null;
         var result:Boolean = true;
         var op:String = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_EQUALS);
         var quantity:int = params.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY) ? int(params[PrerequisiteConstants.KEY_QUANTITY]) : 0;
         var acceptDate:Number = 0;
         if(params.hasOwnProperty(PrerequisiteConstants.KEY_TIME_INTERVAL))
         {
            acceptDate = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - params[PrerequisiteConstants.KEY_TIME_INTERVAL];
         }
         else if(params.hasOwnProperty(PrerequisiteConstants.KEY_TIME))
         {
            ErrorManager.addError("time param not supported on the frontend in prerequisite type currency_log_count. Please use timeInterval instead!");
            result = false;
         }
         if(result == true)
         {
            transactionLogCount = 0;
            postDateTransactions = Global.player.getCashTransactionsFromDate(acceptDate);
            if(value == "")
            {
               transactionLogCount = int(postDateTransactions.length);
            }
            else
            {
               for each(transaction in postDateTransactions)
               {
                  if(transaction.hasOwnProperty(value) && transaction[value] > 0)
                  {
                     transactionLogCount++;
                  }
               }
            }
            result = getComparisonValue(transactionLogCount,quantity,op);
         }
         return result;
      }
      
      public static function checkCanPopHolidayCountdown(value:String, params:Object) : Boolean
      {
         return HolidayCountdownManager.shouldAutoPop();
      }
      
      public static function checkbuildinglevel(value:String, params:Object) : Boolean
      {
         var objectsInWorld:Array = null;
         var highestBuildingLevel:int = 0;
         var obj:MapResource = null;
         var op:String = null;
         var storageBuilding:StorageBuilding = null;
         var buildingItem:FarmItem = null;
         var expansionLevel:int = 0;
         var result:Boolean = false;
         var target:String = params.hasOwnProperty(PrerequisiteConstants.KEY_TARGET) ? params[PrerequisiteConstants.KEY_TARGET] : "";
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(target);
         if(itemCode)
         {
            objectsInWorld = Global.world.getObjectsByCode(itemCode);
            highestBuildingLevel = 0;
            for each(obj in objectsInWorld)
            {
               storageBuilding = obj as StorageBuilding;
               if(storageBuilding)
               {
                  if(storageBuilding.storageLevel > highestBuildingLevel)
                  {
                     highestBuildingLevel = storageBuilding.storageLevel;
                  }
               }
               else
               {
                  buildingItem = obj.getItem();
                  expansionLevel = StorageBuilding.getInitialExpansionLevelFromItem(buildingItem);
                  if(expansionLevel > highestBuildingLevel)
                  {
                     highestBuildingLevel = expansionLevel;
                  }
               }
            }
            op = getComparisonOp(params,PrerequisiteConstants.PREREQ_OP_LESS_THAN_EQUALS);
            result = getComparisonValue(parseInt(value),highestBuildingLevel,op);
         }
         return result;
      }
      
      public static function getPrerequisiteFailureDescription(prereqName:String) : String
      {
         var result:String = null;
         if(prereqName)
         {
            result = ZLocUtils.t("FarmVille",PrerequisiteConstants.PREREQ_FAILURE_DESCRIPTION_PREFIX + prereqName);
         }
         return result;
      }
      
      public static function getPrerequisiteNotMet(prereqs:Array, returnMultiPrereqs:Boolean = false) : Array
      {
         var prereqLength:int = 0;
         var idx:int = 0;
         var preReqNotMet:Array = new Array();
         if(prereqs)
         {
            prereqLength = int(prereqs.length);
            for(idx = 0; idx < prereqLength; idx++)
            {
               if(!isPrerequisiteMet(prereqs[idx]))
               {
                  preReqNotMet.push(prereqs[idx]);
                  if(!returnMultiPrereqs)
                  {
                     break;
                  }
               }
            }
         }
         return preReqNotMet;
      }
   }
}

