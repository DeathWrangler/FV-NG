package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Helpers.IntVector2;
   import Engine.Managers.TransactionManager;
   import Events.SubscriptionsEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.MOTD.SubscriptionAllBenefitsMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionPostFCBuyMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionRevampExSignUpWindow;
   import Widgets.Windows.MOTD.SubscriptionStreakRestoredMOTDWindow;
   import Widgets.Windows.Subscriptions.SubscriptionPostSignupCongratsWindow;
   import Widgets.Windows.Subscriptions.SubscriptionReinstateWindow;
   import Widgets.Windows.Subscriptions.SubscriptionWeeklyVIPFridaySale;
   import Widgets.Windows.Subscriptions.SubscriptionsBenefits;
   import Widgets.Windows.Subscriptions.SubscriptionsBenefitsRetention;
   import Widgets.Windows.Subscriptions.SubscriptionsBonusDrop;
   import Widgets.Windows.Subscriptions.SubscriptionsLearnMore;
   import Widgets.Windows.Subscriptions.SubscriptionsLevelUp;
   import Widgets.Windows.Subscriptions.SubscriptionsMigration;
   import Widgets.Windows.Subscriptions.SubscriptionsNoDrop;
   import Widgets.Windows.Subscriptions.SubscriptionsPSDeclinedWindow;
   import Widgets.Windows.Subscriptions.SubscriptionsRedeemV1Drop;
   import Widgets.Windows.Subscriptions.SubscriptionsSignUp;
   import Widgets.Windows.Subscriptions.SubscriptionsSignUpConfirmation;
   import Widgets.Windows.Subscriptions.SubscriptionsWeeklyDrop;
   import Widgets.Windows.Subscriptions.TrialSubscriptionStart;
   import flash.events.EventDispatcher;
   
   public class SubscriptionsManager extends EventDispatcher
   {
      
      private static var m_revampEADuration:Number;
      
      private static var m_revampTrialDuration:Number;
      
      private static var m_revampStarttime:Number;
      
      public static const SUBSCRIPTION_ACTIVE:String = "SUBSCRIPTION_ACTIVE";
      
      public static const SUBSCRIPTION_TRIAL:String = "SUBSCRIPTION_TRIAL";
      
      public static const SUBSCRIPTION_PENDING_CANCEL:String = "SUBSCRIPTION_PENDING_CANCEL";
      
      public static const SUBSCRIPTION_CANCELED:String = "SUBSCRIPTION_CANCELED";
      
      public static const SUBSCRIPTION_REINSTATE:String = "SUBSCRIPTION_REINSTATE";
      
      public static const SHOW_SIGNUP_POPUP:String = "SHOW_SIGNUP_POPUP";
      
      public static const SHOW_SIGNUP_CONFIRMATION_POPUP:String = "SHOW_SIGNUP_CONFIRMATION_POPUP";
      
      public static const SHOW_MIGRATION_POPUP:String = "SHOW_MIGRATION_POPUP";
      
      public static const SHOW_DROP_POPUP:String = "SHOW_DROP_POPUP";
      
      public static const SHOW_BENEFITS_POPUP:String = "SHOW_BENEFITS_POPUP";
      
      public static const SHOW_TRIAL_SUB_START_POPUP:String = "SHOW_TRIAL_SUB_START_POPUP";
      
      public static const SHOW_LEARN_MORE_POPUP:String = "SHOW_LEARN_MORE_POPUP";
      
      public static const SHOW_LEVEL_UP_POPUP:String = "SHOW_LEVEL_UP_POPUP";
      
      public static const SHOW_REINSTATE_POPUP:String = "SHOW_REINSTATE_POPUP";
      
      public static const SHOW_RESUBSCRIBE_POPUP:String = "SHOW_RESUBSCRIBE_POPUP";
      
      public static const SHOW_PAYMENT_DECLINED_POPUP:String = "SHOW_PAYMENT_DECLINED_POPUP";
      
      public static const SHOW_PS_DECLINED_POPUP:String = "SHOW_PS_DECLINED_POPUP";
      
      public static const SHOW_HEIGHEST_STREAK_RESTORED_POPUP:String = "SHOW_HEIGHEST_STREAK_RESTORED_POPUP";
      
      public static const SHOW_VIP_FRIDAY_SALE_POPUP:String = "SHOW_VIP_FRIDAY_SALE_POPUP";
      
      public static const SHOW_POST_FCBUY_SUBSCRIPTION_POPUP:String = "SHOW_POST_FCBUY_SUBSCRIPTION_POPUP";
      
      public static const TRIAL_SUB_BENEFITS_AUTO:String = "tsBNAUTO";
      
      public static const RESTORED_MOTD_SEEN_FLAG:String = "STREAK_RESTORED_MOTD_SEEN_FLAG_V3";
      
      public static const REVAMP_REWARD_GRANT_FLAG:String = "REVAMP_REWARD_GRANT_FLAG_V3";
      
      public static const TRIAL_RESUB_GRACE_PERIOD:int = 7;
      
      public static const SUBSCRIPTIONS_DATA_FROM_SERVER:String = "subscriptionsData";
      
      public static const MIGRATED_USER:String = "migratedUserSubscriptions";
      
      public static const WEEKLY_DROP_KEY:String = "weeklyDrop";
      
      public static const UNICORN_REWARDS_KEY:String = "unicornDrop";
      
      public static const ONE_TIME_BONUS_KEY:String = "oneTimeSubscriptionsBonus";
      
      public static const REDEEMED_MIGRATION_KEY:String = "redeemedSubscriptionsMigration";
      
      public static const DEFAULT_SUBSCRIPTION_CODE:String = "sub:1";
      
      public static const TRIAL_SUBSCRIPTION_CODE:String = "sub:2";
      
      public static const ONE_TIME_BONUS_FLAG:String = "oneTimeSubscriptionsBonus";
      
      public static const STATS_COUNTER:String = "subs_v2";
      
      public static const TRIAL_SUB_STATS_COUNTER:String = "subs_trial";
      
      public static var DEFAULT_SUBSCRIPTION_RECAPTURE_CODE:String = "sub:recapture";
      
      public static const PENDING_POPUP_DISPLAY_TOTAL_COUNT:Number = 2;
      
      public static const DAYS_REMAINING_TO_POPUP_REINSTAE:Number = 5;
      
      public static const RESUBSCRIBE_POPUP_DISPLAY_TOTAL_COUNT:Number = 6;
      
      public static const RESUBSCRIBE_POPUP_DISPLAY_DAY:Number = 1;
      
      public static const PS_DECLINED_GRACE_PERIOD_DAYS:Number = 14;
      
      public static const PS_DECLINED_POPUP_DISPLAY_TOTAL_COUNT:Number = 2;
      
      public static const PS_DECLINED_POPUP_COOLDOWN_DAYS:Number = 2;
      
      private static var m_instance:SubscriptionsManager = null;
      
      public static const WEEKLY_DROP:int = 0;
      
      public static const BONUS_DROP:int = 1;
      
      public static const REDEEM_DROP:int = 2;
      
      public static const NO_DROP:int = 3;
      
      public static const TOTAL_SUBSCRIPTION_DURATION:String = "totalSubscriptionDuration";
      
      public static const CURRENT_SUBSCRIPTION_DURATION:String = "currentSubscriptionDuration";
      
      public static const LAST_UNICORN_INDEX:String = "lastUnicornIndex";
      
      public static const REWARD_ITEM_SUPER_FERTILIZER:String = "organic_fertilizer_1";
      
      public static const HEIGHEST_KNOWN_STREAK:String = "lastKnownHeighestStreak";
      
      public static const LAST_SUBSCRIPTION_DURATION:String = "lastDuration";
      
      public static const LEVEL_INACTIVE:int = 0;
      
      public static const LEVEL_BRONZE:int = 1;
      
      public static const LEVEL_SILVER:int = 2;
      
      public static const LEVEL_GOLD:int = 3;
      
      public static const LEVEL_RUBY:int = 4;
      
      public static const LEVEL_DIAMOND:int = 5;
      
      public static const STREAK_LEVEL_BRONZE:int = 1;
      
      public static const STREAK_LEVEL_SILVER:int = 2;
      
      public static const STREAK_LEVEL_GOLD:int = 4;
      
      public static const STREAK_LEVEL_RUBY:int = 7;
      
      public static const STREAK_LEVEL_DIAMOND:int = 13;
      
      public static const BRONZE_BENEFIT_MARKET_STALL_CAPACITY:int = 100;
      
      public static const SILVER_BENEFIT_MARKET_STALL_CAPACITY:int = 200;
      
      public static const GOLD_BENEFIT_MARKET_STALL_CAPACITY:int = 500;
      
      public static const RUBY_BENEFIT_MARKET_STALL_CAPACITY:int = 700;
      
      public static const DIAMOND_BENEFIT_MARKET_STALL_CAPACITY:int = 900;
      
      public static const RUBY_LAND_EXPANSIONS_DISCOUNT:int = 5;
      
      public static const PACKAGE_COST_BRONZE:int = 20;
      
      public static const PACKAGE_COST_TRIAL:int = 10;
      
      public static const PACKAGE_COST_SILVER:int = 40;
      
      public static const PACKAGE_COST_GOLD:int = 100;
      
      public static const PACKAGE_COST_RUBY:int = 150;
      
      public static const PACKAGE_COST_DIAMOND:int = 200;
      
      public static const TRIAL_SUBSCRIPTION_PREREQ:String = "trialsub_active";
      
      public static const TRIAL_SUBSCRIPTION_AUTO_POPUP_PREREQ:String = "trialsub_enabled";
      
      public static const START_TS:String = "startTS";
      
      public static const CANCEL_TS:String = "cancelTS";
      
      public static const NUM_TRIAL_DAYS:int = 14;
      
      public static const SUBSCRIPTION_MONTHLY_COST:int = 10;
      
      public static const NEXT_REC_DATE:String = "next_recurring_date";
      
      public function SubscriptionsManager()
      {
         super();
         this.initListeners();
      }
      
      public static function get instance() : SubscriptionsManager
      {
         if(m_instance == null)
         {
            m_instance = new SubscriptionsManager();
         }
         return m_instance;
      }
      
      private static function showSignUpPopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         var sub_type:String = null;
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("sub_type"))
         {
            sub_type = event.data.sub_type;
         }
         if(SubscriptionsManager.instance.isExsubscriber() && SubscriptionsManager.isRevampEAActive())
         {
            UI.displayPopup(new SubscriptionRevampExSignUpWindow());
         }
         else
         {
            UI.displayPopup(new SubscriptionAllBenefitsMOTDWindow());
         }
         if(sub_type == SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE)
         {
            FarmStatsManager.count(TRIAL_SUB_STATS_COUNTER,"sign_up",source,"view");
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,"sign_up",source,"view");
         }
      }
      
      private static function showSignUpConfirmationPopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         SubscriptionsSignUpConfirmation.display(source,triggerSignUpFlow);
         FarmStatsManager.count(STATS_COUNTER,"sign_up_confirmation",source,"view");
      }
      
      private static function showMigrationPopup(event:SubscriptionsEvent) : void
      {
         SubscriptionsMigration.display(logMigrationDialogShown);
         FarmStatsManager.count(STATS_COUNTER,"migration","","view");
      }
      
      private static function showLevelUpPopup(event:SubscriptionsEvent) : void
      {
         SubscriptionsLevelUp.display(null,SubscriptionsManager.instance.getSubscriptionLevel());
         FarmStatsManager.count(STATS_COUNTER,"levelup","","view");
      }
      
      private static function showDropPopup(event:SubscriptionsEvent) : void
      {
         var popup:int = 0;
         if(Boolean(event && event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("popup"))
         {
            popup = int(event.data.popup);
         }
         var amount:int = 0;
         if(Boolean(event && event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("amount"))
         {
            amount = int(event.data.amount);
         }
         var item_amount:int = 0;
         if(Boolean(event && event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("item_amount"))
         {
            item_amount = int(event.data.item_amount);
         }
         if(amount == 0)
         {
            popup = NO_DROP;
         }
         switch(popup)
         {
            case WEEKLY_DROP:
               SubscriptionsWeeklyDrop.display(showUserRewardGrant,amount,item_amount);
               FarmStatsManager.count(STATS_COUNTER,"weekly_drop","","view",amount.toString());
               break;
            case BONUS_DROP:
               SubscriptionsBonusDrop.display(showUserRewardGrant,amount);
               FarmStatsManager.count(STATS_COUNTER,"bonus_drop","","view",amount.toString());
               break;
            case REDEEM_DROP:
               SubscriptionsRedeemV1Drop.display(showUserRewardGrant,amount);
               FarmStatsManager.count(STATS_COUNTER,"redeem_drop","","view",amount.toString());
               break;
            case NO_DROP:
               SubscriptionsNoDrop.display(null);
               FarmStatsManager.count(STATS_COUNTER,"no_drop","","view");
               break;
            default:
               FarmStatsManager.count(STATS_COUNTER,"error","drop_error","view",popup.toString());
         }
      }
      
      private static function showBenefitsPopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            SubscriptionsBenefitsRetention.display(source);
         }
         else
         {
            SubscriptionsBenefits.display(source);
         }
         FarmStatsManager.count(STATS_COUNTER,"benefits",source,"view");
      }
      
      private static function showStreakRestoredPopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         SubscriptionStreakRestoredMOTDWindow.display(source);
      }
      
      private static function showPostFCBuyPopup(event:SubscriptionsEvent) : void
      {
         SubscriptionPostFCBuyMOTDWindow.display();
      }
      
      private static function showTrialSubStartPopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         TrialSubscriptionStart.display(source);
      }
      
      private static function showVipFridaySalePopup(event:SubscriptionsEvent) : void
      {
         SubscriptionWeeklyVIPFridaySale.display();
      }
      
      private static function showPostSignUpCongratsPopup() : void
      {
         SubscriptionPostSignupCongratsWindow.display();
      }
      
      private static function showLearnMorePopup(event:SubscriptionsEvent) : void
      {
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         var previousPopupEventType:String = "none";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("previousPopupEventType"))
         {
            previousPopupEventType = event.data.previousPopupEventType;
         }
         if(Boolean(event.hasOwnProperty("data") && event.data) && Boolean(event.data.hasOwnProperty("isTrial")) && event.data.isTrial == true)
         {
            SubscriptionsLearnMore.display(previousPopupEventType,null,true);
         }
         else
         {
            SubscriptionsLearnMore.display(previousPopupEventType);
         }
         FarmStatsManager.count(STATS_COUNTER,"learnMore",source,"view");
      }
      
      public static function triggerSignUpFlow(source:String = "default") : void
      {
         if(SubscriptionsManager.isTrialSubscriptionActive() || !SubscriptionsManager.instance.isExsubscriber() && SubscriptionsManager.isRevampTrialActive())
         {
            FarmStatsManager.count(TRIAL_SUB_STATS_COUNTER,"trigger","sign_up",source);
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,"trigger","sign_up",source);
         }
      }
      
      public static function triggerPSDeclinedResubscribeFlow(source:String = "default") : void
      {
         FarmStatsManager.count(STATS_COUNTER,"recapture","ps_declined_short_term_2","resubscribe");
      }
      
      public static function triggerConfirmationFlow(source:String = "default") : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SHOW_SIGNUP_CONFIRMATION_POPUP,{"source":source}));
      }
      
      public static function logMigrationDialogShown() : void
      {
         var migrationDialogShownTransaction:TGenericTransaction = new TGenericTransaction("SubscriptionsService","migrationDialogShown",null,null);
         TransactionManager.addTransaction(migrationDialogShownTransaction,true);
      }
      
      public static function showUserRewardGrant(amount:int = 0, source:String = "default", item_amount:int = 0) : void
      {
         var reward:Object = null;
         var item:FarmItem = null;
         FarmStatsManager.count(STATS_COUNTER,source,"","click",amount.toString());
         UserRewardUtil.grantUserReward({
            "type":QuestConstants.REWARD_CASH,
            "value":amount
         });
         switch(SubscriptionsManager.instance.getSubscriptionLevel())
         {
            case LEVEL_GOLD:
               reward = new Object();
               item = null;
               item = Global.farmGameSettingsManager.getFarmItemByName(REWARD_ITEM_SUPER_FERTILIZER);
               if(item != null)
               {
                  reward.type = QuestConstants.REWARD_GRANT_ITEM;
                  reward.value = item.code;
                  reward.quantity = item_amount;
                  UserRewardUtil.grantUserReward(reward);
               }
         }
         if(source == "weekly_drop" || source == "bonus_drop")
         {
            if(Global.vipSalesManager.isEnabled() && Global.vipSalesManager.hasValidOnSaleItems())
            {
               UI.displayMarketDialog(STATS_COUNTER + "_" + source,"sale");
            }
            else if(LimitedSaleUtility.isEligible)
            {
               LimitedSaleUtility.instance().conditionallyOpenSaleDialog();
            }
         }
      }
      
      public static function isActivesubscriber() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && (subscriptionStatus == SUBSCRIPTION_ACTIVE || subscriptionStatus == SUBSCRIPTION_REINSTATE))
         {
            result = true;
         }
         return result;
      }
      
      public static function isRetentionProgramActivated() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUBSCRIPTIONS_V2_RETENTION) == Experiments.VARIANT_SUBSCRIPTIONS_V2_RETENTION)
         {
            result = true;
         }
         return result;
      }
      
      public static function isPendingCancellationMode() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && subscriptionStatus == SUBSCRIPTION_PENDING_CANCEL)
         {
            result = true;
         }
         return result;
      }
      
      public static function isInCancellationMode() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && subscriptionStatus == SUBSCRIPTION_CANCELED)
         {
            result = true;
         }
         return result;
      }
      
      public static function showReinstatePopUp(event:SubscriptionsEvent) : void
      {
         FarmStatsManager.count(STATS_COUNTER,"recapture","pending_cancel","view");
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         SubscriptionReinstateWindow.display(source,triggerSignUpFlow);
      }
      
      public static function showReSubscribePopUP(event:SubscriptionsEvent) : void
      {
         var featureData:Object = null;
         var cancelReason:String = null;
         var cancelTs:int = 0;
         var daysPassed:int = 0;
         var daysPassedTrialEnd:int = 0;
         var source:String = "default";
         if(Boolean(event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("source"))
         {
            source = event.data.source;
         }
         var isPSDeclined:Boolean = false;
         var isTrialSubAutoCancelled:Boolean = false;
         var isTrial:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PSDECLINE_RECAPTURE) == Experiments.VARIANT_PSDECLINE_RECAPTURE)
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_CODE);
            if(featureData == null)
            {
               featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,TRIAL_SUBSCRIPTION_CODE);
               isTrial = true;
            }
            if(featureData)
            {
               cancelReason = featureData.hasOwnProperty("cancelReason") ? featureData["cancelReason"] : "";
               cancelTs = int(featureData["cancelTS"]);
               daysPassed = FarmGameUtil.secondsElapsed(cancelTs) / FarmGameUtil.NUM_SECS_IN_DAY;
               isPSDeclined = cancelReason == "PS_DECLINED" && daysPassed < PS_DECLINED_GRACE_PERIOD_DAYS;
               daysPassedTrialEnd = FarmGameUtil.secondsElapsed(SubscriptionsManager.getTrialEndTS(false)) / FarmGameUtil.NUM_SECS_IN_DAY;
               isTrialSubAutoCancelled = isTrial && cancelReason == "TRIAL_AUTO_CANCEL" && daysPassedTrialEnd < TRIAL_RESUB_GRACE_PERIOD;
            }
         }
      }
      
      public static function showPSDeclinedPopup(event:SubscriptionsEvent) : void
      {
         var source:String = null;
         FarmStatsManager.count(STATS_COUNTER,"recapture","ps_declined_short_term_2","view");
         var successCallback:Function = null;
         if(isInCancellationMode())
         {
            source = SubscriptionsPSDeclinedWindow.NOT_SUBSCRIBED;
            successCallback = triggerPSDeclinedResubscribeFlow;
         }
         else
         {
            source = SubscriptionsPSDeclinedWindow.SUBSCRIBED;
         }
         SubscriptionsPSDeclinedWindow.display(source,successCallback,null);
      }
      
      public static function showPSDeclinedLTPopup(event:SubscriptionsEvent) : void
      {
         FarmStatsManager.count(STATS_COUNTER,"recapture","ps_declined_short_term_2","view");
         var source:String = "ps_declined_lt";
         SubscriptionsPSDeclinedWindow.display(source,triggerPSDeclinedResubscribeFlow,null);
      }
      
      public static function isTrialSubscriptionActive() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(SubscriptionsManager.TRIAL_SUBSCRIPTION_PREREQ);
      }
      
      public static function isTrialSubscriptionAutoPopupActive() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(SubscriptionsManager.TRIAL_SUBSCRIPTION_AUTO_POPUP_PREREQ);
      }
      
      public static function inTrialPeriod(withGracePeriod:Boolean = true) : Boolean
      {
         var result:Boolean = false;
         var endTS:int = SubscriptionsManager.getTrialEndTS(true);
         var nowTS:int = GlobalEngine.serverTime / 1000;
         if(nowTS <= endTS)
         {
            result = true;
         }
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         return result && subscriptionStatus != null && subscriptionStatus != "" && (subscriptionStatus == SubscriptionsManager.SUBSCRIPTION_TRIAL || subscriptionStatus == SubscriptionsManager.SUBSCRIPTION_PENDING_CANCEL);
      }
      
      public static function getTrialEndDate() : String
      {
         var date:Date = null;
         var result:String = null;
         var endTS:Number = getTrialEndTS(false);
         if(endTS > 0)
         {
            date = new Date(Number(endTS * 1000));
            result = (date.getMonth() + 1).toString() + "/" + date.getDate().toString() + "/" + date.getFullYear().toString();
         }
         return result;
      }
      
      public static function getTrialEndTS(withGracePeriod:Boolean = true) : Number
      {
         var startTS:Number = NaN;
         var endTS:Number = 0;
         var subscriptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE);
         if(Boolean(subscriptionData) && Boolean(subscriptionData.hasOwnProperty(SubscriptionsManager.START_TS)) && subscriptionData[SubscriptionsManager.START_TS] > 0)
         {
            if(subscriptionData.hasOwnProperty(SubscriptionsManager.NEXT_REC_DATE) && subscriptionData[SubscriptionsManager.NEXT_REC_DATE] > 0)
            {
               endTS = Number(subscriptionData[SubscriptionsManager.NEXT_REC_DATE]);
            }
            else
            {
               startTS = Number(subscriptionData[SubscriptionsManager.START_TS]);
               endTS = startTS + SubscriptionsManager.NUM_TRIAL_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
            }
         }
         if(endTS > 0 && withGracePeriod)
         {
            endTS += SubscriptionsManager.TRIAL_RESUB_GRACE_PERIOD * FarmGameUtil.NUM_SECS_IN_DAY;
         }
         return endTS;
      }
      
      public static function isRevampEAActive() : Boolean
      {
         var duration:Number = NaN;
         var ret:Boolean = false;
         if(Boolean(m_revampEADuration) && Boolean(m_revampStarttime))
         {
            duration = m_revampEADuration * FarmGameUtil.NUM_SECS_IN_DAY;
            if(GlobalEngine.serverTime / 1000 - m_revampStarttime > 0 && GlobalEngine.serverTime / 1000 - m_revampStarttime < duration)
            {
               ret = true;
            }
         }
         var params:Object = new Object();
         params[PrerequisiteConstants.KEY_TYPE] = PrerequisiteConstants.PREREQUISITE_SUB_REVAMP_EXSUBSCRIBER;
         params[PrerequisiteConstants.KEY_VALUE] = 7;
         return ret && PrerequisiteUtility.isPrerequisiteMet(params);
      }
      
      public static function isRevampTrialActive() : Boolean
      {
         var duration:Number = NaN;
         var ret:Boolean = false;
         if(Boolean(m_revampStarttime) && Boolean(m_revampTrialDuration))
         {
            duration = m_revampTrialDuration * FarmGameUtil.NUM_SECS_IN_DAY;
            if(GlobalEngine.serverTime / 1000 - m_revampStarttime > 0 && GlobalEngine.serverTime / 1000 - m_revampStarttime < duration)
            {
               ret = true;
            }
         }
         return ret && isTrialSignupEnabled();
      }
      
      public static function isTrialSignupEnabled() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getSeenFlag("payer_last_90_days"))
         {
            result = !SubscriptionsManager.instance.isExsubscriber() && !SubscriptionsManager.instance.isSubscriber();
         }
         return result;
      }
      
      public static function getEADaysRemaining() : int
      {
         var endTime:Number = NaN;
         var diff:Number = NaN;
         var days:int = -1;
         if(Boolean(m_revampEADuration) && Boolean(m_revampStarttime))
         {
            endTime = m_revampStarttime + m_revampEADuration * FarmGameUtil.NUM_SECS_IN_DAY;
            diff = endTime - GlobalEngine.serverTime / 1000;
            if(diff > 0 && diff < m_revampEADuration * FarmGameUtil.NUM_SECS_IN_DAY)
            {
               days = Math.round(diff / FarmGameUtil.NUM_SECS_IN_DAY);
            }
         }
         return days;
      }
      
      public static function isEligibleForVIPBenifit() : Boolean
      {
         var result:Boolean = false;
         var data:int = FeatureOptionsManager.getInstance().getFeatureOption("VIP_PROGRAM","VIP") as int;
         if(Boolean(data) && data == 1)
         {
            result = true;
         }
         return result;
      }
      
      public static function enableTileForOneFc() : Boolean
      {
         return true;
      }
      
      public static function getBucketForCurrencyConversion() : int
      {
         var result:int = 0;
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption("VIP_PROGRAM");
         if(Boolean(data) && data.hasOwnProperty("bucket"))
         {
            result = int(data["bucket"]);
         }
         return result;
      }
      
      public function init(data:Object) : void
      {
         var unicorns:Array = null;
         var i:int = 0;
         var fixVal:String = null;
         var amount:int = 0;
         var item_amount:int = 0;
         if(data.hasOwnProperty("hasMigrated"))
         {
            this.dispatchEvent(new SubscriptionsEvent(SHOW_MIGRATION_POPUP));
         }
         if(data.hasOwnProperty("SubRevampStarttime"))
         {
            m_revampStarttime = data["SubRevampStarttime"] as Number;
         }
         if(data.hasOwnProperty("SubRevampEADuration"))
         {
            m_revampEADuration = data["SubRevampEADuration"] as Number;
         }
         if(data.hasOwnProperty("SubRevampTrialSignupDuration"))
         {
            m_revampTrialDuration = data["SubRevampTrialSignupDuration"] as Number;
         }
         if(data.hasOwnProperty(SubscriptionsManager.TRIAL_SUB_BENEFITS_AUTO))
         {
            showPostSignUpCongratsPopup();
            Global.player.setSeenFlag(SubscriptionsManager.TRIAL_SUB_BENEFITS_AUTO,true);
         }
         if(data.hasOwnProperty("activeUnicornDrop"))
         {
            SubscriptionsItemDropManager.getInstance().setActiveIndex(data["activeUnicornDrop"]);
         }
         if(data.hasOwnProperty("rewards") && data["rewards"] != null)
         {
            if(Boolean(data.rewards.hasOwnProperty(REDEEMED_MIGRATION_KEY)) && data.rewards[REDEEMED_MIGRATION_KEY] != null)
            {
               amount = int(data.rewards[REDEEMED_MIGRATION_KEY]);
               this.dispatchEvent(new SubscriptionsEvent(SHOW_DROP_POPUP,{
                  "popup":REDEEM_DROP,
                  "amount":amount
               }));
            }
            if(Boolean(data.rewards.hasOwnProperty(ONE_TIME_BONUS_KEY)) && data.rewards[ONE_TIME_BONUS_KEY] != null)
            {
               amount = int(data.rewards[ONE_TIME_BONUS_KEY]);
               this.dispatchEvent(new SubscriptionsEvent(SHOW_DROP_POPUP,{
                  "popup":BONUS_DROP,
                  "amount":amount
               }));
            }
            if(Boolean(data.rewards.hasOwnProperty(WEEKLY_DROP_KEY)) && data.rewards[WEEKLY_DROP_KEY] != null)
            {
               amount = int(data.rewards[WEEKLY_DROP_KEY]);
               if(Boolean(data.rewards.hasOwnProperty(REWARD_ITEM_SUPER_FERTILIZER)) && data.rewards[REWARD_ITEM_SUPER_FERTILIZER] != null)
               {
                  item_amount = int(data.rewards[REWARD_ITEM_SUPER_FERTILIZER]);
               }
               this.dispatchEvent(new SubscriptionsEvent(SHOW_DROP_POPUP,{
                  "popup":WEEKLY_DROP,
                  "amount":amount,
                  "item_amount":item_amount
               }));
            }
            if(data.rewards.hasOwnProperty(UNICORN_REWARDS_KEY))
            {
               unicorns = data.rewards[UNICORN_REWARDS_KEY];
               if(unicorns)
               {
                  for(i = 0; i < unicorns.length; i++)
                  {
                     Global.player.addGift(unicorns[i],"0",1);
                  }
                  SubscriptionsItemDropManager.getInstance().setEligibileToClaim(true);
               }
            }
         }
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            if(data.hasOwnProperty("showLevelUp") && Boolean(data.showLevelUp))
            {
               this.dispatchEvent(new SubscriptionsEvent(SHOW_LEVEL_UP_POPUP));
            }
         }
         if(data.hasOwnProperty("showVIPFridaySale") && Boolean(data.showVIPFridaySale))
         {
            this.dispatchEvent(new SubscriptionsEvent(SHOW_VIP_FRIDAY_SALE_POPUP));
         }
         if(data.hasOwnProperty("showPostFCBuyPopup") && Boolean(data.showPostFCBuyPopup))
         {
            this.dispatchEvent(new SubscriptionsEvent(SHOW_POST_FCBUY_SUBSCRIPTION_POPUP));
         }
         if(data.hasOwnProperty("psDeclinedFix"))
         {
            fixVal = data.psDeclinedFix;
            this.dispatchEvent(new SubscriptionsEvent(SHOW_PS_DECLINED_POPUP));
         }
         if(data.hasOwnProperty("showTSD"))
         {
            this.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_TRIAL_SUB_START_POPUP,{
               "source":"init",
               "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
            }));
         }
         if(data.hasOwnProperty("showRestoredPopup_V2"))
         {
            this.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_HEIGHEST_STREAK_RESTORED_POPUP,{"source":"init"}));
         }
         if(SubscriptionsManager.isActivesubscriber())
         {
            FeatureOptionsManager.deleteFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_RECAPTURE_CODE);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUBSCRIPTION_RECAPTURE) == 1)
         {
            if(SubscriptionsManager.isPendingCancellationMode() && !SubscriptionsManager.inTrialPeriod(true) && !SubscriptionsManager.isRevampTrialActive() && !SubscriptionsManager.isRevampEAActive())
            {
               this.dispatchEvent(new SubscriptionsEvent(SHOW_REINSTATE_POPUP));
            }
            if(SubscriptionsManager.isInCancellationMode() && !SubscriptionsManager.isRevampTrialActive() && !SubscriptionsManager.isRevampEAActive())
            {
               this.dispatchEvent(new SubscriptionsEvent(SHOW_RESUBSCRIBE_POPUP));
            }
         }
         if(SubscriptionsManager.isTrialSubscriptionAutoPopupActive())
         {
            SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{
               "source":"init",
               "sub_type":TRIAL_SUBSCRIPTION_CODE
            }));
            Global.player.setFeatureLastShown(SubscriptionsSignUp.TRIALSUB_FEATURE_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
            Global.player.incrementActionCount(SubscriptionsSignUp.TRIALSUB_FEATURE_NAME,true);
         }
      }
      
      private function initListeners() : void
      {
         this.addEventListener(SHOW_SIGNUP_POPUP,showSignUpPopup);
         this.addEventListener(SHOW_SIGNUP_CONFIRMATION_POPUP,showSignUpConfirmationPopup);
         this.addEventListener(SHOW_MIGRATION_POPUP,showMigrationPopup);
         this.addEventListener(SHOW_LEARN_MORE_POPUP,showLearnMorePopup);
         this.addEventListener(SHOW_DROP_POPUP,showDropPopup);
         this.addEventListener(SHOW_BENEFITS_POPUP,showBenefitsPopup);
         this.addEventListener(SHOW_LEVEL_UP_POPUP,showLevelUpPopup);
         this.addEventListener(SHOW_REINSTATE_POPUP,showReinstatePopUp);
         this.addEventListener(SHOW_RESUBSCRIBE_POPUP,showReSubscribePopUP);
         this.addEventListener(SHOW_PS_DECLINED_POPUP,showPSDeclinedPopup);
         this.addEventListener(SHOW_TRIAL_SUB_START_POPUP,showTrialSubStartPopup);
         this.addEventListener(SHOW_VIP_FRIDAY_SALE_POPUP,showVipFridaySalePopup);
         this.addEventListener(SHOW_HEIGHEST_STREAK_RESTORED_POPUP,showStreakRestoredPopup);
         this.addEventListener(SHOW_POST_FCBUY_SUBSCRIPTION_POPUP,showPostFCBuyPopup);
      }
      
      public function isSubscriber() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && (subscriptionStatus == SUBSCRIPTION_ACTIVE || subscriptionStatus == SUBSCRIPTION_PENDING_CANCEL || subscriptionStatus == SUBSCRIPTION_REINSTATE || subscriptionStatus == SUBSCRIPTION_TRIAL))
         {
            result = true;
         }
         return result;
      }
      
      public function isExsubscriber() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && subscriptionStatus == SUBSCRIPTION_CANCELED)
         {
            result = true;
         }
         return result;
      }
      
      public function isCancelledRecently(cancelledBefore:int) : Boolean
      {
         var cancelTS:Number = NaN;
         var daysPassed:int = 0;
         var result:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_CODE);
         if(featureData == null)
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS,DEFAULT_SUBSCRIPTION_CODE);
         }
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(CANCEL_TS)) && featureData[CANCEL_TS] > 0)
         {
            cancelTS = Number(featureData[CANCEL_TS]);
            daysPassed = FarmGameUtil.secondsElapsed(cancelTS) / FarmGameUtil.NUM_SECS_IN_DAY;
            if(daysPassed < cancelledBefore)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getMarketStallCapacityBenefit() : int
      {
         var result:int = 0;
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            switch(this.getSubscriptionLevel())
            {
               case LEVEL_BRONZE:
                  result = BRONZE_BENEFIT_MARKET_STALL_CAPACITY;
                  break;
               case LEVEL_SILVER:
                  result = SILVER_BENEFIT_MARKET_STALL_CAPACITY;
                  break;
               case LEVEL_GOLD:
                  result = GOLD_BENEFIT_MARKET_STALL_CAPACITY;
                  break;
               case LEVEL_RUBY:
                  result = RUBY_BENEFIT_MARKET_STALL_CAPACITY;
                  break;
               case LEVEL_DIAMOND:
                  result = DIAMOND_BENEFIT_MARKET_STALL_CAPACITY;
            }
         }
         return result;
      }
      
      public function getSubscriptionLevel(byPassActiveCheck:Boolean = false) : int
      {
         var result:int = 0;
         var streak:int = this.getSubscriptionStreak(byPassActiveCheck);
         if(streak >= STREAK_LEVEL_DIAMOND)
         {
            result = LEVEL_DIAMOND;
         }
         else if(streak >= STREAK_LEVEL_RUBY)
         {
            result = LEVEL_RUBY;
         }
         else if(streak >= STREAK_LEVEL_GOLD)
         {
            result = LEVEL_GOLD;
         }
         else if(streak >= STREAK_LEVEL_SILVER)
         {
            result = LEVEL_SILVER;
         }
         else if(streak >= STREAK_LEVEL_BRONZE)
         {
            result = LEVEL_BRONZE;
         }
         else
         {
            result = LEVEL_INACTIVE;
         }
         return result;
      }
      
      public function getSubscriptionStreak(byPassActiveCheck:Boolean = false) : int
      {
         var featureData:Object = null;
         var currentStreak:int = 0;
         var totalStreak:int = 0;
         var streakModulationCount:int = 0;
         var result:int = 0;
         if(this.isSubscriber() || byPassActiveCheck)
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_CODE);
            if(featureData)
            {
               currentStreak = 0;
               if(featureData.hasOwnProperty(CURRENT_SUBSCRIPTION_DURATION))
               {
                  currentStreak = int(featureData[CURRENT_SUBSCRIPTION_DURATION]);
               }
               totalStreak = 0;
               if(featureData.hasOwnProperty(TOTAL_SUBSCRIPTION_DURATION))
               {
                  totalStreak = int(featureData[TOTAL_SUBSCRIPTION_DURATION]);
               }
               streakModulationCount = 0;
               if(currentStreak > 0 && totalStreak > 0)
               {
                  if(currentStreak == totalStreak)
                  {
                     if(Global.player.getSeenFlag(MIGRATED_USER))
                     {
                     }
                  }
               }
               result = currentStreak + streakModulationCount;
            }
         }
         return result;
      }
      
      public function getHeighestStreak() : int
      {
         var featureData:Object = null;
         var result:int = 0;
         if(this.isExsubscriber())
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_CODE);
            if(featureData)
            {
               if(featureData.hasOwnProperty(HEIGHEST_KNOWN_STREAK))
               {
                  result = int(featureData[HEIGHEST_KNOWN_STREAK]);
               }
               else if(featureData.hasOwnProperty(LAST_SUBSCRIPTION_DURATION))
               {
                  result = int(featureData[LAST_SUBSCRIPTION_DURATION]);
               }
            }
         }
         return result;
      }
      
      public function getHeighestSubscriptionLevel() : int
      {
         var result:int = 0;
         var streak:int = this.getHeighestStreak();
         if(streak >= STREAK_LEVEL_DIAMOND)
         {
            result = LEVEL_DIAMOND;
         }
         else if(streak >= STREAK_LEVEL_RUBY)
         {
            result = LEVEL_RUBY;
         }
         else if(streak >= STREAK_LEVEL_GOLD)
         {
            result = LEVEL_GOLD;
         }
         else if(streak >= STREAK_LEVEL_SILVER)
         {
            result = LEVEL_SILVER;
         }
         else if(streak >= STREAK_LEVEL_BRONZE)
         {
            result = LEVEL_BRONZE;
         }
         else
         {
            result = LEVEL_INACTIVE;
         }
         return result;
      }
      
      public function getSubscriptionLevelText(subLevel:int) : String
      {
         var subLevelString:String = "Inactive";
         switch(subLevel)
         {
            case SubscriptionsManager.LEVEL_DIAMOND:
               subLevelString = ZLocUtils.t("Dialogs","subsRet_level_diamond");
               break;
            case SubscriptionsManager.LEVEL_RUBY:
               subLevelString = ZLocUtils.t("Dialogs","subs_level_ruby");
               break;
            case SubscriptionsManager.LEVEL_GOLD:
               subLevelString = ZLocUtils.t("Dialogs","subs_level_gold");
               break;
            case SubscriptionsManager.LEVEL_SILVER:
               subLevelString = ZLocUtils.t("Dialogs","subs_level_silver");
               break;
            case SubscriptionsManager.LEVEL_BRONZE:
               subLevelString = ZLocUtils.t("Dialogs","subs_level_bronze");
         }
         return subLevelString;
      }
      
      public function getLastUnicornDrop() : Number
      {
         var result:Number = -1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,DEFAULT_SUBSCRIPTION_CODE);
         if(featureData)
         {
            if(featureData.hasOwnProperty(LAST_UNICORN_INDEX))
            {
               result = featureData[LAST_UNICORN_INDEX] as Number;
            }
         }
         return result;
      }
      
      public function getVehicleActionSize() : IntVector2
      {
         var subscriptionLevel:int = 0;
         var result:IntVector2 = null;
         if(this.isSubscriber())
         {
            subscriptionLevel = this.getSubscriptionLevel();
            switch(subscriptionLevel)
            {
               case LEVEL_BRONZE:
               case LEVEL_SILVER:
                  result = new IntVector2(3,3);
                  break;
               case LEVEL_GOLD:
               case LEVEL_RUBY:
                  result = new IntVector2(4,4);
                  break;
               case LEVEL_DIAMOND:
                  result = new IntVector2(5,5);
            }
         }
         return result;
      }
   }
}

