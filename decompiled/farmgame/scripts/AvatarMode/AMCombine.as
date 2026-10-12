package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Combine;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.CrossPromoManager;
   import Widgets.Constants.Market.Currency;
   import flash.geom.Point;
   
   public class AMCombine extends AMSeeder
   {
      
      private static const FUEL_USE_MULTIPLIER_HARVESTABLE:int = 3;
      
      private static const FUEL_USE_MULTIPLIER_PLOWABLE:int = 2;
      
      private static const FUEL_USE_MULTIPLIER_PLANTABLE:int = 1;
      
      public function AMCombine(avatar:FarmAvatar, plots:Array, combine:Combine, centerPos:Point, seed:FarmItem)
      {
         super(avatar,plots,combine,centerPos,seed);
      }
      
      override public function enter() : void
      {
         super.enter();
         var fuelRequired:int = this.calculateFuelRequired(m_plots);
         if(this.canCombineAllWithCurrency(m_plots))
         {
            if(!Global.player.hasEnergy(fuelRequired))
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_FUEL,"impulseBuyVehicle");
               m_avatar.getStateMachine().removeMachineStates();
            }
         }
         else
         {
            m_avatar.getStateMachine().removeMachineStates();
         }
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var statusKeySuffix:String = null;
         var numSeeded:int = 0;
         var crossPromoManager:CrossPromoManager = null;
         if(m_equipment != null && m_equipment.isAttached() == true)
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plantTime");
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  statusKeySuffix = Global.player.hasNoFuelDayActive() ? AMMultiPlotAction.STATUS_ENERGY_SOURCE_FREE_FUEL : AMMultiPlotAction.STATUS_ENERGY_SOURCE_FUEL;
                  numSeeded = multiCombine(HarvestableResource.ENERGY_SOURCE_FUEL,m_seed,m_plots,m_actionEquipment,statusKeySuffix);
                  if(!Global.player.hasEnergy())
                  {
                     crossPromoManager = CrossPromoManager.getInstance();
                     crossPromoManager.notifyBeginOutBoundPromo("use_x_fuel");
                  }
                  m_avatar.getStateMachine().removeState(this);
                  if(numSeeded == 0 && 0 == !Global.player.hasEnergy())
                  {
                     UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_FUEL,"impulseBuyVehicle");
                     m_avatar.getStateMachine().removeMachineStates();
                  }
               }
               else
               {
                  m_actionEquipment.setActionProgress(ZLocUtils.t("FarmGame","Farming"),progress);
               }
            }
         }
         else
         {
            m_avatar.displayStatus(ZLocUtils.t("FarmGame","NeedCombine"));
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      private function canCombineAllWithCurrency(plots:Array) : Boolean
      {
         var plot:Plot = null;
         var currencyUnit:String = null;
         var result:Boolean = true;
         var plowAllPlotsCost:int = 0;
         var worldPlotCostData:Object = Plot.getWorldPlowPlotCostData();
         var plantAllPlotsCost:int = 0;
         var cost:int = m_seed.cost;
         for(var plotIndex:int = 0; plotIndex < plots.length; plotIndex++)
         {
            plot = plots[plotIndex] as Plot;
            if(plot.isHarvestable() || plot.isPlowable() || plot.isPlantable())
            {
               plowAllPlotsCost += worldPlotCostData.cost;
               plantAllPlotsCost += cost;
            }
         }
         var worldPlotCurrencyUnit:String = worldPlotCostData.currencyUnit;
         var canPlowAllPlots:Boolean = Global.player.canBuyWithCurrency(worldPlotCurrencyUnit,plowAllPlotsCost,true,"Plowing");
         var canPlantAllPlots:Boolean = false;
         if(canPlowAllPlots)
         {
            currencyUnit = m_seed.market ? m_seed.market : Currency.COINS;
            canPlantAllPlots = Global.player.canBuyWithCurrency(currencyUnit,plantAllPlotsCost);
         }
         return canPlowAllPlots && canPlantAllPlots;
      }
      
      private function calculateFuelRequired(plots:Array) : int
      {
         var perPlotEnergy:int = 0;
         var plot:Plot = null;
         var result:int = 0;
         for(var plotIndex:int = 0; plotIndex < plots.length; plotIndex++)
         {
            perPlotEnergy = getEnergyForPlot(plotIndex);
            plot = plots[plotIndex] as Plot;
            if(plot)
            {
               if(plot.isGrown())
               {
                  result += perPlotEnergy * FUEL_USE_MULTIPLIER_HARVESTABLE;
               }
               else if(plot.isPlowable())
               {
                  result += perPlotEnergy * FUEL_USE_MULTIPLIER_PLOWABLE;
               }
               else if(plot.isPlantable())
               {
                  result += perPlotEnergy * FUEL_USE_MULTIPLIER_PLANTABLE;
               }
            }
         }
         return result;
      }
   }
}

