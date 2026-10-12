package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryV2Manager;
   import flash.events.Event;
   
   public class WildwestWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XWA:String = "258";
      
      public function WildwestWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWA_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XWA));
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
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XWA_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XWA);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
   }
}

