package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.FeatureMessagingManager;
   import Managers.JMInnovationManager;
   import Managers.WorldSeasonsManager;
   
   public class JungleWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XJM:String = "267";
      
      private static const INNOVATION_FEATURE_SEEN_FLAG:String = "JMInnovation_Tutorial";
      
      public function JungleWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XJM_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XJM));
         }
         var isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JUNGLE);
         if(isEA && !Global.player.getSeenFlag(INNOVATION_FEATURE_SEEN_FLAG))
         {
            JMInnovationManager.getInstance().showGrantPopup();
         }
         JMInnovationManager.getInstance().initEventListener();
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("JMInnovation");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XJM_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XJM);
         }
         JMInnovationManager.getInstance().deleteEventListener();
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("JMInnovation");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
   }
}

