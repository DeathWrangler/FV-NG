package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.LoyaltyProgramGoldenFarmerWindow;
   import Widgets.Windows.LoyaltyProgramToasterWindow;
   import flash.utils.setTimeout;
   
   public class LoyaltyProgramManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "loyaltyProgram";
      
      private static const CAP_DEFINITIONS:String = "capDefinitions";
      
      private static const CAP_DEFINITION:String = "capDefinition";
      
      private static const CAP_VALUE:String = "capValue";
      
      private static const TASK:String = "task";
      
      private static const GOLDEN_FARMER_DEF:String = "goldenFarmer";
      
      private static const POINTS:String = "points";
      
      private static const CURRENT_MONTH:String = "currentMonth";
      
      private static const POINTS_FOR_MONTH:String = "pointsForMonth";
      
      private static const GOLD_FARMER:String = "goldFarmer";
      
      private static const IS_GOLD_FARMER:String = "isGoldFarmer";
      
      private static const IS_NOTIFIED:String = "isNotified";
      
      private static const EXPIRATION_DATE:String = "expirationDate";
      
      private static const CAPS:String = "caps";
      
      private static const CURRENT_TIME:String = "currentTime";
      
      private static const TOASTER_DELAY:Number = 15000;
      
      private static const GOLDEN_FARMER_COST:int = 200;
      
      private static const MAX_STATUS_POINTS:Number = 100000;
      
      private static const MONTH_ARRAY:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
      
      private var m_isToasterBeingDelayed:Boolean = false;
      
      private var m_statusPointsGainedSinceLastToaster:int = 0;
      
      public function LoyaltyProgramManager(featureName:String = "loyaltyProgram")
      {
         var featureConfig:XML = getLoyaltyProgramXML();
         super(featureName,featureConfig);
      }
      
      public static function getLoyaltyProgramXML() : XML
      {
         var result:XML = null;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         if(Boolean(xml.loyaltyProgram) && Boolean(xml.loyaltyProgram.children()))
         {
            result = xml.loyaltyProgram[0];
         }
         return result;
      }
      
      public static function getInstance(featureName:String = "loyaltyProgram") : LoyaltyProgramManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,LoyaltyProgramManager) as LoyaltyProgramManager;
      }
      
      public static function initialize() : void
      {
         if(getInstance().userPassesPrereq())
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,LoyaltyProgramManager.onTransactionAdded);
         }
      }
      
      public static function onTransactionAdded(event:TransactionEvent) : void
      {
         getInstance().checkForStatusPointUpdates(event);
      }
      
      private static function getEndOfNextMonthTime() : Number
      {
         var dateObj:Date = getEndOfNextMonthDate();
         var dateString:String = dateObj.month + 1 + "/" + dateObj.date + "/" + dateObj.fullYear;
         return FarmGameUtil.synchronizedDateToNumber(dateString) / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public static function getEndOfThisMonthTime() : Number
      {
         var todaysDate:Date = new Date(GlobalEngine.serverTime);
         var endOfMonth:Date = new Date(todaysDate.fullYear,todaysDate.month + 1,0);
         var dateString:String = endOfMonth.month + 1 + "/" + endOfMonth.date + "/" + endOfMonth.fullYear;
         return FarmGameUtil.synchronizedDateToNumber(dateString) / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      private static function getEndOfNextMonthDate() : Date
      {
         var todaysDate:Date = new Date(GlobalEngine.serverTime);
         var month:Number = todaysDate.month;
         var year:Number = todaysDate.fullYear;
         if(month === 11)
         {
            month = 1;
            year++;
         }
         else
         {
            month += 2;
         }
         return new Date(year,month,0);
      }
      
      public static function endOfNextMonthReadableDate() : String
      {
         var endOfNextMonthDate:Date = getEndOfNextMonthDate();
         var thisMonth:String = MONTH_ARRAY[endOfNextMonthDate.month];
         return thisMonth + " " + endOfNextMonthDate.fullYear.toString();
      }
      
      public static function endOfMonthAfterCurrentMonth() : String
      {
         var endOfNextMonthDate:Date = getEndOfNextMonthDate();
         var currentMonth:int = endOfNextMonthDate.month + 1;
         if(currentMonth == 11)
         {
            currentMonth = 0;
         }
         var thisMonth:String = MONTH_ARRAY[currentMonth];
         return thisMonth + " " + endOfNextMonthDate.fullYear.toString();
      }
      
      public static function startOfMonthAfterCurrentMonth() : String
      {
         var endOfNextMonthDate:Date = getEndOfNextMonthDate();
         var currentMonth:int = endOfNextMonthDate.month + 1;
         if(currentMonth == 11)
         {
            currentMonth = 0;
         }
         var thisMonth:String = MONTH_ARRAY[currentMonth];
         return thisMonth + " 1";
      }
      
      private static function getTodaysYMD() : String
      {
         var todaysDate:Date = new Date(GlobalEngine.serverTime);
         var day:String = todaysDate.date.toString();
         var month:String = (todaysDate.month + 1).toString();
         var year:String = todaysDate.fullYear.toString();
         return year + month + day;
      }
      
      private static function getTodaysYM() : String
      {
         var todaysDate:Date = new Date(GlobalEngine.serverTime);
         var month:String = (todaysDate.month + 1).toString();
         var year:String = todaysDate.fullYear.toString();
         return year + month;
      }
      
      public static function redeemStatusPoints() : void
      {
         UI.displayMarketDialog("loyaltyManager","loyaltyItem");
      }
      
      private function checkForStatusPointUpdates(event:TransactionEvent) : void
      {
         var maxStatusPoints:Number = NaN;
         var capDefinitions:XMLList = null;
         var isUnderCap:Boolean = false;
         var capValue:int = 0;
         var statusPointsToAward:int = 0;
         var farmTask:FarmTask = null;
         var transaction:TFarmTransaction = null;
         var capDefinition:XML = null;
         var capCheckFunction:String = null;
         var farmTaskXML:XML = null;
         if(m_featureConfig)
         {
            maxStatusPoints = Number(m_featureConfig["statusPoints"].@maxPoints);
            if(!maxStatusPoints)
            {
               maxStatusPoints = MAX_STATUS_POINTS;
            }
            if(Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS) < maxStatusPoints)
            {
               capDefinitions = m_featureConfig[CAP_DEFINITIONS];
               if(capDefinitions[CAP_DEFINITION])
               {
                  isUnderCap = true;
                  capValue = 0;
                  statusPointsToAward = 0;
                  for each(capDefinition in capDefinitions[CAP_DEFINITION])
                  {
                     capCheckFunction = capDefinition.@capCheckFunction;
                     if(Boolean(capCheckFunction) && this.hasOwnProperty(capCheckFunction))
                     {
                        if(capDefinition[CAP_VALUE])
                        {
                           capValue = int(capDefinition.@capValue);
                        }
                        isUnderCap = Boolean(this[capCheckFunction](capValue));
                     }
                     if(isUnderCap)
                     {
                        transaction = event.transaction as TFarmTransaction;
                        if(capDefinition[TASK])
                        {
                           for each(farmTaskXML in capDefinition[TASK])
                           {
                              farmTask = new FarmTask(FarmGameUtil.xmlNodeToAttributes(farmTaskXML));
                              statusPointsToAward = int(farmTaskXML.@statusPointsReward);
                              this.awardStatusPointsIfTaskProgresses(farmTask,transaction,capValue,statusPointsToAward);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function awardStatusPointsIfTaskProgresses(farmTask:FarmTask, transaction:TFarmTransaction, capValue:int, statusPointsToAward:int) : void
      {
         var taskProgress:Number = FarmQuestUtility.getInstance().getProgression(farmTask,transaction,null);
         if(taskProgress > 0)
         {
            this.awardStatusPointsForTask(farmTask,taskProgress,capValue,statusPointsToAward);
         }
      }
      
      private function awardStatusPointsForTask(farmTask:FarmTask, taskProgress:Number, capValue:int, statusPointsToAward:int) : void
      {
         var currentCapCount:int = 0;
         var potentialAward:int = 0;
         var maxStatusPoints:Number = NaN;
         var potentialTotal:Number = NaN;
         var success:Boolean = false;
         var actionName:String = farmTask.action;
         var amountToAward:int = 0;
         switch(actionName)
         {
            case QuestConstants.TASK_HARVEST_BY_TYPE:
               currentCapCount = this.getTodaysHarvestCapCountForCurrentWorld();
               potentialAward = taskProgress + currentCapCount;
               if(capValue > 0 && potentialAward >= capValue)
               {
                  amountToAward = capValue - currentCapCount;
               }
               else
               {
                  amountToAward = taskProgress;
               }
               break;
            case QuestConstants.TASK_MASTER_BY_TYPE:
            case QuestConstants.TASK_MAKE_RECIPE_ANY:
            case QuestConstants.TASK_BUY_ITEM_WITH_CASH:
               amountToAward = statusPointsToAward ? statusPointsToAward : int(taskProgress);
         }
         if(amountToAward > 0)
         {
            maxStatusPoints = Number(m_featureConfig["statusPoints"].@maxPoints);
            if(!maxStatusPoints)
            {
               maxStatusPoints = MAX_STATUS_POINTS;
            }
            potentialTotal = Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS) + amountToAward;
            if(potentialTotal > maxStatusPoints)
            {
               amountToAward = maxStatusPoints - Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS);
            }
            success = Global.player.updateWorldCurrency(Currency.COST_STATUS_POINTS,amountToAward);
            if(success)
            {
               this.incrementOrResetStatusPointsForThisMonth(amountToAward);
               this.incrementOrResetCapCountForAction(actionName,amountToAward);
               this.conditionallyAwardGoldenFarmerStatus();
               this.m_statusPointsGainedSinceLastToaster += amountToAward;
               if(!this.m_isToasterBeingDelayed)
               {
                  this.m_isToasterBeingDelayed = true;
                  setTimeout(this.displayStatusPointsNotification,TOASTER_DELAY);
               }
            }
            else
            {
               StatsManager.count("LoyaltyProgramManager_FE","errors","failed_to_add_statuspoints",amountToAward.toString());
            }
         }
      }
      
      private function displayStatusPointsNotification() : void
      {
         ToasterManager.getInstance().add(new LoyaltyProgramToasterWindow(this.m_statusPointsGainedSinceLastToaster.toString()));
         this.m_statusPointsGainedSinceLastToaster = 0;
         this.m_isToasterBeingDelayed = false;
      }
      
      public function goldenFarmerCost() : int
      {
         var cost:int = 0;
         if(m_featureConfig[GOLDEN_FARMER_DEF])
         {
            cost = int(m_featureConfig[GOLDEN_FARMER_DEF].@cashValue);
         }
         if(!cost)
         {
            cost = GOLDEN_FARMER_COST;
         }
         return cost;
      }
      
      public function buyGoldenFarmerStatus() : void
      {
         var cost:int = this.goldenFarmerCost();
         if(Global.player.canBuyCash(cost))
         {
            Global.player.cash -= cost;
            this.awardGoldenFarmerStatus();
            TransactionManager.addTransaction(new TGenericTransaction("LoyaltyProgramService","buyGoldenFarmerStatus"));
         }
      }
      
      private function conditionallyAwardGoldenFarmerStatus() : void
      {
         var pointsThisMonth:Number = this.getPointsForTheMonth();
         if(pointsThisMonth >= this.goldenFarmerThreshold())
         {
            this.awardGoldenFarmerStatus();
         }
      }
      
      public function goldenFarmerThreshold() : Number
      {
         return this.isGoldenFarmer() && Boolean(m_featureConfig[GOLDEN_FARMER_DEF]) ? Number(m_featureConfig[GOLDEN_FARMER_DEF].@goldenValue) : Number(m_featureConfig[GOLDEN_FARMER_DEF].@defaultValue);
      }
      
      public function getPointsForTheMonth() : Number
      {
         var points:Number = 0;
         var featureOptionsData:Object = getFeatureOptionData();
         var currentMonth:Number = Number(getTodaysYM());
         if(currentMonth <= featureOptionsData[POINTS][CURRENT_MONTH])
         {
            points = Number(featureOptionsData[POINTS][POINTS_FOR_MONTH]);
         }
         return points;
      }
      
      private function awardGoldenFarmerStatus() : void
      {
         var featureOptionsData:Object = getFeatureOptionData();
         var expiration:Number = getEndOfNextMonthTime();
         if(expiration != featureOptionsData[GOLD_FARMER][EXPIRATION_DATE])
         {
            featureOptionsData[GOLD_FARMER][IS_GOLD_FARMER] = true;
            featureOptionsData[GOLD_FARMER][IS_NOTIFIED] = true;
            featureOptionsData[GOLD_FARMER][EXPIRATION_DATE] = expiration;
            setFeatureData(featureOptionsData);
            UI.displayPopup(new LoyaltyProgramGoldenFarmerWindow());
         }
      }
      
      public function goldenFarmerExpirationReadableDate() : String
      {
         var featureOptionsData:Object = getFeatureOptionData();
         var expirationNumber:Number = Number(featureOptionsData[GOLD_FARMER][EXPIRATION_DATE]);
         var expirationDate:Date = new Date(expirationNumber * 1000);
         var month:String = MONTH_ARRAY[expirationDate.month];
         return month + " " + expirationDate.fullYear.toString();
      }
      
      public function isGoldenFarmer() : Boolean
      {
         var isGoldenFarmer:Boolean = false;
         var featureOptionsData:Object = getFeatureOptionData();
         var thisMonth:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(featureOptionsData[GOLD_FARMER][EXPIRATION_DATE] != 0 && thisMonth <= Number(featureOptionsData[GOLD_FARMER][EXPIRATION_DATE]))
         {
            isGoldenFarmer = Boolean(featureOptionsData[GOLD_FARMER][IS_GOLD_FARMER]);
         }
         return isGoldenFarmer;
      }
      
      public function shouldNotifyGoldenFarmer() : Boolean
      {
         var shouldNotify:Boolean = false;
         var featureOptionsData:Object = getFeatureOptionData();
         if(featureOptionsData[GOLD_FARMER][IS_NOTIFIED])
         {
            shouldNotify = !featureOptionsData[GOLD_FARMER][IS_NOTIFIED] && this.isGoldenFarmer();
         }
         return shouldNotify;
      }
      
      private function incrementOrResetStatusPointsForThisMonth(amountToAward:int) : void
      {
         var featureOptionsData:Object = getFeatureOptionData();
         var currentMonth:String = getTodaysYM();
         if(currentMonth === featureOptionsData[POINTS][CURRENT_MONTH])
         {
            if(featureOptionsData[POINTS][POINTS_FOR_MONTH])
            {
               featureOptionsData[POINTS][POINTS_FOR_MONTH] += amountToAward;
            }
            else
            {
               featureOptionsData[POINTS][POINTS_FOR_MONTH] = amountToAward;
            }
         }
         else
         {
            featureOptionsData[POINTS][CURRENT_MONTH] = currentMonth;
            featureOptionsData[POINTS][POINTS_FOR_MONTH] = amountToAward;
         }
         setFeatureData(featureOptionsData);
      }
      
      private function incrementOrResetCapCountForAction(actionName:String, progression:int) : void
      {
         var capLimitKey:String = null;
         var featureOptionsData:Object = null;
         var currentTime:String = null;
         switch(actionName)
         {
            case QuestConstants.TASK_HARVEST_BY_TYPE:
               capLimitKey = "harvest" + Global.worldManager.currentWorldType;
               featureOptionsData = getFeatureOptionData();
               currentTime = getTodaysYMD();
               if(currentTime === featureOptionsData[CAPS][CURRENT_TIME])
               {
                  if(featureOptionsData[CAPS].hasOwnProperty(capLimitKey))
                  {
                     featureOptionsData[CAPS][capLimitKey] += progression;
                  }
                  else
                  {
                     featureOptionsData[CAPS][capLimitKey] = progression;
                  }
               }
               else
               {
                  featureOptionsData[CAPS][CURRENT_TIME] = currentTime;
                  featureOptionsData[CAPS][capLimitKey] = progression;
               }
               setFeatureData(featureOptionsData);
         }
      }
      
      private function getTodaysHarvestCapCountForCurrentWorld() : int
      {
         var capLimitKey:String = "harvest" + Global.worldManager.currentWorldType;
         return this.getTodaysCapCountForKey(capLimitKey);
      }
      
      private function getTodaysCapCountForKey(key:String) : int
      {
         var currentTime:String = null;
         var result:int = 0;
         var featureOptionData:Object = getFeatureOptionData();
         if(featureOptionData.hasOwnProperty("caps") && Boolean(featureOptionData.caps.hasOwnProperty("currentTime")))
         {
            currentTime = getTodaysYMD();
            if(currentTime === featureOptionData.caps.currentTime)
            {
               result = featureOptionData.caps.hasOwnProperty(key) ? int(featureOptionData["caps"][key]) : 0;
            }
         }
         return result;
      }
      
      override protected function getNewFeatureOptionData() : Object
      {
         return {
            "points":{
               "currentMonth":getTodaysYM(),
               "pointsForMonth":0
            },
            "goldFarmer":{
               "isGoldFarmer":false,
               "isNotified":false,
               "expirationDate":0
            },
            "caps":{"currentTime":getTodaysYMD()}
         };
      }
      
      public function userPassesPrereq() : Boolean
      {
         var prereqs:Array = null;
         var result:Boolean = false;
         if(m_featureConfig)
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(m_featureConfig.prereqs.children());
            result = PrerequisiteUtility.arePrerequisitesMet(prereqs);
         }
         return result;
      }
      
      public function getGoldenFarmerStatusText() : String
      {
         return this.isGoldenFarmer() ? ZLocUtils.t("Dialogs","GoldenFarmer_active") : ZLocUtils.t("Dialogs","GoldenFarmer_inactive");
      }
      
      public function getGoldenFarmerStatusTooltipText() : String
      {
         var month:String = null;
         var activeText:String = "";
         if(this.isGoldenFarmer())
         {
            activeText = ZLocUtils.t("Dialogs","GoldenFarmer_active_tooltip");
         }
         else
         {
            month = endOfNextMonthReadableDate();
            activeText = ZLocUtils.t("Dialogs","GoldenFarmer_inactive_tooltip",{"month":month});
         }
         return activeText;
      }
      
      public function isUnderHarvestLimit(capValue:int) : Boolean
      {
         var result:Boolean = true;
         var currentCount:int = this.getTodaysHarvestCapCountForCurrentWorld();
         if(currentCount >= capValue)
         {
            result = false;
         }
         return result;
      }
   }
}

