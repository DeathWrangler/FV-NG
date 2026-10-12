package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Combine;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Display.TurboPPHDialog;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import flash.geom.Point;
   
   public class GMCombineAll extends GMCombine
   {
      
      private var m_validPlots:Array = [];
      
      public function GMCombineAll(seed:FarmItem, combine:Combine = null)
      {
         super(seed,combine);
         var allplots:Array = Global.world.getObjectsByClass(Plot);
         if(seed.seedpackagecode != null && Global.player.seeds[seed.seedpackagecode] != null && Global.player.seeds[seed.seedpackagecode].quantity > 0 && allplots.length > Global.player.seeds[seed.seedpackagecode].quantity)
         {
            this.m_validPlots = this.getPlotsWithConstraints(allplots);
         }
         else
         {
            this.determineValidPlots();
         }
         this.performResourceCheck();
      }
      
      public static function getTotalTurboChargersConsumed() : int
      {
         var plot:Plot = null;
         var cost:int = 0;
         var harvest:Boolean = false;
         var plow:Boolean = false;
         var allplots:Array = Global.world.getObjectsByClass(Plot);
         for each(plot in allplots)
         {
            if(plot.isHarvestable())
            {
               harvest = true;
               plow = true;
               break;
            }
            if(plot.isPlowable())
            {
               plow = true;
            }
         }
         cost = 1;
         if(harvest)
         {
            cost++;
         }
         if(plow)
         {
            cost++;
         }
         return cost;
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         super.addAvatarState(avatar,plots,centerPos);
         m_cursorImage = null;
         UI.removeAllCursors();
         Global.world.popGameMode();
         Global.world.addGameMode(new GMDefault());
      }
      
      override protected function getValidPlots() : Array
      {
         var result:Array = [];
         if(isMouseOverValidPlot())
         {
            result = this.m_validPlots;
         }
         return result;
      }
      
      override protected function performResourceCheck() : Boolean
      {
         var missingReqs:Array = null;
         var tempSeeds:int = 0;
         var result:Boolean = true;
         var energyCount:int = this.m_validPlots.length * m_equipment.getEnergyCost();
         if(!Global.player.hasEnoughTurbos(getTotalTurboChargersConsumed()))
         {
            TurboPPHDialog.showOutOfTurbosDialog(TurboPPHDialog.ACTION_COMBINE,outOfTurbosDialogHandler);
            result = false;
         }
         else if(!m_fuelOverride && !Global.player.hasEnergy(energyCount))
         {
            TurboPPHDialog.showOutOfFuelDialog(TurboPPHDialog.ACTION_COMBINE,outOfFuelDialogHandler);
            result = false;
         }
         else if(m_seed.buyableWithWorldCurrency() && this.m_validPlots.length * m_seed.cost > Global.player.currentWorldCurrencyTotal)
         {
            TurboPPHDialog.showOutOfWorldCurrencyDialog(TurboPPHDialog.ACTION_COMBINE,outOfWorldCurrencyHandler);
            result = false;
         }
         else if(!m_seed.buyableWithWorldCurrency() && this.m_validPlots.length * m_seed.cost > Global.player.gold)
         {
            TurboPPHDialog.showOutOfCoinsDialog(TurboPPHDialog.ACTION_COMBINE,outOfCoinsDialogHandler);
            result = false;
         }
         var hasSeedPackage:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            hasSeedPackage = m_seed.hasPropertyInDataSource("seedpackage");
         }
         else
         {
            hasSeedPackage = m_seed.xml.hasOwnProperty("seedpackage");
         }
         if(!m_seedOverride && hasSeedPackage && this.m_validPlots.length > Global.player.countSeeds(m_seed.name))
         {
            if(Global.player.seeds[m_seed.seedpackagecode])
            {
               tempSeeds = int(Global.player.seeds[m_seed.seedpackagecode].quantity);
               Global.player.seeds[m_seed.seedpackagecode].quantity = 0;
               missingReqs = m_seed.allMissingRequirements;
               Global.player.seeds[m_seed.seedpackagecode].quantity = tempSeeds;
            }
            else
            {
               missingReqs = m_seed.allMissingRequirements;
            }
            if(null != missingReqs && missingReqs.length > 0)
            {
               TurboPPHDialog.showOutOfSeedsDialog(TurboPPHDialog.ACTION_PLANT,m_seed,outOfSeedsDialogHandler);
               result = false;
            }
         }
         return result;
      }
      
      public function determineValidPlots() : void
      {
         var plot:Plot = null;
         this.m_validPlots = [];
         var fullPlotSet:Array = Global.world.getObjectsByClass(Plot);
         var p:Point = new Point();
         for each(plot in fullPlotSet)
         {
            p = new Point(plot.getPosition().x,plot.getPosition().y);
            if(!(plot.isPlanted() && !plot.isGrown()))
            {
               if(isPlotOnAcceptableTerrain(plot))
               {
                  this.m_validPlots.push({
                     "point":p,
                     "object":plot,
                     "valid":true
                  });
               }
            }
         }
      }
   }
}

