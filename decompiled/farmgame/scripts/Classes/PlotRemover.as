package Classes
{
   import Display.ContextMenuItem;
   import Engine.Managers.SoundManager;
   import GameMode.GMPlotRemover;
   import flash.events.MouseEvent;
   
   public class PlotRemover extends Equipment
   {
      
      public static const PLOW:String = "plow";
      
      public static const FIRST_PLOTREMOVER_PLACEMENT_FLAG:String = "firstPlotRemover";
      
      public function PlotRemover(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var gmClear:GMPlotRemover = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case VEHICLE_ACTION:
                  gmClear = new GMPlotRemover();
                  Global.world.addGameMode(gmClear);
                  break;
               case HORN:
                  SoundManager.addSound("tractorHorn",Global.getAssetURL("assets/sounds/tractor_horn.mp3"));
                  SoundManager.playSound("tractorHorn");
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         if(!Global.player.getSeenFlag(FIRST_PLOTREMOVER_PLACEMENT_FLAG))
         {
            if(!Global.player.getSeenSessionFlag(FIRST_PLOTREMOVER_PLACEMENT_FLAG))
            {
               Global.player.energy += this.calcFirstTractorFuel();
               Global.player.setSeenSessionFlag(FIRST_PLOTREMOVER_PLACEMENT_FLAG);
            }
         }
      }
      
      public function hasRemovableTerrain() : Boolean
      {
         return Global.world.removablePlots(getItem().getTerrainCodes());
      }
      
      private function calcFirstTractorFuel() : uint
      {
         var numPlots:uint = Global.world.getObjectsByClass(Plot).length;
         var fuelTankSize:uint = uint(Global.player.energyMax);
         var fuelMultiplier:uint = Global.farmGameSettingsManager.getAttribute("firstTractorBundledFuelMultiplier",3);
         var bundledFuelAmount:uint = Math.floor(numPlots * fuelMultiplier / fuelTankSize) * fuelTankSize;
         if(bundledFuelAmount < 0)
         {
            bundledFuelAmount = 0;
         }
         return bundledFuelAmount;
      }
   }
}

