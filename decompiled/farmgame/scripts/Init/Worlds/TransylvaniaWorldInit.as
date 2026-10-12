package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Managers.HUDTutorialManager;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class TransylvaniaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XTR:String = "261";
      
      private const TRANSYLVANIA_TUTORIAL_FEATURE_NAME:String = "transylvania";
      
      public function TransylvaniaWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTR_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XTR));
            if(!Global.player.getSeenFlag(this.TRANSYLVANIA_TUTORIAL_FEATURE_NAME + "_ftue_complete"))
            {
               HUDTutorialManager.instance.initialize(this.TRANSYLVANIA_TUTORIAL_FEATURE_NAME,null,true);
            }
            else
            {
               HUDTutorialManager.instance.initializeBottomHud(this.TRANSYLVANIA_TUTORIAL_FEATURE_NAME);
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XTR_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XTR);
         }
         if(HUDTutorialManager.instance)
         {
            HUDTutorialManager.instance.releaseTutorialWidget();
         }
      }
   }
}

