package Managers
{
   import Display.TurboPPHOnBoardingDialog;
   import GameMode.GMCombine;
   import GameMode.GMCombineAll;
   import GameMode.GMHarvester;
   import GameMode.GMHarvesterAll;
   import GameMode.GMSeeder;
   import GameMode.GMSeederAll;
   import GameMode.GMTractorPlow;
   import GameMode.GMTractorPlowAll;
   import GameMode.GameMode;
   import Widgets.HUD.DrivingManagerHUD;
   
   public class TurboPPHManager
   {
      
      private static var m_instance:TurboPPHManager = null;
      
      private var m_drivingManager:DrivingManagerHUD;
      
      public function TurboPPHManager()
      {
         super();
         this.m_drivingManager = new DrivingManagerHUD();
      }
      
      public static function getInstance() : TurboPPHManager
      {
         if(m_instance == null)
         {
            m_instance = new TurboPPHManager();
         }
         return m_instance;
      }
      
      public function get turboSelected() : Boolean
      {
         var turboSelect:Boolean = false;
         return Global.player.hasEnoughTurbos(GameMode.AUTOSELECT_MIN_TURBO_PPH) && this.m_drivingManager.getTurboState() == DrivingManagerHUD.STATE_ACTIVE;
      }
      
      public function onMultiPlotEnabled() : void
      {
         TurboPPHOnBoardingDialog.conditionalShow();
         this.m_drivingManager.show();
      }
      
      public function onMultiPlotDisabled() : void
      {
         this.m_drivingManager.hideLater();
      }
      
      public function enableTurboMode() : Boolean
      {
         var plowMode:GMTractorPlow = null;
         var seedMode:GMSeeder = null;
         var harvestMode:GMHarvester = null;
         var combineMode:GMCombine = null;
         var result:Boolean = false;
         var newMode:GameMode = null;
         var topMode:GameMode = Global.world.getTopGameMode();
         if(topMode is GMTractorPlow)
         {
            plowMode = topMode as GMTractorPlow;
            newMode = new GMTractorPlowAll(plowMode.tractor);
         }
         else if(topMode is GMSeeder)
         {
            seedMode = topMode as GMSeeder;
            newMode = new GMSeederAll(seedMode.seed,seedMode.seeder);
         }
         else if(topMode is GMHarvester)
         {
            harvestMode = topMode as GMHarvester;
            newMode = new GMHarvesterAll(harvestMode.harvester);
         }
         else if(topMode is GMCombine)
         {
            combineMode = topMode as GMCombine;
            newMode = new GMCombineAll(combineMode.seed,combineMode.combine);
         }
         if(newMode)
         {
            Global.world.popGameMode();
            Global.world.addGameMode(newMode);
            result = true;
         }
         return result;
      }
      
      public function disableTurboMode() : Boolean
      {
         var plowAllMode:GMTractorPlowAll = null;
         var seedAllMode:GMSeederAll = null;
         var harvestAllMode:GMHarvesterAll = null;
         var combineAllMode:GMCombineAll = null;
         var result:Boolean = false;
         var newMode:GameMode = null;
         var topMode:GameMode = Global.world.getTopGameMode();
         if(topMode is GMTractorPlowAll)
         {
            plowAllMode = topMode as GMTractorPlowAll;
            newMode = new GMTractorPlow(plowAllMode.tractor);
         }
         else if(topMode is GMSeederAll)
         {
            seedAllMode = topMode as GMSeederAll;
            seedAllMode.determineValidPlots();
            newMode = new GMSeeder(seedAllMode.seed,seedAllMode.seeder);
         }
         else if(topMode is GMHarvesterAll)
         {
            harvestAllMode = topMode as GMHarvesterAll;
            newMode = new GMHarvester(harvestAllMode.harvester);
         }
         else if(topMode is GMCombineAll)
         {
            combineAllMode = topMode as GMCombineAll;
            combineAllMode.determineValidPlots();
            newMode = new GMCombine(combineAllMode.seed,combineAllMode.combine);
         }
         if(newMode)
         {
            Global.world.popGameMode();
            Global.world.addGameMode(newMode);
            result = true;
         }
         return result;
      }
      
      public function turboCountChanged() : void
      {
         this.m_drivingManager.turboCountChanged();
         if(!Global.player.hasEnoughTurbos(1))
         {
            this.disableTurboMode();
         }
      }
   }
}

