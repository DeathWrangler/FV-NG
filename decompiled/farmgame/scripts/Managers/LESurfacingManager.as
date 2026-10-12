package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Widgets.Windows.LESet.LERecommendationToasterWindow;
   import Widgets.Windows.LESet.LESurfacingToasterWindow;
   import Widgets.Windows.LESet.LESurfacingWindow;
   import Widgets.Windows.ToasterWindow;
   
   public class LESurfacingManager
   {
      
      private static const m_instance:LESurfacingManager = new LESurfacingManager(SingletonLock);
      
      public static const FEATURE_NAME:String = "LESurfacing";
      
      private static const RUNTIME_VARIABLE_KEY:String = "LE_SURFACING";
      
      private static const HUD_ICON_NAME:String = "LESurfacing";
      
      public static const HUD_ICON_ACTION_KEY:String = "LESurfacingUI";
      
      public static const TOASTER_TYPE_RECOMMENDATION:String = "recommendation";
      
      public static const TOASTER_TYPE_LESET:String = "leSet";
      
      private static const LE_SURFACING_LASTIMPRESSION_FLAG:String = "LESurfacingLatest";
      
      public static const LE_SURFACING_INTERACTION_FLAG:String = "LESurfacingInteraction";
      
      public static const LE_SURFACING_DISMISS_FLAG:String = "LESurfacingDismissFlag";
      
      private static const LE_SURFACING_THROTTLE:String = "LESurfacingThrottle";
      
      private static const HUD_ICON_INTRO_URL:String = "assets/hud/LE/FV_LESurfacingHUD.swf";
      
      private static const ITEM_TYPES:Array = ["animal","building","decoration","tree"];
      
      public static const MAX_NUMBER_SLOTS:int = 4;
      
      public static const PURCHASED_ITEM_TYPE_OF_PURCHASE_INDEX:int = 0;
      
      public static const PURCHASED_ITEM_NAME_INDEX:int = 1;
      
      public static const PURCHASED_ITEM_COST_INDEX:int = 2;
      
      public static const PURCHASED_ITEM_NUMBER_PURCHASED_INDEX:int = 3;
      
      public static const PURCHASED_ITEM_TIMESTAMP_INDEX:int = 4;
      
      public static const PURCHASED_ITEM_TYPE_BUY:String = "buy";
      
      private static const THROTTLE_HOURS:int = 12;
      
      private static const MAX_LE_DAYS_DURATION:int = 16;
      
      private static const MIN_LE_DAYS_DURATION:int = 12;
      
      private static const MAX_NUM_OF_LE_TO_DISPLAY:int = 15;
      
      private static const MIN_LE_TO_COUNT_AS_SET:int = 5;
      
      public static const EXPIRING_DAYS:int = 3;
      
      public static const NEW_DAYS:int = 3;
      
      private var m_limitedEditionItems:Object;
      
      private var m_playerPreferences:Array;
      
      private var m_v2Variant:int = -1;
      
      private var m_leForCharityVariant:int = 0;
      
      private var m_leSetsByOrder:Array = null;
      
      private var m_hasBeenShown:Boolean = false;
      
      private var m_LEWindowItems:Array = null;
      
      private var m_LESurfacingWindow:LESurfacingWindow = null;
      
      private var m_inLELastChanceExperimentControl:Boolean;
      
      public function LESurfacingManager(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid LESurfacingManager Singleton access. Use LESurfacingManager.instance");
         }
         this.m_inLELastChanceExperimentControl = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING;
         this.m_leForCharityVariant = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_LE_FOR_CHARITY);
      }
      
      public static function get instance() : LESurfacingManager
      {
         return m_instance;
      }
      
      private static function orderDates(inputDate1:String, inputDate2:String) : int
      {
         var date1:Date = new Date(inputDate1);
         var date2:Date = new Date(inputDate2);
         if(date1 < date2)
         {
            return 1;
         }
         if(date1 > date2)
         {
            return -1;
         }
         return 0;
      }
      
      public function show(featureName:String = null) : void
      {
         if(!this.m_hasBeenShown && this.m_inLELastChanceExperimentControl)
         {
            this.m_hasBeenShown = true;
            this.filterLESet();
            this.cashItemsPurchasedRecently();
            this.showUI(featureName);
            this.showHUD();
         }
      }
      
      public function hasBeenShown() : Boolean
      {
         return this.m_hasBeenShown;
      }
      
      public function init(canShowUI:Boolean = true) : void
      {
         var prereq:Object = null;
         var shouldShow:Boolean = false;
         var newLESet:Boolean = false;
         var recentlyPurchased:Array = null;
         var latestLEDate:String = null;
         var latestLETimestamp:Number = NaN;
         var lastClick:Number = NaN;
         var lastHudImpression:Number = NaN;
         var lastDissmisal:Number = NaN;
         if(!this.m_hasBeenShown)
         {
            this.m_hasBeenShown = true;
            prereq = Global.farmGameSettingsManager.getPrereqByName("LESurfacing");
            if(PrerequisiteUtility.isPrerequisiteMet(prereq))
            {
               this.filterLESet();
               shouldShow = true;
               newLESet = false;
               recentlyPurchased = this.cashItemsPurchasedRecently();
               if(Global.flashHotParams[RUNTIME_VARIABLE_KEY] != null && Boolean(Global.flashHotParams[RUNTIME_VARIABLE_KEY]))
               {
                  latestLEDate = this.getLatestStartDate();
                  latestLETimestamp = FarmGameUtil.synchronizedDateToNumber(latestLEDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  lastClick = Global.player.getFeatureLastShown(LESurfacingManager.LE_SURFACING_INTERACTION_FLAG);
                  if(latestLETimestamp > lastClick)
                  {
                     newLESet = true;
                  }
                  else
                  {
                     lastHudImpression = Global.player.getFeatureLastShown(LESurfacingManager.LE_SURFACING_LASTIMPRESSION_FLAG);
                     lastDissmisal = Global.player.getFeatureLastShown(LESurfacingManager.LE_SURFACING_DISMISS_FLAG);
                     if(lastHudImpression < lastDissmisal)
                     {
                        shouldShow = false;
                     }
                  }
               }
               else
               {
                  shouldShow = false;
               }
               if(shouldShow && this.m_inLELastChanceExperimentControl)
               {
                  if(recentlyPurchased.length > 0 && newLESet && canShowUI)
                  {
                     this.showUI();
                     this.showHUD();
                  }
                  else
                  {
                     this.showHUD();
                  }
               }
            }
         }
      }
      
      public function numberOfItemPurchases(itemName:String) : int
      {
         var purchase:Object = null;
         var result:int = 0;
         for each(purchase in Global.player.purchaseHistory)
         {
            if(purchase[LESurfacingManager.PURCHASED_ITEM_NAME_INDEX] == itemName)
            {
               result += purchase[LESurfacingManager.PURCHASED_ITEM_NUMBER_PURCHASED_INDEX];
            }
         }
         return result;
      }
      
      public function cashItemsPurchasedRecently(days:int = 30) : Array
      {
         var purchase:Object = null;
         var timeDiff:Number = NaN;
         var farmItem:FarmItem = null;
         var newEntry:Boolean = false;
         var obj:Object = null;
         var result:Array = new Array();
         this.m_playerPreferences = new Array();
         var interval:Number = FarmGameUtil.NUM_SECS_IN_DAY * days;
         for each(purchase in Global.player.purchaseHistory)
         {
            if(purchase != null && purchase[LESurfacingManager.PURCHASED_ITEM_TIMESTAMP_INDEX] != null)
            {
               timeDiff = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - purchase[LESurfacingManager.PURCHASED_ITEM_TIMESTAMP_INDEX];
               if(timeDiff <= interval)
               {
                  result.push(purchase);
               }
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(purchase[LESurfacingManager.PURCHASED_ITEM_NAME_INDEX]);
               if(farmItem != null && LESurfacingManager.ITEM_TYPES.indexOf(farmItem.type) >= 0)
               {
                  newEntry = true;
                  for each(obj in this.m_playerPreferences)
                  {
                     if(obj.type == farmItem.type)
                     {
                        obj.quantity += 1;
                        newEntry = false;
                        break;
                     }
                  }
                  if(newEntry)
                  {
                     this.m_playerPreferences.push({
                        "type":farmItem.type,
                        "quantity":1
                     });
                  }
               }
            }
         }
         return result;
      }
      
      public function get LEWindowItems() : Array
      {
         return this.m_LEWindowItems;
      }
      
      public function setLEWindowItems() : void
      {
         var leSet:Array = null;
         var charityItemToBeShown:FarmItem = null;
         if(this.m_LEWindowItems == null)
         {
            leSet = this.filterLESet();
            if(leSet != null)
            {
               this.m_LEWindowItems = this.sortLeSet(leSet);
               if(this.m_leForCharityVariant == Experiments.LE_FOR_CHARITY_ON && this.m_LEWindowItems.length > 0)
               {
                  charityItemToBeShown = this.getCharityItemToBeShown();
                  try
                  {
                     if(charityItemToBeShown != null)
                     {
                        this.m_LEWindowItems.unshift(charityItemToBeShown);
                        if(this.m_LEWindowItems.length == this.getNumLeItemLimit())
                        {
                           this.m_LEWindowItems.pop();
                        }
                     }
                  }
                  catch(e:Error)
                  {
                     FarmGameUtil.reportClientLog("Adding charity item to le items failed - LeSurfacingManager.setLeWindowItems : " + e.message);
                  }
               }
            }
         }
      }
      
      private function showHUD() : void
      {
         Global.player.setFeatureLastShown(LESurfacingManager.LE_SURFACING_LASTIMPRESSION_FLAG,GlobalEngine.serverTime,true);
         FarmStatsManager.count("le_display_promo","hud_icon","le_display_" + LESurfacingManager.MAX_NUMBER_SLOTS,"view");
         this.setLEWindowItems();
         Global.hud.rightSideIconQueue.addIcon(HUD_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
      }
      
      public function showOnHud(leSurfacingType:String = "leSet") : void
      {
         var toasterWindow:ToasterWindow = null;
         if(this.m_LEWindowItems != null && !Global.ui.leSurfacingToaster && !ToasterManager.getInstance().isQueuePaused())
         {
            switch(leSurfacingType)
            {
               case TOASTER_TYPE_RECOMMENDATION:
                  toasterWindow = new LERecommendationToasterWindow();
                  break;
               case TOASTER_TYPE_LESET:
                  toasterWindow = new LESurfacingToasterWindow(this.m_LEWindowItems);
            }
            Global.ui.leSurfacingToaster = toasterWindow;
            HudWidgetManager.instance.add(toasterWindow);
         }
      }
      
      public function conditionallyShowOnHud() : void
      {
         var toasterWindow:ToasterWindow = null;
         var shownCount:int = 0;
         var variant:int = 0;
         var counterName:String = null;
         if(!ToasterManager.getInstance().isQueuePaused())
         {
            if(this.m_LEWindowItems != null)
            {
               if(!Global.ui.leSurfacingToaster)
               {
                  shownCount = 0;
                  variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_RECOMMENDATION_TOASTER);
                  switch(variant)
                  {
                     case 0:
                     case 1:
                     case 2:
                        toasterWindow = new LESurfacingToasterWindow(this.m_LEWindowItems);
                        break;
                     case 3:
                     case 4:
                        toasterWindow = new LERecommendationToasterWindow();
                        break;
                     case 6:
                     case 8:
                        shownCount = 1;
                     case 5:
                     case 7:
                        counterName = "LESurfacingManager_shownToaster";
                        shownCount += Global.player.getActionCount(counterName);
                        if(shownCount % 2 == 0)
                        {
                           toasterWindow = new LESurfacingToasterWindow(this.m_LEWindowItems);
                        }
                        else
                        {
                           toasterWindow = new LERecommendationToasterWindow();
                        }
                        Global.player.incrementActionCount(counterName,true);
                  }
                  Global.ui.leSurfacingToaster = toasterWindow;
               }
               HudWidgetManager.instance.add(Global.ui.leSurfacingToaster);
            }
            else
            {
               ErrorManager.addError("LEWindowItems is null");
            }
         }
      }
      
      public function showUI(featureName:String = null) : void
      {
         Global.player.setFeatureLastShown(LESurfacingManager.LE_SURFACING_INTERACTION_FLAG,GlobalEngine.serverTime,true);
         Global.hud.rightSideIconQueue.removeIconByName(HUD_ICON_NAME);
         this.setLEWindowItems();
         if(this.m_LEWindowItems != null)
         {
            if(this.m_inLELastChanceExperimentControl)
            {
               this.m_LESurfacingWindow = new LESurfacingWindow(this.m_LEWindowItems,featureName);
               UI.displayPopup(this.m_LESurfacingWindow,false,"LESurfacing");
            }
         }
      }
      
      public function onCloseMarketDialog() : void
      {
         if(this.m_LESurfacingWindow)
         {
            this.m_LESurfacingWindow.close();
            this.m_LESurfacingWindow = null;
         }
      }
      
      private function defaultLeItemSort(leSet:Array) : Array
      {
         var type:String = null;
         var prefCopy:Array = null;
         var totalPreferredItems:Number = NaN;
         var obj:Object = null;
         var currentIndex:int = 0;
         var i:int = 0;
         var typePresent:Boolean = false;
         var object:Object = null;
         var j:int = 0;
         var itemsToShow:int = 0;
         var k:int = 0;
         var result:Array = new Array();
         leSet.sortOn(["type"]);
         for each(type in LESurfacingManager.ITEM_TYPES)
         {
            typePresent = false;
            for each(object in this.m_playerPreferences)
            {
               if(object.type == type)
               {
                  typePresent = true;
                  break;
               }
            }
            if(!typePresent)
            {
               this.m_playerPreferences.push({
                  "quantity":0,
                  "type":type
               });
            }
         }
         this.m_playerPreferences.sortOn(["quantity"],Array.DESCENDING);
         prefCopy = this.m_playerPreferences;
         totalPreferredItems = 0;
         for each(obj in prefCopy)
         {
            totalPreferredItems += obj.quantity;
            obj.items = this.filterByType(leSet,{"type":obj.type});
         }
         currentIndex = 0;
         i = 0;
         while(i < leSet.length)
         {
            j = 0;
            while(j < LESurfacingManager.MAX_NUMBER_SLOTS && i < leSet.length)
            {
               currentIndex = 0;
               for(currentIndex = 0; currentIndex < prefCopy.length; currentIndex++)
               {
                  itemsToShow = Math.min(prefCopy[currentIndex].items.length,Math.ceil((prefCopy[currentIndex].items.length as Number) / totalPreferredItems * LESurfacingManager.MAX_NUMBER_SLOTS));
                  k = 0;
                  while(k < itemsToShow && k < prefCopy[currentIndex].items.length && j < LESurfacingManager.MAX_NUMBER_SLOTS)
                  {
                     result.push((prefCopy[currentIndex].items as Array).pop());
                     k++;
                     i++;
                     j++;
                  }
               }
            }
         }
         return result;
      }
      
      private function filterByType(array:Array, obj:Object) : Array
      {
         var filterFunction:Function = function(element:*, index:int, arr:Array):Boolean
         {
            return element.type == this.type;
         };
         return array.filter(filterFunction,obj);
      }
      
      private function filterLESet() : Array
      {
         var isMarket3:Boolean = false;
         var items:Array = null;
         var i:int = 0;
         var farmItem:FarmItem = null;
         var limitedStart:Number = NaN;
         var timeDiff:Number = NaN;
         var leDays:Number = NaN;
         var limitedEnd:Number = NaN;
         var saleDuration:Number = NaN;
         var dayDiff:Number = NaN;
         var leSet:Array = new Array();
         var itemsByDate:Object = new Object();
         if(this.m_limitedEditionItems == null)
         {
            isMarket3 = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_3_LIMITED_TAB) == 2;
            items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_LIMITED,FarmGameSettingsManager.ALL,FarmGameSettingsManager.ALL,FarmGameSettingsManager.REQUIRED_LEVEL,FarmGameSettingsManager.DESCENDING,true,"",null,isMarket3);
            this.m_limitedEditionItems = new Object();
            this.m_leSetsByOrder = [];
            for(i = 0; i < items.length; i++)
            {
               farmItem = items[i];
               if(this.isUsingV2() == false || farmItem.cash <= 50)
               {
                  if(this.isUsingV2() == false || farmItem.saleCash == farmItem.cash)
                  {
                     if(farmItem.isWithinLimitedStartDate() && farmItem.isWithinLimitedEndDate() && farmItem.isLimitedItem() && farmItem.isCash && !farmItem.isCharityItem() && LESurfacingManager.ITEM_TYPES.indexOf(farmItem.type) >= 0)
                     {
                        limitedStart = FarmGameUtil.synchronizedDateToNumber(farmItem.getLimitedStartDate());
                        timeDiff = (GlobalEngine.serverTime / 1000 - limitedStart / 1000) / 3600;
                        leDays = Math.round(timeDiff / 24);
                        if(farmItem.getLimitedStartDate() != null && farmItem.getLimitedEndDate() != null)
                        {
                           limitedEnd = FarmGameUtil.synchronizedDateToNumber(farmItem.getLimitedEndDate());
                           saleDuration = (limitedEnd - limitedStart) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                           dayDiff = Math.round(saleDuration / FarmGameUtil.NUM_SECS_IN_DAY);
                           if(dayDiff >= MIN_LE_DAYS_DURATION && dayDiff <= MAX_LE_DAYS_DURATION)
                           {
                              if(this.m_limitedEditionItems.hasOwnProperty(farmItem.getLimitedStartDate()) == false)
                              {
                                 this.m_limitedEditionItems[farmItem.getLimitedStartDate()] = new Array(farmItem);
                                 this.m_leSetsByOrder.push(farmItem.getLimitedStartDate());
                              }
                              else
                              {
                                 (this.m_limitedEditionItems[farmItem.getLimitedStartDate()] as Array).push(farmItem);
                              }
                           }
                        }
                     }
                  }
               }
            }
            this.m_leSetsByOrder.sort(orderDates);
         }
         return this.getLeSet();
      }
      
      public function getLeSet() : Array
      {
         var maxLeItems:int = 0;
         var leSetLength:int = 0;
         var letSet:Array = null;
         var currentNumOfItemsToDisplay:int = 0;
         var i:int = 0;
         var numItemsToMerge:int = 0;
         var latestStartDate:String = null;
         var result:Array = null;
         if(this.isUsingV2())
         {
            maxLeItems = this.getNumLeItemLimit();
            leSetLength = int(this.m_leSetsByOrder.length);
            letSet = null;
            currentNumOfItemsToDisplay = 0;
            for(i = 0; i < leSetLength; i++)
            {
               letSet = this.m_limitedEditionItems[this.m_leSetsByOrder[i]];
               if(letSet.length >= this.getMinLeToCountAsSet())
               {
                  if(result == null)
                  {
                     result = [];
                  }
                  currentNumOfItemsToDisplay = int(result.length);
                  if(currentNumOfItemsToDisplay + letSet.length <= maxLeItems)
                  {
                     result = result.concat(letSet);
                  }
                  else
                  {
                     numItemsToMerge = maxLeItems - currentNumOfItemsToDisplay;
                     result = result.concat(letSet.slice(0,numItemsToMerge));
                  }
                  if(result.length > maxLeItems)
                  {
                     break;
                  }
               }
            }
         }
         else
         {
            latestStartDate = this.getLatestStartDate();
            result = this.m_limitedEditionItems[latestStartDate];
         }
         return result;
      }
      
      private function getCharityItemToBeShown() : FarmItem
      {
         var charityItemsRuntime:String = null;
         var charityItemName:String = null;
         var charityItem:FarmItem = null;
         var charityItemsArray:Array = null;
         var result:FarmItem = null;
         try
         {
            if(Global.flashHotParams["LE_MOTD_CHARITY_ITEMS"] != null)
            {
               charityItemsRuntime = Global.flashHotParams["LE_MOTD_CHARITY_ITEMS"];
               charityItemsArray = charityItemsRuntime.split(",");
               if(charityItemsArray.length > 0)
               {
                  charityItemName = charityItemsArray[charityItemsArray.length - 1];
                  charityItem = Global.farmGameSettingsManager.getFarmItemByName(charityItemName);
                  if(Boolean(charityItem) && this.canCharityItemBeShown(charityItem))
                  {
                     result = charityItem;
                  }
               }
            }
         }
         catch(e:Error)
         {
            FarmGameUtil.reportClientLog("Getting charity item from runtime failed - LeSurfacingManager.getCharityItemToBeShown : " + e.message);
            result = null;
         }
         return result;
      }
      
      private function canCharityItemBeShown(charityItem:FarmItem) : Boolean
      {
         var result:Boolean = false;
         if(charityItem.isCharityItem() && charityItem.hasLimitedStart() && charityItem.hasLimitedStartEnd())
         {
            if(charityItem.isWithinLimitedEndDate() && charityItem.isWithinLimitedStartDate())
            {
               result = true;
            }
         }
         return result;
      }
      
      private function getLatestStartDate() : String
      {
         var result:String = null;
         var key:String = null;
         for(key in this.m_limitedEditionItems)
         {
            if(result == null || key > result)
            {
               result = key;
            }
         }
         return result;
      }
      
      public function getLatestLESet() : Array
      {
         var startDate:String = null;
         var result:Array = [];
         if(this.m_limitedEditionItems)
         {
            startDate = this.getLatestStartDate();
            if(Boolean(startDate) && this.m_limitedEditionItems.hasOwnProperty(startDate))
            {
               result = this.m_limitedEditionItems[startDate];
            }
         }
         return result;
      }
      
      private function isUsingV2() : Boolean
      {
         var result:Boolean = false;
         if(this.m_v2Variant < 0)
         {
            this.m_v2Variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_SURFACING_V2);
         }
         if(this.m_v2Variant > 1)
         {
            result = true;
         }
         return true;
      }
      
      private function sortLeSet(items:Array) : Array
      {
         var result:Array = items;
         switch(this.m_v2Variant)
         {
            case 2:
            case 5:
               result = this.defaultLeItemSort(items);
               break;
            case 3:
            case 6:
               result = items.sort(Global.farmGameSettingsManager.getItemSortFunction(FarmGameSettingsManager.PRICE));
               break;
            case 4:
            case 7:
               items.sort(Global.farmGameSettingsManager.getItemSortFunction(FarmGameSettingsManager.PRICE));
               result = items.reverse();
         }
         return result;
      }
      
      private function getNumLeItemLimit() : int
      {
         return MAX_NUM_OF_LE_TO_DISPLAY;
      }
      
      private function getMinLeToCountAsSet() : int
      {
         return MIN_LE_TO_COUNT_AS_SET;
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
