package Widgets.Slots
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.ItemLicense;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.LicenseManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.Subscriptions.SubscriptionsWeeklyDrop;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SubscriptionVipItemsBuySlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_buyButton:FarmAnimatedButton = null;
      
      private var m_objectPreviewFrame:ZwWidget;
      
      private var m_objectPreviewFrame1:ZwWidget;
      
      private var m_iconPreview:FarmIcon;
      
      private var m_itemName:FarmTextField;
      
      private var m_newPriceText:FarmTextField;
      
      private var m_oldPriceText:FarmTextField;
      
      private var m_item:FarmItem;
      
      private var m_substitutionString:String;
      
      public function SubscriptionVipItemsBuySlot(element:DisplayObject)
      {
         super(element);
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_itemName = new FarmTextField(m_element.name_tf,""),true);
         }
         if(m_element.hasOwnProperty("newPrice_tf"))
         {
            addWidget(this.m_newPriceText = new FarmTextField(m_element.newPrice_tf,""),true);
         }
         if(m_element.hasOwnProperty("oldPrice_tf"))
         {
            addWidget(this.m_oldPriceText = new FarmTextField(m_element.oldPrice_tf,""),true);
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buyButton = new FarmAnimatedButton(m_element.buy_bt,this.onBuyButtonClicked),true) as FarmAnimatedButton;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemLicense:ItemLicense = null;
         var farmItem:FarmItem = null;
         super.populate(data);
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = true;
            this.m_buyButton.enabled = true;
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.clearDimensions();
            removeWidget(this.m_iconPreview);
            this.m_iconPreview = null;
         }
         this.m_item = data as FarmItem;
         if(this.m_itemName)
         {
            this.m_itemName.text = this.m_item.friendlyTitle;
            this.m_itemName.visible = true;
         }
         if(this.m_newPriceText)
         {
            this.m_newPriceText.text = this.m_item.realCashCost.toString();
            this.m_newPriceText.visible = true;
         }
         if(this.m_oldPriceText)
         {
            this.m_oldPriceText.text = this.m_item.cash.toString();
            this.m_oldPriceText.visible = true;
         }
         var limitedTimeLeft:Number = 0;
         if(this.m_item.isLEItem())
         {
            limitedTimeLeft = this.m_item.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
            itemLicense = this.m_item.itemLicense;
            if(itemLicense != null && LicenseManager.getInstance().hasCurrentLicense(this.m_item.code))
            {
               limitedTimeLeft = LicenseManager.getInstance().getTimeLeftToExpiration(this.m_item.code);
            }
         }
         var parsedTime:Array = FarmGameUtil.parseTimeLeft(limitedTimeLeft);
         this.m_substitutionString = this.m_item.substitutionString;
         if(Boolean(m_element.hasOwnProperty("objectPreview_mc")) && Boolean(this.m_substitutionString) && this.m_substitutionString != "")
         {
            this.m_objectPreviewFrame = new ZwWidget(m_element.objectPreview_mc);
            addWidget(this.m_objectPreviewFrame,true);
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_substitutionString);
            addWidget(this.m_objectPreviewFrame1 = new ObjectPreviewFrame(m_element.objectPreview_mc.icon_0_mc,farmItem,null,null,[100],Animal.STATE_FRONT_IDLE),true);
            this.m_objectPreviewFrame.element.play();
            this.attachTooltip(new FarmTextTooltip(FarmGameUtil.getFormattedTimeLeftText(parsedTime)));
         }
         else if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_iconPreview = new FarmIcon(m_element.icon_mc,this.m_item.icon);
            this.m_iconPreview.setIconSize(ICON_SIZE,ICON_SIZE);
            addWidget(this.m_iconPreview,true);
            this.m_iconPreview.visible = true;
            this.attachTooltip(new FarmTextTooltip(FarmGameUtil.getFormattedTimeLeftText(parsedTime)));
         }
      }
      
      private function onBuyButtonClicked(event:Event = null) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","Buy_Confirmation_Message",{
            "amount":this.m_item.realCashCost,
            "item":ZLocUtils.tk_pk(this.m_item.friendlyName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteNowPopup,"",true);
      }
      
      private function onAcceptCompleteNowPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.player.buyFarmItem(this.m_item,Currency.CASH,1,true,false,false,this.onSuccess,true);
         }
      }
      
      private function onSuccess(result:Object) : void
      {
         if(Boolean(result) && result.itemName != "")
         {
            UI.displayPopup(new GenericSingleRewardPopup(SubscriptionsWeeklyDrop.ASSET_REWARD_PATH,"subscriptions",Global.farmGameSettingsManager.getFarmItemByName(result.itemName)),false);
         }
      }
   }
}

