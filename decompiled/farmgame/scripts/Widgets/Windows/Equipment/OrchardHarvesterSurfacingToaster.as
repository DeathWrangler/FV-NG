package Widgets.Windows.Equipment
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.OrchardHarvester;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import flash.events.MouseEvent;
   
   public class OrchardHarvesterSurfacingToaster extends ResourceHarvesterSurfacingToaster
   {
      
      private static const SURFACING_TOASTER_FEATURE_FREQUENCY_NAME:String = "OrchardHarvesterSurfacingToaster";
      
      private static const ORCHARD_HARVESTER_PHYLUM:String = "orchardharvester";
      
      private static const ORCHARD_HARVESTER_SURFACING_TOASTER_ASSET_PATH:String = "assets/dialogs/FV_OrchardHarvester_Toaster.swf";
      
      private static const ORCHARD_HARVESTER_SURFACING_TOASTER_PREFIX:String = "OrchardHarvester_SurfacingToaster";
      
      private static const SURFACING_TOASTER_WAIT_DAYS_GAME_SETTING_NAME:String = "OrchardHarvester_SurfacingToaster_WaitDays";
      
      private static const DEFAULT_SURFACING_TOASTER_WAIT_DAYS:int = 7;
      
      public function OrchardHarvesterSurfacingToaster()
      {
         super(ORCHARD_HARVESTER_SURFACING_TOASTER_ASSET_PATH);
         m_titleText = ZLocUtils.t("Dialogs",ORCHARD_HARVESTER_SURFACING_TOASTER_PREFIX + "_Title");
         m_descriptionText = ZLocUtils.t("Dialogs",ORCHARD_HARVESTER_SURFACING_TOASTER_PREFIX + "_Description");
         m_acceptButtonText = ZLocUtils.t("Dialogs",ORCHARD_HARVESTER_SURFACING_TOASTER_PREFIX + "_AcceptButton");
      }
      
      public static function conditionallyShow() : void
      {
         var waitDays:int = 0;
         if(!Global.world.getEquipment(OrchardHarvester))
         {
            waitDays = Global.farmGameSettingsManager.getInt(SURFACING_TOASTER_WAIT_DAYS_GAME_SETTING_NAME,DEFAULT_SURFACING_TOASTER_WAIT_DAYS);
            if(Global.player.canShowFeatureWithFeatureFrequency(SURFACING_TOASTER_FEATURE_FREQUENCY_NAME,waitDays))
            {
               ToasterManager.getInstance().add(new OrchardHarvesterSurfacingToaster());
            }
         }
      }
      
      override public function show() : void
      {
         var waitDays:int = Global.farmGameSettingsManager.getInt(SURFACING_TOASTER_WAIT_DAYS_GAME_SETTING_NAME,DEFAULT_SURFACING_TOASTER_WAIT_DAYS);
         if(Global.player.canShowFeatureWithFeatureFrequency(SURFACING_TOASTER_FEATURE_FREQUENCY_NAME,waitDays))
         {
            FarmStatsManager.count(StatsTrackingConstants.SURFACING_TOASTER,ORCHARD_HARVESTER_PHYLUM,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            Global.player.setFeatureLastShown(SURFACING_TOASTER_FEATURE_FREQUENCY_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
            super.show();
         }
         else
         {
            close();
         }
      }
      
      override protected function onAcceptButtonClick(event:MouseEvent) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.SURFACING_TOASTER,ORCHARD_HARVESTER_PHYLUM,StatsTrackingConstants.STATS_CLICK);
         var items:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("OrchardHarvester");
         UI.displayMiniMarketDialog(items,"OrchardHarvesterSurfacingToaster","vehicle");
         close();
      }
   }
}

