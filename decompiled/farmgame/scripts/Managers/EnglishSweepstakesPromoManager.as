package Managers
{
   import Classes.Idle.EnglishSweepstakesIdleTask;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.feed.EnglishSweepstakesFeed;
   import Classes.util.FarmGameUtil;
   import Display.FarmDynamicDialog;
   import Display.Promo.EnglishSweepstakesDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TEnterSweepstakes;
   import Transactions.TGetSweepstakesReward;
   import Widgets.Windows.Promotions.EnglishSweepstakesToasterWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.external.ExternalInterface;
   
   public class EnglishSweepstakesPromoManager
   {
      
      public static const FEATURE_NAME:String = "ECSweepstakes";
      
      public static const FIRST_QUEST_COMPLETED:String = "fv_english_sweepstakes_firstQuest";
      
      public static const FEATURE_ENTRIES_ACTION_KEY:String = "SECURE_xuk_sweepstakes_entries";
      
      public static const FEATURE_FREQUENCY_SHARE_FEED:String = "xuk_sweepstakes_feed";
      
      public static const DEFAULT_LANDING_PAGE:String = "https://apps.facebook.com/onthefarm/english_sweepstakes.php";
      
      public function EnglishSweepstakesPromoManager()
      {
         super();
      }
      
      public static function getManager() : FeatureConfigManager
      {
         return FeatureConfigManager.getFeatureConfiguration(FEATURE_NAME);
      }
      
      public static function test() : void
      {
         var timeRemaining:Array = null;
         var timeElapsed:Array = null;
         var lastPostTimes:Array = null;
         var isSweepstakesActive:Boolean = isSweepstakesActive();
         var output:String = "isSweepstakesActive(): " + (isSweepstakesActive ? "yes" : "no") + "\n";
         output = output + "triggerQuest: " + getManager().getStringConstant("triggerQuest") + "\n";
         output = output + "requiredLevel: " + getManager().getNumberConstant("requiredLevel") + "\n";
         output = output + "born date:" + getManager().getStringConstant("@born") + "\n";
         output = output + "dies date:" + getManager().getStringConstant("@dies") + "\n";
         if(isSweepstakesActive)
         {
            timeRemaining = getManager().getTimeRemaining();
            timeElapsed = getManager().getTimeElapsed();
            lastPostTimes = FarmGameUtil.parseTimeLeft(Global.player.getFeatureLastShown(FEATURE_FREQUENCY_SHARE_FEED));
            output = output + "isFirstQuestCompleted(): " + (isFirstQuestCompleted() ? "yes" : "no") + "\n";
            output = output + "sweepstakes entries:" + getRewardEntryCount() + "\n";
            output = output + "remaining days:" + timeRemaining[0] + " hours:" + timeRemaining[1] + "\n";
            output = output + "elapsed days:" + timeElapsed[0] + " hours:" + timeElapsed[1] + "\n";
            output = output + "rollover hours:" + getManager().getNumberConstant("shareRolloverHours") + "\n";
            output = output + "shareItemRewardDays:" + getManager().getNumberConstant("shareItemRewardDays") + "\n";
            output = output + "userCanPostFeed():" + userCanPostFeed() + "\n";
            output = output + "lastPostTimes days:" + lastPostTimes[0] + " hours:" + lastPostTimes[1] + " minutes:" + lastPostTimes[2] + "\n";
         }
         UI.showMessage(output,UI.BUTTON_LAYOUT_OK,"EnglishSweepstakesPromoManager.test()");
      }
      
      public static function claimFirstSweepstakesEntry() : void
      {
         var t:TEnterSweepstakes = null;
         if(isSweepstakesActive())
         {
            t = new TEnterSweepstakes();
            TransactionManager.addTransaction(t);
            addRewardEntry();
         }
      }
      
      public static function addRewardEntry() : void
      {
         if(isSweepstakesActive())
         {
            Global.player.incrementActionCount(FEATURE_ENTRIES_ACTION_KEY,false);
         }
      }
      
      public static function getRewardEntryCount() : Number
      {
         return Global.player.getActionCount(FEATURE_ENTRIES_ACTION_KEY);
      }
      
      public static function isSweepstakesActive() : Boolean
      {
         return getManager().isFeatureVisible();
      }
      
      public static function registerQuestCallback() : void
      {
         QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,onFirstQuestCompleted);
      }
      
      public static function onFirstQuestCompleted(event:QuestEvent) : void
      {
         var completedFarmQuest:FarmQuest = event.quest as FarmQuest;
         if(completedFarmQuest.name == getManager().getStringConstant("triggerQuest"))
         {
            QuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,onFirstQuestCompleted);
            addQuestToasterToQueue();
         }
      }
      
      public static function isFirstQuestCompleted() : Boolean
      {
         var questName:String = null;
         var completedQuests:Array = null;
         var quest:String = null;
         var result:Boolean = false;
         if(isSweepstakesActive())
         {
            questName = getManager().getStringConstant("triggerQuest");
            completedQuests = FarmQuestManager.getInstance().completedQuests;
            for each(quest in completedQuests)
            {
               if(quest == questName)
               {
                  result = true;
                  break;
               }
            }
         }
         return result || Global.player.getSeenFlag(EnglishSweepstakesPromoManager.FIRST_QUEST_COMPLETED);
      }
      
      public static function showDialog(sourceBanner:Boolean = false) : void
      {
         var dialog:EnglishSweepstakesDialog = null;
         var completedFirstQuest:Boolean = false;
         if(EnglishSweepstakesPromoManager.isSweepstakesActive())
         {
            completedFirstQuest = isFirstQuestCompleted();
            if(completedFirstQuest)
            {
               if(getRewardEntryCount() > 0)
               {
                  dialog = FarmDynamicDialog.createDialog(EnglishSweepstakesDialog.ECSWEEPS_POPUP_C,EnglishSweepstakesDialog) as EnglishSweepstakesDialog;
                  if(dialog)
                  {
                     dialog.setConfigType(EnglishSweepstakesDialog.ECSWEEPS_POPUP_C);
                     dialog.setup();
                     dialog.show(true,"EnglishSweepstakesPopup",true);
                     if(sourceBanner)
                     {
                        FarmStatsManager.count("englandsweeps","banner_click","entered");
                     }
                  }
               }
               else
               {
                  dialog = FarmDynamicDialog.createDialog(EnglishSweepstakesDialog.ECSWEEPS_POPUP_D,EnglishSweepstakesDialog) as EnglishSweepstakesDialog;
                  if(dialog)
                  {
                     dialog.setConfigType(EnglishSweepstakesDialog.ECSWEEPS_POPUP_D);
                     dialog.setup();
                     dialog.show(true,"EnglishSweepstakesPopup",true);
                     if(sourceBanner)
                     {
                        FarmStatsManager.count("englandsweeps","banner_click","not_entered");
                     }
                  }
               }
            }
            else if(Global.player.level >= getManager().getNumberConstant("requiredLevel"))
            {
               dialog = FarmDynamicDialog.createDialog(EnglishSweepstakesDialog.ECSWEEPS_POPUP_B,EnglishSweepstakesDialog) as EnglishSweepstakesDialog;
               if(dialog)
               {
                  dialog.setConfigType(EnglishSweepstakesDialog.ECSWEEPS_POPUP_B);
                  dialog.setup();
                  dialog.show(true,"EnglishSweepstakesPopup",true);
                  if(sourceBanner)
                  {
                     FarmStatsManager.count("englandsweeps","banner_click","not_qualified");
                  }
               }
            }
            else
            {
               dialog = FarmDynamicDialog.createDialog(EnglishSweepstakesDialog.ECSWEEPS_POPUP_A,EnglishSweepstakesDialog) as EnglishSweepstakesDialog;
               if(dialog)
               {
                  dialog.setConfigType(EnglishSweepstakesDialog.ECSWEEPS_POPUP_A);
                  dialog.setup();
                  dialog.show(true,"EnglishSweepstakesPopup",true);
                  if(sourceBanner)
                  {
                     FarmStatsManager.count("englandsweeps","banner_click","not_20");
                  }
               }
            }
         }
      }
      
      public static function addQuestToasterToQueue() : void
      {
         var task:EnglishSweepstakesIdleTask = null;
         if(EnglishSweepstakesPromoManager.isSweepstakesActive())
         {
            Global.player.setSeenFlag(EnglishSweepstakesPromoManager.FIRST_QUEST_COMPLETED,false);
            FarmStatsManager.count("englandsweeps","questcomplete","completed");
            task = new EnglishSweepstakesIdleTask(EnglishSweepstakesIdleTask.EXTENDED_TOASTER_DELAY,EnglishSweepstakesIdleTask.QUEST_FINISHED);
            task.submit();
         }
      }
      
      public static function showInGameBanner() : void
      {
         ExternalInterface.call("sendPromoBarMessage","showBanner");
      }
      
      public static function showQuestToaster() : void
      {
         if(EnglishSweepstakesPromoManager.isSweepstakesActive())
         {
            Global.player.setSeenFlag(EnglishSweepstakesPromoManager.FIRST_QUEST_COMPLETED,false);
            FarmStatsManager.count("englandsweeps","questcomplete","completed");
            ToasterManager.getInstance().add(new EnglishSweepstakesToasterWindow(EnglishSweepstakesToasterWindow.QUEST_FINISHED));
         }
      }
      
      public static function showDooberToaster() : void
      {
         if(EnglishSweepstakesPromoManager.isSweepstakesActive())
         {
            ToasterManager.getInstance().add(new EnglishSweepstakesToasterWindow());
         }
      }
      
      public static function userCanPostFeed() : Boolean
      {
         var lastPostTimestamp:Number = NaN;
         var timeSec:Number = NaN;
         var rolloverSec:Number = NaN;
         var result:Boolean = false;
         if(getManager().isFeatureVisible())
         {
            lastPostTimestamp = Global.player.getFeatureLastShown(FEATURE_FREQUENCY_SHARE_FEED);
            timeSec = GlobalEngine.serverTime / 1000;
            rolloverSec = getManager().getNumberConstant("shareRolloverHours") * FarmGameUtil.NUM_SECS_IN_HOUR;
            if(timeSec - lastPostTimestamp >= rolloverSec)
            {
               result = true;
            }
         }
         return result;
      }
      
      private static function onSweepstakesPost(tResult:Object) : void
      {
         var timeElapsedMS:Number = getManager().getTimeElapsedMS();
         var shareItemRewardDays:Number = getManager().getNumberConstant("shareItemRewardDays");
         var shareBundle:String = "";
         var imgUrl:String = "";
         if(timeElapsedMS <= FarmGameUtil.NUM_MSECS_IN_DAY * shareItemRewardDays)
         {
            shareBundle = "EnglishSweepstakes1";
            imgUrl = Global.farmGameSettingsManager.getFarmItemByName("consume_fertilize_all").iconRelativeUrl;
         }
         else
         {
            shareBundle = "EnglishSweepstakes2";
            imgUrl = Global.farmGameSettingsManager.getFarmItemByName("consume_coins_50").iconRelativeUrl;
         }
         var rewardLink:String = tResult.hasOwnProperty("rewardLink") ? tResult["rewardLink"] : DEFAULT_LANDING_PAGE;
         var feed:EnglishSweepstakesFeed = new EnglishSweepstakesFeed(shareBundle,rewardLink);
         feed.setImage(imgUrl);
         Global.player.setFeatureLastShown(FEATURE_FREQUENCY_SHARE_FEED,GlobalEngine.serverTime / 1000,false);
         feed.publish();
      }
      
      public static function onBeginShareFeedFlow() : void
      {
         var t:TGetSweepstakesReward = null;
         if(userCanPostFeed())
         {
            t = new TGetSweepstakesReward(onSweepstakesPost);
            TransactionManager.addTransaction(t,true);
         }
         else
         {
            UI.showMessage("Error: User should not have been able to post a feed since it has been too soon since last feed post");
         }
      }
   }
}

