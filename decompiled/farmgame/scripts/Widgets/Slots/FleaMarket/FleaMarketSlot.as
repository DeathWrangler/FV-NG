package Widgets.Slots.FleaMarket
{
   import Classes.FarmGameObject;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Constants;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TFleaMarket;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FleaMarket.FleaMarketWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class FleaMarketSlot extends ZwSlotFrame
   {
      
      protected static const OVERLAY_URL:String = "assets/overlays/effect_sapling_sparkling.swf";
      
      private static const STATS_COUNTER:String = "trading";
      
      private static const PAN_ANIMATION_DELAY:int = 3500;
      
      private static const ICON_SIZE:int = 100;
      
      private var m_titleText:ZwTextField;
      
      private var m_sellPriceText:ZwTextField;
      
      private var m_descriptionText:ZwTextField;
      
      private var m_sellButton:FarmAnimatedTextButton;
      
      private var m_icon:FarmIcon;
      
      private var m_currencyIcon:ZwBaseWidget;
      
      private var m_priceTag:ZwBaseWidget;
      
      private var m_parentWindow:FarmWindow;
      
      private var m_name:String;
      
      private var m_id:int;
      
      private var m_resellPrice:int;
      
      private var m_slotIndex:int;
      
      private var m_farmGameObject:FarmGameObject;
      
      private var m_farmGameId:int;
      
      private var m_confirmPopup:GenericPopup;
      
      public function FleaMarketSlot(element:DisplayObject, parentWindow:FarmWindow, slotIndex:int)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_slotIndex = slotIndex;
         addWidget(this.m_titleText = new ZwTextField(m_element.itemTitle_tf));
         addWidget(this.m_priceTag = new ZwBaseWidget(m_element.price_mc));
         var currency:String = FleaMarketWindow.getCurrencyFromVariant();
         switch(currency)
         {
            case Currency.CASH:
               addWidget(this.m_sellPriceText = new ZwTextField(m_element.number_tf));
               addWidget(this.m_currencyIcon = new ZwBaseWidget(m_element.price_mc.cashIcon_mc));
               addWidget(new ZwBaseWidget(m_element.price_mc.cocoIcon_mc),false);
               addWidget(new ZwBaseWidget(m_element.price_mc.coinIcon_mc),false);
               break;
            case Currency.COCONUTS:
               addWidget(this.m_sellPriceText = new ZwTextField(m_element.number2_tf));
               addWidget(this.m_currencyIcon = new ZwBaseWidget(m_element.price_mc.cocoIcon_mc));
               addWidget(new ZwBaseWidget(m_element.price_mc.cashIcon_mc),false);
               addWidget(new ZwBaseWidget(m_element.price_mc.coinIcon_mc),false);
               break;
            case Currency.COINS:
               addWidget(this.m_sellPriceText = new ZwTextField(m_element.number2_tf));
               addWidget(this.m_currencyIcon = new ZwBaseWidget(m_element.price_mc.coinIcon_mc));
               addWidget(new ZwBaseWidget(m_element.price_mc.cashIcon_mc),false);
               addWidget(new ZwBaseWidget(m_element.price_mc.cocoIcon_mc),false);
               break;
            default:
               this.m_parentWindow.close();
         }
         this.m_icon = new FarmIcon(m_element.icon_mc);
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(this.m_icon);
         addWidget(this.m_sellButton = new FarmAnimatedTextButton(m_element.sell_bt,ZLocUtils.t("Dialogs","MarketPromo_ActionButton_FleaMarket"),this.onSaleConfrimation));
      }
      
      override public function populate(data:Object) : void
      {
         this.m_id = data.id;
         this.m_name = data.name;
         this.m_resellPrice = data.price;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_name);
         if(farmItem)
         {
            FarmStatsManager.count(STATS_COUNTER,"ctr_impression",farmItem.type,"",farmItem.name);
            this.m_titleText.visible = true;
            this.m_titleText.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
            this.m_sellPriceText.visible = true;
            this.m_priceTag.visible = true;
            this.m_currencyIcon.visible = true;
            this.m_sellPriceText.text = Utilities.formatNumber(this.m_resellPrice);
            this.m_icon.visible = true;
            this.m_sellButton.visible = true;
            this.m_icon.loadIcon(farmItem.icon);
         }
      }
      
      private function onSaleConfrimation(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,"confirm","view");
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_name);
         var sellMessage:String = ZLocUtils.t("Dialogs","fleaMarket_sellConfirmation",{"itemName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)});
         this.m_confirmPopup = new GenericPopup(sellMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onSellItem);
         UI.displayPopup(this.m_confirmPopup,false,"FleaMarket_sellConfirmation",true);
      }
      
      private function onSellItem(event:GenericPopupEvent) : void
      {
         var detachTimer:Timer = null;
         var farmItem:FarmItem = null;
         var storageCellars:Array = null;
         var storageBuildings:Array = null;
         var i:int = 0;
         var storageBuilding:StorageBuilding = null;
         var storageItem:FarmItem = null;
         this.m_confirmPopup.close();
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(STATS_COUNTER,"confirm","click_ok");
            FarmStatsManager.count(STATS_COUNTER,"dialog","sell_item",this.m_resellPrice.toString(),this.m_slotIndex.toString());
            detachTimer = new Timer(PAN_ANIMATION_DELAY,1);
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_name);
            if(farmItem)
            {
               FarmStatsManager.count(STATS_COUNTER,"ctr_click",farmItem.type,"",farmItem.name);
            }
            if(this.m_id == FleaMarketWindow.STORAGE_ID)
            {
               storageCellars = new Array();
               this.m_farmGameId = FleaMarketWindow.STORAGE_ID;
               storageBuildings = Global.world.getObjectsByClass(getDefinitionByName("Classes.StorageBuilding") as Class);
               for(i = 0; i < storageBuildings.length; i++)
               {
                  storageBuilding = storageBuildings[i] as StorageBuilding;
                  storageItem = storageBuilding.getItem();
                  if(storageItem.subType != "" && storageItem.subType == "storage" && storageItem.className == "StorageBuilding")
                  {
                     storageCellars.push(storageBuilding);
                  }
               }
               if(storageCellars.length > 0)
               {
                  this.m_farmGameObject = storageCellars[0] as FarmGameObject;
               }
            }
            else
            {
               this.m_farmGameObject = Global.world.getObjectById(this.m_id) as FarmGameObject;
               this.m_farmGameId = this.m_farmGameObject.getId();
            }
            if(this.m_parentWindow != null)
            {
               this.m_parentWindow.close();
            }
            this.onFrameAsset();
            detachTimer.addEventListener(TimerEvent.TIMER,this.onPanAnimation);
            detachTimer.start();
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,"confirm","click_Cancel");
         }
      }
      
      private function onFrameAsset() : void
      {
         if(this.m_farmGameObject != null)
         {
            this.m_farmGameObject.centerOn();
            this.m_farmGameObject.setHighlighted(true,Constants.COLOR_HIGHLIGHT_BLUE);
            this.m_farmGameObject.dispOverlay(OVERLAY_URL);
         }
         var resellTranasaction:TFleaMarket = new TFleaMarket(TFleaMarket.TYPE_RESELL,null,{
            "id":this.m_id,
            "currentId":this.m_farmGameId,
            "name":this.m_name,
            "price":this.m_resellPrice
         });
         TransactionManager.addTransaction(resellTranasaction,true);
      }
      
      private function onPanAnimation(event:Event) : void
      {
         var itemCode:String = null;
         if(this.m_farmGameObject != null)
         {
            if(this.m_farmGameId != FleaMarketWindow.STORAGE_ID)
            {
               this.m_farmGameObject.detach();
            }
            else if(this.m_farmGameId == FleaMarketWindow.STORAGE_ID)
            {
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_name);
               Global.player.removeInventoryItem(itemCode);
            }
            this.m_farmGameObject.setHighlighted(false);
            this.m_farmGameObject.setToolTip("");
         }
         this.onItemSold();
      }
      
      private function onItemSold() : void
      {
         var currency:String = FleaMarketWindow.getCurrencyFromVariant();
         switch(currency)
         {
            case Currency.CASH:
               Global.player.cash += this.m_resellPrice;
               break;
            case Currency.COCONUTS:
               Global.player.updateWorldCurrency(currency,this.m_resellPrice);
               break;
            case Currency.COINS:
               Global.player.gold += this.m_resellPrice;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_last_item",{
            "id":this.m_id,
            "name":this.m_name,
            "price":this.m_resellPrice
         });
         FeatureOptionsManager.getInstance().setFeatureOption(FleaMarketWindow.FLEA_MARKET_OPTION,"flea_market_last_time",GlobalEngine.serverTime);
         var dialog:FleaMarketWindow = new FleaMarketWindow();
         UI.displayPopup(dialog,false,"FleaMarketWindow",true);
      }
   }
}

