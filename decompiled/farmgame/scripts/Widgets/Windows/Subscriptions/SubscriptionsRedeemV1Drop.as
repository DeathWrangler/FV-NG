package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SubscriptionCommonDropPopupWindow;
   import flash.events.Event;
   
   public class SubscriptionsRedeemV1Drop extends SubscriptionCommonDropPopupWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Loot_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      private var m_amount:int;
      
      public function SubscriptionsRedeemV1Drop(dialogAsset:String, callBack:Function = null, amount:int = 0)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_amount = amount;
      }
      
      public static function display(callBack:Function = null, amount:int = 0) : void
      {
         var popUp:SubscriptionsRedeemV1Drop = null;
         popUp = new SubscriptionsRedeemV1Drop(ASSET_NAME,callBack,amount);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,"Awesome!",this.onOkButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropTitle")),true);
         addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsRedeemDropBody")),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropSubtitle",{"amount":this.m_amount.toString()})),true);
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack(this.m_amount,"redeem_drop");
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

