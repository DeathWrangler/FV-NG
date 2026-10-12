package Widgets.Slots
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwWindowSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.ItemMembershipWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ItemMembershipRedeemSlot extends ZwWindowSlotFrame
   {
      
      private static const REDEEM_CONFIRMATION_DUP_KEY:String = "item_membership_redeem_confirmation";
      
      private var m_featureName:String;
      
      private var m_item:FarmItem;
      
      private var m_icon:FarmIcon;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_friendlyName:ZwTextField;
      
      public function ItemMembershipRedeemSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = new FarmIcon(m_element.icon_mc);
            this.m_icon.setIconSize(FarmIcon.STANDARD_ICON_WIDTH,FarmIcon.STANDARD_ICON_HEIGHT);
            addWidget(this.m_icon);
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            this.m_redeemButton = new FarmAnimatedTextButton(m_element["redeem_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + ItemMembershipManager.ZLOC_KEY_REDEEM),this.onRedeemButtonClicked);
            addWidget(this.m_redeemButton,true);
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            this.m_friendlyName = new ZwTextField(m_element["name_tf"]);
            addWidget(this.m_friendlyName);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data.hasOwnProperty(ItemMembershipManager.KEY_FEATURE_NAME))
         {
            this.m_featureName = data[ItemMembershipManager.KEY_FEATURE_NAME];
         }
         if(data.hasOwnProperty("item"))
         {
            this.m_item = data["item"];
         }
         if(this.m_item is FarmItem)
         {
            if(Boolean(this.m_item.iconUrl) && this.m_icon is FarmIcon)
            {
               if(this.m_item.iconUrl)
               {
                  this.m_icon.loadIcon(this.m_item.iconUrl);
                  this.m_icon.visible = true;
               }
            }
            if(this.m_friendlyName is ZwTextField)
            {
               this.m_friendlyName.text = this.m_item.friendlyTitle;
               this.m_friendlyName.visible = true;
            }
         }
         if(this.m_redeemButton is FarmAnimatedTextButton)
         {
            this.m_redeemButton.visible = true;
            ItemMembershipWindow.toggleRedeemButton(this.m_redeemButton,this.m_featureName);
         }
      }
      
      private function onRedeemButtonClicked(event:Event) : void
      {
         if(this.m_item is FarmItem)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_redeem_confirmation",{"friendlyTitle":this.m_item.friendlyTitle}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationWindowClosed,REDEEM_CONFIRMATION_DUP_KEY,true,true,REDEEM_CONFIRMATION_DUP_KEY);
            StatsManager.count(this.m_featureName,StatsTrackingConstants.REDEEM_VIEW,StatsTrackingConstants.CLICK_REDEEM,this.m_item.name);
         }
      }
      
      private function onConfirmationWindowClosed(event:GenericPopupEvent) : void
      {
         var itemMembershipWindow:ItemMembershipWindow = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            ItemMembershipManager.redeem(this.m_featureName,this.m_item.code);
            itemMembershipWindow = m_parentWindow as ItemMembershipWindow;
            if(itemMembershipWindow)
            {
               itemMembershipWindow.populateRedeemView(true);
            }
            StatsManager.count(this.m_featureName,StatsTrackingConstants.REDEEM_VIEW,StatsTrackingConstants.ITEM_REDEEMED,this.m_item.name);
         }
      }
      
      override public function release() : void
      {
         this.m_featureName = null;
         this.m_item = null;
         this.m_icon = null;
         this.m_redeemButton = null;
         this.m_friendlyName = null;
         super.release();
      }
   }
}

