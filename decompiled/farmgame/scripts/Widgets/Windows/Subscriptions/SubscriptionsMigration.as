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
   
   public class SubscriptionsMigration extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Migration_v1.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      public function SubscriptionsMigration(dialogAsset:String, callBack:Function = null)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
      }
      
      public static function display(callBack:Function = null) : void
      {
         var popUp:SubscriptionsMigration = null;
         popUp = new SubscriptionsMigration(ASSET_NAME,callBack);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsMigrationPopupYesButton"),this.onOkButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsSignUpTitle")),true);
         addWidget(new FarmTextField(m_window.hi_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsMigrationPopupHi")),true);
         addWidget(new FarmTextField(m_window.name_tf,Global.player.snUser.name),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsMigrationPopupSubtitle")),true);
         addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsMigrationPopupBody")),true);
         var showBonusMC:Boolean = !Global.player.getSeenFlag(SubscriptionsManager.ONE_TIME_BONUS_FLAG);
         addWidget(new FarmTextField(m_window.mc_bonus.bonus_tf,"Joining Bonus 30 Farm Cash!"),true);
         (m_window.mc_bonus as MovieClip).visible = showBonusMC;
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
            "source":"migration_popup",
            "previousPopupEventType":SubscriptionsManager.SHOW_MIGRATION_POPUP
         }));
         super.close();
      }
   }
}

