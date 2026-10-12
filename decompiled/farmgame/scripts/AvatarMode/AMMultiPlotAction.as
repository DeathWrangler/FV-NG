package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Doobers.DooberRewardViewController;
   import Classes.Equipment;
   import Classes.FarmGameObject;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.util.WorldIdUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import GameMode.GMCombineAll;
   import Managers.CrossPromoManager;
   import Managers.DailyStatsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.RetentionMasterManager;
   import Transactions.TEquipmentAction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BushelReportWindow;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import gs.TweenLite;
   
   public class AMMultiPlotAction extends AMActionState
   {
      
      protected static const STATUS_ENERGY_SOURCE_FUEL:String = "fuel";
      
      protected static const STATUS_ENERGY_SOURCE_FREE_FUEL:String = "freefuel";
      
      protected static const STATUS_ENERGY_SOURCE_SUPERAVATAR:String = "superavatar";
      
      protected static const RESOURCE_FADE_ALPHA:Number = 0.6;
      
      protected var m_plots:Array = [];
      
      protected var m_equipment:Equipment;
      
      protected var m_centerPos:Point;
      
      protected var m_validPlotsBundle:Object = {};
      
      public function AMMultiPlotAction(avatar:FarmAvatar, plots:Array, centerPos:Point)
      {
         super(avatar,null);
         this.m_plots = plots;
         this.m_centerPos = centerPos;
      }
      
      override public function getNumActions() : int
      {
         return this.m_plots.length;
      }
      
      override public function added() : void
      {
         super.added();
         this.fadeAndLockResources(true);
      }
      
      override public function removed() : void
      {
         super.removed();
         this.fadeAndLockResources(false);
         this.show();
      }
      
      protected function fadeAndLockResources(onOff:Boolean, noFade:Boolean = false) : void
      {
         var plot:Plot = null;
         var fadeAlpha:Number = 1;
         if(onOff && !noFade)
         {
            fadeAlpha = RESOURCE_FADE_ALPHA;
         }
         for(var plotIdx:int = 0; plotIdx < this.m_plots.length; plotIdx++)
         {
            plot = this.m_plots[plotIdx] as Plot;
            plot.setAlpha(fadeAlpha);
            if(onOff)
            {
               plot.lock();
            }
            else
            {
               plot.unlock();
            }
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         this.hide();
      }
      
      override public function reenter() : void
      {
         super.reenter();
         this.hide();
      }
      
      protected function hide() : void
      {
         TweenLite.to(m_avatar,0.25,{"alpha":0});
      }
      
      protected function show() : void
      {
         TweenLite.to(m_avatar,0.25,{"alpha":1});
      }
      
      override protected function getActionDistance() : Number
      {
         return -1;
      }
      
      protected function multiPlow(energySource:int, plots:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true) : int
      {
         var plotEnergy:int = 0;
         var currentPlot:Plot = null;
         var limitGroupNames:String = null;
         var cost:int = 0;
         var tweenDisplacement:int = 0;
         var worldPlotCostData:Object = null;
         var numPlowed:int = 0;
         var totalEnergy:int = 0;
         var totalXP:int = 0;
         var preActionPlotItems:Object = this.tryToGetPreActionPlotItems(sendTransaction,plots);
         var numPlots:int = int(this.m_plots.length);
         for(var plotIdx:int = 0; plotIdx < numPlots; plotIdx++)
         {
            plotEnergy = this.getEnergyForPlot(plotIdx);
            currentPlot = this.m_plots[plotIdx] as Plot;
            if(Boolean(currentPlot) && currentPlot.plow(energySource,plotEnergy,false,false,false))
            {
               if(0 == currentPlot.getId())
               {
                  currentPlot.setId(WorldIdUtil.getNewTempId());
                  this.m_validPlotsBundle[plotIdx] = currentPlot.getSaveObject();
               }
               else
               {
                  this.m_validPlotsBundle[plotIdx] = {
                     "id":currentPlot.getId(),
                     "position":currentPlot.getPosition()
                  };
               }
               numPlowed++;
               totalEnergy += plotEnergy;
               totalXP += currentPlot.lastPlowYield;
            }
         }
         if(numPlowed > 0 && sendTransaction)
         {
            limitGroupNames = "";
            if(this.m_equipment)
            {
               limitGroupNames = this.m_equipment.getLimitGroupNamesForStatHit();
            }
            FarmStatsManager.count("farm_world_actions","plow","Plot","plow_" + limitGroupNames + "vehicle",numPlowed.toString());
            TransactionManager.addTransaction(new TEquipmentAction(TEquipmentAction.ACTION_PLOW,this.m_equipment,this.m_validPlotsBundle,Plot.STATE_PLOWED,preActionPlotItems));
         }
         var crossPromoManager:CrossPromoManager = CrossPromoManager.getInstance();
         crossPromoManager.notifyFuelUse(totalEnergy);
         if(numPlowed > 0)
         {
            cost = Global.farmGameSettingsManager.getInt("plowCost");
            tweenDisplacement = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
            if(!sendTransaction)
            {
               tweenDisplacement *= 2;
            }
            worldPlotCostData = Plot.getWorldPlowPlotCostData();
            if(!RetentionMasterManager.shouldSuppressHarvestStatusText() || this is AMTractorPlow && Global.flashHotParams["HOOBER_FLYOUT_REDUCE"] == false)
            {
               displayStatusTarget.displayStatus(ZLocUtils.t("FarmGame","Status_PlowPlotEnergy_" + statusKeySuffix,{
                  "coinNum":cost * numPlowed,
                  "currency":ZLocUtils.t("FarmGame",worldPlotCostData.currencyUnit),
                  "fuelNum":totalEnergy,
                  "xpNum":totalXP
               }),"",null,UI.DEFAULT_STATUS_TWEEN_DURATION,tweenDisplacement);
            }
         }
         return numPlowed;
      }
      
      protected function multiPlotRemove(energySource:int, plots:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true) : int
      {
         var plotEnergy:int = 0;
         var currentPlot:Plot = null;
         var limitGroupNames:String = null;
         var cost:int = 0;
         var tweenDisplacement:int = 0;
         var worldPlotCostData:Object = null;
         var numPlowed:int = 0;
         var totalEnergy:int = 0;
         var totalXP:int = 0;
         var preActionPlotItems:Object = this.tryToGetPreActionPlotItems(sendTransaction,plots);
         var numPlots:int = int(this.m_plots.length);
         for(var plotIdx:int = 0; plotIdx < numPlots; plotIdx++)
         {
            plotEnergy = this.getEnergyForPlot(plotIdx);
            currentPlot = this.m_plots[plotIdx] as Plot;
            if(Boolean(currentPlot) && currentPlot.remove(energySource,plotEnergy,false,false,false))
            {
               if(0 == currentPlot.getId())
               {
                  currentPlot.setId(WorldIdUtil.getNewTempId());
                  this.m_validPlotsBundle[plotIdx] = currentPlot.getSaveObject();
               }
               else
               {
                  this.m_validPlotsBundle[plotIdx] = {
                     "id":currentPlot.getId(),
                     "position":currentPlot.getPosition()
                  };
               }
               numPlowed++;
               totalEnergy += plotEnergy;
               totalXP += currentPlot.lastPlowYield;
            }
         }
         if(numPlowed > 0 && sendTransaction)
         {
            limitGroupNames = "";
            if(this.m_equipment)
            {
               limitGroupNames = this.m_equipment.getLimitGroupNamesForStatHit();
            }
            FarmStatsManager.count("farm_world_actions","plotRemove","PlotRemove","plotRemove_" + limitGroupNames + "vehicle",numPlowed.toString());
            TransactionManager.addTransaction(new TEquipmentAction(TEquipmentAction.ACTION_PLOTREMOVE,this.m_equipment,this.m_validPlotsBundle,Plot.STATE_PLOWED,preActionPlotItems));
         }
         var crossPromoManager:CrossPromoManager = CrossPromoManager.getInstance();
         crossPromoManager.notifyFuelUse(totalEnergy);
         if(numPlowed > 0)
         {
            cost = Global.farmGameSettingsManager.getInt("plowCost");
            tweenDisplacement = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
            if(!sendTransaction)
            {
               tweenDisplacement *= 2;
            }
            worldPlotCostData = Plot.getWorldPlowPlotCostData();
            if(!RetentionMasterManager.shouldSuppressHarvestStatusText() || this is AMTractorPlow && Global.flashHotParams["HOOBER_FLYOUT_REDUCE"] == false)
            {
               displayStatusTarget.displayStatus(ZLocUtils.t("FarmGame","Status_PlowPlotEnergy_" + statusKeySuffix,{
                  "coinNum":cost * numPlowed,
                  "currency":ZLocUtils.t("FarmGame",worldPlotCostData.currencyUnit),
                  "fuelNum":totalEnergy,
                  "xpNum":totalXP
               }),"",null,UI.DEFAULT_STATUS_TWEEN_DURATION,tweenDisplacement);
            }
         }
         return numPlowed;
      }
      
      protected function multiPlant(energySource:int, seed:FarmItem, plots:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true) : int
      {
         var seedItem:SeedItem = null;
         var currentPlot:Plot = null;
         var hasSeedPackage:Boolean = false;
         var lockedStates:Array = null;
         var kickOut:Boolean = false;
         var plotEnergy:int = 0;
         var isLastPlot:Boolean = false;
         var currentPlotId:Number = NaN;
         var isTempId:Boolean = false;
         var hasSeedPackageProperty:Boolean = false;
         var hasHybridProperty:Boolean = false;
         var limitGroupNames:String = null;
         var cost:int = 0;
         var worldPlotCostData:Object = null;
         var currencyUnit:String = null;
         var numPlotsSeeded:int = 0;
         var totalEnergy:int = 0;
         var totalXP:int = 0;
         var preActionPlotItems:Object = this.tryToGetPreActionPlotItems(sendTransaction,plots);
         var useOriginalSeed:Boolean = false;
         if(seed != null)
         {
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(seed.name) as SeedItem;
         }
         else if(sendTransaction === false)
         {
            useOriginalSeed = true;
         }
         var plotsLen:uint = this.m_plots.length;
         for(var plotIdx:int = 0; plotIdx < plotsLen; plotIdx++)
         {
            currentPlot = this.m_plots[plotIdx] as Plot;
            if(currentPlot)
            {
               if(useOriginalSeed)
               {
                  seed = currentPlot.getItem();
                  seedItem = Global.farmGameSettingsManager.getFarmItemByName(seed.name) as SeedItem;
               }
               hasSeedPackage = Boolean(seedItem.seedpackage) && Global.player.hasSeed(seedItem.name);
               lockedStates = seed.getLockedStates(seed);
               kickOut = false;
               if(lockedStates.indexOf(FarmItem.UNLOCKED) >= 0 || hasSeedPackage)
               {
                  plotEnergy = this.getEnergyForPlot(plotIdx);
                  isLastPlot = plotIdx + 1 == plotsLen;
                  if(currentPlot.plant(seed.name,energySource,plotEnergy,false,false,false,isLastPlot))
                  {
                     currentPlotId = currentPlot.getId();
                     isTempId = false;
                     if(currentPlotId >= WorldIdUtil.TEMP_ID_START)
                     {
                        isTempId = true;
                     }
                     this.m_validPlotsBundle[plotIdx] = {
                        "id":currentPlot.getId(),
                        "position":currentPlot.getPosition(),
                        "itemRef":currentPlot,
                        "tempId":isTempId
                     };
                     numPlotsSeeded++;
                     totalEnergy += plotEnergy;
                     totalXP += currentPlot.lastPlantYield;
                     hasSeedPackageProperty = false;
                     hasHybridProperty = false;
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        hasSeedPackage = seedItem.hasPropertyInDataSource("seedpackage");
                        hasHybridProperty = seedItem.hasPropertyInDataSource("isHybrid");
                     }
                     else
                     {
                        hasSeedPackageProperty = seedItem.xml.hasOwnProperty("seedpackage");
                        hasHybridProperty = seedItem.xml.hasOwnProperty("@isHybrid");
                     }
                     if(hasSeedPackageProperty && !Global.player.hasSeed(seed.name) && !(hasHybridProperty || seedItem.isSuperCrop()))
                     {
                        kickOut = true;
                     }
                  }
                  else
                  {
                     kickOut = true;
                  }
               }
               else
               {
                  kickOut = true;
               }
               if(kickOut)
               {
                  abortActions();
                  break;
               }
            }
         }
         if(numPlotsSeeded > 0 && sendTransaction)
         {
            limitGroupNames = "";
            if(this.m_equipment)
            {
               limitGroupNames = this.m_equipment.getLimitGroupNamesForStatHit();
            }
            FarmStatsManager.count("farm_world_actions","plant","Plot","plant_" + limitGroupNames + "vehicle",numPlotsSeeded.toString());
            TransactionManager.addTransaction(new TEquipmentAction(TEquipmentAction.ACTION_PLANT,this.m_equipment,this.m_validPlotsBundle,seed.name,preActionPlotItems,numPlotsSeeded));
         }
         var crossPromoManager:CrossPromoManager = CrossPromoManager.getInstance();
         crossPromoManager.notifyFuelUse(totalEnergy);
         if(numPlotsSeeded > 0)
         {
            cost = seed.cost;
            worldPlotCostData = Plot.getWorldPlowPlotCostData();
            currencyUnit = seedItem.market ? seedItem.market : Currency.COINS;
            if(!RetentionMasterManager.shouldSuppressHarvestStatusText() || this is AMSeeder && !(this is AMCombine) && Global.flashHotParams["HOOBER_FLYOUT_REDUCE"] == false)
            {
               displayStatusTarget.displayStatus(ZLocUtils.t("FarmGame","Status_PlowPlotEnergy_" + statusKeySuffix,{
                  "coinNum":cost * numPlotsSeeded,
                  "currency":ZLocUtils.t("FarmGame",currencyUnit),
                  "fuelNum":totalEnergy,
                  "xpNum":totalXP
               }));
            }
         }
         BushelReportWindow.conditionallyRefreshWindow();
         return numPlotsSeeded;
      }
      
      protected function multiHarvest(energySource:int, plots:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, sendTransaction:Boolean = true, refreshBushelWindow:Boolean = true) : int
      {
         var type:String = null;
         var plot:Plot = null;
         var plotEnergy:int = 0;
         var currentPlot:Plot = null;
         var currentPlotId:Number = NaN;
         var isTempId:Boolean = false;
         var harvestDropOff:Object = null;
         var currency:String = null;
         var limitGroupNames:String = null;
         var iconUrl:String = null;
         var iconFilters:Array = null;
         var tweenDuration:Number = NaN;
         var tweenDisplacement:int = 0;
         var harvestedItemMsg:String = null;
         var harvestStatus:Object = null;
         var numHarvested:int = 0;
         var numPlotsHarvested:int = 0;
         var total:int = 0;
         var totalXp:int = 0;
         var totalEnergy:int = 0;
         var totalMastery:int = 0;
         var totalHarvestedItems:int = 0;
         var preActionPlotItems:Object = this.tryToGetPreActionPlotItems(sendTransaction,plots);
         var numPlots:int = int(plots.length);
         var totalHarvestYields:Dictionary = new Dictionary();
         DooberRewardViewController.willHarvestNumPlots(numPlots);
         for(var plotIdx:int = 0; plotIdx < numPlots; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            plotEnergy = this.getEnergyForPlot(plotIdx);
            if(plot.harvest(energySource,plotEnergy,false,false))
            {
               currentPlot = this.m_plots[plotIdx] as Plot;
               currentPlotId = currentPlot.getId();
               isTempId = false;
               if(currentPlotId >= WorldIdUtil.TEMP_ID_START)
               {
                  isTempId = true;
               }
               this.m_validPlotsBundle[plotIdx] = {
                  "id":currentPlot.getId(),
                  "position":currentPlot.getPosition(),
                  "itemRef":this.m_plots[plotIdx],
                  "tempId":isTempId
               };
               numHarvested++;
               harvestDropOff = plot.doHarvestDropOff(m_avatar,false);
               total += int(harvestDropOff.coinYield) * Global.player.getWorldCurrencyMultiplier(Currency.COINS);
               totalXp += int(harvestDropOff.xpYield);
               totalHarvestedItems += int(harvestDropOff.numHarvestedItems);
               if(harvestDropOff.canEarnMasteryPoints)
               {
                  totalMastery += int(harvestDropOff.masteryYield);
               }
               numPlotsHarvested++;
               totalEnergy += plotEnergy;
               for(currency in harvestDropOff.harvestYields)
               {
                  if(totalHarvestYields[currency] == null)
                  {
                     totalHarvestYields[currency] = harvestDropOff.harvestYields[currency];
                  }
                  else
                  {
                     totalHarvestYields[currency] += harvestDropOff.harvestYields[currency];
                  }
               }
            }
         }
         DooberRewardViewController.flushQueuedDoobers();
         DooberRewardViewController.setPlotsPerDooberAmount(1);
         totalEnergy = plotEnergy * numHarvested;
         if(numHarvested > 0 && sendTransaction)
         {
            limitGroupNames = "";
            if(this.m_equipment)
            {
               limitGroupNames = this.m_equipment.getLimitGroupNamesForStatHit();
            }
            FarmStatsManager.count("farm_world_actions","harvest","Plot","harvest_" + limitGroupNames + "vehicle",numPlotsHarvested.toString());
            TransactionManager.addTransaction(new TEquipmentAction(TEquipmentAction.ACTION_HARVEST,this.m_equipment,this.m_validPlotsBundle,Plot.STATE_PLOWED,preActionPlotItems));
         }
         if(numHarvested > 0)
         {
            DailyStatsManager.getInstance().incrementCounter(DailyStatsManager.SOURCE_CROP,DailyStatsManager.ACTION_HARVEST,numPlotsHarvested);
         }
         var crossPromoManager:CrossPromoManager = CrossPromoManager.getInstance();
         crossPromoManager.notifyFuelUse(totalEnergy);
         var statusMessage:String = "";
         var harvestYieldString:String = "";
         for(type in totalHarvestYields)
         {
            harvestYieldString += "+";
            harvestYieldString += Math.floor(totalHarvestYields[type]);
            harvestYieldString += " ";
            harvestYieldString += ZLocUtils.t("FarmGame",type);
            harvestYieldString += " ";
         }
         harvestYieldString = ZLocUtils.t("FarmGame","Status_HarvestYieldStyling",{"status":harvestYieldString});
         statusMessage += harvestYieldString;
         if(totalXp > 0)
         {
            if(total > 0)
            {
               if(totalMastery > 0)
               {
                  statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergyCoinsXPMastery_" + statusKeySuffix,{
                     "fuelNum":totalEnergy,
                     "coinNum":total,
                     "xpNum":totalXp,
                     "masteryNum":totalMastery
                  });
               }
               else
               {
                  statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergyCoinsXP_" + statusKeySuffix,{
                     "fuelNum":totalEnergy,
                     "coinNum":total,
                     "xpNum":totalXp
                  });
               }
            }
            else if(totalMastery > 0)
            {
               statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergyXPMastery_" + statusKeySuffix,{
                  "xpNum":totalXp,
                  "fuelNum":totalEnergy,
                  "masteryNum":totalMastery
               });
            }
            else
            {
               statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergyXP_" + statusKeySuffix,{
                  "xpNum":totalXp,
                  "fuelNum":totalEnergy
               });
            }
         }
         else if(total > 0)
         {
            if(totalMastery > 0)
            {
               statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergyMastery_" + statusKeySuffix,{
                  "fuelNum":totalEnergy,
                  "coinNum":total,
                  "masteryNum":totalMastery
               });
            }
            else
            {
               statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotEnergy_" + statusKeySuffix,{
                  "fuelNum":totalEnergy,
                  "coinNum":total
               });
            }
         }
         if(statusMessage != null)
         {
            iconUrl = "";
            iconFilters = [];
            tweenDuration = UI.DEFAULT_STATUS_TWEEN_DURATION;
            tweenDisplacement = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
            if(totalHarvestedItems > 0)
            {
               harvestStatus = plot.getHarvestProduceStatusData(totalHarvestedItems);
               harvestedItemMsg = harvestStatus.message;
               iconUrl = harvestStatus.iconUrl;
               iconFilters = harvestStatus.iconFilters;
               tweenDuration = Number(harvestStatus.tweenDuration);
               tweenDisplacement = int(harvestStatus.tweenDisplacement);
            }
            if(harvestedItemMsg != null)
            {
               statusMessage += "\n" + harvestedItemMsg;
            }
            if(!sendTransaction)
            {
               tweenDisplacement *= 3;
            }
            if(!RetentionMasterManager.shouldSuppressHarvestStatusText())
            {
               displayStatusTarget.displayStatus(statusMessage,iconUrl,iconFilters,tweenDuration,tweenDisplacement);
            }
         }
         if(refreshBushelWindow && BushelReportWindow.isWindowOpen())
         {
            Global.ui.bushelReportWindow.refreshWindow();
         }
         return numPlotsHarvested;
      }
      
      protected function multiCombine(energySource:int, seed:FarmItem, plots:Array, displayStatusTarget:FarmGameObject, statusKeySuffix:String, deductTurbo:Boolean = true, sendTransaction:Boolean = true) : int
      {
         var limitGroupNames:String = null;
         var validPlotsBundle:Object = {};
         var numPlotsHarvested:int = 0;
         var numPlotsPlowed:int = 0;
         var numPlotsSeeded:int = 0;
         var numPlotChanges:int = 0;
         var numTurbosConsumed:int = 0;
         if(deductTurbo && plots.length > this.m_equipment.getActionSize().x * this.m_equipment.getActionSize().y)
         {
            numTurbosConsumed = GMCombineAll.getTotalTurboChargersConsumed();
         }
         var preActionPlotItems:Object = this.getPreActionPlotItemsList(plots);
         numPlotsHarvested = this.multiHarvest(energySource,plots,displayStatusTarget,statusKeySuffix,false,false);
         numPlotsPlowed = this.multiPlow(energySource,plots,displayStatusTarget,statusKeySuffix,false);
         numPlotsSeeded = this.multiPlant(energySource,seed,plots,displayStatusTarget,statusKeySuffix,false);
         if(numPlotsHarvested > 0 || numPlotsPlowed > 0 || numPlotsSeeded > 0)
         {
            limitGroupNames = "";
            if(this.m_equipment)
            {
               limitGroupNames = this.m_equipment.getLimitGroupNamesForStatHit();
            }
            if(sendTransaction)
            {
               FarmStatsManager.count("farm_world_actions","combine","Plot","combine_" + limitGroupNames + "vehicle",numPlotsSeeded.toString());
               TransactionManager.addTransaction(new TEquipmentAction(TEquipmentAction.ACTION_COMBINE,this.m_equipment,this.m_validPlotsBundle,seed.name,preActionPlotItems,numPlotsSeeded,numTurbosConsumed));
            }
         }
         return int(numPlotsHarvested + numPlotsSeeded + numPlotsPlowed);
      }
      
      protected function getEnergyForPlot(plotIndex:int) : int
      {
         return 0;
      }
      
      protected function getPreActionPlotItemsList(plots:Array, fixState:String = null) : Object
      {
         var plot:Plot = null;
         var plotState:String = null;
         var preActionPlotItems:Object = new Object();
         for each(plot in plots)
         {
            plotState = plot.getState();
            if(fixState)
            {
               plotState = fixState;
            }
            if(!preActionPlotItems.hasOwnProperty(plotState))
            {
               preActionPlotItems[plotState] = new Dictionary();
            }
            preActionPlotItems[plotState][plot] = plot.getItem();
         }
         return preActionPlotItems;
      }
      
      private function tryToGetPreActionPlotItems(getItems:Boolean, plots:Array) : Object
      {
         return getItems == true ? this.getPreActionPlotItemsList(plots) : null;
      }
   }
}

