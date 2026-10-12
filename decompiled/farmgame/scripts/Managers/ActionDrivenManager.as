package Managers
{
   import Classes.FeatureMessagingDefinition;
   import Classes.Idle.ActionDrivenIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.util.FarmGameUtil;
   import Display.MOTD;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import GameMode.GameModeEvent;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.ActionDrivenRewardsWindow;
   import Widgets.Windows.ActionDrivenWindow;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public class ActionDrivenManager extends BaseFeatureManager
   {
      
      public static const COOLDOWN_HOURS:int = 6;
      
      public static const COOLDOWN_TIME_SECONDS:Number = 21600;
      
      private static const EVENT_FEATURE_UI_BY_MOTD:String = "northpole_toy_works2016";
      
      public static const VIRAL_POST_FREQUENCY_FLAG:String = "ActionDrivenFeedPost";
      
      public static const SERVICE_CLASS:String = "ActionDrivenService";
      
      private static const EXTRA_REWARD_COUNT:int = 5;
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      private var m_item:String;
      
      private var m_timer:Timer;
      
      private var m_motdData:Object = null;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      public function ActionDrivenManager(featureName:String)
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String) : ActionDrivenManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,ActionDrivenManager) as ActionDrivenManager;
      }
      
      public static function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_FEATURE_UI_BY_MOTD,openFeatureByMotd);
      }
      
      public static function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_FEATURE_UI_BY_MOTD,openFeatureByMotd);
      }
      
      public static function dispatchEventListener() : void
      {
         GlobalEventManager.getInstance().dispatchEvent(new Event(EVENT_FEATURE_UI_BY_MOTD));
      }
      
      public static function openFeatureByMotd(e:Event) : void
      {
         ActionDrivenWindow.showStatic(EVENT_FEATURE_UI_BY_MOTD);
         ActionDrivenManager.deleteEventListener();
      }
      
      public static function conditionallyAddToasterIdleTasks() : void
      {
         var featureName:String = null;
         var manager:ActionDrivenManager = null;
         var featureNames:Array = Global.farmGameSettingsManager.getFeatureNamesByType("action_driven_feature");
         if(featureNames)
         {
            for each(featureName in featureNames)
            {
               manager = getInstance(featureName);
               if(!manager.hasReachedMaxActionCount() && manager.passesDateGates())
               {
                  manager.addToasterIdleTask();
               }
            }
         }
      }
      
      public static function showStaticWithObj(params:Object) : void
      {
         var featureName:String = null;
         if(Boolean(params) && Boolean(params.featureName))
         {
            featureName = params.featureName;
            if(featureName)
            {
               showStaticWithString(featureName);
            }
         }
      }
      
      public static function showStaticWithString(featureName:String) : void
      {
         var manager:ActionDrivenManager = getInstance(featureName);
         if(manager.passesDateGates())
         {
            ActionDrivenWindow.showStatic(featureName);
         }
         else
         {
            ActionDrivenRewardsWindow.show(featureName);
         }
      }
      
      public static function onAcceptMOTD(featureName:String, itemName:String = null) : void
      {
         var existingItems:Array = null;
         if(featureName)
         {
            if(itemName)
            {
               existingItems = Global.world.getObjectsByName(itemName);
               if(Boolean(existingItems) && existingItems.length > 0)
               {
                  ActionDrivenWindow.showStatic(featureName);
               }
            }
            else
            {
               ActionDrivenWindow.showStatic(featureName);
            }
         }
      }
      
      private static function onGMBuildPopped(featureName:String, event:GameModeEvent) : void
      {
         ActionDrivenWindow.showStatic(featureName);
      }
      
      private function onCompleteTriggerMOTD(result:Object) : void
      {
         if(result != null)
         {
            MOTD.displayMOTD(result);
         }
      }
      
      public function canHarvest() : Boolean
      {
         var result:Boolean = false;
         var harvestThrottleSeconds:int = getConstantsIntWithKey("harvestThrottleSeconds");
         if(harvestThrottleSeconds > int.MIN_VALUE)
         {
            result = canShowFeatureWithFrequencyInSeconds(harvestThrottleSeconds);
         }
         return result;
      }
      
      public function onHarvestFinished(result:Object) : void
      {
         var harvestTime:Number = NaN;
         if(Boolean(result) && Boolean(result.harvestTime))
         {
            harvestTime = parseInt(result.harvestTime);
            if(!isNaN(harvestTime))
            {
               setFeatureLastShown("",harvestTime);
            }
            else
            {
               ErrorManager.addError(ErrorManager.getFormattedErrorMessage("Non-numeric harvest time for feature. ","featureName=" + m_featureName,"harvestTime=" + harvestTime));
            }
         }
         else
         {
            ErrorManager.addError(ErrorManager.getFormattedErrorMessage("No data from backend for feature. ","featureName=" + m_featureName));
         }
      }
      
      public function passesDateGates() : Boolean
      {
         var result:Boolean = false;
         var startDate:String = getConstantsStringWithKey("startDate");
         var endDate:String = getConstantsStringWithKey("endDate");
         if(Boolean(startDate) && Boolean(endDate) && FarmGameUtil.checkDateGate(startDate,endDate))
         {
            result = true;
         }
         return result;
      }
      
      public function addToasterIdleTask() : void
      {
         IdleTaskQueue.getInstance().addTask(new ActionDrivenIdleTask(m_featureName));
      }
      
      public function hasReachedMaxActionCount() : Boolean
      {
         var result:Boolean = false;
         var currentActionCount:int = getActionCount();
         var maxActionCount:int = getConstantsIntWithKey("maxActionCount");
         if(maxActionCount != int.MIN_VALUE && currentActionCount >= maxActionCount)
         {
            result = true;
         }
         return result;
      }
      
      public function canPost() : Boolean
      {
         var result:Boolean = false;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var lastViralSent:Number = Global.player.getFeatureLastShown(VIRAL_POST_FREQUENCY_FLAG);
         var timeSinceLastPosted:Number = Math.floor(currentTime - lastViralSent);
         if(lastViralSent == 0 || timeSinceLastPosted > COOLDOWN_TIME_SECONDS && timeSinceLastPosted > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function canCollectFromFeed() : int
      {
         var result:int = 0;
         var key:String = m_featureName + ActionDrivenWindow.FRIEND_HELP_ASK_KEY;
         var friendsWhoHelpedCount:int = Global.player.getActionCount(key);
         return int(friendsWhoHelpedCount / ActionDrivenWindow.HELPER_COUNT);
      }
      
      private function canGrantExtraReward() : Boolean
      {
         var result:Boolean = false;
         if(!Global.player.getSeenFlag(m_featureName + "_ExtraRewards"))
         {
            if(!this.hasReachedMaxActionCount())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function grantExtraReward() : void
      {
         var rewardCountToGrant:int = 0;
         var i:int = 0;
         var count:int = EXTRA_REWARD_COUNT;
         var currentActionCount:int = getActionCount();
         var maxActionCount:int = getConstantsIntWithKey("maxActionCount");
         if(this.canGrantExtraReward())
         {
            rewardCountToGrant = maxActionCount - currentActionCount >= 0 && maxActionCount - currentActionCount <= 50 ? int(Math.min(count,maxActionCount - currentActionCount)) : count;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantExtraReward",this.onGrantExtraReward,[m_featureName,count]));
            for(i = 0; i < rewardCountToGrant; i++)
            {
               incrementActionCount();
            }
         }
      }
      
      private function onGrantExtraReward(result:Object) : void
      {
         var count:int = 0;
         if(result.count != null)
         {
            count = int(result.count);
         }
         Global.player.setSeenFlag(m_featureName + "_ExtraRewards");
      }
   }
}

