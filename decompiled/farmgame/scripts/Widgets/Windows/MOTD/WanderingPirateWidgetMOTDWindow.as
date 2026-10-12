package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.WanderingPirateManager;
   import flash.events.MouseEvent;
   
   public class WanderingPirateWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function WanderingPirateWidgetMOTDWindow(displayParams:Object = null)
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
         var actionParams:Object = null;
         if(currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS))
         {
            actionParams = currentMOTD[CUSTOM_ACTION_PARAMS];
         }
         var mapTriggerName:String = actionParams.mapTriggerName;
         WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).showWanderingPirateAndOpenWindow(mapTriggerName);
      }
   }
}

