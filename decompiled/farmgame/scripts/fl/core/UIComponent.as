package fl.core
{
   import fl.events.ComponentEvent;
   import fl.managers.FocusManager;
   import fl.managers.IFocusManager;
   import fl.managers.IFocusManagerComponent;
   import fl.managers.StyleManager;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.system.IME;
   import flash.system.IMEConversionMode;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="hide",type="fl.events.ComponentEvent")]
   [Event(name="show",type="fl.events.ComponentEvent")]
   [Event(name="resize",type="fl.events.ComponentEvent")]
   [Event(name="move",type="fl.events.ComponentEvent")]
   public class UIComponent extends Sprite
   {
      
      public static var createAccessibilityImplementation:Function;
      
      public static var inCallLaterPhase:Boolean = false;
      
      private static var defaultStyles:Object = {
         "focusRectSkin":"focusRectSkin",
         "focusRectPadding":2,
         "textFormat":new TextFormat("_sans",11,0,false,false,false,"","",TextFormatAlign.LEFT,0,0,0,0),
         "disabledTextFormat":new TextFormat("_sans",11,10066329,false,false,false,"","",TextFormatAlign.LEFT,0,0,0,0),
         "defaultTextFormat":new TextFormat("_sans",11,0,false,false,false,"","",TextFormatAlign.LEFT,0,0,0,0),
         "defaultDisabledTextFormat":new TextFormat("_sans",11,10066329,false,false,false,"","",TextFormatAlign.LEFT,0,0,0,0)
      };
      
      private static var focusManagers:Dictionary = new Dictionary(false);
      
      protected var _x:Number;
      
      protected var _enabled:Boolean = true;
      
      protected var callLaterMethods:Dictionary;
      
      private var _mouseFocusEnabled:Boolean = true;
      
      private var tempText:TextField;
      
      private var _focusEnabled:Boolean = true;
      
      protected var startHeight:Number;
      
      protected var _height:Number;
      
      protected var invalidateFlag:Boolean = false;
      
      protected var _oldIMEMode:String = null;
      
      protected var _inspector:Boolean = false;
      
      protected var startWidth:Number;
      
      public var focusTarget:IFocusManagerComponent;
      
      protected var errorCaught:Boolean = false;
      
      protected var invalidHash:Object;
      
      protected var sharedStyles:Object;
      
      protected var uiFocusRect:DisplayObject;
      
      protected var isLivePreview:Boolean = false;
      
      protected var _imeMode:String = null;
      
      protected var _width:Number;
      
      protected var instanceStyles:Object;
      
      public var version:String = "3.0.0.15";
      
      protected var isFocused:Boolean = false;
      
      protected var _y:Number;
      
      public function UIComponent()
      {
         super();
         instanceStyles = {};
         sharedStyles = {};
         invalidHash = {};
         callLaterMethods = new Dictionary();
         StyleManager.registerInstance(this);
         configUI();
         invalidate(InvalidationType.ALL);
         tabEnabled = this is IFocusManagerComponent;
         focusRect = false;
         if(tabEnabled)
         {
            addEventListener(FocusEvent.FOCUS_IN,focusInHandler);
            addEventListener(FocusEvent.FOCUS_OUT,focusOutHandler);
            addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
            addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
         }
         initializeFocusManager();
         addEventListener(Event.ENTER_FRAME,hookAccessibility,false,0,true);
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      public static function mergeStyles(... list) : Object
      {
         var styleList:Object = null;
         var n:String = null;
         var styles:Object = {};
         var l:uint = uint(list.length);
         for(var i:uint = 0; i < l; i++)
         {
            styleList = list[i];
            for(n in styleList)
            {
               if(styles[n] == null)
               {
                  styles[n] = list[i][n];
               }
            }
         }
         return styles;
      }
      
      public function getStyle(style:String) : Object
      {
         return instanceStyles[style];
      }
      
      protected function checkLivePreview() : Boolean
      {
         var className:String = null;
         if(parent == null)
         {
            return false;
         }
         try
         {
            className = getQualifiedClassName(parent);
         }
         catch(e:Error)
         {
         }
         return className == "fl.livepreview::LivePreviewParent";
      }
      
      private function callLaterDispatcher(event:Event) : void
      {
         var method:Object = null;
         if(event.type == Event.ADDED_TO_STAGE)
         {
            removeEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher);
            stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
            stage.invalidate();
            return;
         }
         event.target.removeEventListener(Event.RENDER,callLaterDispatcher);
         if(stage == null)
         {
            addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
            return;
         }
         inCallLaterPhase = true;
         var methods:Dictionary = callLaterMethods;
         for(method in methods)
         {
            method();
            delete methods[method];
         }
         inCallLaterPhase = false;
      }
      
      protected function validate() : void
      {
         invalidHash = {};
      }
      
      protected function focusOutHandler(event:FocusEvent) : void
      {
         if(isOurFocus(event.target as DisplayObject))
         {
            drawFocus(false);
            isFocused = false;
         }
      }
      
      public function set mouseFocusEnabled(b:Boolean) : void
      {
         _mouseFocusEnabled = b;
      }
      
      public function getFocus() : InteractiveObject
      {
         if(stage)
         {
            return stage.focus;
         }
         return null;
      }
      
      override public function get height() : Number
      {
         return _height;
      }
      
      private function addedHandler(evt:Event) : void
      {
         removeEventListener("addedToStage",addedHandler);
         initializeFocusManager();
      }
      
      protected function getStyleValue(name:String) : Object
      {
         return instanceStyles[name] == null ? sharedStyles[name] : instanceStyles[name];
      }
      
      public function invalidate(property:String = "all", callLater:Boolean = true) : void
      {
         invalidHash[property] = true;
         if(callLater)
         {
            this.callLater(draw);
         }
      }
      
      protected function isOurFocus(target:DisplayObject) : Boolean
      {
         return target == this;
      }
      
      [Inspectable(defaultValue="true",verbose="1")]
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      protected function getScaleX() : Number
      {
         return super.scaleX;
      }
      
      protected function getScaleY() : Number
      {
         return super.scaleY;
      }
      
      public function get focusEnabled() : Boolean
      {
         return _focusEnabled;
      }
      
      protected function afterComponentParameters() : void
      {
      }
      
      override public function get scaleY() : Number
      {
         return height / startHeight;
      }
      
      protected function setIMEMode(enabled:Boolean) : void
      {
         if(_imeMode != null)
         {
            if(enabled)
            {
               IME.enabled = true;
               _oldIMEMode = IME.conversionMode;
               try
               {
                  if(!errorCaught && IME.conversionMode != IMEConversionMode.UNKNOWN)
                  {
                     IME.conversionMode = _imeMode;
                  }
                  errorCaught = false;
               }
               catch(e:Error)
               {
                  errorCaught = true;
                  throw new Error("IME mode not supported: " + _imeMode);
               }
            }
            else
            {
               if(IME.conversionMode != IMEConversionMode.UNKNOWN && _oldIMEMode != IMEConversionMode.UNKNOWN)
               {
                  IME.conversionMode = _oldIMEMode;
               }
               IME.enabled = false;
            }
         }
      }
      
      protected function draw() : void
      {
         if(isInvalid(InvalidationType.SIZE,InvalidationType.STYLES))
         {
            if(isFocused && focusManager.showFocusIndicator)
            {
               drawFocus(true);
            }
         }
         validate();
      }
      
      override public function set height(value:Number) : void
      {
         if(_height == value)
         {
            return;
         }
         setSize(width,value);
      }
      
      protected function configUI() : void
      {
         isLivePreview = checkLivePreview();
         var r:Number = rotation;
         rotation = 0;
         var w:Number = super.width;
         var h:Number = super.height;
         super.scaleX = super.scaleY = 1;
         setSize(w,h);
         move(super.x,super.y);
         rotation = r;
         startWidth = w;
         startHeight = h;
         if(numChildren > 0)
         {
            removeChildAt(0);
         }
      }
      
      protected function setScaleY(value:Number) : void
      {
         super.scaleY = value;
      }
      
      override public function get scaleX() : Number
      {
         return width / startWidth;
      }
      
      protected function setScaleX(value:Number) : void
      {
         super.scaleX = value;
      }
      
      private function initializeFocusManager() : void
      {
         if(stage == null)
         {
            addEventListener(Event.ADDED_TO_STAGE,addedHandler,false,0,true);
         }
         else
         {
            createFocusManager();
         }
      }
      
      protected function keyDownHandler(event:KeyboardEvent) : void
      {
      }
      
      public function set focusManager(f:IFocusManager) : void
      {
         UIComponent.focusManagers[this] = f;
      }
      
      public function clearStyle(style:String) : void
      {
         setStyle(style,null);
      }
      
      protected function isInvalid(property:String, ... properties) : Boolean
      {
         if(Boolean(invalidHash[property]) || Boolean(invalidHash[InvalidationType.ALL]))
         {
            return true;
         }
         while(properties.length > 0)
         {
            if(invalidHash[properties.pop()])
            {
               return true;
            }
         }
         return false;
      }
      
      public function setStyle(style:String, value:Object) : void
      {
         if(instanceStyles[style] === value && !(value is TextFormat))
         {
            return;
         }
         instanceStyles[style] = value;
         invalidate(InvalidationType.STYLES);
      }
      
      [Inspectable(defaultValue="true",verbose="1")]
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      protected function focusInHandler(event:FocusEvent) : void
      {
         var fm:IFocusManager = null;
         if(isOurFocus(event.target as DisplayObject))
         {
            fm = focusManager;
            if(Boolean(fm) && fm.showFocusIndicator)
            {
               drawFocus(true);
               isFocused = true;
            }
         }
      }
      
      public function get componentInspectorSetting() : Boolean
      {
         return _inspector;
      }
      
      override public function get x() : Number
      {
         return isNaN(_x) ? super.x : _x;
      }
      
      override public function get y() : Number
      {
         return isNaN(_y) ? super.y : _y;
      }
      
      public function set enabled(value:Boolean) : void
      {
         if(value == _enabled)
         {
            return;
         }
         _enabled = value;
         invalidate(InvalidationType.STATE);
      }
      
      public function setSize(width:Number, height:Number) : void
      {
         _width = width;
         _height = height;
         invalidate(InvalidationType.SIZE);
         dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE,false));
      }
      
      protected function keyUpHandler(event:KeyboardEvent) : void
      {
      }
      
      public function setSharedStyle(name:String, style:Object) : void
      {
         if(sharedStyles[name] === style && !(style is TextFormat))
         {
            return;
         }
         sharedStyles[name] = style;
         if(instanceStyles[name] == null)
         {
            invalidate(InvalidationType.STYLES);
         }
      }
      
      public function set focusEnabled(b:Boolean) : void
      {
         _focusEnabled = b;
      }
      
      override public function set width(value:Number) : void
      {
         if(_width == value)
         {
            return;
         }
         setSize(value,height);
      }
      
      public function setFocus() : void
      {
         if(stage)
         {
            stage.focus = this;
         }
      }
      
      override public function set scaleX(value:Number) : void
      {
         setSize(startWidth * value,height);
      }
      
      public function get mouseFocusEnabled() : Boolean
      {
         return _mouseFocusEnabled;
      }
      
      override public function set scaleY(value:Number) : void
      {
         setSize(width,startHeight * value);
      }
      
      protected function getDisplayObjectInstance(skin:Object) : DisplayObject
      {
         var classDef:Object = null;
         if(skin is Class)
         {
            return new skin() as DisplayObject;
         }
         if(skin is DisplayObject)
         {
            (skin as DisplayObject).x = 0;
            (skin as DisplayObject).y = 0;
            return skin as DisplayObject;
         }
         try
         {
            classDef = getDefinitionByName(skin.toString());
         }
         catch(e:Error)
         {
            try
            {
               classDef = loaderInfo.applicationDomain.getDefinition(skin.toString()) as Object;
            }
            catch(e:Error)
            {
            }
         }
         if(classDef == null)
         {
            return null;
         }
         return new classDef() as DisplayObject;
      }
      
      protected function copyStylesToChild(child:UIComponent, styleMap:Object) : void
      {
         var n:String = null;
         for(n in styleMap)
         {
            child.setStyle(n,getStyleValue(styleMap[n]));
         }
      }
      
      protected function initializeAccessibility() : void
      {
         if(UIComponent.createAccessibilityImplementation != null)
         {
            UIComponent.createAccessibilityImplementation(this);
         }
      }
      
      public function get focusManager() : IFocusManager
      {
         var o:DisplayObject = this;
         while(o)
         {
            if(UIComponent.focusManagers[o] != null)
            {
               return IFocusManager(UIComponent.focusManagers[o]);
            }
            o = o.parent;
         }
         return null;
      }
      
      override public function get width() : Number
      {
         return _width;
      }
      
      protected function beforeComponentParameters() : void
      {
      }
      
      protected function callLater(fn:Function) : void
      {
         if(inCallLaterPhase)
         {
            return;
         }
         callLaterMethods[fn] = true;
         if(stage != null)
         {
            stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
            stage.invalidate();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
         }
      }
      
      public function move(x:Number, y:Number) : void
      {
         _x = x;
         _y = y;
         super.x = Math.round(x);
         super.y = Math.round(y);
         dispatchEvent(new ComponentEvent(ComponentEvent.MOVE));
      }
      
      public function validateNow() : void
      {
         invalidate(InvalidationType.ALL,false);
         draw();
      }
      
      override public function set visible(value:Boolean) : void
      {
         if(super.visible == value)
         {
            return;
         }
         super.visible = value;
         var t:String = value ? ComponentEvent.SHOW : ComponentEvent.HIDE;
         dispatchEvent(new ComponentEvent(t,true));
      }
      
      protected function createFocusManager() : void
      {
         if(focusManagers[stage] == null)
         {
            focusManagers[stage] = new FocusManager(stage);
         }
      }
      
      protected function hookAccessibility(event:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,hookAccessibility);
         initializeAccessibility();
      }
      
      public function set componentInspectorSetting(value:Boolean) : void
      {
         _inspector = value;
         if(_inspector)
         {
            beforeComponentParameters();
         }
         else
         {
            afterComponentParameters();
         }
      }
      
      override public function set y(value:Number) : void
      {
         move(_x,value);
      }
      
      public function drawFocus(focused:Boolean) : void
      {
         var focusPadding:Number = NaN;
         isFocused = focused;
         if(uiFocusRect != null && contains(uiFocusRect))
         {
            removeChild(uiFocusRect);
            uiFocusRect = null;
         }
         if(focused)
         {
            uiFocusRect = getDisplayObjectInstance(getStyleValue("focusRectSkin")) as Sprite;
            if(uiFocusRect == null)
            {
               return;
            }
            focusPadding = Number(getStyleValue("focusRectPadding"));
            uiFocusRect.x = -focusPadding;
            uiFocusRect.y = -focusPadding;
            uiFocusRect.width = width + focusPadding * 2;
            uiFocusRect.height = height + focusPadding * 2;
            addChildAt(uiFocusRect,0);
         }
      }
      
      override public function set x(value:Number) : void
      {
         move(value,_y);
      }
      
      public function drawNow() : void
      {
         draw();
      }
   }
}

