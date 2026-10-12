package Widgets.Slots.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingSiloInventorySlot extends ZwSlotFrame
   {
      
      private static const ITEM_ICON_SIZE_IN_PIXELS:Number = 70;
      
      private static const LOC_PREFIX:String = "_InventoryItem";
      
      private var m_building:FeatureBuilding = null;
      
      private var m_data:MarketInventoryItem = null;
      
      private var m_item:FarmItem = null;
      
      private var m_farmIcon:FarmIcon = null;
      
      private var m_askFrame:ZwFrame = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_shareButton:FarmAnimatedTextButton = null;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_buyCallback:Function = null;
      
      private var m_shareCallback:Function = null;
      
      private var m_askCallback:Function = null;
      
      private var m_locPrefix:String = "";
      
      private var m_itemTitleTF:ZwTextField = null;
      
      private var m_itemCountTF:ZwTextField = null;
      
      private var m_itemAskTextTF:ZwTextField = null;
      
      private var m_askButtonGreyedOut:Boolean = false;
      
      private var m_shareButtonGreyedOut:Boolean = false;
      
      private var m_buyButtonGreyedOut:Boolean = false;
      
      private var m_askGreyToolTip:FarmTextTooltip = null;
      
      private var m_shareGreyToolTip:FarmTextTooltip = null;
      
      private var m_buyGreyToolTip:FarmTextTooltip = null;
      
      public function CraftingSiloInventorySlot(building:FeatureBuilding, element:DisplayObject, locPrefix:String, buyCallback:Function, shareCallback:Function, askCallback:Function)
      {
         this.m_building = building;
         super(element);
         this.m_locPrefix = locPrefix + LOC_PREFIX;
         this.m_buyCallback = buyCallback;
         this.m_shareCallback = shareCallback;
         this.m_askCallback = askCallback;
         this.m_itemTitleTF = addWidget(new ZwTextField(m_element.generic1_tf)) as ZwTextField;
         this.m_itemCountTF = addWidget(new ZwTextField(m_element.generic2_tf)) as ZwTextField;
         this.m_buyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_BuyButton"),this.onBuyClick);
         addWidget(this.m_buyButton);
         this.m_shareButton = new FarmAnimatedTextButton(m_element.share_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_ShareButton"),this.onShareClick);
         addWidget(this.m_shareButton);
         this.m_askFrame = addWidget(new ZwFrame(m_element.ask_mc)) as ZwFrame;
         this.m_itemAskTextTF = this.m_askFrame.addWidget(new ZwTextField(m_element.ask_mc.generic_tf,ZLocUtils.t("Crafting",this.m_locPrefix + "_AskText",{"bushelitem":"item name gets refreshed"}))) as ZwTextField;
         this.m_askButton = new FarmAnimatedTextButton(m_element.ask_mc.ask_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_AskButton"),this.onAskClick);
         this.m_askFrame.addWidget(this.m_askButton);
         this.m_farmIcon = new FarmIcon(m_element.icon_mc);
         this.m_farmIcon.setIconSize(ITEM_ICON_SIZE_IN_PIXELS,ITEM_ICON_SIZE_IN_PIXELS);
         this.m_farmIcon.setSmoothing(true);
         this.addWidget(this.m_farmIcon);
         this.m_askGreyToolTip = new FarmTextTooltip("");
         this.m_askButton.attachTooltip(this.m_askGreyToolTip);
         this.m_shareGreyToolTip = new FarmTextTooltip("");
         this.m_shareButton.attachTooltip(this.m_shareGreyToolTip);
         this.m_buyGreyToolTip = new FarmTextTooltip("");
         this.m_buyButton.attachTooltip(this.m_buyGreyToolTip);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         this.m_data = data as MarketInventoryItem;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
         var itemFrendlyName:String = ZLocUtils.tk_pk_asTitlePlural(this.m_item.friendlyName);
         this.m_itemTitleTF.text = ZLocUtils.t("Crafting",this.m_locPrefix + "_ShareDialog_Title",{"bushelitem":itemFrendlyName});
         this.m_itemTitleTF.visible = true;
         this.m_itemCountTF.text = String(this.m_data.quantity);
         this.m_itemCountTF.visible = true;
         this.m_buyButton.visible = true;
         this.refreshBuyButton();
         this.m_shareButton.visible = true;
         this.refreshShareButton();
         this.m_askFrame.visible = true;
         this.m_itemAskTextTF.visible = true;
         this.refreshAskButton();
         this.m_askButton.visible = true;
         this.m_farmIcon.loadIcon(this.m_item.icon);
         this.m_farmIcon.visible = true;
      }
      
      public function refreshBuyButton() : void
      {
         var currentCapacity:Number = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
         var maxCapacity:Number = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity;
         if(currentCapacity < maxCapacity)
         {
            this.m_buyButton.applyGrayOut = false;
            this.m_buyButtonGreyedOut = false;
            this.m_buyGreyToolTip.setText("");
         }
         else
         {
            this.m_buyButton.applyGrayOut = true;
            this.m_buyButtonGreyedOut = true;
            this.m_buyGreyToolTip.setText(ZLocUtils.t("Crafting","CraftingSiloDialog_InventorySlot_BuyGrey_Tool_Tip"));
         }
      }
      
      public function refreshShareButton() : void
      {
         if(this.m_data.quantity > 0)
         {
            this.m_shareButton.applyGrayOut = false;
            this.m_shareButtonGreyedOut = false;
            this.m_shareButton.enabled = true;
            this.m_shareGreyToolTip.setText("");
         }
         else
         {
            this.m_shareButton.applyGrayOut = true;
            this.m_shareButtonGreyedOut = true;
            this.m_shareGreyToolTip.setText(ZLocUtils.t("Crafting","CraftingSiloDialog_InventorySlot_ShareGrey_Tool_Tip"));
         }
      }
      
      public function refreshAskButton() : void
      {
         if(CraftingManager.getInstance().canPublishBushelRequestFeed())
         {
            this.m_askButtonGreyedOut = false;
            this.m_askButton.applyGrayOut = false;
         }
         else
         {
            this.m_askButtonGreyedOut = true;
            this.m_askButton.applyGrayOut = true;
         }
         this.refreshAskText();
      }
      
      public function refreshAskText() : void
      {
         var timeLeftInSeconds:Number = NaN;
         var timeLeftInHours:Number = NaN;
         var itemFrendlyName:String = itemFrendlyName = ZLocUtils.tk_pk_asTitlePlural(this.m_item.friendlyName);
         if(!this.m_askButtonGreyedOut)
         {
            this.m_itemAskTextTF.text = ZLocUtils.t("Crafting",this.m_locPrefix + "_AskText",{"bushelitem":itemFrendlyName});
            this.m_askGreyToolTip.setText("");
         }
         else
         {
            this.m_itemAskTextTF.text = ZLocUtils.t("Crafting",this.m_locPrefix + "_AskText_Waiting",{"bushelitem":itemFrendlyName});
            timeLeftInSeconds = Global.player.craftingState.shoppingState.lastGetBushelsRequestTS - (GlobalEngine.serverTime / 1000 - Global.craftConfigSettings.getBushelRequestFeedLimitSeconds());
            timeLeftInHours = Math.floor(timeLeftInSeconds / FarmGameUtil.NUM_SECS_IN_HOUR);
            if(timeLeftInHours > 1)
            {
               this.m_askGreyToolTip.setText(ZLocUtils.t("Crafting","CraftingSiloDialog_InventorySlot_AskGrey_Tool_Tip_hours",{"number":timeLeftInHours}));
            }
            else
            {
               this.m_askGreyToolTip.setText(ZLocUtils.t("Crafting","CraftingSiloDialog_InventorySlot_AskGrey_Tool_Tip_minutes",{"number":Math.floor(timeLeftInSeconds / 60)}));
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_buyButton = null;
         this.m_shareButton = null;
         this.m_askButton = null;
         this.m_buyCallback = null;
         this.m_shareCallback = null;
         this.m_askCallback = null;
         this.m_farmIcon = null;
         this.m_data = null;
         this.m_item = null;
         this.m_askGreyToolTip = null;
         this.m_shareGreyToolTip = null;
         this.m_buyGreyToolTip = null;
      }
      
      private function onBuyClick(evt:MouseEvent) : void
      {
         if(!this.m_buyButtonGreyedOut)
         {
            this.m_buyCallback(this.m_item,this.m_data);
         }
      }
      
      private function onShareClick(evt:MouseEvent) : void
      {
         if(!this.m_shareButtonGreyedOut)
         {
            this.m_shareCallback(this.m_item,this.m_data);
         }
      }
      
      private function onAskClick(evt:MouseEvent) : void
      {
         if(!this.m_askButtonGreyedOut)
         {
            this.m_askCallback(this.m_item,this.m_data);
         }
      }
   }
}

