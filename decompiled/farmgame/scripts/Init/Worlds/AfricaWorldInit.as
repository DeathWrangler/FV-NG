package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.Managers.HUDTutorialManager;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryV2Manager;
   import flash.events.Event;
   
   public class AfricaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XAF:String = "260";
      
      private const AFRICA_GENERAL_ACCESS_TUTORIAL_FEATURE_NAME:String = "africaGA";
      
      private const AFRICA_EARLY_ACCESS_TUTORIAL_FEATURE_NAME:String = "africa";
      
      public function AfricaWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var isGeneralAccessStarted:Boolean = false;
         var featureName:String = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAF_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XAF));
            isGeneralAccessStarted = Global.experimentManager.getExperimentVariant("fv_xaf_motd_generalaccess") >= 1;
            featureName = null;
            if(isGeneralAccessStarted)
            {
               featureName = this.AFRICA_GENERAL_ACCESS_TUTORIAL_FEATURE_NAME;
            }
            else
            {
               featureName = this.AFRICA_EARLY_ACCESS_TUTORIAL_FEATURE_NAME;
            }
            if(!Global.player.getSeenFlag(featureName + "_ftue_complete"))
            {
               if(isGeneralAccessStarted)
               {
                  HUDTutorialManager.instance.initialize(this.AFRICA_GENERAL_ACCESS_TUTORIAL_FEATURE_NAME);
               }
               else
               {
                  HUDTutorialManager.instance.initialize(this.AFRICA_EARLY_ACCESS_TUTORIAL_FEATURE_NAME);
               }
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAF_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XAF);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
   }
}

