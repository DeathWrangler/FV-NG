package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Harvester;
   import Classes.Plot;
   import Display.TurboPPHDialog;
   import flash.geom.Point;
   
   public class GMHarvesterAll extends GMHarvester
   {
      
      private var m_validPlots:Array;
      
      public function GMHarvesterAll(harvester:Harvester = null)
      {
         var plot:Plot = null;
         var p:Point = null;
         this.m_validPlots = [];
         super(harvester);
         var allplots:Array = Global.world.getObjectsByClass(Plot);
         var plots:Array = [];
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
         var energyCount:int = this.m_validPlots.length * m_equipment.getEnergyCost();
         if(!m_fuelOverride && !Global.player.hasEnergy(energyCount))
         {
            TurboPPHDialog.showOutOfFuelDialog(TurboPPHDialog.ACTION_HARVEST,outOfFuelDialogHandler);
            result = false;
         }
         return result;
      }
   }
}

