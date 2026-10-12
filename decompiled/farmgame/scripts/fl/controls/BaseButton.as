package fl.controls
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   [Event(name="change",type="flash.events.Event")]
   [Event(name="buttonDown",type="fl.events.ComponentEvent")]
   public class BaseButton extends UIComponent
   {
      
      private static var defaultStyles:Object = {
         "upSkin":"Button_upSkin",
         "downSkin":"Button_downSkin",
         "overSkin":"Button_overSkin",
         "disabledSkin":"Button_disabledSkin",
         "selectedDisabledSkin":"Button_selectedDisabledSkin",
         "selectedUpSkin":"Button_selectedUpSkin",
         "selectedDownSkin":"Button_selectedDownSkin",
         "selectedOverSkin":"Button_selectedOverSkin",
         "focusRectSkin":null,
         "focusRectPadding":null,
         "repeatDelay":500,
         "repeatInterval":35
      };
      
      protected var pressTimer:Timer;
      
      protected var _autoRepeat:Boolean = false;
      
      protected var _selected:Boolean = false;
      
      protected var background:DisplayObject;
      
      private var unlockedMouseState:String;
      
      protected var mouseState:String;
      
      private var _mouseStateLocked:Boolean = false;
      
      public function BaseButton()
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         useHandCursor = false;
         setupMouseEvents();
         setMouseState("up");
         pressTimer = new Timer(1,0);
         pressTimer.addEventListener(TimerEvent.TIMER,buttonDown,false,0,true);
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      [Inspectable(defaultValue="true",verbose="1")]
      override public function get enabled() : Boolean
      {
         return super.enabled;
      }
      
      protected function startPress() : void
      {
         if(_autoRepeat)
         {
            pressTimer.delay = Number(getStyleValue("repeatDelay"));
            pressTimer.start();
         }
         dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN,true));
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.STYLES,InvalidationType.STATE))
         {
            drawBackground();
            invalidate(InvalidationType.SIZE,false);
         }
         if(isInvalid(InvalidationType.SIZE))
         {
            drawLayout();
         }
         super.draw();
      }
      
      protected function drawLayout() : void
      {
         background.width = width;
         background.height = height;
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         mouseEnabled = value;
      }
      
      public function set autoRepeat(value:Boolean) : void
      {
         _autoRepeat = value;
      }
      
      protected function mouseEventHandler(event:MouseEvent) : void
      {
         if(event.type == MouseEvent.MOUSE_DOWN)
         {
            setMouseState("down");
            startPress();
         }
         else if(event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_UP)
         {
            setMouseState("over");
            endPress();
         }
         else if(event.type == MouseEvent.ROLL_OUT)
         {
            setMouseState("up");
            endPress();
         }
      }
      
      protected function drawBackground() : void
      {
         var styleName:String = enabled ? mouseState : "disabled";
         if(selected)
         {
            styleName = "selected" + styleName.substr(0,1).toUpperCase() + styleName.substr(1);
         }
         styleName += "Skin";
         var bg:DisplayObject = background;
         background = getDisplayObjectInstance(getStyleValue(styleName));
         addChildAt(background,0);
         if(bg != null && bg != background)
         {
            removeChild(bg);
         }
      }
      
      public function get selected() : Boolean
      {
         return _selected;
      }
      
      protected function setupMouseEvents() : void
      {
         addEventListener(MouseEvent.ROLL_OVER,mouseEventHandler,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,mouseEventHandler,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,mouseEventHandler,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,mouseEventHandler,false,0,true);
      }
      
      protected function endPress() : void
      {
         pressTimer.reset();
      }
      
      public function set mouseStateLocked(value:Boolean) : void
      {
         _mouseStateLocked = value;
         if(value == false)
         {
            setMouseState(unlockedMouseState);
         }
         else
         {
            unlockedMouseState = mouseState;
         }
      }
      
      public function get autoRepeat() : Boolean
      {
         return _autoRepeat;
      }
      
      public function set selected(value:Boolean) : void
      {
         if(_selected == value)
         {
            return;
         }
         _selected = value;
         invalidate(InvalidationType.STATE);
      }
      
      protected function buttonDown(event:TimerEvent) : void
      {
         if(!_autoRepeat)
         {
            endPress();
            return;
         }
         if(pressTimer.currentCount == 1)
         {
            pressTimer.delay = Number(getStyleValue("repeatInterval"));
         }
         dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN,true));
      }
      
      public function setMouseState(state:String) : void
      {
         if(_mouseStateLocked)
         {
            unlockedMouseState = state;
            return;
         }
         if(mouseState == state)
         {
            return;
         }
         mouseState = state;
         invalidate(InvalidationType.STATE);
      }
   }
}

