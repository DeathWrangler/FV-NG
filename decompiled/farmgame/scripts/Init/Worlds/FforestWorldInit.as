package Init.Worlds
{
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class FforestWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XFF:String = "244";
      
      public function FforestWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XFF));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XFF);
      }
   }
}

