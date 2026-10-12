package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HalloweenUSAInnovationMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function HalloweenUSAInnovationMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         UI.stopPopups(true);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         HalloweenInnovationManager.getInstance().showMainUI();
         FarmStatsManager.count("HalloweenUSAInnovation","MOTD","click");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

