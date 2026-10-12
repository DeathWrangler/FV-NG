package Widgets.Windows.MOTD
{
   import Display.UI;
   import GameMode.GMDecorationPlace;
   import GameMode.GameMode;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BoraboraInnovationMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      public function BoraboraInnovationMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var mainWindow:MovieClip = null;
         var speechbuble:MovieClip = null;
         super.postLoadComplete();
         UI.stopPopups(true);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            mainWindow = m_window["mainWindow"] as MovieClip;
            if(mainWindow.hasOwnProperty("speechbuble_mc"))
            {
               speechbuble = mainWindow["speechbuble_mc"] as MovieClip;
               speechbuble.visible = false;
            }
         }
         FarmStatsManager.count("MOTD","impressions","MOTD_Borabora_INNOVATION");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         var modes:Array = null;
         var mode:GameMode = null;
         var result:GameMode = null;
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            if(Global.world.isGameModeActive(GMDecorationPlace))
            {
               modes = Global.world.getActiveGameModes();
               for each(mode in modes)
               {
                  if(mode is GMDecorationPlace)
                  {
                     result = mode;
                     break;
                  }
               }
               Global.world.removeGameMode(result);
               return;
            }
            BoraBoraInnovationManager.getInstance(FEATURE_NAME).showMainWindow();
         }
         FarmStatsManager.count("MOTD","click","MOTD_Borabora_INNOVATION");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","close","MOTD_Borabora_INNOVATION");
      }
   }
}

