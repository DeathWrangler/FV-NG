package Classes.ZItem
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMSetAltGraphic;
   import Managers.FarmGameSettingsManager;
   import Managers.LicenseManager;
   import Managers.SubscriptionsManager;
   import Managers.UnlimitedPacksManager;
   import Transactions.TBuyConsumables;
   import Transactions.TBuyTheme;
   import Transactions.TChangeTheme;
   import Transactions.TExpandFarm;
   import Widgets.Constants.Market.Currency;
   
   public class ChangeFarmItem extends FarmItem
   {
      
      protected var m_squares:Number = -559038227;
      
      public function ChangeFarmItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get squares() : Number
      {
         if(this.m_squares == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_squares = m_dataSource.getNumber("squares");
            }
            else
            {
               this.m_squares = Number(m_itemXML.@squares);
            }
         }
         return this.m_squares;
      }
      
      override public function get isVisible() : Boolean
      {
         var showExpand:Boolean = false;
         var showTreasureExpand:Boolean = false;
         var showChange:Boolean = false;
         var showConsumable:Boolean = false;
         var showGameModePurchase:Boolean = false;
         var showUnlimitedPack:Boolean = false;
         var subType:String = null;
         var squares:Number = NaN;
         var name:String = null;
         var type:String = null;
         var sizeX:int = Global.world.getGridWidth();
         var sizeY:int = Global.world.getGridHeight();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            subType = m_dataSource.getString("subtype");
            squares = m_dataSource.getNumber("squares");
            name = m_dataSource.getString("name");
            type = m_dataSource.getString("type");
            showExpand = subType == "expand_farm" && squares > sizeX && squares > sizeY;
            showTreasureExpand = subType == "treasure" && squares > sizeX && squares > sizeY;
            showChange = subType == "tile_set" && name != Global.world.getThemeType();
            showConsumable = type == "change_farm" && subType == "consumable";
            showGameModePurchase = type == "change_farm" && subType == "lightItems";
            showUnlimitedPack = type == "change_farm" && subType == "unlimited_pack";
         }
         else
         {
            showTreasureExpand = m_itemXML.@subtype == "treasure" && m_itemXML.@squares > sizeX && m_itemXML.@squares > sizeY;
            showExpand = m_itemXML.@subtype == "expand_farm" && m_itemXML.@squares > sizeX && m_itemXML.@squares > sizeY;
            showChange = m_itemXML.@subtype == "tile_set" && m_itemXML.@name != Global.world.getThemeType();
            showConsumable = m_itemXML.@type == "change_farm" && m_itemXML.@subtype == "consumable";
            showGameModePurchase = m_itemXML.@type == "change_farm" && m_itemXML.@subtype == "lightItems";
            showUnlimitedPack = m_itemXML.@type == "change_farm" && m_itemXML.@subtype == "unlimited_pack";
         }
         return super.isVisible && (showExpand || showChange || showConsumable || showGameModePurchase || showTreasureExpand || showUnlimitedPack);
      }
      
      override public function get sellPrice() : Number
      {
         var sellPrice:Number = 0;
         if(subType == "expand_farm")
         {
            sellPrice = 0;
         }
         else
         {
            sellPrice = super.sellPrice;
         }
         return sellPrice;
      }
      
      override public function get xpGained() : Number
      {
         var xpGained:Number = 0;
         if(subType == "expand_farm")
         {
            xpGained = 0;
         }
         else
         {
            xpGained = super.xpGained;
         }
         return xpGained;
      }
      
      override public function get saleCash() : int
      {
         var result:int = super.saleCash;
         if(subType == "expand_farm" && SubscriptionsManager.enableTileForOneFc())
         {
            result -= cash * SubscriptionsManager.RUBY_LAND_EXPANSIONS_DISCOUNT / 100;
         }
         if(subType == "expand_farm")
         {
            result = 1;
         }
         return result;
      }
      
      override public function get hasSale() : Boolean
      {
         var result:Boolean = false;
         if(subType == "expand_farm" && SubscriptionsManager.enableTileForOneFc())
         {
            result = true;
         }
         else
         {
            result = super.hasSale;
         }
         return result;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var gridX:int = 0;
         var gridY:int = 0;
         var success:Boolean = false;
         var foundCurrent:Boolean = false;
         var lowestName:String = null;
         var farmItems:Array = null;
         var changeFarmItem:ChangeFarmItem = null;
         var closeMarket:Boolean = true;
         var currencyUnit:String = Currency.COINS;
         if(Boolean(extraData) && extraData.hasOwnProperty("currency"))
         {
            currencyUnit = extraData["currency"];
         }
         if(subType == "lightItems")
         {
            Global.world.addGameMode(new GMSetAltGraphic(name));
         }
         else if(subType == "expand_farm" || subType == "treasure")
         {
            gridX = Global.world.getGridWidth();
            gridY = Global.world.getGridHeight();
            success = false;
            foundCurrent = false;
            lowestName = null;
            farmItems = Global.farmGameSettingsManager.getExpansionFarmItemsForCurrentWorld();
            farmItems.sortOn("squares",Array.NUMERIC);
            for each(changeFarmItem in farmItems)
            {
               if(changeFarmItem.squares == gridX && changeFarmItem.squares == gridY)
               {
                  foundCurrent = true;
               }
               else if(foundCurrent == true)
               {
                  if(changeFarmItem.size == size)
                  {
                     success = true;
                  }
                  lowestName = changeFarmItem.friendlyName;
                  break;
               }
            }
            if(success || subType == "treasure")
            {
               if(Boolean(extraData) && (!extraData.hasOwnProperty("friendSet") || extraData["friendSet"] == false))
               {
                  this.beginFarmExpansionPurchaseFlow(currencyUnit,name);
               }
            }
            else
            {
               closeMarket = false;
               UI.displayMessage(ZLocUtils.t("Dialogs","CantExpandFarm",{"item":ZLocUtils.tk_pk(lowestName)}),GenericPopup.TYPE_OK,null,"",true);
            }
         }
         else if(subType == "tile_set")
         {
            TransactionManager.addTransaction(new TBuyTheme(name));
         }
         else if(subType == "consumable")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_dataSource.hasProperty("showBuyMessage"))
               {
                  if(extraData == null)
                  {
                     extraData = {};
                  }
                  extraData.displayBuyMessage = m_dataSource.getBoolean("showBuyMessage");
               }
            }
            else if(xml.attribute("showBuyMessage").length() > 0)
            {
               if(extraData == null)
               {
                  extraData = {};
               }
               extraData.displayBuyMessage = String(xml.@showBuyMessage) == "true" ? true : false;
            }
            if(Global.player.canBuyCash(realCashCost,true))
            {
               TransactionManager.addTransaction(new TBuyConsumables(name,false,extraData),true);
            }
         }
         else if(subType == "unlimited_pack")
         {
            UnlimitedPacksManager.getInstance().onBuyBundle();
         }
         return closeMarket;
      }
      
      private function beginFarmExpansionPurchaseFlow(currencyUnit:String, name:String) : void
      {
         var onComplete:Function = null;
         if(currencyUnit == FarmItem.CASH_ATTRIBUTE_NAME)
         {
            onComplete = ZCacheUtil.applyPartial(this.onFinishFarmExpansionPopup,this,[currencyUnit,name]);
            UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.realCashCost}),GenericPopup.TYPE_ACCEPTCANCEL,onComplete,"Expand_Farm_Complete_Now_Confirmation",true,true);
         }
         else
         {
            TransactionManager.addTransaction(new TExpandFarm(name,true,currencyUnit),true);
         }
      }
      
      private function onFinishFarmExpansionPopup(currencyUnit:String, name:String, event:GenericPopupEvent) : void
      {
         var changeFarmItem:FarmItem = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            TransactionManager.addTransaction(new TExpandFarm(name,true,currencyUnit),true);
            changeFarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
            if(Boolean(changeFarmItem) && subType == "treasure")
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(changeFarmItem.rewardsData != null)
                  {
                     UserRewardUtil.grantUserRewardsFromDataSource(changeFarmItem.rewardsData);
                  }
               }
               else if(changeFarmItem.hasOwnProperty("rewardsXML") && changeFarmItem.rewardsXML != null)
               {
                  UserRewardUtil.grantUserRewardsFromXml(changeFarmItem.rewardsXML);
               }
            }
         }
         else
         {
            UI.displayMarketDialog("unknown","landExpansion",null,"expansion");
         }
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         if(subType == "tile_set" && isLicenseGated && LicenseManager.getInstance().hasCurrentLicense(code))
         {
            TransactionManager.addTransaction(new TChangeTheme(name));
         }
      }
   }
}

