package Init.Worlds
{
   import Classes.Managers.HUDTutorialManager;
   import Display.HUD.HUDWidgets.HUDTutorialButton;
   import Managers.FarmStatsManager;
   import Managers.HangingGardensManager;
   
   public class GardenWorldInit extends HomeWorldInit
   {
      
      public static const GARDEN_RIGHT_HUD_ICON_NAME:String = "";
      
      private static const HANGING_GARDENS_VISIT_WORLD_SEEN_FLAG:String = "hangingGardenVisitedWorld";
      
      private var m_hudTutorialButton:HUDTutorialButton;
      
      public function GardenWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         Global.player.setSeenFlag(HANGING_GARDENS_VISIT_WORLD_SEEN_FLAG);
         Global.player.setFeatureLastShown(HangingGardensManager.HANGING_GARDENS_TRAVEL_FEATURE_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,true);
         if(Global.player.getSeenFlag(HangingGardensManager.HANGING_GARDENS_FTUE_SEEN_FLAG))
         {
            HangingGardensManager.instance.addFourPanelHudIcon();
            HUDTutorialManager.instance.initialize("hangingGardensStatic");
         }
         else
         {
            HangingGardensManager.instance.beginFTUE();
            FarmStatsManager.featureSample("Hanging_Gardens","FTUE","start");
         }
         super.onEnterWorld(resultData);
         HangingGardensManager.instance.determineStageNumber();
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         Global.hud.rightSideIconQueue.removeIconByName(GARDEN_RIGHT_HUD_ICON_NAME);
         HangingGardensManager.instance.removeFourPanelHudIcon();
         HUDTutorialManager.instance.releaseTutorialWidget();
         if(this.m_hudTutorialButton)
         {
            this.m_hudTutorialButton.release();
         }
         super.onLeaveWorld(destIsVisiting);
         Global.player.setFeatureLastShown(HangingGardensManager.HANGING_GARDENS_TRAVEL_FEATURE_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,true);
         HangingGardensManager.instance.determineStageNumber();
      }
   }
}

