package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.GenericOnboardingWindow;
   
   public class ReturningUserExperienceManager
   {
      
      private static const FEATURE_CONFIG_NAME:String = "returningUserExperience";
      
      public function ReturningUserExperienceManager()
      {
         super();
      }
      
      public static function isInExperiment() : Boolean
      {
         return Global.eosManager.getEosVariant(Experiments.EXPERIMENT_RTUE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
      
      public static function shouldHideQuestBubble() : Boolean
      {
         var feature:XML = null;
         var hideQuestBubbles:XMLList = null;
         var hideBubble:XML = null;
         var prereqs:XMLList = null;
         var result:Boolean = false;
         if(ReturningUserExperienceManager.isInExperiment())
         {
            feature = Global.farmGameSettingsManager.getFeatureXML(ReturningUserExperienceManager.FEATURE_CONFIG_NAME);
            if(feature != null && feature.hasOwnProperty("hideQuestBubbles"))
            {
               hideQuestBubbles = feature.hideQuestBubbles;
               hideBubble = hideQuestBubbles[0];
               prereqs = hideBubble.prereqs.prereq;
               if(PrerequisiteUtility.evalPrereqsXML(prereqs))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public static function shouldHideArrowFlyout(type:String = "quest") : Boolean
      {
         var feature:XML = null;
         var hideArrowFlyout:XMLList = null;
         var hideFlyouts:XML = null;
         var typeFlyouts:XMLList = null;
         var node:XML = null;
         var flyoutObject:Object = null;
         var prereqs:XMLList = null;
         var result:Boolean = false;
         if(ReturningUserExperienceManager.isInExperiment())
         {
            feature = Global.farmGameSettingsManager.getFeatureXML(ReturningUserExperienceManager.FEATURE_CONFIG_NAME);
            if(feature != null && feature.hasOwnProperty("hideFlyout"))
            {
               hideArrowFlyout = feature.hideFlyout;
               hideFlyouts = hideArrowFlyout[0];
               if(hideFlyouts != null && hideFlyouts.hasOwnProperty("flyout"))
               {
                  typeFlyouts = hideFlyouts.flyout;
                  node = null;
                  for each(node in typeFlyouts)
                  {
                     flyoutObject = FarmGameSettingsManager.parseXmlAttributesToObject(node,true);
                     if(flyoutObject["type"] == type)
                     {
                        break;
                     }
                     node = null;
                  }
                  if(node != null)
                  {
                     prereqs = node.prereqs.prereq;
                     if(PrerequisiteUtility.evalPrereqsXML(prereqs))
                     {
                        result = true;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public static function sendTransactionAndRewardUser() : void
      {
         if(ReturningUserExperienceManager.isInExperiment())
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("ReturningUserExperienceService.rewardUserIfNecessary",ReturningUserExperienceManager.checkDailyDripStatus,""),true);
            ReturningUserExperienceManager.updateFeatureOptionsIfNecessary();
            ReturningUserExperienceManager.rewardUserIfNecessary();
         }
      }
      
      private static function checkDailyDripStatus(data:Object) : void
      {
         var farmItem:FarmItem = null;
         var iconPath:String = null;
         var message:String = null;
         var promise:String = null;
         var extraData:Object = null;
         if(data.hasOwnProperty("daily_drip_prize") && data["daily_drip_prize"] !== null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(data["daily_drip_prize"]);
            iconPath = farmItem.icon;
            message = ZLocUtils.t("Dialogs","RTUE_DailyDripMessage");
            promise = "";
            if(!(data["last_day_of_daily_drip_awards"] as Boolean))
            {
               promise = " " + ZLocUtils.t("Dialogs","RTUE_DailyDripPromise");
            }
            extraData = new Object();
            extraData["item"] = farmItem;
            extraData["message"] = message + promise;
            extraData["iconTooltip"] = ZLocUtils.t("Dialogs","RTUE_DailyDripIconHoverText");
            Global.hud.rightSideIconQueue.addIcon("DailyDrip",DynamicIconQueue.ADD_BY_PRIORITY,null,extraData,false);
            Global.player.addGift(data["daily_drip_prize"]);
         }
      }
      
      private static function rewardUserIfNecessary() : void
      {
         var buckets:XMLList = null;
         var bucket:XML = null;
         var prereqs:XMLList = null;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(ReturningUserExperienceManager.FEATURE_CONFIG_NAME);
         if(feature != null && feature.hasOwnProperty("bucket"))
         {
            buckets = feature.bucket;
            for each(bucket in buckets)
            {
               prereqs = bucket.prereqs.prereq;
               if(PrerequisiteUtility.evalPrereqsXML(prereqs))
               {
                  UserRewardUtil.grantUserRewardsFromXml(bucket.rewards[0]);
               }
            }
         }
      }
      
      private static function updateFeatureOptionsIfNecessary() : void
      {
         var bucketingPrereq:XML = null;
         var userRebucketed:Boolean = false;
         var i:int = 0;
         var featureOptionValue:Object = null;
         var reset:Boolean = false;
         var sessionObject:Object = null;
         var keyName:String = null;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(ReturningUserExperienceManager.FEATURE_CONFIG_NAME);
         var keyNames:Array = new Array();
         var initialBucketPrereqNames:Array = new Array();
         for each(bucketingPrereq in feature.initialBucketingPrereqs.bucketingPrereq)
         {
            keyNames.push(bucketingPrereq.@sessionVar);
            initialBucketPrereqNames.push(bucketingPrereq.@prereq);
         }
         userRebucketed = false;
         for(i = 0; i < keyNames.length; i++)
         {
            if(PrerequisiteUtility.checkPrereqByName(initialBucketPrereqNames[i]))
            {
               featureOptionValue = new Object();
               featureOptionValue[keyNames[i]] = 1;
               FeatureOptionsManager.getInstance().setFeatureOption(ReturningUserExperienceManager.FEATURE_CONFIG_NAME,"session",featureOptionValue);
               userRebucketed = true;
               break;
            }
         }
         if(!userRebucketed)
         {
            reset = false;
            sessionObject = FeatureOptionsManager.getInstance().getFeatureOption(ReturningUserExperienceManager.FEATURE_CONFIG_NAME,"session");
            for each(keyName in keyNames)
            {
               if(sessionObject !== null && sessionObject.hasOwnProperty(keyName) && sessionObject[keyName] as int > (feature.sessionsBeforeRemovingRTUEStatus.@value as int))
               {
                  reset = true;
                  break;
               }
            }
            if(reset)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(ReturningUserExperienceManager.FEATURE_CONFIG_NAME,"session",new Object());
            }
         }
      }
      
      public static function awardGiftPack() : void
      {
         var feature:XML = null;
         var params:Object = null;
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_RTUE) == Experiments.VARIANT_POPUP_REDUCTION_AND_REWARDS)
         {
            feature = Global.farmGameSettingsManager.getFeatureXML(ReturningUserExperienceManager.FEATURE_CONFIG_NAME);
            params = new Object();
            params["dialog"] = feature.@swf;
            params["icon"] = feature.image.@path;
            params["buttonText"] = "Dialogs:WelcomeBackPackButtonText";
            params["text"] = "Dialogs:WelcomeBackPackBody";
            UI.displayPopup(new GenericOnboardingWindow(params));
            StatsManager.count("react_optimization","award_gift_pack");
         }
      }
   }
}

