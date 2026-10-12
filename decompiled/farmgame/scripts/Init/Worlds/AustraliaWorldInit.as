package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryManager;
   import flash.events.Event;
   
   public class AustraliaWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XAU:String = "236";
      
      public function AustraliaWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAU_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XAU));
         }
         if(Boolean(AnimalSanctuaryManager.getInstance()) && AnimalSanctuaryManager.getInstance().isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
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
            if(AnimalSanctuaryManager.getInstance())
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XAU_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XAU);
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudCasablancaInnovationButton();
         }
      }
   }
}

