package Classes.Managers
{
   import Classes.*;
   import Display.HUD.HUDWidgets.HUDBottomTutorialButton;
   import Display.HUD.HUDWidgets.HUDHomeWidget;
   import Display.HUD.HUDWidgets.HUDTutorialButton;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import Display.HUD.HUDWidgets.HUDWidget;
   import Engine.Managers.StatsManager;
   import flash.events.Event;
   
   public class HUDTutorialManager
   {
      
      private static var m_instance:HUDTutorialManager;
      
      public static const EVENT_CONTINUE:String = "event_continue";
      
      private var m_states:HUDTutorialStateContainer;
      
      private var m_showBottomHud:Boolean = false;
      
      private var m_hudTutorial:HUDTutorialWindow;
      
      private var m_hudTutorialButton:HUDWidget;
      
      private var m_bottomHudTutorialButton:HUDWidget;
      
      private var m_onTutorialCompleCallback:Function;
      
      private var m_canGlowOnHover:Boolean = false;
      
      public function HUDTutorialManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"Invalid TutorialManager Singleton access. Use TutorialManager.instance");
      }
      
      public static function get instance() : HUDTutorialManager
      {
         if(!m_instance)
         {
            m_instance = new HUDTutorialManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function initialize(featureName:String, onTutorialCompleteCallBackFunction:Function = null, showBottomHud:Boolean = false) : void
      {
         this.m_states = new HUDTutorialStateContainer(m_instance,featureName);
         this.m_showBottomHud = showBottomHud;
         this.m_hudTutorial = new HUDTutorialWindow(this);
         if(!this.m_states.hasWindow())
         {
            this.m_hudTutorial.release();
         }
         this.m_onTutorialCompleCallback = onTutorialCompleteCallBackFunction;
      }
      
      public function launchTutorial() : void
      {
         Global.world.addEventListener(HUDHomeWidget.TRAVEL_HOME,this.releaseTutorialWidget);
         this.m_states.initialize();
      }
      
      public function get hudTutorial() : HUDTutorialWindow
      {
         return this.m_hudTutorial;
      }
      
      public function step() : void
      {
         this.m_states.step();
      }
      
      public function initializeBottomHud(featureName:String, addGlow:Boolean = false) : void
      {
         this.m_states = new HUDTutorialStateContainer(m_instance,featureName);
         if(this.m_states.getHasReplay())
         {
            if(this.m_bottomHudTutorialButton)
            {
               this.m_bottomHudTutorialButton.release();
               this.m_bottomHudTutorialButton = null;
            }
            if(addGlow)
            {
               this.m_canGlowOnHover = true;
            }
            this.m_bottomHudTutorialButton = new HUDBottomTutorialButton(this.m_states.getHudIconPath(),this.m_states.getHudToolTipKey(),this.m_states.getFeatureName(),this.m_states.getXoffSet(),this.m_states.getYoffSet(),addGlow);
            Global.hud.setBottomHudTutorialButton(this.m_bottomHudTutorialButton as HUDBottomTutorialButton);
         }
      }
      
      public function stop() : void
      {
         if(this.m_hudTutorial)
         {
            this.m_hudTutorial.release();
         }
         this.m_hudTutorial = null;
         Global.player.setSeenFlag(this.m_states.getSeenFlag(),true);
         Global.hud.conditionallyRefreshHUD();
         if(this.m_states.getHasReplay())
         {
            if(this.m_showBottomHud)
            {
               if(this.m_bottomHudTutorialButton)
               {
                  this.m_bottomHudTutorialButton.release();
                  this.m_bottomHudTutorialButton = null;
               }
               if(!this.m_canGlowOnHover)
               {
                  this.m_bottomHudTutorialButton = new HUDBottomTutorialButton(this.m_states.getHudIconPath(),this.m_states.getHudToolTipKey(),this.m_states.getFeatureName(),this.m_states.getXoffSet(),this.m_states.getYoffSet());
               }
               else
               {
                  this.m_bottomHudTutorialButton = new HUDBottomTutorialButton(this.m_states.getHudIconPath(),this.m_states.getHudToolTipKey(),this.m_states.getFeatureName(),this.m_states.getXoffSet(),this.m_states.getYoffSet(),true);
               }
               Global.hud.setBottomHudTutorialButton(this.m_bottomHudTutorialButton as HUDBottomTutorialButton);
            }
            else
            {
               if(this.m_hudTutorialButton)
               {
                  this.m_hudTutorialButton.release();
                  this.m_hudTutorialButton = null;
               }
               this.m_hudTutorialButton = new HUDTutorialButton(this.m_states.getHudIconPath(),this.m_states.getHudToolTipKey(),this.m_states.getFeatureName());
            }
         }
         if(this.m_onTutorialCompleCallback != null)
         {
            this.m_onTutorialCompleCallback();
         }
         var statCounters:Array = this.m_states.getStatCounters();
         if(Boolean(statCounters) && Boolean(statCounters[0]) && Boolean(statCounters[1]) && Boolean(statCounters[2]))
         {
            StatsManager.count(statCounters[0],statCounters[1],statCounters[2]);
         }
         Global.player.setSeenFlag(this.m_states.getFeatureName() + "_ftue_complete");
      }
      
      public function getStateContainer() : HUDTutorialStateContainer
      {
         return this.m_states;
      }
      
      public function toggleWindowVisibility(toggle:Boolean) : void
      {
         this.m_hudTutorial.toggleWindowVisibility(toggle);
      }
      
      public function releaseTutorialWidget(event:Event = null) : void
      {
         if(Global.world.hasEventListener(HUDHomeWidget.TRAVEL_HOME))
         {
            Global.world.removeEventListener(HUDHomeWidget.TRAVEL_HOME,this.releaseTutorialWidget);
         }
         if(this.m_hudTutorial)
         {
            this.m_hudTutorial.release();
            this.m_hudTutorial = null;
         }
         if(this.m_hudTutorialButton)
         {
            this.m_hudTutorialButton.release();
            this.m_hudTutorialButton = null;
         }
         if(this.m_bottomHudTutorialButton)
         {
            this.m_bottomHudTutorialButton.release();
            this.m_bottomHudTutorialButton = null;
         }
         if(this.m_states)
         {
            this.m_states.release();
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
