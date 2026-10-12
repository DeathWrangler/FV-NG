package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FarmersMarket2020MOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      public function FarmersMarket2020MOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         UI.stopPopups(true);
         FarmStatsManager.count("MOTD","impressions","MOTD_GIFTRUSH_RACING");
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
            FarmersMarketInnovationManager.getInstance().showMainWindow();
         }
         FarmStatsManager.count("MOTD","click","MOTD_GIFTRUSH_RACING");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","close","MOTD_GIFTRUSH_RACING");
      }
   }
}

