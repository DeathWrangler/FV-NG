package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsClickThankYou extends FarmWindow
   {
      
      private static const assetName:String = "assets/dialogs/FV_subscriptionclicktest_thanks.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      public function SubscriptionsClickThankYou(dialogAsset:String, callBack:Function = null)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
      }
      
      public static function display(callBack:Function = null) : void
      {
         var popUp:SubscriptionsClickThankYou = null;
         popUp = new SubscriptionsClickThankYou(assetName,callBack);
         UI.displayPopup(popUp,false,"",false,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"treeoflove2013bubble-01-006_iconTooltip"),this.onOkButtonClicked),true);
         this.m_okButton.visible = true;
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
         this.m_callBack = null;
         this.m_okButton = null;
         super.release();
      }
   }
}

