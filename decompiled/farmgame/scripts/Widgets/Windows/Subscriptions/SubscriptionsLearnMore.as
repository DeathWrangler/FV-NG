package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsLearnMore extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_LearnMore_v1.swf";
      
      private static const ASSET_TRIAL_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_LearnMore_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      private var m_isTrial:Boolean;
      
      private var m_previousPopupEventType:String;
      
      public function SubscriptionsLearnMore(dialogAsset:String, previousPopupEventType:String = "none", callBack:Function = null, isTrial:Boolean = false)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_previousPopupEventType = previousPopupEventType;
         this.m_isTrial = isTrial;
      }
      
      public static function display(previousPopupEventType:String = "none", callBack:Function = null, isTrial:Boolean = false) : void
      {
         var popUp:SubscriptionsLearnMore = null;
         if(isTrial)
         {
            popUp = new SubscriptionsLearnMore(ASSET_TRIAL_NAME,previousPopupEventType,callBack,isTrial);
         }
         else
         {
            popUp = new SubscriptionsLearnMore(ASSET_NAME,previousPopupEventType,callBack,isTrial);
         }
         UI.displayPopup(popUp,false,"",false,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(m_closeButton = new FarmButton(m_window.bt_close,this.onCloseButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsLearnMoreTitle")),true);
         if(this.m_isTrial)
         {
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"TrialSubscriptionsLearnMoreBody")),true);
         }
         else
         {
            addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsLearnMoreBody")),true);
         }
      }
      
      private function onCloseButtonClicked(event:Event) : void
      {
         if(this.m_previousPopupEventType != "none")
         {
            if(this.m_isTrial)
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(this.m_previousPopupEventType,{
                  "source":"learn_more",
                  "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
               }));
            }
            else
            {
               SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(this.m_previousPopupEventType,{"source":"learn_more"}));
            }
         }
         if(this.m_callBack != null)
         {
            this.m_callBack();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_callBack = null;
         this.m_okButton = null;
         super.release();
      }
   }
}

