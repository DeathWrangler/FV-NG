package Widgets.Windows.Crafting
{
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingStatsManager;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Utilities;
   import Events.MarketEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.MFSRequestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BuyMarketStallWindow extends FarmWindow
   {
      
      protected static const NUM_TUTORIAL_STEPS:uint = 4;
      
      protected static const IMAGE_PREFIX:String = "assets/farmers_market/farmersmarket_tutorial_";
      
      protected static const IMAGE_SUFFIX:String = ".png";
      
      public function BuyMarketStallWindow()
      {
         super("assets/dialogs/FV_MarketStall_BuyStall.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         CraftingStatsManager.recordMarketStallImpulseBuyPageView();
         var mainFrame:ZwFrame = new ZwFrame(m_window.popupBox_mc);
         addWidget(mainFrame);
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.goldTitle_tf,ZLocUtils.t("Crafting","BuyMarketStallDialog_Title")));
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.generic_tf,ZLocUtils.t("Crafting","BuyMarketStallDialog_Info")));
         this.setupCoinFrame(mainFrame);
         this.setupCashFrame(mainFrame);
         mainFrame.addWidget(new FarmAnimatedTextButton(m_window.popupBox_mc.cancel_bt,ZLocUtils.t("Crafting","BuyMarketStallDialog_CancelButton"),this.onCancelButtonPressed));
      }
      
      private function setupCoinFrame(mainFrame:ZwFrame) : void
      {
         var tierCost:Number = NaN;
         var levelRequired:Number = NaN;
         var unlockString:String = null;
         var item:BuildingItem = Global.farmGameSettingsManager.getFarmItemByCode("ms") as BuildingItem;
         var slotMc:MovieClip = m_window.popupBox_mc.slot_0_mc;
         var slot:ZwFrame = new ZwFrame(slotMc);
         slot.addWidget(new ZwTextField(slotMc.itemName_mc,item.friendlyTitle));
         var stallIcon:FarmIcon = new FarmIcon(slotMc.icon_mc,item.icon);
         stallIcon.setIconSize(80,80);
         var canBuy:Boolean = item.checkTiers();
         if(canBuy)
         {
            slotMc.locked_mc.visible = false;
            slotMc.itemCost_mc.visible = true;
            slotMc.itemCost_mc.farmCoin_mc.visible = true;
            slotMc.itemCost_mc.farmCash_mc.visible = false;
            tierCost = item.getNumberFromTierSource("cost",1);
            slot.addWidget(new ZwTextField(slotMc.itemCost_mc.farmCoin_mc.cost_tf,Utilities.formatNumber(tierCost)));
            slot.addWidget(new ZwTextField(slotMc.sellFor_mc,ZLocUtils.t("Crafting","BuyMarketStallDialog_SellFor",{"quantity":Utilities.formatNumber(item.sellPrice)})));
            slot.addWidget(new FarmAnimatedTextButton(slotMc.buy_mc,ZLocUtils.t("Crafting","BuyMarketStallDialog_BuyButton"),this.onBuyCoinButtonPressed));
         }
         else
         {
            slotMc.locked_mc.visible = true;
            slot.addWidget(new FarmAnimatedTextButton(slotMc.neighbor_bt,ZLocUtils.t("Crafting","BuyMarketStallDialog_AddNeighborsButton"),this.onAddNeighborButtonPressed));
            levelRequired = item.getNumberFromTierSource("levelRequired",1);
            if(!item.hasItemTierData(1))
            {
               unlockString = ZLocUtils.t("Dialogs","LimitHit",{"quantity":item.totalTiers});
            }
            else if(levelRequired > Global.player.level)
            {
               unlockString = ZLocUtils.t("Dialogs","LevelNeeded",{"quantity":item.levelRequired});
            }
            else
            {
               unlockString = ZLocUtils.t("Dialogs","NeighborsNeeded",{
                  "quantity":item.neighborsRequired,
                  "quantityTotal":Global.friendManager.neighborCount
               });
            }
            slot.addWidget(new ZwTextField(slotMc.neighborsNeeded_tf,unlockString));
         }
         slot.addWidget(stallIcon);
         mainFrame.addWidget(slot);
      }
      
      private function setupCashFrame(mainFrame:ZwFrame) : void
      {
         var nextTierCash:int = 0;
         var nextTierData:BaseDataSource = null;
         var nextTier1:XML = null;
         var itemTierData:BaseDataSource = null;
         var itemTier:XML = null;
         var itemTierLevelRequired:int = 0;
         var hasTierData:Boolean = false;
         var unlockString:String = null;
         var item:BuildingItem = Global.farmGameSettingsManager.getFarmItemByCode(CraftingConstants.MARKETSTALL_CASH_ITEM_CODE) as BuildingItem;
         var slotMc:MovieClip = m_window.popupBox_mc.slot_1_mc;
         var slot:ZwFrame = new ZwFrame(slotMc);
         slot.addWidget(new ZwTextField(slotMc.itemName_mc,item.friendlyTitle));
         var stallIcon:FarmIcon = new FarmIcon(slotMc.icon_mc,item.icon);
         stallIcon.setIconSize(80,80);
         item.currentContext = FarmItem.MARKET_CONTEXT_CASH;
         var canBuy:Boolean = item.checkTiers();
         if(canBuy)
         {
            slotMc.locked_mc.visible = false;
            slotMc.itemCost_mc.visible = true;
            slotMc.itemCost_mc.farmCoin_mc.visible = false;
            slotMc.itemCost_mc.farmCash_mc.visible = true;
            item.currentContext = FarmItem.MARKET_CONTEXT_CASH;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               nextTierData = item.nextTierDS;
               nextTierCash = nextTierData.getInt("cash");
            }
            else
            {
               nextTier1 = item.nextTier;
               nextTierCash = int(nextTier1.cash);
            }
            slot.addWidget(new ZwTextField(slotMc.itemCost_mc.farmCash_mc.cost_tf,"  " + Utilities.formatNumber(nextTierCash)));
            slot.addWidget(new ZwTextField(slotMc.sellFor_mc,ZLocUtils.t("Crafting","BuyMarketStallDialog_SellFor",{"quantity":Utilities.formatNumber(item.sellPrice)})));
            slot.addWidget(new FarmAnimatedTextButton(slotMc.buy_mc,ZLocUtils.t("Crafting","BuyMarketStallDialog_BuyButton"),this.onBuyCashButtonPressed));
         }
         else
         {
            slotMc.locked_mc.visible = true;
            slot.addWidget(new FarmAnimatedTextButton(slotMc.neighbor_bt,ZLocUtils.t("Crafting","BuyMarketStallDialog_AddNeighborsButton"),this.onAddNeighborButtonPressed));
            itemTierData = null;
            itemTier = null;
            hasTierData = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               itemTierData = item.getItemTierDS(item.getActiveDataByCode(CraftingConstants.MARKETSTALL_CASH_ITEM_CODE),1);
               if(itemTierData != null)
               {
                  hasTierData = true;
                  itemTierLevelRequired = itemTierData.getInt("levelRequired");
               }
            }
            else
            {
               itemTier = item.getItemTier(item.getActiveXmlByCode(CraftingConstants.MARKETSTALL_CASH_ITEM_CODE),1);
               if(itemTier != null)
               {
                  hasTierData = true;
                  itemTierLevelRequired = int(itemTier.levelRequired);
               }
            }
            if(!hasTierData)
            {
               unlockString = ZLocUtils.t("Dialogs","LimitHit",{"quantity":item.totalTiers});
            }
            else if(itemTierLevelRequired > Global.player.level)
            {
               unlockString = ZLocUtils.t("Dialogs","LevelNeeded",{"quantity":item.levelRequired});
            }
            else
            {
               unlockString = ZLocUtils.t("Dialogs","NeighborsNeeded",{
                  "quantity":item.neighborsRequired,
                  "quantityTotal":Global.friendManager.neighborCount
               });
            }
            slot.addWidget(new ZwTextField(slotMc.neighborsNeeded_tf,unlockString));
         }
         item.resetCurrentContext();
         slot.addWidget(stallIcon);
         mainFrame.addWidget(slot);
      }
      
      private function onBuyCoinButtonPressed(evt:Event) : void
      {
         var nextTierCost:int = 0;
         var nextTierData:BaseDataSource = null;
         var nextTier1:XML = null;
         CraftingStatsManager.recordMarketStallImpulseBuyCoinClick();
         var item:BuildingItem = Global.farmGameSettingsManager.getFarmItemByCode(CraftingConstants.MARKETSTALL_COIN_ITEM_CODE) as BuildingItem;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextTierData = item.nextTierDS;
            nextTierCost = nextTierData.getInt("cost");
         }
         else
         {
            nextTier1 = item.nextTier;
            nextTierCost = int(nextTier1.cost);
         }
         if(Global.player.canBuy(nextTierCost,true))
         {
            CraftingManager.getInstance().reconfigureOnPlace = true;
            item.onBuy("marketstall");
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.NONE));
         }
         this.close();
      }
      
      private function onBuyCashButtonPressed(evt:Event) : void
      {
         var nextTierCash:int = 0;
         var nextTierData:BaseDataSource = null;
         var nextTier1:XML = null;
         CraftingStatsManager.recordMarketStallImpulseBuyCoinClick();
         var item:BuildingItem = Global.farmGameSettingsManager.getFarmItemByCode(CraftingConstants.MARKETSTALL_COIN_ITEM_CODE) as BuildingItem;
         item.currentContext = FarmItem.MARKET_CONTEXT_CASH;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextTierData = item.nextTierDS;
            nextTierCash = nextTierData.getInt("cash");
         }
         else
         {
            nextTier1 = item.nextTier;
            nextTierCash = int(nextTier1.cash);
         }
         if(Global.player.canBuyCash(nextTierCash,true))
         {
            CraftingStatsManager.recordMarketStallImpulseBuyCashClick();
            CraftingManager.getInstance().reconfigureOnPlace = true;
            item.onBuy("marketstall_cash");
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.NONE));
         }
         item.resetCurrentContext();
         this.close();
      }
      
      private function onAddNeighborButtonPressed(evt:Event) : void
      {
         MFSRequestManager.getInstance().displayR2AddNeighborWindow("marketStall");
      }
      
      private function onCancelButtonPressed(evt:Event) : void
      {
         this.close();
      }
   }
}

