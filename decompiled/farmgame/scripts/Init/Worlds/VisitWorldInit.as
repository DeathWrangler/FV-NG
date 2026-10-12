package Init.Worlds
{
   import Classes.Constants.WorldsConstants;
   import Classes.Idle.IdleTaskQueue;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUDSkin;
   import Display.HUD.HUDSkinConfig;
   
   public class VisitWorldInit extends BaseWorldInit
   {
      
      protected var m_destinationUid:String;
      
      public function VisitWorldInit(destinationUid:String)
      {
         this.m_destinationUid = destinationUid;
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         var giftableItem:FarmItem = null;
         if(resultData.visitGiftItemCode)
         {
            giftableItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.visitGiftItemCode);
         }
         var visitorManager:VisitorManager = VisitorManager.getInstance();
         resultData.user.id = this.m_destinationUid;
         visitorManager.initForVisit(resultData.user,giftableItem);
         var neighborActionsQueue:Object = resultData.neighborActionsQueue;
         if(neighborActionsQueue)
         {
            visitorManager.initNeighborActionData(neighborActionsQueue.m_actionQueue);
         }
         IdleTaskQueue.getInstance().addVisitIdleTasks();
      }
      
      override public function setupHud() : void
      {
         var hudSkin:HUDSkin = null;
         super.setupHud();
         var config:Object = Global.worldSettingsManager.getConfigByWorld(WorldsConstants.WORLD_ID_HOME);
         if(config.hudSkinConfig != null && config.hudSkinConfig is HUDSkinConfig)
         {
            hudSkin = new HUDSkin(WorldsConstants.WORLD_ID_HOME,config.hudSkinConfig);
            hudSkin.apply();
         }
         if(Global.hud.m_statsDropDown != null)
         {
            Global.hud.m_statsDropDown.SetVisibility(false);
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(!destIsVisiting)
         {
            if(Global.mission)
            {
               Global.postInitActions.execute();
               Global.mission = null;
            }
            VisitorManager.getInstance().onGoHome();
         }
      }
   }
}

