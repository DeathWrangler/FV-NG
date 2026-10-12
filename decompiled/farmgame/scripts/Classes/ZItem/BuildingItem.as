package Classes.ZItem
{
   import Classes.BuildingItemUseMediator;
   import Classes.DealOfDayHelper;
   import Classes.DoghouseTreat;
   import Classes.FeatureComponents.FeatureManager;
   import Classes.SimpleHarvestableItem;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import GameMode.GMBuild;
   import GameMode.GMMutableAnimalBabyPlace;
   import GameMode.GMMutableAnimalCratePlace;
   import GameMode.GMMysterySeedlingPlace;
   import GameMode.GMPaintBuilding;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyConsumables;
   import Widgets.Constants.Market.Currency;
   
   public class BuildingItem extends SimpleHarvestableItem
   {
      
      protected var m_levelRequired:int = -559038227;
      
      protected var m_lookInsideOnFinishPlace:String = null;
      
      protected var m_neighborsRequired:int = -559038227;
      
      protected var m_currentContext:String = "coins";
      
      protected var m_neighborAction:String = null;
      
      protected var m_neighborActionKey:String = null;
      
      protected var m_neighborActionLimit:int = -559038227;
      
      private var m_completeWorldScore:int = 0;
      
      private var m_completeWorldScoreUnit:String = "";
      
      private var m_usesSmartSystems:Boolean = false;
      
      public function BuildingItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         super.onConstruction(itemXML,itemData);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_usesSmartSystems = m_dataSource.hasProperty("smartSystemTuning");
            m_cashData = m_dataSource;
         }
         else
         {
            m_cashXML = itemXML;
            this.m_usesSmartSystems = itemXML.hasOwnProperty("smartSystemTuning");
         }
      }
      
      public function get usesSmartSystems() : Boolean
      {
         return this.m_usesSmartSystems;
      }
      
      override public function buyableWithCash() : Boolean
      {
         var level:Number = Global.player.level;
         level = isNaN(level) ? 0 : level;
         return Boolean(super.buyableWithCash()) && level >= this.levelRequired;
      }
      
      override public function calculateCurrentTier() : int
      {
         return Global.player.getGlobalItemInstances(className) + 1;
      }
      
      public function getItemTier(itemXML:XML, offset:int = 0) : XML
      {
         var desiredTier:int = this.calculateCurrentTier() + offset - 1;
         var numItemInstances:int = getNumInstancesOfThisItem();
         if(className == "CraftingCottageBuilding" && numItemInstances > 0)
         {
            desiredTier = offset;
         }
         if(desiredTier == 0)
         {
            desiredTier = 1;
         }
         return getItemTierById(itemXML,desiredTier);
      }
      
      public function getItemTierDS(itemDS:BaseDataSource, offset:int = 0) : BaseDataSource
      {
         var desiredTier:int = this.calculateCurrentTier() + offset - 1;
         var numItemInstances:int = getNumInstancesOfThisItem();
         if(className == "CraftingCottageBuilding" && numItemInstances > 0)
         {
            desiredTier = offset;
         }
         if(desiredTier == 0)
         {
            desiredTier = 1;
         }
         return getItemTierDataById(itemDS,desiredTier);
      }
      
      public function hasItemTierData(offset:int = 0) : Boolean
      {
         var retVal:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            retVal = this.getItemTierDS(m_dataSource,offset) != null;
         }
         else
         {
            retVal = this.getItemTier(m_itemXML,offset) != null;
         }
         return retVal;
      }
      
      public function getNumberFromTierSource(key:String, offset:int = 0) : Number
      {
         var retVal:Number = NaN;
         var nextTierDS:BaseDataSource = null;
         var nextTierXML:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextTierDS = this.getItemTierDS(m_dataSource,offset);
            retVal = nextTierDS.getNumber(key);
         }
         else
         {
            nextTierXML = this.getItemTier(m_itemXML,offset);
            retVal = Number(nextTierXML[key]);
         }
         return retVal;
      }
      
      public function get nextTier() : XML
      {
         var activeXML:XML = null;
         var result:XML = null;
         if(this.isTiered)
         {
            activeXML = getActiveXmlForContext(this.m_currentContext);
            result = this.getItemTier(activeXML,1);
         }
         return result;
      }
      
      public function get nextTierDS() : BaseDataSource
      {
         var activeDS:BaseDataSource = null;
         var result:BaseDataSource = null;
         if(isTiered)
         {
            activeDS = getActiveDSForContext(this.m_currentContext);
            result = this.getItemTierDS(activeDS,1);
         }
         return result;
      }
      
      public function get currentTier() : XML
      {
         var activeXML:XML = null;
         var result:XML = null;
         if(this.isTiered)
         {
            activeXML = getActiveXmlForContext(this.m_currentContext);
            result = this.getItemTier(activeXML);
         }
         return result;
      }
      
      public function get currentTierDS() : BaseDataSource
      {
         var activeDS:BaseDataSource = null;
         var result:BaseDataSource = null;
         if(this.isTiered)
         {
            activeDS = getActiveDSForContext(this.m_currentContext);
            result = this.getItemTierDS(activeDS);
         }
         return result;
      }
      
      public function get currentContext() : String
      {
         return this.m_currentContext;
      }
      
      public function set currentContext(context:String) : void
      {
         this.m_currentContext = context;
      }
      
      public function checkTiers() : Boolean
      {
         var result:Boolean = true;
         var nextTierXML:XML = null;
         var nextTierData:BaseDataSource = null;
         var nextTierNeighborKey:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextTierData = this.nextTierDS;
            if(nextTierData)
            {
               nextTierNeighborKey = nextTierData.getString("neighborKey");
            }
         }
         else
         {
            nextTierXML = this.nextTier;
            if(nextTierXML)
            {
               nextTierNeighborKey = nextTierXML.neighborKey;
            }
         }
         if(nextTierData != null || nextTierXML != null)
         {
            if(nextTierNeighborKey)
            {
               result = Global.player.checkNeighbors(this.neighborsRequired) && Global.player.checkLevel(this.levelRequired);
            }
            else
            {
               result = true;
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      override public function getActiveXml(itemName:String = "") : XML
      {
         var result:XML = super.getActiveXml(itemName);
         if(isTiered)
         {
            result = this.getItemTier(result);
         }
         return result;
      }
      
      override public function getActiveDS(itemName:String = "") : BaseDataSource
      {
         var result:BaseDataSource = super.getActiveDS(itemName);
         if(isTiered)
         {
            result = this.getItemTierDS(result);
         }
         return result;
      }
      
      public function getActiveXmlWithTierOffset(itemName:String = "", offset:int = 0) : XML
      {
         var result:XML = super.getActiveXml(itemName);
         if(isTiered)
         {
            result = this.getItemTier(result,offset);
         }
         return result;
      }
      
      public function getActiveDSWithTierOffset(itemName:String = "", offset:int = 0) : BaseDataSource
      {
         var result:BaseDataSource = super.getActiveDS(itemName);
         if(isTiered)
         {
            result = this.getItemTierDS(result,offset);
         }
         return result;
      }
      
      override public function get isCash() : Boolean
      {
         var tierData:BaseDataSource = null;
         var tierMarket:String = null;
         var tierXml:XML = null;
         var res:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            tierData = this.nextTierDS;
            if(tierData)
            {
               tierMarket = tierData.getString("market");
               if(tierMarket == "cash")
               {
                  res = true;
               }
            }
         }
         else
         {
            tierXml = this.nextTier;
            if(Boolean(tierXml) && Boolean(tierXml["@market"]) && tierXml["@market"] == "cash")
            {
               res = true;
            }
         }
         return res;
      }
      
      public function get buildingName() : String
      {
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("buildingName");
         }
         else if(Boolean(m_itemXML) && Boolean(m_itemXML["@buildingName"]))
         {
            result = m_itemXML["@buildingName"];
         }
         return result;
      }
      
      override public function get sellPrice() : Number
      {
         var sellBackRatio:Number = NaN;
         var amount:Number = NaN;
         var dataSource:BaseDataSource = null;
         var xml:XML = null;
         var currencyData:CurrencyData = null;
         var experimentVariant:int = 0;
         var sellPrice:Number = super.sellPrice;
         var isSellPriceUpdated:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dataSource = isTiered && Boolean(this.currentTierDS) ? this.currentTierDS : m_dataSource;
            if(dataSource)
            {
               isSellPriceUpdated = true;
               if(dataSource.hasProperty("sellPrice"))
               {
                  sellPrice = dataSource.getNumber("sellPrice");
               }
               else
               {
                  sellBackRatio = Global.farmGameSettingsManager.getNumber("sellBackRatio");
                  amount = isTiered && Boolean(this.currentTierDS) ? this.currentTierDS.getNumber("cost") : this.cost;
                  sellPrice = Math.floor(amount * sellBackRatio);
               }
            }
         }
         else
         {
            xml = isTiered && Boolean(this.currentTier) ? this.currentTier : m_itemXML;
            if(xml)
            {
               isSellPriceUpdated = true;
               if(xml.hasOwnProperty("sellPrice"))
               {
                  sellPrice = Number(xml.sellPrice);
               }
               else
               {
                  sellBackRatio = Global.farmGameSettingsManager.getNumber("sellBackRatio");
                  amount = isTiered && Boolean(this.currentTier) ? Number(this.currentTier.cost) : this.cost;
                  sellPrice = Math.floor(amount * sellBackRatio);
               }
            }
         }
         if(isSellPriceUpdated)
         {
            if(this.marketIsWorldCurrency)
            {
               currencyData = Global.farmGameSettingsManager.getCurrencyData(this.market);
               if(currencyData)
               {
                  experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
                  sellPrice = Math.floor(m_sellPrice * currencyData.getInflowTuningMultiplierByVariant(experimentVariant));
               }
               else
               {
                  ErrorManager.addError("Missing currency data for " + this.market + ". Item name = " + this.name);
               }
            }
            else
            {
               sellPrice = this.m_sellPrice;
            }
         }
         return sellPrice;
      }
      
      override public function get cost() : int
      {
         var costString:String = null;
         var tierDataDS:BaseDataSource = null;
         var tierDataXml:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_dataSource) && isTiered)
            {
               tierDataDS = this.getItemTierDS(m_dataSource,1);
               if(tierDataDS != null)
               {
                  costString = getDataProperty(tierDataDS,"cost");
               }
               else
               {
                  costString = getDataProperty(m_dataSource,"cost");
               }
            }
            else
            {
               costString = getDataProperty(m_dataSource,"cost");
            }
         }
         else if(isTiered)
         {
            tierDataXml = this.getItemTier(m_itemXML,1);
            if(tierDataXml != null)
            {
               costString = getXMLProperty(tierDataXml,"cost");
            }
            else
            {
               costString = getXMLProperty(m_itemXML,"cost");
            }
         }
         else
         {
            costString = getXMLProperty(m_itemXML,"cost");
         }
         if(costString)
         {
            m_cost = int(costString);
         }
         else
         {
            m_cost = 0;
         }
         var altPrice:int = testForVariablePricing();
         if(altPrice > 0)
         {
            m_cost = altPrice;
         }
         return m_cost;
      }
      
      override public function get coins() : int
      {
         var coinsString:String = null;
         var tierDataSource:BaseDataSource = null;
         var tierData:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_dataSource) && isTiered)
            {
               tierDataSource = this.getItemTierDS(m_dataSource,1);
               if(Global.flashHotParams["BUILDING_GET_CURRENT_TIER"] == true && !tierDataSource)
               {
                  tierDataSource = this.getItemTierDS(m_dataSource,0);
               }
               if(tierDataSource != null)
               {
                  coinsString = getDataProperty(tierDataSource,"coins");
               }
               else
               {
                  coinsString = getDataProperty(m_dataSource,"coins");
               }
            }
            else
            {
               coinsString = getDataProperty(m_dataSource,"coins");
            }
         }
         else if(Boolean(m_itemXML) && isTiered)
         {
            tierData = this.getItemTier(m_itemXML,1);
            if(Global.flashHotParams["BUILDING_GET_CURRENT_TIER"] == true && !tierData)
            {
               tierData = this.getItemTier(m_itemXML,0);
            }
            if(tierData != null)
            {
               coinsString = getXMLProperty(tierData,"coins");
            }
            else
            {
               coinsString = getXMLProperty(m_itemXML,"coins");
            }
         }
         else
         {
            coinsString = getXMLProperty(m_itemXML,"coins");
         }
         if(coinsString)
         {
            m_coins = int(coinsString);
         }
         else
         {
            m_coins = 0;
         }
         return m_coins;
      }
      
      override public function get cash() : int
      {
         var cashString:String = null;
         var offset:int = 0;
         var tiered:Boolean = false;
         var tierDataSource:BaseDataSource = null;
         var tierData:XML = null;
         var hasCashPriceTest:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_cashData)
            {
               tiered = m_cashData.getBoolean("tiered");
               if(tiered)
               {
                  if(className == "CraftingCottageBuilding")
                  {
                     offset = Global.player.getGlobalItemInstances("CraftingCottageBuilding");
                     tierDataSource = this.getActiveDSWithTierOffset(name,offset);
                  }
                  else
                  {
                     tierDataSource = this.getItemTierDS(m_cashData,1);
                     if(Global.flashHotParams["BUILDING_GET_CURRENT_TIER"] == true && !tierDataSource)
                     {
                        tierDataSource = this.getItemTierDS(m_cashData,0);
                     }
                  }
                  if(tierDataSource != null)
                  {
                     cashString = getDataProperty(tierDataSource,"cash");
                  }
                  else
                  {
                     cashString = getDataProperty(m_cashData,"cash");
                  }
               }
               else
               {
                  cashString = getDataProperty(m_cashData,"cash");
               }
               hasCashPriceTest = m_cashData.hasProperty("priceTest") && m_cashData.getString("priceTest") != "";
            }
         }
         else
         {
            if(Boolean(m_cashXML) && Boolean(m_cashXML.@tiered) && m_cashXML.@tiered == "true")
            {
               if(className == "CraftingCottageBuilding")
               {
                  offset = Global.player.getGlobalItemInstances("CraftingCottageBuilding");
                  tierData = this.getActiveXmlWithTierOffset(name,offset);
               }
               else
               {
                  tierData = this.getItemTier(m_cashXML,1);
                  if(Global.flashHotParams["BUILDING_GET_CURRENT_TIER"] == true && !tierData)
                  {
                     tierData = this.getItemTier(m_cashXML,0);
                  }
               }
               if(tierData != null)
               {
                  cashString = getXMLProperty(tierData,"cash");
               }
               else
               {
                  cashString = getXMLProperty(m_cashXML,"cash");
               }
            }
            else
            {
               cashString = getXMLProperty(m_cashXML,"cash");
            }
            hasCashPriceTest = this.cashXML.hasOwnProperty("priceTest") && this.cashXML.priceTest != null && this.cashXML.priceTest != "";
         }
         if(cashString)
         {
            m_cash = int(cashString);
         }
         else if(hasCashPriceTest)
         {
            m_cash = super.cash;
         }
         else
         {
            m_cash = 0;
         }
         var altPrice:int = testForVariablePricing();
         if(altPrice > 0)
         {
            m_cash = altPrice;
         }
         return m_cash;
      }
      
      override public function get saleCost() : int
      {
         var costString:String = null;
         var tierDataDS:BaseDataSource = null;
         var tierDataXml:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_saleData) && m_saleData.getBoolean("tiered"))
            {
               tierDataDS = this.getItemTierDS(m_saleData,1);
               if(tierDataDS != null)
               {
                  costString = getDataProperty(tierDataDS,"cost");
               }
               else
               {
                  costString = getDataProperty(m_saleData,"cost");
               }
            }
         }
         else if(Boolean(m_saleXML) && Boolean(m_saleXML.@tiered) && m_saleXML.@tiered == "true")
         {
            tierDataXml = this.getItemTier(m_saleXML,1);
            if(tierDataXml != null)
            {
               costString = getXMLProperty(tierDataXml,"cost");
            }
            else
            {
               costString = getXMLProperty(m_saleXML,"cost");
            }
         }
         else
         {
            costString = getXMLProperty(m_saleXML,"cost");
         }
         if(costString)
         {
            m_saleCost = int(costString);
         }
         else
         {
            m_saleCost = 0;
         }
         if(isDealOfDaySaleItem)
         {
            if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.COINS)
            {
               m_saleCost = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
            }
         }
         return m_saleCost;
      }
      
      override public function get saleCoins() : int
      {
         var coinsString:String = null;
         var tierDataDS:BaseDataSource = null;
         var tierDataXml:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_saleData) && m_saleData.getBoolean("tiered"))
            {
               tierDataDS = this.getItemTierDS(m_saleData,1);
               if(tierDataDS != null)
               {
                  coinsString = getDataProperty(tierDataDS,"coins");
               }
               else
               {
                  coinsString = getDataProperty(m_saleData,"coins");
               }
            }
         }
         else if(Boolean(m_saleXML) && Boolean(m_saleXML.@tiered) && m_saleXML.@tiered == "true")
         {
            tierDataXml = this.getItemTier(m_saleXML,1);
            if(tierDataXml != null)
            {
               coinsString = getXMLProperty(tierDataXml,"coins");
            }
            else
            {
               coinsString = getXMLProperty(m_saleXML,"coins");
            }
         }
         else
         {
            coinsString = getXMLProperty(m_saleXML,"coins");
         }
         if(coinsString)
         {
            m_saleCoins = int(coinsString);
         }
         else
         {
            m_saleCoins = 0;
         }
         if(isDealOfDaySaleItem)
         {
            if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.COINS)
            {
               m_saleCoins = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
            }
         }
         return m_saleCoins;
      }
      
      override public function get saleCash() : int
      {
         var cashString:String = null;
         var tierDataDS:BaseDataSource = null;
         var tierDataXml:XML = null;
         if(m_saleCash == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Boolean(m_saleData) && m_saleData.getBoolean("tiered"))
               {
                  tierDataDS = this.getItemTierDS(m_saleData,1);
                  if(tierDataDS)
                  {
                     cashString = getDataProperty(tierDataDS,"cash");
                     if(cashString)
                     {
                        m_saleCash = int(cashString);
                     }
                  }
               }
            }
            else if(Boolean(m_saleXML) && Boolean(m_saleXML.@tiered) && m_saleXML.@tiered == "true")
            {
               tierDataXml = this.getItemTier(m_saleXML,1);
               if(tierDataXml)
               {
                  cashString = getXMLProperty(tierDataXml,"cash");
                  if(cashString)
                  {
                     m_saleCash = int(cashString);
                  }
               }
            }
            if(isDealOfDaySaleItem)
            {
               if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.CASH)
               {
                  m_saleCash = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
               }
            }
         }
         return super.saleCash;
      }
      
      public function get bundle() : Boolean
      {
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getBoolean("bundle");
         }
         else if(m_itemXML.@bundle == "true")
         {
            result = true;
         }
         return result;
      }
      
      override public function get buyable() : Boolean
      {
         var isBuyableCoin:Boolean = false;
         var isBuyableCash:Boolean = false;
         var isBuyableSale:Boolean = false;
         var useDataSource:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(buyableWithCurrency())
         {
            if(useDataSource)
            {
               isBuyableCoin = m_dataSource.getBoolean("buyable");
            }
            else if(m_itemXML.@buyable == "true")
            {
               isBuyableCoin = true;
            }
         }
         if(this.buyableWithCash())
         {
            if(useDataSource)
            {
               isBuyableCash = m_cashData.getBoolean("buyable");
            }
            else if(m_cashXML.@buyable == "true")
            {
               isBuyableCash = true;
            }
         }
         if(useDataSource)
         {
            if(m_saleData)
            {
               isBuyableSale = m_saleData.getBoolean("buyable");
            }
         }
         else if(Boolean(m_saleXML) && m_saleXML.@buyable == "true")
         {
            isBuyableSale = true;
         }
         m_buyable = isBuyableCoin || isBuyableCash || isBuyableSale ? 1 : 0;
         return m_buyable > 0;
      }
      
      override public function get marketIsCoin() : Boolean
      {
         var marketType:String = super.market;
         return marketType == Currency.COINS || marketType == Currency.GOLD || marketType == Currency.BOTH || (marketType == null || marketType == "");
      }
      
      override public function get market() : String
      {
         var tierDataDS:BaseDataSource = null;
         var tierData:XML = null;
         var coinFlag:Boolean = false;
         var cashFlag:Boolean = false;
         if(isTiered)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_dataSource)
               {
                  tierDataDS = this.getItemTierDS(m_dataSource,1);
                  if(tierDataDS != null)
                  {
                     coinFlag = tierDataDS.getString("market") != Currency.CASH;
                  }
                  else
                  {
                     coinFlag = this.marketIsCoin;
                  }
               }
               else
               {
                  coinFlag = this.marketIsCoin;
               }
               if(m_cashData)
               {
                  tierDataDS = this.getItemTierDS(m_cashData,1);
                  if(tierDataDS != null)
                  {
                     cashFlag = tierDataDS.getString("market") == Currency.CASH;
                  }
                  else
                  {
                     cashFlag = m_cashData.getString("market") == Currency.CASH;
                  }
               }
               else
               {
                  cashFlag = this.cashDSMarket == Currency.CASH;
               }
            }
            else
            {
               if(m_itemXML)
               {
                  tierData = this.getItemTier(m_itemXML,1);
                  if(tierData != null)
                  {
                     coinFlag = tierData.@market != Currency.CASH;
                  }
                  else
                  {
                     coinFlag = this.marketIsCoin;
                  }
               }
               else
               {
                  coinFlag = this.marketIsCoin;
               }
               if(m_cashXML)
               {
                  tierData = this.getItemTier(m_cashXML,1);
                  if(tierData != null)
                  {
                     cashFlag = tierData.@market == Currency.CASH;
                  }
                  else
                  {
                     cashFlag = m_cashXML.@market == Currency.CASH;
                  }
               }
               else
               {
                  cashFlag = this.cashXMLMarket == Currency.CASH;
               }
            }
            if(coinFlag && cashFlag)
            {
               m_market = Currency.BOTH;
            }
            else if(cashFlag)
            {
               m_market = Currency.CASH;
            }
            else
            {
               m_market = Currency.COINS;
            }
            if(m_market == "")
            {
               m_market = Currency.COINS;
            }
         }
         else
         {
            m_market = super.market;
         }
         return m_market;
      }
      
      public function get levelRequired() : int
      {
         var levelString:String = null;
         var activeDS:BaseDataSource = null;
         var tierDataDS:BaseDataSource = null;
         var activeXML:XML = null;
         var tierData:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = getActiveDSForContext(this.m_currentContext);
            if(Boolean(activeDS) && isTiered)
            {
               tierDataDS = this.getItemTierDS(activeDS,1);
               if(tierDataDS != null)
               {
                  levelString = tierDataDS.getString("levelRequired");
               }
               else
               {
                  levelString = activeDS.getString("levelRequired");
               }
            }
            else
            {
               levelString = activeDS.getString("levelRequired");
            }
         }
         else
         {
            activeXML = getActiveXmlForContext(this.m_currentContext);
            if(Boolean(activeXML) && isTiered)
            {
               tierData = this.getItemTier(activeXML,1);
               if(tierData != null)
               {
                  levelString = getXMLProperty(tierData,"levelRequired");
               }
               else
               {
                  levelString = getXMLProperty(activeXML,"levelRequired");
               }
            }
            else
            {
               levelString = getXMLProperty(activeXML,"requiredLevel");
            }
         }
         if(levelString)
         {
            this.m_levelRequired = int(levelString);
         }
         else
         {
            this.m_levelRequired = 0;
         }
         return this.m_levelRequired;
      }
      
      public function get neighborsRequired() : int
      {
         var neighborsString:String = null;
         var neighborFeatureKey:String = null;
         var additionalNeighbors:int = 0;
         var neighborMinimum:int = 0;
         var neighborMaximum:int = 0;
         var capturedNeighbors:int = 0;
         var proposedNeighbors:int = 0;
         var activeDS:BaseDataSource = null;
         var tierDataSource:BaseDataSource = null;
         var activeXML:XML = null;
         var tierData:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = getActiveDSForContext(this.m_currentContext);
            if(Boolean(activeDS) && isTiered)
            {
               tierDataSource = this.getItemTierDS(activeDS,1);
               if(tierDataSource)
               {
                  neighborsString = getDataProperty(tierDataSource,"neighborsRequired");
                  if(!neighborsString && tierDataSource.hasProperty("neighborKey"))
                  {
                     neighborFeatureKey = getDataProperty(tierDataSource,"neighborKey");
                     additionalNeighbors = getDataPropertyAsInt(tierDataSource,"additionalNeighbors");
                     neighborMinimum = getDataPropertyAsInt(tierDataSource,"neighborMinimum");
                     neighborMaximum = getDataPropertyAsInt(tierDataSource,"neighborMaximum");
                     capturedNeighbors = Global.player.getBaseLineFriendsForFeature(neighborFeatureKey);
                     proposedNeighbors = capturedNeighbors + additionalNeighbors;
                     proposedNeighbors = Math.min(proposedNeighbors,neighborMaximum);
                     proposedNeighbors = Math.max(proposedNeighbors,neighborMinimum);
                     neighborsString = String(proposedNeighbors);
                  }
               }
               else
               {
                  neighborsString = getDataProperty(activeDS,"neighborsRequired");
               }
            }
            else
            {
               neighborsString = getDataProperty(activeDS,"neighborsRequired");
            }
         }
         else
         {
            activeXML = getActiveXmlForContext(this.m_currentContext);
            if(Boolean(activeXML) && isTiered)
            {
               tierData = this.getItemTier(activeXML,1);
               if(tierData != null)
               {
                  neighborsString = getXMLProperty(tierData,"neighborsRequired");
                  if(!neighborsString && tierData.hasOwnProperty("neighborKey"))
                  {
                     neighborFeatureKey = getXMLProperty(tierData,"neighborKey");
                     additionalNeighbors = getXMLPropertyAsInt(tierData,"additionalNeighbors");
                     neighborMinimum = getXMLPropertyAsInt(tierData,"neighborMinimum");
                     neighborMaximum = getXMLPropertyAsInt(tierData,"neighborMaximum");
                     capturedNeighbors = Global.player.getBaseLineFriendsForFeature(neighborFeatureKey);
                     proposedNeighbors = capturedNeighbors + additionalNeighbors;
                     proposedNeighbors = Math.min(proposedNeighbors,neighborMaximum);
                     proposedNeighbors = Math.max(proposedNeighbors,neighborMinimum);
                     neighborsString = String(proposedNeighbors);
                  }
               }
               else
               {
                  neighborsString = getXMLProperty(activeXML,"neighborsRequired");
               }
            }
            else
            {
               neighborsString = getXMLProperty(activeXML,"neighborsRequired");
            }
         }
         if(neighborsString)
         {
            this.m_neighborsRequired = int(neighborsString);
         }
         else
         {
            this.m_neighborsRequired = 0;
         }
         return this.m_neighborsRequired;
      }
      
      public function isFullyUpgraded() : Boolean
      {
         var arr:Array = null;
         var featureArr:Array = null;
         var curDS:BaseDataSource = null;
         var upgradeArr:Array = null;
         var upgradeDS:BaseDataSource = null;
         var i:int = 0;
         var j:int = 0;
         var list:XMLList = null;
         var hasLevelsGreater:Boolean = false;
         var initialExpansionLevel:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            initialExpansionLevel = m_dataSource.getInt("initialExpansionLevel");
            if(m_dataSource.hasProperty("upgrade"))
            {
               arr = m_dataSource.getArray("upgrade");
            }
            else
            {
               featureArr = m_dataSource.getArray("feature","features");
               for(i = 0; i < featureArr.length; i++)
               {
                  curDS = featureArr[i] as BaseDataSource;
                  if(curDS.getString("name") == "expand")
                  {
                     upgradeArr = curDS.getArray("upgrade");
                     for(j = 0; j < upgradeArr.length; j++)
                     {
                        upgradeDS = upgradeArr[j] as BaseDataSource;
                        if(upgradeDS.getInt("level") > initialExpansionLevel)
                        {
                           arr.push(upgradeDS);
                        }
                     }
                  }
               }
            }
            hasLevelsGreater = !arr || arr.length < 1;
         }
         else
         {
            initialExpansionLevel = int(m_itemXML.initialExpansionLevel);
            list = null;
            if(m_itemXML.hasOwnProperty("upgrade"))
            {
               list = m_itemXML.upgrade.(@level > initialExpansionLevel);
            }
            else if(m_itemXML.hasOwnProperty("features") && m_itemXML.features.hasOwnProperty("feature"))
            {
               list = m_itemXML.features.feature.(@name == "expand");
               if(list != null && list.hasOwnProperty("upgrade"))
               {
                  list = list.upgrade.(@level > initialExpansionLevel);
               }
            }
            hasLevelsGreater = list == null || list.length() == 0;
         }
         return hasLevelsGreater;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var initialExpansionLevel:int = 0;
         var item:FarmItem = null;
         var iconPopup:GenericPopup = null;
         var currency:String = null;
         var paint:Boolean = false;
         var hasInitialExpansionLevel:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            paint = m_dataSource.getBoolean("paint");
            hasInitialExpansionLevel = m_dataSource.hasProperty("initialExpansionLevel");
            if(hasInitialExpansionLevel)
            {
               initialExpansionLevel = m_dataSource.getInt("initialExpansionLevel");
            }
         }
         else
         {
            paint = m_itemXML.hasOwnProperty("@paint") && m_itemXML.@paint.toString() == "true";
            hasInitialExpansionLevel = m_itemXML.hasOwnProperty("initialExpansionLevel");
            if(hasInitialExpansionLevel)
            {
               initialExpansionLevel = int(m_itemXML.initialExpansionLevel);
            }
         }
         if(className == "BuildingPart")
         {
            if(Global.player.getSeenFlag("FirstBuildingMaterialPurchase"))
            {
               Global.player.setSeenFlag("FirstBuildingMaterialPurchase");
               iconPopup = new GenericPopup(ZLocUtils.t("Dialogs","FirstBuildingMaterialBuy"));
               iconPopup.setAcceptTextName("Okay");
               UI.displayPopup(iconPopup);
            }
            BuildingItemUseMediator.getInstance().mediate(name,false);
            item = Global.farmGameSettingsManager.getFarmItemByName(name);
            Global.player.xp += item.xpGained;
         }
         else if(paint)
         {
            Global.world.addGameMode(new GMPaintBuilding(name,false),false);
         }
         else if(className == DoghouseTreat.CLASS_NAME)
         {
            BuildingItemUseMediator.getInstance().mediate(name,false);
         }
         else if(className == "WateringCan")
         {
            BuildingItemUseMediator.getInstance().mediate(name,false);
         }
         else if(subType == "consumable")
         {
            TransactionManager.addTransaction(new TBuyConsumables(name,false));
         }
         else
         {
            extraData = null == extraData ? {} : extraData;
            if(hasInitialExpansionLevel)
            {
               extraData.expansionLevel = initialExpansionLevel;
            }
            else if(this.cash > 0)
            {
               extraData.expansionLevel = 1;
            }
            currency = "";
            if(extraData != null && extraData.hasOwnProperty("currency"))
            {
               currency = extraData["currency"];
            }
            Global.world.addGameMode(new GMBuild(name,false,0,true,extraData,currency));
         }
         Global.farmGameSettingsManager.updateItemByName(name);
         return true;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var suppressGiftRepop:Boolean = false;
         var metadata:Object = null;
         var shouldRepopGift:Boolean = false;
         var isGift:Boolean = true;
         suppressGiftRepop = false;
         var combineTransactions:Boolean = true;
         var storageBuilding:StorageBuilding = null;
         var numParts:int = 1;
         if(extraData)
         {
            if(extraData.repopGift != null)
            {
               extraData.suppressGiftRepop = !extraData.repopGift;
            }
            if(extraData.suppressGiftRepop != null)
            {
               suppressGiftRepop = Boolean(extraData.suppressGiftRepop);
            }
            if(extraData.isGift != null && extraData.isGift == false)
            {
               isGift = false;
            }
            if(extraData.storageBuilding != null)
            {
               storageBuilding = extraData.storageBuilding;
            }
            if(extraData.numParts != null)
            {
               numParts = int(extraData.numParts);
            }
            if(extraData.combineTransactions != null)
            {
               combineTransactions = Boolean(extraData.combineTransactions);
            }
         }
         var itemName:String = name;
         if(Boolean(extraData) && extraData.realItemName != null)
         {
            itemName = extraData.realItemName;
         }
         var hasPaint:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            hasPaint = m_dataSource.getBoolean("paint");
         }
         else
         {
            hasPaint = m_itemXML.hasOwnProperty("@paint") && m_itemXML.@paint.toString() == "true";
         }
         if(hasPaint)
         {
            Global.world.addGameMode(new GMPaintBuilding(itemName,true),false);
         }
         else
         {
            metadata = null;
            switch(className)
            {
               case "BuildingPart":
               case DoghouseTreat.CLASS_NAME:
               case "WateringCan":
                  BuildingItemUseMediator.getInstance().mediate(name,isGift,storageBuilding,suppressGiftRepop,true,numParts,combineTransactions);
                  break;
               case "MutableAnimalBaby":
                  if(isGift)
                  {
                     metadata = Global.player.getGiftMetadata(code);
                  }
                  Global.world.addGameMode(new GMMutableAnimalBabyPlace(metadata,name,isGift,buildingId,false,0),false);
                  break;
               case "MutableAnimalCrate":
                  if(isGift)
                  {
                     metadata = Global.player.getGiftMetadata(code);
                  }
                  if(Boolean(extraData) && extraData.hasOwnProperty("metadata"))
                  {
                     metadata = extraData.metadata;
                  }
                  Global.world.addGameMode(new GMMutableAnimalCratePlace(metadata,name,isGift,buildingId,false),false);
                  break;
               case "MysterySeedling":
                  if(isGift)
                  {
                     metadata = Global.player.getGiftMetadata(code);
                  }
                  if(Boolean(extraData) && extraData.hasOwnProperty("metadata"))
                  {
                     metadata = extraData.metadata;
                  }
                  Global.world.addGameMode(new GMMysterySeedlingPlace(metadata,name,isGift,buildingId,false),false);
                  break;
               default:
                  shouldRepopGift = isToolGenerated ? false : !suppressGiftRepop;
                  Global.world.addGameMode(new GMBuild(itemName,isGift,buildingId,shouldRepopGift,extraData));
            }
         }
      }
      
      override protected function defaultPreview() : Boolean
      {
         return className != "BuildingPart" && placeable;
      }
      
      override public function getPreviewState() : String
      {
         return "built";
      }
      
      public function resetCurrentContext() : void
      {
         this.m_currentContext = FarmItem.MARKET_CONTEXT_COINS;
      }
      
      public function get lookInsideOnFinishPlace() : Boolean
      {
         if(this.m_lookInsideOnFinishPlace == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_lookInsideOnFinishPlace = m_dataSource.getString("lookInsideOnFinishPlace");
            }
            else
            {
               this.m_lookInsideOnFinishPlace = getXMLProperty(m_itemXML,"lookInsideOnFinishPlace");
            }
         }
         return this.m_lookInsideOnFinishPlace == "true";
      }
      
      public function get neighborLookInside() : Boolean
      {
         var experimentName:String = null;
         var exp:String = null;
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.getBoolean("neighborLookInside"))
            {
               experimentName = m_dataSource.getString("neighborLookInside");
               if(Boolean(experimentName) && Global.experimentManager.getExperimentVariant(experimentName) > 0)
               {
                  result = true;
               }
               else if(!experimentName)
               {
                  result = true;
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("neighborLookInside") && m_itemXML.neighborLookInside.toString() == "true")
         {
            if(m_itemXML.neighborLookInside.hasOwnProperty("@experiment"))
            {
               exp = m_itemXML.neighborLookInside["@experiment"];
               if(Global.experimentManager.getExperimentVariant(exp) > 0)
               {
                  result = true;
               }
            }
            else
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get neighborAction() : String
      {
         var neighborActionData:BaseDataSource = null;
         var neighborActionXML:XML = null;
         if(this.m_neighborAction == null)
         {
            this.m_neighborAction = "";
            if(m_dataSource)
            {
               neighborActionData = getFeatureDataByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionData)
               {
                  this.m_neighborAction = neighborActionData.getString("type");
               }
            }
            else
            {
               neighborActionXML = getFeatureXMLByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionXML)
               {
                  this.m_neighborAction = String(neighborActionXML.type);
               }
            }
         }
         return this.m_neighborAction;
      }
      
      public function get neighborActionKey() : String
      {
         var neighborActionData:BaseDataSource = null;
         var neighborActionXML:XML = null;
         if(this.m_neighborActionKey == null)
         {
            this.m_neighborActionKey = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               neighborActionData = getFeatureDataByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionData)
               {
                  this.m_neighborActionKey = neighborActionData.getString("key");
               }
            }
            else
            {
               neighborActionXML = getFeatureXMLByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionXML)
               {
                  this.m_neighborActionKey = String(neighborActionXML.key);
               }
            }
         }
         return this.m_neighborActionKey;
      }
      
      public function get neighborActionLimit() : int
      {
         var neighborActionData:BaseDataSource = null;
         var neighborActionXML:XML = null;
         if(this.m_neighborActionLimit == INVALID_VALUE)
         {
            this.m_neighborActionLimit = 0;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               neighborActionData = getFeatureDataByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionData)
               {
                  this.m_neighborActionLimit = neighborActionData.getInt("limit");
               }
            }
            else
            {
               neighborActionXML = getFeatureXMLByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
               if(neighborActionXML)
               {
                  this.m_neighborActionLimit = int(neighborActionXML.limit);
               }
            }
         }
         return this.m_neighborActionLimit;
      }
      
      public function get paintable() : Boolean
      {
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getBoolean("paintable");
         }
         else if(m_itemXML.hasOwnProperty("@paintable") && m_itemXML.@paintable.toString() == "true")
         {
            result = true;
         }
         return result;
      }
      
      public function get completeWorldScore() : int
      {
         return this.m_completeWorldScore;
      }
      
      public function set completeWorldScore(value:int) : void
      {
         this.m_completeWorldScore = value;
      }
      
      public function get completeWorldScoreUnit() : String
      {
         return this.m_completeWorldScoreUnit;
      }
      
      public function set completeWorldScoreUnit(value:String) : void
      {
         this.m_completeWorldScoreUnit = value;
      }
   }
}

