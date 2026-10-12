package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class ItemMembershipOutOfCashWindow extends FarmWindowWithBackground
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_prize.swf";
      
      private static const UI_DUP_KEY:String = "Widgets.Windows.ItemMembershipOutOfCashWindow";
      
      private var m_featureName:String = "";
      
      public function ItemMembershipOutOfCashWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(ASSET_PATH,ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_WELCOME_WINDOW_BACKGROUND_IMAGE));
      }
      
      public static function showStatic(featureName:String) : void
      {
         UI.displayPopup(new ItemMembershipOutOfCashWindow(featureName),true,UI_DUP_KEY,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var zLocObj:Object = null;
         var bonusItemNames:Array = null;
         var item:FarmItem = null;
         var numBonusItemNames:int = 0;
         var i:int = 0;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window["generic_tf"])
            {
               addWidget(new ZwTextField(m_window.generic_tf,"item_membership_not_enough_cash_title",false,"Dialogs"),true);
            }
            if(m_window["generic2_tf"])
            {
               zLocObj = {"itemNameSingular":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR)};
               addWidget(new ZwTextField(m_window.generic2_tf,"item_membership_not_enough_cash_body",false,"Dialogs",zLocObj),true);
            }
            if(m_window["generic4_tf"])
            {
               addWidget(new ZwTextField(m_window.generic3_tf,"item_membership_not_enough_cash_footer",false,"Dialogs"),true);
            }
            if(m_window["share_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","buyAndResubscribe"),this.onBuyButtonClicked),true);
            }
            bonusItemNames = ItemMembershipManager.getBonusItemNamesForNumMonthsSubscribed(this.m_featureName,1);
            if(Boolean(bonusItemNames) && bonusItemNames.length > 0)
            {
               numBonusItemNames = int(bonusItemNames.length);
               for(i = 0; i < numBonusItemNames; i++)
               {
                  if(m_window["icon" + i + "_mc"])
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByName(bonusItemNames[i]);
                     if(item)
                     {
                        if(numBonusItemNames == 1 && Boolean(m_window["icon1_mc"]))
                        {
                           m_window.icon0_mc.x = (m_window.icon0_mc.x + m_window.icon1_mc.x) / 2;
                        }
                        addWidget(new FarmIcon(m_window["icon" + i + "_mc"],item.getImageByName("feed",false)),true);
                     }
                  }
               }
            }
            this.count(StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      private function onBuyButtonClicked(event:Event) : void
      {
         var cashNeeded:int = ItemMembershipManager.getCostForMembershipLength(this.m_featureName,ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.SUBSCRIPTION_LENGTH));
         PaymentUtil.instance.addCashToCart(PaymentUtil.getPricePoint(cashNeeded),ItemMembershipManager.PAYMENTS_REF,ItemMembershipManager.onPurchaseSuccess);
         ItemMembershipManager.s_outOfCashFeatureName = this.m_featureName;
         this.count(StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM);
         this.close();
      }
      
      override public function close() : void
      {
         ItemMembershipManager.unsubscribe(this.m_featureName);
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.count(StatsTrackingConstants.CLOSE);
         super.onClose(event);
      }
      
      private function count(phylum:String) : void
      {
         StatsManager.count(this.m_featureName,StatsTrackingConstants.NOT_ENOUGH_CASH,phylum);
      }
   }
}

