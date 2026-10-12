package Managers
{
   import Classes.BirdCaptureFeatureComponent;
   import Classes.CaptureFeatureComponent;
   import Classes.CaptureFeatureItem;
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.GopherCaptureFeatureComponent;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.UI;
   import Engine.Classes.Observer.IObserver;
   import Engine.Managers.TransactionManager;
   import Transactions.CaptureFeatures.TBuyCaptureFeatureTreat;
   import Transactions.CaptureFeatures.TCaptureFeatureAskForTreats;
   import Transactions.CaptureFeatures.TCapturedFeature;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.CaptureFeatures.CaptureFeaturePopupWindow;
   import Widgets.Windows.FarmWindow;
   import flash.utils.Dictionary;
   
   public class CaptureFeatureManager implements IObserver
   {
      
      private static var s_instance:CaptureFeatureManager;
      
      public static const GOPHER_FEATURE_NAME:String = "gophergarden";
      
      public static const BIRD_FEATURE_NAME:String = "migrationpond";
      
      public static const FEATURE_NEXT_AVAILABLE_TIME:String = "nextAvailableTime";
      
      public static const FEATURE_NEXT_AVAILABLE_FEATURE_ITEM:String = "nextAvailableGopher";
      
      public static const FEATURE_CAPTURED_COUNT:String = "capturedCount";
      
      public static const FEATURE_TREAT_COUNT:String = "treatCount";
      
      public static const FEATURE_OPT_STATUS:String = "optStatus";
      
      private static const ON_GOPHER_SEEN:String = "onGopherSeen";
      
      private static const ON_GOPHER_IGNORED:String = "onGopherIgnored";
      
      private static const ON_GOPHER_CAPTURED:String = "onGopherCaptured";
      
      public static const FEATURE_OPT_IN:int = 1;
      
      public static const EXPERIMENT_FEATURE:String = "feature";
      
      public static const FEATURE_SHOW_CHANCE_IN:Number = 0.1;
      
      public static const FEATURE_SHOW_CHANCE_OUT:Number = 0.00005;
      
      public static const SOURCE_UI:String = "ui";
      
      public static const SOURCE_CONTEXT:String = "context";
      
      private const CANCAPTURE:String = "CanCapture";
      
      private const CANNOTCAPTURE_TREATS:String = "CannotCaptureTreats";
      
      private const GOPHER_GARDEN_FEATURE_SHOW_CHANCE:String = "GOPHER_GARDEN_FEATURE_SHOW_CHANCE";
      
      private const GOPHER_GARDEN_FEATURE_SHOW_CHANCE_OUT:String = "GOPHER_GARDEN_FEATURE_SHOW_CHANCE_OUT";
      
      private var m_feedLocks:Object = {};
      
      private var m_onUnlockCallbacks:Object = {};
      
      private var m_spawnedWindows:Vector.<FarmWindow> = new Vector.<FarmWindow>();
      
      private var m_featureComponents:Dictionary;
      
      private var m_initialized:Boolean = false;
      
      public function CaptureFeatureManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[GopherManager] :: Use GetInstance()");
      }
      
      public static function get instance() : CaptureFeatureManager
      {
         if(!s_instance)
         {
            s_instance = new CaptureFeatureManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function getExperimentOption(featureID:String, variant:int, option:String) : XMLList
      {
         var feature:XML = null;
         var variants:XMLList = null;
         var obj:XMLList = null;
         var config:XMLList = null;
         feature = Global.farmGameSettingsManager.getFeatureXML(featureID);
         variants = feature.experimentConfig.variant;
         config = variants.(@value == variant);
         if(config[option] != "")
         {
            obj = config[option];
         }
         return obj.toString() != "" ? obj : null;
      }
      
      public static function gopherFeatureExperimentHelper(option:String) : XMLList
      {
         return CaptureFeatureManager.getExperimentOption("gophergarden",getExperimentVariant(),option);
      }
      
      public static function getExperimentVariant() : int
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GOPHERGARDEN);
      }
      
      public function get initialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function init() : void
      {
         this.m_initialized = true;
         this.m_featureComponents = new Dictionary();
         if(gopherFeatureExperimentHelper(EXPERIMENT_FEATURE))
         {
            this.m_featureComponents[GOPHER_FEATURE_NAME] = new GopherCaptureFeatureComponent(GOPHER_FEATURE_NAME);
         }
         var birdMigrationVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BIRDMIGRATION);
         if(birdMigrationVariant == 2 || birdMigrationVariant == 3)
         {
            this.m_featureComponents[BIRD_FEATURE_NAME] = new BirdCaptureFeatureComponent(BIRD_FEATURE_NAME);
         }
      }
      
      public function notify(event:String, data:Object) : void
      {
         var item:CaptureFeatureComponent = null;
         for each(item in this.m_featureComponents)
         {
            item.notify(event,data);
         }
      }
      
      public function onFeatureInteraction(featureName:String, gopher:CaptureFeatureItem) : void
      {
         var result:String = null;
         var counter:String = null;
         var featureData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData();
         if(gopher.getFinalState() != CaptureFeatureItem.FEATURE_STATE_RESOLVED)
         {
            gopher.setInteractedWith();
            result = this.canCaptureFeatureItem(featureName,gopher.getItemName());
            counter = this.getStatsPrefix(featureName) + "s";
            if(result == this.CANCAPTURE)
            {
               FarmStatsManager.count(counter,"click_captured",featureData["nextAvailableGopher"]);
               this.captureGopher(featureName,gopher,false);
            }
            else if(result == this.CANNOTCAPTURE_TREATS)
            {
               FarmStatsManager.count(counter,"click_escaped",featureData["nextAvailableGopher"]);
               UI.displayPopup(new CaptureFeaturePopupWindow(featureName,gopher,CaptureFeaturePopupWindow.INSUFFICIENT_TREATS));
            }
         }
      }
      
      public function onFeatureIdle(featureName:String, gopher:CaptureFeatureItem) : void
      {
         var window:FarmWindow = new CaptureFeaturePopupWindow(featureName,gopher,CaptureFeaturePopupWindow.APPEARED);
         UI.displayPopup(window);
         this.m_spawnedWindows.push(window);
      }
      
      public function onFeatureIgnored(featureName:String, gopher:CaptureFeatureItem) : void
      {
         var featureItemId:String = null;
         if(gopher.getFinalState() != CaptureFeatureItem.FEATURE_STATE_RESOLVED)
         {
            gopher.setResolved();
            featureItemId = gopher.getItemName();
            TransactionManager.addTransaction(new TCapturedFeature(featureName,ON_GOPHER_IGNORED,featureItemId));
            this.resetFeatureWindows();
            FarmStatsManager.count(this.getStatsPrefix(featureName) + "s","disappear",featureItemId);
         }
      }
      
      public function onFeatureSeen(featureName:String, gopher:CaptureFeatureItem) : void
      {
         if(gopher.getFinalState() != CaptureFeatureItem.FEATURE_STATE_RESOLVED)
         {
            gopher.setResolved();
            this.resetFeatureWindows();
            TransactionManager.addTransaction(new TCapturedFeature(featureName,ON_GOPHER_SEEN,gopher.getItemName()),true);
         }
      }
      
      private function resetFeatureWindows() : void
      {
         var window:FarmWindow = null;
         for each(window in this.m_spawnedWindows)
         {
            UI.removeFromPopupQueue(window);
         }
         this.m_spawnedWindows = new Vector.<FarmWindow>();
      }
      
      private function canCaptureFeatureItem(featureName:String, featureItemId:String) : String
      {
         var result:String = this.CANCAPTURE;
         var data:Object = this.getItemData(featureName,featureItemId);
         if(data.requirements.@treats > this.getTreatCount(featureName))
         {
            result = this.CANNOTCAPTURE_TREATS;
         }
         return result;
      }
      
      public function getGopherCapturePrice(featureName:String, featureItemId:String) : int
      {
         return int(this.getItemData(featureName,featureItemId).@capturePrice);
      }
      
      public function captureGopher(featureName:String, featureItem:CaptureFeatureItem, paid:Boolean = false) : void
      {
         var gopherData:Object = null;
         var data:Object = null;
         var itemName:String = featureItem.getItemName();
         var featureData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData();
         if(featureItem.getFinalState() != CaptureFeatureItem.FEATURE_STATE_RESOLVED)
         {
            featureItem.setResolved();
            TransactionManager.addTransaction(new TCapturedFeature(featureName,ON_GOPHER_CAPTURED,itemName,paid));
            gopherData = (this.m_featureComponents[featureName] as CaptureFeatureComponent).featureData;
            if(gopherData.hasOwnProperty(itemName))
            {
               UserRewardUtil.grantUserRewardsFromXml(gopherData[itemName]);
            }
            if(featureData[FEATURE_CAPTURED_COUNT] == null)
            {
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_PROMPT_IDLE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
               {
                  featureData[FEATURE_CAPTURED_COUNT] = {};
               }
               else
               {
                  featureData[FEATURE_CAPTURED_COUNT] = [];
               }
            }
            if(featureData[FEATURE_CAPTURED_COUNT][itemName] == null)
            {
               featureData[FEATURE_CAPTURED_COUNT][itemName] = 0;
            }
            ++featureData[FEATURE_CAPTURED_COUNT][itemName];
            data = this.getItemData(featureName,itemName);
            if(Boolean(data) && !paid)
            {
               featureData[FEATURE_TREAT_COUNT] -= data.requirements.@treats;
            }
            this.resetFeatureWindows();
            UI.displayPopup(new CaptureFeaturePopupWindow(featureName,featureItem,CaptureFeaturePopupWindow.CAPTURED));
            featureItem.detach();
         }
      }
      
      public function postCapture(featureItem:CaptureFeatureItem) : void
      {
         var buildingItem:FarmItem = null;
         var building:FeatureBuilding = null;
         var feature:String = featureItem.featureName;
         var buildingLookup:Array = Global.world.getObjectsByName(feature);
         if(buildingLookup.length == 0)
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(feature);
            UI.displayPopup(new BuildingSurfaceWindow(buildingItem,featureItem,false,null,buildingItem.name));
         }
         else
         {
            building = buildingLookup[0] as FeatureBuilding;
            if(building)
            {
               building.displayStorageDialog();
            }
         }
      }
      
      public function purchaseGopherTreat(featureName:String, callback:Function) : Boolean
      {
         var success:Boolean = false;
         var price:int = (this.m_featureComponents[featureName] as CaptureFeatureComponent).treatPrice;
         if(Global.player.canBuyCash(price,true))
         {
            TransactionManager.addTransaction(new TBuyCaptureFeatureTreat(featureName,callback),true);
         }
         return success;
      }
      
      public function getTreatPrice(featureName:String) : int
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).treatPrice;
      }
      
      public function askForTreats(featureName:String, source:String, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TCaptureFeatureAskForTreats(callback,featureName,source),true);
      }
      
      public function getStatsPrefix(featureName:String) : String
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).statsPrefix;
      }
      
      public function getStringsPrefix(featureName:String) : String
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).stringsPrefix;
      }
      
      public function getFeatureNameFromItemName(itemName:String) : String
      {
         var featureComponent:String = null;
         var feature:CaptureFeatureComponent = null;
         var featureItem:String = null;
         var featureName:String = null;
         loop0:
         for(featureComponent in this.m_featureComponents)
         {
            feature = this.m_featureComponents[featureComponent];
            for(featureItem in feature.featureData)
            {
               if(featureItem == itemName)
               {
                  featureName = featureComponent;
                  break loop0;
               }
            }
         }
         return featureName;
      }
      
      public function getItemData(featureName:String, featureItemId:String) : XML
      {
         var gopherData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).featureData;
         return gopherData.hasOwnProperty(featureItemId) ? gopherData[featureItemId] : null;
      }
      
      public function getFeatureItems(featureName:String) : Array
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).featureItems;
      }
      
      public function getCaptureItemRewardData(featureName:String, featureItemId:String) : Array
      {
         var reward:XML = null;
         var rewards:Array = new Array();
         var gopherData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).featureData;
         var rlist:XMLList = gopherData[featureItemId].rewards.reward;
         var i:int = 0;
         var l:int = rlist.length();
         while(i < l)
         {
            reward = rlist[i];
            rewards.push({
               "type":reward.@type,
               "value":reward.@value
            });
            i++;
         }
         return rewards;
      }
      
      public function getBuildingData(featureName:String) : Array
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).buildingData;
      }
      
      public function getCurrentBuildLevel(featureName:String) : int
      {
         var level:Object = null;
         var caught:int = this.getCapturedCount(featureName);
         var buildingData:Array = this.getBuildingData(featureName);
         for(var i:int = 0; i < buildingData.length; i++)
         {
            level = buildingData[i];
            if(level.capturedGophers > caught)
            {
               break;
            }
         }
         return i > 0 ? int(i - 1) : 0;
      }
      
      public function getCurrentMaxTreats(featureName:String) : int
      {
         var treats:int = 0;
         var current:int = this.getCurrentBuildLevel(featureName);
         var buildingData:Array = this.getBuildingData(featureName);
         if(buildingData.length > current)
         {
            treats = int(buildingData[current]["maxTreats"]);
         }
         return treats;
      }
      
      public function canAskForTreats(featureName:String, source:String) : Boolean
      {
         return (this.m_featureComponents[featureName] as CaptureFeatureComponent).dataLoaded && this.getCurrentMaxTreats(featureName) > this.getTreatCount(featureName) && this.secondsLeftToNextAskForTreats(featureName,source) == 0 && !this.isFeedLocked(featureName,source);
      }
      
      public function secondsLeftToNextAskForTreats(featureName:String, source:String) : int
      {
         var timeSinceLastFeed:int = 0;
         var feedData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).feedData[source];
         var seconds:int = 0;
         if(feedData)
         {
            timeSinceLastFeed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(feedData.throttle);
            seconds = feedData.throttleTime - timeSinceLastFeed;
            if(seconds < 0)
            {
               seconds = 0;
            }
         }
         return seconds;
      }
      
      public function setAskThrottle(featureName:String, source:String) : void
      {
         var feedData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).feedData[source];
         if(feedData)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(feedData.throttle),true);
            Global.player.setFeatureLastShown(feedData.throttle,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
      }
      
      public function lockAskForTreats(featureName:String, source:String) : void
      {
         var feedData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).feedData[source];
         if(feedData)
         {
            this.m_feedLocks[feedData.throttle] = 1;
         }
      }
      
      public function unlockAskForTreats(featureName:String, source:String) : void
      {
         var func:Function = null;
         var feedData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).feedData[source];
         if(feedData)
         {
            func = this.m_onUnlockCallbacks[source] as Function;
            if(func != null)
            {
               func();
            }
            this.m_onUnlockCallbacks[source] = null;
            this.m_feedLocks[feedData.throttle] = null;
         }
      }
      
      public function isFeedLocked(featureName:String, source:String) : Boolean
      {
         var feedData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).feedData[source];
         var result:Boolean = false;
         if(feedData)
         {
            result = this.m_feedLocks[feedData.throttle] == 1;
         }
         return result;
      }
      
      public function registerOnUnlockCallback(source:String, func:Function) : void
      {
         this.m_onUnlockCallbacks[source] = func;
      }
      
      public function getCapturedCount(featureName:String) : int
      {
         var i:int = 0;
         var count:int = 0;
         for each(i in this.getCapturedBreakdown(featureName))
         {
            count += i;
         }
         return count;
      }
      
      public function getCapturedBreakdown(featureName:String) : Object
      {
         var featureData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData();
         return featureData[FEATURE_CAPTURED_COUNT];
      }
      
      public function getTreatCount(featureName:String) : int
      {
         var featureData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData();
         return featureData[FEATURE_TREAT_COUNT];
      }
      
      public function incrementTreatCount(featureName:String, count:int = 1) : Boolean
      {
         var success:Boolean = false;
         var featureData:Object = (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData();
         if(this.getTreatCount(featureName) < this.getCurrentMaxTreats(featureName))
         {
            featureData[FEATURE_TREAT_COUNT] += count;
            success = true;
         }
         return success;
      }
      
      public function setFeatureData(featureName:String, data:Object) : void
      {
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).setFeatureData(data);
      }
      
      public function getFeatureData(featureName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(featureName,featureName);
      }
      
      public function resetFeatureData(featureName:String) : void
      {
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).createFeatureData();
      }
      
      public function setAvailableTime(featureName:String, time:int) : void
      {
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData()[FEATURE_NEXT_AVAILABLE_TIME] = time;
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).setFeatureData();
      }
      
      public function setAvailableGopher(featureName:String, featureItemId:String) : void
      {
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).getFeatureData()[FEATURE_NEXT_AVAILABLE_FEATURE_ITEM] = featureItemId;
         (this.m_featureComponents[featureName] as CaptureFeatureComponent).setFeatureData();
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
