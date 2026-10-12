package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.OrderBoard.BobBerryManager;
   import flash.events.MouseEvent;
   
   public class BobBerryWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function BobBerryWidgetMOTDWindow(displayParams:Object = null)
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
         close();
         var actionParams:Object = null;
         if(currentMOTD.hasOwnProperty("customActionParams"))
         {
            actionParams = currentMOTD["customActionParams"];
         }
         var mapTriggerName:String = actionParams.mapTriggerName;
         BobBerryManager.getInstance(mapTriggerName).showBobAndOpenWindow();
      }
   }
}

