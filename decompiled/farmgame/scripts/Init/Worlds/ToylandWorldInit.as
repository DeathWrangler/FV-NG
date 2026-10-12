package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class ToylandWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XTL:String = "255";
      
      public function ToylandWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTL_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XTL));
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTL_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XTL);
         }
      }
   }
}

