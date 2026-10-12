package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriptionsBenefits extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Benefits_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      private var m_source:String;
      
      public function SubscriptionsBenefits(dialogAsset:String, source:String = "default", callBack:Function = null)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", callBack:Function = null) : void
      {
         var popUp:SubscriptionsBenefits = null;
         popUp = new SubscriptionsBenefits(ASSET_NAME,source,callBack);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(SubscriptionsManager.inTrialPeriod())
         {
            if(Boolean(m_window) && m_window.hasOwnProperty("bebronze_tf"))
            {
               addWidget(new FarmTextField(m_window.bebronze_tf,"Free Trial"),true);
            }
            addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tSubscriptionsMigrationPopupYesButton"),this.onOkButtonClicked),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tsubscriptionsBenefitsTitle")),true);
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tsubscriptionsBenefitsBody")),true);
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tsubscriptionsBenefitsSubtitle")),true);
         }
         else
         {
            addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsMigrationPopupYesButton"),this.onOkButtonClicked),true);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsBenefitsTitle")),true);
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsBenefitsBody")),true);
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsBenefitsSubtitle")),true);
         }
         var learnMoreBtn:ZwButton = new ZwButton(m_window.learrmore_mc,this.onLearnMoreClicked);
         addWidget(learnMoreBtn,true);
         learnMoreBtn.toggleClickableButton(true);
         (m_window.learrmore_mc as MovieClip).buttonMode = true;
         (m_window.learrmore_mc as MovieClip).useHandCursor = true;
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         (m_window.learrmore_mc as MovieClip).removeEventListener(MouseEvent.CLICK,this.onLearnMoreClicked);
         this.m_callBack = null;
         this.m_okButton = null;
         super.release();
      }
      
      public function onLearnMoreClicked(event:MouseEvent) : void
      {
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_LEARN_MORE_POPUP,{
            "source":this.m_source,
            "previousPopupEventType":SubscriptionsManager.SHOW_BENEFITS_POPUP,
            "isTrial":SubscriptionsManager.inTrialPeriod()
         }));
         super.close();
      }
   }
}

