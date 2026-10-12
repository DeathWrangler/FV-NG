package Widgets.Windows.MOTD
{
   import Classes.GypsyTrader;
   import Classes.util.MovieClipUtils;
   import Display.UI;
   import flash.events.MouseEvent;
   
   public class GypsyTraderWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function GypsyTraderWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
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
         GypsyTrader.getInstance(mapTriggerName).showMainWindow();
      }
   }
}

