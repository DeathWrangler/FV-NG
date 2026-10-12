package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class SpaceWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XSP:String = "238";
      
      public function SpaceWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XSP_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XSP));
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XSP_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XSP);
         }
      }
   }
}

