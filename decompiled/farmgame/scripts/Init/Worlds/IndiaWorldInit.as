package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.Managers.HUDTutorialManager;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryV2Manager;
   import Managers.FeatureMessagingManager;
   import Managers.FestivalOfColorManager;
   import flash.events.Event;
   
   public class IndiaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XIN:String = "263";
      
      public function IndiaWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XIN_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XIN));
         }
         if(Boolean(AnimalSanctuaryV2Manager.getInstance()) && AnimalSanctuaryV2Manager.getInstance().isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               AnimalSanctuaryV2Manager.getInstance().setupAnimalSanctuaryV2Hud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("FestivalOfColor");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         FestivalOfColorManager.getInstance().initEventListener();
         FestivalOfColorManager.getInstance().conditionallyTriggerTutorialOne();
         if(Global.player.getSeenFlag(FestivalOfColorManager.TUTORIAL_FLAG_3 + FestivalOfColorManager.TUTORIAL_FLAG_SUFFIX))
         {
            HUDTutorialManager.instance.initializeBottomHud(FestivalOfColorManager.TUTORIAL_FLAG_3);
         }
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(AnimalSanctuaryV2Manager.getInstance())
            {
               AnimalSanctuaryV2Manager.getInstance().setupAnimalSanctuaryV2Hud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XIN_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XIN);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition("FestivalOfColor");
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
         FestivalOfColorManager.getInstance().deleteEventListener();
         if(HUDTutorialManager.instance)
         {
            HUDTutorialManager.instance.releaseTutorialWidget();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
   }
}

