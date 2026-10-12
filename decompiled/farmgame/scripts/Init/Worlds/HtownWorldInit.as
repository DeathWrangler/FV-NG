package Init.Worlds
{
   import Classes.Constants.WorldsConstants;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Init.PostInitActionHandlers.WorldProgressWindowInitAction;
   import Managers.DecoPointsManager;
   
   public class HtownWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XHD:String = "232";
      
      public function HtownWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         DecoPointsManager.instance.init();
         Global.postInitActionsManager.addInitAction(new WorldProgressWindowInitAction(WorldsConstants.WORLD_ITEM_PREFIX_HTOWN));
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XHD));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
      }
   }
}

