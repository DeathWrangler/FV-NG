package Init.Worlds
{
   import Display.QueuedIcon;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryManager;
   import flash.events.Event;
   
   public class AsiaWorldInit extends HomeWorldInit
   {
      
      public static const ASIA_STARTER_RIGHT_HUD_ICON_NAME:String = "JadeFallsStarter";
      
      public function AsiaWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(QueuedIcon.ICON_CODE_JADE));
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
         Global.hud.rightSideIconQueue.removeIconByName(ASIA_STARTER_RIGHT_HUD_ICON_NAME);
         super.onLeaveWorld(destIsVisiting);
         if(Global.hud)
         {
            Global.hud.removeBottomHudCasablancaInnovationButton();
         }
      }
   }
}

