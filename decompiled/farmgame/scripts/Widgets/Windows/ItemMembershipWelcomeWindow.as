package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class ItemMembershipWelcomeWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_FTU.swf";
      
      private static const CREDIT_ASSET_PATH:String = "assets/dialogs/4d_elements/SubscriptionsClub/token_tree_icon.png";
      
      private static const UI_DUP_KEY:String = "Widgets.Windows.ItemMembershipWelcomeWindow";
      
      private static const STAT_WELCOME_WINDOW:String = "welcome_window";
      
      private var m_featureName:String = "";
      
      public function ItemMembershipWelcomeWindow(featureName:String)
      {
         super(ASSET_PATH);
         this.m_featureName = featureName;
      }
      
      public static function showStatic(featureName:String) : void
      {
         UI.displayPopup(new ItemMembershipWelcomeWindow(featureName),false,UI_DUP_KEY,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var numMonthsSubscribed:int = 0;
         var zLocObj:Object = null;
         var numCreditsPerMonth:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_welcome_title",{"clubName":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_CLUB_NAME)})),true);
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            numMonthsSubscribed = ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.NUM_MONTHS_SUBSCRIBED);
            if(!isNaN(numMonthsSubscribed))
            {
               zLocObj = {
                  "numMonthsSubscribed":numMonthsSubscribed,
                  "itemSingular":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR),
                  "clubName":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_CLUB_NAME)
               };
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_welcome_member_level",zLocObj)),true);
            }
         }
         if(m_window.hasOwnProperty("generic3_tf"))
         {
            addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_welcome_bonus",{"itemPlural":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL)})),true);
         }
         if("icon_mc" in m_window)
         {
            addWidget(new FarmIcon(m_window["icon_mc"],CREDIT_ASSET_PATH),true);
         }
         if(m_window.hasOwnProperty("generic4_tf"))
         {
            numCreditsPerMonth = ItemMembershipManager.getConstantsIntWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_NUM_CREDITS_PER_MONTH);
            if(numCreditsPerMonth > 0)
            {
               addWidget(new ZwTextField(m_window["generic4_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_welcome_credits",{
                  "numCreditsPerMonth":numCreditsPerMonth,
                  "itemSingular":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR)
               })),true);
            }
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + ItemMembershipManager.ZLOC_KEY_REDEEM),this.onRedeemButtonClicked),true);
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            addWidget(new FarmIcon(m_window["background_mc"],ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_WELCOME_WINDOW_BACKGROUND_IMAGE)),true);
         }
         this.count(StatsTrackingConstants.IMPRESSIONS);
      }
      
      private function onRedeemButtonClicked(event:Event) : void
      {
         this.count(StatsTrackingConstants.CLICK_REDEEM);
         this.close();
      }
      
      private function count(phylum:String) : void
      {
         StatsManager.count(this.m_featureName,STAT_WELCOME_WINDOW,phylum);
      }
   }
}

