package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Managers.HUDTutorialManager;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class HlightsWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XLG:String = "246";
      
      public function HlightsWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         if(!Global.player.getSeenFlag("holidayLights_ftue_complete") && !Global.player.getSeenFlag("holidayLightsGA_ftue_complete"))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_HLIGHTS_FTUE) >= 1)
            {
               if(Global.experimentManager.getExperimentVariant("fv_xlg_motd_generalaccess") >= 1)
               {
                  HUDTutorialManager.instance.initialize("holidayLightsGA");
               }
               else
               {
                  HUDTutorialManager.instance.initialize("holidayLights");
               }
            }
         }
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XLG_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XLG));
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         HUDTutorialManager.instance.releaseTutorialWidget();
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XLG_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XLG);
         }
      }
   }
}

