package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Plot;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Display.TurboPPHDialog;
   import Display.UI;
   import flash.geom.Point;
   
   public class GMSeederAll extends GMSeeder
   {
      
      private var m_validPlots:Array;
      
      public function GMSeederAll(seed:FarmItem, seeder:Seeder = null)
      {
         var plot:Plot = null;
         var p:Point = null;
         this.m_validPlots = [];
         super(seed,seeder);
         var allplots:Array = Global.world.getObjectsByClass(Plot);
         if(seed.seedpackagecode != null && Global.player.seeds[seed.seedpackagecode] != null && Global.player.seeds[seed.seedpackagecode].quantity > 0 && allplots.length > Global.player.seeds[seed.seedpackagecode].quantity)
         {
            this.m_validPlots = this.getPlotsWithConstraints(allplots);
         }
         else
         {
            for each(plot in allplots)
            {
               p = new Point(plot.getPosition().x,plot.getPosition().y);
               if(isSelectable(plot))
               {
                  this.m_validPlots.push({
                     "point":p,
                     "object":plot,
                     "valid":true
                  });
               }
            }
         }
         this.performResourceCheck();
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
               this.m_validPlots.push({
                  "point":p,
                  "object":plot,
                  "valid":true
               });
            }
         }
      }
      
      override protected function outOfSeedsDialogHandler(result:int) : void
      {
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               Global.world.popGameMode();
               Global.world.addGameMode(new GMDefault());
               UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds");
               break;
            case TurboPPHDialog.RESULT_OK:
               m_seedOverride = true;
               handleClick(null);
         }
      }
      
      override protected function performResourceCheck() : Boolean
      {
         var missingReqs:Array = null;
         var tempSeeds:int = 0;
         var result:Boolean = true;
         if(!m_seedOverride && m_seed.seedpackagecode != null && this.m_validPlots.length > Global.player.countSeeds(m_seed.name))
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
               TurboPPHDialog.showOutOfSeedsDialog(TurboPPHDialog.ACTION_PLANT,m_seed,this.outOfSeedsDialogHandler);
               result = false;
            }
         }
         var energyAmount:int = this.m_validPlots.length * m_equipment.getEnergyCost();
         if(!m_fuelOverride && !Global.player.hasEnergy(energyAmount))
         {
            TurboPPHDialog.showOutOfFuelDialog(TurboPPHDialog.ACTION_PLANT,outOfFuelDialogHandler);
            result = false;
         }
         else if(m_seed.buyableWithWorldCurrency() && this.m_validPlots.length * m_seed.cost > Global.player.currentWorldCurrencyTotal)
         {
            TurboPPHDialog.showOutOfWorldCurrencyDialog(TurboPPHDialog.ACTION_PLANT,outOfWorldCurrencyHandler);
            result = false;
         }
         else if(!m_seed.buyableWithWorldCurrency() && this.m_validPlots.length * m_seed.cost > Global.player.gold)
         {
            TurboPPHDialog.showOutOfCoinsDialog(TurboPPHDialog.ACTION_PLANT,outOfCoinsDialogHandler);
            result = false;
         }
         return result;
      }
   }
}

