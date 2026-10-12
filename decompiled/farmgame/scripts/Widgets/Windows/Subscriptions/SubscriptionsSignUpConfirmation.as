package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsSignUpConfirmation extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_motd_confirmation_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_cancelButton:FarmAnimatedTextButton;
      
      private var m_successCallBack:Function;
      
      private var m_failureCallBack:Function;
      
      private var m_source:String;
      
      public function SubscriptionsSignUpConfirmation(dialogAsset:String, source:String = "default", successCallBack:Function = null, failureCallBack:Function = null)
      {
         super(dialogAsset);
         this.m_successCallBack = successCallBack;
         this.m_failureCallBack = failureCallBack;
         this.m_source = source;
      }
      
      public static function display(source:String = "default", successCallBack:Function = null, failureCallBack:Function = null) : void
      {
         var popUp:SubscriptionsSignUpConfirmation = null;
         popUp = new SubscriptionsSignUpConfirmation(ASSET_NAME,source,successCallBack,failureCallBack);
         UI.displayPopup(popUp,false,"",false,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpConfirmationYesButton"),this.onOkButtonClicked),true);
         this.m_okButton.visible = true;
         addWidget(this.m_cancelButton = new FarmAnimatedTextButton(m_window.mainWindow.no_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpConfirmationCloseButton"),this.onCloseButtonClicked),true);
         this.m_cancelButton.visible = true;
         if(SubscriptionsManager.isTrialSubscriptionActive())
         {
            addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tSubConfirmTitle")),true);
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"tSubConfirmBody")),true);
         }
         else
         {
            addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpTitle")),true);
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpConfirmationBody")),true);
         }
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
            this.m_failureCallBack();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_successCallBack = null;
         this.m_okButton = null;
         super.release();
      }
   }
}

