package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ItemMembershipUnsubscribeConfirmationWindow extends FarmWindowWithBackground
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_cancel.swf";
      
      private static const UI_DUP_KEY:String = "Widgets.Windows.ItemMembershipUnsubscribeConfirmationWindow";
      
      private static const STAT_UNSUBSCRIBE_CONFIRMATION_WINDOW:String = "unsubscribe_confirmation_window";
      
      private var m_featureName:String = "";
      
      public function ItemMembershipUnsubscribeConfirmationWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(ASSET_PATH,ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_WELCOME_WINDOW_BACKGROUND_IMAGE));
      }
      
      public static function showStatic(featureName:String) : void
      {
         UI.displayPopup(new ItemMembershipUnsubscribeConfirmationWindow(featureName),true,UI_DUP_KEY,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var zLocObj:Object = null;
         super.postLoadComplete();
         if(m_window is MovieClip)
         {
            if("title_tf" in m_window)
            {
               addWidget(new ZwTextField(m_window["title_tf"],ItemMembershipManager.FEATURE_TYPE + "_unsubscribe_confirmation_title",false,"Dialogs"),true);
            }
            if("body_tf" in m_window)
            {
               zLocObj = {"itemNamePlural":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL)};
               addWidget(new ZwTextField(m_window["body_tf"],ItemMembershipManager.FEATURE_TYPE + "_unsubscribe_confirmation_body",false,"Dialogs",zLocObj),true);
            }
            if("accept_bt" in m_window)
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_unsubscribe_confirmation_cancel"),this.onCancelButtonClicked),true);
            }
            if("cancel_bt" in m_window)
            {
               addWidget(new FarmAnimatedTextButton(m_window["cancel_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_unsubscribe_confirmation_unsubscribe"),this.onUnsubscribeButtonClicked),true);
            }
            this.count(StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      private function onCancelButtonClicked(event:Event) : void
      {
         this.count(StatsTrackingConstants.STAY);
         this.close();
      }
      
      private function onUnsubscribeButtonClicked(event:Event) : void
      {
         this.count(StatsTrackingConstants.UNSUBSCRIBE);
         ItemMembershipManager.unsubscribe(this.m_featureName);
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.count(StatsTrackingConstants.CLOSE);
         super.onClose(event);
      }
      
      private function count(phylum:String) : void
      {
         StatsManager.count(this.m_featureName,STAT_UNSUBSCRIBE_CONFIRMATION_WINDOW,phylum);
      }
   }
}

