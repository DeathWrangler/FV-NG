package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TrialSubscriptionStart extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_SignUp_TrialOver.swf";
      
      public function TrialSubscriptionStart()
      {
         super(ASSET_NAME);
      }
      
      public static function display(source:String = "default") : void
      {
         var popUp:TrialSubscriptionStart = new TrialSubscriptionStart();
         UI.displayPopup(popUp);
         FarmStatsManager.count(SubscriptionsManager.TRIAL_SUB_STATS_COUNTER,"trial_sub_start_sec_drop_popup",source,"view");
      }
      
      override protected function postLoadComplete() : void
      {
         var trail_mc:MovieClip = null;
         var learnMoreBtn:ZwButton = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("try_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.try_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subStartYesButton"),this.onOkButtonClicked),true);
         }
         if(m_window.hasOwnProperty("bt_close"))
         {
            addWidget(m_closeButton = new FarmButton(m_window.bt_close,this.onCloseButtonClicked),true);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialTitle_start")),true);
         }
         if(m_window.hasOwnProperty("subtitle_1_tf"))
         {
            addWidget(new FarmTextField(m_window.subtitle_1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialSubTitle_start")),true);
         }
         var trialEndDate:String = SubscriptionsManager.getTrialEndDate();
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialSubTitle_body",{
               "prize":SubscriptionsManager.SUBSCRIPTION_MONTHLY_COST,
               "date":trialEndDate
            })),true);
         }
         if(m_window.hasOwnProperty("body1_tf"))
         {
            addWidget(new FarmTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialSubTitle_body_1",{"prize":SubscriptionsManager.SUBSCRIPTION_MONTHLY_COST})),true);
         }
         if(m_window.hasOwnProperty("bronzevalue_tf"))
         {
            addWidget(new FarmTextField(m_window.bronzevalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_bronz")),true);
         }
         if(m_window.hasOwnProperty("silvervalue_tf"))
         {
            addWidget(new FarmTextField(m_window.silvervalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_silver")),true);
         }
         if(m_window.hasOwnProperty("goldvalue_tf"))
         {
            addWidget(new FarmTextField(m_window.goldvalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_gold")),true);
         }
         if(m_window.hasOwnProperty("rubyvalue_tf"))
         {
            addWidget(new FarmTextField(m_window.rubyvalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_ruby")),true);
         }
         if(m_window.hasOwnProperty("trial_mc"))
         {
            trail_mc = m_window.trial_mc as MovieClip;
            trail_mc.visible = true;
         }
         if(m_window.hasOwnProperty("learrmore_mc"))
         {
            learnMoreBtn = new ZwButton(m_window.learrmore_mc,this.onLearnMoreClicked);
            addWidget(learnMoreBtn,true);
            learnMoreBtn.toggleClickableButton(true);
         }
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function onCloseButtonClicked(event:Event) : void
      {
         super.onClose(event);
      }
      
      public function onLearnMoreClicked(event:MouseEvent) : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_LEARN_MORE_POPUP,{
            "source":"sign_up_popup" + "trial_sub_start",
            "previousPopupEventType":SubscriptionsManager.SHOW_SIGNUP_POPUP,
            "isTrial":true
         }));
         super.close();
      }
   }
}

