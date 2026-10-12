package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Managers.HUDTutorialManager;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class OasisWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XOA:String = "252";
      
      public function OasisWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         if(!Global.player.getSeenFlag("oasis_ftue_complete") && !Global.player.getSeenFlag("oasisGA_ftue_complete"))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_OASIS_FTUE) >= 1)
            {
               if(Global.experimentManager.getExperimentVariant("fv_xoa_motd_generalaccess") >= 1)
               {
                  HUDTutorialManager.instance.initialize("oasisGA");
               }
               else
               {
                  HUDTutorialManager.instance.initialize("oasis");
               }
            }
         }
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XOA_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XOA));
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XOA_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XOA);
         }
      }
   }
}

