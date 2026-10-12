package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.SpendometerReopenIdleTask;
   import Classes.ZItem.FarmItem;
   import Display.QueuedIcons.SpendometerQueuedIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.Spendometer.SpendometerWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SpendometerManager extends EventDispatcher
   {
      
      private static var m_instance:SpendometerManager;
      
      public static const SHOW_SPENDOMETER_DIALOG:String = "SHOW_SPENDOMETER_DIALOG";
      
      public static const REWARD_STATE_INCOMPLETE:int = 0;
      
      public static const REWARD_STATE_READY:int = 1;
      
      public static const REWARD_STATE_COLLECTED:int = 2;
      
      public static const FEATURE_OPTIONS_KEY:String = "spendometer";
      
      public static const KEY_REWARDS:String = "rewards";
      
      public static const KEY_REWARD_THRESHOLD:String = "threshold";
      
      public static const KEY_REWARD_STATE:String = "state";
      
      public static const KEY_SPEND_COUNT:String = "count";
      
      public static const KEY_LAST_SPEND_SHOWN_COUNT:String = "lastShownCount";
      
      public static const KEY_START_TS:String = "startTS";
      
      public static const KEY_END_TS:String = "endTS";
      
      public static const KEY_OFFBOARD_TS:String = "offboardTS";
      
      private var m_isEnabled:Boolean;
      
      private var m_currentRevision:String;
      
      private var m_currentCashCount:int;
      
      public function SpendometerManager()
      {
         super();
         this.m_isEnabled = false;
         this.m_currentRevision = "blank";
         this.m_currentCashCount = 0;
      }
      
      public static function get instance() : SpendometerManager
      {
         if(m_instance == null)
         {
            m_instance = new SpendometerManager();
         }
         return m_instance;
      }
      
      public static function inExperiment() : Boolean
      {
         var result:Boolean = false;
         var variant:int = getVariant();
         if(variant == 2 || variant == 3 || variant == 4)
         {
            result = true;
         }
         return result;
      }
      
      public static function inSurfacingExperiment() : Boolean
      {
         var result:Boolean = false;
         var variant:int = getVariant();
         if(variant == 3 || variant == 4)
         {
            result = true;
         }
         return result;
      }
      
      public static function inHiddenExperiemnt() : Boolean
      {
         var result:Boolean = false;
         var variant:int = getVariant();
         if(variant == 2)
         {
            result = true;
         }
         return result;
      }
      
      private static function getVariant() : int
      {
         return Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_SPENDOMETER);
      }
      
      private static function displayMainUI(eve:Event) : void
      {
         var source:String = "undef";
         if(Boolean(eve.hasOwnProperty("data")) && Boolean(eve["data"]) && Boolean(eve["data"].hasOwnProperty("source")) && Boolean(eve["data"]["source"]))
         {
            source = eve["data"]["source"];
         }
         SpendometerWindow.display(null,source);
      }
      
      public function init(isEnabled:Boolean, revision:String = "blank") : void
      {
         var currentFeatureOptionsData:Object = null;
         this.enabled = isEnabled;
         this.currentRevision = revision;
         this.m_currentCashCount = Global.player.cash;
         if(this.enabled)
         {
            if(SpendometerManager.inSurfacingExperiment())
            {
               currentFeatureOptionsData = this.featureData;
               if(Boolean(currentFeatureOptionsData) && currentFeatureOptionsData.hasOwnProperty(this.currentRevision))
               {
                  this.actualInit();
               }
               else
               {
                  TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,function(eve:TransactionEvent):void
                  {
                     TransactionManager.getInstance().removeEventListener(TransactionEvent.COMPLETED,arguments.callee);
                     actualInit();
                  });
               }
            }
         }
      }
      
      public function actualInit() : void
      {
         if(this.shouldShowUI())
         {
            SpendometerQueuedIcon.showHUDIcon();
            this.addEventListener(SHOW_SPENDOMETER_DIALOG,displayMainUI);
         }
      }
      
      public function shouldShowUI() : Boolean
      {
         var result:Boolean = false;
         var rewardCodes:Array = this.getRewardItemsCode();
         for(var i:int = 0; i < rewardCodes.length; i++)
         {
            if(this.getRewardItemState(rewardCodes[i]) != REWARD_STATE_COLLECTED)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get featureData() : Object
      {
         var result:Object = null;
         if(this.enabled)
         {
            result = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY);
         }
         return result;
      }
      
      public function set featureData(data:Object) : void
      {
         if(this.enabled)
         {
            FeatureOptionsManager.getInstance().setFeature(FEATURE_OPTIONS_KEY,data);
         }
      }
      
      public function get count() : int
      {
         var result:int = 0;
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_SPEND_COUNT)))
         {
            result = int(data[this.currentRevision][KEY_SPEND_COUNT]);
         }
         return result;
      }
      
      public function set count(currentCount:int) : void
      {
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_SPEND_COUNT)))
         {
            data[this.currentRevision][KEY_SPEND_COUNT] = currentCount;
            this.featureData = data;
         }
      }
      
      public function get lastShownCount() : int
      {
         var result:int = 0;
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_LAST_SPEND_SHOWN_COUNT)))
         {
            result = int(data[this.currentRevision][KEY_LAST_SPEND_SHOWN_COUNT]);
         }
         return result;
      }
      
      public function set lastShownCount(newCount:int) : void
      {
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_SPEND_COUNT)))
         {
            data[this.currentRevision][KEY_LAST_SPEND_SHOWN_COUNT] = newCount;
            this.featureData = data;
         }
      }
      
      public function get rewards() : Object
      {
         var result:Object = null;
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_REWARDS)))
         {
            result = data[this.currentRevision][KEY_REWARDS];
         }
         return result;
      }
      
      public function set rewards(rewardsObj:Object) : void
      {
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_REWARDS)))
         {
            data[this.currentRevision][KEY_REWARDS] = rewardsObj;
            this.featureData = data;
         }
      }
      
      public function getRewardItemsCode() : Array
      {
         var rewardItemCode:String = null;
         var result:Array = new Array();
         var rewardsData:Object = this.rewards;
         for(rewardItemCode in rewardsData)
         {
            result.push(rewardItemCode);
         }
         return result;
      }
      
      private function getRewardItemData(itemCode:String) : Object
      {
         var result:Object = null;
         var rewardsData:Object = this.rewards;
         if(this.rewards.hasOwnProperty(itemCode))
         {
            result = this.rewards[itemCode];
         }
         return result;
      }
      
      private function setRewardItemData(itemCode:String, newData:Object) : void
      {
         var rewardsData:Object = this.rewards;
         if(rewardsData.hasOwnProperty(itemCode))
         {
            rewardsData[itemCode] = newData;
            this.rewards = rewardsData;
         }
      }
      
      public function getRewardItemState(itemCode:String) : int
      {
         var result:int = 0;
         var rewardData:Object = this.getRewardItemData(itemCode);
         if(Boolean(rewardData) && rewardData.hasOwnProperty(KEY_REWARD_STATE))
         {
            result = int(rewardData[KEY_REWARD_STATE]);
         }
         return result;
      }
      
      public function setRewardItemState(itemCode:String, newState:int) : void
      {
         var rewardData:Object = this.getRewardItemData(itemCode);
         if(Boolean(rewardData) && rewardData.hasOwnProperty(KEY_REWARD_STATE))
         {
            rewardData[KEY_REWARD_STATE] = newState;
         }
         this.setRewardItemData(itemCode,rewardData);
      }
      
      public function getTimeRemaining() : int
      {
         var endTS:Number = NaN;
         var result:int = 0;
         var data:Object = this.featureData;
         if(Boolean(data) && Boolean(data.hasOwnProperty(this.currentRevision)) && Boolean(data[this.currentRevision].hasOwnProperty(KEY_END_TS)))
         {
            endTS = Number(data[this.currentRevision][KEY_END_TS]);
            if(!isNaN(endTS))
            {
               result = endTS - GlobalEngine.serverTime / 1000;
            }
         }
         return result;
      }
      
      public function getRewardItemThreshold(itemCode:String) : int
      {
         var result:int = 0;
         var rewardData:Object = this.getRewardItemData(itemCode);
         if(Boolean(rewardData) && rewardData.hasOwnProperty(KEY_REWARD_THRESHOLD))
         {
            result = int(rewardData[KEY_REWARD_THRESHOLD]);
         }
         return result;
      }
      
      public function getSortedThresholds() : Array
      {
         var rewardsData:Object = null;
         var itemCode:String = null;
         var itemThreshold:int = 0;
         var result:Array = new Array();
         if(this.enabled)
         {
            rewardsData = this.rewards;
            if(rewardsData)
            {
               for(itemCode in rewardsData)
               {
                  itemThreshold = 0;
                  if(Boolean(rewardsData[itemCode]) && Boolean(rewardsData[itemCode].hasOwnProperty(KEY_REWARD_THRESHOLD)))
                  {
                     itemThreshold = int(rewardsData[itemCode][KEY_REWARD_THRESHOLD]);
                     if(itemThreshold > 0)
                     {
                        result.push(itemThreshold);
                     }
                  }
               }
               if(result.length > 0)
               {
                  result.sort(Array.NUMERIC);
               }
            }
         }
         return result;
      }
      
      public function getItemCodeForThreshold(threshold:int) : String
      {
         var rewards:Object = null;
         var itemCode:String = null;
         var result:String = "";
         if(this.enabled)
         {
            if(threshold > 0)
            {
               rewards = this.rewards;
               if(rewards)
               {
                  for(itemCode in rewards)
                  {
                     if(Boolean(rewards[itemCode]) && Boolean(rewards[itemCode].hasOwnProperty(KEY_REWARD_THRESHOLD)) && rewards[itemCode][KEY_REWARD_THRESHOLD] == threshold)
                     {
                        result = itemCode;
                     }
                  }
               }
            }
         }
         if(result == "")
         {
         }
         return result;
      }
      
      public function getLastShownItemCode() : String
      {
         var currentProgress:int = 0;
         var remainingProgress:int = 0;
         var sortedThresholds:Array = null;
         var currentThresholdValue:int = 0;
         var threshold:int = 0;
         var result:String = "";
         if(this.enabled)
         {
            currentProgress = this.lastShownCount;
            remainingProgress = currentProgress;
            sortedThresholds = this.getSortedThresholds();
            currentThresholdValue = 0;
            for each(threshold in sortedThresholds)
            {
               currentThresholdValue = threshold;
               if(!(remainingProgress >= 0 && remainingProgress - currentThresholdValue >= 0))
               {
                  break;
               }
            }
            if(currentThresholdValue > 0)
            {
               result = this.getItemCodeForThreshold(currentThresholdValue);
            }
         }
         return result;
      }
      
      public function getActualCurentItemCode() : String
      {
         var currentProgress:int = 0;
         var remainingProgress:int = 0;
         var sortedThresholds:Array = null;
         var currentThresholdValue:int = 0;
         var threshold:int = 0;
         var result:String = "";
         if(this.enabled)
         {
            currentProgress = this.count;
            remainingProgress = currentProgress;
            sortedThresholds = this.getSortedThresholds();
            currentThresholdValue = 0;
            for each(threshold in sortedThresholds)
            {
               currentThresholdValue = threshold;
               if(!(remainingProgress >= 0 && remainingProgress - currentThresholdValue >= 0))
               {
                  break;
               }
            }
            if(currentThresholdValue > 0)
            {
               result = this.getItemCodeForThreshold(currentThresholdValue);
            }
         }
         return result;
      }
      
      public function getActualCurrentProgressCount() : int
      {
         var currentProgress:int = 0;
         var remainingProgress:int = 0;
         var sortedThresholds:Array = null;
         var currentThresholdValue:int = 0;
         var applicableThresholdValue:int = 0;
         var threshold:int = 0;
         var result:int = 0;
         if(this.enabled)
         {
            currentProgress = this.count;
            remainingProgress = currentProgress;
            sortedThresholds = this.getSortedThresholds();
            currentThresholdValue = 0;
            applicableThresholdValue = 0;
            for each(threshold in sortedThresholds)
            {
               currentThresholdValue = threshold;
               if(!(remainingProgress >= 0 && remainingProgress - currentThresholdValue >= 0))
               {
                  break;
               }
               applicableThresholdValue = currentThresholdValue;
            }
            if(remainingProgress - applicableThresholdValue >= 0)
            {
               result = remainingProgress - applicableThresholdValue;
            }
         }
         return result;
      }
      
      public function getLastShownProgressCount() : int
      {
         var currentProgress:int = 0;
         var remainingProgress:int = 0;
         var sortedThresholds:Array = null;
         var currentThresholdValue:int = 0;
         var applicableThresholdValue:int = 0;
         var threshold:int = 0;
         var result:int = 0;
         if(this.enabled)
         {
            currentProgress = this.lastShownCount;
            remainingProgress = currentProgress;
            sortedThresholds = this.getSortedThresholds();
            currentThresholdValue = 0;
            applicableThresholdValue = 0;
            for each(threshold in sortedThresholds)
            {
               currentThresholdValue = threshold;
               if(!(remainingProgress >= 0 && remainingProgress - currentThresholdValue >= 0))
               {
                  break;
               }
               applicableThresholdValue = currentThresholdValue;
            }
            if(remainingProgress - applicableThresholdValue >= 0)
            {
               result = remainingProgress - applicableThresholdValue;
            }
         }
         return result;
      }
      
      public function getTotalCountReqForItemCode(itemCode:String) : int
      {
         var currentProgress:int = 0;
         var remainingProgress:int = 0;
         var sortedThresholds:Array = null;
         var currentThresholdValue:int = 0;
         var consumedCount:int = 0;
         var threshold:int = 0;
         var result:int = 0;
         if(this.enabled)
         {
            currentProgress = this.lastShownCount;
            remainingProgress = currentProgress;
            sortedThresholds = this.getSortedThresholds();
            currentThresholdValue = 0;
            consumedCount = 0;
            for each(threshold in sortedThresholds)
            {
               if(this.getItemCodeForThreshold(threshold) == itemCode)
               {
                  currentThresholdValue = threshold;
                  break;
               }
               consumedCount = threshold;
            }
            if(currentThresholdValue - consumedCount > 0)
            {
               result = currentThresholdValue - consumedCount;
            }
         }
         return result;
      }
      
      public function dialogShown(showCount:int = -1) : void
      {
         if(this.enabled)
         {
            if(showCount != -1)
            {
               this.lastShownCount = showCount;
            }
            else
            {
               this.lastShownCount = this.count;
            }
            if(!SpendometerManager.inHiddenExperiemnt())
            {
               TransactionManager.addTransaction(new TransactionWithCallBack("SpendometerService.updateLastShownCount",null,this.m_currentRevision,this.lastShownCount),false);
            }
         }
      }
      
      public function showMiniMarket(item:Array) : void
      {
         if(Boolean(item) && item.length > 0)
         {
            UI.displayMiniMarketDialog(item,FEATURE_OPTIONS_KEY);
         }
      }
      
      public function showMarket(eve:Event = null) : void
      {
         UI.displayMarketDialog(FEATURE_OPTIONS_KEY,"limited");
         IdleTaskQueue.getInstance().addTask(new SpendometerReopenIdleTask());
      }
      
      public function offBoardFeature() : void
      {
         if(SpendometerManager.inSurfacingExperiment())
         {
            SpendometerQueuedIcon.removeHUDIcon();
            this.removeEventListener(SHOW_SPENDOMETER_DIALOG,displayMainUI);
         }
      }
      
      public function grantRewardItem(itemCode:String) : void
      {
         var rewardItem:FarmItem = null;
         if(this.getRewardItemState(itemCode) == REWARD_STATE_READY)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(rewardItem)
            {
               this.setRewardItemState(itemCode,REWARD_STATE_COLLECTED);
               Global.player.addGift(rewardItem.name);
               if(!SpendometerManager.inHiddenExperiemnt())
               {
                  FarmStatsManager.count(FEATURE_OPTIONS_KEY,"reward","collected",itemCode,rewardItem.name,"frontend");
                  TransactionManager.addTransaction(new TransactionWithCallBack("SpendometerService.grantRewardItem",Global.refreshGifts,this.m_currentRevision,itemCode),false);
               }
            }
         }
      }
      
      public function get enabled() : Boolean
      {
         return this.m_isEnabled;
      }
      
      public function set enabled(isEnabled:Boolean) : void
      {
         this.m_isEnabled = isEnabled;
      }
      
      public function get currentRevision() : String
      {
         return this.m_currentRevision;
      }
      
      public function set currentRevision(revision:String) : void
      {
         this.m_currentRevision = revision;
      }
      
      public function checkAndUpdateCashCount(amount:int) : void
      {
         var delta:int = 0;
         if(this.enabled)
         {
            if(amount < this.m_currentCashCount)
            {
               delta = this.m_currentCashCount - amount;
               this.count += delta;
               this.checkAndUpdateRewardState();
               SpendometerQueuedIcon.updateHUDIcon(delta);
            }
         }
         this.m_currentCashCount = amount;
      }
      
      private function checkAndUpdateRewardState() : void
      {
         var statusUpdated:Boolean = false;
         var threshold:int = 0;
         if(this.enabled)
         {
            statusUpdated = false;
            for each(threshold in this.getSortedThresholds())
            {
               if(this.count < threshold)
               {
                  break;
               }
               if(this.getRewardItemState(this.getItemCodeForThreshold(threshold)) == REWARD_STATE_INCOMPLETE)
               {
                  this.setRewardItemState(this.getItemCodeForThreshold(threshold),REWARD_STATE_READY);
                  statusUpdated = true;
                  if(SpendometerManager.inHiddenExperiemnt())
                  {
                     this.dialogShown(this.count);
                     this.grantRewardItem(this.getItemCodeForThreshold(threshold));
                  }
               }
            }
            if(statusUpdated)
            {
               IdleTaskQueue.getInstance().addTask(new SpendometerReopenIdleTask());
            }
         }
      }
   }
}

