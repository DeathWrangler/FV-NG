package Widgets.Windows.Amex
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class AmexTreeIframeNotification extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_ServeFrame_MOTD.swf";
      
      private static const NOTIFICATION_ACTION_COUNTER:String = "amexIframe_notifications";
      
      private static const MIN_NOTIFICATION_COUNT:int = 3;
      
      private static const STATS_COUNTER:String = "amex_serve";
      
      private static const STATS_COUNTER_DIALOG:String = "dialog";
      
      private static const STATS_COUNTER_VIEW:String = "view";
      
      private static const STATS_COUNTER_CLOSE:String = "close";
      
      public function AmexTreeIframeNotification()
      {
         super(DIALOG_ASSET);
      }
      
      public static function conditionallyShowNotification() : void
      {
         if(Global.player.getActionCount(NOTIFICATION_ACTION_COUNTER) < MIN_NOTIFICATION_COUNT)
         {
            UI.displayPopup(new AmexTreeIframeNotification());
         }
         else
         {
            showAmexLocker();
         }
      }
      
      private static function showAmexLocker() : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_VIEW,"serve_dashboard");
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onAmexIframeError",onAmexIframError);
            ExternalInterface.addCallback("onAmexLockerClosed",onAmexLockerClose);
            ExternalInterface.call("showRewardsDialog");
         }
      }
      
      private static function onAmexLockerClose() : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_CLOSE,"serve_dashboard");
      }
      
      private static function onAmexIframError() : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_VIEW,"error");
         UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AmexTreeIframeNotification_error"),GenericPopup.TYPE_OK,onAmexIframErrorClosed,"",true);
      }
      
      private static function onAmexIframErrorClosed(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_CLOSE,"error");
      }
      
      override public function show() : void
      {
         super.show();
         Global.player.incrementActionCount(NOTIFICATION_ACTION_COUNTER);
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_VIEW,"interstitial");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.place_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AmexTreeIframeNotification_buttontxt"),this.onShowDashboard));
         addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AmexTreeIframeNotification_header")));
         addWidget(new ZwTextField(m_window.legal_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AmexTreeIframeNotification_legal")));
         addWidget(new ZwWidget(m_window.cashAnimated_mc));
      }
      
      private function onShowDashboard(event:Event) : void
      {
         close();
         FarmStatsManager.count(STATS_COUNTER,STATS_COUNTER_DIALOG,STATS_COUNTER_CLOSE,"interstitial");
         AmexTreeIframeNotification.showAmexLocker();
      }
   }
}

