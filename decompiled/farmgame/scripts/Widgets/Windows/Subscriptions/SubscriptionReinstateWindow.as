package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriptionReinstateWindow extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_Subscription_PendingCancel.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_successCallBack:Function;
      
      private var m_failureCallBack:Function;
      
      private var m_source:String;
      
      public function SubscriptionReinstateWindow(dialogAsset:String, source:String = "default", successCallBack:Function = null, failureCallBack:Function = null)
      {
         super(dialogAsset);
         this.m_successCallBack = successCallBack;
         this.m_failureCallBack = failureCallBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", successCallBack:Function = null, failureCallBack:Function = null) : void
      {
         var popUp:SubscriptionReinstateWindow = null;
         var remainingDays:int = getDaysRemainingInCancellation();
         if(getSeenCount() < SubscriptionsManager.PENDING_POPUP_DISPLAY_TOTAL_COUNT && getHrsDifferenceSinceLastSeen() > 24 && remainingDays <= SubscriptionsManager.DAYS_REMAINING_TO_POPUP_REINSTAE && remainingDays > 0)
         {
            popUp = new SubscriptionReinstateWindow(ASSET_NAME,source,successCallBack,failureCallBack);
            UI.displayPopup(popUp);
         }
      }
      
      public static function getHrsDifferenceSinceLastSeen() : Number
      {
         var mydata:Object = null;
         var lastSeen:Number = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_RECAPTURE_CODE);
         if(Boolean(featureData) && featureData.hasOwnProperty("reinstate"))
         {
            mydata = featureData["reinstate"];
            if(Boolean(mydata) && mydata.hasOwnProperty("lastSeen"))
            {
               lastSeen = mydata["lastSeen"] as Number;
            }
         }
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         return (currentTime - lastSeen) / (60 * 60);
      }
      
      public static function getSeenCount() : Number
      {
         var mydata:Object = null;
         var seenCount:Number = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_RECAPTURE_CODE);
         if(Boolean(featureData) && featureData.hasOwnProperty("reinstate"))
         {
            mydata = featureData["reinstate"];
            if(Boolean(mydata) && mydata.hasOwnProperty("seenCount"))
            {
               seenCount = mydata["seenCount"] as Number;
            }
         }
         return seenCount;
      }
      
      public static function getDaysRemainingInCancellation() : int
      {
         var lastRenewalTS:Number = NaN;
         var lastRenewalDate:Date = null;
         var Day:Number = NaN;
         var Month:Number = NaN;
         var Year:Number = NaN;
         var Hours:Number = NaN;
         var Minutes:Number = NaN;
         var nextRenewalDate:Date = null;
         var nextRenewalTS:Number = NaN;
         var theDate:String = null;
         var currentTime:Number = NaN;
         var difftime:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_CODE);
         if(featureData)
         {
            lastRenewalTS = 0;
            if(featureData.hasOwnProperty("lastRenewalTS"))
            {
               lastRenewalTS = Number(featureData["lastRenewalTS"]);
               lastRenewalDate = new Date(lastRenewalTS * 1000);
               Day = lastRenewalDate.getDate();
               Month = lastRenewalDate.getMonth() + 1;
               Year = lastRenewalDate.getFullYear();
               Hours = lastRenewalDate.getHours();
               Minutes = lastRenewalDate.getMinutes();
               nextRenewalDate = new Date(Year,Month,Day,Hours,Minutes);
               nextRenewalTS = Math.round(nextRenewalDate.getTime() / 1000);
               theDate = Month + "/" + Day + "/" + Year + "  " + Hours + " : " + Minutes;
               currentTime = GlobalEngine.serverTime / 1000;
               return int((nextRenewalTS - currentTime) / (24 * 60 * 60));
            }
         }
         return -1;
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         FarmStatsManager.count(SubscriptionsManager.STATS_COUNTER,"recapture","pending_cancel","resubscribe");
         this.updateSeenCountAndSeenTime();
         if(this.m_successCallBack != null)
         {
            this.m_successCallBack(this.m_source);
         }
         super.onClose(event);
      }
      
      private function onCloseButtonClicked(event:Event) : void
      {
         if(this.m_failureCallBack != null)
         {
            this.m_failureCallBack(this.m_source);
         }
         this.updateSeenCountAndSeenTime();
         super.onClose(event);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_staysubscribe"),this.onOkButtonClicked),true);
         addWidget(m_closeButton = new FarmButton(m_window.close_btn,this.onCloseButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpTitle")),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsReinstateSubTitle")),true);
         addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsReinstateBody")),true);
         addWidget(new FarmTextField(m_window.price_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_packagepriceText")),true);
         this.addBenefitsText();
         (m_window.package_mc as MovieClip).visible = true;
         addWidget(new FarmTextField(m_window.package_mc.deal_tf,this.getPackageText(),true));
         var learnMoreBtn:ZwButton = new ZwButton(m_window.learnmore_mc,this.onLearnMoreClicked);
         addWidget(learnMoreBtn,true);
         learnMoreBtn.toggleClickableButton(true);
         (m_window.learnmore_mc as MovieClip).buttonMode = true;
         (m_window.learnmore_mc as MovieClip).useHandCursor = true;
      }
      
      private function addBenefitsText() : void
      {
         var subscriptionLevel:int = SubscriptionsManager.instance.getSubscriptionLevel();
         if(subscriptionLevel == SubscriptionsManager.LEVEL_GOLD)
         {
            addWidget(new FarmTextField(m_window.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsReinstateSubTitle2Gold")),true);
         }
         else if(subscriptionLevel == SubscriptionsManager.LEVEL_SILVER)
         {
            addWidget(new FarmTextField(m_window.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsReinstateSubTitle2Silver")),true);
         }
         else if(subscriptionLevel == SubscriptionsManager.LEVEL_BRONZE)
         {
            addWidget(new FarmTextField(m_window.subtitlebronze_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsReinstateSubTitle2Bronze")),true);
         }
      }
      
      private function getPackageText() : String
      {
         var text:String = "";
         var subscriptionLevel:int = SubscriptionsManager.instance.getSubscriptionLevel();
         if(subscriptionLevel == SubscriptionsManager.LEVEL_GOLD)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_packageworthGold");
         }
         else if(subscriptionLevel == SubscriptionsManager.LEVEL_SILVER)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_packageworthSilver");
         }
         else if(subscriptionLevel == SubscriptionsManager.LEVEL_BRONZE)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_packageworthBronze");
         }
         return text;
      }
      
      public function onLearnMoreClicked(event:MouseEvent) : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_LEARN_MORE_POPUP,{
            "source":"sign_up_popup" + this.m_source,
            "previousPopupEventType":SubscriptionsManager.SHOW_REINSTATE_POPUP
         }));
         super.close();
      }
      
      public function updateSeenCountAndSeenTime() : void
      {
         var objData:Object = null;
         var seenCount:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_RECAPTURE_CODE);
         if(featureData)
         {
            if(featureData.hasOwnProperty("reinstate"))
            {
               objData = featureData["reinstate"];
               if(Boolean(objData) && objData.hasOwnProperty("seenCount"))
               {
                  seenCount = int(objData["seenCount"]);
               }
            }
         }
         seenCount++;
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         var packagesArray:Array = new Array();
         var packageObj:Object = {
            "seenCount":seenCount,
            "lastSeen":currentTime
         };
         packagesArray["reinstate"] = packageObj;
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_RECAPTURE_CODE,packagesArray);
         FeatureOptionsManager.getInstance().saveSingleFeature(FeatureOptionsManager.SUBSCRIPTIONS_V2,SubscriptionsManager.DEFAULT_SUBSCRIPTION_RECAPTURE_CODE);
      }
   }
}

