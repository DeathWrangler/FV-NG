package Init.PostInitActionHandlers
{
   import Classes.Constants.WorldsConstants;
   import Managers.HangingGardensManager;
   import Managers.MapTriggerManager;
   
   public class MapTriggerManagerInit extends AbstractPostInitAction
   {
      
      public function MapTriggerManagerInit(callback:Function = null)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         if(Global.farmGameSettingsManager.getXML().hasOwnProperty("mapTriggers"))
         {
            MapTriggerManager.getInstance().loadMapTriggerXML(Global.farmGameSettingsManager.getXML().child("mapTriggers")[0]);
            if(Global.worldManager.currentWorldType != HangingGardensManager.HANGING_GARDENS && Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_AVALON)
            {
               MapTriggerManager.getInstance().createMapTriggers();
            }
         }
         m_isFinished = true;
      }
   }
}

