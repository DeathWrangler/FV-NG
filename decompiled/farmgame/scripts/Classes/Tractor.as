package Classes
{
   import Display.ContextMenuItem;
   import Engine.Managers.SoundManager;
   import GameMode.GMTractorPlow;
   import GameMode.GMTractorPlowAll;
   import Managers.FarmGameSettingsManager;
   import Managers.TurboPPHManager;
   import flash.events.MouseEvent;
   
   public class Tractor extends Equipment
   {
      
      public static const PLOW:String = "plow";
      
      public static const FIRST_TRACTOR_PLACEMENT_FLAG:String = "firstTractor";
      
      public function Tractor(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      public function get isHotrod() : Boolean
      {
         var tractorName:String = null;
         var hotrod:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            tractorName = m_item.getStringFromDataSource("name");
         }
         else
         {
            tractorName = m_item.xml.@name;
         }
         if(tractorName.indexOf("tractorhotrod") != -1)
         {
            hotrod = true;
         }
         return hotrod;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
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
                  if(TurboPPHManager.getInstance().turboSelected && this.hasPlowableTerrain())
                  {
                     Global.world.addGameMode(new GMTractorPlowAll(this),true);
                  }
                  else
                  {
                     Global.world.addGameMode(new GMTractorPlow(this),true);
                  }
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
         if(!Global.player.getSeenFlag(FIRST_TRACTOR_PLACEMENT_FLAG))
         {
            if(!Global.player.getSeenSessionFlag(FIRST_TRACTOR_PLACEMENT_FLAG))
            {
               Global.player.energy += this.calcFirstTractorFuel();
               Global.player.setSeenSessionFlag(FIRST_TRACTOR_PLACEMENT_FLAG);
            }
         }
      }
      
      public function hasPlowableTerrain() : Boolean
      {
         return Global.world.plowablePlots(getItem().getTerrainCodes());
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

