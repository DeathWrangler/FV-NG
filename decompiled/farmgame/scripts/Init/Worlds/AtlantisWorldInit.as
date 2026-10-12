package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class AtlantisWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XAL:String = "235";
      
      public function AtlantisWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XAL));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAL_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XAL);
         }
         super.onLeaveWorld(destIsVisiting);
      }
   }
}

