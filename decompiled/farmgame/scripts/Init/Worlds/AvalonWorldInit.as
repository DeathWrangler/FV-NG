package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.Managers.HUDTutorialManager;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureMessagingManager;
   import Managers.WorldSeasonsManager;
   
   public class AvalonWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XMA:String = "256";
      
      public static const ICON_CODE_STARTER_XMB:String = "257";
      
      public function AvalonWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var currentSeasonNumber:int = 0;
         var featureName:String = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_AVALON_FTUE) >= 1)
         {
            currentSeasonNumber = WorldSeasonsManager.getInstance().getCurrentSeason(WorldsConstants.WORLD_ID_AVALON);
            featureName = WorldsConstants.WORLD_ID_AVALON + "_" + currentSeasonNumber;
            if(!Global.player.getSeenFlag(featureName + "_ftue_complete"))
            {
               HUDTutorialManager.instance.initialize(featureName,null,true);
            }
            else
            {
               HUDTutorialManager.instance.initializeBottomHud(featureName);
            }
         }
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMA_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XMA));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMB_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XMB));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMA_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XMA);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMB_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XMB);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(CommunityGoalsManager.FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(HUDTutorialManager.instance)
         {
            HUDTutorialManager.instance.releaseTutorialWidget();
         }
      }
   }
}

