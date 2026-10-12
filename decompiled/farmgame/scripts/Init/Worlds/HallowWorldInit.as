package Init.Worlds
{
   import Classes.Constants.WorldsConstants;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Init.PostInitActionHandlers.WorldProgressWindowInitAction;
   import Managers.DecoPointsManager;
   
   public class HallowWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHW:String = "230";
      
      public function HallowWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         DecoPointsManager.instance.init();
         Global.postInitActionsManager.addInitAction(new WorldProgressWindowInitAction(WorldsConstants.WORLD_ITEM_PREFIX_HALLOW));
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHW));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         Global.hud.rightSideIconQueue.removeIconByCode(ICON_CODE_STARTER_XHW);
         super.onLeaveWorld(destIsVisiting);
      }
   }
}

