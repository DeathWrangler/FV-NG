package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.BoatRushManager;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BoatRushMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const FEATURE_NAME:String = "BoatRush2020";
      
      public function BoatRushMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         UI.stopPopups(true);
         FarmStatsManager.count("MOTD","impressions","MOTD_BOATRUSH_RACING");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
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
            BoatRushManager.getInstance().showMainWindow();
         }
         FarmStatsManager.count("MOTD","click","MOTD_BOATRUSH_RACING");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","close","MOTD_BOATRUSH_RACING");
      }
   }
}

