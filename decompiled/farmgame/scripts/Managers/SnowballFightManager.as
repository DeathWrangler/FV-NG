package Managers
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.feed.W2WFeatureFeed;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetW2WReward;
   import Widgets.Windows.SnowballFight.SnowballWindow;
   import flash.geom.Point;
   
   public class SnowballFightManager
   {
      
      public static const FEATURE_NAME:String = "snowman2010";
      
      public static const FEED_NAME:String = "snowball_throw";
      
      public static const SORRY_CREDIT:String = "snowman2010_sorryCredit";
      
      public static const SNOWBALL_THROW_HIT_BUNDLE:String = "SnowmanW2WSnowballHit";
      
      public static const SNOWBALL_THROW_MISS_BUNDLE:String = "SnowmanW2WSnowballMiss";
      
      private static const THROW_SNOWBALL_OVERLAY_URL:String = "assets/effects/effects_snowballThrow.swf";
      
      private static const OVERLAY_X:Number = 0;
      
      private static const OVERLAY_Y:Number = 0;
      
      private static const OVERLAY_WIDTH:Number = 760;
      
      private static const OVERLAY_HEIGHT:Number = 600;
      
      public static const STAT_SNOWBALL:String = "snowball";
      
      public static const STAT_PROMPT_THROW:String = "prompt_throw_friend_farm";
      
      public static const STAT_PROMPT_THROW_FIRST_TIME:String = "prompt_throw_friend_farm_first_time";
      
      public static const STAT_THROW_SHARE:String = "throw_snow_friend_farm_share";
      
      public static const STAT_THROW_MISS_SHARE:String = "throw_snow_friend_farm_miss_share";
      
      public static const STAT_HIT_BY_SNOWBALL:String = "hit_by_snowball";
      
      public static const STAT_HIT_BY_SNOWBALL_FIRST_TIME:String = "hit_by_snowball_first_time";
      
      public static const STAT_ERROR_ELIGIBLE_RECIPIENTS:String = "error_eligible_recipients";
      
      public function SnowballFightManager()
      {
         super();
      }
      
      public static function isFeatureActive() : Boolean
      {
         return true;
      }
      
      public static function canTargetPlayer(targetUid:String) : Boolean
      {
         var initComplete:Boolean = Global.player.w2wState.initComplete;
         var wasRecentlySent:Boolean = Global.player.w2wState.getRecentlySent(FEATURE_NAME,FEED_NAME,targetUid);
         return isFeatureActive() && initComplete && !wasRecentlySent;
      }
      
      public static function promptThrowSnowball(neighborUid:String) : void
      {
         var target:Friend;
         var onShare:Function = null;
         FarmStatsManager.count(STAT_SNOWBALL,STAT_PROMPT_THROW);
         if(!Global.player.getSeenFlag(STAT_PROMPT_THROW_FIRST_TIME))
         {
            FarmStatsManager.count(STAT_SNOWBALL,STAT_PROMPT_THROW_FIRST_TIME);
            Global.player.setSeenFlag(STAT_PROMPT_THROW_FIRST_TIME);
         }
         target = Global.friendManager.getFriendData(neighborUid);
         if(target)
         {
            onShare = function():void
            {
               FarmStatsManager.count(STAT_SNOWBALL,STAT_THROW_SHARE);
               SnowballFightManager.onSnowballThrown(neighborUid);
            };
            displaySnowballWindow(ZLocUtils.t("Dialogs","Snowman2010_SnowballFight"),target.picture,ZLocUtils.t("Dialogs","Snowman2010_ThrowSnowballPrompt",{"user":ZLocUtils.tn(target.firstName,ZLocUtils.tg(target.snUser.gender))}),ZLocUtils.t("Dialogs","GenericShareButton"),onShare);
         }
      }
      
      public static function onSnowballThrown(targetUid:String) : void
      {
         var hitUid:String = rollSnowballHit(targetUid);
         if(hitUid == targetUid)
         {
            onBeginShareFeedFlow(targetUid,targetUid);
         }
         else
         {
            promptSnowballMiss(hitUid,targetUid);
         }
      }
      
      private static function rollSnowballHit(targetUid:String) : String
      {
         var friends:Array = null;
         var randomPick:int = 0;
         var result:Friend = Global.friendManager.getFriendData(targetUid);
         var roll:Number = Math.random() * 100;
         var missPercentage:Number = Global.farmGameSettingsManager.getW2WMissPercentage(FEATURE_NAME);
         if(roll <= missPercentage)
         {
            friends = Global.friendManager.appFriends;
            randomPick = Math.floor(Math.random() * friends.length);
            result = friends[randomPick];
         }
         return result.uid;
      }
      
      public static function promptSnowballMiss(hitUid:String, targetUid:String) : void
      {
         var target:Friend = Global.friendManager.getFriendData(targetUid);
         var hit:Friend = Global.friendManager.getFriendData(hitUid);
         var onShare:Function = function():void
         {
            FarmStatsManager.count(STAT_SNOWBALL,STAT_THROW_MISS_SHARE);
            onBeginShareFeedFlow(hitUid,targetUid);
         };
         if(hit != null)
         {
            displaySnowballWindow(ZLocUtils.t("Dialogs","Snowman2010_SnowballFight"),hit.picture,ZLocUtils.t("Dialogs","Snowman2010_ThrowSnowballMissed",{
               "userA":ZLocUtils.tn(target.firstName,ZLocUtils.tg(target.snUser.gender)),
               "userB":ZLocUtils.tn(hit.firstName,ZLocUtils.tg(hit.snUser.gender))
            }),ZLocUtils.t("Dialogs","GenericShareButton"),onShare);
         }
      }
      
      private static function onBeginShareFeedFlow(hitUid:String, targetUid:String) : void
      {
         var callback:Function = function():void
         {
            var t:TGetW2WReward = new TGetW2WReward(FEATURE_NAME,FEED_NAME,hitUid,targetUid,function(tResult:Object):void
            {
               promptShareFeed(hitUid,targetUid,tResult.toString());
            });
            TransactionManager.addTransaction(t,true);
         };
         throwSnowballFX(callback);
      }
      
      private static function promptShareFeed(hitUid:String, targetUid:String, tResult:String) : void
      {
         var bundleId:String = SNOWBALL_THROW_HIT_BUNDLE;
         if(hitUid != targetUid)
         {
            bundleId = SNOWBALL_THROW_MISS_BUNDLE;
            FarmStatsManager.count("snowball","prompt_throw_friend_farm","miss","click_share");
         }
         else
         {
            FarmStatsManager.count("snowball","prompt_throw_friend_farm","hit","click_share");
         }
         var feed:W2WFeatureFeed = new W2WFeatureFeed(bundleId,tResult,hitUid,targetUid);
         var snowballItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("snowball_part");
         if(snowballItem != null)
         {
            feed.setImage("assets/newsfeed/snowballfight_hit.png");
         }
         feed.publishFeedWithoutPrompt();
      }
      
      private static function throwSnowballFX(cb:Function) : void
      {
         var params:Object = {
            "instanceName":"effect_mc",
            "addToStage":true,
            "freezeAll":true
         };
         Global.ui.displayOverlaySWF(Global.getAssetURL(THROW_SNOWBALL_OVERLAY_URL),new Point(OVERLAY_X,OVERLAY_Y),new Vector2(OVERLAY_WIDTH,OVERLAY_HEIGHT),0,cb,params);
      }
      
      public static function displaySnowballWindow(title:String, iconUrl:String, message:String, acceptButtonText:String, acceptCallback:Function = null, cancelCallback:Function = null) : void
      {
         var snowballWindow:SnowballWindow = new SnowballWindow(title,iconUrl,message,acceptButtonText,acceptCallback,cancelCallback);
         UI.displayPopup(snowballWindow,false,"throwSnowballWindow");
      }
   }
}

