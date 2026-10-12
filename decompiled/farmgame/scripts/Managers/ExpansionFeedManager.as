package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   
   public class ExpansionFeedManager
   {
      
      public function ExpansionFeedManager()
      {
         super();
      }
      
      public static function onCompleteExpansionMilestone(rewardLink:String, feedKey:String, feedImage:String, trackerKey:String, message:String, buildingFriendlyName:String, itemFriendlyName:String = "", callback:Function = null, fallbackFeedKey:String = "", fallbackStats:Object = null, isItemPopupBlocked:Boolean = false) : void
      {
         var dialog:GenericIconPopup = null;
         var bundleData:Object = {
            "item":itemFriendlyName,
            "first_name":Global.player.firstName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }],
            "building":buildingFriendlyName
         };
         var forceResize:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1;
         if(fallbackFeedKey != "")
         {
            bundleData.fallbackAction = fallbackFeedKey;
            if(fallbackStats != null)
            {
               bundleData.fallbackStats = fallbackStats;
            }
         }
         var onFinishShareExpansionReward:Function = createShareExpansionRewardCallback(feedKey,bundleData,callback);
         if(UI.shouldBlockPopupForRetention() && isItemPopupBlocked)
         {
            UI.handlePopupDisplayForRetention(message,GenericPopup.TYPE_SHARE,onFinishShareExpansionReward,feedImage,trackerKey,{"addToQueue":false});
         }
         else
         {
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,onFinishShareExpansionReward,feedImage,false,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,forceResize,true);
            dialog.setTrackerKey(trackerKey);
            UI.displayPopup(dialog,false);
         }
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,feedKey,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      public static function createShareExpansionRewardCallback(feedAction:String, bundleData:Object, callback:Function = null) : Function
      {
         var onShareExpansionReward:Function = function(event:GenericPopupEvent):void
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,feedAction,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            }
            else
            {
               TransactionManager.addTransaction(new TCancelFriendReward([bundleData["reward_link"]]));
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,feedAction,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            }
            if(callback != null)
            {
               callback(feedAction,bundleData);
            }
         };
         return onShareExpansionReward;
      }
      
      public static function shareStartExpansion(featureFlag:String, statsKingdom:String, message:String, feedImage:String, bundleName:String = null, rewardLink:String = null) : void
      {
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var onShareStartExpansion:Function = function(event:GenericPopupEvent):void
         {
            var bundleData:Object = null;
            if(event.button == GenericPopup.ACCEPT)
            {
               if(rewardLink == null)
               {
                  rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
               }
               bundleData = {
                  "reward_link":rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + rewardLink,
                     "src":feedImage
                  }]
               };
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
               GlobalEngine.socialNetwork.publishFeedStory(bundleName,bundleData,[],false);
            }
            else
            {
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            }
         };
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,onShareStartExpansion,feedImage);
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,statsKingdom,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         UI.displayPopup(dialog,false);
         Global.player.setFeatureLastShown(featureFlag,currentTime,true);
      }
   }
}

