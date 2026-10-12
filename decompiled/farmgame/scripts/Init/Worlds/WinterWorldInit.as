package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.FeatureMessagingManager;
   
   public class WinterWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XWI:String = "262";
      
      public function WinterWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWI_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XWI));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("northpole_toy_works");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWI_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XWI);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("northpole_toy_works");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
   }
}

