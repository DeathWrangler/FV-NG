package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SubscriptionCommonDropPopupWindow;
   import flash.events.Event;
   
   public class SubscriptionsNoDrop extends SubscriptionCommonDropPopupWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Loot_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      public function SubscriptionsNoDrop(dialogAsset:String, callBack:Function = null)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
      }
      
      public static function display(callBack:Function = null) : void
      {
         var popUp:SubscriptionsNoDrop = null;
         popUp = new SubscriptionsNoDrop(ASSET_NAME,callBack);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,"Okay",this.onOkButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropTitle")),true);
         addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsNoDropBody")),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropSubtitle",{"amount":"0"})),false);
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

