package Widgets.Windows.MOTD
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.BuyFromFeedsManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class BuyFromFeedsOfferWindow extends CustomWindowMOTDBase
   {
      
      private static const MAIN_UI_ASSET_PATH:String = "assets/dialogs/FV_BuyFromFeeds_share.swf";
      
      public static const UPDATE_LOOP_DELAY:Number = 50;
      
      private static var m_instance:BuyFromFeedsOfferWindow = null;
      
      private var m_updateTimer:Timer = null;
      
      private var m_offerLengthSeconds:int;
      
      private var m_totalElapsedTimeMSec:int = 0;
      
      private var m_lastGetTimerTime:int = 0;
      
      private var m_timeLeftSecs:int = 0;
      
      private var m_timeLeftHourFirstDigit:ZwTextField = null;
      
      private var m_timeLeftHourSecondDigit:ZwTextField = null;
      
      private var m_timeLeftMinuteFirstDigit:ZwTextField = null;
      
      private var m_timeLeftMinuteSecondDigit:ZwTextField = null;
      
      private var m_timeLeftSecondFirstDigit:ZwTextField = null;
      
      private var m_timeLeftSecondSecondDigit:ZwTextField = null;
      
      private var m_numSharesRequired:int = 0;
      
      private var m_shareTextField:ZwTextField = null;
      
      private var m_offerRewardItem:FarmItem = null;
      
      private var m_postingThrottleSeconds:int = 0;
      
      private var m_hasSetSharedTextToExpired:Boolean = false;
      
      private var m_shareButton:FarmAnimatedTextButton = null;
      
      public function BuyFromFeedsOfferWindow()
      {
         super(MAIN_UI_ASSET_PATH);
         this.m_offerLengthSeconds = BuyFromFeedsManager.getCurrentOfferLengthSeconds();
         this.m_numSharesRequired = BuyFromFeedsManager.getCurrentOfferNumSharesRequired();
         this.m_offerRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(BuyFromFeedsManager.getCurrentOfferFriendRewardItemCode());
         this.m_postingThrottleSeconds = BuyFromFeedsManager.getCurrentOfferPostingThrottleSeconds();
         m_currentMOTD = {"motdSeenFlag":BuyFromFeedsManager.MOTD_NAME};
      }
      
      public static function get instance() : BuyFromFeedsOfferWindow
      {
         if(m_instance == null)
         {
            m_instance = new BuyFromFeedsOfferWindow();
         }
         return m_instance;
      }
      
      public static function show() : void
      {
         UI.displayPopup(instance,false,BuyFromFeedsManager.BUY_FROM_FEEDS_FEATURE_NAME,true);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window)
         {
            this.m_timeLeftHourFirstDigit = this.addWidget(new ZwTextField(m_window.timer1_tf)) as ZwTextField;
            this.m_timeLeftHourSecondDigit = this.addWidget(new ZwTextField(m_window.timer2_tf)) as ZwTextField;
            this.m_timeLeftMinuteFirstDigit = this.addWidget(new ZwTextField(m_window.timer3_tf)) as ZwTextField;
            this.m_timeLeftMinuteSecondDigit = this.addWidget(new ZwTextField(m_window.timer4_tf)) as ZwTextField;
            this.m_timeLeftSecondFirstDigit = this.addWidget(new ZwTextField(m_window.timer5_tf)) as ZwTextField;
            this.m_timeLeftSecondSecondDigit = this.addWidget(new ZwTextField(m_window.timer6_tf)) as ZwTextField;
            this.addWidget(new ObjectPreviewFrame(m_window.icon_mc,this.m_offerRewardItem,null,[3],null,"","",null,new Point(0,-30)));
            this.m_shareTextField = this.addWidget(new ZwTextField(m_window.share_tf,ZLocUtils.t("Dialogs","buy_from_feedsMainUI_shareText",{"shareThrottle":BuyFromFeedsManager.getCurrentOfferPostingThrottleSeconds() / FarmGameUtil.NUM_SECS_IN_HOUR}))) as ZwTextField;
            this.addWidget(new ZwTextField(m_window.friends_tf,ZLocUtils.t("Dialogs","buy_from_feedsMainUI_friendsText")));
            this.addWidget(new ZwTextField(m_window.itemShareNumber_tf,BuyFromFeedsManager.getCurrentOfferFeatureOptionNumFriendsClicked() + "/" + this.m_numSharesRequired));
            this.addWidget(new ZwTextField(m_window.bubblebody_tf,ZLocUtils.t("Dialogs","buy_from_feedsMainUI_bubbleBody",{"numSharesRequired":BuyFromFeedsManager.getCurrentOfferNumSharesRequired()})));
            this.m_shareButton = this.addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","shareGeneric"),this.onShareButtonClicked)) as FarmAnimatedTextButton;
            this.startUpdateTimer();
            this.updateTimeLeft();
            if(BuyFromFeedsManager.getCurrentOfferFeatureOptionLastPostedTime() > 0 || this.m_timeLeftSecs <= 0)
            {
               this.m_shareButton.enabled = false;
            }
            FarmStatsManager.count(BuyFromFeedsManager.STATS_COUNTER,StatsTrackingConstants.INGAME_DIALOG,StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      private function startUpdateTimer() : void
      {
         var bffFeatureOption:Object = null;
         if(this.m_updateTimer == null)
         {
            this.m_updateTimer = new Timer(UPDATE_LOOP_DELAY);
            this.m_updateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimer);
            this.m_updateTimer.start();
            this.m_lastGetTimerTime = getTimer();
            bffFeatureOption = BuyFromFeedsManager.getCurrentOfferFeatureOption();
            if(bffFeatureOption != null && bffFeatureOption.hasOwnProperty("firstInteractedTime"))
            {
               this.m_totalElapsedTimeMSec = GlobalEngine.serverTime - bffFeatureOption.firstInteractedTime * FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
            else
            {
               TransactionManager.addTransaction(new TGenericTransaction("BuyFromFeedsService","onFirstInteracted",this.onFirstInteracted));
               this.m_totalElapsedTimeMSec = 0;
            }
         }
      }
      
      private function onFirstInteracted(result:Object) : void
      {
         if(result.hasOwnProperty("featureOption"))
         {
            BuyFromFeedsManager.setCurrentOfferFeatureOption(result.featureOption);
         }
      }
      
      private function onUpdateTimer(event:Event) : void
      {
         this.updateTimeLeft();
         this.checkForOfferOver();
         this.checkCanPostAgain();
      }
      
      private function checkCanPostAgain() : void
      {
         var lastPostedTimeSeconds:Number = NaN;
         var timePassed:Number = NaN;
         if(this.m_shareButton != null && this.m_shareButton.enabled == false && this.m_timeLeftSecs > 0)
         {
            lastPostedTimeSeconds = BuyFromFeedsManager.getCurrentOfferFeatureOptionLastPostedTime();
            timePassed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastPostedTimeSeconds;
            if(timePassed >= this.m_postingThrottleSeconds && lastPostedTimeSeconds > 0)
            {
               this.m_shareButton.enabled = true;
            }
         }
      }
      
      private function updateTimeLeft() : void
      {
         var currentGetTimerTime:int = getTimer();
         this.m_totalElapsedTimeMSec += currentGetTimerTime - this.m_lastGetTimerTime;
         this.m_lastGetTimerTime = currentGetTimerTime;
         this.m_timeLeftSecs = this.m_offerLengthSeconds - this.m_totalElapsedTimeMSec / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_timeLeftSecs < 0)
         {
            this.m_timeLeftSecs = 0;
         }
         else if(!this.m_hasSetSharedTextToExpired && this.m_shareButton != null && this.m_shareButton.enabled == false && this.m_timeLeftSecs < BuyFromFeedsManager.getCurrentOfferPostingThrottleSeconds())
         {
            this.m_shareTextField.text = ZLocUtils.t("Dialogs","buy_from_feedsMainUI_shareTextExpired");
            this.m_hasSetSharedTextToExpired = true;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(this.m_timeLeftSecs);
         var numDaysAsHours:int = timeLeftArray[0] * FarmGameUtil.NUM_HOURS_IN_DAY;
         var numHoursLeftString:String = int(numDaysAsHours + timeLeftArray[1]).toString();
         if(numHoursLeftString.length > 1)
         {
            this.m_timeLeftHourFirstDigit.text = numHoursLeftString.charAt(0);
            this.m_timeLeftHourSecondDigit.text = numHoursLeftString.charAt(1);
         }
         else
         {
            this.m_timeLeftHourFirstDigit.text = "0";
            this.m_timeLeftHourSecondDigit.text = numHoursLeftString.charAt(0);
         }
         var numMinutesLeftString:String = int(timeLeftArray[2]).toString();
         if(numMinutesLeftString.length > 1)
         {
            this.m_timeLeftMinuteFirstDigit.text = numMinutesLeftString.charAt(0);
            this.m_timeLeftMinuteSecondDigit.text = numMinutesLeftString.charAt(1);
         }
         else
         {
            this.m_timeLeftMinuteFirstDigit.text = "0";
            this.m_timeLeftMinuteSecondDigit.text = numMinutesLeftString.charAt(0);
         }
         var numSecondsLeftString:String = int(timeLeftArray[3]).toString();
         if(numSecondsLeftString.length > 1)
         {
            this.m_timeLeftSecondFirstDigit.text = numSecondsLeftString.charAt(0);
            this.m_timeLeftSecondSecondDigit.text = numSecondsLeftString.charAt(1);
         }
         else
         {
            this.m_timeLeftSecondFirstDigit.text = "0";
            this.m_timeLeftSecondSecondDigit.text = numSecondsLeftString.charAt(0);
         }
      }
      
      private function checkForOfferOver() : void
      {
         if(this.m_timeLeftSecs <= 0)
         {
            this.m_timeLeftSecs = 0;
            this.m_updateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimer);
            this.m_updateTimer.stop();
            if(this.m_shareButton)
            {
               this.m_shareButton.enabled = false;
            }
            this.m_shareTextField.text = ZLocUtils.t("Dialogs","buy_from_feedsMainUI_shareTextExpired");
            BuyFromFeedsManager.setCurrentOfferExpired();
            Global.hud.rightSideIconQueue.removeIconByName("buyFromFeeds");
         }
      }
      
      private function onShareButtonClicked(event:Event) : void
      {
         if(this.m_shareButton != null)
         {
            this.m_shareButton.enabled = false;
         }
         TransactionManager.addTransaction(new TGenericTransaction("BuyFromFeedsService","postOffer",this.onCompleteAskForTransaction));
         FarmStatsManager.count(BuyFromFeedsManager.STATS_COUNTER,StatsTrackingConstants.INGAME_DIALOG,StatsTrackingConstants.CLICK_SHARE);
      }
      
      private function onCompleteAskForTransaction(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = new Object();
         }
         result.postSuccessful = success;
         if(success)
         {
            BuyFromFeedsManager.setLastPostedTime(GlobalEngine.serverTime);
            if(this.m_shareButton != null)
            {
               this.m_shareButton.enabled = false;
            }
         }
         else if(this.m_shareButton != null)
         {
            this.m_shareButton.enabled = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(BuyFromFeedsManager.STATS_COUNTER,StatsTrackingConstants.INGAME_DIALOG,StatsTrackingConstants.CLOSE);
         this.m_updateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimer);
         m_instance = null;
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_shareButton = null;
         m_instance = null;
         this.m_updateTimer = null;
         this.m_timeLeftHourFirstDigit = null;
         this.m_timeLeftHourSecondDigit = null;
         this.m_timeLeftMinuteFirstDigit = null;
         this.m_timeLeftMinuteSecondDigit = null;
         this.m_timeLeftSecondFirstDigit = null;
         this.m_timeLeftSecondSecondDigit = null;
         this.m_shareTextField = null;
         this.m_offerRewardItem = null;
         super.release();
      }
   }
}

