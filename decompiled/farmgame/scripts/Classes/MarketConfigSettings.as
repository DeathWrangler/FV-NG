package Classes
{
   import Classes.Constants.Experiments;
   import Classes.StarterPack.StarterPackUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Widgets.Windows.Market.MarketWindow;
   
   public class MarketConfigSettings
   {
      
      private static const PROMO_5_SLOT_LAYOUT:int = 5;
      
      private static const PROMO_3_SLOT_LAYOUT:int = 3;
      
      private static const PROMO_1_SLOT_LAYOUT:int = 1;
      
      private static const MARKET_3_RIGHT_PROMO_ASSET:String = "assets/dialogs/FV_MarketPromo3_right.swf";
      
      private static const MARKET_3_PROMO_ASSET:String = "assets/dialogs/FV_MarketPromo3_top.swf";
      
      private static const CARNIVAL_BOOTH_SIZE:String = "Carnival";
      
      private static const DEFAULT_MAX_BESTSELLERS:Number = 15;
      
      private var m_xml:XML;
      
      private var m_categorization:XML = null;
      
      private var m_marketCardDescriptorHash:Object = {};
      
      private var m_marketPromotionHash:Object = {};
      
      private var m_lockExplanationList:Array = [];
      
      private var m_marketPromotionList:Array = [];
      
      private var m_activePromos:Array = null;
      
      private var m_carnivalPromotionHash:Object = {};
      
      private var m_carnivalPromotionList:Array = [];
      
      private var m_activeCarnivalPromos:Array = null;
      
      private var m_marketSortingHash:Object = {};
      
      private var m_worldSaleMarketBannerHash:Object = {};
      
      private var m_numBestSellers:Number = 0;
      
      private var m_newItemCutoffTimestamp:Number = 0;
      
      private var m_marketMappings:Array = new Array();
      
      private var m_activeLEPromos:Array = null;
      
      public function MarketConfigSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
         this.init();
      }
      
      public static function getMarketDialogAssetFullPath(asset:String, absolute:Boolean = true) : String
      {
         var path:String = "";
         if(absolute)
         {
            path = Global.getAssetURL("assets/dialogs/" + asset);
         }
         else
         {
            path = Global.getAssetHashPath("assets/dialogs/" + asset);
         }
         return path;
      }
      
      public static function getMarketDialogSupportFullPath(asset:String, absolute:Boolean = true) : String
      {
         var path:String = "";
         if(absolute)
         {
            path = Global.getAssetURL("assets/dialogs/FV_Support/FV_Market/" + asset);
         }
         else
         {
            path = Global.getAssetHashPath("assets/dialogs/FV_Support/FV_Market/" + asset);
         }
         return path;
      }
      
      private function init() : void
      {
         var marketCardXML:XML = null;
         var promoXML:XML = null;
         var carnivalPromoXML:XML = null;
         var lockExplanationXML:XML = null;
         var card:MarketCardDescriptor = null;
         var promo:MarketPromotion = null;
         var carnivalPromo:MarketPromotion = null;
         var link:LockedExplanation = null;
         for each(marketCardXML in this.m_xml.marketCards.marketCard)
         {
            card = MarketCardDescriptor.fromXML(marketCardXML);
            this.m_marketCardDescriptorHash[card.name] = card;
         }
         for each(promoXML in this.m_xml.promoPage.promoItem)
         {
            promo = MarketPromotion.fromXML(promoXML);
            this.m_marketPromotionHash[promo.name] = promo;
            this.m_marketPromotionList.push(promo);
         }
         for each(carnivalPromoXML in this.m_xml.carnivalPage.promoItem)
         {
            carnivalPromo = MarketPromotion.fromXML(carnivalPromoXML);
            this.m_carnivalPromotionHash[carnivalPromo.name] = carnivalPromo;
            this.m_carnivalPromotionList.push(carnivalPromo);
         }
         for each(lockExplanationXML in this.m_xml.lockExplanations.lockExplanation)
         {
            link = LockedExplanation.fromXML(lockExplanationXML);
            this.m_lockExplanationList.push(link);
         }
         this.buildMarketMappings();
         this.buildWorldNameBannerMappings();
      }
      
      private function buildWorldNameBannerMappings() : void
      {
         var banner:XML = null;
         var worldName:String = null;
         var assetPath:String = null;
         var banners:XMLList = this.m_xml.banners.banner;
         for each(banner in banners)
         {
            worldName = banner.@worldName.toString();
            assetPath = banner.@assetPath.toString();
            this.m_worldSaleMarketBannerHash[worldName] = assetPath;
         }
      }
      
      public function getLockExplanation(prereqType:String, prereqVal:String) : LockedExplanation
      {
         var result:LockedExplanation = null;
         var eLink:LockedExplanation = null;
         for each(eLink in this.m_lockExplanationList)
         {
            if(eLink.prereqType == prereqType && eLink.prereqValue == prereqVal)
            {
               result = eLink;
               break;
            }
         }
         return result;
      }
      
      public function getMarketCardDescriptor(name:String) : MarketCardDescriptor
      {
         return this.m_marketCardDescriptorHash[name];
      }
      
      public function getMarketPromotion(name:String) : MarketPromotion
      {
         return this.m_marketPromotionHash[name];
      }
      
      public function getAllMarketPromotions() : Array
      {
         var m:MarketPromotion = null;
         var allPromos:Array = [];
         for each(m in this.m_marketPromotionHash)
         {
            if(m.checkPrerequisites())
            {
               allPromos.push(m);
            }
         }
         return allPromos;
      }
      
      public function deletePromotion(name:String) : void
      {
         if(this.m_marketPromotionHash.hasOwnProperty(name))
         {
            delete this.m_marketPromotionHash[name];
            this.getActiveMarketPromotions(true);
         }
      }
      
      public function getActiveCarnivalPromotions(forceRefresh:Boolean = false) : Array
      {
         var numActivePromos:Number = NaN;
         var slotIndex:int = 0;
         if(this.m_activeCarnivalPromos == null || forceRefresh)
         {
            this.m_activeCarnivalPromos = new Array();
            numActivePromos = Number(Global.flashHotParams["CARNIVAL_PROMOS_ACTIVE"]);
            for(slotIndex = 0; slotIndex < numActivePromos; slotIndex++)
            {
               this.m_activeCarnivalPromos.push(this.getActiveCarnivalPromoBySlot(slotIndex));
            }
         }
         return this.m_activeCarnivalPromos;
      }
      
      public function getActiveMarketPromotions(forceRefresh:Boolean = false) : Array
      {
         var numActivePromos:Number = NaN;
         if(this.m_activePromos == null || forceRefresh)
         {
            this.m_activePromos = new Array();
            numActivePromos = Number(Global.flashHotParams["MARKET_PROMOS_ACTIVE"]);
            switch(numActivePromos)
            {
               case PROMO_5_SLOT_LAYOUT:
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(0,MarketPromotion.PROMO_SIZE_SMALL));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(1,MarketPromotion.PROMO_SIZE_SMALL));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(2,MarketPromotion.PROMO_SIZE_MEDIUM));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(3,MarketPromotion.PROMO_SIZE_SMALL));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(4,MarketPromotion.PROMO_SIZE_SMALL));
                  break;
               case PROMO_1_SLOT_LAYOUT:
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(0,MarketPromotion.PROMO_SIZE_LARGE));
                  break;
               case PROMO_3_SLOT_LAYOUT:
               default:
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(0,MarketPromotion.PROMO_SIZE_MEDIUM));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(1,MarketPromotion.PROMO_SIZE_MEDIUM));
                  this.m_activePromos.push(this.getActivePromoBySlotAndSize(2,MarketPromotion.PROMO_SIZE_MEDIUM));
            }
         }
         return this.m_activePromos;
      }
      
      public function getActiveLEPromoItems(themes:Array, refresh:Boolean = false) : Array
      {
         var i:int = 0;
         var promo:MarketPromotion = null;
         if(this.m_activeLEPromos == null || refresh)
         {
            this.m_activeLEPromos = new Array();
            for(i = 0; i < themes.length; i++)
            {
               promo = this.getMarketPromotion(themes[i]);
               if(promo)
               {
                  this.m_activeLEPromos.push([promo]);
               }
            }
         }
         return this.m_activeLEPromos;
      }
      
      public function getActiveLEPromoBySlot(slot:int) : Array
      {
         var size:String = MarketPromotion.PROMO_SIZE_MEDIUM;
         var result:Array = new Array();
         return result.concat(this.getActivePromoFromConfig(slot,size));
      }
      
      private function getActiveCarnivalPromoBySlot(slotNum:int) : Array
      {
         var resultPromoArray:Array = new Array();
         var result:Array = this.getActivePromoFromRuntime(this.m_carnivalPromotionHash,"CARNIVAL_PROMO_SLOT_" + slotNum);
         if(result.length > 0)
         {
            resultPromoArray = resultPromoArray.concat(result);
         }
         else
         {
            result = this.getActiveCarnivalPromoFromConfig(slotNum);
            if(result.length > 0)
            {
               resultPromoArray = resultPromoArray.concat(result);
            }
            else
            {
               resultPromoArray = resultPromoArray.concat(this.getDefaultCarnivalPromo());
            }
         }
         return resultPromoArray;
      }
      
      private function getActivePromoBySlotAndSize(slotNum:int, size:String) : Array
      {
         var resultPromoArray:Array = new Array();
         resultPromoArray = resultPromoArray.concat(this.getStarterPackPromo(slotNum,size));
         var result:Array = this.getActivePromoFromRuntime(this.m_marketPromotionHash,"MARKET_PROMO_SLOT_" + slotNum,size);
         if(result.length > 0)
         {
            resultPromoArray = resultPromoArray.concat(result);
         }
         else
         {
            resultPromoArray = resultPromoArray.concat(this.getActivePromoFromConfig(slotNum,size));
         }
         return resultPromoArray;
      }
      
      private function getStarterPackPromo(slotNum:int, size:String) : Array
      {
         var starterPackPromoValue:String = null;
         var starterPackPromo:MarketPromotion = null;
         var result:Array = new Array();
         if(slotNum == StarterPackUtility.STARTER_PACK_PROMO_SLOT && StarterPackUtility.starterPacksAvailable())
         {
            starterPackPromoValue = Global.flashHotParams[StarterPackUtility.STARTER_PACK_PROMO_FLAG];
            if(starterPackPromoValue != "")
            {
               starterPackPromo = this.m_marketPromotionHash[starterPackPromoValue] as MarketPromotion;
               if(Boolean(starterPackPromo && size == starterPackPromo.size) && Boolean(Global.player.level >= starterPackPromo.minRequiredLevel) && FarmGameUtil.checkDateGate(starterPackPromo.timedLimitedStart,starterPackPromo.timedLimitedEnd))
               {
                  result.push(starterPackPromo);
               }
            }
         }
         return result;
      }
      
      private function getDefaultCarnivalPromo() : Array
      {
         var result:Array = new Array();
         var defaultCarnvialPromoName:String = Global.flashHotParams["CARNIVAL_PROMO_DEFAULT"];
         var defaultCarnivalPromo:MarketPromotion = this.m_carnivalPromotionHash[defaultCarnvialPromoName] as MarketPromotion;
         if(defaultCarnivalPromo)
         {
            result.push(defaultCarnivalPromo);
         }
         return result;
      }
      
      private function getActivePromoFromRuntime(promoHash:Object, runtimePromoFlag:String, size:String = "") : Array
      {
         var promoArray:Array = null;
         var runTimePromoName:String = null;
         var runtimePromo:MarketPromotion = null;
         var result:Array = new Array();
         var runtimePromoValues:String = Global.flashHotParams[runtimePromoFlag];
         if(runtimePromoValues)
         {
            promoArray = runtimePromoValues.split(",");
            for each(runTimePromoName in promoArray)
            {
               if(promoHash[runTimePromoName] is MarketPromotion)
               {
                  runtimePromo = promoHash[runTimePromoName] as MarketPromotion;
                  if((size == "" || runtimePromo.size == size) && Global.player.level >= runtimePromo.minRequiredLevel && runtimePromo.checkPrerequisites(true))
                  {
                     result.push(runtimePromo);
                  }
               }
            }
         }
         return result;
      }
      
      private function getActivePromoFromConfig(slotNum:int, size:String) : Array
      {
         var marketPromo:MarketPromotion = null;
         var result:Array = new Array();
         for(var i:int = 0; i < this.m_marketPromotionList.length; i++)
         {
            marketPromo = this.m_marketPromotionList[i];
            if(this.xmlPromoIsValid(marketPromo,this.m_marketPromotionHash,slotNum,size))
            {
               result.push(marketPromo);
            }
         }
         return result;
      }
      
      private function getActiveCarnivalPromoFromConfig(slotNum:int) : Array
      {
         var carnivalPromo:MarketPromotion = null;
         var result:Array = new Array();
         for(var i:int = 0; i < this.m_carnivalPromotionList.length; i++)
         {
            carnivalPromo = this.m_carnivalPromotionList[i];
            if(this.xmlPromoIsValid(carnivalPromo,this.m_carnivalPromotionHash,slotNum))
            {
               result.push(carnivalPromo);
            }
         }
         return result;
      }
      
      private function xmlPromoIsValid(marketPromo:MarketPromotion, promoHash:Object, slotNum:int, size:String = "") : Boolean
      {
         var validSize:Boolean = false;
         var validSlot:Boolean = false;
         var result:Boolean = false;
         if(Boolean(promoHash) && Boolean(marketPromo) && promoHash.hasOwnProperty(marketPromo.name))
         {
            validSize = size == "" || marketPromo.size == size;
            validSlot = marketPromo.timedSlot != null && marketPromo.timedSlot != "" && slotNum == int(marketPromo.timedSlot);
            if(validSize && validSlot && Global.player.level >= marketPromo.minRequiredLevel && marketPromo.checkPrerequisites())
            {
               result = true;
            }
         }
         if(MarketWindow.isNewMarketplaceHomepageOn() && result)
         {
            if(marketPromo.size != CARNIVAL_BOOTH_SIZE && marketPromo.asset != MARKET_3_PROMO_ASSET && marketPromo.asset != Global.getAssetHashPath(MARKET_3_PROMO_ASSET) && marketPromo.asset != MARKET_3_RIGHT_PROMO_ASSET && marketPromo.asset != Global.getAssetHashPath(MARKET_3_RIGHT_PROMO_ASSET))
            {
               result = false;
            }
         }
         else if(result)
         {
            if(marketPromo.asset == MARKET_3_PROMO_ASSET || marketPromo.asset == Global.getAssetHashPath(MARKET_3_PROMO_ASSET) || marketPromo.asset == MARKET_3_RIGHT_PROMO_ASSET || marketPromo.asset == Global.getAssetHashPath(MARKET_3_RIGHT_PROMO_ASSET))
            {
               result = false;
            }
         }
         return result;
      }
      
      public function getSubTypes(typeName:String) : Array
      {
         var subTypes:Array = null;
         var subTypeXMLList:XMLList = null;
         var subTypeXML:XML = null;
         subTypes = [];
         subTypeXMLList = this.categorization.type.(@name == typeName);
         if(Boolean(subTypeXMLList) && Boolean(subTypeXMLList[0]))
         {
            for each(subTypeXML in subTypeXMLList[0].subtype)
            {
               if(Global.farmGameSettingsManager.checkPrereqNode(subTypeXML) == true)
               {
                  subTypes.push(subTypeXML.@name.toString());
               }
            }
         }
         return subTypes;
      }
      
      public function getSubSubTypes(typeName:String, subTypeName:String) : Array
      {
         var subTypes:Array = null;
         var subTypeXMLList:XMLList = null;
         var subTypeXML:XML = null;
         subTypes = [];
         subTypeXMLList = this.categorization.type.(@name == typeName).subtype.(@name == subTypeName);
         if(Boolean(subTypeXMLList) && Boolean(subTypeXMLList[0]))
         {
            for each(subTypeXML in subTypeXMLList[0].subsubtype)
            {
               subTypes.push(subTypeXML.@name.toString());
            }
         }
         return subTypes;
      }
      
      public function getSortOptions(typeName:String) : Array
      {
         var sortOptsXMLList:XMLList = null;
         var sortOpts:Array = null;
         var sortOptXML:XML = null;
         var sortBy:String = null;
         var sortDir:String = null;
         var sortOpt:Object = null;
         if(!this.m_marketSortingHash.hasOwnProperty(typeName))
         {
            sortOptsXMLList = this.categorization.type.(@name == typeName).sortTypes.sort;
            sortOpts = [];
            for each(sortOptXML in sortOptsXMLList)
            {
               sortBy = sortOptXML.@by.toString();
               sortDir = sortOptXML.@dir.toString();
               sortOpt = {
                  "sortBy":sortBy,
                  "sortDirection":sortDir
               };
               sortOpts.push(sortOpt);
            }
            this.m_marketSortingHash[typeName] = sortOpts;
         }
         return this.m_marketSortingHash[typeName];
      }
      
      public function getPresortXMLList(typeName:String) : XMLList
      {
         var returnXMLList:XMLList = null;
         var typeXMLList:XMLList = null;
         var presortsXMLList:XMLList = null;
         returnXMLList = null;
         typeXMLList = this.categorization.type.(@name == typeName);
         if(typeXMLList)
         {
            presortsXMLList = this.categorization.type.(@name == typeName).presorts;
            if(presortsXMLList)
            {
               returnXMLList = presortsXMLList.presort;
            }
         }
         return returnXMLList;
      }
      
      public function getPresortAllWorldXMLList(typeName:String) : XMLList
      {
         var returnXMLList:XMLList = null;
         var allWorldShowXMLList:XMLList = null;
         var typeXMLList:XMLList = null;
         var presortsXMLList:XMLList = null;
         var allWorldPresortXMLList:XMLList = null;
         var node:XML = null;
         var nodeItr:int = 0;
         returnXMLList = null;
         typeXMLList = this.categorization.type.(@name == typeName);
         if(typeXMLList)
         {
            presortsXMLList = this.categorization.type.(@name == typeName).presorts;
            if(presortsXMLList)
            {
               allWorldPresortXMLList = this.categorization.type.(@name == typeName).presorts.presort;
               if(allWorldPresortXMLList)
               {
                  for(nodeItr = 0; nodeItr < allWorldPresortXMLList.length(); nodeItr++)
                  {
                     node = allWorldPresortXMLList[nodeItr];
                     if(node.hasOwnProperty("@showUpFrontInAllWorlds") && Boolean(node.(@showUpFrontInAllWorlds == "true")))
                     {
                        if(!returnXMLList)
                        {
                           returnXMLList = XMLList(node);
                        }
                        else
                        {
                           returnXMLList += node;
                        }
                     }
                  }
               }
            }
         }
         return returnXMLList;
      }
      
      public function getPromoItemSlotData(typeName:String) : Object
      {
         var promoSlotData:Object = null;
         var typeXMLList:XMLList = null;
         var promoSlotXMLList:XMLList = null;
         var itemName:String = null;
         var marketCard:String = null;
         promoSlotData = null;
         typeXMLList = this.categorization.type.(@name == typeName);
         if(typeXMLList)
         {
            promoSlotXMLList = this.categorization.type.(@name == typeName).promoSlot;
            if(promoSlotXMLList.length() > 0)
            {
               itemName = promoSlotXMLList[0].@name;
               marketCard = promoSlotXMLList[0].@marketCard;
               if(Boolean(itemName) && Boolean(marketCard))
               {
                  promoSlotData = {
                     "name":itemName,
                     "marketCard":marketCard
                  };
               }
            }
         }
         return promoSlotData;
      }
      
      public function get maxBestSellers() : Number
      {
         if(!this.m_numBestSellers)
         {
            this.m_numBestSellers = Number(this.m_xml.featureConfig.showBestSellers);
            this.m_numBestSellers = this.m_numBestSellers ? this.m_numBestSellers : DEFAULT_MAX_BESTSELLERS;
         }
         return this.m_numBestSellers;
      }
      
      public function getDefaultBestSellers() : Array
      {
         var item:XML = null;
         var result:Array = null;
         var sortedItemObj:Object = null;
         var itemObj:Object = null;
         var farmItem:FarmItem = null;
         var itemsToSort:Array = [];
         var items:XMLList = this.m_xml.bestSellers.items.item;
         for each(item in items)
         {
            if(item.@minWeight.toString().length > 0)
            {
               itemObj = {
                  "name":item.@name.toString(),
                  "minWeight":Number(item.@minWeight.toString())
               };
               itemsToSort.push(itemObj);
            }
         }
         itemsToSort.sortOn("minWeight",Array.DESCENDING | Array.NUMERIC);
         result = [];
         for each(sortedItemObj in itemsToSort)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(sortedItemObj["name"]);
            result.push(farmItem);
         }
         return result;
      }
      
      public function getNewItemCutoff() : Number
      {
         var cutoffDate:String = null;
         var runtimeCutoffFlag:String = null;
         var x:Object = {};
         if(!this.m_newItemCutoffTimestamp)
         {
            cutoffDate = this.m_xml.featureConfig.newDateCutoff;
            runtimeCutoffFlag = Global.flashHotParams["MARKET_NEW_DATE_CUTOFF"];
            if(runtimeCutoffFlag != null && runtimeCutoffFlag != "")
            {
               cutoffDate = runtimeCutoffFlag;
            }
            this.m_newItemCutoffTimestamp = FarmGameUtil.synchronizedDateToNumber(cutoffDate);
         }
         return this.m_newItemCutoffTimestamp;
      }
      
      public function getNewItems() : Array
      {
         return [];
      }
      
      private function get categorization() : XML
      {
         var categorization:XML = null;
         var cat:XML = null;
         if(this.m_categorization != null)
         {
            cat = this.m_categorization;
         }
         else
         {
            for each(categorization in this.m_xml.categorization)
            {
               if(Global.farmGameSettingsManager.checkPrereqNode(categorization) == true)
               {
                  cat = categorization;
                  break;
               }
            }
            this.m_categorization = cat;
         }
         return cat;
      }
      
      private function buildMarketMappings() : void
      {
         var mapping:XML = null;
         var marketMapping:MarketMapping = null;
         for each(mapping in this.m_xml.marketMapping)
         {
            marketMapping = new MarketMapping(mapping);
            this.m_marketMappings.push(marketMapping);
         }
      }
      
      public function getMarketMappings(type:String, subtype:String = "", subsubtype:String = "", farmItem:FarmItem = null) : Array
      {
         var mapping:MarketMapping = null;
         var result:Array = new Array();
         for each(mapping in this.m_marketMappings)
         {
            if(mapping.matchesMapping(type,subtype,subsubtype,farmItem))
            {
               result.push(mapping);
            }
         }
         return result;
      }
      
      public function getWorldSaleBannerAssetPath(worldName:String) : String
      {
         var assetPath:String = "";
         if(this.m_worldSaleMarketBannerHash.hasOwnProperty(worldName))
         {
            assetPath = this.m_worldSaleMarketBannerHash[worldName];
         }
         return assetPath;
      }
      
      public function isLERevampActive() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_REVAMP_2017) == 1)
         {
            result = true;
         }
         return result;
      }
   }
}

