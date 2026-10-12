package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Plot;
   import Classes.Tractor;
   import Display.TurboPPHDialog;
   import flash.geom.Point;
   
   public class GMTractorPlowAll extends GMTractorPlow
   {
      
      private var m_validPlots:Array;
      
      public function GMTractorPlowAll(tractor:Tractor = null)
      {
         var plot:Plot = null;
         var p:Point = null;
         this.m_validPlots = [];
         super(tractor);
         var allplots:Array = Global.world.getObjectsByClass(Plot);
         for each(plot in allplots)
         {
            p = new Point(plot.getPosition().x,plot.getPosition().y);
            if(plot.isPlowable() && isPlotOnAcceptableTerrain(plot))
            {
               this.m_validPlots.push({
                  "point":p,
                  "object":plot,
                  "valid":true
               });
            }
         }
      }
      
      override protected function shouldScaleCursor() : Boolean
      {
         return false;
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         Global.world.popGameMode();
         Global.world.addGameMode(new GMDefault());
         super.addAvatarState(avatar,plots,centerPos);
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
         var result:Boolean = true;
         var worldPlotCostData:Object = Plot.getWorldPlowPlotCostData();
         var energyAmount:int = this.m_validPlots.length * m_equipment.getEnergyCost();
         if(!m_fuelOverride && !Global.player.hasEnergy(energyAmount))
         {
            TurboPPHDialog.showOutOfFuelDialog(TurboPPHDialog.ACTION_PLOW,outOfFuelDialogHandler);
            result = false;
         }
         else if(this.m_validPlots.length * Global.farmGameSettingsManager.getInt("plowCost") > Global.player.gold)
         {
            TurboPPHDialog.showOutOfCoinsDialog(TurboPPHDialog.ACTION_PLOW,outOfCoinsDialogHandler);
            result = false;
         }
         else if(this.m_validPlots.length * worldPlotCostData.cost > Global.player.currentWorldCurrencyTotal)
         {
            TurboPPHDialog.showOutOfWorldCurrencyDialog(TurboPPHDialog.ACTION_PLOW,outOfWorldCurrencyHandler);
            result = false;
         }
         return result;
      }
   }
}

