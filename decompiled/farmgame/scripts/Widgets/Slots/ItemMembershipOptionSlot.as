package Widgets.Slots
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwWindowSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ItemMembershipOptionSlot extends ZwWindowSlotFrame
   {
      
      private static const SUBSCRIBE_CONFIRMATION_DUP_KEY:String = "item_membership_subscribe_confirmation";
      
      private var m_numMonths:String = null;
      
      private var m_featureName:String = "";
      
      private var m_price:String = null;
      
      public function ItemMembershipOptionSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
      }
      
      override public function populate(data:Object) : void
      {
         var numBonusItems:int = 0;
         var itemName:String = null;
         var zLocObj:Object = null;
         m_widgetManager.removeAllWidgets();
         if(data.hasOwnProperty(ItemMembershipManager.KEY_FEATURE_NAME))
         {
            this.m_featureName = data[ItemMembershipManager.KEY_FEATURE_NAME];
         }
         if(data.hasOwnProperty(ItemMembershipManager.NUM_MONTHS))
         {
            this.m_numMonths = data[ItemMembershipManager.NUM_MONTHS];
            if(m_element.hasOwnProperty("month_mc"))
            {
               addWidget(new ZwTextField(m_element.month_mc,this.m_numMonths + " MONTH"),true);
            }
            if(m_element.hasOwnProperty("monthBig_tf"))
            {
               addWidget(new ZwTextField(m_element.monthBig_tf,this.m_numMonths),true);
            }
         }
         if(m_element.hasOwnProperty("buy_bt") && data.hasOwnProperty(ItemMembershipManager.PRICE))
         {
            this.m_price = data[ItemMembershipManager.PRICE];
            addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Join",this.m_price,this.onJoinButtonClicked));
         }
         if(m_element.hasOwnProperty("value_tf") && data.hasOwnProperty(ItemMembershipManager.PERCENT_DISCOUNT))
         {
            addWidget(new ZwTextField(m_element.value_tf,data[ItemMembershipManager.PERCENT_DISCOUNT]),true);
         }
         if(m_element.hasOwnProperty("bonus_tf") && data.hasOwnProperty(ItemMembershipManager.KEY_NUM_BONUS_ITEMS))
         {
            numBonusItems = int(data[ItemMembershipManager.KEY_NUM_BONUS_ITEMS]);
            if(numBonusItems == 1)
            {
               itemName = ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR);
            }
            else
            {
               itemName = ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL);
            }
            zLocObj = {
               "numBonusItems":numBonusItems,
               "itemName":itemName
            };
            addWidget(new ZwTextField(m_element.bonus_tf,ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_subscription_option_total_bonus",zLocObj)),true);
         }
      }
      
      private function onJoinButtonClicked(event:Event) : void
      {
         var monthString:String = parseInt(this.m_numMonths) > 1 ? "months" : "month";
         var zLocObj:Object = {
            "clubName":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_CLUB_NAME),
            "numMonths":this.m_numMonths,
            "price":this.m_price,
            "monthKey":monthString
         };
         UI.displayMessage(ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_subscribe_confirmation",zLocObj),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationWindowClosed,SUBSCRIBE_CONFIRMATION_DUP_KEY,true,true,SUBSCRIBE_CONFIRMATION_DUP_KEY);
         StatsManager.count(this.m_featureName,StatsTrackingConstants.CLICK_JOIN,this.m_numMonths);
      }
      
      private function onConfirmationWindowClosed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            if(!isNaN(parseInt(this.m_price)) && Global.player.canBuyCash(parseInt(this.m_price)) && !isNaN(parseInt(this.m_numMonths)) && this.m_featureName != null && this.m_numMonths != null)
            {
               StatsManager.count(this.m_featureName,StatsTrackingConstants.JOINED,this.m_numMonths);
               ItemMembershipManager.subscribe(this.m_featureName,parseInt(this.m_numMonths),parseInt(this.m_price));
               m_parentWindow.refreshWindow();
            }
         }
      }
      
      override public function release() : void
      {
         this.m_numMonths = null;
         this.m_featureName = null;
         this.m_price = null;
         super.release();
      }
   }
}

