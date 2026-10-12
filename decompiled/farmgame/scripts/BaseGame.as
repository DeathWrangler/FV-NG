package
{
   import Engine.Classes.Viewport;
   import Engine.Classes.ZEngineCoreModules;
   import Engine.Classes.ZEngineOptions;
   import Engine.Constants;
   import Engine.Init.InitializationManager;
   import Engine.Interfaces.IEngineComponent;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Engine.Managers.ZaspManager;
   import Engine.Profiler.PlaytimeMonitor;
   import Engine.Profiler.ProdAggregator;
   import Engine.Utilities;
   import cipro.Profiler.RuntimeProfiler;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   
   public class BaseGame extends Sprite
   {
      
      public var parameters:Object = null;
      
      protected var gameUpdateFunction:Function = null;
      
      public function BaseGame(param1:Object = null, param2:ZEngineOptions = null)
      {
         super();
         Security.allowDomain("*.zynga.com");
         Security.allowDomain("http://static.ak.fbcdn.net/");
         if(LoaderInfo(this.root.loaderInfo).parameters)
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         }
         var _loc3_:ContextMenu = new ContextMenu();
         _loc3_.hideBuiltInItems();
         contextMenu = _loc3_;
         if(param2 == null)
         {
            param2 = new ZEngineOptions();
         }
         GlobalEngine.engineOptions = param2;
         GlobalEngine.initializationManager = new InitializationManager();
         ZEngineCoreModules.initialize();
         Constants.TILE_WIDTH = param2.tileWidth;
         Constants.TILE_HEIGHT = param2.tileHeight;
         Constants.TILE_SCALE = param2.tileScale;
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         if(this.parameters == null)
         {
            this.parameters = LoaderInfo(this.root.loaderInfo).parameters;
         }
         ProdAggregator.enable(this.parameters);
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.BaseGameOnAddedToStage);
         RuntimeProfiler.enableFrameCapture(this.stage);
         PlaytimeMonitor.enableFrameCapture(this.stage);
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.stage.scaleMode = StageScaleMode.NO_SCALE;
         this.stage.align = StageAlign.TOP_LEFT;
         this.initEngine();
         this.init();
         RuntimeProfiler.leave(_loc2_);
      }
      
      private function initEngine() : void
      {
         var _loc2_:int = 0;
         GlobalEngine.stage = this.stage;
         GlobalEngine.stage.addEventListener(Event.ENTER_FRAME,this.onEngineEnterFrame,false,10000);
         GlobalEngine.viewport = new GlobalEngine.engineOptions.viewportClass() as Viewport;
         GlobalEngine.parseFlashVars(this.parameters);
         if(GlobalEngine.getFlashVar(ZaspManager.SESSION_KEY_FLASHVAR))
         {
            if(GlobalEngine.engineOptions.zaspManagerClass)
            {
               GlobalEngine.zaspManager = new GlobalEngine.engineOptions.zaspManagerClass(GlobalEngine.stage) as ZaspManager;
               if(GlobalEngine.getFlashVar(ZaspManager.DEBUG_FLASHVAR) == "true")
               {
                  GlobalEngine.zaspManager.forceActivateDebugTracking(this);
               }
            }
         }
         GlobalEngine.stage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreenChanged);
         ErrorManager.getInstance().addEventListener(ErrorEvent.ERROR,this.onError);
         TransactionManager.initialize();
         var _loc1_:Vector.<IEngineComponent> = GlobalEngine.engineOptions.engineComponents;
         if(_loc1_ != null)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _loc1_[_loc2_].initialize();
               _loc2_++;
            }
         }
         GlobalEngine.log("Init","Base URL: " + Config.SERVICES_GATEWAY_PATH);
         GlobalEngine.log("Init","Asset URLs: " + Config.ASSET_PATHS.join(", "));
      }
      
      private function onEngineEnterFrame(param1:Event) : void
      {
         var _loc2_:int = RuntimeProfiler.enter(ZEngineCoreModules.BaseGameOnEngineEnterFrame);
         GlobalEngine.updateTimers();
         if(this.gameUpdateFunction != null)
         {
            this.gameUpdateFunction(param1);
         }
         RuntimeProfiler.leave(_loc2_);
      }
      
      protected function init() : void
      {
      }
      
      protected function onError(param1:ErrorEvent) : void
      {
      }
      
      protected function onFullScreenChanged(param1:FullScreenEvent) : void
      {
         if(GlobalEngine.viewport)
         {
            GlobalEngine.viewport.centerViewport();
         }
      }
      
      public function disableAllInput() : void
      {
         Utilities.toggleInputOnlyChildren(GlobalEngine.stage,false);
         InputManager.disableInput();
      }
      
      public function enableAllInput() : void
      {
         Utilities.toggleInputOnlyChildren(GlobalEngine.stage,true);
         InputManager.enableInput();
      }
   }
}

