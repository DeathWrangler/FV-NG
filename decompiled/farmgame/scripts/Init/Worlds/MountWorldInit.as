package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.Managers.HUDTutorialManager;
   import Display.HUD.HUDWidgets.HudBottomShowAnimalsButton;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.FeatureMessagingManager;
   import Managers.OlyInnovationManager;
   
   public class MountWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XMO:String = "268";
      
      private static const SHOW_ANIMALS_HUD_ASSET_1:String = "assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_HUD_E.swf";
      
      private static const SHOW_ANIMALS_HUD_ASSET_2:String = "assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_HUD_U.swf";
      
      private static const SHOW_ANIMALS_HUD_ASSET_3:String = "assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_HUD_O.swf";
      
      private static const FEATURE_NAME:String = "olympus_innovation";
      
      public static const SHOW_ANIMAL_TYPE_1:String = "earth";
      
      public static const SHOW_ANIMAL_TYPE_2:String = "hades";
      
      public static const SHOW_ANIMAL_TYPE_3:String = "olympus";
      
      public static const ICON_1_X_OFFSET:int = -800;
      
      public static const ICON_1_Y_OFFSET:int = 94;
      
      public static const ICON_2_X_OFFSET:int = -740;
      
      public static const ICON_2_Y_OFFSET:int = 94;
      
      public static const ICON_3_X_OFFSET:int = -770;
      
      public static const ICON_3_Y_OFFSET:int = 144;
      
      public static const TUTORIAL_FLAG:String = "GlobalftueMount";
      
      public var hudButton:HudBottomShowAnimalsButton;
      
      public function MountWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMO_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XMO));
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         this.hudButton = new HudBottomShowAnimalsButton(SHOW_ANIMALS_HUD_ASSET_1,FEATURE_NAME,SHOW_ANIMAL_TYPE_1,ICON_1_X_OFFSET,ICON_1_Y_OFFSET);
         Global.hud.setBottomHudShowAnimalsButton(this.hudButton as HudBottomShowAnimalsButton);
         this.hudButton = new HudBottomShowAnimalsButton(SHOW_ANIMALS_HUD_ASSET_2,FEATURE_NAME,SHOW_ANIMAL_TYPE_2,ICON_2_X_OFFSET,ICON_2_Y_OFFSET);
         Global.hud.setBottomHudShowAnimalsButton(this.hudButton as HudBottomShowAnimalsButton);
         this.hudButton = new HudBottomShowAnimalsButton(SHOW_ANIMALS_HUD_ASSET_3,FEATURE_NAME,SHOW_ANIMAL_TYPE_3,ICON_3_X_OFFSET,ICON_3_Y_OFFSET);
         Global.hud.setBottomHudShowAnimalsButton(this.hudButton as HudBottomShowAnimalsButton);
         HUDTutorialManager.instance.initializeBottomHud(TUTORIAL_FLAG,true);
         OlyInnovationManager.getInstance().initEventListener();
         if(!Global.player.getSeenFlag(TUTORIAL_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_FLAG);
            HUDTutorialManager.instance.launchTutorial();
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.hud)
         {
            Global.hud.removeBottomHudShowAnimalsButton();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XMO_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XMO);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         if(HUDTutorialManager.instance)
         {
            HUDTutorialManager.instance.releaseTutorialWidget();
         }
         OlyInnovationManager.getInstance().deleteEventListener();
      }
   }
}

