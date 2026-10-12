package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.SouthindiaInnovationManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SouthindiaInnovationMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function SouthindiaInnovationMOTDWindow(displayParams:Object = null)
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
         if(currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS) && Boolean(currentMOTD[CUSTOM_ACTION_PARAMS].hasOwnProperty("motdType")))
         {
            if(currentMOTD[CUSTOM_ACTION_PARAMS]["motdType"] == "feature")
            {
               SouthindiaInnovationManager.getInstance().showMainUI();
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

