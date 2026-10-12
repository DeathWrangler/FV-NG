package Init.Worlds
{
   import Classes.Constants.Experiments;
   import Classes.consumables.CUnwither;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   
   public class SleepyhollowWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_STARTER_XSH:String = "254";
      
      public function SleepyhollowWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         var unwither:CUnwither = null;
         super.onEnterWorld(resultData);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XSH_STARTER) >= 1)
         {
            Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_STARTER_XSH));
         }
         if(Global.flashHotParams["SLEEPYHOLLOW_UNWITHER_CROPS_ONCE"])
         {
            if(Global.player.getSeenSessionFlag("sleepyhollowunwitheradded") && !Global.player.getSeenFlag("SLEEPYHOLLOW_UNLOCKED"))
            {
               Global.player.setSeenFlag("SLEEPYHOLLOW_UNLOCKED");
               unwither = new CUnwither("consume_unwither");
               unwither.consume(true,true,"",true,-1,1);
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MOTD_XSH_STARTER) >= 1)
         {
            Global.hud.rightSideIconQueue.removeIconByName(ICON_CODE_STARTER_XSH);
         }
      }
   }
}

