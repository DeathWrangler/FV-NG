package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.AnimalSanctuaryV2Manager;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2MOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function AnimalSanctuaryV2MOTD(displayParams:Object = null)
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
         FarmStatsManager.count("MOTD","impressions","MOTD_Animal_Sanctuary_V2");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         AnimalSanctuaryV2Manager.getInstance().showMainUI();
         FarmStatsManager.count("MOTD","click","MOTD_Animal_Sanctuary_V2");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","close","MOTD_Animal_Sanctuary_V2");
      }
   }
}

