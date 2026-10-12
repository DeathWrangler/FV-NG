package Widgets.Slots.Market
{
   import Classes.BushelReportActionDropHandler;
   import Classes.Constants.Experiments;
   import Classes.DealOfDayHelper;
   import Classes.DragonImageProgression;
   import Classes.HarvestYield;
   import Classes.ItemBuff;
   import Classes.ItemBuffs.IBPollinatedCrop;
   import Classes.ManagedSale;
   import Classes.MarketCardDescriptor;
   import Classes.Mastery;
   import Classes.StarterPack.StarterPackUtility;
   import Classes.SuperCropRequirement;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.ClothingItem;
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.ExpansionAccessItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.GreenhouseSeedItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.IUGCItem;
   import Classes.ZItem.ItemLicense;
   import Classes.ZItem.SeedItem;
   import Classes.ZItem.StarterPackItem;
   import Classes.ZItem.StencilPortalItem;
   import Classes.ZItem.TreeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   import Managers.ItemBuffManager;
   import Managers.ItemMembershipManager;
   import Managers.LESetManager;
   import Managers.LicenseManager;
   import Managers.ManagedSalesManager;
   import Managers.MarketFlashSaleManager;
   import Managers.MarketStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotCashBuyFrame;
   import Widgets.Frames.Market.MarketSlotCoinBuyFrame;
   import Widgets.Frames.Market.MarketSlotFrame;
   import Widgets.Frames.Market.MarketSlotInventoryFrame;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.Market.MarketSlotSaleFrame;
   import Widgets.Frames.Market.MarketSlotTreeLevelFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.BrandedItemTooltip;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.LineScaleMode;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   
   public class MarketSlot extends ZwSlotFrame
   {
      
      private static const DEFAULT_COIN_GAIN_WIDTH:int = 40;
      
      private static const MIN_GAIN_CURRENCY_WIDTH:int = 60;
      
      private static const BACKGROUND_WIDTH:int = 220;
      
      private static const BACKGROUND_HEIGHT:int = 118;
      
      private static const BACKGROUND_CORNER_RADIUS:int = 10;
      
      private static const ICON_SIZE:int = 50;
      
      private static const TOP_BUY_POSITION_Y:int = 79;
      
      private static const BOTTOM_BUY_POSITION_Y:int = 97;
      
      private static const TOP_SALE_POSITION_Y:int = 57;
      
      private static const BOTTOM_SALE_POSITION_Y:int = 73;
      
      private static const MAX_CARD_INFO_HEIGHT:int = 82;
      
      private static const THEME_PREFIX:String = "theme_";
      
      private static const VIP_ICON_URL:String = "assets/animals/";
      
      private static const VIP_ICON_URL_NEW:String = "assets/animalsnew/";
      
      private static const ICON_CASH_LICENSE_EXPIRED_URL:String = "assets/dialogs/FV_Support/FV_Market/cashCrop_permitPre.png";
      
      private static const ICON_CASH_LICENSE_ACTIVE_URL:String = "assets/dialogs/FV_Support/FV_Market/cashCrop_permitPost.png";
      
      private static const ICON_SUPER_CROP_LOCKED_URL:String = "assets/dialogs/4d_elements/City_xPromo/xpromoCity_lock.png";
      
      public static const ALT_MARKET_TOKEN:String = "_shortFriendlyName";
      
      public static const XAF_CHARITY:String = "xafcharity";
      
      private var m_callbacks:Object;
      
      private var m_container:MarketSlotFrame;
      
      protected var m_data:FarmItem;
      
      private var m_backgroundGradient:Sprite;
      
      private var m_backgroundImage:FarmIcon;
      
      protected var m_icon:FarmIcon;
      
      private var m_iconTooltip:BrandedItemTooltip;
      
      private var m_nameTextField:ZwTextField;
      
      protected var m_infoTextField:ZwTextField;
      
      private var m_themeTextField:ZwTextField;
      
      private var m_gainCoinText:ZwTextField;
      
      private var m_gainCurrencyText:ZwTextField;
      
      private var m_gainCoin:ZwFrame;
      
      private var m_gainCurrency:ZwFrame;
      
      private var m_gainJadeCurrency:ZwFrame;
      
      private var m_limitedTimer:Timer;
      
      private var m_saleTimer:Timer;
      
      private var m_limitedTimerTextField:ZwTextField;
      
      private var m_saleTimerTextField:ZwTextField;
      
      private var m_helpButton:FarmAnimatedTextButton;
      
      private var m_terrainButton:FarmAnimatedTextButton;
      
      private var m_newButton:FarmAnimatedTextButton;
      
      protected var m_previewButton:FarmAnimatedTextButton;
      
      protected var m_buyCashFrame:MarketSlotCashBuyFrame;
      
      protected var m_buyCoinFrame:MarketSlotCoinBuyFrame;
      
      private var m_inventoryFrame:MarketSlotInventoryFrame;
      
      private var m_masteryFrame:MarketSlotMasteryFrame;
      
      protected var m_saleFrame:MarketSlotSaleFrame;
      
      private var m_cashLicenseIcon:FarmIcon;
      
      private var m_singleBloomIcon:FarmIcon;
      
      private var m_fullBloomIcon:FarmIcon;
      
      private var m_treeLevelFrame:MarketSlotTreeLevelFrame;
      
      private var m_gainCurrencyTextOriginalX:int;
      
      private var m_gainCurrencyOriginalX:int;
      
      private var m_managedSale:ManagedSale = null;
      
      private var m_charityLogo:ZwWidget;
      
      private var m_charityLogo_africa:ZwWidget;
      
      protected var m_originalSaleFarmeX:int = 0;
      
      protected var m_originalSaleFarmeY:int = 0;
      
      public function MarketSlot(element:DisplayObject, container:MarketSlotFrame, callbacks:Object)
      {
         this.m_container = container;
         this.m_callbacks = callbacks;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(this.iconSize,this.iconSize);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.title_tf,"",true)) as ZwTextField;
         this.m_infoTextField = addWidget(new ZwTextField(m_element.info_tf,"",true)) as ZwTextField;
         (this.m_infoTextField.element as TextField).autoSize = TextFieldAutoSize.LEFT;
         this.m_themeTextField = addWidget(new ZwTextField(m_element.theme_tf)) as ZwTextField;
         this.m_limitedTimerTextField = addWidget(new ZwTextField(m_element.timer_tf,"",true)) as ZwTextField;
         this.m_saleTimerTextField = addWidget(new ZwTextField(m_element.saletimer_tf,"",true)) as ZwTextField;
         this.m_cashLicenseIcon = addWidget(new FarmIcon(m_element.iconPermit_mc),false) as FarmIcon;
         if(Boolean(m_element.bloomSingle_mc) && Boolean(m_element.bloomFull_mc))
         {
            this.m_singleBloomIcon = addWidget(new FarmIcon(m_element.bloomSingle_mc),false) as FarmIcon;
            this.m_fullBloomIcon = addWidget(new FarmIcon(m_element.bloomFull_mc),false) as FarmIcon;
         }
         if(m_element.hasOwnProperty("logoMiniCharity_mc"))
         {
            this.m_charityLogo = addWidget(new ZwWidget(m_element.logoMiniCharity_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("charity_logo_mc"))
         {
            this.m_charityLogo_africa = addWidget(new ZwWidget(m_element.charity_logo_mc),false) as ZwWidget;
         }
         this.m_buyCashFrame = addWidget(new MarketSlotCashBuyFrame(m_element.buyCash_mc,this.onCallbackButtonClick)) as MarketSlotCashBuyFrame;
         this.m_buyCoinFrame = addWidget(new MarketSlotCoinBuyFrame(m_element.buyCoin_mc,this.onCallbackButtonClick)) as MarketSlotCoinBuyFrame;
         this.m_inventoryFrame = addWidget(new MarketSlotInventoryFrame(m_element.giftable_mc,this.onCallbackButtonClick)) as MarketSlotInventoryFrame;
         this.m_saleFrame = addWidget(new MarketSlotSaleFrame(m_element.sale_mc)) as MarketSlotSaleFrame;
         this.m_treeLevelFrame = addWidget(new MarketSlotTreeLevelFrame(m_element.mc_treemasterylvl)) as MarketSlotTreeLevelFrame;
         this.m_helpButton = addWidget(new FarmAnimatedTextButton(m_element.question_bt,"?",this.onCallbackButtonClick),false) as FarmAnimatedTextButton;
         this.m_helpButton.attachTooltip(new MarketTooltip());
         this.m_newButton = addWidget(new FarmAnimatedTextButton(m_element.new_bt,ZLocUtils.t("Dialogs","NewLabel")),false) as FarmAnimatedTextButton;
         this.m_newButton.attachTooltip(new MarketTooltip());
         this.m_previewButton = addWidget(new FarmAnimatedTextButton(m_element.preview_bt," ",this.onCallbackButtonClick),false) as FarmAnimatedTextButton;
         this.m_originalSaleFarmeX = this.m_saleFrame.x;
         this.m_originalSaleFarmeY = this.m_saleFrame.y;
         this.initializeMarketVersionSpecificElements();
      }
      
      public static function generateMarketCardInfoText(item:FarmItem, fallbackToTooltipText:Boolean = false, isMarketWindow:Boolean = true) : String
      {
         var harvestLocStr:String = null;
         var harvestTime:Number = NaN;
         var harvestTimeStr:String = null;
         var harvestYieldObject:Object = null;
         var dayInSeconds:Number = NaN;
         var gainStr:String = null;
         var textOnlyGain:String = null;
         var currentWorldCurrency:String = null;
         var result:String = "";
         var info:Array = new Array();
         if(ZLocUtils.hasString("Dialogs",item.name + "AltInfoMessage"))
         {
            info.push(ZLocUtils.t("Dialogs",item.name + "AltInfoMessage"));
         }
         if(item is HarvestableItem && (item as HarvestableItem).growTime > 0)
         {
            harvestLocStr = "GrowthDays";
            harvestTime = (item as HarvestableItem).growTime;
            harvestTimeStr = "";
            if(harvestTime < 1)
            {
               harvestLocStr = "GrowthHours";
               dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
               harvestTime = dayInSeconds / 60 / 60 * harvestTime;
               harvestTimeStr = harvestTime.toFixed(0);
               info.push(ZLocUtils.t("Dialogs",harvestLocStr,{
                  "quantity":harvestTimeStr,
                  "Hour_word":ZLocUtils.tk("Dialogs","Hour_word","",harvestTime)
               }));
            }
            else
            {
               harvestTimeStr = harvestTime.toString();
               info.push(ZLocUtils.t("Dialogs",harvestLocStr,{
                  "quantity":harvestTimeStr,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",harvestTime)
               }));
            }
            harvestYieldObject = getHarvestYieldObject(item);
            if(harvestYieldObject.coinYield > 0 || harvestYieldObject.goldYield > 0 || harvestYieldObject.worldCurrencyYield > 0)
            {
               gainStr = ZLocUtils.t("Dialogs","Gain");
               if(!isMarketWindow)
               {
                  textOnlyGain = " ";
                  if(harvestYieldObject.goldYield > 0)
                  {
                     textOnlyGain += Utilities.formatNumber(harvestYieldObject.goldYield) + " " + ZLocUtils.t("Dialogs","coins") + " ";
                  }
                  else if(harvestYieldObject.coinYield > 0)
                  {
                     textOnlyGain += Utilities.formatNumber(harvestYieldObject.coinYield) + " " + ZLocUtils.t("Dialogs","coins") + " ";
                  }
                  if(harvestYieldObject.worldCurrencyYield > 0)
                  {
                     textOnlyGain += Utilities.formatNumber(harvestYieldObject.worldCurrencyYield);
                     currentWorldCurrency = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
                     textOnlyGain += textOnlyGain + " " + ZLocUtils.t("Dialogs",currentWorldCurrency);
                  }
                  gainStr += textOnlyGain;
               }
               info.push(gainStr);
            }
         }
         else if(item.sellable && item.sellPrice > 0)
         {
            info.push(ZLocUtils.t("Dialogs","Yield",{
               "coinQuantity":item.sellDisplayPrice,
               "Coin_word":ZLocUtils.tk("FarmGame",item.sellCurrency,"",item.sellDisplayPrice)
            }));
         }
         if(item.buyWorldScore > 0)
         {
            info.push(ZLocUtils.t("Dialogs","WorldScoreGained",{
               "scoreUnit":ZLocUtils.t("FarmGame","worldscore_short_" + item.buyWorldScoreUnit),
               "quantity":item.buyWorldScore
            }));
         }
         else if(item.plantXp > 0)
         {
            info.push(ZLocUtils.t("Dialogs","XPGained",{"quantity":item.plantXp}));
         }
         else if(item.xpGained > 0)
         {
            info.push(ZLocUtils.t("Dialogs","XPGained",{"quantity":item.xpGained}));
         }
         result = info.join("\n");
         if(fallbackToTooltipText && info.length == 0)
         {
            result = item.getUsageDescription();
            if(result == null)
            {
               result = "";
            }
         }
         return result;
      }
      
      protected static function getHarvestYieldObject(item:FarmItem) : Object
      {
         var type:String = null;
         var yield:Number = NaN;
         var result:Object = new Object();
         var currentWorldCurrencyType:String = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
         var coinYield:Number = (item as HarvestableItem).coinYield;
         var harvestYields:Vector.<HarvestYield> = (item as HarvestableItem).harvestYields;
         var harvestYieldObject:Object = new Object();
         for(var i:int = 0; i < harvestYields.length; i++)
         {
            type = harvestYields[i].type;
            yield = harvestYields[i].displayYield;
            harvestYieldObject[type] = yield;
         }
         var goldYield:int = int(harvestYieldObject[Currency.GOLD]);
         var worldCurrencyYield:int = int(harvestYieldObject[currentWorldCurrencyType]);
         result.coinYield = coinYield;
         result.goldYield = goldYield;
         result.worldCurrencyYield = worldCurrencyYield;
         return result;
      }
      
      protected function initializeMarketVersionSpecificElements() : void
      {
         this.m_backgroundGradient = new Sprite();
         (m_element as MovieClip).addChildAt(this.m_backgroundGradient,(m_element as MovieClip).getChildIndex(m_element.cardLoader_mc));
         this.m_backgroundImage = addWidget(new FarmIcon(m_element.cardLoader_mc)) as FarmIcon;
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         this.m_gainCoin = addWidget(new ZwFrame(m_element.gain_coin_mc)) as ZwFrame;
         this.m_gainCoinText = addWidget(new ZwTextField(m_element.coin_info_tf,"")) as ZwTextField;
         var currencyImgFrameName:String = "gain_" + Global.worldManager.currentWorldCurrency + "_mc";
         if(Global.worldManager.currentWorldCurrency != Currency.COINS && m_element[currencyImgFrameName] != null)
         {
            this.m_gainCurrency = addWidget(new ZwFrame(m_element[currencyImgFrameName])) as ZwFrame;
            this.m_gainCurrencyOriginalX = this.m_gainCurrency.x;
         }
         this.m_gainCurrencyText = addWidget(new ZwTextField(m_element.coconuts_info_tf,"")) as ZwTextField;
         this.m_gainCurrencyTextOriginalX = this.m_gainCurrencyText.x;
         if(this.m_gainCurrencyText.width < MIN_GAIN_CURRENCY_WIDTH)
         {
            this.m_gainCurrencyText.width = MIN_GAIN_CURRENCY_WIDTH;
         }
         (this.m_infoTextField.element as TextField).width = 144;
      }
      
      public function get data() : FarmItem
      {
         return this.m_data;
      }
      
      public function get iconSize() : int
      {
         return ICON_SIZE;
      }
      
      private function setHarvestableGain(item:FarmItem) : void
      {
         var harvestYieldObject:Object = null;
         var coinTextOffset:int = 0;
         if(item is HarvestableItem && (item as HarvestableItem).growTime > 0)
         {
            harvestYieldObject = getHarvestYieldObject(item);
            coinTextOffset = 0;
            if(harvestYieldObject.goldYield > 0)
            {
               this.m_gainCoinText.text = Utilities.formatNumber(harvestYieldObject.goldYield);
               this.m_gainCoin.visible = true;
               this.m_gainCoinText.visible = true;
               coinTextOffset = (this.m_gainCoinText.element as TextField).textWidth - DEFAULT_COIN_GAIN_WIDTH;
            }
            else if(harvestYieldObject.coinYield > 0)
            {
               this.m_gainCoinText.text = Utilities.formatNumber(harvestYieldObject.coinYield);
               this.m_gainCoin.visible = true;
               this.m_gainCoinText.visible = true;
               coinTextOffset = (this.m_gainCoinText.element as TextField).textWidth - DEFAULT_COIN_GAIN_WIDTH;
            }
            if(harvestYieldObject.worldCurrencyYield > 0 && this.m_gainCurrency != null)
            {
               this.m_gainCurrencyText.text = Utilities.formatNumber(harvestYieldObject.worldCurrencyYield);
               this.m_gainCurrencyText.x = coinTextOffset + this.m_gainCurrencyTextOriginalX;
               this.m_gainCurrency.x = coinTextOffset + this.m_gainCurrencyOriginalX;
               this.m_gainCurrency.visible = true;
               this.m_gainCurrencyText.visible = true;
            }
         }
      }
      
      protected function setupNormalSlot() : void
      {
         var saleCurrency:String = null;
         var managedSale:ManagedSale = null;
         var cashPrice:Number = this.m_data.cash;
         var coinPrice:Number = this.m_data.cost;
         var salePrice:Number = 0;
         this.m_buyCoinFrame.resetLockStates();
         if(this.m_data.buyableWithCash() && this.m_data.isInCashExperiment)
         {
            this.m_buyCashFrame.cost = cashPrice;
            if(Boolean(this.m_data.promoMode) && this.m_data.promoMode == LESetManager.LESET_PROMO_ID)
            {
               StatsManager.count("marketcard","reward_purch_set","view");
               this.m_buyCashFrame.licensable = true;
               this.m_buyCashFrame.cost = 0;
            }
            this.m_buyCashFrame.playable = this.m_data.isGameToken;
            this.m_buyCashFrame.sendable = MarketWindow.isItemSendable(this.m_data);
            this.m_buyCashFrame.visible = true;
            if(this.m_data.hasSale)
            {
               saleCurrency = Currency.CASH;
               salePrice = this.m_data.saleCash;
            }
         }
         if(this.m_data.buyableWithCurrency() && this.m_data.isInCoinExperiment)
         {
            this.m_buyCoinFrame.cost = coinPrice;
            this.m_buyCoinFrame.setupLockState(this.m_data);
            this.m_buyCoinFrame.visible = true;
            if(this.m_data.hasSale)
            {
               saleCurrency = Currency.COINS;
            }
         }
         if(this.m_buyCoinFrame.locked && !this.m_buyCoinFrame.unlockable && !this.m_data.buyableWithCash())
         {
            this.m_buyCashFrame.visible = false;
         }
         else
         {
            this.m_buyCashFrame.setupLockState(this.m_data);
         }
         if(Boolean(this.m_singleBloomIcon) && Boolean(this.m_fullBloomIcon))
         {
            if(this.m_data.subType == "singlebloom" && this.m_data.type == "bloom")
            {
               this.m_singleBloomIcon.visible = true;
               this.m_fullBloomIcon.visible = false;
            }
            else if(this.m_data.subType == "fullbloom" && this.m_data.type == "bloom")
            {
               this.m_singleBloomIcon.visible = false;
               this.m_fullBloomIcon.visible = true;
            }
            else
            {
               this.m_singleBloomIcon.visible = false;
               this.m_fullBloomIcon.visible = false;
            }
         }
         if(this.m_buyCoinFrame.visible)
         {
            this.m_buyCashFrame.y = this.getCashFrameTop();
            this.adjustSendButtonPositionForMultipleCurrency();
         }
         else
         {
            this.m_buyCashFrame.y = this.getCashFrameBottom();
         }
         if(this.m_data.marketIsWorldCurrency && this.m_data.marketIsNectar)
         {
            this.m_buyCoinFrame.showNectarCurrencyIcon();
         }
         if(MarketFlashSaleManager.instance.isSaleActiveForItem(this.m_data))
         {
            this.m_buyCashFrame.cost = salePrice;
            this.m_buyCashFrame.visible = true;
            this.m_saleFrame.cost = this.m_data.cash;
            this.m_saleFrame.currency = Currency.CASH;
            this.m_saleFrame.setSaleTextField(ZLocUtils.t("Dialogs","Sale"));
            this.m_saleFrame.visible = true;
         }
         else if(this.m_data.isDealOfDaySaleItem)
         {
            if(DealOfDayHelper.getDealOfDayItemCurrency(this.m_data.code) == Currency.COINS)
            {
               this.m_buyCoinFrame.cost = this.m_data.saleCoins;
               this.m_buyCoinFrame.visible = true;
               this.m_buyCashFrame.visible = false;
               this.m_buyCoinFrame.setupLockState(this.m_data);
            }
            else if(DealOfDayHelper.getDealOfDayItemCurrency(this.m_data.code) == Currency.CASH)
            {
               this.m_buyCashFrame.cost = this.m_data.saleCash;
               this.m_buyCashFrame.visible = true;
               this.m_buyCoinFrame.visible = false;
               this.m_buyCashFrame.setupLockState(this.m_data);
            }
            if(this.m_data.buyableWithCurrency())
            {
               this.m_saleFrame.cost = coinPrice;
               this.m_saleFrame.currency = Currency.COINS;
               this.m_saleFrame.setSaleTextField(ZLocUtils.t("Dialogs","Sale"));
               this.m_saleFrame.visible = true;
            }
            else
            {
               this.m_saleFrame.cost = cashPrice;
               this.m_saleFrame.currency = Currency.CASH;
               this.m_saleFrame.setSaleTextField(ZLocUtils.t("Dialogs","Sale"));
               this.m_saleFrame.visible = true;
            }
         }
         else if(this.m_data.hasSale)
         {
            this.m_buyCashFrame.cost = salePrice;
            this.m_buyCashFrame.visible = true;
            this.m_saleFrame.currency = saleCurrency;
            managedSale = ManagedSalesManager.getSaleObject(this.m_data);
            if(this.m_data.hasSale)
            {
               this.m_saleFrame.cost = this.m_data.cash;
               this.m_saleFrame.currency = Currency.CASH;
            }
            this.m_saleFrame.setSaleTextField(ZLocUtils.t("Dialogs","Sale"));
            this.m_saleFrame.visible = true;
         }
         if(this.m_data.isLicenseGated && LicenseManager.getInstance().hasCurrentLicense(this.m_data.code))
         {
            this.m_buyCoinFrame.hasLicense = true;
            this.m_buyCoinFrame.visible = true;
            this.m_buyCashFrame.visible = false;
         }
      }
      
      protected function isPPHLimitedWorldExpansionItem(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         if(item.subType == "expand_farm")
         {
            if(Global.worldManager.currentWorldHasPlotLimits)
            {
               result = true;
            }
         }
         return result;
      }
      
      protected function generateExpansionMarketCardText(item:FarmItem) : String
      {
         var limitIndex:Object = null;
         var limitName:String = null;
         var key:String = null;
         var currentItemSquares:int = (item as ChangeFarmItem).squares;
         var plotLimitData:Array = Global.worldManager.getCurrentWorldPlotLimitsData();
         var currentWorld:String = Global.worldManager.currentWorldType;
         var cardText:String = ZLocUtils.t("Dialogs","FarmExpansionMarketCardText_Title");
         for(limitIndex in plotLimitData[currentItemSquares])
         {
            limitName = Global.worldManager.getLimitGroupNameByLimitGroupIndex(int(limitIndex));
            key = currentWorld + "_FarmExpansionMarketCardText_" + limitName;
            cardText += ZLocUtils.t("Dialogs",key,{"quantity":plotLimitData[currentItemSquares][int(limitIndex)]});
         }
         return cardText;
      }
      
      public function populateMarketVersionSpecificElements() : void
      {
         var primaryTerrainName:String = null;
         var toolTipText:String = null;
         this.setHarvestableGain(this.m_data);
         var terrainCodes:Array = this.m_data.getTerrainCodes();
         var invalidTerrainButtonCodes:Array = Global.farmGameSettingsManager.getTerrainCodes(FarmGameSettingsManager.TERRAIN_LAND);
         var hasInvalidCode:Boolean = TerrainUtil.intersectTerrainCodeArrays(terrainCodes,invalidTerrainButtonCodes);
         if(terrainCodes.length == 1 && !hasInvalidCode)
         {
            primaryTerrainName = Global.farmGameSettingsManager.getPrimaryTerrainNameFromCode(terrainCodes[0]);
            if(ZLocUtils.hasString("Dialogs","TerrainTooltipMessage_TerrainRestriction") && m_element.hasOwnProperty(primaryTerrainName + "_bt"))
            {
               if(this.m_terrainButton != null)
               {
                  this.m_terrainButton.visible = false;
               }
               if(getWidget(m_element[primaryTerrainName + "_bt"]) == null)
               {
                  this.m_terrainButton = addWidget(new FarmAnimatedTextButton(m_element[primaryTerrainName + "_bt"],"",this.onCallbackButtonClick),false) as FarmAnimatedTextButton;
                  this.m_terrainButton.attachTooltip(new MarketTooltip());
                  if(!this.m_data.expires)
                  {
                     toolTipText = ZLocUtils.t("Dialogs","TerrainTooltipMessage_TerrainRestriction_neverwither",{"terrain":FarmGameUtil.toUpperCaseFirst(primaryTerrainName)});
                  }
                  else
                  {
                     toolTipText = ZLocUtils.t("Dialogs","TerrainTooltipMessage_TerrainRestriction",{"terrain":FarmGameUtil.toUpperCaseFirst(primaryTerrainName)});
                  }
                  (this.m_terrainButton.tooltip as MarketTooltip).setText(toolTipText);
               }
               else
               {
                  this.m_terrainButton = getWidget(m_element[primaryTerrainName + "_bt"]) as FarmAnimatedTextButton;
               }
               this.m_terrainButton.visible = true;
            }
         }
         else if(this.m_terrainButton != null)
         {
            this.m_terrainButton.visible = false;
         }
         var seedItem:SeedItem = this.m_data as SeedItem;
         if(seedItem)
         {
            m_element.mastery_mc.goldFrame_mc.visible = seedItem.isSuperCrop();
         }
         if(!this.m_data.isDealOfDaySaleItem && this.m_data.hasSale)
         {
            this.m_saleFrame.y = this.m_buyCoinFrame.visible ? TOP_SALE_POSITION_Y : BOTTOM_SALE_POSITION_Y;
         }
      }
      
      protected function updateMastery() : void
      {
         var mastery:Mastery = (this.m_data as HarvestableItem).mastery;
         this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
         this.m_masteryFrame.visible = true;
      }
      
      protected function adjustSendButtonPositionForMultipleCurrency() : void
      {
      }
      
      protected function getCashFrameBottom() : int
      {
         return BOTTOM_BUY_POSITION_Y;
      }
      
      protected function getCashFrameTop() : int
      {
         return TOP_BUY_POSITION_Y;
      }
      
      public function get buyCashFrame() : MarketSlotCashBuyFrame
      {
         return this.m_buyCashFrame;
      }
      
      public function get buyCoinFrame() : MarketSlotCoinBuyFrame
      {
         return this.m_buyCoinFrame;
      }
      
      override public function populate(data:Object) : void
      {
         var titleKey:String = null;
         var tooltipText:String = null;
         var seedItem:SeedItem = null;
         var greenhouseSeedItem:GreenhouseSeedItem = null;
         var cardDescriptor:MarketCardDescriptor = null;
         var itemBuffs:Array = null;
         var iconText:String = null;
         var iconBrandText:String = null;
         var currentMasteryLevel:int = 0;
         var hasSeeds:Boolean = false;
         var missingReqs:Array = null;
         var isMissingNonSuperCropRequirement:Boolean = false;
         var missingRequirement:* = undefined;
         var changeFarmItem:ChangeFarmItem = null;
         var treeItem:TreeItem = null;
         var treeLevel:int = 0;
         var itemBuff:ItemBuff = null;
         var buff:IBPollinatedCrop = null;
         var pollinatedTooltipTextKey:String = null;
         var pollinatedTooltipText:String = null;
         var cardDescriptorName:String = null;
         var canvas:Graphics = null;
         var colors:Array = null;
         var alphas:Array = null;
         var ratios:Array = null;
         var i:int = 0;
         var matrixRotation:Number = NaN;
         var matrix:Matrix = null;
         super.populate(data);
         this.m_data = data as FarmItem;
         if(this.m_data)
         {
            this.populateMarketVersionSpecificElements();
            this.m_iconTooltip = this.m_icon.detachTooltip() as BrandedItemTooltip;
            this.m_iconTooltip = null;
            this.m_saleFrame.x = this.m_originalSaleFarmeX;
            this.m_saleFrame.y = this.m_originalSaleFarmeY;
            this.m_buyCashFrame.redeemable = false;
            if(this.m_buyCashFrame.redeemButton)
            {
               this.m_buyCashFrame.redeemButton.visible = false;
            }
            if(this.m_data.isBrandedItem && this.m_icon != null)
            {
               if(this.m_iconTooltip == null)
               {
                  iconText = ZLocUtils.t("Items","zap_tooltip_text_" + this.m_data.name);
                  iconBrandText = ZLocUtils.t("Items","zap_tooltip_branded_text_" + this.m_data.name);
                  this.m_iconTooltip = new BrandedItemTooltip(this.m_data.friendlyTitle,iconText,iconBrandText,this.m_data.iconUrl);
                  this.m_icon.attachTooltip(this.m_iconTooltip);
               }
            }
            this.m_icon.setIconSize(this.iconSize,this.iconSize);
            if(this.m_data.isVipItem())
            {
               currentMasteryLevel = (this.m_data as HarvestableItem).mastery.currentLevel;
               if(this.m_data.iconUrl.indexOf("animalsnew") >= 0)
               {
                  this.m_icon.loadIcon(VIP_ICON_URL_NEW + this.m_data.name + "_" + this.getIconSuffix(currentMasteryLevel + 1) + "_icon.png");
               }
               else
               {
                  this.m_icon.loadIcon(VIP_ICON_URL + this.m_data.name + "_" + this.getIconSuffix(currentMasteryLevel + 1) + "_icon.png");
               }
            }
            else if(this.m_data.iconUrl)
            {
               this.m_icon.loadIcon(this.m_data.iconUrl);
            }
            this.m_icon.visible = true;
            titleKey = ZLocUtils.hasString("Items",this.m_data.name + ALT_MARKET_TOKEN) ? "Items:" + this.m_data.name + ALT_MARKET_TOKEN : this.m_data.friendlyName;
            ZLocUtils.setTextAsTitle(m_element,"title_tf",titleKey);
            this.m_nameTextField.visible = true;
            if(this.isPPHLimitedWorldExpansionItem(this.m_data))
            {
               this.m_infoTextField.text = this.generateExpansionMarketCardText(this.m_data);
            }
            else
            {
               this.m_infoTextField.text = generateMarketCardInfoText(this.m_data);
            }
            this.m_infoTextField.visible = true;
            this.m_buyCashFrame.restoreDefaults();
            this.m_buyCoinFrame.restoreDefaults();
            this.m_buyCoinFrame.resetLockStates();
            this.m_buyCoinFrame.currencyType = this.m_data.market;
            tooltipText = this.m_data.getUsageDescription();
            if(this.m_infoTextField.text.length == 0 && tooltipText != null)
            {
               this.m_infoTextField.text = tooltipText;
               if(this.m_infoTextField.height > MAX_CARD_INFO_HEIGHT)
               {
                  this.m_infoTextField.text = "";
               }
               else
               {
                  tooltipText = "";
               }
            }
            seedItem = this.m_data as SeedItem;
            if(Boolean(seedItem) && seedItem.isSuperCrop())
            {
               hasSeeds = Global.player.seeds[seedItem.seedpackagecode] != null && Boolean(Global.player.seeds[seedItem.seedpackagecode].quantity);
               missingReqs = this.m_data.getLockedStates();
               if(missingReqs.indexOf(FarmItem.UNLOCKED) >= 0)
               {
                  if(hasSeeds)
                  {
                     this.m_inventoryFrame.update(Global.player.seeds[seedItem.seedpackagecode].quantity,false);
                     this.m_inventoryFrame.visible = true;
                  }
                  else
                  {
                     this.setupNormalSlot();
                  }
               }
               else
               {
                  isMissingNonSuperCropRequirement = false;
                  for each(missingRequirement in missingReqs)
                  {
                     if(!(missingRequirement is SuperCropRequirement))
                     {
                        isMissingNonSuperCropRequirement = true;
                        break;
                     }
                  }
                  if(isMissingNonSuperCropRequirement)
                  {
                     this.setupNormalSlot();
                  }
                  else
                  {
                     this.m_buyCashFrame.licensable = true;
                     this.m_buyCashFrame.cost = 0;
                     this.m_buyCashFrame.visible = true;
                     this.m_buyCashFrame.setLocked(false);
                     this.m_buyCashFrame.y = this.getCashFrameBottom();
                     this.m_buyCoinFrame.visible = false;
                     this.m_cashLicenseIcon.loadIcon(Global.getAssetURL(ICON_SUPER_CROP_LOCKED_URL));
                     this.m_cashLicenseIcon.visible = true;
                     this.m_inventoryFrame.visible = false;
                  }
               }
            }
            else if(Boolean(Global.flashHotParams["MARKET_SLOT_SEED_LICENSE_TEMPRT"] == true && seedItem) && Boolean(seedItem.seedpackage != null) && seedItem.isLicenseGated)
            {
               if(this.conditionallySetupForPackageSeedItem(seedItem) == false)
               {
                  this.setupForLicenseSeedItem(seedItem,tooltipText);
               }
            }
            else if(Boolean(seedItem) && seedItem.seedpackage != null)
            {
               this.conditionallySetupForPackageSeedItem(seedItem);
            }
            else if(Boolean(seedItem) && seedItem.isLicenseGated)
            {
               this.setupForLicenseSeedItem(seedItem,tooltipText);
            }
            else if(this.m_data is DecorationItem && Global.player.hasUnlimitedCredits(this.m_data.name))
            {
               this.m_inventoryFrame.update(0,false,true);
               this.m_inventoryFrame.visible = true;
            }
            else if(this.m_data is ChangeFarmItem && this.m_data.isLicenseGated && LicenseManager.getInstance().hasCurrentLicense(this.m_data.code))
            {
               changeFarmItem = this.m_data as ChangeFarmItem;
               this.m_buyCoinFrame.setupLockState(this.m_data);
               if(!this.m_buyCoinFrame.locked)
               {
                  this.m_inventoryFrame.update(0,false,true);
                  this.m_inventoryFrame.visible = true;
               }
            }
            else if(this.m_data is StencilPortalItem)
            {
               this.m_buyCashFrame.moreInfo = true;
               this.m_buyCashFrame.moreInfoText = "Open";
               this.m_buyCashFrame.cost = 0;
               this.m_buyCashFrame.y = this.getCashFrameBottom();
               this.m_buyCashFrame.visible = true;
            }
            else if(this.m_data is ExpansionAccessItem)
            {
               if(!Global.worldManager.hasUnlockedWorld((this.m_data as ExpansionAccessItem).worldType) && !Global.worldManager.accessExpansionTransactionInProgress())
               {
                  this.m_buyCashFrame.moreInfo = true;
                  this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardMoreInfoButton");
                  this.m_buyCashFrame.cost = 0;
                  this.m_buyCashFrame.y = this.getCashFrameBottom();
                  this.m_buyCashFrame.visible = true;
               }
            }
            else if(this.m_data is StarterPackItem)
            {
               this.m_buyCashFrame.moreInfo = true;
               this.m_buyCashFrame.cost = 0;
               this.m_buyCashFrame.y = this.getCashFrameBottom();
               this.m_buyCashFrame.visible = true;
               MarketStatsManager.countStarterPackMarketStat(StarterPackUtility.STARTER_PACK_MARKET_CARD_KINGDOM,StarterPackUtility.STARTER_PACK_MARKET_VIEW_PHYLUM);
            }
            else if(this.m_data is IUGCItem)
            {
               if(this.m_data.isLocked)
               {
                  this.m_buyCoinFrame.cost = 0;
                  this.m_buyCoinFrame.setupLockState(this.m_data);
                  this.m_buyCoinFrame.visible = true;
               }
               else
               {
                  this.m_buyCashFrame.moreInfo = true;
                  this.m_buyCashFrame.cost = 0;
                  this.m_buyCashFrame.y = this.getCashFrameBottom();
                  this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardCreateButton");
                  this.m_buyCashFrame.sendable = MarketWindow.isItemSendable(this.m_data);
                  this.m_buyCashFrame.visible = true;
                  this.m_buyCashFrame.setLocked(false);
               }
            }
            else if(this.m_data.promoMode != null && this.m_data.promoMode == "premiumBaby")
            {
               this.m_buyCashFrame.moreInfo = true;
               this.m_previewButton.visible = false;
               this.m_buyCashFrame.cost = Global.farmGameSettingsManager.getNumber(this.m_data.name + "_cash",2);
               this.m_buyCashFrame.setLocked(false);
               this.m_buyCashFrame.y = this.getCashFrameBottom();
               this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardButtonPremiumBaby");
               this.m_buyCashFrame.sendable = MarketWindow.isItemSendable(this.m_data);
               this.m_buyCashFrame.visible = true;
            }
            else if(MarketWindow.isItemRedeemable(this.m_data) || ItemMembershipManager.isInItemMembershipExperiment() && ItemMembershipManager.isItemRedeemable(this.m_data))
            {
               this.m_buyCashFrame.y = this.getCashFrameBottom();
               this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardCreateButton");
               this.m_buyCashFrame.sendable = false;
               this.m_buyCashFrame.redeemable = true;
               this.m_buyCashFrame.cost = 0;
               this.m_saleFrame.cost = this.m_data.cash;
               this.m_saleFrame.currency = Currency.CASH;
               this.m_saleFrame.setSaleTextField(ZLocUtils.t("Dialogs","Free"));
               this.m_saleFrame.visible = true;
               this.m_buyCashFrame.visible = true;
            }
            else
            {
               this.setupNormalSlot();
            }
            if(seedItem)
            {
               if(seedItem.isSuperCrop())
               {
                  this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardUnlock");
               }
               else
               {
                  this.m_buyCashFrame.moreInfoText = ZLocUtils.t("Dialogs","MarketCardMoreInfoButton");
               }
            }
            if(this.m_data.isNew)
            {
               this.m_newButton.visible = true;
               (this.m_newButton.tooltip as MarketTooltip).setText(tooltipText);
            }
            else if(this.m_data.hasWhatIsThis)
            {
               if(this.m_data.whatIsThisDialog)
               {
                  this.m_helpButton.visible = true;
               }
               else if(tooltipText)
               {
                  this.m_helpButton.visible = true;
                  (this.m_helpButton.tooltip as MarketTooltip).setText(tooltipText);
               }
            }
            if(this.m_data is HarvestableItem && (this.m_data as HarvestableItem).hasMastery)
            {
               this.updateMastery();
            }
            else if(this.m_data is ClothingItem)
            {
               this.m_previewButton.text = ZLocUtils.t("Dialogs","MarketCardTryOnButton");
               this.m_previewButton.visible = true;
            }
            else if(this.m_data.hasPreview)
            {
               this.m_previewButton.text = ZLocUtils.t("Dialogs","MarketCardPreviewButton");
               this.m_previewButton.visible = true;
            }
            if(this.m_data is TreeItem)
            {
               treeItem = this.m_data as TreeItem;
               if(treeItem.hasMastery)
               {
                  treeLevel = 1;
                  if(treeItem.nextLevel != null && treeItem.nextLevel == treeItem.code)
                  {
                     treeLevel = 2;
                  }
                  this.m_treeLevelFrame.treeLevel = treeLevel;
                  this.m_treeLevelFrame.visible = true;
               }
            }
            this.m_managedSale = ManagedSalesManager.getSaleObject(this.m_data);
            if(this.shouldShowLimitedItemTimer())
            {
               this.refreshLimitedTimerTextField();
            }
            else if(this.m_limitedTimer != null)
            {
               this.m_limitedTimer.stop();
            }
            if(this.shouldShowSaleItemTimer())
            {
               this.refreshSaleTimerTextField();
            }
            else if(this.m_saleTimer != null)
            {
               this.m_saleTimer.stop();
            }
            greenhouseSeedItem = this.m_data as GreenhouseSeedItem;
            if(greenhouseSeedItem != null)
            {
               this.m_limitedTimerTextField.text = greenhouseSeedItem.getBuyingMultipleText();
               this.m_limitedTimerTextField.visible = true;
               this.m_buyCoinFrame.cost *= GreenhouseSeedItem.NUM_SEEDS_IN_PACK;
               this.m_buyCoinFrame.setupLockState(this.m_data);
               this.m_buyCoinFrame.visible = true;
            }
            itemBuffs = ItemBuffManager.getInstance().getItemBuff("IBPollinatedCrop",this.m_data.code);
            if(itemBuffs.length > 0)
            {
               for each(itemBuff in itemBuffs)
               {
                  buff = new IBPollinatedCrop(itemBuff.buffName,itemBuff.buffItemCode,itemBuff.startTime);
                  if(!buff.hasExpired())
                  {
                     cardDescriptor = Global.marketConfigSettings.getMarketCardDescriptor("pollinated");
                     pollinatedTooltipTextKey = BushelReportActionDropHandler.canPlayerSeeFeature() ? "NewPollinatedBuffTimeRemaining" : "PollinatedBuffTimeRemaining";
                     pollinatedTooltipText = ZLocUtils.t("Dialogs",pollinatedTooltipTextKey,{"quantity":buff.daysRemaining()});
                     if(this.m_data.isNew)
                     {
                        this.m_newButton.visible = true;
                        (this.m_newButton.tooltip as MarketTooltip).setText(pollinatedTooltipText);
                     }
                     else
                     {
                        this.m_helpButton.visible = true;
                        (this.m_helpButton.tooltip as MarketTooltip).setText(pollinatedTooltipText);
                     }
                  }
               }
            }
            else if(this.m_data.isDealOfDaySaleItem)
            {
               cardDescriptorName = DealOfDayHelper.marketCardDescriptorName;
               cardDescriptor = Global.marketConfigSettings.getMarketCardDescriptor(cardDescriptorName);
            }
            else
            {
               cardDescriptor = this.m_data.marketCardDescriptor;
            }
            if(cardDescriptor)
            {
               if(Boolean(cardDescriptor.assetUrl) && Boolean(this.m_backgroundImage))
               {
                  this.m_backgroundImage.clearDimensions();
                  this.m_backgroundImage.loadIcon(cardDescriptor.assetUrl);
                  this.m_backgroundImage.visible = true;
               }
               else if(this.m_backgroundGradient)
               {
                  if(cardDescriptor.gradientColors)
                  {
                     canvas = this.m_backgroundGradient.graphics;
                     canvas.clear();
                     canvas.lineStyle(2,cardDescriptor.themeColor,1,true,LineScaleMode.NONE);
                     colors = cardDescriptor.gradientColors;
                     if(colors.length > 1)
                     {
                        alphas = [];
                        ratios = [];
                        for(i = 0; i < colors.length; i++)
                        {
                           alphas[i] = 1;
                           ratios[i] = Math.round(255 * (i / (colors.length - 1)));
                        }
                        matrixRotation = 90 * Math.PI / 180;
                        matrix = new Matrix();
                        matrix.createGradientBox(BACKGROUND_WIDTH,BACKGROUND_HEIGHT,matrixRotation,0,0);
                        canvas.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
                     }
                     else
                     {
                        canvas.beginFill(colors[0]);
                     }
                     canvas.drawRoundRect(0,0,BACKGROUND_WIDTH,BACKGROUND_HEIGHT,BACKGROUND_CORNER_RADIUS,BACKGROUND_CORNER_RADIUS);
                     this.m_backgroundGradient.visible = true;
                  }
                  else
                  {
                     this.m_backgroundGradient.visible = false;
                  }
               }
               if(!this.leForCharityOn() || !this.m_managedSale || !this.m_managedSale.isActive() || !this.m_buyCoinFrame.visible || this.isInActiveWorldSpecificSale || this.isInActiveCategorySpecificSale)
               {
                  if(cardDescriptor.name != MarketCardDescriptor.DEFAULT_NAME)
                  {
                     if(ZLocUtils.hasString("Dialogs",THEME_PREFIX + cardDescriptor.name))
                     {
                        this.m_themeTextField.text = ZLocUtils.t("Dialogs",THEME_PREFIX + cardDescriptor.name);
                        this.m_themeTextField.color = cardDescriptor.themeColor;
                        this.m_themeTextField.visible = true;
                     }
                  }
               }
            }
            if(this.m_charityLogo)
            {
               if(this.leForCharityOn())
               {
                  this.m_charityLogo.visible = true;
               }
               else
               {
                  this.m_charityLogo.visible = false;
               }
            }
            if(this.m_charityLogo_africa)
            {
               if(Boolean(this.m_data) && this.m_data.marketCardName == XAF_CHARITY)
               {
                  this.m_charityLogo_africa.visible = true;
               }
               else
               {
                  this.m_charityLogo_africa.visible = false;
               }
            }
         }
      }
      
      private function getIconSuffix(masteryLevel:int) : String
      {
         var iconSuffix:String = "";
         var frtString:String = "frt_";
         if(masteryLevel >= 0)
         {
            switch(masteryLevel)
            {
               case 0:
                  iconSuffix = frtString + DragonImageProgression.STATE_SMALL;
                  break;
               case 1:
                  iconSuffix = frtString + DragonImageProgression.STATE_ADULT;
                  break;
               case 2:
                  iconSuffix = frtString + DragonImageProgression.STATE_FIRE;
                  break;
               case 3:
                  iconSuffix = frtString + DragonImageProgression.STATE_WINGS;
            }
         }
         return iconSuffix;
      }
      
      private function leForCharityOn() : Boolean
      {
         var result:Boolean = false;
         if(MarketWindow.LE_FOR_CHARITY_VARIANT == Experiments.LE_FOR_CHARITY_ON && this.m_data.isCharityItem())
         {
            result = true;
         }
         return result;
      }
      
      private function conditionallySetupForPackageSeedItem(seedItem:SeedItem) : Boolean
      {
         var bMeetsRequirements:Boolean = false;
         var seedCount:Number = NaN;
         var isAcquireable:Boolean = false;
         var isShowingSeedPackage:Boolean = false;
         var seedPackageCode:String = seedItem.seedpackagecode;
         var seedPackage:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedPackageCode);
         if(seedPackage)
         {
            bMeetsRequirements = null == this.m_data.allMissingRequirements || this.m_data.allMissingRequirements.length == 0;
            if(bMeetsRequirements && Global.player.seeds[seedPackageCode] != null && Boolean(Global.player.seeds[seedPackageCode].quantity))
            {
               seedCount = Number(Global.player.seeds[seedPackageCode].quantity);
               isAcquireable = this.m_data.isLimited && this.m_data.limitedTimeLeft <= 0 || seedItem.isHybrid || Boolean(seedPackage) && Boolean(!seedPackage.canGetFromMarket()) ? false : true;
               this.m_inventoryFrame.update(seedCount,isAcquireable);
               this.m_inventoryFrame.visible = true;
               isShowingSeedPackage = true;
            }
            else if(seedItem.isHybrid)
            {
               this.m_inventoryFrame.update(0,false);
               this.m_inventoryFrame.visible = true;
               this.setupNormalSlot();
               isShowingSeedPackage = true;
            }
         }
         return isShowingSeedPackage;
      }
      
      private function setupForLicenseSeedItem(seedItem:SeedItem, tooltipText:String) : void
      {
         var licenseTooltip:MarketTooltip = null;
         if(LicenseManager.getInstance().hasCurrentLicense(this.m_data.code))
         {
            if(seedItem.donatable)
            {
               this.m_buyCoinFrame.cost = this.m_data.cost;
               this.m_buyCoinFrame.hasLicense = true;
               this.m_buyCoinFrame.visible = true;
            }
            else
            {
               this.m_buyCoinFrame.cost = this.m_data.cost;
               this.m_buyCoinFrame.visible = true;
               licenseTooltip = new MarketTooltip(" ",this.generateLicenseExpirationTooltip,1);
               this.m_buyCoinFrame.buyButton.attachTooltip(licenseTooltip);
               this.m_cashLicenseIcon.loadIcon(Global.getAssetURL(ICON_CASH_LICENSE_ACTIVE_URL));
               this.m_cashLicenseIcon.visible = true;
            }
         }
         else if(this.m_data.isBuyableLicense())
         {
            if(seedItem.donatable)
            {
               this.m_buyCoinFrame.donatable = true;
               this.m_buyCoinFrame.cost = this.m_data.cost;
               this.m_buyCoinFrame.visible = true;
            }
            else if(this.m_data.isLocked)
            {
               this.m_buyCoinFrame.cost = 0;
               this.m_buyCoinFrame.setupLockState(this.m_data);
               this.m_buyCoinFrame.visible = true;
            }
            else
            {
               this.m_buyCashFrame.licensable = true;
               this.m_buyCashFrame.cost = this.m_data.licenseCost;
               this.m_buyCashFrame.y = this.getCashFrameBottom();
               this.m_buyCashFrame.visible = true;
               this.m_cashLicenseIcon.loadIcon(Global.getAssetURL(ICON_CASH_LICENSE_EXPIRED_URL));
               this.m_cashLicenseIcon.visible = true;
            }
            if(this.m_data.isBerryBuyableLicense())
            {
               this.m_buyCashFrame.showBerryLicenseIcon();
            }
         }
         else if(null != this.m_data.allMissingRequirements && this.m_data.allMissingRequirements.length > 0)
         {
            this.m_buyCoinFrame.setLocked(true,tooltipText);
            this.m_buyCoinFrame.visible = true;
         }
      }
      
      private function generateLicenseExpirationTooltip() : String
      {
         var licenseTimeLeft:Number = LicenseManager.getInstance().getLicenseExpirationTime(this.m_data.code) - GlobalEngine.serverTime / 1000;
         return ZLocUtils.t("Dialogs","MarketCardLicenseExpiration",{"timeStr":FarmGameUtil.toFriendlyTime(licenseTimeLeft)});
      }
      
      private function onCallbackButtonClick(evt:MouseEvent) : void
      {
         var callbackName:String = null;
         var callback:Function = null;
         var callbackButton:MovieClip = evt.target as MovieClip;
         switch(callbackButton)
         {
            case this.m_buyCashFrame.buyButton.element:
               callbackName = MarketWindow.CALLBACK_BUY_CASH;
               break;
            case this.m_buyCashFrame.moreInfoButton.element:
               callbackName = MarketWindow.CALLBACK_MORE_INFO;
               break;
            case this.m_buyCashFrame.playButton.element:
               callbackName = MarketWindow.CALLBACK_PLAY;
               break;
            case this.m_buyCashFrame.sendButton.element:
               callbackName = MarketWindow.CALLBACK_SEND;
               break;
            case this.m_buyCashFrame.redeemButton.element:
               callbackName = MarketWindow.CALLBACK_REDEEM;
               break;
            case this.m_buyCoinFrame.donateButton.element:
               callbackName = MarketWindow.CALLBACK_DONATE;
               break;
            case this.m_buyCoinFrame.buyButton.element:
               callbackName = MarketWindow.CALLBACK_BUY_COIN;
               break;
            case this.m_buyCoinFrame.actionButton.element:
               callbackName = MarketWindow.CALLBACK_UNLOCK;
               break;
            case this.m_buyCoinFrame.unlockButton.element:
               callbackName = MarketWindow.CALLBACK_LOCK_EXPLANATION;
               break;
            case this.m_inventoryFrame.getButton.element:
               callbackName = MarketWindow.CALLBACK_GET;
               break;
            case this.m_inventoryFrame.useButton.element:
               callbackName = MarketWindow.CALLBACK_USE;
               break;
            case this.m_previewButton.element:
               callbackName = MarketWindow.CALLBACK_PREVIEW;
               break;
            case this.m_helpButton.element:
               callbackName = MarketWindow.CALLBACK_HELP;
               break;
            case this.m_buyCashFrame.travelButton.element:
            case this.m_buyCoinFrame.travelButton.element:
               callbackName = MarketWindow.CALLBACK_TRAVEL_WORLD;
         }
         if(callbackName)
         {
            callback = this.m_callbacks[callbackName] as Function;
            if(callback != null)
            {
               callback(this);
            }
         }
      }
      
      private function onLimitedTimer(event:TimerEvent) : void
      {
         this.refreshLimitedTimerTextField();
      }
      
      private function onSaleTimer(event:TimerEvent) : void
      {
         this.refreshSaleTimerTextField();
      }
      
      private function refreshLimitedTimerTextField() : void
      {
         var itemLicense:ItemLicense = null;
         var showingLimitedQuantity:Boolean = false;
         var limitedTimeLeft:Number = 0;
         if(this.m_data.isLEItem())
         {
            limitedTimeLeft = this.m_data.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
            itemLicense = this.m_data.itemLicense;
            if(itemLicense != null && LicenseManager.getInstance().hasCurrentLicense(this.m_data.code))
            {
               limitedTimeLeft = LicenseManager.getInstance().getTimeLeftToExpiration(this.m_data.code);
            }
         }
         var parsedTime:Array = FarmGameUtil.parseTimeLeft(limitedTimeLeft);
         this.m_limitedTimerTextField.text = FarmGameUtil.getFormattedTimeLeftText(parsedTime);
         if(!showingLimitedQuantity && parsedTime[0] <= 0)
         {
            if(this.m_limitedTimer == null)
            {
               this.m_limitedTimer = new Timer(1000);
               this.m_limitedTimer.addEventListener(TimerEvent.TIMER,this.onLimitedTimer,false,0,true);
            }
            if(!this.m_limitedTimer.running)
            {
               this.m_limitedTimer.start();
            }
         }
         else if(this.m_limitedTimer != null)
         {
            this.m_limitedTimer.stop();
         }
      }
      
      private function refreshSaleTimerTextField() : void
      {
         var showingLimitedQuantity:Boolean = false;
         var limitedTimeLeft:Number = 0;
         var managedSale:ManagedSale = ManagedSalesManager.getSaleObject(this.m_data);
         var worldSalePrice:int = 100000;
         var managedSalePrice:int = 100000;
         var categorySalePrice:int = 100000;
         if(this.isInActiveWorldSpecificSale)
         {
            worldSalePrice = Global.worldSpecificSalesManager.price(this.m_data.cash);
         }
         if(this.isInActiveCategorySpecificSale)
         {
            categorySalePrice = Global.categorySpecificSalesManager.price(this.m_data.cash);
         }
         if(Boolean(managedSale) && managedSale.isActive())
         {
            managedSalePrice = managedSale.price;
         }
         var minPrice:int = Math.min(worldSalePrice,Math.min(managedSalePrice,categorySalePrice));
         if(minPrice != 100000 && minPrice == worldSalePrice)
         {
            limitedTimeLeft = Global.worldSpecificSalesManager.timeLeft;
         }
         else if(minPrice != 100000 && minPrice == managedSalePrice)
         {
            limitedTimeLeft = managedSale.timeLeft;
         }
         else if(minPrice != 100000 && minPrice == categorySalePrice)
         {
            limitedTimeLeft = Global.categorySpecificSalesManager.timeLeft;
         }
         if(this.m_data.isDealOfDaySaleItem)
         {
            limitedTimeLeft = DealOfDayHelper.getDealOfDayItemTimeLeft(this.m_data.code);
         }
         var parsedTime:Array = FarmGameUtil.parseTimeLeft(limitedTimeLeft);
         this.m_saleTimerTextField.text = FarmGameUtil.getFormattedTimeLeftText(parsedTime);
         if(limitedTimeLeft < 0 && this.m_data.isDealOfDaySaleItem)
         {
            if(this.m_buyCoinFrame.visible)
            {
               this.m_buyCoinFrame.buyButton.enabled = false;
            }
            else
            {
               this.m_buyCashFrame.buyButton.enabled = false;
            }
            this.m_saleTimerTextField.text = ZLocUtils.t("Dialogs","TimeLeftSuffix",{"timeStr":"0:00:00"});
            this.m_saleTimerTextField.visible = true;
         }
         else if(limitedTimeLeft < 0 || isNaN(limitedTimeLeft))
         {
            this.m_saleTimerTextField.text = "";
            this.m_saleTimerTextField.visible = false;
         }
         else
         {
            this.m_saleTimerTextField.visible = true;
         }
         if(!showingLimitedQuantity && parsedTime[0] <= 0)
         {
            if(this.m_saleTimer == null)
            {
               this.m_saleTimer = new Timer(1000);
               this.m_saleTimer.addEventListener(TimerEvent.TIMER,this.onSaleTimer,false,0,true);
            }
            if(!this.m_saleTimer.running)
            {
               this.m_saleTimer.start();
            }
         }
         else if(this.m_saleTimer != null)
         {
            this.m_saleTimer.stop();
         }
      }
      
      public function refresh() : void
      {
         this.populate(this.m_data);
      }
      
      override public function release() : void
      {
         if(this.m_saleTimer != null)
         {
            this.m_saleTimer.removeEventListener(TimerEvent.TIMER,this.onSaleTimer);
         }
         this.m_saleTimer = null;
         if(this.m_limitedTimer != null)
         {
            this.m_limitedTimer.removeEventListener(TimerEvent.TIMER,this.onLimitedTimer);
         }
         this.m_limitedTimer = null;
         if(this.m_charityLogo != null)
         {
            this.m_charityLogo = null;
         }
         if(this.m_charityLogo_africa != null)
         {
            this.m_charityLogo_africa = null;
         }
         this.m_callbacks = null;
         this.m_container = null;
         this.m_data = null;
         this.m_backgroundGradient = null;
         this.m_backgroundImage = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_infoTextField = null;
         this.m_themeTextField = null;
         this.m_limitedTimerTextField = null;
         this.m_saleTimerTextField = null;
         this.m_buyCashFrame = null;
         this.m_buyCoinFrame = null;
         this.m_inventoryFrame = null;
         this.m_masteryFrame = null;
         this.m_treeLevelFrame = null;
         this.m_saleFrame = null;
         this.m_helpButton = null;
         this.m_newButton = null;
         this.m_previewButton = null;
         this.m_singleBloomIcon = null;
         this.m_fullBloomIcon = null;
         super.release();
      }
      
      protected function get limitedTimerText() : String
      {
         return this.m_limitedTimerTextField.text;
      }
      
      protected function get saleTimerText() : String
      {
         return this.m_saleTimerTextField.text;
      }
      
      protected function shouldShowLimitedItemTimer() : Boolean
      {
         var isLE:Boolean = false;
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_OPTIM_SORTING) == 2)
         {
            isLE = this.m_data.isLEItem();
         }
         else
         {
            isLE = this.m_data.isLimitedItem();
         }
         return isLE;
      }
      
      protected function shouldShowSaleItemTimer() : Boolean
      {
         return this.m_managedSale && this.m_managedSale.isActive() || this.m_data.isDealOfDaySaleItem || this.isInActiveWorldSpecificSale || this.isInActiveCategorySpecificSale;
      }
      
      public function get isInActiveWorldSpecificSale() : Boolean
      {
         return Global.worldSpecificSalesManager.isActive() && Global.worldSpecificSalesManager.inSale(this.m_data);
      }
      
      public function get isInActiveCategorySpecificSale() : Boolean
      {
         return Global.categorySpecificSalesManager.isActive() && Global.categorySpecificSalesManager.inSale(this.m_data);
      }
      
      public function get worldType() : String
      {
         var worldType:String = this.m_buyCoinFrame.worldType;
         if(this.m_buyCashFrame.visible)
         {
            worldType = this.m_buyCashFrame.worldType;
         }
         return worldType;
      }
      
      public function set worldType(value:String) : void
      {
         if(this.m_buyCashFrame.worldType)
         {
            this.m_buyCashFrame.worldType = value;
         }
         if(this.m_buyCoinFrame.worldType)
         {
            this.m_buyCoinFrame.worldType = value;
         }
      }
      
      public function removeTooltip() : void
      {
         var tooltip:MarketTooltip = null;
         if(this.m_buyCashFrame.visible)
         {
            if(this.m_buyCashFrame.travelButton.tooltip)
            {
               (this.m_buyCashFrame.travelButton.tooltip as MarketTooltip).setText("");
               tooltip = this.m_buyCashFrame.travelButton.detachTooltip() as MarketTooltip;
            }
         }
         else if(this.m_buyCoinFrame.travelButton.tooltip)
         {
            (this.m_buyCoinFrame.travelButton.tooltip as MarketTooltip).setText("");
            tooltip = this.m_buyCoinFrame.travelButton.detachTooltip() as MarketTooltip;
         }
         if(tooltip)
         {
            tooltip.detach();
            tooltip.release();
            tooltip = null;
         }
      }
   }
}

