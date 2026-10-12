package Managers
{
   import Classes.MapResource;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import GameMode.GMClear;
   import GameMode.GMDecoMove;
   import GameMode.GMRotate;
   import GameMode.GMStore;
   import GameMode.GameMode;
   import Widgets.Windows.DecoratorMode.DecoratorModeStorage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   
   public class DecoratorModeManager
   {
      
      private static var s_instance:DecoratorModeManager;
      
      public static const STATS_KINGDOM:String = "deco_mode";
      
      public static const CLOSE_EVENT:String = "DecoratorModeClose";
      
      public static const MOVE_MODE:String = "move_mode";
      
      public static const CLEAR_MODE:String = "clear_mode";
      
      public static const STORE_MODE:String = "store_mode";
      
      public static const ROTATE_MODE:String = "rotate_mode";
      
      private var m_gameModes:Object;
      
      private var m_defaultGameMode:String = "move_mode";
      
      private var m_storing:Boolean = false;
      
      public function DecoratorModeManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[DecoratorModeManager] :: Use instance()");
         Global.stage.addEventListener(KeyboardEvent.KEY_UP,this.onDecoratorModeKeyUp);
         this.m_gameModes = new Object();
         this.m_gameModes[MOVE_MODE] = new GMDecoMove();
         this.m_gameModes[CLEAR_MODE] = new GMClear();
         this.m_gameModes[STORE_MODE] = new GMStore();
         this.m_gameModes[ROTATE_MODE] = new GMRotate();
      }
      
      public static function get instance() : DecoratorModeManager
      {
         if(!s_instance)
         {
            s_instance = new DecoratorModeManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function startDecoMode() : void
      {
         var disableExpansionMarketing:Boolean = false;
         if(Global.player.postInitFinished)
         {
            Global.ui.visible = false;
            UI.displayPopup(new DecoratorModeStorage());
            StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"opens");
            this.setGameMode(this.m_defaultGameMode);
            disableExpansionMarketing = true;
            Global.world.createLotBG(true,true,disableExpansionMarketing);
         }
      }
      
      public function stopDecoMode() : void
      {
         Global.ui.visible = true;
         UI.suppressPopupQueue = false;
         this.resetGameMode();
         Global.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onDecoratorModeKeyUp);
         Global.world.createLotBG();
         Global.stage.dispatchEvent(new Event(DecoratorModeManager.CLOSE_EVENT));
      }
      
      public function setGameMode(mode:String) : void
      {
         var success:Boolean = false;
         var gm:GameMode = this.m_gameModes[mode];
         if(gm != null)
         {
            Global.world.addGameMode(gm);
            success = Global.world.acquireDefaultGameMode(gm,this);
            if(!success)
            {
               throw new Error("Decorator Mode Manager - Could not acquire lock on default Game Mode when setting Game Mode");
            }
         }
      }
      
      private function resetGameMode() : void
      {
         var success:Boolean = Global.world.resetDefaultGameMode(this);
         if(!success)
         {
            throw new Error("Decorator Mode Manager - Could not release lock on default Game Mode when disabling");
         }
         Global.world.setDefaultGameMode();
      }
      
      public function storeItem(mapResource:MapResource) : Boolean
      {
         var success:Boolean = false;
         if(mapResource.canAddToInventory())
         {
            this.m_storing = true;
            mapResource.addToInventory();
            mapResource.detach();
            this.m_storing = false;
            success = true;
         }
         return success;
      }
      
      public function get storing() : Boolean
      {
         return this.m_storing;
      }
      
      public function onDecoratorModeKeyUp(event:KeyboardEvent) : void
      {
         if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_M)
         {
            this.setGameMode(MOVE_MODE);
         }
         else if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_R)
         {
            this.setGameMode(ROTATE_MODE);
         }
         else if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_S)
         {
            this.setGameMode(STORE_MODE);
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
