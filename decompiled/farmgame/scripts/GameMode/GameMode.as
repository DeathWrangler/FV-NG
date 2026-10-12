package GameMode
{
   import Display.UI;
   import Engine.Interfaces.IInputHandler;
   import Engine.IsoMath;
   import Engine.Managers.InputManager;
   import GameMode.ModeComponents.IGameModeComponent;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class GameMode implements IInputHandler
   {
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      protected static const TILE_OUTLINE_BORDER_WIDTH:int = 2;
      
      public static const EVENT_PPH_WARNING_TRACTOR:String = "PPHEventTractor";
      
      public static const EVENT_PPH_WARNING_PLOW:String = "PPHEventPlow";
      
      public static const AUTOSELECT_MIN_TURBO_PPH:int = 3;
      
      protected var m_enabled:Boolean = false;
      
      protected var m_cursorImage:Object = null;
      
      protected var m_cursorId:Number = 0;
      
      protected var m_mouseDownPos:Point;
      
      protected var m_captureMouse:Boolean = false;
      
      protected var m_scrollTimer:Timer = new Timer(125);
      
      protected var m_displayObject:Sprite = new Sprite();
      
      protected var m_components:Array;
      
      public function GameMode()
      {
         super();
      }
      
      public function getToolboxId() : String
      {
         return null;
      }
      
      public function enableMode() : void
      {
         InputManager.addHandler(this);
         if(this.m_captureMouse)
         {
            Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,1,true);
            Global.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,1,true);
         }
         if(this.m_cursorImage)
         {
            this.m_cursorId = UI.setCursor(this.m_cursorImage,false,this.shouldScaleCursor());
         }
         GlobalEngine.viewport.overlayBase.addChild(this.m_displayObject);
         this.m_enabled = true;
         this.addComponents();
         this.executeComponents("enableMode");
      }
      
      public function disableMode() : void
      {
         this.setViewScrollEnabled(false);
         this.m_enabled = false;
         InputManager.removeHandler(this);
         if(Global.stage != null)
         {
            Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
         if(this.m_cursorId != 0)
         {
            UI.removeCursor(this.m_cursorId);
            this.m_cursorId = 0;
         }
         if(Boolean(this.m_displayObject) && Boolean(this.m_displayObject.parent))
         {
            this.m_displayObject.parent.removeChild(this.m_displayObject);
         }
         this.executeComponents("disableMode");
      }
      
      protected function shouldScaleCursor() : Boolean
      {
         return true;
      }
      
      protected function setViewScrollEnabled(scrollEnabled:Boolean) : void
      {
         this.m_scrollTimer.removeEventListener(TimerEvent.TIMER,this.onScrollTimer);
         this.m_scrollTimer.stop();
         if(scrollEnabled)
         {
            this.m_scrollTimer.addEventListener(TimerEvent.TIMER,this.onScrollTimer);
            this.m_scrollTimer.start();
         }
      }
      
      protected function getMouseStagePos() : Point
      {
         return new Point(Global.stage.mouseX,Global.stage.mouseY);
      }
      
      protected function getMouseTilePos(event:MouseEvent = null) : Point
      {
         var mousePos:Point = null;
         if(event)
         {
            mousePos = new Point(event.stageX,event.stageY);
         }
         else
         {
            mousePos = this.getMouseStagePos();
         }
         return IsoMath.screenPosToTilePos(mousePos.x,mousePos.y);
      }
      
      protected function onScrollTimer(event:TimerEvent) : void
      {
      }
      
      public function onMouseOut(event:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onMouseDown(event:MouseEvent) : Boolean
      {
         this.m_mouseDownPos = new Point(event.stageX,event.stageY);
         Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,1,true);
         Global.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,1,true);
         return false;
      }
      
      public function onMouseUp(event:MouseEvent) : Boolean
      {
         this.m_mouseDownPos = null;
         Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         return false;
      }
      
      public function onMouseDoubleClick(event:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onMouseMove(event:MouseEvent) : Boolean
      {
         this.executeComponents("onMouseMove",event);
         return false;
      }
      
      public function onMouseWheel(event:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onKeyDown(event:KeyboardEvent) : Boolean
      {
         return false;
      }
      
      public function onKeyUp(event:KeyboardEvent) : Boolean
      {
         return false;
      }
      
      public function dispatchAddToStackEvent() : void
      {
      }
      
      protected function isDragging() : Boolean
      {
         return this.m_mouseDownPos != null;
      }
      
      public function canAdd() : Boolean
      {
         return true;
      }
      
      public function isFullscreenEnabled() : Boolean
      {
         return true;
      }
      
      protected function executeComponents(functionName:String, ... params) : void
      {
         var component:IGameModeComponent = null;
         for each(component in this.m_components)
         {
            component[functionName].apply(component,params);
         }
      }
      
      protected function addComponents() : void
      {
         this.m_components = new Array();
      }
   }
}

