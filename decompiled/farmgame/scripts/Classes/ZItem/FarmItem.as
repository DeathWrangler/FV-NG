package Classes.ZItem
{
   import Classes.Animal;
   import Classes.AreasOfEffect.AOEConfig;
   import Classes.Building;
   import Classes.CaptureFeatureItem;
   import Classes.Constants.BlossomConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.DataSources.OptItemDataSource;
   import Classes.DataSources.XMLDataSource;
   import Classes.DealOfDayHelper;
   import Classes.Decoration;
   import Classes.DisplayLoading.MapResourceDL;
   import Classes.FarmGameWorld;
   import Classes.FeatureComponents.FeatureManager;
   import Classes.FriendSetGoal;
   import Classes.ItemImage;
   import Classes.ItemRequirement;
   import Classes.ManagedSale;
   import Classes.MapResource;
   import Classes.MarketCardDescriptor;
   import Classes.MarketMapping;
   import Classes.MessageSign;
   import Classes.Plot;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.Terrain.TerrainUtil;
   import Classes.Tree;
   import Classes.WorldLicenseRequirement;
   import Classes.WorldRequirement;
   import Classes.consumables.CPigoGameToken;
   import Classes.storage.StorageItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataObjects.Items.ItemFeatures.FeatureInfiniteUpgradeDataDO;
   import DataSources.BaseDataSource;
   import DataSources.DataObjectDataSource;
   import Display.UI;
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import Managers.AOEManager;
   import Managers.ExperimentManager;
   import Managers.FarmGameSettingsManager;
   import Managers.LicenseManager;
   import Managers.LoyaltyProgramManager;
   import Managers.ManagedSalesManager;
   import Managers.MarketFlashSaleManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Market.MarketPreviewWindow;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class FarmItem extends ZItemBase
   {
      
      public static const ICON_200:String = "icon200";
      
      public static const ICON_FEED:String = "feed";
      
      public static const CASH_ATTRIBUTE_NAME:String = "cash";
      
      public static const COST_ATTRIBUTE_NAME:String = "cost";
      
      public static const PRICE_TEST_ELEMENT_NAME:String = "priceTest";
      
      public static const RT_SILO_MAX_LEVEL_UPGRADE_NAME:String = "FEATURE_SILO_CAPACITY_LEVEL_CAP";
      
      public static const UNLOCKED:String = "unlocked";
      
      public static const EXPERIMENT_NOT_CACHED:int = -1;
      
      public static const EXPERIMENT_INACTIVE:int = 0;
      
      public static const EXPERIMENT_ACTIVE:int = 1;
      
      public static const MARKET_CONTEXT_COINS:String = "coins";
      
      public static const MARKET_CONTEXT_CASH:String = "cash";
      
      public static const MARKET_CONTEXT_SALE:String = "sale";
      
      public static const ITEM_POSTFIX_CASH:String = "_cash";
      
      public static const ITEM_POSTFIX_SALE:String = "_sale";
      
      public static const GEOIP_XML_ELEMENT_NAME:String = "geoip";
      
      public static const SUPER_CROP_DEFAULT_UNLOCK_COST:int = 10;
      
      public static const DONATION_CURRENCY_FC:String = "FC";
      
      public static const DONATION_CURRENCY_FC_MULTI:String = "FC_MULTI";
      
      private static const DONATION_CURRENCY_DEFAULT:String = DONATION_CURRENCY_FC;
      
      private static const PROP_DONATION_CURRENCY:String = "donationCurrency";
      
      public static const VARIABLE_PRICING_ON_LEVEL:String = "level";
      
      public static const VARIABLE_PRICING_ON_WORLD_LEVEL:String = "world_level";
      
      public static const VARIABLE_PRICING_ON_WORLD_SCORE:String = "world_score";
      
      public static const TYPE_ARRAY_TYPE_INDEX:int = 0;
      
      protected static const m_defaultTerrains:Array = new Array(FarmGameSettingsManager.TERRAIN_LAND,FarmGameSettingsManager.TERRAIN_SHORELINE,FarmGameSettingsManager.TERRAIN_TERRACE,FarmGameSettingsManager.TERRAIN_UNDERWATER,FarmGameSettingsManager.TERRAIN_EARTH);
      
      private static const DEFAULT_FREE_GIFT_COLOR:uint = 9544362;
      
      private static const typeToClassMapping:Object = {
         "seed":Plot,
         "plot":Plot,
         "tree":Tree,
         "building":Building,
         "animal":Animal,
         "decoration":Decoration,
         "messageSign":MessageSign,
         "gopher":CaptureFeatureItem,
         "consumable":null,
         "fuel":null
      };
      
      protected var m_cashName:String = null;
      
      protected var m_saleName:String = null;
      
      protected var m_cashCode:String = null;
      
      protected var m_saleCode:String = null;
      
      protected var m_saleCost:int = -559038227;
      
      protected var m_saleCoins:int = -559038227;
      
      protected var m_saleCash:int = -559038227;
      
      protected var m_sellPrice:int = -559038227;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_subsubtype:String = null;
      
      protected var m_keyword:String = null;
      
      protected var m_actionBundle:String = null;
      
      protected var m_limitedQuantity:String = null;
      
      protected var m_className:String = null;
      
      protected var m_giftUseMultiselect:Boolean = false;
      
      protected var m_resourcePrefix:String = null;
      
      protected var m_category:String = null;
      
      protected var m_substitutionString:String = null;
      
      protected var m_hasRequirements:int = -1;
      
      protected var m_requirements:Array = null;
      
      protected var m_hasStats:Boolean = false;
      
      protected var m_sounds:Array = null;
      
      protected var m_showFeed:int = -1;
      
      protected var m_multiplace:int = -1;
      
      protected var m_ignoreMarketSort:int = -1;
      
      protected var m_unlock:String = null;
      
      protected var m_market:String = null;
      
      protected var m_cashXMLMarket:String = null;
      
      protected var m_cashDSMarket:String = null;
      
      protected var m_experiment:String = null;
      
      protected var m_experimentVariant:Number = -559038227;
      
      protected var m_experimentActive:int = -1;
      
      protected var m_cashExperimentActive:int = -1;
      
      protected var m_coinExperimentActive:int = -1;
      
      protected var m_dealOfDayExperimentActive:int = -1;
      
      protected var m_priceTest:String = null;
      
      protected var m_gateCode:String = null;
      
      protected var m_promoMode:String = null;
      
      protected var m_colorGroup:String = null;
      
      protected var m_marketInfoURL:String = null;
      
      protected var m_lootTable:String = null;
      
      protected var m_licenseCode:String = null;
      
      protected var m_itemLicense:ItemLicense = null;
      
      protected var m_newsfeedUrl:String = null;
      
      protected var m_unlockCost:Number = -559038227;
      
      protected var m_specialSortPriority:Number = -559038227;
      
      protected var m_size:Number = -559038227;
      
      protected var m_sizeX:int = -559038227;
      
      protected var m_sizeY:int = -559038227;
      
      protected var m_minNeighbors:Number = -559038227;
      
      protected var m_whatIsThis:int = -1;
      
      protected var m_whatIsThisDialog:String = null;
      
      protected var m_isPresent:int = -1;
      
      protected var m_isSpecialValentinesItem:int = -1;
      
      protected var m_isGameToken:int = -1;
      
      protected var m_buyable:int = -1;
      
      protected var m_giftable:int = -1;
      
      protected var m_consumable:int = -559038227;
      
      protected var m_isTiered:int = -1;
      
      protected var m_totalTiers:int = -559038227;
      
      protected var m_marketCardDescriptor:MarketCardDescriptor = null;
      
      protected var m_marketCardName:String = null;
      
      protected var m_hideHarvestPick:String = null;
      
      protected var m_tooltipKey:String = null;
      
      protected var m_placeable:int = -1;
      
      protected var m_canUseFromGiftBox:int = -1;
      
      protected var m_preview:int = -1;
      
      protected var m_superCrop:int = -559038227;
      
      protected var m_creationTimestamp:Number = -1;
      
      protected var m_isLimited:int = -1;
      
      protected var m_hasLimitedStartEnd:int = -1;
      
      protected var m_hasLimitedStart:int = -1;
      
      protected var m_cashXML:XML = null;
      
      protected var m_cashData:BaseDataSource = null;
      
      protected var m_saleXML:XML = null;
      
      protected var m_saleData:BaseDataSource = null;
      
      protected var m_collisionData:Vector.<Vector.<int>> = null;
      
      protected var m_displayLoader:MapResourceDL = null;
      
      protected var m_limitedLocale:String = null;
      
      protected var m_limitedGiftStart:String = "";
      
      protected var m_limitedGiftEnd:String = "";
      
      protected var m_friendlyTitle:String = "";
      
      protected var m_friendlyTitlePlural:String = "";
      
      private var m_searchTitle:String = "";
      
      protected var m_statsCounter:String = null;
      
      protected var m_incrementalGateType:String = null;
      
      protected var m_worldRestrictions:Array = null;
      
      protected var m_friendSetGoal:FriendSetGoal = null;
      
      protected var m_basket:String = null;
      
      protected var m_basketClass:String = null;
      
      protected var m_ugcTransforms:Object = null;
      
      private var m_hasCheckedMarketEntries:Boolean;
      
      private var m_marketEntries:Object = null;
      
      protected var m_marketEntriesHash:Object = null;
      
      protected var m_market3EntriesHash:Object = null;
      
      protected var m_market3EntriesTypeArray:Array = null;
      
      protected var m_max:int = -559038227;
      
      protected var m_subcreditsType:String = null;
      
      protected var m_prefixUrl:String = null;
      
      protected var m_donations:Array = null;
      
      protected var m_donationCurrency:String = null;
      
      protected var m_toolGenerated:Boolean = false;
      
      protected var m_expires:Boolean = true;
      
      protected var m_toolGeneratedAssetFile:String = "";
      
      protected var m_terrainCodes:Array = null;
      
      protected var m_terrainSetCodes:Array = null;
      
      protected var m_buyWorldScore:int = 0;
      
      protected var m_buyWorldScoreUnit:String = "";
      
      private var m_upgradeWorldScoreReward:Array = null;
      
      protected var m_freeGiftColor:uint = 16777215;
      
      protected var m_freeGiftTitle:String = null;
      
      protected var m_aoeConfig:AOEConfig;
      
      protected var m_isDealOfDaySaleItem:Boolean = false;
      
      private var m_materialPrice:Object;
      
      private var m_aoeTargetKeywords:Array;
      
      private var m_aoeImageState:String = null;
      
      protected var m_imageProgressionClassName:String = null;
      
      protected var m_eventName:String = null;
      
      protected var m_stencilArea:Dictionary = null;
      
      private var m_aoeLicenseKey:String = null;
      
      public function FarmItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public static function getMarketContextByName(name:String) : String
      {
         var result:String = FarmItem.MARKET_CONTEXT_COINS;
         if(name.indexOf("_cash") > 0)
         {
            result = FarmItem.MARKET_CONTEXT_CASH;
         }
         else if(name.indexOf("_cash") > 0)
         {
            result = FarmItem.MARKET_CONTEXT_SALE;
         }
         return result;
      }
      
      public static function getMapResourceClassByType(type:String, className:String = null) : Class
      {
         var mapResourceClass:Class = null;
         if(className)
         {
            mapResourceClass = getDefinitionByName("Classes." + className) as Class;
         }
         else if(typeToClassMapping.hasOwnProperty(type))
         {
            mapResourceClass = typeToClassMapping[type];
         }
         else if(Config.DEBUG_MODE)
         {
            throw new Error("Class name for item type:" + type + " className:" + className + " not found");
         }
         return mapResourceClass;
      }
      
      public static function getPlayerStatForVariablePricing(stat:String, statSubtype:String = "") : Number
      {
         var result:Number = 0;
         switch(stat)
         {
            case VARIABLE_PRICING_ON_LEVEL:
               result = Global.player.level;
               break;
            case VARIABLE_PRICING_ON_WORLD_LEVEL:
               if(Global.player.worldScores[statSubtype])
               {
                  result = Global.player.getWorldLevel(statSubtype);
                  break;
               }
               throw new Error("Unsupported world subtype: " + statSubtype);
               break;
            case VARIABLE_PRICING_ON_WORLD_SCORE:
               if(Global.player.worldScores[statSubtype])
               {
                  result = Global.player.getWorldScore(statSubtype);
                  break;
               }
               throw new Error("Unsupported world subtype: " + statSubtype);
               break;
            default:
               throw new Error("Unsupported stat for variable pricing: " + stat);
         }
         return result;
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         var imageProgressionClass:String = null;
         var aoeData:BaseDataSource = null;
         var materialArray:Array = null;
         var materialCount:int = 0;
         var i:int = 0;
         var materials:XMLList = null;
         var j:int = 0;
         super.onConstruction(itemXML,itemData);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageProgressionClass = m_dataSource.getString("imageProgressionClass");
            if(imageProgressionClass)
            {
               this.m_imageProgressionClassName = imageProgressionClass;
            }
            this.m_toolGenerated = m_dataSource.getBoolean("toolGenerated");
            this.m_giftUseMultiselect = m_dataSource.getBoolean("giftUseMultiselect");
            this.m_expires = !m_dataSource.hasProperty("expires") || m_dataSource.getBoolean("expires");
            aoeData = m_dataSource.getData("aoe");
            if(aoeData)
            {
               this.m_aoeConfig = new AOEConfig(code,null,aoeData);
               AOEManager.getInstance().addConfig(this.m_aoeConfig);
            }
            materialArray = m_dataSource.getArray("materialPrice","material");
            materialCount = int(materialArray.length);
            if(materialCount > 0)
            {
               this.m_materialPrice = new Object();
               for(i = 0; i < materialCount; i++)
               {
                  this.m_materialPrice[materialArray[i].getString("name")] = materialArray[i].getInt("quantity");
               }
            }
         }
         else
         {
            if(itemXML.hasOwnProperty("imageProgressionClass"))
            {
               this.m_imageProgressionClassName = itemXML.imageProgressionClass;
            }
            if(Boolean(itemXML.@toolGenerated) && itemXML.@toolGenerated == "true")
            {
               this.m_toolGenerated = true;
            }
            if(Boolean(itemXML.@giftUseMultiselect) && itemXML.@giftUseMultiselect == "true")
            {
               this.m_giftUseMultiselect = true;
            }
            if(itemXML.@expires != null && itemXML.@expires.toString() == "false")
            {
               this.m_expires = false;
            }
            if(m_itemXML.hasOwnProperty("aoe"))
            {
               this.m_aoeConfig = new AOEConfig(code,m_itemXML.aoe);
               AOEManager.getInstance().addConfig(this.m_aoeConfig);
            }
            if(m_itemXML.hasOwnProperty("materialPrice"))
            {
               this.m_materialPrice = new Object();
               materials = m_itemXML.materialPrice.material;
               for(j = 0; j < materials.length(); j++)
               {
                  this.m_materialPrice[String(materials[j].@name)] = int(materials[j].@quantity);
               }
            }
         }
      }
      
      override public function readExternal(input:IDataInput) : void
      {
         this.m_cashData = input.readObject();
         this.m_saleData = input.readObject();
         super.readExternal(input);
      }
      
      override public function writeExternal(output:IDataOutput) : void
      {
         output.writeObject(this.m_cashData);
         output.writeObject(this.m_saleData);
         super.writeExternal(output);
      }
      
      protected function copyDataSource(sourceItem:FarmItem) : void
      {
         m_dataSource = sourceItem.dataSource;
      }
      
      protected function getDefaultTerrains() : Array
      {
         return FarmItem.m_defaultTerrains;
      }
      
      public function get imageProgressionClassName() : String
      {
         return this.m_imageProgressionClassName;
      }
      
      public function get isToolGenerated() : Boolean
      {
         return this.m_toolGenerated;
      }
      
      public function get aoeImageState() : String
      {
         return this.m_aoeImageState;
      }
      
      public function set aoeImageState(imageState:String) : void
      {
         this.m_aoeImageState = imageState;
      }
      
      public function get expires() : Boolean
      {
         return this.m_expires;
      }
      
      public function getMapResourceClass() : Class
      {
         return FarmItem.getMapResourceClassByType(this.type,this.className);
      }
      
      private function get creationDate() : String
      {
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("creationDate");
            if(!result)
            {
               result = m_dataSource.getString("limitedStart");
            }
         }
         else if(m_itemXML.creationDate)
         {
            result = m_itemXML.creationDate;
         }
         else if(m_itemXML.limitedStart)
         {
            result = m_itemXML.limitedStart;
         }
         return result;
      }
      
      public function get harvestItem() : String
      {
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("harvestItem");
         }
         else if(m_itemXML.harvestItem)
         {
            result = m_itemXML.harvestItem;
         }
         return result;
      }
      
      public function get creationTimestamp() : Number
      {
         if(this.m_creationTimestamp < 0)
         {
            this.m_creationTimestamp = FarmGameUtil.synchronizedDateToNumber(this.creationDate);
         }
         return this.m_creationTimestamp;
      }
      
      public function get isNew() : Boolean
      {
         var cutoff:Number = Global.marketConfigSettings.getNewItemCutoff();
         return Boolean(cutoff) && this.creationTimestamp > cutoff;
      }
      
      public function get cashName() : String
      {
         if(this.m_cashName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
            {
               this.m_cashName = this.m_cashData.getString("name");
            }
            else if(this.m_cashXML)
            {
               this.m_cashName = this.m_cashXML.@name;
            }
         }
         return this.m_cashName;
      }
      
      public function get saleName() : String
      {
         if(this.m_saleName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
            {
               this.m_saleName = this.m_saleData.getString("name");
            }
            else if(this.m_saleXML != null)
            {
               this.m_saleName = this.m_saleXML.@name;
            }
         }
         return this.m_saleName;
      }
      
      public function get cashCode() : String
      {
         if(this.m_cashCode == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
            {
               this.m_cashCode = this.m_cashData.getString("code");
            }
            else if(this.m_cashXML != null)
            {
               this.m_cashCode = this.m_cashXML.@code;
            }
         }
         return this.m_cashCode;
      }
      
      public function get saleCode() : String
      {
         if(this.m_saleCode == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
            {
               this.m_saleCode = this.m_saleData.getString("code");
            }
            else if(this.m_saleXML != null)
            {
               this.m_saleCode = this.m_saleXML.@code;
            }
         }
         return this.m_saleCode;
      }
      
      public function get saleCost() : int
      {
         var costString:String = null;
         if(this.m_saleCost == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               costString = this.getDataProperty(this.m_saleData,"cost");
            }
            else
            {
               costString = this.getXMLProperty(this.m_saleXML,"cost");
            }
            this.m_saleCost = int(costString);
            if(this.isDealOfDaySaleItem)
            {
               if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.COINS)
               {
                  this.m_saleCost = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
               }
            }
         }
         return this.m_saleCost;
      }
      
      public function get stencilArea() : Dictionary
      {
         if(this.m_stencilArea == null)
         {
            this.m_stencilArea = new Dictionary();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_stencilArea["height"] = m_dataSource.getNumber("stencilHeight");
               this.m_stencilArea["width"] = m_dataSource.getNumber("stencilWidth");
            }
            else
            {
               this.m_stencilArea["height"] = Number(m_itemXML.stencilHeight);
               this.m_stencilArea["width"] = Number(m_itemXML.stencilWidth);
            }
         }
         return this.m_stencilArea;
      }
      
      public function get saleCoins() : int
      {
         var coinsString:String = null;
         if(this.m_saleCoins == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               coinsString = this.getDataProperty(this.m_saleData,"coins");
            }
            else
            {
               coinsString = this.getXMLProperty(this.m_saleXML,"coins");
            }
            this.m_saleCoins = int(coinsString);
            if(this.isDealOfDaySaleItem)
            {
               if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.COINS)
               {
                  this.m_saleCoins = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
               }
            }
         }
         return this.m_saleCoins;
      }
      
      public function get saleCash() : int
      {
         var cashString:String = null;
         var saleValue:int = 0;
         if(this.m_saleCash == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cashString = this.getDataProperty(this.m_saleData,"cash");
            }
            else
            {
               cashString = this.getXMLProperty(this.m_saleXML,"cash");
            }
            this.m_saleCash = int(cashString);
         }
         var managedSalePrice:int = 0;
         var worldSalePrice:int = 0;
         var categorySalePrice:int = 0;
         var sale:ManagedSale = ManagedSalesManager.getSaleObject(this);
         this.m_saleCash = m_cash;
         if(Boolean(sale) && sale.isActive())
         {
            managedSalePrice = sale.price;
            this.m_saleCash = Math.min(this.m_saleCash,managedSalePrice);
         }
         if(Global.worldSpecificSalesManager.isActive() && Global.worldSpecificSalesManager.inSale(this))
         {
            worldSalePrice = Math.max(1,Global.worldSpecificSalesManager.price(m_cash));
            this.m_saleCash = Math.min(this.m_saleCash,worldSalePrice);
         }
         if(Global.categorySpecificSalesManager.isActive() && Global.categorySpecificSalesManager.inSale(this))
         {
            categorySalePrice = Math.max(1,Global.categorySpecificSalesManager.price(m_cash));
            this.m_saleCash = Math.min(this.m_saleCash,categorySalePrice);
         }
         if(this.isDealOfDaySaleItem)
         {
            if(DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.CASH)
            {
               this.m_saleCash = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
            }
         }
         var result:Number = this.m_saleCash;
         if(MarketFlashSaleManager.instance.isSaleActive())
         {
            saleValue = MarketFlashSaleManager.instance.getItemSaleCashCost(this);
            if(result > 0)
            {
               result = Math.min(result,saleValue);
            }
            else
            {
               result = saleValue;
            }
         }
         if(this.isVipItem())
         {
            result = int(m_cash - m_cash * Global.flashHotParams["VIP_ITEMS_DISCOUNT"] / 100);
         }
         return result;
      }
      
      public function get realCashCost() : int
      {
         var result:int = this.saleCash;
         if(Boolean(Global.flashHotParams["LOG_0_CASH_ITEMS"]) && Global.flashHotParams["LOG_0_CASH_ITEMS"] == true)
         {
            if(result == 0)
            {
               ErrorManager.addError("0 Cash Item : " + m_name + "available for user");
            }
         }
         if(result < 0)
         {
            result = this.cash;
         }
         return result;
      }
      
      public function get realCost() : int
      {
         var realSaleCoins:int = 0;
         if(this.isDealOfDaySaleItem && DealOfDayHelper.getDealOfDayItemCurrency(this.code) == Currency.COINS)
         {
            realSaleCoins = Math.max(1,DealOfDayHelper.getDealOfDayItemPrice(this.code));
         }
         return realSaleCoins ? realSaleCoins : this.cost;
      }
      
      public function get type() : String
      {
         if(this.m_type == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_type = m_dataSource.getString("type");
            }
            else
            {
               this.m_type = m_itemXML.@type;
            }
         }
         return this.m_type;
      }
      
      public function get subType() : String
      {
         if(this.m_subtype == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_subtype = m_dataSource.getString("subtype");
            }
            else
            {
               this.m_subtype = m_itemXML.@subtype;
            }
         }
         return this.m_subtype;
      }
      
      public function get subsubtype() : String
      {
         if(this.m_subsubtype == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_subsubtype = m_dataSource.getString("subsubtype");
            }
            else
            {
               this.m_subsubtype = m_itemXML.@subsubtype;
            }
         }
         return this.m_subsubtype;
      }
      
      public function get resourcePrefix() : String
      {
         if(null == this.m_resourcePrefix)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_resourcePrefix = this.getDataProperty(m_dataSource,"resourcePrefix");
               if(this.m_resourcePrefix == null)
               {
                  this.m_resourcePrefix = name;
               }
            }
            else
            {
               this.m_resourcePrefix = this.getXMLProperty(m_itemXML,"resourcePrefix");
               if(null == this.m_resourcePrefix)
               {
                  this.m_resourcePrefix = this.name;
               }
            }
         }
         return this.m_resourcePrefix;
      }
      
      public function get prefixUrl() : String
      {
         var imageArray:Array = null;
         var imageName:String = null;
         var imageData:BaseDataSource = null;
         var imageList:XMLList = null;
         var itemName:String = null;
         var item:XML = null;
         if(null == this.m_prefixUrl)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               imageArray = m_dataSource.getArray("image");
               for each(imageData in imageArray)
               {
                  imageName = imageData.getString("name");
                  if(imageName == "what_is_this")
                  {
                     this.m_prefixUrl = imageData.getString("prefixUrl");
                     break;
                  }
               }
            }
            else
            {
               imageList = m_itemXML.elements("image");
               for each(item in imageList)
               {
                  itemName = item.@name;
                  if(itemName == "what_is_this")
                  {
                     this.m_prefixUrl = item.@prefixUrl;
                     break;
                  }
               }
            }
         }
         return this.m_prefixUrl;
      }
      
      public function getActionCursorImage(limited:Boolean = false) : Object
      {
         var imageArray:Array = null;
         var imageName:String = null;
         var nameToFind:String = null;
         var imageData:BaseDataSource = null;
         var imageList:XMLList = null;
         var itemName:String = null;
         var searchForImage:String = null;
         var item:XML = null;
         var result:Object = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArray = m_dataSource.getArray("embeddedImage");
            if(limited)
            {
               nameToFind = "limited_action_cursor";
            }
            else
            {
               nameToFind = "action_cursor";
            }
            for each(imageData in imageArray)
            {
               imageName = imageData.getString("name");
               if(imageName == nameToFind)
               {
                  result = new Object();
                  result.symbol = imageData.getString("symbol");
                  break;
               }
            }
         }
         else
         {
            imageList = m_itemXML.elements("embeddedImage");
            searchForImage = limited ? "limited_action_cursor" : "action_cursor";
            for each(item in imageList)
            {
               itemName = item.@name;
               if(itemName == searchForImage)
               {
                  result = new Object();
                  result.symbol = item.@symbol;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get keyword() : String
      {
         if(this.m_keyword == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_keyword = this.getDataProperty(m_dataSource,"keyword");
            }
            else
            {
               this.m_keyword = this.getXMLProperty(m_itemXML,"keyword");
            }
            if(this.m_keyword == null)
            {
               this.m_keyword = "";
            }
         }
         return this.m_keyword;
      }
      
      public function get category() : String
      {
         if(this.m_category == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_category = m_dataSource.getString("category");
            }
            else
            {
               this.m_category = m_itemXML.@category;
            }
         }
         return this.m_category;
      }
      
      public function get substitutionString() : String
      {
         if(this.m_substitutionString == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_substitutionString = this.getDataProperty(m_dataSource,"substitution_string");
            }
            else
            {
               this.m_substitutionString = this.getXMLProperty(m_itemXML,"substitution_string");
            }
         }
         return this.m_substitutionString;
      }
      
      public function getDepthOffset() : Vector3
      {
         var depthOffsetX:* = undefined;
         var depthOffsetY:* = undefined;
         var result:Vector3 = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            depthOffsetX = m_dataSource.getData("depthOffset","x");
            if(depthOffsetX != null)
            {
               depthOffsetY = m_dataSource.getData("depthOffset","y");
               if(depthOffsetY != null)
               {
                  result = new Vector3(Number(depthOffsetX),Number(depthOffsetY));
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("depthOffset") && m_itemXML.depthOffset.hasOwnProperty("@x") && m_itemXML.depthOffset.hasOwnProperty("@y"))
         {
            result = new Vector3(Number(m_itemXML.depthOffset.@x),Number(m_itemXML.depthOffset.@y));
         }
         return result;
      }
      
      public function get toolTipOffset() : Point
      {
         var result:Point = new Point(0,0);
         var toolTipOffsetData:* = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            toolTipOffsetData = m_dataSource.getData("toolTipOffset");
            if(toolTipOffsetData)
            {
               result = new Point(toolTipOffsetData.getNumber("x"),toolTipOffsetData.getNumber("y"));
            }
         }
         else if(m_itemXML.hasOwnProperty("toolTipOffset"))
         {
            result = new Point(m_itemXML.toolTipOffset.@x,m_itemXML.toolTipOffset.@y);
         }
         return result;
      }
      
      private function get hasRequirements() : Boolean
      {
         var hasRequirements:Boolean = false;
         if(this.m_hasRequirements == -1)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasRequirements = m_dataSource.hasProperty("requirements");
            }
            else
            {
               hasRequirements = m_itemXML.hasOwnProperty("requirements");
            }
            if(hasRequirements)
            {
               this.m_hasRequirements = 1;
            }
            else
            {
               this.m_hasRequirements = 0;
            }
         }
         return this.m_hasRequirements == 1;
      }
      
      public function getRequirementCompareType() : String
      {
         var compareType:String = ItemRequirement.COMPARE_TYPE_ALL;
         if(this.hasRequirements)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               compareType = m_dataSource.getString("requirements","compare");
            }
            else if(m_itemXML.requirements.@compare != null)
            {
               compareType = m_itemXML.requirements.@compare.toString();
            }
         }
         return compareType;
      }
      
      public function getRequirement(type:String) : ItemRequirement
      {
         var result:ItemRequirement = null;
         var itemRequirement:ItemRequirement = null;
         var className:String = null;
         var requirements:Array = this.requirements;
         for each(itemRequirement in requirements)
         {
            className = getQualifiedClassName(itemRequirement);
            className = className.substring(className.lastIndexOf(":") + 1,className.length);
            if(className == type)
            {
               result = itemRequirement;
               break;
            }
         }
         return result;
      }
      
      private function shouldConsiderAllRequirements() : Boolean
      {
         var result:Boolean = true;
         if(this.getRequirementCompareType() == ItemRequirement.COMPARE_TYPE_ANY)
         {
            result = false;
         }
         return result;
      }
      
      public function get hasStats() : Boolean
      {
         return this.m_hasStats;
      }
      
      public function set hasStats(hasStats:Boolean) : void
      {
         this.m_hasStats = hasStats;
      }
      
      public function get requirements() : Array
      {
         var className:String = null;
         var requirementClass:Class = null;
         var requirementArray:Array = null;
         var requirementData:BaseDataSource = null;
         var requirementList:XMLList = null;
         var requirement:XML = null;
         if(this.m_requirements == null)
         {
            this.m_requirements = [];
            if(this.hasRequirements)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  requirementArray = m_dataSource.getArray("requirements","requirement");
                  for each(requirementData in requirementArray)
                  {
                     className = requirementData.getString("className");
                     if(className != "")
                     {
                        className = "Classes." + className + "Requirement";
                        try
                        {
                           requirementClass = getDefinitionByName(className) as Class;
                           this.m_requirements.push(new requirementClass(null,this,requirementData));
                        }
                        catch(error:Error)
                        {
                           GlobalEngine.error("FarmItem","Unable to create ItemRequirement subclass: " + className + ", " + error.message);
                           ErrorManager.addError("Unable to create ItemRequirement subclass: " + className + ", " + error.message);
                        }
                        continue;
                     }
                     this.m_requirements.push(new ItemRequirement(null,this,requirementData));
                  }
               }
               else
               {
                  requirementList = m_itemXML.requirements.requirement;
                  for each(requirement in requirementList)
                  {
                     className = requirement.@className.toString();
                     if(className != "")
                     {
                        className = "Classes." + className + "Requirement";
                        try
                        {
                           requirementClass = getDefinitionByName(className) as Class;
                           this.m_requirements.push(new requirementClass(requirement,this));
                        }
                        catch(error:Error)
                        {
                           GlobalEngine.error("FarmItem","Unable to create ItemRequirement subclass: " + className + ", " + error.message);
                           ErrorManager.addError("Unable to create ItemRequirement subclass: " + className + ", " + error.message);
                        }
                        continue;
                     }
                     this.m_requirements.push(new ItemRequirement(requirement,this));
                  }
               }
            }
         }
         return this.m_requirements;
      }
      
      public function get meetsRequirments() : Boolean
      {
         var result:Boolean = true;
         var requirements:Array = this.requirements;
         var considerAll:Boolean = this.shouldConsiderAllRequirements();
         var isConditionMet:Boolean = false;
         var curReq:ItemRequirement = null;
         for(var reqIdx:int = 0; reqIdx < requirements.length; reqIdx++)
         {
            curReq = requirements[reqIdx];
            if(null != curReq)
            {
               isConditionMet = curReq.check();
               if(isConditionMet == false)
               {
                  result = isConditionMet;
               }
               else if(considerAll == false)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get firstMissingRequirement() : ItemRequirement
      {
         var allMissingRequirements:Array = null;
         var itemRequirement:ItemRequirement = null;
         var result:ItemRequirement = null;
         if(!this.shouldConsiderAllRequirements())
         {
            allMissingRequirements = this.allMissingRequirements;
            if(allMissingRequirements.length > 0)
            {
               result = allMissingRequirements[0];
            }
         }
         else
         {
            for each(itemRequirement in this.requirements)
            {
               if(!itemRequirement.check())
               {
                  result = itemRequirement;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get allMissingRequirements() : Array
      {
         var hasMissingRequirement:Boolean = false;
         var compareAll:Boolean = false;
         var itemRequirement:ItemRequirement = null;
         var isRequirementMet:Boolean = false;
         var result:Array = [];
         if(this.hasRequirements)
         {
            hasMissingRequirement = false;
            compareAll = this.shouldConsiderAllRequirements();
            for each(itemRequirement in this.requirements)
            {
               isRequirementMet = itemRequirement.check();
               if(!compareAll && isRequirementMet)
               {
                  hasMissingRequirement = false;
                  break;
               }
               if(!isRequirementMet)
               {
                  hasMissingRequirement = true;
                  result.push(itemRequirement);
               }
            }
            if(!hasMissingRequirement)
            {
               result = [];
            }
         }
         return result;
      }
      
      public function haveWorldLicenseRequirements() : Boolean
      {
         var itemRequirement:ItemRequirement = null;
         var result:Boolean = false;
         if(this.hasRequirements)
         {
            for each(itemRequirement in this.requirements)
            {
               if(itemRequirement is WorldLicenseRequirement)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function meetsWorldLicenseRequirements() : Boolean
      {
         var shouldCompareAll:Boolean = false;
         var itemRequirement:ItemRequirement = null;
         var result:Boolean = false;
         if(this.hasRequirements)
         {
            shouldCompareAll = this.shouldConsiderAllRequirements();
            itemRequirement = null;
            for each(itemRequirement in this.requirements)
            {
               if(itemRequirement is WorldLicenseRequirement)
               {
                  if(itemRequirement.check() == false)
                  {
                     if(shouldCompareAll)
                     {
                        result = false;
                        break;
                     }
                  }
                  else if(!shouldCompareAll)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function get bushelGrantsLicense() : Boolean
      {
         var bushelItemCode:String = null;
         var seedPackageItem:FarmItem = null;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            bushelItemCode = m_dataSource.getString("buselItemCode");
         }
         else if(this.xml.hasOwnProperty("bushelItemCode"))
         {
            bushelItemCode = this.xml.bushelItemCode;
         }
         if(bushelItemCode)
         {
            seedPackageItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
            result = seedPackageItem.grantsLicense;
         }
         return result;
      }
      
      public function get grantsLicense() : Boolean
      {
         var grantsLicense:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            grantsLicense = !m_dataSource.hasProperty("grantsLicense") || m_dataSource.getBoolean("grantsLicense");
         }
         else
         {
            grantsLicense = m_itemXML.@grantsLicense != "false";
         }
         return grantsLicense;
      }
      
      public function get ignoreMarketSort() : Boolean
      {
         var shouldIgnoreMarketSort:Boolean = false;
         var ignoreMarketSortString:String = null;
         if(this.m_ignoreMarketSort < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               shouldIgnoreMarketSort = m_dataSource.getBoolean("ignoreMarketSort");
               if(shouldIgnoreMarketSort)
               {
                  this.m_ignoreMarketSort = 1;
               }
               else
               {
                  this.m_ignoreMarketSort = 0;
               }
            }
            else
            {
               ignoreMarketSortString = m_itemXML.@ignoreMarketSort;
               if(ignoreMarketSortString == "")
               {
                  this.m_ignoreMarketSort = 0;
               }
               else
               {
                  this.m_ignoreMarketSort = ignoreMarketSortString == "true" ? 1 : 0;
               }
            }
         }
         return this.m_ignoreMarketSort > 0;
      }
      
      public function get unlock() : String
      {
         if(this.m_unlock == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_unlock = m_dataSource.getString("unlock");
            }
            else
            {
               this.m_unlock = m_itemXML.@unlock;
            }
            if(this.m_unlock == "")
            {
               this.m_unlock = FarmItemLock.LEVEL;
            }
         }
         return this.m_unlock;
      }
      
      public function get market() : String
      {
         if(this.m_market == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_market = m_dataSource.getString("market");
            }
            else if(m_itemXML)
            {
               this.m_market = String(m_itemXML.@market);
            }
         }
         return this.m_market;
      }
      
      public function get currency() : String
      {
         return this.market;
      }
      
      public function get cashXMLMarket() : String
      {
         if(this.m_cashXMLMarket == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
            {
               this.m_cashXMLMarket = this.m_cashData.getString("market");
            }
            else if(this.m_cashXML != null)
            {
               this.m_cashXMLMarket = String(this.m_cashXML.@market);
            }
         }
         return this.m_cashXMLMarket;
      }
      
      public function get cashDSMarket() : String
      {
         if(this.m_cashDSMarket == null && Boolean(this.m_cashData))
         {
            this.m_cashDSMarket = this.m_cashData.getString("market");
         }
         return this.m_cashDSMarket;
      }
      
      public function get buff() : String
      {
         var buffString:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buffString = m_dataSource.getString("buff");
         }
         else
         {
            buffString = m_itemXML.buff;
         }
         return buffString;
      }
      
      public function get isInExperiment() : Boolean
      {
         return this.isInCoinExperiment || this.isInCashExperiment;
      }
      
      public function get isInCoinExperiment() : Boolean
      {
         var result:Number = this.m_coinExperimentActive;
         if(result == FarmItem.EXPERIMENT_NOT_CACHED)
         {
            result = this.checkExperimentGate(m_itemXML,m_dataSource);
            if(Global.experimentManager.initialized)
            {
               this.m_coinExperimentActive = result;
            }
         }
         return result == FarmItem.EXPERIMENT_ACTIVE;
      }
      
      public function get isInCashExperiment() : Boolean
      {
         var result:Number = this.m_cashExperimentActive;
         if(result == FarmItem.EXPERIMENT_NOT_CACHED)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
            {
               result = this.checkExperimentGate(null,this.m_cashData);
            }
            else if(null != this.m_cashXML)
            {
               result = this.checkExperimentGate(this.m_cashXML);
            }
            if(Global.experimentManager.initialized)
            {
               this.m_cashExperimentActive = result;
            }
         }
         return result == FarmItem.EXPERIMENT_ACTIVE;
      }
      
      public function get isDealOfDaySaleItem() : Boolean
      {
         return this.m_isDealOfDaySaleItem;
      }
      
      public function set isDealOfDaySaleItem(val:Boolean) : void
      {
         this.m_isDealOfDaySaleItem = val;
      }
      
      public function get isInDealOfDayExperiment() : Boolean
      {
         var result:Number = this.m_dealOfDayExperimentActive;
         if(result == FarmItem.EXPERIMENT_NOT_CACHED)
         {
            result = DealOfDayHelper.inExperiment() ? FarmItem.EXPERIMENT_ACTIVE : FarmItem.EXPERIMENT_INACTIVE;
            if(Global.experimentManager.initialized)
            {
               this.m_dealOfDayExperimentActive = result;
            }
         }
         return result == FarmItem.EXPERIMENT_ACTIVE;
      }
      
      public function checkExperimentGate(itemXml:XML = null, itemData:BaseDataSource = null) : Number
      {
         var experimentVariants:Array = null;
         if(itemXml == null)
         {
            itemXml = m_itemXML;
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment() && itemData == null)
         {
            itemData = m_dataSource;
         }
         var result:Number = FarmItem.EXPERIMENT_ACTIVE;
         var experimentName:String = ExperimentManager.getItemExperimentFromXml(itemXml,itemData);
         if(experimentName != "")
         {
            experimentVariants = ExperimentManager.getItemExperimentVariantsFromXml(itemXml,itemData);
            if(experimentVariants.length > 0)
            {
               result = experimentVariants.indexOf(Global.experimentManager.getExperimentVariant(experimentName)) >= 0 ? FarmItem.EXPERIMENT_ACTIVE : FarmItem.EXPERIMENT_INACTIVE;
            }
            else
            {
               result = Global.experimentManager.getExperimentVariant(experimentName) > 0 ? FarmItem.EXPERIMENT_ACTIVE : FarmItem.EXPERIMENT_INACTIVE;
            }
         }
         return result;
      }
      
      public function get priceTest() : String
      {
         if(this.m_priceTest == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_priceTest = "";
            }
            this.m_priceTest = m_itemXML.@priceTest;
         }
         return this.m_priceTest;
      }
      
      public function get gateCode() : String
      {
         if(this.m_gateCode == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_gateCode = m_dataSource.getString("gateCode");
            }
            else
            {
               this.m_gateCode = m_itemXML.@gateCode;
            }
         }
         return this.m_gateCode;
      }
      
      public function get promoMode() : String
      {
         if(this.m_promoMode == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_promoMode = m_dataSource.getString("promoMode");
            }
            else
            {
               this.m_promoMode = m_itemXML.@promoMode;
            }
         }
         return this.m_promoMode;
      }
      
      public function get colorGroup() : String
      {
         if(this.m_colorGroup == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_colorGroup = m_dataSource.getString("colorGroup");
            }
            else
            {
               this.m_colorGroup = m_itemXML.@colorGroup;
            }
            if(this.m_colorGroup == "")
            {
               this.m_colorGroup = "~";
            }
         }
         return this.m_colorGroup;
      }
      
      public function get marketInfoURL() : String
      {
         if(this.m_marketInfoURL == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_marketInfoURL = m_dataSource.getString("marketInfoURL");
            }
            else
            {
               this.m_marketInfoURL = m_itemXML.@marketInfoURL;
            }
         }
         return this.m_marketInfoURL;
      }
      
      public function get lootTable() : String
      {
         if(this.m_lootTable == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_lootTable = this.getDataProperty(m_dataSource,"lootTable");
            }
            else
            {
               this.m_lootTable = this.getXMLProperty(m_itemXML,"lootTable");
            }
         }
         return this.m_lootTable;
      }
      
      public function get isMysteryItem() : Boolean
      {
         return Boolean(this.lootTable) && this.lootTable != "" && this.promoMode != CPigoGameToken.PROMO_MODE;
      }
      
      public function get license() : String
      {
         if(this.m_licenseCode == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_licenseCode = m_dataSource.getString("license");
            }
            else
            {
               this.m_licenseCode = m_itemXML.@license;
            }
         }
         return this.m_licenseCode;
      }
      
      public function get licenseLimit() : String
      {
         var limit:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            limit = m_dataSource.getString("licenseLimit");
         }
         else
         {
            limit = m_itemXML.@licenseLimit;
         }
         return limit;
      }
      
      public function get licenseCost() : int
      {
         var cost:int = 0;
         if(Boolean(this.itemLicense) && this.itemLicense.hasBuyableUnlock)
         {
            cost = this.itemLicense.buyableUnlock.requirement;
         }
         return cost;
      }
      
      public function get itemLicense() : ItemLicense
      {
         var licenseXML:XML = null;
         if(this.m_itemLicense == null && Boolean(this.license))
         {
            licenseXML = Global.farmGameSettingsManager.getLicenseXML(this.license);
            if(licenseXML)
            {
               this.m_itemLicense = new ItemLicense(licenseXML);
            }
         }
         return this.m_itemLicense;
      }
      
      public function get unlockCost() : int
      {
         if(this.m_unlockCost == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_unlockCost = this.getDataInt(m_dataSource,"unlockCost",SUPER_CROP_DEFAULT_UNLOCK_COST);
            }
            else
            {
               this.m_unlockCost = this.getXMLInt(m_itemXML,"unlockCost",SUPER_CROP_DEFAULT_UNLOCK_COST);
            }
         }
         return this.m_unlockCost;
      }
      
      public function get isLicenseGated() : Boolean
      {
         return this.license != "";
      }
      
      public function get worldRestrictions() : Array
      {
         var requirement:ItemRequirement = null;
         if(this.m_worldRestrictions == null)
         {
            this.m_worldRestrictions = [];
            requirement = null;
            for each(requirement in this.requirements)
            {
               if(requirement is WorldRequirement)
               {
                  this.m_worldRestrictions.push((requirement as WorldRequirement).worldId);
               }
            }
         }
         return this.m_worldRestrictions.slice(0);
      }
      
      public function meetsWorldRestrictions() : Boolean
      {
         var worldId:String = null;
         var result:Boolean = false;
         var worldRestrictions:Array = this.worldRestrictions;
         if(worldRestrictions.length == 0)
         {
            result = true;
         }
         else
         {
            for each(worldId in this.worldRestrictions)
            {
               if(worldId == Global.worldManager.currentWorldType)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isBuyableLicense() : Boolean
      {
         return Boolean(this.itemLicense) && this.itemLicense.hasBuyableUnlock;
      }
      
      public function isBerryBuyableLicense() : Boolean
      {
         var licenseXML:XML = null;
         var unlockXMLList:XMLList = null;
         var unlock:LicenseUnlock = null;
         var result:Boolean = false;
         if(this.license)
         {
            licenseXML = Global.farmGameSettingsManager.getLicenseXML(this.license);
            if(Boolean(licenseXML) && Boolean(licenseXML.unlock))
            {
               unlockXMLList = licenseXML.unlock;
               unlock = new LicenseUnlock(unlockXMLList[0]);
               if(unlock.className == "BerryLicense")
               {
                  result = true;
               }
            }
         }
         return result && this.isBuyableLicense();
      }
      
      public function get isLicenseValid() : Boolean
      {
         var itemLicense:ItemLicense = null;
         var result:Boolean = false;
         var licenseCode:String = this.license;
         if(licenseCode != "")
         {
            itemLicense = Global.farmGameSettingsManager.getItemLicenseByCode(licenseCode);
            if(itemLicense != null && ((!itemLicense.startDate && !itemLicense.endDate || Global.farmGameSettingsManager.checkTimeGate(itemLicense.startDate,itemLicense.endDate)) && (!itemLicense.prereqs || PrerequisiteUtility.arePrerequisitesMet(itemLicense.prereqs))) || LicenseManager.getInstance().hasCurrentLicense(this.code))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get isLicenseHidden() : Boolean
      {
         var itemLicense:ItemLicense = null;
         var result:Boolean = false;
         var licenseCode:String = this.license;
         if(licenseCode != "")
         {
            itemLicense = Global.farmGameSettingsManager.getItemLicenseByCode(licenseCode);
            if(itemLicense != null && (Boolean(itemLicense.startDate && itemLicense.endDate) && Boolean(!Global.farmGameSettingsManager.checkTimeGate(itemLicense.startDate,itemLicense.endDate)) || Boolean(itemLicense.prereqs) && Boolean(!PrerequisiteUtility.arePrerequisitesMet(itemLicense.prereqs))))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get hasLicense() : Boolean
      {
         return !this.isLicenseGated || Global.farmGameSettingsManager.getItemLicenseByCode(this.license) != null;
      }
      
      public function get specialSortPriority() : Number
      {
         var specialSortPriorityString:String = null;
         if(this.m_specialSortPriority == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               specialSortPriorityString = this.getDataProperty(m_dataSource,"specialSortPriority");
            }
            else
            {
               specialSortPriorityString = this.getXMLProperty(m_itemXML,"specialSortPriority");
            }
            if(specialSortPriorityString)
            {
               this.m_specialSortPriority = Number(specialSortPriorityString);
            }
            else
            {
               this.m_specialSortPriority = 0;
            }
         }
         return this.m_specialSortPriority;
      }
      
      public function get size() : Number
      {
         if(this.m_size == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_size = m_dataSource.getNumber("size");
            }
            else
            {
               this.m_size = Number(m_itemXML.@size);
            }
         }
         return this.m_size;
      }
      
      public function set size(newSize:Number) : void
      {
         this.m_size = newSize;
      }
      
      public function get sizeX() : int
      {
         if(this.m_sizeX == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_sizeX = Math.max(m_dataSource.getInt("sizeX"),1);
            }
            else
            {
               this.m_sizeX = int(Math.max(m_itemXML.sizeX,1));
            }
         }
         return this.m_sizeX;
      }
      
      public function set sizeX(newX:int) : void
      {
         if(newX > 0)
         {
            this.m_sizeX = newX;
         }
      }
      
      public function set sizeY(newY:int) : void
      {
         if(newY > 0)
         {
            this.m_sizeY = newY;
         }
      }
      
      public function get sizeY() : int
      {
         if(this.m_sizeY == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_sizeY = Math.max(m_dataSource.getInt("sizeY"),1);
            }
            else
            {
               this.m_sizeY = int(Math.max(m_itemXML.sizeY,1));
            }
         }
         return this.m_sizeY;
      }
      
      public function get minNeighbors() : Number
      {
         var minNeighborsString:String = null;
         if(this.m_minNeighbors == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               minNeighborsString = this.getDataProperty(m_dataSource,"minNeighbors");
            }
            else
            {
               minNeighborsString = this.getXMLProperty(m_itemXML,"minNeighbors");
            }
            if(minNeighborsString)
            {
               this.m_minNeighbors = Number(minNeighborsString);
            }
            else
            {
               this.m_minNeighbors = 0;
            }
         }
         return this.m_minNeighbors;
      }
      
      private function getVariant(experimentCategory:String, variantIndex:int) : XML
      {
         var categoryElement:XML = null;
         var categoryVariants:XMLList = null;
         var currentVariant:XML = null;
         var currentVariantNumber:int = 0;
         var result:XML = null;
         var childList:XMLList = m_itemXML.child(experimentCategory);
         var categoryVariantCount:int = 0;
         var childListLength:int = childList.length();
         if(childListLength == 1)
         {
            categoryElement = m_itemXML.child(experimentCategory)[0];
            categoryVariants = categoryElement.variant;
            categoryVariantCount = categoryVariants.length();
         }
         else
         {
            GlobalEngine.log("FarmItem","There should be exactly one element name" + experimentCategory + "in the item xml for " + friendlyName);
         }
         for(var currentVariantIndex:int = 0; currentVariantIndex < categoryVariantCount; currentVariantIndex++)
         {
            currentVariant = categoryVariants[currentVariantIndex];
            currentVariantNumber = int(currentVariant.@number);
            if(currentVariantNumber == variantIndex)
            {
               result = currentVariant;
               break;
            }
         }
         return result;
      }
      
      public function isVariantDefined(experimentCategory:String, variantIndex:int) : Boolean
      {
         var variantDataArray:Array = null;
         var variantData:BaseDataSource = null;
         var isDefined:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            variantDataArray = m_dataSource.getArray(experimentCategory,"variant");
            for each(variantData in variantDataArray)
            {
               if(variantData.getInt("number") == variantIndex)
               {
                  isDefined = true;
                  break;
               }
            }
         }
         else
         {
            isDefined = this.getVariant(experimentCategory,variantIndex) != null;
         }
         return isDefined;
      }
      
      public function getStringByVariant(experimentCategory:String, variantIndex:int, variantAttribute:String) : String
      {
         var variantDataArray:Array = null;
         var variantData:BaseDataSource = null;
         var variant:XML = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            variantDataArray = m_dataSource.getArray(experimentCategory,"variant");
            for each(variantData in variantDataArray)
            {
               if(variantData.getInt("number") == variantIndex)
               {
                  result = variantData.getString(variantAttribute);
               }
            }
         }
         else
         {
            variant = this.getVariant(experimentCategory,variantIndex);
            if(variant != null)
            {
               result = variant.attribute(variantAttribute);
            }
         }
         return result;
      }
      
      public function getIntByVariant(experimentCategory:String, variantIndex:int, variantAttribute:String, defaultValue:int = 0) : int
      {
         var result:int = defaultValue;
         var objectValue:String = this.getStringByVariant(experimentCategory,variantIndex,variantAttribute);
         if(objectValue != null)
         {
            result = parseInt(objectValue);
         }
         return result;
      }
      
      public function getExperimentName(experimentCategory:String) : String
      {
         var experimentName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            experimentName = m_dataSource.getString(experimentCategory,"experiment");
         }
         else
         {
            experimentName = m_itemXML.child(experimentCategory).@experiment;
         }
         return experimentName;
      }
      
      public function getExperimentInt(experimentCategory:String, attributeName:String, xml:XML, dataSource:BaseDataSource = null, defaultValue:int = 0) : int
      {
         var experimentName:String = null;
         var variantIndex:int = 0;
         var result:int = defaultValue;
         var shouldCheckXML:Boolean = true;
         var shouldCheckExperiments:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            shouldCheckExperiments = m_dataSource.hasProperty(experimentCategory) && attributeName == CASH_ATTRIBUTE_NAME;
         }
         else
         {
            shouldCheckExperiments = m_itemXML.hasOwnProperty(experimentCategory) && attributeName == CASH_ATTRIBUTE_NAME;
         }
         if(shouldCheckExperiments)
         {
            experimentName = this.getExperimentName(experimentCategory);
            if(Global.experimentManager.hasExperimentVariant(experimentName) && Global.experimentManager.getExperimentVariant(experimentName) > 0)
            {
               variantIndex = Global.experimentManager.getExperimentVariant(experimentName);
               if(this.isVariantDefined(experimentCategory,variantIndex))
               {
                  result = this.getIntByVariant(experimentCategory,variantIndex,attributeName,defaultValue);
                  shouldCheckXML = false;
               }
               else
               {
                  GlobalEngine.log("FarmItem","Variant " + variantIndex + " was not defined for epxierment " + experimentName + ", using default " + attributeName + " value.");
               }
            }
            else
            {
               GlobalEngine.log("FarmItem",experimentName + " not found on front-end. Please check that you named your constant beginning with EXPERIMENT_FLASH_ in Experiments.class.php");
            }
         }
         if(shouldCheckXML)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = this.getDataInt(dataSource,attributeName,defaultValue);
            }
            else
            {
               result = this.getXMLInt(xml,attributeName,defaultValue);
            }
         }
         return result;
      }
      
      public function getXMLInt(xml:XML, attributeName:String, defaultValue:int) : int
      {
         var result:int = defaultValue;
         var intString:String = this.getXMLProperty(xml,attributeName);
         if(intString)
         {
            result = parseInt(intString);
         }
         return result;
      }
      
      protected function getDataInt(dataSource:BaseDataSource, propertyName:String, defaultValue:int) : int
      {
         var result:int = defaultValue;
         var intString:String = this.getDataProperty(dataSource,propertyName);
         if(intString)
         {
            result = parseInt(intString);
         }
         return result;
      }
      
      public function getItemTierById(itemXML:XML, tierId:int = 1) : XML
      {
         var tierList:XMLList = null;
         var tierObject:XML = null;
         var result:XML = null;
         if(tierId <= this.totalTiers)
         {
            tierList = itemXML.tiers.tier.(@id == tierId);
            tierObject = null;
            if(tierList.length())
            {
               tierObject = tierList[0];
            }
            if(tierObject != null)
            {
               result = tierObject;
            }
            else
            {
               result = null;
            }
         }
         else
         {
            result = null;
         }
         return result;
      }
      
      public function getItemTierDataById(itemData:BaseDataSource, tierId:int = 1) : BaseDataSource
      {
         var tierArray:Array = null;
         var tierData:BaseDataSource = null;
         var result:BaseDataSource = null;
         if(tierId <= this.totalTiers)
         {
            tierArray = itemData.getArray("tiers","tier");
            for each(tierData in tierArray)
            {
               if(tierData.getInt("id") == tierId)
               {
                  result = tierData;
                  break;
               }
            }
         }
         return result;
      }
      
      public function calculateCurrentTier() : int
      {
         return 1;
      }
      
      override public function getXMLProperty(xml:XML, propName:String) : String
      {
         var tierXML:XML = null;
         var param:String = null;
         if(xml != null)
         {
            if(xml.hasOwnProperty(propName))
            {
               param = xml[propName];
            }
            if(param == null && this.isTiered)
            {
               tierXML = null;
               tierXML = this.getItemTierById(xml,this.calculateCurrentTier());
               if(tierXML != null && tierXML.hasOwnProperty(propName))
               {
                  param = tierXML[propName];
               }
            }
         }
         return param;
      }
      
      override protected function getDataProperty(dataSource:BaseDataSource, propertyName:String) : String
      {
         var tierData:BaseDataSource = null;
         var propertyValue:String = null;
         if(dataSource)
         {
            if(dataSource.hasProperty(propertyName))
            {
               propertyValue = dataSource.getString(propertyName);
            }
            if(propertyValue == null && this.isTiered)
            {
               tierData = this.getItemTierDataById(dataSource,this.calculateCurrentTier());
               if(Boolean(tierData) && tierData.hasProperty(propertyName))
               {
                  propertyValue = tierData.getString(propertyName);
               }
            }
         }
         return propertyValue;
      }
      
      protected function getDataPropertyAsInt(dataSource:BaseDataSource, propertyName:String) : int
      {
         var propertyValue:String = this.getDataProperty(dataSource,propertyName);
         var valueAsInt:int = 0;
         if(propertyValue)
         {
            valueAsInt = int(propertyValue);
         }
         return valueAsInt;
      }
      
      override public function get cash() : int
      {
         if(m_cash == INVALID_VALUE)
         {
            if(this.m_cashData)
            {
               m_cash = this.getExperimentInt(PRICE_TEST_ELEMENT_NAME,CASH_ATTRIBUTE_NAME,null,this.m_cashData);
            }
            else
            {
               m_cash = this.getExperimentInt(PRICE_TEST_ELEMENT_NAME,CASH_ATTRIBUTE_NAME,this.m_cashXML);
            }
         }
         var altPrice:int = this.testForVariablePricing();
         if(altPrice > 0 && !this.marketIsCoin)
         {
            m_cash = altPrice;
         }
         return m_cash;
      }
      
      public function testForVariablePricing() : int
      {
         var experimentName:String = null;
         var playerExperiment:int = 0;
         var playerLevel:int = 0;
         var variablePricesByLevelData:BaseDataSource = null;
         var variablePricingData:Array = null;
         var priceSchemeArray:Array = null;
         var levelSchemeArray:Array = null;
         var schemeData:BaseDataSource = null;
         var levelData:BaseDataSource = null;
         var pricingData:BaseDataSource = null;
         var variableNum:Number = NaN;
         var baseNum:Number = NaN;
         var linearCoefNum:Number = NaN;
         var quadCoefNum:Number = NaN;
         var priceSchemes:XMLList = null;
         var scheme:XML = null;
         var levelSchemes:XMLList = null;
         var level:XML = null;
         var variablePricings:XMLList = null;
         var pricing:XML = null;
         var variable:Number = NaN;
         var base:Number = NaN;
         var linearCoef:Number = NaN;
         var quadCoef:Number = NaN;
         var variablePrice:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            variablePricesByLevelData = m_dataSource.getData("variablePricesByLevel");
            variablePricingData = m_dataSource.getArray("variablePricing");
            if(variablePricesByLevelData != null)
            {
               experimentName = variablePricesByLevelData.getString("name");
               playerExperiment = Global.experimentManager.getExperimentVariant(experimentName);
               playerLevel = Global.player.level;
               priceSchemeArray = variablePricesByLevelData.getArray("priceScheme");
               loop1:
               for each(schemeData in priceSchemeArray)
               {
                  levelSchemeArray = schemeData.getArray("levelScheme");
                  if(playerExperiment == schemeData.getInt("variant"))
                  {
                     for each(levelData in levelSchemeArray)
                     {
                        if(playerLevel <= levelData.getInt("topLevel"))
                        {
                           variablePrice = levelData.getInt("price");
                           break loop1;
                        }
                     }
                  }
               }
            }
            else if(variablePricingData.length > 0)
            {
               for each(pricingData in variablePricingData)
               {
                  if(PrerequisiteUtility.evalPrereqsData(pricingData.getArray("prereq")))
                  {
                     try
                     {
                        variableNum = FarmItem.getPlayerStatForVariablePricing(pricingData.getString("variable"),pricingData.getString("variableSubtype"));
                        baseNum = pricingData.getNumber("base");
                        linearCoefNum = pricingData.getNumber("linearCoef");
                        quadCoefNum = pricingData.getNumber("quadCoef");
                        variablePrice = Math.ceil(baseNum) + Math.ceil(linearCoefNum * variableNum) + Math.ceil(quadCoefNum * variableNum * variableNum);
                     }
                     catch(e:Error)
                     {
                        variablePrice = 0;
                     }
                  }
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("variablePricesByLevel"))
         {
            experimentName = m_itemXML.variablePricesByLevel.@name;
            playerExperiment = Global.experimentManager.getExperimentVariant(experimentName);
            playerLevel = Global.player.level;
            priceSchemes = m_itemXML.variablePricesByLevel.priceScheme;
            loop0:
            for each(scheme in priceSchemes)
            {
               levelSchemes = scheme.levelScheme;
               if(playerExperiment == parseInt(scheme.@variant))
               {
                  for each(level in levelSchemes)
                  {
                     if(playerLevel <= parseInt(level.@topLevel))
                     {
                        variablePrice = parseInt(level.@price);
                        break loop0;
                     }
                  }
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("variablePricing"))
         {
            variablePricings = m_itemXML.variablePricing;
            for each(pricing in variablePricings)
            {
               if(PrerequisiteUtility.evalPrereqsXML(pricing.prereq))
               {
                  try
                  {
                     variable = FarmItem.getPlayerStatForVariablePricing(pricing.@variable,pricing.@variableSubtype);
                     base = pricing.@base ? Number(pricing.@base) : 0;
                     linearCoef = pricing.@linearCoef ? Number(pricing.@linearCoef) : 0;
                     quadCoef = pricing.@quadCoef ? Number(pricing.@quadCoef) : 0;
                     variablePrice = Math.ceil(base) + Math.ceil(linearCoef * variable) + Math.ceil(quadCoef * variable * variable);
                  }
                  catch(e:Error)
                  {
                     variablePrice = 0;
                  }
               }
            }
         }
         return variablePrice;
      }
      
      override public function get cost() : int
      {
         if(m_cost == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               m_cost = this.getExperimentInt(PRICE_TEST_ELEMENT_NAME,COST_ATTRIBUTE_NAME,null,m_dataSource);
            }
            else
            {
               m_cost = this.getExperimentInt(PRICE_TEST_ELEMENT_NAME,COST_ATTRIBUTE_NAME,m_itemXML);
            }
         }
         var altPrice:int = this.testForVariablePricing();
         if(altPrice > 0 && this.marketIsCoin)
         {
            m_cost = altPrice;
         }
         return m_cost;
      }
      
      private function testProperty(propertyName:String) : Boolean
      {
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource)
            {
               result ||= m_dataSource.getBoolean(propertyName);
            }
            if(this.m_cashData)
            {
               result ||= this.m_cashData.getBoolean(propertyName);
            }
            if(this.m_saleData)
            {
               result ||= this.m_saleData.getBoolean(propertyName);
            }
         }
         else
         {
            if(m_itemXML != null)
            {
               result ||= m_itemXML.attribute(propertyName) == "true";
            }
            if(this.m_cashXML != null)
            {
               result ||= this.m_cashXML.attribute(propertyName) == "true";
            }
            if(this.m_saleXML != null)
            {
               result ||= this.m_saleXML.attribute(propertyName) == "true";
            }
         }
         return result;
      }
      
      private function applyDateGateToProperty(propertyValue:int) : int
      {
         if(propertyValue == 1 && !this.checkDateGate())
         {
            propertyValue = 0;
         }
         return propertyValue;
      }
      
      private function isPropertyEnabledAfterDateGateCheck(propertyValue:int) : Boolean
      {
         return this.applyDateGateToProperty(propertyValue) > 0;
      }
      
      public function get tooltipKey() : String
      {
         if(this.m_tooltipKey == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_tooltipKey = this.getDataProperty(m_dataSource,"tooltipKey");
            }
            else
            {
               this.m_tooltipKey = this.getXMLProperty(m_itemXML,"tooltipKey");
            }
            if(this.m_tooltipKey == null)
            {
               this.m_tooltipKey = "";
            }
         }
         return this.m_tooltipKey;
      }
      
      public function get hasWhatIsThis() : Boolean
      {
         if(this.m_whatIsThis < 0)
         {
            this.m_whatIsThis = this.testProperty("whatIsThis") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_whatIsThis);
      }
      
      public function get whatIsThisDialog() : String
      {
         if(this.m_whatIsThisDialog == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_whatIsThisDialog = m_dataSource.getString("whatIsThisDialog");
            }
            else if(m_itemXML.hasOwnProperty("@whatIsThisDialog"))
            {
               this.m_whatIsThisDialog = String(m_itemXML.@whatIsThisDialog);
            }
         }
         return this.m_whatIsThisDialog;
      }
      
      public function get isPresent() : Boolean
      {
         if(this.m_isPresent < 0)
         {
            this.m_isPresent = this.testProperty("present") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_isPresent) > 0;
      }
      
      public function get isSpecialValentinesItem() : Boolean
      {
         if(this.m_isSpecialValentinesItem < 0)
         {
            this.m_isSpecialValentinesItem = this.testProperty("specialValentinesItem") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_isSpecialValentinesItem);
      }
      
      public function get isGameToken() : Boolean
      {
         if(this.m_isGameToken < 0)
         {
            this.m_isGameToken = this.testProperty("isGameToken") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_isGameToken);
      }
      
      private function initializeBuyableIfRequired() : void
      {
         if(this.m_buyable < 0)
         {
            this.m_buyable = this.testProperty("buyable") ? 1 : 0;
         }
      }
      
      public function get buyable() : Boolean
      {
         this.initializeBuyableIfRequired();
         return this.isPropertyEnabledAfterDateGateCheck(this.m_buyable);
      }
      
      public function canGetFromMarket() : Boolean
      {
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = !m_dataSource.hasProperty("getFromMarket") || m_dataSource.getBoolean("getFromMarket");
         }
         else if(m_itemXML != null)
         {
            result = m_itemXML.attribute("getFromMarket") != "false";
         }
         return result;
      }
      
      public function get buyableWithoutDateCheck() : Boolean
      {
         this.initializeBuyableIfRequired();
         return this.m_buyable > 0;
      }
      
      public function set buyable(value:Boolean) : void
      {
         this.m_buyable = value ? 1 : 0;
      }
      
      public function get buyableWhileVisiting() : Boolean
      {
         return this.placeable && this.type != FarmItemType.SEED;
      }
      
      public function get buyableFromModelFarm() : Boolean
      {
         return this.buyable && this.buyableWhileVisiting;
      }
      
      public function get buyableFromNeighbor() : Boolean
      {
         return this.buyable && this.buyableWhileVisiting && this.buyableWithCash();
      }
      
      public function get giftable() : Boolean
      {
         if(this.m_giftable < 0)
         {
            this.m_giftable = this.testProperty("giftable") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_giftable);
      }
      
      public function get isConsumable() : Boolean
      {
         if(this.m_consumable < 0)
         {
            this.m_consumable = this.testProperty("consumable") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_consumable);
      }
      
      public function get isTiered() : Boolean
      {
         if(this.m_isTiered < 0)
         {
            this.m_isTiered = this.testProperty("tiered") ? 1 : 0;
         }
         return this.isPropertyEnabledAfterDateGateCheck(this.m_isTiered);
      }
      
      public function get totalTiers() : int
      {
         if(this.m_totalTiers == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_totalTiers = m_dataSource.getInt("totalTiers");
            }
            else if(!m_itemXML.hasOwnProperty("@totalTiers"))
            {
               this.m_totalTiers = 0;
            }
            else
            {
               this.m_totalTiers = int(m_itemXML.@totalTiers);
            }
         }
         return this.m_totalTiers;
      }
      
      public function get allowMultipleFinished() : Boolean
      {
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getBoolean("allowMultipleFinished");
         }
         else
         {
            result = m_itemXML.hasOwnProperty("allowMultipleFinished") && m_itemXML.allowMultipleFinished.toString() == "true";
         }
         return result;
      }
      
      public function get allowMultipleConstructed() : Boolean
      {
         var result:Boolean = true;
         var countByName:uint = Global.world.getObjectsByName(this.getFinishedName()).length;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
            {
               if(m_dataSource.hasOwnProperty("allowMultipleConstructed"))
               {
                  result = !m_dataSource.getBoolean("allowMultipleConstructed") && countByName <= 0;
               }
            }
            else if(FarmGameSettingsManager.isInItemsAMFExperiment())
            {
               if(!m_dataSource.getBoolean("allowMultipleConstructed"))
               {
                  result = countByName <= 0;
               }
            }
            else if(m_dataSource.hasProperty("allowMultipleConstructed"))
            {
               result = !m_dataSource.getBoolean("allowMultipleConstructed") && countByName <= 0;
            }
         }
         else if(m_itemXML.hasOwnProperty("allowMultipleConstructed"))
         {
            result = m_itemXML.allowMultipleConstructed.toString() == "false" && countByName <= 0;
         }
         return result;
      }
      
      public function getNumInstancesOfThisItem(includeGiftbox:Boolean = true) : Number
      {
         var frameName:String = null;
         var giftItem:StorageItem = null;
         var giftData:Array = null;
         var giftCount:int = 0;
         if(includeGiftbox)
         {
            if(Global.player.gifts[code])
            {
               giftItem = Global.player.gifts[code] as StorageItem;
               if(giftItem != null)
               {
                  giftCount = giftItem.quantity;
               }
               else
               {
                  giftData = String(Global.player.gifts[code]).split(",");
                  if(giftData[0])
                  {
                     giftCount = Number(giftData[0]);
                  }
               }
            }
         }
         var numFrameItems:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            frameName = this.getDataProperty(m_dataSource,"frameName");
         }
         else
         {
            frameName = this.getXMLProperty(m_itemXML,"frameName");
         }
         if(frameName != null)
         {
            numFrameItems = Global.player.numLimitedItems(frameName);
         }
         var numLimited:Number = Global.player.numLimitedItems(name);
         if(MarketPreviewWindow.marketPreviewActive && numLimited > 0)
         {
            numLimited--;
         }
         return numLimited + numFrameItems + giftCount;
      }
      
      public function checkItemLimit(includeGiftbox:Boolean = true) : Boolean
      {
         var numOwned:Number = NaN;
         var itemNamesChecked:Object = null;
         var checkItemName:String = null;
         var limitedItemsInGroup:Array = null;
         var i:Number = NaN;
         var packageName:String = null;
         var nextItem:FarmItem = null;
         var limitedItemName:String = null;
         var itemPackageDataArray:Array = null;
         var itemPackageData:BaseDataSource = null;
         var packageCode:String = null;
         var itemPackage:XML = null;
         var code:String = null;
         var result:Boolean = false;
         if(limit > 0)
         {
            numOwned = this.getNumInstancesOfThisItem(includeGiftbox);
            if(!this.allowMultipleFinished)
            {
               itemNamesChecked = {};
               checkItemName = this.getExpansion();
               if(!checkItemName)
               {
                  checkItemName = this.getFinishedName();
               }
               while(Boolean(checkItemName) && Boolean(checkItemName != this.name) && !itemNamesChecked.hasOwnProperty(checkItemName))
               {
                  numOwned += Global.player.numLimitedItems(checkItemName);
                  nextItem = Global.farmGameSettingsManager.getFarmItemByName(checkItemName);
                  if(nextItem)
                  {
                     itemNamesChecked[checkItemName] = 1;
                     checkItemName = nextItem.getExpansion();
                     if(!checkItemName)
                     {
                        checkItemName = this.getFinishedName();
                     }
                  }
                  else
                  {
                     checkItemName = null;
                  }
               }
               limitedItemsInGroup = Global.farmGameSettingsManager.getItemsFromSameLimitGroup(this.name);
               for(i = 0; i < limitedItemsInGroup.length; i++)
               {
                  limitedItemName = limitedItemsInGroup[i];
                  if(!itemNamesChecked.hasOwnProperty(limitedItemName))
                  {
                     itemNamesChecked[limitedItemName] = 1;
                     numOwned += Global.player.numLimitedItems(limitedItemName);
                  }
               }
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  itemPackageDataArray = m_dataSource.getArray("itemPackage");
                  if(itemPackageDataArray.length > 0)
                  {
                     itemPackageData = itemPackageDataArray[0];
                     if(itemPackageData != null)
                     {
                        packageName = itemPackageData.toString();
                        if(packageName)
                        {
                           packageCode = Global.farmGameSettingsManager.getFarmItemCodeByName(packageName);
                           numOwned += Global.player.getGiftCountForItemKey(packageCode);
                           if(itemPackageData.hasProperty("allowOverflow") && !itemPackageData.getBoolean("allowOverflow"))
                           {
                              numOwned += itemPackageData.getInt("amount") - 1;
                           }
                        }
                     }
                  }
               }
               else if(m_itemXML.hasOwnProperty("itemPackage"))
               {
                  itemPackage = m_itemXML.itemPackage[0];
                  packageName = itemPackage.toString();
                  if(packageName != "")
                  {
                     code = Global.farmGameSettingsManager.getFarmItemCodeByName(packageName);
                     numOwned += Global.player.getGiftCountForItemKey(code);
                     if(itemPackage.hasOwnProperty("@allowOverflow") && itemPackage.@allowOverflow == "false")
                     {
                        numOwned += parseInt(itemPackage.@amount) - 1;
                     }
                  }
               }
            }
            result = limit <= numOwned;
            if(!this.allowMultipleConstructed)
            {
               result = true;
            }
         }
         if(!result && limitPrereq != null)
         {
            result = !this.checkLimitPrereqs();
         }
         if(Boolean(!result && Global.flashHotParams["FARM_103313_TMPRT_FIX"] && limitType != "") && Boolean(limitType != null) && limit > 0)
         {
            result = this.checkLimitType();
         }
         return result;
      }
      
      public function get seedpackagecode() : String
      {
         return "";
      }
      
      private function checkSeedInventory() : Boolean
      {
         var seedCountValue:Number = Global.player.seeds[this.seedpackagecode] ? Number(Global.player.seeds[this.seedpackagecode].quantity) : 0;
         return seedCountValue > 0;
      }
      
      public function get isVisible() : Boolean
      {
         return this.isInExperiment && this.buyable && this.checkDateGate() && this.checkGeoGate() && !this.isLicenseHidden && this.checkMarketPrereqs() && this.isVisibleOnApplyWorldItemsOnlyCheck || this.checkSeedInventory() || this.isLicenseValid && this.isInExperiment && this.checkMarketPrereqs() || this.isDealOfDaySaleItem && this.isInDealOfDayExperiment;
      }
      
      public function get isVisibleOnApplyWorldItemsOnlyCheck() : Boolean
      {
         var worldRestrictions:Array = null;
         var curWorldType:String = null;
         var showItem:Boolean = true;
         var worldSpecificClassLocks:Array = Global.worldManager.worldSpecificClassLocks;
         if(worldSpecificClassLocks != null && worldSpecificClassLocks.length > 0 && worldSpecificClassLocks.indexOf(this.className) != -1)
         {
            worldRestrictions = this.worldRestrictions;
            curWorldType = Global.worldManager.currentWorldType;
            if(worldRestrictions != null && worldRestrictions.length > 0 && worldRestrictions.indexOf(curWorldType) != -1)
            {
               showItem = true;
            }
            else
            {
               showItem = false;
            }
         }
         return showItem;
      }
      
      public function get canPurchase() : Boolean
      {
         var result:Boolean = false;
         if(!this.isLocked && this.isVisible && (!Global.worldManager.isVisiting() || Global.worldManager.isVisiting() && this.buyableFromNeighbor))
         {
            result = true;
         }
         return result;
      }
      
      public function get isLocked() : Boolean
      {
         var result:Boolean = false;
         var states:Array = this.getLockedStates();
         if(states != null && states.length > 0 && states[0] != UNLOCKED)
         {
            result = true;
         }
         return result;
      }
      
      public function getLockedStates(context:Object = null) : Array
      {
         var passesGateCheck:Boolean = false;
         var lockedParams:Array = new Array();
         if(!this.isInExperiment)
         {
            lockedParams.push(FarmItemLock.LOCKED);
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            passesGateCheck = Global.player.checkGate(this.unlock,null,null,this);
         }
         else
         {
            passesGateCheck = Global.player.checkGate(this.unlock,name,m_itemXML);
         }
         if(!passesGateCheck)
         {
            if(this.unlock == "")
            {
               lockedParams.push(FarmItemLock.LEVEL);
            }
            else
            {
               lockedParams.push(this.unlock);
            }
         }
         if(this.unlock == FarmItemLock.LOCKED_HIDDEN_PRICE)
         {
            lockedParams.push(FarmItemLock.LOCKED_HIDDEN_PRICE);
         }
         if(!this.doesLockedParamExist(lockedParams,FarmItemLock.INSTANCE_TIERED) && this.checkItemLimit())
         {
            lockedParams.push(FarmItemLock.LIMIT_HIT);
         }
         lockedParams = lockedParams.concat(this.allMissingRequirements);
         if(this.checkIncrementalGate() && Boolean(this.m_incrementalGateType))
         {
            lockedParams.push(this.m_incrementalGateType);
         }
         if(!this.checkPurchasePrereqs(context))
         {
            lockedParams.push(FarmItemLock.PURCHASE_PREREQ);
         }
         if(lockedParams.length == 0)
         {
            lockedParams.push(UNLOCKED);
         }
         return lockedParams;
      }
      
      public function doesLockedParamExist(lockedParams:Array, lock:String) : Boolean
      {
         var lockParam:String = null;
         var returnVal:Boolean = false;
         for each(lockParam in lockedParams)
         {
            if(lock == lockParam)
            {
               returnVal = true;
               break;
            }
         }
         return returnVal;
      }
      
      public function get isUnlocked() : Boolean
      {
         var result:Boolean = false;
         var locks:Array = this.getLockedStates();
         for(var i:Number = 0; i < locks.length; i++)
         {
            if(locks[i] == UNLOCKED)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         return true;
      }
      
      public function onSell(quantity:int = 1) : void
      {
      }
      
      public function canStore(storageType:String) : Boolean
      {
         return false;
      }
      
      public function get canShare() : Boolean
      {
         return false;
      }
      
      public function get canUse() : Boolean
      {
         return false;
      }
      
      public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
      }
      
      public function get marketCardName() : String
      {
         if(this.m_marketCardName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_marketCardName = this.getDataProperty(m_dataSource,"marketCardDescriptor");
            }
            else
            {
               this.m_marketCardName = this.getXMLProperty(m_itemXML,"marketCardDescriptor");
               if(this.m_marketCardName == null)
               {
                  this.m_marketCardName = "";
               }
            }
         }
         return this.m_marketCardName;
      }
      
      public function get marketPrereqName() : String
      {
         var marketPrereqName:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            marketPrereqName = this.getDataProperty(m_dataSource,"marketPrereqs");
         }
         else
         {
            marketPrereqName = this.getXMLProperty(m_itemXML,"marketPrereqs");
         }
         return marketPrereqName;
      }
      
      public function get aoeLicenseKey() : String
      {
         if(this.m_aoeLicenseKey == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_aoeLicenseKey = m_dataSource.getString("aoeLicenseKey");
            }
            else
            {
               this.m_aoeLicenseKey = m_itemXML.aoeLicenseKey;
            }
            if(this.m_aoeLicenseKey == null)
            {
               this.m_aoeLicenseKey = "";
            }
         }
         return this.m_aoeLicenseKey;
      }
      
      public function get eventCallbackName() : String
      {
         if(this.m_eventName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_eventName = m_dataSource.getString("eventCallbackName");
            }
            else
            {
               this.m_eventName = m_itemXML.eventCallbackName;
            }
            if(this.m_eventName == null)
            {
               this.m_eventName = "";
            }
         }
         return this.m_eventName;
      }
      
      public function get aoeTargetKeywords() : Array
      {
         var targetKeyword:String = null;
         var keyword:String = null;
         if(this.m_aoeTargetKeywords == null)
         {
            this.m_aoeTargetKeywords = [];
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               targetKeyword = m_dataSource.getString("aoeTargetKeyword");
               if(targetKeyword)
               {
                  this.m_aoeTargetKeywords.push(targetKeyword);
               }
            }
            else if(m_itemXML.hasOwnProperty("aoeTargetKeyword"))
            {
               for each(keyword in m_itemXML.aoeTargetKeyword)
               {
                  this.m_aoeTargetKeywords.push(keyword);
               }
            }
         }
         return this.m_aoeTargetKeywords;
      }
      
      public function get hideHarvestPick() : Boolean
      {
         if(this.m_hideHarvestPick == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_hideHarvestPick = this.getDataProperty(m_dataSource,"hideHarvestPick");
            }
            else
            {
               this.m_hideHarvestPick = this.getXMLProperty(m_itemXML,"hideHarvestPick");
            }
         }
         return this.m_hideHarvestPick == "true";
      }
      
      public function set marketCardName(name:String) : void
      {
         this.m_marketCardName = name;
         this.m_marketCardDescriptor == null;
         this.marketCardDescriptor;
      }
      
      public function get marketCardDescriptor() : MarketCardDescriptor
      {
         if(this.m_marketCardDescriptor == null)
         {
            if(this.marketCardName != "")
            {
               this.m_marketCardDescriptor = Global.marketConfigSettings.getMarketCardDescriptor(this.marketCardName);
            }
            else
            {
               this.m_marketCardDescriptor = Global.marketConfigSettings.getMarketCardDescriptor(MarketCardDescriptor.DEFAULT_NAME);
            }
         }
         return this.m_marketCardDescriptor;
      }
      
      public function get displayLoader() : MapResourceDL
      {
         if(this.m_displayLoader == null)
         {
            this.m_displayLoader = new MapResourceDL(this);
         }
         return this.m_displayLoader;
      }
      
      public function resetDisplayLoader() : void
      {
         if(this.m_displayLoader)
         {
            this.m_displayLoader.cleanup();
            this.m_displayLoader = null;
            m_imageData = null;
         }
      }
      
      public function get xml() : XML
      {
         return m_itemXML;
      }
      
      private function get dataSource() : BaseDataSource
      {
         return m_dataSource;
      }
      
      public function set xml(xmlIn:XML) : void
      {
         m_itemXML = xmlIn;
      }
      
      public function swapToCashData() : void
      {
         m_dataSource = this.m_cashData;
      }
      
      public function swapToSaleData() : void
      {
         m_dataSource = this.m_saleData;
      }
      
      public function set cashXML(xmlIn:XML) : void
      {
         this.m_cashXML = xmlIn;
      }
      
      public function get cashXML() : XML
      {
         return this.m_cashXML;
      }
      
      public function set cashData(dataSource:BaseDataSource) : void
      {
         this.m_cashData = dataSource;
      }
      
      public function getPropertyFromItemCashSaleSource(propName:String) : String
      {
         var retStr:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource)
            {
               retStr = m_dataSource.getString(propName);
            }
            else if(this.m_cashData)
            {
               retStr = this.m_cashData.getString(propName);
            }
            else if(this.m_saleData)
            {
               retStr = this.m_saleData.getString(propName);
            }
         }
         else if(m_itemXML)
         {
            if(m_itemXML.hasOwnProperty(propName))
            {
               retStr = m_itemXML[propName];
            }
         }
         else if(this.m_cashXML)
         {
            if(this.m_cashXML.hasOwnProperty(propName))
            {
               retStr = this.m_cashXML[propName];
            }
         }
         else if(this.m_saleXML)
         {
            if(this.m_saleXML.hasOwnProperty(propName))
            {
               retStr = this.m_saleXML[propName];
            }
         }
         return retStr;
      }
      
      public function getPropertyFromCashItemSaleSource(propName:String) : String
      {
         var retStr:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.m_cashData)
            {
               retStr = this.m_cashData.getString(propName);
            }
            else if(m_dataSource)
            {
               retStr = m_dataSource.getString(propName);
            }
            else if(this.m_saleData)
            {
               retStr = this.m_saleData.getString(propName);
            }
         }
         else if(this.m_cashXML)
         {
            if(this.m_cashXML.hasOwnProperty(propName))
            {
               retStr = this.m_cashXML[propName];
            }
         }
         else if(m_itemXML)
         {
            if(m_itemXML.hasOwnProperty(propName))
            {
               retStr = m_itemXML[propName];
            }
         }
         else if(this.m_saleXML)
         {
            if(this.m_saleXML.hasOwnProperty(propName))
            {
               retStr = this.m_saleXML[propName];
            }
         }
         return retStr;
      }
      
      public function canRotate() : Boolean
      {
         var dataSourceToUse:BaseDataSource = null;
         var imageArr:Array = null;
         var curDS:BaseDataSource = null;
         var objXML:XML = null;
         var canRotate:Boolean = false;
         var idx:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dataSourceToUse = m_dataSource ? m_dataSource : (this.m_cashData ? this.m_cashData : this.m_saleData);
            imageArr = dataSourceToUse.getArray("image");
            for(idx = 0; idx < imageArr.length; idx++)
            {
               curDS = imageArr[idx] as BaseDataSource;
               if(curDS.getString("name") == "built_rotatable")
               {
                  canRotate = true;
               }
            }
         }
         else
         {
            objXML = m_itemXML ? m_itemXML : (this.m_cashXML ? this.m_cashXML : this.m_saleXML);
            while(objXML.image[idx] != undefined)
            {
               if(objXML.image[idx].attribute("name") == "built_rotatable")
               {
                  canRotate = true;
               }
               idx++;
            }
         }
         return canRotate;
      }
      
      public function getTargetQuestArray() : Array
      {
         var targetQuestDSArr:Array = null;
         var targetQuestDS:BaseDataSource = null;
         var targetQuestXml:XML = null;
         var targetQuestArr:Array = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            targetQuestDSArr = m_dataSource.getArray("targetQuest");
            for each(targetQuestDS in targetQuestDSArr)
            {
               targetQuestArr.push(targetQuestDS.toString());
            }
         }
         else if(m_itemXML.targetQuest != null)
         {
            for each(targetQuestXml in m_itemXML.targetQuest)
            {
               targetQuestArr.push(targetQuestXml.toString());
            }
         }
         return targetQuestArr;
      }
      
      public function getDonationArr() : Array
      {
         var retArr:Array = null;
         var curDS:BaseDataSource = null;
         var curObj:Object = null;
         var donationArr:Array = m_dataSource.getArray("donation");
         var len:int = int(donationArr.length);
         for(var i:int = 0; i < len; i++)
         {
            curDS = donationArr[i] as BaseDataSource;
            curObj = new Object();
            curObj.licenseCode = curDS.getString("name");
            curObj.donationValue = curDS.getString("value");
            curObj.defaultButton = curDS.getString("defaultButton");
            retArr.push(curObj);
         }
         return retArr;
      }
      
      public function set saleXML(xmlIn:XML) : void
      {
         this.m_saleXML = xmlIn;
      }
      
      public function set saleData(dataSource:BaseDataSource) : void
      {
         this.m_saleData = dataSource;
      }
      
      public function get saleXML() : XML
      {
         return this.m_saleXML;
      }
      
      public function get placeable() : Boolean
      {
         var isPlaceable:Boolean = false;
         if(this.m_placeable == -1)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               isPlaceable = m_dataSource.getBoolean("placeable");
            }
            else
            {
               isPlaceable = m_itemXML.@placeable == "true";
            }
            if(isPlaceable)
            {
               this.m_placeable = 1;
            }
            else
            {
               this.m_placeable = 0;
            }
         }
         return this.m_placeable == 1;
      }
      
      public function get canUseFromGiftBox() : Boolean
      {
         var cannotUseFromGiftBox:Boolean = false;
         if(this.m_canUseFromGiftBox == -1)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cannotUseFromGiftBox = m_dataSource.hasProperty("canUseFromGiftBox") && !m_dataSource.getBoolean("canUseFromGiftBox");
            }
            else
            {
               cannotUseFromGiftBox = m_itemXML.@canUseFromGiftBox == "false";
            }
            if(cannotUseFromGiftBox)
            {
               this.m_canUseFromGiftBox = 0;
            }
            else
            {
               this.m_canUseFromGiftBox = 1;
            }
         }
         return this.m_canUseFromGiftBox == 1;
      }
      
      public function displayCantUseFromGiftBoxDialog() : void
      {
         var message:String = null;
         if(ZLocUtils.hasString("Dialogs",this.name + "_CannotUseFromGiftBox"))
         {
            message = ZLocUtils.t("Dialogs",this.name + "_CannotUseFromGiftBox",{"item":ZLocUtils.tk_pk(this.friendlyName)});
         }
         else
         {
            message = ZLocUtils.t("Dialogs","CannotUseFromGiftBox",{"item":ZLocUtils.tk_pk(this.friendlyName)});
         }
         UI.showMessage(message,UI.BUTTON_LAYOUT_OK,null,null,false,null,null,false);
      }
      
      public function get hasPreview() : Boolean
      {
         var previewString:String = null;
         if(this.m_preview == -1)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               previewString = m_dataSource.getString("preview");
            }
            else
            {
               previewString = m_itemXML.@preview;
            }
            if(this.type == FarmItemType.BLOSSOM)
            {
               this.m_preview = 0;
            }
            else if(previewString == "true")
            {
               this.m_preview = 1;
            }
            else if(previewString == "false")
            {
               this.m_preview = 0;
            }
            else
            {
               this.m_preview = this.defaultPreview() ? 1 : 0;
            }
         }
         return this.m_preview == 1;
      }
      
      protected function defaultPreview() : Boolean
      {
         return false;
      }
      
      public function getPreviewState() : String
      {
         return "";
      }
      
      public function get limitedLocale() : String
      {
         var limitedLocale:String = null;
         if(this.m_limitedLocale == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               limitedLocale = m_dataSource.getString("limitedLocale");
            }
            else
            {
               limitedLocale = m_itemXML.limitedLocale;
            }
         }
         return this.m_limitedLocale;
      }
      
      public function get limitedGiftStart() : String
      {
         if(this.m_limitedGiftStart == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitedGiftStart = this.getDataProperty(m_dataSource,"limitedGiftStart");
            }
            else
            {
               this.m_limitedGiftStart = this.getXMLProperty(m_itemXML,"limitedGiftStart");
            }
            if(this.m_limitedGiftStart == "")
            {
               this.m_limitedGiftStart = null;
            }
         }
         return this.m_limitedGiftStart;
      }
      
      public function get limitedGiftEnd() : String
      {
         if(this.m_limitedGiftEnd == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitedGiftEnd = this.getDataProperty(m_dataSource,"limitedGiftEnd");
            }
            else
            {
               this.m_limitedGiftEnd = this.getXMLProperty(m_itemXML,"limitedGiftEnd");
            }
            if(this.m_limitedGiftEnd == "")
            {
               this.m_limitedGiftEnd = null;
            }
         }
         return this.m_limitedGiftEnd;
      }
      
      public function getDialogConfig(key:String) : Object
      {
         var dialogName:String = null;
         var className:String = null;
         var dialogArray:Array = null;
         var dialogData:BaseDataSource = null;
         var experimentName:String = null;
         var dialogXML:XML = null;
         var expName:String = null;
         var attributes:XMLList = null;
         var attribute:XML = null;
         var result:Object = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dialogArray = m_dataSource.getArray("dialogs","dialog");
            if(dialogArray.length > 0)
            {
               for each(dialogData in dialogArray)
               {
                  experimentName = dialogData.getString("experiment");
                  if(experimentName == "" || Boolean(Global.experimentManager.getExperimentVariant(experimentName)))
                  {
                     dialogName = dialogData.getString("name");
                     className = dialogData.getString("className");
                     if(dialogName == key && className != "")
                     {
                        result = dialogData.getAttributesHash();
                        result.width = 0;
                        result.height = 0;
                     }
                  }
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("dialogs"))
         {
            for each(dialogXML in m_itemXML.dialogs.dialog)
            {
               expName = dialogXML.@experiment;
               if(expName == "" || Boolean(Global.experimentManager.getExperimentVariant(expName)))
               {
                  dialogName = dialogXML.@name;
                  className = dialogXML.@className;
                  if(dialogName == key && className != "")
                  {
                     result = new Object();
                     attributes = dialogXML.attributes();
                     for each(attribute in attributes)
                     {
                        result[String(attribute.name())] = String(attribute);
                     }
                     result.width = 0;
                     result.height = 0;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getActiveXml(itemName:String = "") : XML
      {
         var result:XML = null;
         if(itemName.indexOf(FarmItem.ITEM_POSTFIX_SALE) >= 0 && this.m_saleXML != null)
         {
            result = this.m_saleXML;
         }
         else if(itemName.indexOf(FarmItem.ITEM_POSTFIX_CASH) >= 0 && this.m_cashXML != null)
         {
            result = this.m_cashXML;
         }
         else
         {
            result = m_itemXML;
         }
         return result;
      }
      
      public function getActiveDS(itemName:String = "") : BaseDataSource
      {
         var result:BaseDataSource = null;
         if(itemName.indexOf(FarmItem.ITEM_POSTFIX_SALE) >= 0 && this.m_saleData != null)
         {
            result = this.m_saleData;
         }
         else if(itemName.indexOf(FarmItem.ITEM_POSTFIX_CASH) >= 0 && this.m_cashData != null)
         {
            result = this.m_cashData;
         }
         else
         {
            result = m_dataSource;
         }
         return result;
      }
      
      public function getActiveXmlForContext(context:String = "coins") : XML
      {
         var activeXML:XML = m_itemXML;
         if(context == FarmItem.MARKET_CONTEXT_CASH)
         {
            activeXML = this.m_cashXML;
         }
         else if(context == FarmItem.MARKET_CONTEXT_SALE)
         {
            activeXML = this.m_saleXML;
         }
         return activeXML;
      }
      
      public function getActiveDSForContext(context:String = "coins") : BaseDataSource
      {
         var activeDS:BaseDataSource = m_dataSource;
         if(context == FarmItem.MARKET_CONTEXT_CASH)
         {
            activeDS = this.m_cashData;
         }
         else if(context == FarmItem.MARKET_CONTEXT_SALE)
         {
            activeDS = this.m_saleData;
         }
         return activeDS;
      }
      
      public function getClassNameFromActiveData(itemName:String = "") : String
      {
         var activeDS:BaseDataSource = null;
         var activeXML:XML = null;
         var activeClassName:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = this.getActiveDS(itemName);
            activeClassName = activeDS.getString("className");
         }
         else
         {
            activeXML = this.getActiveXml(itemName);
            if(activeXML != null)
            {
               activeClassName = activeXML.@className;
            }
         }
         return activeClassName;
      }
      
      public function getCraftTypeFromActiveData(itemName:String = "") : String
      {
         var activeDS:BaseDataSource = null;
         var activeXML:XML = null;
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = this.getActiveDS(itemName);
            result = activeDS.getString("craftType");
         }
         else
         {
            activeXML = this.getActiveXml(itemName);
            if(activeXML != null)
            {
               result = activeXML.@craftType;
            }
         }
         return result;
      }
      
      public function getIconUrlFromActiveData(itemName:String = "") : String
      {
         var imageUrl:String = null;
         var activeDS:BaseDataSource = null;
         var imageDataArray:Array = null;
         var imageData:BaseDataSource = null;
         var activeXML:XML = null;
         var images:XMLList = null;
         var activeIconUrl:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = this.getActiveDS(itemName);
            imageDataArray = activeDS.getArray("image");
            if(imageDataArray.length > 0)
            {
               for each(imageData in imageDataArray)
               {
                  if(imageData.getString("name") == "icon")
                  {
                     imageUrl = imageData.getString("url");
                     break;
                  }
               }
            }
         }
         else
         {
            activeXML = this.getActiveXml(itemName);
            if(activeXML != null)
            {
               images = activeXML.image.(@name == "icon");
               if(images.length())
               {
                  imageUrl = images[0].@url;
               }
            }
         }
         if(imageUrl)
         {
            activeIconUrl = Global.getAssetURL(imageUrl);
         }
         return activeIconUrl;
      }
      
      public function getRegionLogoUrlFromActiveData() : String
      {
         var activeDS:BaseDataSource = null;
         var imageDataArray:Array = null;
         var imageData:BaseDataSource = null;
         var activeXML:XML = null;
         var images:XMLList = null;
         var imageUrl:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            activeDS = this.getActiveDS(name);
            imageDataArray = activeDS.getArray("image");
            if(imageDataArray.length > 0)
            {
               for each(imageData in imageDataArray)
               {
                  if(imageData.getString("name") == "regionLogo")
                  {
                     imageUrl = imageData.getString("url");
                     break;
                  }
               }
            }
         }
         else
         {
            activeXML = this.getActiveXml(name);
            if(activeXML != null)
            {
               images = activeXML.image.(@name == "regionLogo");
               if(images.length())
               {
                  imageUrl = images[0].@url;
               }
            }
         }
         return imageUrl;
      }
      
      public function getActiveXmlByCode(itemCode:String = null) : XML
      {
         if(itemCode == null)
         {
            itemCode = this.code;
         }
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         return this.getActiveXml(itemName);
      }
      
      public function getActiveDataByCode(itemCode:String = null) : BaseDataSource
      {
         if(itemCode == null)
         {
            itemCode = code;
         }
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         return this.getActiveDS(itemName);
      }
      
      public function get sellCurrency() : String
      {
         return this.marketIsWorldCurrency ? this.market : Currency.COINS;
      }
      
      public function get untunedSellPrice() : Number
      {
         var sellBackRatio:Number = NaN;
         var amount:Number = NaN;
         if(this.m_sellPrice == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_dataSource.hasProperty("sellPrice"))
               {
                  this.m_sellPrice = m_dataSource.getInt("sellPrice");
               }
            }
            else if(m_itemXML.hasOwnProperty("sellPrice"))
            {
               this.m_sellPrice = m_itemXML.sellPrice;
            }
            if(this.m_sellPrice < 0)
            {
               sellBackRatio = Global.farmGameSettingsManager.getNumber("sellBackRatio");
               amount = this.cost;
               this.m_sellPrice = Math.floor(amount * sellBackRatio);
            }
         }
         return this.m_sellPrice;
      }
      
      public function get sellPrice() : Number
      {
         var currencyData:CurrencyData = null;
         var experimentVariant:int = 0;
         var sellingPrice:Number = this.untunedSellPrice;
         if(this.marketIsWorldCurrency)
         {
            currencyData = Global.farmGameSettingsManager.getCurrencyData(this.market);
            if(currencyData)
            {
               experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
               sellingPrice = Math.floor(this.m_sellPrice * currencyData.getInflowTuningMultiplierByVariant(experimentVariant));
            }
            else
            {
               ErrorManager.addError("Missing currency data for " + this.market + ". Item name = " + this.name);
            }
         }
         else
         {
            sellingPrice = this.m_sellPrice;
         }
         return sellingPrice;
      }
      
      public function get sellDisplayPrice() : Number
      {
         var currencyData:CurrencyData = null;
         var sellDisplayPrice:Number = 0;
         this.sellPrice;
         if(this.marketIsWorldCurrency)
         {
            currencyData = Global.farmGameSettingsManager.getCurrencyData(this.market);
            if(currencyData)
            {
               sellDisplayPrice = Math.floor(this.m_sellPrice * currencyData.getInflowTuningMultiplierByVariant(currencyData.getDisplayVariant()));
            }
            else
            {
               ErrorManager.addError("Missing currency data for " + this.market + ". Item name = " + this.name);
            }
         }
         else
         {
            sellDisplayPrice = this.m_sellPrice;
         }
         return sellDisplayPrice;
      }
      
      public function checkDateGateXML(itemXML:XML, checkLimitedStart:Boolean = true, checkLimitedEnd:Boolean = true) : Boolean
      {
         var limitedStart:Number = NaN;
         var limitedEnd:Number = NaN;
         var returnVal:Boolean = true;
         if(checkLimitedStart && returnVal && itemXML.hasOwnProperty("limitedStart"))
         {
            limitedStart = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(itemXML,"limitedStart"));
            returnVal = limitedStart < GlobalEngine.serverTime;
         }
         if(checkLimitedEnd && returnVal && itemXML.hasOwnProperty("limitedEnd"))
         {
            limitedEnd = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(itemXML,"limitedEnd"));
            returnVal = limitedEnd > GlobalEngine.serverTime;
         }
         return returnVal;
      }
      
      public function checkDateGateData(itemData:BaseDataSource, checkLimitedStart:Boolean = true, checkLimitedEnd:Boolean = true) : Boolean
      {
         var limitedStart:Number = NaN;
         var limitedEnd:Number = NaN;
         var returnVal:Boolean = true;
         if(checkLimitedStart && itemData.hasProperty("limitedStart"))
         {
            limitedStart = FarmGameUtil.synchronizedDateToNumber(this.getDataProperty(itemData,"limitedStart"));
            returnVal = limitedStart < GlobalEngine.serverTime;
         }
         if(checkLimitedEnd && returnVal && itemData.hasProperty("limitedEnd"))
         {
            limitedEnd = FarmGameUtil.synchronizedDateToNumber(this.getDataProperty(itemData,"limitedEnd"));
            returnVal = limitedEnd > GlobalEngine.serverTime;
         }
         return returnVal;
      }
      
      public function canShow() : Boolean
      {
         var canShow:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            canShow = this.isInExperiment && (this.getLimitedStartDate() == null || this.checkDateGateData(m_dataSource,true,false));
         }
         else
         {
            canShow = this.isInExperiment && (this.getLimitedStartDate() == null || this.checkDateGateXML(m_itemXML,true,false));
         }
         return canShow;
      }
      
      public function isLimitedItem() : Boolean
      {
         var isLimitedCoin:Boolean = false;
         var isLimitedCash:Boolean = false;
         var isLimitedSale:Boolean = false;
         if(GlobalEngine.isServerTimeValid() && this.m_isLimited < 0)
         {
            isLimitedCoin = false;
            isLimitedCash = false;
            isLimitedSale = false;
            if(this.buyableWithCurrency())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  isLimitedCoin = m_dataSource.hasProperty("limitedStart") || m_dataSource.hasOwnProperty("limitedEnd");
               }
               else
               {
                  isLimitedCoin = m_itemXML.hasOwnProperty("limitedStart") || m_itemXML.hasOwnProperty("limitedEnd");
               }
            }
            if(this.buyableWithCash())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
               {
                  isLimitedCash = this.m_cashData.hasProperty("limitedStart") || this.m_cashData.hasProperty("limitedEnd");
               }
               else
               {
                  isLimitedCash = this.m_cashXML.hasOwnProperty("limitedStart") || this.m_cashXML.hasOwnProperty("limitedEnd");
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
            {
               isLimitedSale = this.m_saleData.hasProperty("limitedStart") || this.m_saleData.hasProperty("limitedEnd");
            }
            else if(this.m_saleXML)
            {
               isLimitedSale = this.m_saleXML.hasOwnProperty("limitedStart") || this.m_saleXML.hasOwnProperty("limitedEnd");
            }
            this.m_isLimited = isLimitedCoin || isLimitedCash || isLimitedSale ? 1 : 0;
         }
         return this.m_isLimited == 1;
      }
      
      public function isLEItem() : Boolean
      {
         return this.isLimitedItem() && this.marketEntriesHash["limited"] != null || this.marketIsBerry && this.hasLimitedStartEnd();
      }
      
      public function isCharityItem() : Boolean
      {
         return this.isLimitedItem() && this.marketEntriesHash["limitedcharity"] != null;
      }
      
      public function isVipItem() : Boolean
      {
         return this.marketEntriesHash[FarmGameSettingsManager.TYPE_VIP] != null;
      }
      
      public function hasLimitedStartEnd() : Boolean
      {
         var isLimitedCoin:Boolean = false;
         var isLimitedCash:Boolean = false;
         var isLimitedSale:Boolean = false;
         if(GlobalEngine.isServerTimeValid() && this.m_hasLimitedStartEnd < 0)
         {
            isLimitedCoin = false;
            isLimitedCash = false;
            isLimitedSale = false;
            if(this.buyableWithCurrency())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  isLimitedCoin = m_dataSource.hasProperty("limitedStart") && m_dataSource.hasProperty("limitedEnd");
               }
               else
               {
                  isLimitedCoin = m_itemXML.hasOwnProperty("limitedStart") && m_itemXML.hasOwnProperty("limitedEnd");
               }
            }
            if(this.buyableWithCash())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
               {
                  isLimitedCash = this.m_cashData.hasProperty("limitedStart") && this.m_cashData.hasProperty("limitedEnd");
               }
               else
               {
                  isLimitedCash = this.m_cashXML.hasOwnProperty("limitedStart") && this.m_cashXML.hasOwnProperty("limitedEnd");
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
            {
               isLimitedSale = this.m_saleData.hasProperty("limitedStart") && this.m_saleData.hasProperty("limitedEnd");
            }
            else if(this.m_saleXML)
            {
               isLimitedSale = this.m_saleXML.hasOwnProperty("limitedStart") && this.m_saleXML.hasOwnProperty("limitedEnd");
            }
            this.m_hasLimitedStartEnd = isLimitedCoin || isLimitedCash || isLimitedSale ? 1 : 0;
         }
         return this.m_hasLimitedStartEnd == 1;
      }
      
      public function hasLimitedStart() : Boolean
      {
         var isLimitedCoin:Boolean = false;
         var isLimitedCash:Boolean = false;
         var isLimitedSale:Boolean = false;
         if(GlobalEngine.isServerTimeValid() && this.m_hasLimitedStart < 0)
         {
            isLimitedCoin = false;
            isLimitedCash = false;
            isLimitedSale = false;
            if(this.buyableWithCurrency())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  isLimitedCoin = m_dataSource.hasProperty("limitedStart");
               }
               else
               {
                  isLimitedCoin = m_itemXML.hasOwnProperty("limitedStart");
               }
            }
            if(this.buyableWithCash())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
               {
                  isLimitedCash = this.m_cashData.hasProperty("limitedStart");
               }
               else
               {
                  isLimitedCash = this.m_cashXML.hasOwnProperty("limitedStart");
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
            {
               isLimitedSale = this.m_saleData.hasProperty("limitedStart");
            }
            else if(this.m_saleXML)
            {
               isLimitedSale = this.m_saleXML.hasOwnProperty("limitedStart");
            }
            this.m_hasLimitedStart = isLimitedCoin || isLimitedCash || isLimitedSale ? 1 : 0;
         }
         return this.m_hasLimitedStart == 1;
      }
      
      override public function get limitedStartTime() : Number
      {
         var limitedTimeCoin:Number = NaN;
         var limitedTimeCash:Number = NaN;
         var limitedTimeSale:Number = NaN;
         if(GlobalEngine.isServerTimeValid() && m_limitedStartTime == INVALID_VALUE)
         {
            limitedTimeCoin = BIG_VALUE;
            limitedTimeCash = BIG_VALUE;
            limitedTimeSale = BIG_VALUE;
            if(this.buyableWithCurrency())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(m_dataSource.hasProperty("limitedStart"))
                  {
                     limitedTimeCoin = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(m_dataSource,"limitedStart"));
                  }
               }
               else if(m_itemXML.hasOwnProperty("limitedStart"))
               {
                  limitedTimeCoin = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(m_itemXML,"limitedStart"));
               }
            }
            if(this.buyableWithCash())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(Boolean(this.m_cashData) && this.m_cashData.hasProperty("limitedStart"))
                  {
                     limitedTimeCash = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(this.m_cashData,"limitedStart"));
                  }
               }
               else if(Boolean(this.m_cashXML) && this.m_cashXML.hasOwnProperty("limitedStart"))
               {
                  limitedTimeCash = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(this.m_cashXML,"limitedStart"));
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Boolean(this.m_saleData) && this.m_saleData.hasProperty("limitedStart"))
               {
                  limitedTimeSale = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(this.m_saleData,"limitedStart"));
               }
            }
            else if(Boolean(this.m_saleXML) && this.m_saleXML.hasOwnProperty("limitedStart"))
            {
               limitedTimeSale = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(this.m_saleXML,"limitedStart"));
            }
            m_limitedStartTime = Math.min(limitedTimeCoin,limitedTimeCash,limitedTimeSale);
         }
         return m_limitedStartTime;
      }
      
      override public function get limitedEndTime() : Number
      {
         var limitedTimeCoin:Number = NaN;
         var limitedTimeCash:Number = NaN;
         var limitedTimeSale:Number = NaN;
         if(GlobalEngine.isServerTimeValid() && m_limitedEndTime == INVALID_VALUE)
         {
            limitedTimeCoin = 0;
            limitedTimeCash = 0;
            limitedTimeSale = 0;
            if(this.buyableWithCurrency())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(m_dataSource.hasProperty("limitedEnd"))
                  {
                     limitedTimeCoin = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(m_dataSource,"limitedEnd"));
                  }
               }
               else if(m_itemXML.hasOwnProperty("limitedEnd"))
               {
                  limitedTimeCoin = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(m_itemXML,"limitedEnd"));
               }
            }
            if(this.buyableWithCash())
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(Boolean(this.m_cashData) && this.m_cashData.hasProperty("limitedEnd"))
                  {
                     limitedTimeCash = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(this.m_cashData,"limitedEnd"));
                  }
               }
               else if(this.m_cashXML.hasOwnProperty("limitedEnd"))
               {
                  limitedTimeCash = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(this.m_cashXML,"limitedEnd"));
               }
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Boolean(this.m_saleData) && this.m_saleData.hasProperty("limitedEnd"))
               {
                  limitedTimeSale = FarmGameUtil.synchronizedDateTimeToNumber(this.getDataProperty(this.m_saleData,"limitedEnd"));
               }
            }
            else if(Boolean(this.m_saleXML) && this.m_saleXML.hasOwnProperty("limitedEnd"))
            {
               limitedTimeSale = FarmGameUtil.synchronizedDateToNumber(this.getXMLProperty(this.m_saleXML,"limitedEnd"));
            }
            m_limitedEndTime = Math.max(limitedTimeCoin,limitedTimeCash,limitedTimeSale);
         }
         return m_limitedEndTime;
      }
      
      override public function checkDateGate() : Boolean
      {
         var returnVal:Boolean = true;
         var checkCoin:Boolean = false;
         var checkCash:Boolean = false;
         var checkSale:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            checkCoin = this.checkDateGateData(m_dataSource);
         }
         else if(m_itemXML)
         {
            checkCoin = this.checkDateGateXML(m_itemXML);
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
         {
            checkCash = this.checkDateGateData(m_dataSource);
         }
         else if(this.m_cashXML)
         {
            checkCash = this.checkDateGateXML(this.m_cashXML);
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
         {
            checkSale = this.checkDateGateData(m_dataSource);
         }
         else if(this.m_saleXML)
         {
            checkSale = this.checkDateGateXML(this.m_saleXML);
         }
         return checkCoin || checkCash || checkSale;
      }
      
      public function checkStartDateGate() : Boolean
      {
         var returnVal:Boolean = true;
         var checkCoin:Boolean = false;
         var checkCash:Boolean = false;
         var checkSale:Boolean = false;
         if(this.buyableWithCurrency())
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               checkCoin = this.checkDateGateData(m_dataSource,true,false);
            }
            else
            {
               checkCoin = this.checkDateGateXML(m_itemXML,true,false);
            }
         }
         if(this.buyableWithCash())
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_cashData))
            {
               checkCash = this.checkDateGateData(this.m_cashData,true,false);
            }
            else
            {
               checkCash = this.checkDateGateXML(this.m_cashXML,true,false);
            }
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_saleData))
         {
            checkSale = this.checkDateGateData(this.m_saleData,true,false);
         }
         else if(this.m_saleXML)
         {
            checkSale = this.checkDateGateXML(this.m_saleXML,true,false);
         }
         return checkCoin || checkCash || checkSale;
      }
      
      public function checkGeoGate() : Boolean
      {
         var geoIPData:BaseDataSource = null;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            geoIPData = m_dataSource.getData("geoip");
            if(geoIPData)
            {
               result = Global.geoIpManager.checkGeoGate(null,geoIPData);
            }
         }
         else if(m_itemXML.hasOwnProperty(GEOIP_XML_ELEMENT_NAME))
         {
            result = Global.geoIpManager.checkGeoGate(m_itemXML.geoip);
         }
         return result;
      }
      
      public function checkIncrementalGate() : Boolean
      {
         var gateData:Object = null;
         var acquired:Object = null;
         var playerGateItem:Object = null;
         var length:int = 0;
         var hashItem:String = null;
         var returnVal:Boolean = true;
         if(this.gateCode != "")
         {
            gateData = Global.player.incrementalGateArray[this.gateCode];
            if(gateData)
            {
               acquired = gateData.acquired;
               playerGateItem = Global.farmGameSettingsManager.getIncrementalGateItemByGateCode(this.gateCode);
               length = 0;
               this.m_incrementalGateType = playerGateItem.gateType;
               for each(hashItem in acquired)
               {
                  length++;
               }
               if(acquired)
               {
                  switch(playerGateItem.gateType)
                  {
                     case FarmItemLock.NEIGHBOR:
                        this.m_minNeighbors = Math.min(Math.max(gateData.baseValue + playerGateItem.addsRequired * (length + 1),playerGateItem.minValue),playerGateItem.maxValue);
                  }
               }
               else
               {
                  returnVal = false;
               }
            }
         }
         return returnVal;
      }
      
      public function get tooltipNotes() : String
      {
         var notes:String = "";
         if(ZLocUtils.hasString("Items",name + "_notes"))
         {
            notes = ZLocUtils.t("Items",name + "_notes");
         }
         return notes;
      }
      
      public function get specialValentinesItem() : Boolean
      {
         var res:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getBoolean("specialValentinesItem");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@specialValentinesItem.toString() == "true")
         {
            res = true;
         }
         return res;
      }
      
      public function cleanup() : void
      {
         this.displayLoader.cleanup();
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this.displayLoader.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this.displayLoader.removeEventListener(type,listener,useCapture);
      }
      
      public function getLimitedStartDate() : String
      {
         return limitedStartDate;
      }
      
      public function getLimitedEndDate() : String
      {
         return limitedEndDate;
      }
      
      public function isWithinLimitedStartDate(millsecondsBuffer:Number = 0) : Boolean
      {
         var startDate:Number = NaN;
         var serverTime:Number = NaN;
         var result:Boolean = false;
         if(this.isLimitedItem())
         {
            startDate = FarmGameUtil.synchronizedDateToNumber(this.getLimitedStartDate());
            serverTime = GlobalEngine.serverTime;
            if(startDate < serverTime + millsecondsBuffer)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isWithinLimitedEndDate(millsecondsBuffer:Number = 0) : Boolean
      {
         var endDate:Number = NaN;
         var serverTime:Number = NaN;
         var result:Boolean = true;
         if(this.isLimitedItem())
         {
            endDate = FarmGameUtil.synchronizedDateToNumber(this.getLimitedEndDate());
            serverTime = GlobalEngine.serverTime;
            if(endDate < serverTime - millsecondsBuffer)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function isWithinCountryCode() : Boolean
      {
         var geoIpDataArray:Array = null;
         var geoIpData:BaseDataSource = null;
         var geoIpXmlList:XMLList = null;
         var geoIpXml:XML = null;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            geoIpDataArray = m_dataSource.getArray("geoip","includeData");
            if(geoIpDataArray.length > 0)
            {
               result = false;
               for each(geoIpData in geoIpDataArray)
               {
                  if(Global.geoIpManager.geoip != null && geoIpData.getString("country") == Global.geoIpManager.geoip.country_code)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         else
         {
            geoIpXmlList = this.getGeoIpXml();
            if(geoIpXmlList)
            {
               result = false;
               for each(geoIpXml in geoIpXmlList)
               {
                  if(Global.geoIpManager.geoip != null && geoIpXml.@country == Global.geoIpManager.geoip.country_code)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      private function getGeoIpXml() : XMLList
      {
         var geoIpXml:XMLList = null;
         if(Boolean(m_itemXML.geoip) && m_itemXML.geoip.length() > 0)
         {
            geoIpXml = m_itemXML.geoip.includeData;
         }
         return geoIpXml;
      }
      
      public function getLimitedTimeLeft() : String
      {
         var endDate:Number = NaN;
         var result:String = "";
         if(this.isLimitedItem())
         {
            endDate = FarmGameUtil.synchronizedDateToNumber(this.getLimitedEndDate());
            result = FarmGameUtil.getTimeLeftText(endDate / 1000);
         }
         return result;
      }
      
      private function getLimitedDurationXml() : XML
      {
         var variant:int = 0;
         var durationList:XMLList = null;
         var durationXml:XML = null;
         if(Boolean(m_itemXML.limitedDurations) && m_itemXML.limitedDurations.length() > 0)
         {
            variant = Global.experimentManager.getExperimentVariant(m_itemXML.limitedDurations.@experiment);
            durationList = m_itemXML.limitedDurations.duration.(@variant == variant);
            if(durationList.length() > 0)
            {
               durationXml = durationList[0];
            }
         }
         return durationXml;
      }
      
      public function get craftType() : String
      {
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("craftType");
            if(result == "")
            {
               result = null;
            }
         }
         else if(m_itemXML["@craftType"])
         {
            result = m_itemXML["@craftType"];
         }
         return result;
      }
      
      public function get keywords() : Array
      {
         var keywordDataArray:Array = null;
         var keywordData:BaseDataSource = null;
         var xml:XML = null;
         var words:Array = [];
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            keywordDataArray = m_dataSource.getArray("keyword");
            if(keywordDataArray.length > 0)
            {
               for each(keywordData in keywordDataArray)
               {
                  words.push(keywordData.toString());
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("keyword"))
         {
            for each(xml in m_itemXML.keyword)
            {
               words.push(xml.toString());
            }
         }
         return words;
      }
      
      public function get className() : String
      {
         if(this.m_className == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_className = m_dataSource.getString("className");
            }
            else
            {
               this.m_className = m_itemXML.@className;
            }
         }
         return this.m_className;
      }
      
      public function get giftUseMultiselect() : Boolean
      {
         return this.m_giftUseMultiselect;
      }
      
      public function get actionBundle() : String
      {
         if(this.m_actionBundle == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_actionBundle = m_dataSource.getString("actionBundle");
            }
            else
            {
               this.m_actionBundle = m_itemXML.@actionBundle;
            }
         }
         return this.m_actionBundle;
      }
      
      public function get limitedQuantity() : String
      {
         if(this.m_limitedQuantity == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitedQuantity = m_dataSource.getString("limitedQuantity");
            }
            else
            {
               this.m_limitedQuantity = m_itemXML.@limitedQuantity;
            }
         }
         return this.m_limitedQuantity;
      }
      
      public function get showFeed() : Boolean
      {
         var showFeedBool:Boolean = false;
         var showFeedString:String = null;
         if(this.m_showFeed < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               showFeedBool = m_dataSource.getBoolean("showFeed");
            }
            else
            {
               showFeedString = m_itemXML.@showFeed;
               showFeedBool = showFeedString == "true";
            }
            if(!showFeedBool)
            {
               this.m_showFeed = 0;
            }
            else
            {
               this.m_showFeed = 1;
            }
         }
         return this.m_showFeed > 0;
      }
      
      public function get multiplace() : Boolean
      {
         var multiplaceBool:Boolean = false;
         var multiplaceString:String = null;
         if(this.m_multiplace < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               multiplaceBool = m_dataSource.getBoolean("multiplace");
            }
            else
            {
               multiplaceString = m_itemXML.@multiplace;
               multiplaceBool = multiplaceString == "true";
            }
            if(!multiplaceBool)
            {
               this.m_multiplace = 0;
            }
            else
            {
               this.m_multiplace = 1;
            }
         }
         return this.m_multiplace > 0;
      }
      
      public function getImageByName(imageName:String, absoluteUrl:Boolean = true) : String
      {
         var imageArray:Array = null;
         var mappedImageName:String = null;
         var imageData:BaseDataSource = null;
         var images:XMLList = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArray = m_dataSource.getArray("image");
            if(imageArray.length > 0)
            {
               mappedImageName = mapImageName(imageName);
               for each(imageData in imageArray)
               {
                  if(imageData.getString("name") == mappedImageName)
                  {
                     if(absoluteUrl)
                     {
                        result = Global.getAssetURL(imageData.getString("url"));
                     }
                     else
                     {
                        result = imageData.getString("url");
                     }
                  }
               }
            }
         }
         else
         {
            images = m_itemXML.image.(@name == mapImageName(imageName));
            if(images.length())
            {
               if(absoluteUrl)
               {
                  result = Global.getAssetURL(images[0].@url);
               }
               else
               {
                  result = images[0].@url;
               }
            }
         }
         return result;
      }
      
      public function get assetKey() : String
      {
         var assetKey:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            assetKey = m_dataSource.getString("assetKey");
            if(assetKey == "")
            {
               assetKey = null;
            }
         }
         else if(m_itemXML.hasOwnProperty("assetKey"))
         {
            assetKey = m_itemXML.assetKey;
         }
         return assetKey;
      }
      
      public function getCollisionData(index:int = 0) : Vector.<int>
      {
         var collisionDataLength:int = 0;
         var collisionDataArray:Array = null;
         var rowLength:int = 0;
         var rowDataArray:Array = null;
         var typeIdx:int = 0;
         var str:String = null;
         var rowIdx:int = 0;
         var chara:String = null;
         var charIdx:int = 0;
         if(this.m_collisionData == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               collisionDataArray = m_dataSource.getArray("collision");
               collisionDataLength = int(collisionDataArray.length);
            }
            else
            {
               collisionDataLength = m_itemXML.collision.length();
            }
            this.m_collisionData = new Vector.<Vector.<int>>(collisionDataLength);
            for(typeIdx = 0; typeIdx < collisionDataLength; typeIdx++)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  rowDataArray = collisionDataArray[typeIdx].getArray("r");
                  rowLength = int(rowDataArray.length);
               }
               else
               {
                  rowLength = m_itemXML.collision[typeIdx].r.length();
               }
               this.m_collisionData[typeIdx] = new Vector.<int>(rowLength * this.sizeX,false);
               for(rowIdx = 0; rowIdx < rowLength; rowIdx++)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     str = rowDataArray[rowIdx].toString();
                  }
                  else
                  {
                     str = m_itemXML.collision[typeIdx].r[rowIdx];
                  }
                  for(charIdx = 0; charIdx < str.length; charIdx++)
                  {
                     chara = str.charAt(charIdx);
                     this.m_collisionData[typeIdx][rowIdx * str.length + charIdx] = this.getCollisionFlagsFromChar(chara);
                  }
               }
            }
            if(this.m_collisionData.length == 0)
            {
               this.m_collisionData[0] = new Vector.<int>(0,true);
            }
         }
         return this.m_collisionData[index];
      }
      
      protected function getCollisionFlagsFromChar(char:String) : int
      {
         var result:int = 0;
         switch(char)
         {
            case "#":
               result = Constants.COLLISION_ALL;
               break;
            case "O":
               result = Constants.COLLISION_OVERLAP;
               break;
            case "H":
               result = Constants.COLLISION_ALL_EXCEPT_AVATAR;
               break;
            case ".":
            default:
               result = Constants.COLLISION_NONE;
         }
         return result;
      }
      
      public function getCollisionDataIndexByName(name:String) : int
      {
         var result:int = 0;
         var collisionDataLength:int = 0;
         var collisionDataArray:Array = null;
         var currentName:String = null;
         var typeIdx:int = 0;
         result = -1;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            collisionDataArray = m_dataSource.getArray("collision");
            collisionDataLength = int(collisionDataArray.length);
         }
         else
         {
            collisionDataLength = m_itemXML.collision.length();
         }
         for(typeIdx = 0; typeIdx < collisionDataLength; typeIdx++)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               currentName = collisionDataArray[typeIdx].getString("name");
            }
            else
            {
               currentName = m_itemXML.collision[typeIdx].@name;
            }
            if(currentName == name)
            {
               result = typeIdx;
               break;
            }
         }
         return result;
      }
      
      public function hasAltGraphic(name:String) : Boolean
      {
         var result:Boolean = false;
         var altGraphicDataArray:Array = null;
         var altGraphicData:BaseDataSource = null;
         var graphicName:String = null;
         result = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            altGraphicDataArray = m_dataSource.getArray("altGraphic");
            if(altGraphicDataArray.length > 0)
            {
               for each(altGraphicData in altGraphicDataArray)
               {
                  if(altGraphicData.toString() == name)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("altGraphic"))
         {
            for each(graphicName in m_itemXML.altGraphic)
            {
               if(graphicName == name)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getAltGraphics() : Array
      {
         var result:Array = null;
         var altGraphicDataArray:Array = null;
         var altGraphicData:BaseDataSource = null;
         var graphicName:String = null;
         result = [];
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            altGraphicDataArray = m_dataSource.getArray("altGraphic");
            if(altGraphicDataArray.length > 0)
            {
               for each(altGraphicData in altGraphicDataArray)
               {
                  result.push(altGraphicData.toString());
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("altGraphic"))
         {
            for each(graphicName in m_itemXML.altGraphic)
            {
               result.push(graphicName);
            }
         }
         return result;
      }
      
      public function get plantXp() : int
      {
         var plantXp:int = 0;
         plantXp = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            plantXp = m_dataSource.getInt("plantXp");
         }
         else if(m_itemXML.plantXp)
         {
            plantXp = int(m_itemXML.plantXp);
         }
         return plantXp;
      }
      
      public function get nectarGain() : int
      {
         var nectarUnit:int = 0;
         nectarUnit = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nectarUnit = m_dataSource.getInt("nectarUnit");
         }
         else if(m_itemXML.nectarUnit)
         {
            nectarUnit = int(m_itemXML.nectarUnit);
         }
         return nectarUnit;
      }
      
      public function get buyXp() : int
      {
         var costForXpCalculation:int = 0;
         var xp:Number = NaN;
         var realXp:Number = NaN;
         var costData:BaseDataSource = null;
         var costDataBuyXp:int = 0;
         var baseDataBuyXp:int = 0;
         var costXml:XML = null;
         costForXpCalculation = this.cost;
         xp = Math.floor(costForXpCalculation * Global.farmGameSettingsManager.getNumber("buyXpGainRatio"));
         realXp = Math.max(xp,Global.farmGameSettingsManager.getNumber("buyXpGainMin"));
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            costData = this.getActiveDS(name);
            costDataBuyXp = costData.getInt("buyXp");
            baseDataBuyXp = m_dataSource.getInt("buyXp");
            if(this.isTiered && costDataBuyXp >= 0)
            {
               realXp = costDataBuyXp;
            }
            else if(baseDataBuyXp >= 0)
            {
               realXp = baseDataBuyXp;
            }
         }
         else
         {
            costXml = this.getActiveXml(this.name);
            if(Boolean(this.isTiered) && Boolean(costXml.buyXp) && costXml.buyXp.toString() != "")
            {
               realXp = Number(costXml.buyXp);
            }
            else if(Boolean(this.xml.buyXp) && this.xml.buyXp.toString() != "")
            {
               realXp = Number(this.xml.buyXp);
            }
         }
         return realXp;
      }
      
      public function set buyWorldScore(worldScoreAmount:int) : void
      {
         this.m_buyWorldScore = worldScoreAmount;
      }
      
      public function get buyWorldScore() : int
      {
         return this.m_buyWorldScore;
      }
      
      public function set buyWorldScoreUnit(worldScoreUnit:String) : void
      {
         this.m_buyWorldScoreUnit = worldScoreUnit;
      }
      
      public function get buyWorldScoreUnit() : String
      {
         return this.m_buyWorldScoreUnit;
      }
      
      public function addUpgradeConfigWorldScoreBonus(upgradeLevel:int, unit:String, WorldScoreAmount:int) : void
      {
         if(this.m_upgradeWorldScoreReward == null)
         {
            this.m_upgradeWorldScoreReward = new Array();
         }
         this.m_upgradeWorldScoreReward[upgradeLevel] = {
            "unit":unit,
            "amount":WorldScoreAmount
         };
      }
      
      public function getUpgradeWorldScoreRewardObject(upgradeLevel:int) : Object
      {
         var result:Object = null;
         result = null;
         if(this.m_upgradeWorldScoreReward != null && this.m_upgradeWorldScoreReward.hasOwnProperty(String(upgradeLevel)))
         {
            result = this.m_upgradeWorldScoreReward[upgradeLevel];
         }
         return result;
      }
      
      public function getUpgradeWorldScoreRewardUnit(upgradeLevel:int) : String
      {
         var rewardObj:Object = null;
         var result:String = null;
         rewardObj = this.getUpgradeWorldScoreRewardObject(upgradeLevel);
         result = null;
         if(rewardObj != null)
         {
            result = rewardObj.unit;
         }
         return result;
      }
      
      public function getUpgradeWorldScoreRewardAmount(upgradeLevel:int) : String
      {
         var rewardObj:Object = null;
         var result:String = null;
         rewardObj = this.getUpgradeWorldScoreRewardObject(upgradeLevel);
         result = null;
         if(rewardObj != null)
         {
            result = rewardObj.amount;
         }
         return result;
      }
      
      public function get insanePercent() : Number
      {
         var percentInsane:Number = NaN;
         percentInsane = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            percentInsane = m_dataSource.getNumber("insanityProbability");
         }
         else if(m_itemXML.insanityProbability)
         {
            percentInsane = Number(m_itemXML.insanityProbability);
         }
         return percentInsane;
      }
      
      public function get jumpHeight() : Number
      {
         var height:Number = NaN;
         height = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            height = m_dataSource.getNumber("jumpHeight");
         }
         else if(m_itemXML.jumpHeight)
         {
            height = Number(m_itemXML.jumpHeight);
         }
         return height;
      }
      
      public function get wanderSpeed() : int
      {
         var speed:int = 0;
         speed = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            speed = m_dataSource.getInt("wanderSpeed");
         }
         else if(m_itemXML.wanderSpeed)
         {
            speed = int(m_itemXML.wanderSpeed);
         }
         return speed;
      }
      
      public function get allowAnimalTypeWander() : Boolean
      {
         var disallowWanderFlag:int = 0;
         var result:Boolean = false;
         disallowWanderFlag = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            disallowWanderFlag = m_dataSource.getInt("disallowWander");
         }
         else if(Boolean(m_itemXML) && Boolean(m_itemXML.disallowWander))
         {
            disallowWanderFlag = int(m_itemXML.disallowWander);
         }
         return disallowWanderFlag != 1;
      }
      
      public function get hasFoal() : Boolean
      {
         var result:Boolean = false;
         result = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("foal") != "";
         }
         else if(Boolean(m_itemXML) && Boolean(m_itemXML.foal))
         {
            result = true;
         }
         return result;
      }
      
      public function get foalItemName() : String
      {
         var foalName:String = null;
         foalName = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            foalName = m_dataSource.getString("foal");
            if(foalName == "")
            {
               foalName = null;
            }
         }
         else if(Boolean(m_itemXML) && Boolean(m_itemXML.foal))
         {
            foalName = m_itemXML.foal;
         }
         return foalName;
      }
      
      public function get canShareFoal() : Boolean
      {
         var result:Boolean = false;
         result = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = false;
         }
         else if(Boolean(m_itemXML) && Boolean(m_itemXML.foal) && m_itemXML.foal.hasOwnProperty("@share"))
         {
            result = m_itemXML.foal.@share.toString() == "true";
         }
         return result;
      }
      
      public function getItemPackageHash() : Object
      {
         var result:Object = null;
         var itemPackageDataArray:Array = null;
         var itemPackageData:BaseDataSource = null;
         var packageXml:XML = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemPackageDataArray = m_dataSource.getArray("itemPackage");
            if(itemPackageDataArray.length > 0)
            {
               result = {};
               for each(itemPackageData in itemPackageDataArray)
               {
                  result[itemPackageData.toString()] = itemPackageData.getInt("amount");
               }
            }
         }
         else if(Boolean(m_itemXML) && (m_itemXML.itemPackage as XMLList).length() > 0)
         {
            result = new Object();
            for each(packageXml in m_itemXML.itemPackage)
            {
               result[packageXml.toString()] = parseInt(packageXml.@amount);
            }
         }
         return result;
      }
      
      public function getItemPackageFenceHash() : Object
      {
         var result:Object = null;
         var itemPackageFenceData:BaseDataSource = null;
         var packageXml:XML = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemPackageFenceData = m_dataSource.getData("itemPackageFence");
            if(itemPackageFenceData)
            {
               result = new Object();
               result[itemPackageFenceData.getString("value")] = itemPackageFenceData.getInt("amount");
            }
         }
         else if(Boolean(m_itemXML) && (m_itemXML.itemPackageFence as XMLList).length() > 0)
         {
            result = new Object();
            for each(packageXml in m_itemXML.itemPackageFence)
            {
               result[packageXml.toString()] = parseInt(packageXml.@amount);
            }
         }
         return result;
      }
      
      public function getRewardsPackageHash() : Object
      {
         var result:Object = null;
         var itemPackageDataArray:Array = null;
         var itemPackageData:BaseDataSource = null;
         var packageXml:XML = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemPackageDataArray = m_dataSource.getArray("rewards","reward");
            if(itemPackageDataArray.length > 0)
            {
               result = {};
               for each(itemPackageData in itemPackageDataArray)
               {
                  if(!isNaN(itemPackageData.getInt("quantity")))
                  {
                     result[itemPackageData.getString("value")] = itemPackageData.getInt("quantity");
                  }
               }
            }
         }
         else if(Boolean(m_itemXML) && (m_itemXML.rewards.reward as XMLList).length() > 0)
         {
            result = new Object();
            for each(packageXml in m_itemXML.rewards.reward)
            {
               if(!isNaN(parseInt(packageXml.@quantity)))
               {
                  result[packageXml.@value] = parseInt(packageXml.@quantity);
               }
            }
         }
         return result;
      }
      
      public function getItemLandBundleObject() : Object
      {
         var result:Object = null;
         var landbundles:Array = null;
         var landbundle:BaseDataSource = null;
         var packageXml:XML = null;
         result = new Object();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            landbundles = m_dataSource.getArray("landbundles","landbundle");
            if(landbundles.length > 0)
            {
               for each(landbundle in landbundles)
               {
                  result[landbundle.getString("name")] = landbundle.getString("subtype");
               }
            }
         }
         else if(Boolean(m_itemXML) && (m_itemXML.landbundles as XMLList).length() > 0)
         {
            for each(packageXml in m_itemXML.landbundles.landbundle)
            {
               result[packageXml.@name.toString()] = packageXml.@subtype.toString();
            }
         }
         return result;
      }
      
      public function get hasContentTypes() : Boolean
      {
         var storageTypeItemName:String = null;
         var hasContentTypes:Boolean = false;
         storageTypeItemName = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            storageTypeItemName = m_dataSource.getString("storageType","itemName");
         }
         else if(Boolean(m_itemXML.storageType) && Boolean(m_itemXML.storageType.itemName))
         {
            storageTypeItemName = m_itemXML.storageType.itemName;
         }
         return this.storageClass != "" || storageTypeItemName != "";
      }
      
      public function get storageClass() : String
      {
         var result:String = null;
         result = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("storageType","itemClass");
         }
         else if(Boolean(m_itemXML.storageType) && m_itemXML.storageType.hasOwnProperty("@itemClass"))
         {
            result = m_itemXML.storageType.@itemClass;
         }
         return result;
      }
      
      public function get storageSize() : int
      {
         var storageSize:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            storageSize = m_dataSource.getInt("storageSize");
         }
         else
         {
            storageSize = int(m_itemXML.storageSize);
         }
         return storageSize;
      }
      
      public function get capacity() : int
      {
         var capacity:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            capacity = m_dataSource.getInt("capacity");
         }
         else
         {
            capacity = int(m_itemXML.capacity);
         }
         return capacity;
      }
      
      public function get crop() : String
      {
         var result:String = null;
         result = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("crop");
         }
         else if(Boolean(m_itemXML.crop) && String(m_itemXML.crop) != "")
         {
            result = String(m_itemXML.crop);
         }
         return result;
      }
      
      public function getFinishedName() : String
      {
         var finishedName:String = null;
         var experimentName:String = null;
         var expFinishedName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            finishedName = m_dataSource.getString("finishedName");
         }
         else
         {
            finishedName = String(m_itemXML.finishedName);
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_dataSource) && m_dataSource.hasProperty("experimentFinishedName"))
            {
               experimentName = m_dataSource.getString("experimentFinishedName","experiment");
               expFinishedName = m_dataSource.getString("experimentFinishedName","finishedName");
            }
         }
         else if(Boolean(m_itemXML) && m_itemXML.hasOwnProperty("experimentFinishedName"))
         {
            experimentName = String(m_itemXML.experimentFinishedName.@experiment);
            expFinishedName = String(m_itemXML.experimentFinishedName.@finishedName);
         }
         if(experimentName)
         {
            if(Global.experimentManager.getExperimentVariant(experimentName) > 0)
            {
               finishedName = expFinishedName;
            }
         }
         return finishedName;
      }
      
      public function getExpansion() : String
      {
         return this.expansion;
      }
      
      public function getCashName() : String
      {
         return this.cashName;
      }
      
      public function getExpansionIncomplete() : String
      {
         var expansionIncompleteFeed:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            expansionIncompleteFeed = m_dataSource.getString("expansion","incompleteFeed");
         }
         else
         {
            expansionIncompleteFeed = String(m_itemXML.expansion.@incompleteFeed);
         }
         return expansionIncompleteFeed;
      }
      
      public function getExpansionComplete() : String
      {
         var expansionCompleteFeed:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            expansionCompleteFeed = m_dataSource.getString("expansion","completeFeed");
         }
         else
         {
            expansionCompleteFeed = String(m_itemXML.completeFeed);
         }
         return expansionCompleteFeed;
      }
      
      public function get expansion() : String
      {
         var expansion:String = null;
         expansion = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            expansion = m_dataSource.getString("expansion");
         }
         else
         {
            expansion = String(m_itemXML.expansion);
         }
         return expansion;
      }
      
      public function get constructionUI() : String
      {
         var result:String = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("constructionUI"))
            {
               result = m_dataSource.getString("constructionUI");
            }
         }
         else if(m_itemXML.hasOwnProperty("constructionUI"))
         {
            result = m_itemXML["constructionUI"];
         }
         return result;
      }
      
      public function getUpgradeData(level:int) : XML
      {
         var xml:XML = null;
         var list:XMLList = null;
         xml = null;
         list = null;
         if(m_itemXML.hasOwnProperty("upgrade"))
         {
            list = m_itemXML.upgrade.(@level == level);
         }
         else if(m_itemXML.hasOwnProperty("features"))
         {
            list = m_itemXML.features.feature.(@name == "expand").upgrade.(@level == level);
         }
         if(list !== null && Boolean(list.length()))
         {
            xml = list[0];
         }
         else if(level > this.getMaxExplicitUpgradeData()["level"])
         {
            xml = this.getInfiniteUpgradeData(level);
         }
         return xml;
      }
      
      public function getUpgradeDataSource(level:int) : BaseDataSource
      {
         var dataSource:BaseDataSource = null;
         var upgradeDataArray:Array = null;
         var shouldCheckInfiniteUpgrade:Boolean = false;
         var expandFeatureData:BaseDataSource = null;
         var currentLevel:int = 0;
         var upgradeData:BaseDataSource = null;
         dataSource = null;
         upgradeDataArray = null;
         shouldCheckInfiniteUpgrade = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataArray = m_dataSource.getArray("upgrade");
            if(upgradeDataArray.length == 0)
            {
               expandFeatureData = this.getFeatureDataByName(FeatureManager.EXPAND_FEATURE_NAME);
               if(expandFeatureData)
               {
                  upgradeDataArray = expandFeatureData.getArray("upgrade");
               }
            }
            if(upgradeDataArray.length > 0)
            {
               for each(upgradeData in upgradeDataArray)
               {
                  currentLevel = upgradeData.getInt("level");
                  if(level == currentLevel)
                  {
                     dataSource = upgradeData;
                     shouldCheckInfiniteUpgrade = false;
                     break;
                  }
                  if(level < currentLevel)
                  {
                     shouldCheckInfiniteUpgrade = false;
                  }
               }
            }
            if(shouldCheckInfiniteUpgrade)
            {
               dataSource = this.getInfiniteUpgradeDataSource(level);
            }
         }
         return dataSource;
      }
      
      private function getInfiniteUpgradeData(level:int) : XML
      {
         var xml:XML = null;
         var maxExplicitUpgradeData:Dictionary = null;
         var maxExplicitLevel:int = 0;
         var maxExplicitCapacity:int = 0;
         var infiniteUpgradeData:XML = null;
         var flashVarName:String = null;
         var runTimeMaxLevel:int = 0;
         xml = null;
         if(m_itemXML.hasOwnProperty("features"))
         {
            maxExplicitUpgradeData = this.getMaxExplicitUpgradeData();
            maxExplicitLevel = int(maxExplicitUpgradeData["level"]);
            maxExplicitCapacity = int(maxExplicitUpgradeData["capacity"]);
            infiniteUpgradeData = m_itemXML.features.feature.(@name == "expand").infiniteUpgradeData[0];
            flashVarName = RT_SILO_MAX_LEVEL_UPGRADE_NAME;
            if(Boolean(infiniteUpgradeData) && Boolean(infiniteUpgradeData["@runtimeString"]) && GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") == 1)
            {
               flashVarName = infiniteUpgradeData.@runtimeString;
            }
            runTimeMaxLevel = parseInt(GlobalEngine.getFlashVar(flashVarName) as String);
            if(Boolean(infiniteUpgradeData && this.checkExperimentGate(infiniteUpgradeData) && level > maxExplicitLevel) && Boolean(runTimeMaxLevel) && runTimeMaxLevel >= level)
            {
               xml = new XML("<upgrade infinite=\"true\" level=\"" + level + "\" capacity=\"" + (maxExplicitCapacity + (level - maxExplicitLevel) * infiniteUpgradeData.@additionalCapacity) + "\" matsNeeded=\"" + infiniteUpgradeData.@matsNeeded + "\"></upgrade>");
               xml.setChildren(infiniteUpgradeData.children());
            }
         }
         return xml;
      }
      
      private function getInfiniteUpgradeDataSource(level:int) : BaseDataSource
      {
         var upgradeData:BaseDataSource = null;
         var expandFeatureData:BaseDataSource = null;
         var maxExplicitUpgradeInfo:Dictionary = null;
         var maxExplicitLevel:int = 0;
         var infiniteUpgradeData:BaseDataSource = null;
         var flashVarName:String = null;
         var runtimeString:String = null;
         var runtimeMaxLevel:int = 0;
         var maxExplicitCapacity:int = 0;
         var newCapacity:int = 0;
         var newMatsNeeded:int = 0;
         var upgrade:Object = null;
         var infiniteUpgradeDataObject:FeatureInfiniteUpgradeDataDO = null;
         var upgradeXml:XML = null;
         var infiniteUpgradeXML:XML = null;
         upgradeData = null;
         expandFeatureData = this.getFeatureDataByName(FeatureManager.EXPAND_FEATURE_NAME);
         if(expandFeatureData)
         {
            maxExplicitUpgradeInfo = this.getMaxExplicitUpgradeData();
            maxExplicitLevel = int(maxExplicitUpgradeInfo["level"]);
            if(level > maxExplicitLevel)
            {
               infiniteUpgradeData = expandFeatureData.getData("infiniteUpgradeData");
               if(Boolean(infiniteUpgradeData) && Boolean(this.checkExperimentGate(null,infiniteUpgradeData)))
               {
                  flashVarName = RT_SILO_MAX_LEVEL_UPGRADE_NAME;
                  runtimeString = infiniteUpgradeData.getString("runtimeString");
                  if(Boolean(runtimeString) && GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") == 1)
                  {
                     flashVarName = runtimeString;
                  }
                  runtimeMaxLevel = parseInt(GlobalEngine.getFlashVar(flashVarName) as String);
                  if(Boolean(runtimeMaxLevel) && runtimeMaxLevel >= level)
                  {
                     maxExplicitCapacity = int(maxExplicitUpgradeInfo["capacity"]);
                     newCapacity = maxExplicitCapacity + (level - maxExplicitLevel) * infiniteUpgradeData.getInt("additionalCapacity");
                     newMatsNeeded = infiniteUpgradeData.getInt("matsNeeded");
                     if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
                     {
                        upgrade = {
                           "infinite":true,
                           "level":level.toString(),
                           "capacity":newCapacity.toString(),
                           "matsNeeded":newMatsNeeded.toString()
                        };
                        upgrade.part = infiniteUpgradeData.getArray("part");
                        upgradeData = new OptItemDataSource(upgrade);
                     }
                     else if(FarmGameSettingsManager.isInItemsAMFExperiment())
                     {
                        infiniteUpgradeDataObject = new FeatureInfiniteUpgradeDataDO();
                        infiniteUpgradeDataObject.infinite = true;
                        infiniteUpgradeDataObject.level = level;
                        infiniteUpgradeDataObject.capacity = newCapacity;
                        infiniteUpgradeDataObject.matsNeeded = newMatsNeeded;
                        infiniteUpgradeDataObject.part = infiniteUpgradeData.getArray("part");
                        upgradeData = new DataObjectDataSource(infiniteUpgradeDataObject);
                     }
                     else
                     {
                        upgradeXml = new XML("<upgrade infinite=\"true\" level=\"" + level + "\" capacity=\"" + newCapacity + "\" matsNeeded=\"" + newMatsNeeded + "\"></upgrade>");
                        infiniteUpgradeXML = new XML(infiniteUpgradeData.toString());
                        upgradeXml.setChildren(infiniteUpgradeXML.children());
                        upgradeData = new XMLDataSource(upgradeXml);
                     }
                  }
               }
            }
         }
         return upgradeData;
      }
      
      public function getMaxExplicitUpgradeData() : Dictionary
      {
         var maxLevel:int = 0;
         var maxCapacity:int = 0;
         var upgradeXMLs:XMLList = null;
         var upgradeDataArray:Array = null;
         var values:Dictionary = null;
         var expandFeatureData:BaseDataSource = null;
         var upgradeLevel:int = 0;
         var upgradeData:BaseDataSource = null;
         var upgradeXML:XML = null;
         maxLevel = 0;
         maxCapacity = 0;
         upgradeXMLs = null;
         upgradeDataArray = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            maxCapacity = m_dataSource.getInt("capacity");
            upgradeDataArray = m_dataSource.getArray("upgrade");
            if(upgradeDataArray.length == 0)
            {
               expandFeatureData = this.getFeatureDataByName(FeatureManager.EXPAND_FEATURE_NAME);
               if(expandFeatureData)
               {
                  upgradeDataArray = expandFeatureData.getArray("upgrade");
               }
            }
            if(upgradeDataArray.length > 0)
            {
               for each(upgradeData in upgradeDataArray)
               {
                  upgradeLevel = upgradeData.getInt("level");
                  if(Boolean(this.checkExperimentGate(null,upgradeData)) && upgradeLevel > maxLevel)
                  {
                     maxLevel = upgradeLevel;
                     maxCapacity = upgradeData.getInt("capacity");
                  }
               }
            }
         }
         else
         {
            if(m_itemXML.hasOwnProperty("capacity"))
            {
               maxCapacity = int(m_itemXML.capacity);
            }
            if(m_itemXML.hasOwnProperty("upgrade"))
            {
               upgradeXMLs = m_itemXML.upgrade;
            }
            else if(m_itemXML.hasOwnProperty("features"))
            {
               upgradeXMLs = m_itemXML.features.feature.(@name == "expand").upgrade;
            }
            if(upgradeXMLs)
            {
               for each(upgradeXML in upgradeXMLs)
               {
                  if(Boolean(this.checkExperimentGate(upgradeXML)) && upgradeXML.@level > maxLevel)
                  {
                     maxLevel = int(upgradeXML.@level);
                     maxCapacity = int(upgradeXML.@capacity);
                  }
               }
            }
         }
         values = new Dictionary();
         values["level"] = maxLevel;
         values["capacity"] = maxCapacity;
         return values;
      }
      
      public function getMaxUpgradeData() : XML
      {
         return this.getUpgradeData(this.getMaxUpgradeLevel());
      }
      
      public function getMaxUpgradeDataSource() : BaseDataSource
      {
         var dataSource:BaseDataSource = null;
         return this.getUpgradeDataSource(this.getMaxUpgradeLevel());
      }
      
      public function getMaxUpgradeLevel() : int
      {
         var level:int = 0;
         var flashVarString:String = null;
         var upgradeDataArray:Array = null;
         var upgradeData:BaseDataSource = null;
         var currentLevel:int = 0;
         var expandFeatureData:BaseDataSource = null;
         var infiniteUpgradeData:BaseDataSource = null;
         var isUsingRuntimeMaxLevel:Boolean = false;
         var runtimeString:String = null;
         var runtimeMaxLevelFlashVar:Object = null;
         var runtimeMaxLevel:int = 0;
         var upgradeXML:XML = null;
         var expandXml:XMLList = null;
         var featuresUpgradeXML:XML = null;
         var runtimeMaxLevelVar:Object = null;
         var runTimeMaxLevel:int = 0;
         level = 1;
         flashVarString = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataArray = m_dataSource.getArray("upgrade");
            upgradeData = null;
            if(upgradeDataArray.length == 0)
            {
               expandFeatureData = this.getFeatureDataByName(FeatureManager.EXPAND_FEATURE_NAME);
               if(expandFeatureData)
               {
                  infiniteUpgradeData = expandFeatureData.getData("inifiniteUpgradeData");
                  isUsingRuntimeMaxLevel = false;
                  if(infiniteUpgradeData)
                  {
                     flashVarString = RT_SILO_MAX_LEVEL_UPGRADE_NAME;
                     runtimeString = infiniteUpgradeData.getString("runtimeString");
                     if(Boolean(runtimeString) && GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") == 1)
                     {
                        flashVarString = runtimeString;
                     }
                     runtimeMaxLevelFlashVar = GlobalEngine.getFlashVar(flashVarString);
                     if(runtimeMaxLevelFlashVar)
                     {
                        runtimeMaxLevel = parseInt(runtimeMaxLevelFlashVar.toString());
                        if(Boolean(runtimeMaxLevel) && Boolean(this.checkExperimentGate(null,infiniteUpgradeData)))
                        {
                           level = runtimeMaxLevel;
                           isUsingRuntimeMaxLevel = true;
                        }
                     }
                  }
                  if(!isUsingRuntimeMaxLevel)
                  {
                     upgradeDataArray = expandFeatureData.getArray("upgrade");
                  }
               }
            }
            if(upgradeDataArray.length > 0)
            {
               for each(upgradeData in upgradeDataArray)
               {
                  currentLevel = upgradeData.getInt("level");
                  if(currentLevel > level)
                  {
                     level = currentLevel;
                  }
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("upgrade"))
         {
            for each(upgradeXML in m_itemXML.upgrade)
            {
               if(upgradeXML.@level > level)
               {
                  level = int(upgradeXML.@level);
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("features"))
         {
            expandXml = m_itemXML.features.feature.(@name == "expand");
            for each(featuresUpgradeXML in expandXml.upgrade)
            {
               if(featuresUpgradeXML.@level > level)
               {
                  level = int(featuresUpgradeXML.@level);
               }
            }
            if(expandXml.hasOwnProperty("infiniteUpgradeData"))
            {
               flashVarString = RT_SILO_MAX_LEVEL_UPGRADE_NAME;
               if(GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") == 1 && Boolean(expandXml.infiniteUpgradeData.hasOwnProperty("@runtimeString")))
               {
                  flashVarString = expandXml.infiniteUpgradeData.@runtimeString;
               }
               runtimeMaxLevelVar = GlobalEngine.getFlashVar(flashVarString);
               if(runtimeMaxLevelVar)
               {
                  runTimeMaxLevel = parseInt(runtimeMaxLevelVar.toString());
                  if(Boolean(runTimeMaxLevel && this.checkExperimentGate(expandXml.infiniteUpgradeData[0])) && Boolean(runTimeMaxLevel) && runTimeMaxLevel > 0)
                  {
                     level = runTimeMaxLevel;
                  }
               }
            }
         }
         return level;
      }
      
      public function getFeaturesXML() : XMLList
      {
         var xml:XMLList = null;
         xml = null;
         if(m_itemXML.hasOwnProperty("features"))
         {
            xml = m_itemXML.features.feature;
         }
         return xml;
      }
      
      public function getFeaturesData() : Array
      {
         var featuresArray:Array = null;
         featuresArray = m_dataSource.getArray("features","feature");
         if(featuresArray.length == 0)
         {
            featuresArray = null;
         }
         return featuresArray;
      }
      
      public function getFeatureXMLByName(featureName:String) : XML
      {
         var xml:XML = null;
         var list:XMLList = null;
         xml = null;
         list = null;
         if(m_itemXML.hasOwnProperty("features"))
         {
            list = m_itemXML.features.feature.(@name == featureName);
         }
         if(Boolean(list) && Boolean(list.length()))
         {
            xml = list[0];
         }
         return xml;
      }
      
      public function getFeatureDataByName(featureName:String) : BaseDataSource
      {
         var dataSource:BaseDataSource = null;
         var featuresArray:Array = null;
         var featureData:BaseDataSource = null;
         dataSource = null;
         featuresArray = m_dataSource.getArray("features","feature");
         for each(featureData in featuresArray)
         {
            if(featureData.getString("name") == featureName)
            {
               dataSource = featureData;
               break;
            }
         }
         return dataSource;
      }
      
      public function getNumberOfParts() : int
      {
         var numParts:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            numParts = m_dataSource.getInt("numParts");
         }
         else
         {
            numParts = int(m_itemXML.numParts);
         }
         return numParts;
      }
      
      public function getPartSize(partNumber:int) : Vector3
      {
         var partSize:Vector3 = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            partSize = new Vector3(Number(m_dataSource.getString("partSizes","x").split(" ")[partNumber]),Number(m_dataSource.getString("partSizes","y").split(" ")[partNumber]),Number(m_dataSource.getString("partSizes","z").split(" ")[partNumber]));
         }
         else
         {
            partSize = new Vector3(Number(m_itemXML.partSizes.x.split(" ")[partNumber]),Number(m_itemXML.partSizes.y.split(" ")[partNumber]),Number(m_itemXML.partSizes.z.split(" ")[partNumber]));
         }
         return partSize;
      }
      
      public function getPartDisplacement(partNumber:int) : Vector3
      {
         var partDisplacement:Vector3 = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            partDisplacement = new Vector3(Number(m_dataSource.getString("partDisplacements","x").split(" ")[partNumber]),Number(m_dataSource.getString("partDisplacements","y").split(" ")[partNumber]),Number(m_dataSource.getString("partDisplacements","z").split(" ")[partNumber]));
         }
         else
         {
            partDisplacement = new Vector3(Number(m_itemXML.partDisplacements.x.split(" ")[partNumber]),Number(m_itemXML.partDisplacements.y.split(" ")[partNumber]),Number(m_itemXML.partDisplacements.z.split(" ")[partNumber]));
         }
         return partDisplacement;
      }
      
      public function get imageScale() : Number
      {
         return getImageData().imageScale;
      }
      
      public function incrementInstanceCount() : void
      {
         this.displayLoader.incrementInstanceCount();
      }
      
      public function decrementInstanceCount() : void
      {
         this.displayLoader.decrementInstanceCount();
      }
      
      public function getInstanceCount() : int
      {
         return this.displayLoader.getInstanceCount();
      }
      
      public function addImageToCache(image:Object) : void
      {
         this.displayLoader.addImageToCache(image);
      }
      
      public function getCachedImage(name:String, disallowAltAnimation:Boolean = false) : ItemImage
      {
         return this.displayLoader.getImageByName(mapImageName(name),disallowAltAnimation,this.m_aoeImageState);
      }
      
      public function get action() : String
      {
         var action:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            action = m_dataSource.getString("action");
         }
         else if(m_itemXML.action)
         {
            action = m_itemXML.action;
         }
         return action;
      }
      
      public function get transform() : String
      {
         var transform:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            transform = m_dataSource.getString("transform");
         }
         else if(m_itemXML.action)
         {
            transform = m_itemXML.transform;
         }
         return transform;
      }
      
      public function get sortPriority() : int
      {
         var rank:int = 0;
         rank = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            rank = m_dataSource.getInt("sortPriority");
         }
         else if(m_itemXML["@sortPriority"])
         {
            rank = Number(m_itemXML["@sortPriority"]);
         }
         return rank;
      }
      
      public function get actionText() : String
      {
         var actionText:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            actionText = m_dataSource.getString("actionText");
         }
         else if(m_itemXML.hasOwnProperty("actionText"))
         {
            actionText = m_itemXML.actionText;
         }
         return actionText;
      }
      
      public function get harvestType() : String
      {
         var harvestType:String = null;
         var harvestData:BaseDataSource = null;
         var harvestDataType:String = null;
         var harvestXML:XML = null;
         harvestType = "coins";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            harvestData = this.getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
            if(harvestData)
            {
               harvestDataType = harvestData.getString("harvestType");
               if(harvestDataType)
               {
                  harvestType = harvestDataType;
               }
            }
         }
         else
         {
            harvestXML = this.getFeatureXMLByName("harvester");
            if(Boolean(harvestXML) && harvestXML.hasOwnProperty("harvestType"))
            {
               harvestType = harvestXML.harvestType;
            }
         }
         return harvestType;
      }
      
      public function getDisplayHorizontalOffset() : Number
      {
         var result:Number = NaN;
         result = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getNumber("imageHorizontalOffset");
         }
         else if(Boolean(this.xml) && this.xml.hasOwnProperty("imageHorizontalOffset"))
         {
            result = Number(this.xml.imageHorizontalOffset);
         }
         return result;
      }
      
      public function getDisplayVerticalOffset() : Number
      {
         var result:Number = NaN;
         result = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getNumber("imageVerticalOffset");
         }
         else if(Boolean(this.xml) && this.xml.hasOwnProperty("imageVerticalOffset"))
         {
            result = Number(this.xml.imageVerticalOffset);
         }
         return result;
      }
      
      public function getHighlightColor() : int
      {
         var result:Number = NaN;
         var strResult:String = null;
         result = MapResource.INVALID_HIGHLIGHT_COLOR;
         strResult = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            strResult = m_dataSource.getString("highlightColor");
         }
         else if(Boolean(this.xml) && this.xml.hasOwnProperty("highlightColor"))
         {
            strResult = this.xml.highlightColor;
         }
         if(strResult != "" && strResult.length == 8 && strResult.substr(0,2) == "0x")
         {
            result = int(strResult);
         }
         return result;
      }
      
      public function get icon() : String
      {
         return iconUrl;
      }
      
      public function get newsfeed() : String
      {
         if(this.m_newsfeedUrl == null)
         {
            this.m_newsfeedUrl = this.getImageByName("newsfeed");
            if(this.m_newsfeedUrl == null)
            {
               this.m_newsfeedUrl = this.icon;
            }
         }
         return this.m_newsfeedUrl;
      }
      
      public function get count() : Number
      {
         var count:Number = NaN;
         var dataCount:Number = NaN;
         count = 1;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dataCount = m_dataSource.getNumber("count");
            if(dataCount > 0)
            {
               count = dataCount;
            }
         }
         else if(m_itemXML.count)
         {
            count = Number(m_itemXML.count);
         }
         return count;
      }
      
      public function get allowDelete() : Boolean
      {
         var res:Boolean = false;
         res = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getInt("disallowDelete") != 1;
         }
         else if(m_itemXML)
         {
            res = m_itemXML.disallowDelete != 1;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEV_GAMEBOARD_SETUP) > 0)
         {
            res = true;
         }
         return res;
      }
      
      public function get allowMove() : Boolean
      {
         var res:Boolean = false;
         res = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getInt("disallowMove") != 1;
         }
         else if(m_itemXML)
         {
            res = m_itemXML.disallowMove != 1;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEV_GAMEBOARD_SETUP) > 0)
         {
            res = true;
         }
         return res;
      }
      
      public function get allowStore() : Boolean
      {
         var res:Boolean = false;
         res = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getInt("disallowStore") != 1;
         }
         else if(m_itemXML)
         {
            res = m_itemXML.disallowStore != 1;
         }
         return res;
      }
      
      public function get rare() : Boolean
      {
         var res:Boolean = false;
         res = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getBoolean("rareItem");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@rareItem.toString() == "true")
         {
            res = true;
         }
         return res;
      }
      
      public function get customizable() : Boolean
      {
         var res:Boolean = false;
         res = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = m_dataSource.getBoolean("customizable");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@customizable.toString() == "true")
         {
            res = true;
         }
         return res;
      }
      
      public function get sellable() : Boolean
      {
         var res:Boolean = false;
         res = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = !m_dataSource.hasProperty("sellable") || m_dataSource.getBoolean("sellable");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@sellable.toString() == "false")
         {
            res = false;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEV_GAMEBOARD_SETUP) > 0)
         {
            res = true;
         }
         return res;
      }
      
      public function get canSellFromGiftBox() : Boolean
      {
         var canSellFromGiftBox:Boolean = false;
         canSellFromGiftBox = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            canSellFromGiftBox = !m_dataSource.hasProperty("canSellFromGiftBox") || m_dataSource.getBoolean("canSellFromGiftBox");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@canSellFromGiftBox.toString() == "false")
         {
            canSellFromGiftBox = false;
         }
         return canSellFromGiftBox;
      }
      
      public function get deletable() : Boolean
      {
         var res:Boolean = false;
         res = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            res = !m_dataSource.hasProperty("deletable") || m_dataSource.getBoolean("deletable");
         }
         else if(Boolean(m_itemXML) && m_itemXML.@deletable.toString() == "false")
         {
            res = false;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEV_GAMEBOARD_SETUP) > 0)
         {
            res = true;
         }
         return res;
      }
      
      public function get isCash() : Boolean
      {
         var res:Boolean = false;
         res = false;
         if(this.market == Currency.CASH)
         {
            res = true;
         }
         return res;
      }
      
      public function getLimitedIcon(defaultFileExt:String = ".png") : String
      {
         var limitedIconUrl:String = null;
         var limitedIconBasename:String = null;
         limitedIconUrl = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            limitedIconBasename = m_dataSource.getString("limitedIcon");
         }
         else if(m_itemXML.hasOwnProperty("limitedIcon"))
         {
            limitedIconBasename = m_itemXML.limitedIcon;
         }
         if(limitedIconBasename)
         {
            limitedIconUrl = Global.getAssetURL("assets/LE_icons/" + limitedIconBasename + defaultFileExt);
         }
         return limitedIconUrl;
      }
      
      public function getNextLevelItem() : FarmItem
      {
         var result:FarmItem = null;
         var nextItemCode:String = null;
         var nextLevelItem:FarmItem = null;
         result = this;
         nextItemCode = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextItemCode = m_dataSource.getString("nextLevel");
         }
         else if(m_itemXML.nextLevel)
         {
            nextItemCode = m_itemXML.nextLevel;
         }
         if(nextItemCode != "")
         {
            nextLevelItem = Global.farmGameSettingsManager.getFarmItemByCode(nextItemCode);
            if(nextLevelItem)
            {
               result = nextLevelItem;
            }
         }
         return result;
      }
      
      public function buyableWithCurrency() : Boolean
      {
         var isBuyableWithCurrency:Boolean = false;
         var passesDateGate:Boolean = false;
         passesDateGate = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            passesDateGate = this.checkDateGateData(m_dataSource);
         }
         else if(m_itemXML)
         {
            passesDateGate = this.checkDateGateXML(m_itemXML);
         }
         return (passesDateGate || this.isLicenseValid) && (this.marketIsCoin || this.marketIsLoyaltyPoints || this.marketIsBerry || this.buyableWithWorldCurrency() || this.marketIsNectar);
      }
      
      public function buyableWithWorldCurrency() : Boolean
      {
         var result:Boolean = false;
         var expansionData:ExpansionData = null;
         result = false;
         if(this.marketIsWorldCurrency)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(Global.worldManager.currentWorldType);
            if(Boolean(expansionData) && Boolean(expansionData.currency))
            {
               result = this.market == expansionData.currency;
            }
            else
            {
               result = false;
            }
         }
         return result;
      }
      
      public function buyableWithCash() : Boolean
      {
         var hasMarketCash:Boolean = false;
         var hasCurrencyAndCash:Boolean = false;
         var result:Boolean = false;
         hasMarketCash = this.market == Currency.CASH || this.cashXMLMarket == Currency.CASH;
         hasCurrencyAndCash = Boolean(this.market) && this.cash > 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = Boolean(this.m_cashData) && (hasMarketCash || hasCurrencyAndCash) && this.checkDateGateData(this.m_cashData);
         }
         else
         {
            result = Boolean(this.m_cashXML) && (hasMarketCash || hasCurrencyAndCash) && this.checkDateGateXML(this.m_cashXML);
         }
         return result;
      }
      
      public function get marketIsCoin() : Boolean
      {
         var marketType:String = null;
         marketType = this.market;
         return marketType == Currency.COINS || marketType == Currency.GOLD || marketType == Currency.BOTH || (marketType == null || marketType == "");
      }
      
      public function get marketIsLoyaltyPoints() : Boolean
      {
         var marketType:String = null;
         marketType = this.market;
         return marketType == Currency.COST_STATUS_POINTS && LoyaltyProgramManager.getInstance().userPassesPrereq();
      }
      
      public function get marketIsBerry() : Boolean
      {
         var marketType:String = null;
         marketType = this.market;
         return marketType == Currency.BERRY;
      }
      
      public function get marketIsNectar() : Boolean
      {
         var marketType:String = null;
         marketType = this.market;
         return marketType == Currency.NECTAR;
      }
      
      public function get marketIsWorldCurrency() : Boolean
      {
         var marketType:String = null;
         marketType = this.market;
         return marketType && marketType != Currency.COINS && marketType != Currency.GOLD && marketType != Currency.CASH && marketType != Currency.BOTH && marketType != Currency.BERRY;
      }
      
      public function get hasSale() : Boolean
      {
         var managedSale:ManagedSale = null;
         var passesDateGate:Boolean = false;
         var isManagedSaleActive:Boolean = false;
         var isFlashSaleActiveForItem:Boolean = false;
         var isWorldSpecificSaleActiveForItem:Boolean = false;
         var isCategorySpecificSaleActiveForItem:Boolean = false;
         var hasSale:Boolean = false;
         managedSale = ManagedSalesManager.getSaleObject(this);
         isManagedSaleActive = Boolean(managedSale) && managedSale.isActive();
         isFlashSaleActiveForItem = MarketFlashSaleManager.instance.isSaleActiveForItem(this);
         isWorldSpecificSaleActiveForItem = Global.worldSpecificSalesManager.isActive() && Global.worldSpecificSalesManager.inSale(this);
         isCategorySpecificSaleActiveForItem = Global.categorySpecificSalesManager.isActive() && Global.categorySpecificSalesManager.inSale(this);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            passesDateGate = Boolean(this.m_saleData) && this.checkDateGateData(this.m_saleData);
         }
         else
         {
            passesDateGate = Boolean(this.m_saleXML) && this.checkDateGateXML(this.m_saleXML);
         }
         return this.isVipItem() || passesDateGate || isManagedSaleActive || this.isDealOfDaySaleItem || isFlashSaleActiveForItem || isWorldSpecificSaleActiveForItem || isCategorySpecificSaleActiveForItem;
      }
      
      override public function flush() : void
      {
         super.flush();
         this.m_saleCost = INVALID_VALUE;
         this.m_saleCoins = INVALID_VALUE;
         this.m_saleCash = INVALID_VALUE;
         this.m_unlock = null;
         this.m_market = null;
         this.m_experiment = null;
         this.m_experimentVariant = INVALID_VALUE;
         this.m_experimentActive = -1;
         this.m_priceTest = null;
         this.m_gateCode = null;
         this.m_promoMode = null;
         this.m_licenseCode = null;
         this.m_itemLicense = null;
         this.m_minNeighbors = INVALID_VALUE;
         this.m_isPresent = -1;
         this.m_isSpecialValentinesItem = -1;
         this.m_isGameToken = -1;
         this.m_buyable = -1;
         this.m_giftable = -1;
         this.m_consumable = INVALID_VALUE;
         this.m_isTiered = -1;
         this.m_placeable = -1;
         this.m_preview = -1;
         this.m_creationTimestamp = -1;
      }
      
      public function set patchTime(newTime:Number) : void
      {
      }
      
      public function get patchTime() : Number
      {
         return 0;
      }
      
      public function isBuildingPart() : Boolean
      {
         return this.className == "BuildingPart" || this.className == "DoghouseTreat" || this.className == "WateringCan" || this.className == "CVehiclePart";
      }
      
      public function get friendSetGoal() : FriendSetGoal
      {
         var friendSetCode:String = null;
         if(this.m_friendSetGoal == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               friendSetCode = m_dataSource.getString("featureFriendSet","code");
            }
            else if(this.m_itemXML.hasOwnProperty("featureFriendSet"))
            {
               friendSetCode = this.m_itemXML.featureFriendSet.@code;
            }
            if(friendSetCode)
            {
               this.m_friendSetGoal = Global.farmGameSettingsManager.getFriendSetGoalByCode(friendSetCode);
            }
         }
         return this.m_friendSetGoal;
      }
      
      public function get basket() : String
      {
         if(this.m_basket == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_basket = m_dataSource.getString("basket");
            }
            else
            {
               this.m_basket = this.xml.basket;
            }
         }
         return this.m_basket;
      }
      
      public function get basketClass() : String
      {
         if(this.m_basketClass == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_basketClass = m_dataSource.getString("basketClass");
            }
            else
            {
               this.m_basketClass = this.xml.basketClass;
            }
         }
         return this.m_basketClass;
      }
      
      public function get max() : int
      {
         if(this.m_max == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_max = m_dataSource.getInt("max");
            }
            else
            {
               this.m_max = int(this.xml.max);
            }
         }
         return this.m_max;
      }
      
      public function get subcreditsType() : String
      {
         if(this.m_subcreditsType == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_subcreditsType = m_dataSource.getString("subcreditsType");
            }
            else
            {
               this.m_subcreditsType = this.xml.subcreditsType;
            }
         }
         return this.m_subcreditsType;
      }
      
      public function get sounds() : Array
      {
         var soundsDataArray:Array = null;
         var soundData:BaseDataSource = null;
         var soundList:XMLList = null;
         var sound:XML = null;
         if(this.m_sounds == null)
         {
            this.m_sounds = [];
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               soundsDataArray = m_dataSource.getArray("sounds","sound");
               if(soundsDataArray.length > 0)
               {
                  for each(soundData in soundsDataArray)
                  {
                     this.m_sounds.push(soundData.getString("url"));
                  }
               }
            }
            else
            {
               soundList = m_itemXML.sounds.sound;
               if(soundList.length() > 0)
               {
                  for each(sound in soundList)
                  {
                     this.m_sounds.push(sound.@url);
                  }
               }
            }
         }
         return this.m_sounds;
      }
      
      public function get statsCounter() : String
      {
         if(this.m_statsCounter == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_statsCounter = m_dataSource.getString("statsCounter");
            }
            else
            {
               this.m_statsCounter = m_itemXML.statsCounter;
            }
         }
         return this.m_statsCounter;
      }
      
      public function get ugcTransforms() : Object
      {
         var ugcTransformsDataArray:Array = null;
         var ugcTransformData:BaseDataSource = null;
         var ugcXML:XMLList = null;
         var ugc:XML = null;
         var transformName:String = null;
         var attr:XML = null;
         var attrName:String = null;
         if(null == this.m_ugcTransforms)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               ugcTransformsDataArray = m_dataSource.getArray("ugcTransforms","ugcTransform");
               if(ugcTransformsDataArray.length > 0)
               {
                  this.m_ugcTransforms = {};
                  for each(ugcTransformData in ugcTransformsDataArray)
                  {
                     this.m_ugcTransforms[ugcTransformData.getString("name")] = ugcTransformData.getAttributesHash();
                  }
               }
            }
            else if(m_itemXML.hasOwnProperty("ugcTransforms"))
            {
               ugcXML = m_itemXML.ugcTransforms;
               if(null != ugcXML)
               {
                  this.m_ugcTransforms = {};
                  for each(ugc in ugcXML.ugcTransform)
                  {
                     transformName = String(ugc.@name);
                     this.m_ugcTransforms[transformName] = {};
                     for each(attr in ugc.attributes())
                     {
                        attrName = String(attr.name());
                        this.m_ugcTransforms[transformName][attrName] = attr.toString();
                     }
                  }
               }
            }
         }
         return this.m_ugcTransforms;
      }
      
      public function get dialogName() : String
      {
         var dialogName:String = null;
         dialogName = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dialogName = m_dataSource.getString("dialogName");
         }
         else if(m_itemXML.@dialogName)
         {
            dialogName = m_itemXML.@dialogName;
         }
         return dialogName;
      }
      
      public function get dialogClass() : String
      {
         var dialogClass:String = null;
         dialogClass = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            dialogClass = m_dataSource.getString("dialogClass");
         }
         else if(m_itemXML.@dialogClass)
         {
            dialogClass = m_itemXML.@dialogClass;
         }
         return dialogClass;
      }
      
      public function get friendlyTitle() : String
      {
         if(this.m_friendlyTitle == "")
         {
            this.m_friendlyTitle = ZLocUtils.tk_pk_asTitle(friendlyName);
         }
         return this.m_friendlyTitle;
      }
      
      public function get friendlyTitlePlural() : String
      {
         if(this.m_friendlyTitlePlural == "")
         {
            this.m_friendlyTitlePlural = ZLocUtils.tk_pk_asTitlePlural(friendlyName);
         }
         return this.m_friendlyTitlePlural;
      }
      
      public function get searchTitle() : String
      {
         if(this.m_searchTitle == "")
         {
            this.m_searchTitle = this.friendlyTitle.toLowerCase();
         }
         return this.m_searchTitle;
      }
      
      public function getInstanceName(metadata:Object = null) : String
      {
         return this.friendlyTitle;
      }
      
      public function getUsageDescription() : String
      {
         var result:String = null;
         var possibleKeyName:String = null;
         var packageName:String = null;
         var itemPackageDataArray:Array = null;
         var itemPackageData:BaseDataSource = null;
         result = null;
         if(this.type == FarmItemType.BLOSSOM)
         {
            if(this.subType == BlossomConstants.SINGLE_BLOSSOM_SUBTYPE)
            {
               result = ZLocUtils.t("Dialogs","flower_shack_blossom_market_desp_txt");
            }
            else if(this.subType == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
            {
               result = ZLocUtils.t("Dialogs","flower_shack_boquet_market_desp_tx");
            }
         }
         else if(this.isMysteryItem)
         {
            possibleKeyName = this.name + "_WhatIsThisStore";
            if(ZLocUtils.hasString("Items",possibleKeyName))
            {
               result = ZLocUtils.t("Items",possibleKeyName);
            }
            else
            {
               result = ZLocUtils.t("Dialogs","MysteryBoxGameWhatIsThisStore");
            }
         }
         else if(ZLocUtils.hasString("Dialogs",name + "Message"))
         {
            result = ZLocUtils.t("Dialogs",name + "Message");
         }
         else if(ZLocUtils.hasString("Dialogs",this.subType + "Message"))
         {
            result = ZLocUtils.t("Dialogs",this.subType + "Message");
         }
         else
         {
            packageName = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               itemPackageDataArray = m_dataSource.getArray("itemPackage");
               for each(itemPackageData in itemPackageDataArray)
               {
                  packageName = itemPackageData.toString();
                  if(packageName != "" && ZLocUtils.hasString("Dialogs",packageName + "Message"))
                  {
                     result = ZLocUtils.t("Dialogs",packageName + "Message");
                     break;
                  }
               }
            }
            else
            {
               packageName = m_itemXML.itemPackage.toString();
               if(packageName != "" && ZLocUtils.hasString("Dialogs",packageName + "Message"))
               {
                  result = ZLocUtils.t("Dialogs",packageName + "Message");
               }
            }
         }
         return result;
      }
      
      public function get rewardsXML() : XML
      {
         var result:XML = null;
         var rewardsList:XMLList = null;
         result = null;
         rewardsList = this.xml.rewards;
         if(rewardsList.length() > 0)
         {
            result = rewardsList[0];
         }
         return result;
      }
      
      public function get rewardsData() : BaseDataSource
      {
         var dataSource:BaseDataSource = null;
         try
         {
            dataSource = m_dataSource.getData("rewards");
         }
         catch(err:TypeError)
         {
            dataSource = m_dataSource.getData("rewards")[0];
         }
         return dataSource;
      }
      
      public function checkMarketPrereqs() : Boolean
      {
         return this.checkPrereqs("marketPrereqs",{"currency":Global.worldManager.currentWorldCurrency});
      }
      
      public function checkLimitPrereqs() : Boolean
      {
         return this.checkPrereqs("limitPrereq",null);
      }
      
      public function checkLimitType() : Boolean
      {
         var result:Boolean = false;
         var world:FarmGameWorld = null;
         var buildingItem:BuildingItem = null;
         result = false;
         world = Global.world;
         switch(limitType)
         {
            case CODE_LIMIT_TYPE:
               result = world.getObjectsByCode(code).length >= limit;
               break;
            case BUILDING_NAME_LIMIT_TYPE:
               buildingItem = this as BuildingItem;
               if(buildingItem)
               {
                  result = world.isOverBuildingNameTypeLimit(buildingItem.buildingName,limit);
               }
               break;
            case NAME_LIMIT_TYPE:
            default:
               result = world.getObjectsByName(name).length >= limit;
         }
         return result;
      }
      
      public function checkPurchasePrereqs(context:Object = null) : Boolean
      {
         return this.checkPrereqs("purchasePrereqs",context);
      }
      
      private function checkPrereqs(prereqName:String, context:Object = null) : Boolean
      {
         var result:Boolean = false;
         var prereqString:String = null;
         var prereqs:Array = null;
         var prereq:String = null;
         var newPrereq:Object = null;
         result = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            prereqString = this.getDataProperty(m_dataSource,prereqName);
         }
         else if(m_itemXML.hasOwnProperty(prereqName))
         {
            prereqString = this.getXMLProperty(m_itemXML,prereqName);
         }
         if(prereqString)
         {
            prereqs = prereqString.split(",");
            for each(prereq in prereqs)
            {
               newPrereq = Global.farmGameSettingsManager.getPrereqByName(prereq);
               if(!newPrereq)
               {
                  result = false;
                  break;
               }
               result = PrerequisiteUtility.isPrerequisiteMet(newPrereq,context);
               if(result == false)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public function diagnoseFailedPurchasePrereqs(context:Object = null) : Object
      {
         return this.diagnoseFailedPrereqs("purchasePrereqs",context);
      }
      
      private function diagnoseFailedPrereqs(prereqName:String, context:Object = null) : Object
      {
         var result:Object = null;
         var prereqString:String = null;
         var prereqs:Array = null;
         var prereq:String = null;
         var newPrereq:Object = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            prereqString = this.getDataProperty(m_dataSource,prereqName);
         }
         else if(m_itemXML.hasOwnProperty(prereqName))
         {
            prereqString = this.getXMLProperty(m_itemXML,prereqName);
         }
         if(prereqString)
         {
            prereqs = prereqString.split(",");
            for each(prereq in prereqs)
            {
               newPrereq = Global.farmGameSettingsManager.getPrereqByName(prereq);
               if(!newPrereq)
               {
                  result = null;
                  break;
               }
               result = PrerequisiteUtility.diagnoseFailedPrerequisite(newPrereq,context);
               if(result != null)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public function isFlashGiftableViaRequest() : Boolean
      {
         var result:Boolean = false;
         var giftPermission:String = null;
         result = false;
         giftPermission = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            giftPermission = m_dataSource.getString("giftSendPermission");
         }
         else if(m_itemXML.hasOwnProperty("@giftSendPermission"))
         {
            giftPermission = m_itemXML.@giftSendPermission.toString();
         }
         if(giftPermission == "flashgift")
         {
            result = true;
         }
         return result;
      }
      
      public function get donations() : Array
      {
         var donationDataArray:Array = null;
         var donationObject:Object = null;
         var donationData:BaseDataSource = null;
         var donationObj:Object = null;
         var donateIdx:int = 0;
         if(this.m_donations == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               donationDataArray = m_dataSource.getArray("donation");
               if(donationDataArray.length > 0)
               {
                  this.m_donations = new Array();
                  for each(donationData in donationDataArray)
                  {
                     donationObject = {};
                     donationObject.licenseCode = donationData.getString("name");
                     donationObject.donationValue = donationData.getNumber("value");
                     donationObject.defaultButton = donationData.getBoolean("defaultButton");
                     this.m_donations.push(donationObject);
                  }
               }
            }
            else if(this.xml.hasOwnProperty("donation"))
            {
               this.m_donations = new Array();
               donationObj = {};
               for(donateIdx = 0; donateIdx < this.xml.donation.length(); donateIdx++)
               {
                  donationObj = {};
                  donationObj.licenseCode = String(this.xml.donation[donateIdx].@name);
                  donationObj.donationValue = Number(this.xml.donation[donateIdx].@value);
                  donationObj.defaultButton = Boolean(this.xml.donation[donateIdx].@defaultButton) && this.xml.donation[donateIdx].@defaultButton.toString() == "true" ? true : false;
                  this.m_donations.push(donationObj);
               }
            }
         }
         return this.m_donations;
      }
      
      public function get donatable() : Boolean
      {
         return this.donations != null;
      }
      
      public function get donationCurrency() : String
      {
         if(this.m_donationCurrency == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_donationCurrency = this.getDataProperty(m_dataSource,PROP_DONATION_CURRENCY);
            }
            else if(this.xml.hasOwnProperty(PROP_DONATION_CURRENCY))
            {
               this.m_donationCurrency = this.getXMLProperty(this.xml,PROP_DONATION_CURRENCY);
            }
            if(this.m_donationCurrency == null)
            {
               this.m_donationCurrency = DONATION_CURRENCY_DEFAULT;
            }
            else
            {
               this.m_donationCurrency = this.m_donationCurrency.toUpperCase();
            }
         }
         return this.m_donationCurrency;
      }
      
      public function set toolGeneratedFile(filename:String) : void
      {
         this.m_toolGeneratedAssetFile = filename;
      }
      
      public function get toolGeneratedFile() : String
      {
         return this.m_toolGeneratedAssetFile;
      }
      
      public function get marketEntries() : Object
      {
         var marketEntriesDataArray:Array = null;
         var index:int = 0;
         var marketEntryData:BaseDataSource = null;
         var indexString:String = null;
         var marketEntryType:String = null;
         var marketEntrySubtype:String = null;
         var marketEntrySubsubtype:String = null;
         var marketEntries:XMLList = null;
         var i:int = 0;
         var marketEntry:XML = null;
         var stringI:String = null;
         var type:String = null;
         var subtype:String = null;
         var subsubtype:String = null;
         if(!this.m_hasCheckedMarketEntries)
         {
            this.m_hasCheckedMarketEntries = true;
            this.m_marketEntries = {};
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               marketEntriesDataArray = m_dataSource.getArray("marketEntries","marketEntry");
               if(marketEntriesDataArray.length > 0)
               {
                  index = 0;
                  for each(marketEntryData in marketEntriesDataArray)
                  {
                     indexString = index.toString();
                     this.m_marketEntries[indexString] = {};
                     marketEntryType = marketEntryData.getString("type");
                     marketEntrySubtype = marketEntryData.getString("subtype");
                     marketEntrySubsubtype = marketEntryData.getString("subsubtype");
                     if(marketEntryType)
                     {
                        this.marketEntries[indexString]["type"] = marketEntryType;
                     }
                     if(marketEntrySubtype)
                     {
                        this.marketEntries[indexString]["subtype"] = marketEntrySubtype;
                     }
                     if(marketEntrySubsubtype)
                     {
                        this.marketEntries[indexString]["subsubtype"] = marketEntrySubsubtype;
                     }
                     index++;
                  }
               }
            }
            else if(m_itemXML.hasOwnProperty("marketEntries"))
            {
               marketEntries = m_itemXML.marketEntries.marketEntry;
               i = 0;
               for each(marketEntry in marketEntries)
               {
                  stringI = i.toString();
                  this.m_marketEntries[stringI] = {};
                  type = marketEntry.@type.toString();
                  if(type != "")
                  {
                     this.m_marketEntries[stringI]["type"] = type;
                  }
                  subtype = marketEntry.@subtype.toString();
                  if(subtype != "")
                  {
                     this.m_marketEntries[stringI]["subtype"] = subtype;
                  }
                  subsubtype = marketEntry.@subsubtype.toString();
                  if(subsubtype != "")
                  {
                     this.m_marketEntries[stringI]["subsubtype"] = subsubtype;
                  }
                  i++;
               }
            }
         }
         return this.m_marketEntries;
      }
      
      public function get marketEntriesHash() : Object
      {
         var hasMarketEntries:Boolean = false;
         var marketEntriesArray:Array = null;
         var marketEntryData:BaseDataSource = null;
         var marketType:String = null;
         var marketSubType:String = null;
         var marketSubSubType:String = null;
         var marketEntries:XMLList = null;
         var marketEntry:XML = null;
         if(!this.m_marketEntriesHash)
         {
            this.m_marketEntriesHash = {};
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               marketEntriesArray = m_dataSource.getArray("marketEntries","marketEntry");
               hasMarketEntries = marketEntriesArray.length > 0;
            }
            else
            {
               hasMarketEntries = m_itemXML.hasOwnProperty("marketEntries");
            }
            if(hasMarketEntries)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  for each(marketEntryData in marketEntriesArray)
                  {
                     marketType = marketEntryData.getString("type");
                     marketSubType = marketEntryData.getString("subtype");
                     marketSubSubType = marketEntryData.getString("subsubtype");
                     if(marketSubSubType)
                     {
                        this.m_marketEntriesHash[marketType + marketSubType + marketSubSubType] = true;
                        this.m_marketEntriesHash[marketType + marketSubType] = true;
                        this.m_marketEntriesHash[marketType] = true;
                     }
                     else if(marketSubType)
                     {
                        this.m_marketEntriesHash[marketType + marketSubType] = true;
                        this.m_marketEntriesHash[marketType] = true;
                     }
                     else
                     {
                        this.m_marketEntriesHash[marketType] = true;
                     }
                  }
               }
               else
               {
                  marketEntries = m_itemXML.marketEntries.marketEntry;
                  for each(marketEntry in marketEntries)
                  {
                     if(marketEntry.@subsubtype.toString() != "")
                     {
                        this.m_marketEntriesHash[marketEntry.@type.toString() + marketEntry.@subtype.toString() + marketEntry.@subsubtype.toString()] = true;
                        this.m_marketEntriesHash[marketEntry.@type.toString() + marketEntry.@subtype.toString()] = true;
                        this.m_marketEntriesHash[marketEntry.@type.toString()] = true;
                     }
                     else if(marketEntry.@subtype.toString() != "")
                     {
                        this.m_marketEntriesHash[marketEntry.@type.toString() + marketEntry.@subtype.toString()] = true;
                        this.m_marketEntriesHash[marketEntry.@type.toString()] = true;
                     }
                     else
                     {
                        this.m_marketEntriesHash[marketEntry.@type.toString()] = true;
                     }
                  }
               }
            }
            else if(this.category == "")
            {
               this.m_marketEntriesHash[this.type + this.subType] = true;
               this.m_marketEntriesHash[this.type] = true;
            }
            else
            {
               this.m_marketEntriesHash[this.category + this.subType] = true;
               this.m_marketEntriesHash[this.category] = true;
            }
         }
         return this.m_marketEntriesHash;
      }
      
      public function set marketEntriesHash(value:Object) : void
      {
         this.m_marketEntriesHash = value;
      }
      
      public function getMetalList() : Array
      {
         var retArr:Array = null;
         var metalArr:Array = null;
         var metalList:XMLList = null;
         retArr = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            metalArr = m_dataSource.getArray("metal");
            retArr = this.convertUnwitherElementsDSToArray(metalArr);
         }
         else
         {
            metalList = m_itemXML.metal;
            retArr = this.convertUnwitherElementsXMLToArray(metalList);
         }
         return retArr;
      }
      
      public function getGemList() : Array
      {
         var retArr:Array = null;
         var metalArr:Array = null;
         var metalList:XMLList = null;
         retArr = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            metalArr = m_dataSource.getArray("gem");
            retArr = this.convertUnwitherElementsDSToArray(metalArr);
         }
         else
         {
            metalList = m_itemXML.gem;
            retArr = this.convertUnwitherElementsXMLToArray(metalList);
         }
         return retArr;
      }
      
      private function convertUnwitherElementsXMLToArray(xmlList:XMLList) : Array
      {
         var retArr:Array = null;
         var i:int = 0;
         var curObj:Object = null;
         retArr = [];
         for(i = 0; i < xmlList.length(); i++)
         {
            curObj = {};
            curObj.url = xmlList[i].@url;
            curObj.name = xmlList[i].@name;
            retArr.push(curObj);
         }
         return retArr;
      }
      
      private function convertUnwitherElementsDSToArray(arr:Array) : Array
      {
         var retArr:Array = null;
         var curDataSource:BaseDataSource = null;
         var i:int = 0;
         var elementDSObj:Object = null;
         retArr = new Array();
         for(i = 0; i < arr.length; i++)
         {
            curDataSource = arr[i];
            elementDSObj = {};
            elementDSObj.url = curDataSource.getString("url");
            elementDSObj.name = curDataSource.getString("name");
            retArr.push(elementDSObj);
         }
         return retArr;
      }
      
      public function get market3EntriesHash() : Object
      {
         if(!this.m_market3EntriesHash)
         {
            this.parseMarket3EntriesType();
         }
         return this.m_market3EntriesHash;
      }
      
      private function addToMarket3EntriesHash(market3EntriesHashToAdd:Object, itemType:String, itemSubtype:String, itemSubsubtype:String) : void
      {
         var type:String = null;
         var subtype:String = null;
         var subsubtype:String = null;
         var marketMappings:Array = null;
         var marketMapping:MarketMapping = null;
         type = "";
         subtype = "";
         subsubtype = "";
         marketMappings = Global.marketConfigSettings.getMarketMappings(itemType,itemSubtype,itemSubsubtype,this);
         if(marketMappings.length == 0)
         {
            if(subsubtype != "")
            {
               market3EntriesHashToAdd[type + subtype + subsubtype] = true;
               market3EntriesHashToAdd[type + subtype] = true;
               market3EntriesHashToAdd[type] = true;
            }
            else if(subtype != "")
            {
               market3EntriesHashToAdd[type + subtype] = true;
               market3EntriesHashToAdd[type] = true;
            }
            else
            {
               market3EntriesHashToAdd[type] = true;
            }
         }
         for each(marketMapping in marketMappings)
         {
            type = marketMapping.outputType;
            subtype = marketMapping.outputSubtype;
            subsubtype = marketMapping.outputSubsubtype;
            if(subsubtype != "")
            {
               market3EntriesHashToAdd[type + subtype + subsubtype] = true;
               market3EntriesHashToAdd[type + subtype] = true;
               market3EntriesHashToAdd[type] = true;
            }
            else if(subtype != "")
            {
               market3EntriesHashToAdd[type + subtype] = true;
               market3EntriesHashToAdd[type] = true;
            }
            else
            {
               market3EntriesHashToAdd[type] = true;
            }
         }
      }
      
      public function get market3EntriesTypeArray() : Object
      {
         if(!this.m_market3EntriesTypeArray)
         {
            this.parseMarket3EntriesType();
         }
         return this.m_market3EntriesTypeArray;
      }
      
      private function parseMarket3EntriesType() : void
      {
         var tempMarket3EntriesTypeArray:Array = null;
         var tempMarket3EntriesHash:Object = null;
         var type:String = null;
         var subtype:String = null;
         var subsubtype:String = null;
         var marketMappings:Array = null;
         var marketMapping:MarketMapping = null;
         var marketEntriesArray:Array = null;
         var marketEntryData:BaseDataSource = null;
         var marketEntries:XMLList = null;
         var marketEntry:XML = null;
         tempMarket3EntriesTypeArray = [];
         tempMarket3EntriesHash = {};
         type = "";
         subtype = "";
         subsubtype = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            marketEntriesArray = m_dataSource.getArray("marketEntries","marketEntry");
            if(marketEntriesArray.length > 0)
            {
               for each(marketEntryData in marketEntriesArray)
               {
                  type = marketEntryData.getString("type");
                  subtype = marketEntryData.getString("subtype");
                  subsubtype = marketEntryData.getString("subsubtype");
                  marketMappings = Global.marketConfigSettings.getMarketMappings(type,subtype,subsubtype,this);
                  if(marketMappings.length == 0)
                  {
                     tempMarket3EntriesTypeArray.push([type,subtype,subsubtype]);
                     this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,subsubtype);
                  }
                  for each(marketMapping in marketMappings)
                  {
                     type = marketMapping.outputType;
                     subtype = marketMapping.outputSubtype;
                     subsubtype = marketMapping.outputSubsubtype;
                     tempMarket3EntriesTypeArray.push([type,subtype,subsubtype]);
                     this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,subsubtype);
                  }
               }
            }
            else
            {
               type = subtype = subsubtype = "";
               if(this.category == "")
               {
                  type = this.type;
                  subtype = this.subType;
               }
               else
               {
                  type = this.category;
                  subtype = this.subType;
               }
               tempMarket3EntriesTypeArray.push([type,subtype,""]);
               this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,"");
            }
         }
         else if(m_itemXML.hasOwnProperty("marketEntries"))
         {
            marketEntries = m_itemXML.marketEntries.marketEntry;
            for each(marketEntry in marketEntries)
            {
               type = subtype = subsubtype = "";
               if(marketEntry.@subsubtype.toString() != "")
               {
                  type = marketEntry.@type.toString();
                  subtype = marketEntry.@subtype.toString();
                  subsubtype = marketEntry.@subsubtype.toString();
               }
               else if(marketEntry.@subtype.toString() != "")
               {
                  type = marketEntry.@type.toString();
                  subtype = marketEntry.@subtype.toString();
               }
               else
               {
                  type = marketEntry.@type.toString();
               }
               marketMappings = Global.marketConfigSettings.getMarketMappings(type,subtype,subsubtype,this);
               if(marketMappings.length == 0)
               {
                  tempMarket3EntriesTypeArray.push([type,subtype,subsubtype]);
                  this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,subsubtype);
               }
               for each(marketMapping in marketMappings)
               {
                  type = marketMapping.outputType;
                  subtype = marketMapping.outputSubtype;
                  subsubtype = marketMapping.outputSubsubtype;
                  tempMarket3EntriesTypeArray.push([type,subtype,subsubtype]);
                  this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,subsubtype);
               }
            }
         }
         else
         {
            type = subtype = subsubtype = "";
            if(this.category == "")
            {
               type = this.type;
               subtype = this.subType;
            }
            else
            {
               type = this.category;
               subtype = this.subType;
            }
            tempMarket3EntriesTypeArray.push([type,subtype,""]);
            this.addToMarket3EntriesHash(tempMarket3EntriesHash,type,subtype,"");
         }
         if(!this.m_market3EntriesTypeArray)
         {
            this.m_market3EntriesTypeArray = tempMarket3EntriesTypeArray;
         }
         if(!this.m_market3EntriesHash)
         {
            this.m_market3EntriesHash = tempMarket3EntriesHash;
         }
      }
      
      public function getSwapCountdownItemDeprecationEntry() : String
      {
         var result:String = null;
         var swapCountdownData:BaseDataSource = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            swapCountdownData = m_dataSource.getData("swapCountdown");
            if(swapCountdownData)
            {
               result = swapCountdownData.getString("itemDeprecationEntry");
               if(!result)
               {
                  result = name;
               }
            }
         }
         else if(m_itemXML.hasOwnProperty("swapCountdown"))
         {
            if(m_itemXML.swapCountdown.hasOwnProperty("@itemDeprecationEntry"))
            {
               result = m_itemXML.swapCountdown.@itemDeprecationEntry.toString();
            }
            else
            {
               result = this.name;
            }
         }
         return result;
      }
      
      public function getSwapCountdownDisplayCountExperimentGate() : String
      {
         var result:String = null;
         result = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = m_dataSource.getString("swapCountdown","displayCountExperimentGate");
            if(!result)
            {
               result = null;
            }
         }
         else if(m_itemXML.hasOwnProperty("swapCountdown"))
         {
            if(m_itemXML.swapCountdown.hasOwnProperty("@displayCountExperimentGate"))
            {
               result = m_itemXML.swapCountdown.@displayCountExperimentGate.toString();
            }
         }
         return result;
      }
      
      public function getSwapCountdownFriendlyTime(pkgkeyTimeLeft:String, pkgkeyNoTimeLeft:String, replacements:Object = null, forceComingSoon:Boolean = false) : String
      {
         var resultText:String = null;
         var showNoTimeLeft:Boolean = false;
         var itemDeprecationEntryName:String = null;
         var deprecator:DeprecatorSettings = null;
         var date:String = null;
         var expirationTime:Number = NaN;
         var serverTime:Number = NaN;
         var deltaTime:int = 0;
         var timeText:String = null;
         var pkgkeyTimeLeftSplit:Array = null;
         var pkgkeyNoTimeLeftSplit:Array = null;
         resultText = null;
         showNoTimeLeft = forceComingSoon;
         itemDeprecationEntryName = this.getSwapCountdownItemDeprecationEntry();
         if(Boolean(itemDeprecationEntryName) && !forceComingSoon)
         {
            deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(itemDeprecationEntryName);
            if(deprecator)
            {
               date = deprecator.getPrereqValue(PrerequisiteConstants.PREREQUISITE_START_TIME);
               if(date)
               {
                  expirationTime = FarmGameUtil.synchronizedDateTimeToNumber(date);
                  serverTime = Math.floor(GlobalEngine.serverTime);
                  if(expirationTime > serverTime)
                  {
                     deltaTime = (expirationTime - serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                     timeText = FarmGameUtil.toFriendlyTime(deltaTime);
                     pkgkeyTimeLeftSplit = [pkgkeyTimeLeft];
                     ZLocUtils.splitPkgKey(pkgkeyTimeLeftSplit);
                     replacements.time = timeText;
                     resultText = ZLocUtils.t(pkgkeyTimeLeftSplit[0],pkgkeyTimeLeftSplit[1],replacements);
                  }
                  else
                  {
                     showNoTimeLeft = true;
                  }
               }
            }
         }
         if(showNoTimeLeft)
         {
            pkgkeyNoTimeLeftSplit = [pkgkeyNoTimeLeft];
            ZLocUtils.splitPkgKey(pkgkeyNoTimeLeftSplit);
            resultText = ZLocUtils.t(pkgkeyNoTimeLeftSplit[0],pkgkeyNoTimeLeftSplit[1],replacements);
         }
         return resultText;
      }
      
      private function getTerrains() : Array
      {
         var terrains:Array = null;
         var terrainName:String = null;
         var terrainDataArray:Array = null;
         var terrainData:BaseDataSource = null;
         var terrainList:XMLList = null;
         var terrain:XML = null;
         terrains = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            terrainDataArray = m_dataSource.getArray("terrainSet","terrain");
            if(terrainDataArray.length > 0)
            {
               terrains = [];
               for each(terrainData in terrainDataArray)
               {
                  terrainName = terrainData.getString("name");
                  if(terrainName)
                  {
                     terrains.push(terrainName);
                  }
               }
            }
         }
         else
         {
            terrainList = m_itemXML.terrainSet.terrain;
            if(terrainList.length() > 0)
            {
               terrains = [];
               for each(terrain in terrainList)
               {
                  terrainName = terrain.@name;
                  if(terrainName != "")
                  {
                     terrains.push(terrainName);
                  }
               }
            }
         }
         if(terrains == null)
         {
            terrains = this.getDefaultTerrains();
         }
         return terrains;
      }
      
      private function getTerrainSets() : Array
      {
         var terrains:Array = null;
         var terrainName:String = null;
         var terrainDataArray:Array = null;
         var terrainData:BaseDataSource = null;
         var terrainList:XMLList = null;
         var terrain:XML = null;
         terrains = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            terrainDataArray = m_dataSource.getArray("terrainSet","terrain");
            if(terrainDataArray.length > 0)
            {
               terrains = [];
               for each(terrainData in terrainDataArray)
               {
                  terrainName = terrainData.getString("name");
                  if(terrainName)
                  {
                     terrains.push(terrainName);
                  }
               }
            }
         }
         else
         {
            terrainList = m_itemXML.terrainSet.terrain;
            if(terrainList.length() > 0)
            {
               terrains = [];
               for each(terrain in terrainList)
               {
                  terrainName = terrain.@name;
                  if(terrainName != "")
                  {
                     terrains.push(terrainName);
                  }
               }
            }
         }
         return terrains;
      }
      
      public function getTerrainSetCodes() : Array
      {
         var tmpTerrains:Array = null;
         var index:int = 0;
         var tmpArray:Array = null;
         var i:int = 0;
         if(this.m_terrainSetCodes == null)
         {
            this.m_terrainSetCodes = [];
            tmpTerrains = this.getTerrainSets();
            if(tmpTerrains != null && tmpTerrains.length > 0)
            {
               for(index = 0; index < tmpTerrains.length; index++)
               {
                  tmpArray = Global.farmGameSettingsManager.getTerrainCodes(tmpTerrains[index]);
                  if(tmpArray != null)
                  {
                     for(i = 0; i < tmpArray.length; i++)
                     {
                        if(this.m_terrainSetCodes.indexOf(tmpArray[i]) == -1)
                        {
                           this.m_terrainSetCodes.push(tmpArray[i]);
                        }
                     }
                     if(this.m_terrainSetCodes.indexOf(TerrainUtil.DEFAULT_TERRAIN_CODE) != -1)
                     {
                        this.m_terrainSetCodes.splice(this.m_terrainSetCodes.indexOf(TerrainUtil.DEFAULT_TERRAIN_CODE),1);
                     }
                  }
                  else
                  {
                     ErrorManager.addError("Terrain name " + tmpTerrains[index] + " not found in game settings.");
                  }
               }
            }
            else
            {
               this.m_terrainSetCodes.push(TerrainUtil.LAND_TERRAIN_CODE);
            }
         }
         return this.m_terrainSetCodes;
      }
      
      public function getTerrainCodes() : Array
      {
         var tmpTerrains:Array = null;
         var index:int = 0;
         var tmpArray:Array = null;
         var i:int = 0;
         if(this.m_terrainCodes == null)
         {
            this.m_terrainCodes = [];
            tmpTerrains = this.getTerrains();
            if(tmpTerrains != null && tmpTerrains.length > 0)
            {
               for(index = 0; index < tmpTerrains.length; index++)
               {
                  tmpArray = Global.farmGameSettingsManager.getTerrainCodes(tmpTerrains[index]);
                  if(tmpArray != null)
                  {
                     for(i = 0; i < tmpArray.length; i++)
                     {
                        if(this.m_terrainCodes.indexOf(tmpArray[i]) == -1)
                        {
                           this.m_terrainCodes.push(tmpArray[i]);
                        }
                     }
                  }
                  else
                  {
                     ErrorManager.addError("Terrain name " + tmpTerrains[index] + " not found in game settings.");
                  }
               }
            }
            else
            {
               ErrorManager.addError("No terrains associated with item: " + name + ".");
            }
         }
         return this.m_terrainCodes;
      }
      
      public function get freeGiftColor() : uint
      {
         if(this.m_freeGiftColor == 16777215)
         {
            this.m_freeGiftColor = DEFAULT_FREE_GIFT_COLOR;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_dataSource.hasProperty("freeGift"))
               {
                  this.m_freeGiftColor = uint("0x" + m_dataSource.getString("freeGift","border"));
               }
            }
            else if(this.xml.hasOwnProperty("freeGift"))
            {
               this.m_freeGiftColor = uint("0x" + this.xml.freeGift[0].@border.toString());
            }
         }
         return this.m_freeGiftColor;
      }
      
      public function get freeGiftTitle() : String
      {
         if(this.m_freeGiftTitle == null)
         {
            this.m_freeGiftTitle = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_freeGiftTitle = ZLocUtils.t_pk(m_dataSource.getString("freeGift","title"));
            }
            else if(this.xml.hasOwnProperty("freeGift"))
            {
               this.m_freeGiftTitle = ZLocUtils.t_pk(this.xml.freeGift[0].@title.toString());
            }
         }
         return this.m_freeGiftTitle;
      }
      
      public function get aoeConfig() : AOEConfig
      {
         return this.m_aoeConfig;
      }
      
      public function get hasAreasOfEffect() : Boolean
      {
         var hasAoe:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            hasAoe = m_dataSource.hasProperty("aoe");
         }
         else
         {
            hasAoe = m_itemXML.hasOwnProperty("aoe");
         }
         return hasAoe;
      }
      
      public function getMaterialPrice() : Object
      {
         return this.m_materialPrice;
      }
      
      public function get masteryLevelData() : Array
      {
         var masteryLevelArray:Array = null;
         masteryLevelArray = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            masteryLevelArray = m_dataSource.getArray("masteryLevel");
         }
         return masteryLevelArray;
      }
      
      public function get masteryTypeData() : Array
      {
         var masteryTypeArray:Array = null;
         masteryTypeArray = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            masteryTypeArray = m_dataSource.getArray("masteryTypes","masteryType");
         }
         return masteryTypeArray;
      }
      
      public function get orgReward() : String
      {
         var orgRewardCode:String = null;
         orgRewardCode = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            orgRewardCode = m_dataSource.getString("organicCert","orgReward");
         }
         else
         {
            orgRewardCode = m_itemXML.organicCert.@orgReward;
         }
         return orgRewardCode;
      }
      
      public function get numOfDaysToLEExpire() : Number
      {
         var result:Number = NaN;
         var limitedEnd:Number = NaN;
         result = NaN;
         if(limitedEndDate != null)
         {
            limitedEnd = FarmGameUtil.synchronizedDateToNumber(limitedEndDate);
            result = (limitedEnd / FarmGameUtil.NUM_MSECS_IN_SECOND - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) / FarmGameUtil.NUM_SECS_IN_HOUR / FarmGameUtil.NUM_HOURS_IN_DAY;
         }
         return result;
      }
      
      public function get numOfDaysSinceLENew() : Number
      {
         var result:Number = NaN;
         var limitedStart:Number = NaN;
         result = NaN;
         if(limitedStartDate != null)
         {
            limitedStart = FarmGameUtil.synchronizedDateToNumber(limitedStartDate);
            result = (GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - limitedStart / FarmGameUtil.NUM_MSECS_IN_SECOND) / FarmGameUtil.NUM_SECS_IN_HOUR / FarmGameUtil.NUM_HOURS_IN_DAY;
         }
         return result;
      }
      
      public function get featureName() : String
      {
         var featureName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureName = m_dataSource.getString("featureName");
         }
         else
         {
            featureName = m_itemXML.featureName;
         }
         return featureName;
      }
      
      public function getDefaultItemName() : String
      {
         var name:String = null;
         var defaultItemArr:Array = null;
         var curDS:BaseDataSource = null;
         name = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment() && hasPropertyInDataSource("defaultItem"))
         {
            defaultItemArr = getArrayFromDataSource("defaultItem");
            if(defaultItemArr.length)
            {
               curDS = defaultItemArr[0] as BaseDataSource;
               name = curDS.getString("name");
            }
         }
         else if(Boolean(m_itemXML) && m_itemXML.hasOwnProperty("defaultItem"))
         {
            name = m_itemXML["defaultItem"][0]["@name"];
         }
         return name;
      }
   }
}

