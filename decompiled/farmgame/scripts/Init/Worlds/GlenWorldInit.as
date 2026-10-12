package Init.Worlds
{
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class GlenWorldInit extends HomeWorldInit
   {
      
      public static const GLEN__RIGHT_HUD_ICON_NAME:String = "";
      
      public static const ICON_CODE_STARTER_XEG:String = "233";
      
      public function GlenWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XEG));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         Global.hud.rightSideIconQueue.removeIconByCode(ICON_CODE_STARTER_XEG);
         super.onLeaveWorld(destIsVisiting);
      }
   }
}

