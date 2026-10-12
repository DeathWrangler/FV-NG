package Widgets.Windows.MOTD
{
   import Classes.Constants.WorldsConstants;
   import Display.UI;
   import Managers.XMASInnovationManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class XMASInnovationMotd extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public function XMASInnovationMotd(displayParams:Object = null)
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
            if(WorldsConstants.WORLD_ID_XMAS != Global.worldManager.currentWorldType)
            {
               Global.hud.travelNameDisplay.showNewTravelWindow();
            }
            else if(currentMOTD[CUSTOM_ACTION_PARAMS]["motdType"] == "feature")
            {
               XMASInnovationManager.getInstance().showMainUI();
            }
            else if(currentMOTD[CUSTOM_ACTION_PARAMS]["motdType"] == "redeem")
            {
               XMASInnovationManager.getInstance().showMainUI();
               XMASInnovationManager.getInstance().showRedeemUI();
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

