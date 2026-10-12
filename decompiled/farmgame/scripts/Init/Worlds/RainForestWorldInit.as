package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class RainForestWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XRF:String = "247";
      
      public function RainForestWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XRF_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XRF));
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XRF_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XRF);
         }
      }
   }
}

