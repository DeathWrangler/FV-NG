package Widgets.Slots.FinishAllBuildings
{
   import Classes.Constants.Experiments;
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.OrchardBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TCompleteNowFromMOTD;
   import Transactions.TTransformBuildingFromMOTD;
   import Transactions.TUpgradeStorageFromMOTD;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.MOTD.FinishAllBuildingsMOTDWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class FinishAllBuildingsSlot extends ZwSlotFrame
   {
      
      protected static const POPUP_ICON_WIDTH:Number = 100;
      
      protected static const POPUP_ICON_HEIGHT:Number = 100;
      
      protected static const SALE_PRICE_ROUND_THRESHOLD:int = 5;
      
      public static const BUY_CLICKED_EVENT:String = "buyClicked";
      
      public static const BUY_SUCCESS_EVENT:String = "buySucces";
      
      private static var s_statsCounted:Dictionary = new Dictionary();
      
      private var m_slotAvailabilityIcon:ZwBaseWidget;
      
      private var m_slotFCIcon:ZwBaseWidget;
      
      private var m_slotBackground:ZwBaseWidget;
      
      private var m_slotSalePrice:FarmTextField;
      
      private var m_slotOriginalPrice:FarmTextField;
      
      private var m_slotItemName:FarmTextField;
      
      private var m_slotConstructionBuilding:ConstructionBuilding;
      
      private var m_slotCompleteBuilding:Object;
      
      private var m_slotBuyButton:FarmAnimatedTextButton;
      
      private var m_slotIcon:FarmIcon;
      
      private var m_slotItem:FarmItem;
      
      private var m_salePrice:int;
      
      public function FinishAllBuildingsSlot(element:DisplayObject, slotNum:int)
      {
         super(element);
         this.m_slotFCIcon = new ZwBaseWidget(m_element.cashSm_mc);
         addWidget(this.m_slotFCIcon);
         this.m_slotBackground = new ZwBaseWidget(m_element.slotBackground_mc);
         addWidget(this.m_slotBackground);
         this.m_slotSalePrice = new FarmTextField(m_element.price_tf,"xxx");
         addWidget(this.m_slotSalePrice);
         this.m_slotOriginalPrice = new FarmTextField(m_element.oldPrice_tf,"xxx");
         addWidget(this.m_slotOriginalPrice);
         this.m_slotBuyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),this.onBuyClick);
         addWidget(this.m_slotBuyButton);
         this.m_slotIcon = new FarmIcon(m_element.icon_mc);
         this.m_slotIcon.setIconSize(POPUP_ICON_WIDTH,POPUP_ICON_HEIGHT);
         addWidget(this.m_slotIcon);
         this.m_slotItemName = new FarmTextField(m_element.title_tf,"xxx");
         addWidget(this.m_slotItemName);
      }
      
      override public function populate(saleItem:Object) : void
      {
         var cashNeeded:Number = NaN;
         var itemName:String = null;
         var expansionItem:FarmItem = null;
         super.populate(saleItem);
         this.m_slotFCIcon.visible = true;
         this.m_slotBackground.visible = true;
         this.m_slotSalePrice.visible = true;
         this.m_slotOriginalPrice.visible = true;
         this.m_slotBuyButton.visible = true;
         this.m_slotItemName.visible = true;
         this.m_slotCompleteBuilding = null;
         this.m_slotConstructionBuilding = null;
         var titleKey:String = "";
         var discount:Number = this.getDiscount();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FINISH_ALL_BLDGS_EXPANSIONS) == 1 && !(saleItem is ConstructionBuilding))
         {
            this.m_slotBuyButton.text = ZLocUtils.t("Dialogs","Expand");
            cashNeeded = (saleItem as StorageBuilding).getCashNeeded();
            if(saleItem is FeatureBuilding)
            {
               cashNeeded = (saleItem as FeatureBuilding).nextExpansionCashNeeded();
            }
            else if(saleItem is OrchardBuilding)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  itemName = (saleItem as OrchardBuilding).getItem().getStringFromDataSource("expansion");
               }
               else
               {
                  itemName = (saleItem as OrchardBuilding).getItem().xml.expansion;
               }
               expansionItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               cashNeeded = expansionItem.cash;
            }
            if(cashNeeded <= SALE_PRICE_ROUND_THRESHOLD)
            {
               this.m_salePrice = Math.floor(cashNeeded * (1 - discount));
            }
            else
            {
               this.m_salePrice = Math.round(cashNeeded * (1 - discount));
            }
            this.m_slotCompleteBuilding = saleItem;
            this.m_slotItem = (saleItem as StorageBuilding).getItem();
            if(this.m_slotItem != null)
            {
               this.m_slotIcon.loadIcon(this.m_slotItem.icon);
               this.m_slotIcon.visible = true;
            }
            this.m_slotBuyButton.enabled = true;
            this.m_slotOriginalPrice.text = cashNeeded.toString();
            this.m_slotSalePrice.text = this.m_salePrice.toString();
            titleKey = ZLocUtils.hasString("Items",this.m_slotItem.name + MarketSlot.ALT_MARKET_TOKEN) ? ZLocUtils.t("Items",this.m_slotItem.name + MarketSlot.ALT_MARKET_TOKEN) : this.m_slotItem.friendlyTitle;
            this.m_slotItemName.text = titleKey;
            if(s_statsCounted[this.m_slotCompleteBuilding] == null)
            {
               FarmStatsManager.count(FinishAllBuildingsMOTDWindow.FINISH_ALL_BUILDING_COUNTER,"dialog_view",this.m_slotItem.name,this.m_salePrice.toString());
               s_statsCounted[this.m_slotCompleteBuilding] = true;
            }
         }
         else
         {
            this.m_slotBuyButton.text = ZLocUtils.t("Dialogs","Buy");
            cashNeeded = (saleItem as ConstructionBuilding).getCashNeeded();
            if(cashNeeded <= SALE_PRICE_ROUND_THRESHOLD)
            {
               this.m_salePrice = Math.floor(cashNeeded * (1 - discount));
            }
            else
            {
               this.m_salePrice = Math.round(cashNeeded * (1 - discount));
            }
            this.m_slotConstructionBuilding = saleItem as ConstructionBuilding;
            this.m_slotItem = (saleItem as ConstructionBuilding).getFinishedItem();
            if(this.m_slotItem != null)
            {
               this.m_slotIcon.loadIcon(this.m_slotItem.icon);
               this.m_slotIcon.visible = true;
            }
            this.m_slotBuyButton.enabled = true;
            this.m_slotOriginalPrice.text = cashNeeded.toString();
            this.m_slotSalePrice.text = this.m_salePrice.toString();
            titleKey = ZLocUtils.hasString("Items",this.m_slotItem.name + MarketSlot.ALT_MARKET_TOKEN) ? ZLocUtils.t("Items",this.m_slotItem.name + MarketSlot.ALT_MARKET_TOKEN) : this.m_slotItem.friendlyTitle;
            this.m_slotItemName.text = titleKey;
            if(s_statsCounted[this.m_slotConstructionBuilding] == null)
            {
               FarmStatsManager.count(FinishAllBuildingsMOTDWindow.FINISH_ALL_BUILDING_COUNTER,"dialog_view",this.m_slotItem.name,this.m_salePrice.toString());
               s_statsCounted[this.m_slotConstructionBuilding] = true;
            }
         }
      }
      
      private function getDiscount() : Number
      {
         var result:Number = 0;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FINISH_ALL_BLDGS);
         switch(variant)
         {
            case 2:
               result = 0.1;
               break;
            case 3:
               result = 0.2;
               break;
            case 4:
               result = 0.3;
         }
         return result;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_slotFCIcon = null;
         this.m_slotBackground = null;
         this.m_slotSalePrice = null;
         this.m_slotOriginalPrice = null;
         this.m_slotBuyButton = null;
         this.m_slotIcon = null;
         this.m_slotConstructionBuilding = null;
         this.m_slotCompleteBuilding = null;
         this.m_slotItemName = null;
      }
      
      private function onBuyClick(event:Event) : void
      {
         var discount:int = 0;
         var fbuilding:FeatureBuilding = null;
         var itemPurchased:FarmItem = null;
         var cashNeeded:Number = NaN;
         var newBuilding:MapResource = null;
         if(Global.player.canBuyCash(this.m_salePrice))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FINISH_ALL_BLDGS_EXPANSIONS) == 1 && this.m_slotCompleteBuilding != null)
            {
               if(this.m_slotCompleteBuilding is FeatureBuilding)
               {
                  fbuilding = this.m_slotCompleteBuilding as FeatureBuilding;
                  if(this.m_salePrice > 0)
                  {
                     if(fbuilding.expandToNextStorageLevel() == true)
                     {
                        if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
                        {
                           FarmStatsManager.count(FinishAllBuildingsMOTDWindow.FINISH_ALL_BUILDING_COUNTER,"purchase",fbuilding.getItem().name,this.m_salePrice.toString());
                        }
                        Global.player.cash -= this.m_salePrice;
                        TransactionManager.addTransaction(new TCompleteNowFromMOTD(this.m_slotCompleteBuilding as StorageBuilding,this.itemBuySuccess));
                     }
                     if(fbuilding.expand)
                     {
                        fbuilding.expand.conditionallySwapOnFullyExpanded();
                     }
                  }
               }
               else if(this.m_slotCompleteBuilding is OrchardBuilding)
               {
                  itemPurchased = Global.farmGameSettingsManager.getFarmItemByName((this.m_slotCompleteBuilding as OrchardBuilding).getItem().expansion);
                  cashNeeded = itemPurchased.cash;
                  discount = cashNeeded - this.m_salePrice;
                  TransactionManager.addTransaction(new TUpgradeStorageFromMOTD(this.m_slotCompleteBuilding as OrchardBuilding,this.itemBuySuccess,discount),true);
                  (this.m_slotCompleteBuilding as OrchardBuilding).upgrade(null,true);
                  (this.m_slotCompleteBuilding as OrchardBuilding).reloadImage();
               }
            }
            else
            {
               this.m_slotConstructionBuilding.m_queueRewardFeedPopup = false;
               this.m_slotConstructionBuilding.m_displayFinishedDialog = false;
               newBuilding = this.m_slotConstructionBuilding.transformBuilding();
               if(Boolean(newBuilding) && Boolean(newBuilding.getItem()))
               {
                  discount = newBuilding.getItem().cash - this.m_salePrice;
                  Global.player.tryBuy(newBuilding,false,newBuilding.getItem(),discount);
                  TransactionManager.addTransaction(new TTransformBuildingFromMOTD(this.m_slotConstructionBuilding,false,this.itemBuySuccess));
                  FarmStatsManager.count(FinishAllBuildingsMOTDWindow.FINISH_ALL_BUILDING_COUNTER,"purchase",newBuilding.getItem().name,this.m_salePrice.toString());
               }
            }
            dispatchEvent(new Event(BUY_CLICKED_EVENT));
         }
      }
      
      private function itemBuySuccess(result:Object = null) : void
      {
         dispatchEvent(new Event(BUY_SUCCESS_EVENT));
      }
      
      public function setBuyButtonEnabled(enabled:Boolean) : void
      {
         this.m_slotBuyButton.enabled = enabled;
      }
      
      public function get data() : StorageBuilding
      {
         if(this.m_slotConstructionBuilding != null)
         {
            return this.m_slotConstructionBuilding;
         }
         return this.m_slotCompleteBuilding as StorageBuilding;
      }
   }
}

