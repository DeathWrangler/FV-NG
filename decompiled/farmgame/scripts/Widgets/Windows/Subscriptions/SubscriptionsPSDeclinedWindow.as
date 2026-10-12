package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsPSDeclinedWindow extends FarmWindow
   {
      
      public static const SUBSCRIBED:String = "subscribed";
      
      public static const NOT_SUBSCRIBED:String = "not_subscribed";
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_Subscription_CancelledSubscribers.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_bodyTf:FarmTextField;
      
      private var m_successCallBack:Function;
      
      private var m_failureCallBack:Function;
      
      private var m_source:String;
      
      public function SubscriptionsPSDeclinedWindow(dialogAsset:String, source:String = "default", successCallBack:Function = null, failureCallBack:Function = null)
      {
         super(dialogAsset);
         this.m_successCallBack = successCallBack;
         this.m_failureCallBack = failureCallBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", successCallBack:Function = null, failureCallBack:Function = null) : void
      {
         var popUp:SubscriptionsPSDeclinedWindow = null;
         popUp = new SubscriptionsPSDeclinedWindow(ASSET_NAME,source,successCallBack,failureCallBack);
         UI.displayPopup(popUp);
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         FarmStatsManager.count(SubscriptionsManager.STATS_COUNTER,"recapture","cancelled","resubscribe");
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
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("yes_btn"))
         {
            addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,"",this.onOkButtonClicked),true);
         }
         if(m_window.hasOwnProperty("close_btn"))
         {
            addWidget(m_closeButton = new FarmButton(m_window.close_btn,this.onCloseButtonClicked),true);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpTitle")),true);
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new FarmTextField(m_window.subtitle_tf,""),false);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new FarmTextField(m_window.body_tf,""),true);
         }
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            addWidget(new ZwWidget(m_window.bonus_mc),false);
         }
         if(m_window.hasOwnProperty("learnmore_mc"))
         {
            addWidget(new ZwWidget(m_window.learnmore_mc),true);
         }
         if(this.m_source == SUBSCRIBED)
         {
            this.m_okButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptions_psdeclined_ok");
            this.m_bodyTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptions_psdeclined_st_subscribed");
         }
         else
         {
            this.m_okButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRec_resubscribe");
            this.m_bodyTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptions_psdeclined_st_not_subscribed");
         }
      }
   }
}

