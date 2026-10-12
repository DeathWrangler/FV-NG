package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.LightningDealManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LightningDealMotd extends GenericSingleButtonWidgetMOTD
   {
      
      public function LightningDealMotd(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         LightningDealManager.getInstance().showMainUI();
         FarmStatsManager.count("lightning_deals","MOTD","click");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

