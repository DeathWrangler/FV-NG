package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriptionsSignUp extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_SignUp_v1.swf";
      
      private static const ASSET_TRIAL_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_SignUp_trial.swf";
      
      public static const TRIALSUB_FEATURE_NAME:String = "TSW";
      
      private static var m_isTrialSubSurfacing:Boolean = false;
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_successCallBack:Function;
      
      private var m_failureCallBack:Function;
      
      private var m_source:String;
      
      public function SubscriptionsSignUp(dialogAsset:String, source:String = "default", successCallBack:Function = null, failureCallBack:Function = null)
      {
         super(dialogAsset);
         this.m_successCallBack = successCallBack;
         this.m_failureCallBack = failureCallBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", successCallBack:Function = null, failureCallBack:Function = null, sub_type:String = null) : void
      {
         var popUp:SubscriptionsSignUp = null;
         var assetName:String = ASSET_NAME;
         if(Boolean(sub_type) && sub_type == SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE)
         {
            assetName = ASSET_TRIAL_NAME;
            m_isTrialSubSurfacing = true;
         }
         popUp = new SubscriptionsSignUp(assetName,source,successCallBack,failureCallBack);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         var trail_mc:MovieClip = null;
         var showBonusMC:Boolean = false;
         super.postLoadComplete();
         if(m_isTrialSubSurfacing)
         {
            addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.try_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"trialsubSignUpYesButton"),this.onOkButtonClicked),true);
            addWidget(m_closeButton = new FarmButton(m_window.bt_close,this.onCloseButtonClicked),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialTitle")),true);
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialSubTitle")),true);
            addWidget(new FarmTextField(m_window.subtitle_1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialSubTitle_1")),true);
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpBody")),true);
            addWidget(new FarmTextField(m_window.bronzevalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_bronz")),true);
            addWidget(new FarmTextField(m_window.silvervalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_silver")),true);
            addWidget(new FarmTextField(m_window.goldvalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_gold")),true);
            addWidget(new FarmTextField(m_window.rubyvalue_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vipTrialText_ruby")),true);
            if(m_window.hasOwnProperty("trial_mc"))
            {
               trail_mc = m_window.trial_mc as MovieClip;
               trail_mc.visible = true;
            }
         }
         else
         {
            addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpYesButton"),this.onOkButtonClicked),true);
            addWidget(m_closeButton = new FarmButton(m_window.bt_close,this.onCloseButtonClicked),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpTitle")),true);
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpSubtitle")),true);
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpBody")),true);
            addWidget(new FarmTextField(m_window.bannerdiscount_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpBanner")),true);
            showBonusMC = !Global.player.getSeenFlag(SubscriptionsManager.ONE_TIME_BONUS_FLAG);
            addWidget(new FarmTextField(m_window.mc_bonus.bonus_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpBonus")),true);
            (m_window.mc_bonus as MovieClip).visible = showBonusMC;
         }
         var learnMoreBtn:ZwButton = new ZwButton(m_window.learrmore_mc,this.onLearnMoreClicked);
         addWidget(learnMoreBtn,true);
         learnMoreBtn.toggleClickableButton(true);
         (m_window.learrmore_mc as MovieClip).buttonMode = true;
         (m_window.learrmore_mc as MovieClip).useHandCursor = true;
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
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
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         if(m_window.hasOwnProperty("learrmore_mc"))
         {
            (m_window.learrmore_mc as MovieClip).removeEventListener(MouseEvent.CLICK,this.onLearnMoreClicked);
         }
         this.m_successCallBack = null;
         this.m_failureCallBack = null;
         this.m_okButton = null;
         super.release();
      }
      
      public function onLearnMoreClicked(event:MouseEvent) : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_LEARN_MORE_POPUP,{
            "source":"sign_up_popup" + this.m_source,
            "previousPopupEventType":SubscriptionsManager.SHOW_SIGNUP_POPUP,
            "isTrial":m_isTrialSubSurfacing
         }));
         super.close();
      }
   }
}

