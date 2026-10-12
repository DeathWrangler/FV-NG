package Widgets.Slots.Market
{
   import Classes.DealOfDayHelper;
   import Classes.ManagedSale;
   import Classes.Mastery;
   import Classes.Plot;
   import Classes.ZItem.ClothingItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.ItemLicense;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.ExperimentManager;
   import Managers.FarmGameSettingsManager;
   import Managers.LicenseManager;
   import Managers.ManagedSalesManager;
   import Managers.RewardCardsManager;
   import Widgets.Frames.Market.Market3SlotMasteryFrame;
   import Widgets.Frames.Market.Market3SlotOrganicFrame;
   import Widgets.Frames.Market.MarketSlotFrame;
   import Widgets.Frames.Market.MarketSlotItemStatFrame;
   import Widgets.Frames.Market.MarketSlotItemTimerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.Market.MarketTooltip;
   import ZLocalization.Utilities;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class Market3Slot extends MarketSlot
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static var BUY_BUTTON_OFFSET:int = 18;
      
      private static const NUM_ITEM_STATS:int = 4;
      
      private static const ITEM_STATS_ICON_PREFIX:String = "assets/consumables/";
      
      private static const MAX_CARD_INFO_HEIGHT:int = 85;
      
      private static const REDEEM_TEXT_X_OFFSET:int = 100;
      
      private static const SALE_Y_PADDING:int = 5;
      
      private var m_itemStats:Array;
      
      private var m_masteryFrame:Market3SlotMasteryFrame;
      
      private var m_organicFrame:Market3SlotOrganicFrame;
      
      private var m_limitedTimerFrame:MarketSlotItemTimerFrame;
      
      private var m_saleTimerFrame:MarketSlotItemTimerFrame;
      
      private var m_topLeftIcon:FarmIcon;
      
      public function Market3Slot(element:DisplayObject, container:MarketSlotFrame, callbacks:Object)
      {
         var statFrameName:String = null;
         this.m_itemStats = new Array();
         super(element,container,callbacks);
         for(var i:int = 0; i < NUM_ITEM_STATS; i++)
         {
            statFrameName = "stat_" + i + "_mc";
            this.m_itemStats.push(addWidget(new MarketSlotItemStatFrame(m_element[statFrameName])));
         }
         if(m_element.expiration_mc)
         {
            this.m_limitedTimerFrame = addWidget(new MarketSlotItemTimerFrame(m_element.expiration_mc,this.onLETimerMouseOver,this.onLETimerMouseOut)) as MarketSlotItemTimerFrame;
         }
         if(m_element.sale_mc)
         {
            this.m_saleTimerFrame = addWidget(new MarketSlotItemTimerFrame(m_element.saleExpiration_mc,this.onSaleTimerMouseOver,this.onSaleTimerMouseOut)) as MarketSlotItemTimerFrame;
         }
         if(m_element.newIcon_mc)
         {
            this.m_topLeftIcon = addWidget(new FarmIcon(m_element.newIcon_mc)) as FarmIcon;
         }
         this.m_masteryFrame = addWidget(new Market3SlotMasteryFrame(m_element.mastery_mc)) as Market3SlotMasteryFrame;
         if(ExperimentManager.isOrganicMainExperimentOn() && m_element.hasOwnProperty("organic_mc"))
         {
            this.m_organicFrame = addWidget(new Market3SlotOrganicFrame(m_element.organic_mc)) as Market3SlotOrganicFrame;
         }
         m_previewButton.attachTooltip(new MarketTooltip());
      }
      
      override public function release() : void
      {
         this.m_topLeftIcon = null;
         this.m_masteryFrame = null;
         this.m_organicFrame = null;
         this.m_limitedTimerFrame = null;
         this.m_saleTimerFrame = null;
         super.release();
      }
      
      override protected function initializeMarketVersionSpecificElements() : void
      {
      }
      
      override public function get iconSize() : int
      {
         return ICON_SIZE;
      }
      
      override protected function updateMastery() : void
      {
         var mastery:Mastery = (m_data as HarvestableItem).mastery;
         this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
         this.m_masteryFrame.visible = true;
      }
      
      protected function updateOrganic() : void
      {
         var progress:int = 0;
         var total:int = 0;
         if(m_data.hasOwnProperty("code") && m_data.hasOwnProperty("organicTotal"))
         {
            progress = int(Global.player.organicCounters[m_data.code]);
            total = (m_data as HarvestableItem).organicTotal;
            if(progress > total)
            {
               progress = total;
            }
            if(this.m_organicFrame)
            {
               this.m_organicFrame.update(progress,total);
               this.m_organicFrame.visible = true;
            }
         }
      }
      
      private function setupItemStats(item:FarmItem) : void
      {
         var index:int = 0;
         index = this.setItemHarvestTimeStat(item,index);
         index = this.setItemXPGainStat(item,index);
         index = this.setItemHarvestYieldStat(item,index);
         item.hasStats = index > 0;
      }
      
      private function setItemHarvestTimeStat(farmItem:FarmItem, statIndex:int) : int
      {
         var harvestTime:Number = NaN;
         var harvestLocStr:String = null;
         var harvestTooltipLocString:String = null;
         var tooltipText:String = null;
         var harvestTimeStr:String = null;
         var statFrame:MarketSlotItemStatFrame = null;
         var iconURL:String = null;
         var dayInSeconds:Number = NaN;
         var timeString:String = null;
         var harvestText:String = "";
         var item:HarvestableItem = farmItem as HarvestableItem;
         if(Boolean(item) && item.growTime > 0)
         {
            harvestTime = item.growTime;
            harvestLocStr = "";
            harvestTooltipLocString = "";
            tooltipText = "";
            harvestTimeStr = "";
            if(harvestTime < 1)
            {
               dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
               if(harvestTime < 1 / FarmGameUtil.NUM_HOURS_IN_DAY)
               {
                  timeString = "Minute";
                  harvestTime = dayInSeconds / FarmGameUtil.NUM_SECS_IN_MINUTE * harvestTime;
               }
               else
               {
                  timeString = "Hour";
                  harvestTime = dayInSeconds / FarmGameUtil.NUM_SECS_IN_MINUTE / FarmGameUtil.NUM_MINUTES_IN_HOUR * harvestTime;
               }
               harvestLocStr = "Growth" + timeString + "sTime";
               harvestTimeStr = harvestTime.toFixed(0);
               harvestText = ZLocUtils.t("Dialogs",harvestLocStr,{
                  "quantity":harvestTimeStr,
                  "Hour_word":ZLocUtils.tk("Dialogs",timeString + "_word","",harvestTime)
               });
               harvestTooltipLocString = "Growth" + timeString + "sSentence";
               tooltipText = ZLocUtils.t("Dialogs",harvestTooltipLocString,{
                  "quantity":harvestTimeStr,
                  "Hour_word":ZLocUtils.tk("Dialogs",timeString + "_word","",harvestTime)
               });
            }
            else
            {
               harvestLocStr = "GrowthDaysTime";
               harvestTimeStr = harvestTime.toString();
               harvestText = ZLocUtils.t("Dialogs",harvestLocStr,{
                  "quantity":harvestTimeStr,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",harvestTime)
               });
               harvestTooltipLocString = "GrowthDaysSentence";
               tooltipText = ZLocUtils.t("Dialogs",harvestTooltipLocString,{
                  "quantity":harvestTimeStr,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",harvestTime)
               });
            }
            statFrame = this.m_itemStats[statIndex];
            statFrame.visible = true;
            statFrame.infoText = harvestText;
            iconURL = ITEM_STATS_ICON_PREFIX + "consume_harvestClock_icon_30.png";
            statFrame.loadIcon(iconURL);
            statFrame.detachTooltip();
            statFrame.attachTooltip(new FarmTextTooltip(tooltipText));
            statIndex++;
         }
         return statIndex;
      }
      
      private function setItemXPGainStat(item:FarmItem, statIndex:int) : int
      {
         var itemCode:String = null;
         var itemXml:XML = null;
         var plantXpYield:int = item.plantXp;
         if(ExperimentManager.isOrganicMainExperimentOn())
         {
            itemCode = item.code;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(Global.player.isItemOrganicCertifiedData(item,itemCode))
               {
                  plantXpYield *= Plot.ORGANIC_MULT;
               }
            }
            else
            {
               itemXml = item.xml;
               if(Global.player.isItemOrganicCertified(itemXml,itemCode))
               {
                  plantXpYield *= Plot.ORGANIC_MULT;
               }
            }
         }
         var statFrame:MarketSlotItemStatFrame = this.m_itemStats[statIndex];
         statFrame.detachTooltip();
         var iconURL:String = "";
         var tooltipText:String = "";
         var tooltipLocString:String = "GainQuantity";
         if(item.buyWorldScore > 0)
         {
            statFrame.visible = true;
            statFrame.infoText = item.buyWorldScore.toString();
            iconURL = ITEM_STATS_ICON_PREFIX + "consume_" + item.buyWorldScoreUnit + "_icon_30.png";
            statFrame.loadIcon(iconURL);
            tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
               "quantity":item.buyWorldScore.toString(),
               "unit":ZLocUtils.tk("Dialogs",item.buyWorldScoreUnit)
            });
            statIndex++;
         }
         else if(plantXpYield > 0)
         {
            statFrame.visible = true;
            statFrame.infoText = plantXpYield.toString();
            iconURL = ITEM_STATS_ICON_PREFIX + "consume_xp_icon_30.png";
            statFrame.loadIcon(iconURL);
            tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
               "quantity":plantXpYield.toString(),
               "unit":ZLocUtils.tk("Dialogs","xp")
            });
            statIndex++;
         }
         else if(item.xpGained > 0)
         {
            statFrame.visible = true;
            statFrame.infoText = item.xpGained.toString();
            iconURL = ITEM_STATS_ICON_PREFIX + "consume_xp_icon_30.png";
            statFrame.loadIcon(iconURL);
            tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
               "quantity":item.xpGained.toString(),
               "unit":ZLocUtils.tk("Dialogs","xp")
            });
            statIndex++;
         }
         if(tooltipText != "")
         {
            statFrame.attachTooltip(new FarmTextTooltip(tooltipText));
         }
         return statIndex;
      }
      
      private function setItemHarvestYieldStat(farmItem:FarmItem, statIndex:int) : int
      {
         var harvestYieldObject:Object = null;
         var coinYield:int = 0;
         var nectarGain:int = 0;
         var statFrame:MarketSlotItemStatFrame = null;
         var tooltipLocString:String = null;
         var tooltipText:String = null;
         var itemCode:String = null;
         var itemXml:XML = null;
         var iconURL:String = "";
         var item:HarvestableItem = farmItem as HarvestableItem;
         if(Boolean(item) && item.growTime > 0)
         {
            harvestYieldObject = getHarvestYieldObject(item);
            coinYield = int(harvestYieldObject.coinYield);
            if(ExperimentManager.isOrganicMainExperimentOn())
            {
               itemCode = farmItem.code;
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(Global.player.isItemOrganicCertifiedData(farmItem,itemCode))
                  {
                     coinYield *= Plot.ORGANIC_MULT;
                  }
               }
               else
               {
                  itemXml = farmItem.xml;
                  if(Global.player.isItemOrganicCertified(itemXml,itemCode))
                  {
                     coinYield *= Plot.ORGANIC_MULT;
                  }
               }
            }
            nectarGain = item.nectarGain;
            statFrame = this.m_itemStats[statIndex];
            tooltipLocString = "GainQuantity";
            tooltipText = "";
            statFrame.detachTooltip();
            if(harvestYieldObject.goldYield > 0)
            {
               statFrame.visible = true;
               statFrame.infoText = Utilities.formatNumber(harvestYieldObject.goldYield);
               iconURL = ITEM_STATS_ICON_PREFIX + "consume_coins_icon_30.png";
               statFrame.loadIcon(iconURL);
               tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
                  "quantity":Utilities.formatNumber(harvestYieldObject.goldYield),
                  "unit":ZLocUtils.tk("Dialogs","coins")
               });
               statIndex++;
            }
            else if(coinYield > 0)
            {
               statFrame.visible = true;
               statFrame.infoText = Utilities.formatNumber(coinYield);
               iconURL = ITEM_STATS_ICON_PREFIX + "consume_coins_icon_30.png";
               statFrame.loadIcon(iconURL);
               tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
                  "quantity":Utilities.formatNumber(coinYield),
                  "unit":ZLocUtils.tk("Dialogs","coins")
               });
               statIndex++;
            }
            if(tooltipText != "")
            {
               statFrame.attachTooltip(new FarmTextTooltip(tooltipText));
            }
            statFrame = this.m_itemStats[statIndex];
            statFrame.detachTooltip();
            if(harvestYieldObject.worldCurrencyYield > 0)
            {
               statFrame.visible = true;
               statFrame.infoText = Utilities.formatNumber(harvestYieldObject.worldCurrencyYield);
               iconURL = ITEM_STATS_ICON_PREFIX + "consume_" + Global.worldManager.currentWorldCurrency + "_icon_30.png";
               statFrame.loadIcon(iconURL);
               tooltipText = ZLocUtils.t("Dialogs",tooltipLocString,{
                  "quantity":Utilities.formatNumber(harvestYieldObject.worldCurrencyYield),
                  "unit":ZLocUtils.tk("Dialogs",Global.worldManager.currentWorldCurrency)
               });
               statFrame.attachTooltip(new FarmTextTooltip(tooltipText));
               statIndex++;
            }
            if(nectarGain > 0)
            {
               statFrame.visible = true;
               statFrame.infoText = Utilities.formatNumber(nectarGain);
               iconURL = ITEM_STATS_ICON_PREFIX + "nectar.png";
               statFrame.loadIcon(iconURL);
               tooltipText = ZLocUtils.t("Dialogs","GainNectar",{"quantity":Utilities.formatNumber(nectarGain)});
               statFrame.attachTooltip(new FarmTextTooltip(tooltipText));
               statIndex++;
            }
         }
         return statIndex;
      }
      
      override public function populateMarketVersionSpecificElements() : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         var text:String = null;
         var numDays:int = 0;
         var url:String = null;
         var regionData:String = null;
         var regionPrefixStartPosition:int = 0;
         var regionName:String = null;
         super.populate(data);
         var tooltip:MarketTooltip = null;
         if(m_icon.tooltip)
         {
            tooltip = m_icon.tooltip as MarketTooltip;
         }
         else if(m_previewButton.tooltip)
         {
            tooltip = m_previewButton.tooltip as MarketTooltip;
         }
         if(tooltip)
         {
            tooltip.setText("");
         }
         m_previewButton.visible = false;
         m_previewButton.enabled = false;
         if(m_data is ClothingItem || m_data.hasPreview)
         {
            m_previewButton.visible = true;
            m_previewButton.enabled = true;
         }
         else
         {
            m_icon.attachTooltip(new MarketTooltip());
         }
         m_infoTextField.text = "";
         m_infoTextField.visible = false;
         this.setupItemStats(m_data);
         if(isPPHLimitedWorldExpansionItem(m_data))
         {
            m_infoTextField.text = generateExpansionMarketCardText(m_data);
         }
         else
         {
            this.showWhatIsThis(m_data);
         }
         if(!m_data.hasStats)
         {
            m_infoTextField.visible = true;
         }
         if(shouldShowLimitedItemTimer())
         {
            text = limitedTimerText;
            url = this.timerIcon;
            if(Boolean(text) && Boolean(text != "") && Boolean(url))
            {
               this.m_limitedTimerFrame.text = limitedTimerText;
               this.m_limitedTimerFrame.loadIcon(this.timerIcon);
               numDays = int(FarmGameUtil.parseTimeLeft(this.leTimerTimeLeft)[0]);
               this.m_limitedTimerFrame.toggleTextVisibility(false);
               if(numDays >= 0 && numDays <= 3)
               {
                  this.m_limitedTimerFrame.toggleTextVisibility(true);
               }
               this.m_limitedTimerFrame.visible = true;
            }
         }
         else
         {
            regionData = m_data.getRegionLogoUrlFromActiveData();
            if(regionData != "")
            {
               regionPrefixStartPosition = regionData.lastIndexOf("regionIcon");
               regionName = regionData.substr(regionPrefixStartPosition);
               regionName = regionName.substr(0,regionName.indexOf(".png")) + "_fullName";
               this.m_limitedTimerFrame.text = ZLocUtils.t("Dialogs",regionName);
               this.m_limitedTimerFrame.loadIcon(regionData);
               this.m_limitedTimerFrame.toggleTextVisibility(false);
               this.m_limitedTimerFrame.visible = true;
            }
         }
         if(shouldShowSaleItemTimer())
         {
            text = saleTimerText;
            url = ITEM_STATS_ICON_PREFIX + "consume_sale_30.png";
            if(Boolean(text) && Boolean(text != "") && Boolean(url))
            {
               this.m_saleTimerFrame.text = saleTimerText;
               numDays = int(FarmGameUtil.parseTimeLeft(this.saleTimerTimeLeft)[0]);
               this.m_saleTimerFrame.toggleTextVisibility(false);
               if(numDays >= 0 && numDays <= 3 && !m_data.isLEItem())
               {
                  this.m_saleTimerFrame.toggleTextVisibility(true);
               }
               this.m_saleTimerFrame.visible = true;
            }
         }
         m_saleFrame.enableSaleText();
         if(RewardCardsManager.getInstance().isRewardCardsActive() && Boolean(RewardCardsManager.getInstance().getRedeemableRewardCard(m_data)))
         {
            m_saleFrame.x = m_originalSaleFarmeX + REDEEM_TEXT_X_OFFSET;
         }
         else
         {
            m_saleFrame.disableIcons();
            m_saleFrame.y = m_buyCoinFrame.visible ? this.getCashFrameTop() - SALE_Y_PADDING : this.getCashFrameBottom() - SALE_Y_PADDING;
         }
         if(ExperimentManager.isOrganicMainExperimentOn() && m_data is HarvestableItem && (m_data as HarvestableItem).hasOrganic)
         {
            this.updateOrganic();
         }
      }
      
      override protected function getCashFrameBottom() : int
      {
         return m_buyCoinFrame.y;
      }
      
      override protected function getCashFrameTop() : int
      {
         return m_buyCoinFrame.y - BUY_BUTTON_OFFSET;
      }
      
      override protected function adjustSendButtonPositionForMultipleCurrency() : void
      {
         m_buyCashFrame.sendButton.y += BUY_BUTTON_OFFSET;
         m_buyCashFrame.sendButton.recalculateTransforms();
      }
      
      private function get saleTimerTimeLeft() : Number
      {
         var limitedTimeLeft:Number = 0;
         var managedSale:ManagedSale = ManagedSalesManager.getSaleObject(m_data);
         var worldSalePrice:int = 100000;
         var managedSalePrice:int = 100000;
         var categorySalePrice:int = 100000;
         if(isInActiveWorldSpecificSale)
         {
            worldSalePrice = Global.worldSpecificSalesManager.price(m_data.cash);
         }
         if(isInActiveCategorySpecificSale)
         {
            categorySalePrice = Global.categorySpecificSalesManager.price(m_data.cash);
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
         if(m_data.isDealOfDaySaleItem)
         {
            limitedTimeLeft = DealOfDayHelper.getDealOfDayItemTimeLeft(m_data.code);
         }
         return limitedTimeLeft;
      }
      
      private function get leTimerTimeLeft() : Number
      {
         var itemLicense:ItemLicense = null;
         var limitedTimeLeft:Number = 0;
         if(m_data.isLEItem())
         {
            limitedTimeLeft = m_data.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
            itemLicense = m_data.itemLicense;
            if(itemLicense != null && LicenseManager.getInstance().hasCurrentLicense(m_data.code))
            {
               limitedTimeLeft = LicenseManager.getInstance().getTimeLeftToExpiration(m_data.code);
            }
         }
         return limitedTimeLeft;
      }
      
      private function get timerIcon() : String
      {
         var iconURL:String = null;
         if(m_data.isLEItem())
         {
            iconURL = ITEM_STATS_ICON_PREFIX + "consume_expire_30.png";
         }
         return iconURL;
      }
      
      private function showWhatIsThis(item:FarmItem) : void
      {
         var tooltipText:String = item.getUsageDescription();
         if(tooltipText != null && tooltipText != "")
         {
            m_infoTextField.text = tooltipText;
            if(!m_data.hasStats)
            {
               if(m_infoTextField.height > MAX_CARD_INFO_HEIGHT)
               {
                  m_infoTextField.text = "";
               }
               else
               {
                  tooltipText = "";
               }
            }
            if(m_icon.tooltip)
            {
               (m_icon.tooltip as MarketTooltip).setText(tooltipText);
            }
            else if(m_previewButton.tooltip)
            {
               (m_previewButton.tooltip as MarketTooltip).setText(tooltipText);
            }
         }
      }
      
      private function onSaleTimerMouseOver(event:MouseEvent) : void
      {
         this.m_saleTimerFrame.toggleTextVisibility(true);
      }
      
      private function onLETimerMouseOver(event:MouseEvent) : void
      {
         this.m_limitedTimerFrame.toggleTextVisibility(true);
      }
      
      private function onSaleTimerMouseOut(event:MouseEvent) : void
      {
         var numDays:int = int(FarmGameUtil.parseTimeLeft(this.saleTimerTimeLeft)[0]);
         if(numDays > 3 || m_data.isLEItem())
         {
            this.m_saleTimerFrame.toggleTextVisibility(false);
         }
      }
      
      private function onLETimerMouseOut(event:MouseEvent) : void
      {
         var numDays:int = int(FarmGameUtil.parseTimeLeft(this.leTimerTimeLeft)[0]);
         if(numDays > 3 || !m_data.isLEItem() && m_data.getRegionLogoUrlFromActiveData() != "")
         {
            this.m_limitedTimerFrame.toggleTextVisibility(false);
         }
      }
   }
}

