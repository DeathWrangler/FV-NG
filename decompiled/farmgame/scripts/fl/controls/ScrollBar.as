package fl.controls
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import fl.events.ScrollEvent;
   import flash.events.MouseEvent;
   
   [Event(name="scroll",type="fl.events.ScrollEvent")]
   public class ScrollBar extends UIComponent
   {
      
      public static const WIDTH:Number = 15;
      
      private static var defaultStyles:Object = {
         "downArrowDisabledSkin":"ScrollArrowDown_disabledSkin",
         "downArrowDownSkin":"ScrollArrowDown_downSkin",
         "downArrowOverSkin":"ScrollArrowDown_overSkin",
         "downArrowUpSkin":"ScrollArrowDown_upSkin",
         "thumbDisabledSkin":"ScrollThumb_upSkin",
         "thumbDownSkin":"ScrollThumb_downSkin",
         "thumbOverSkin":"ScrollThumb_overSkin",
         "thumbUpSkin":"ScrollThumb_upSkin",
         "trackDisabledSkin":"ScrollTrack_skin",
         "trackDownSkin":"ScrollTrack_skin",
         "trackOverSkin":"ScrollTrack_skin",
         "trackUpSkin":"ScrollTrack_skin",
         "upArrowDisabledSkin":"ScrollArrowUp_disabledSkin",
         "upArrowDownSkin":"ScrollArrowUp_downSkin",
         "upArrowOverSkin":"ScrollArrowUp_overSkin",
         "upArrowUpSkin":"ScrollArrowUp_upSkin",
         "thumbIcon":"ScrollBar_thumbIcon",
         "repeatDelay":500,
         "repeatInterval":35
      };
      
      protected static const DOWN_ARROW_STYLES:Object = {
         "disabledSkin":"downArrowDisabledSkin",
         "downSkin":"downArrowDownSkin",
         "overSkin":"downArrowOverSkin",
         "upSkin":"downArrowUpSkin",
         "repeatDelay":"repeatDelay",
         "repeatInterval":"repeatInterval"
      };
      
      protected static const THUMB_STYLES:Object = {
         "disabledSkin":"thumbDisabledSkin",
         "downSkin":"thumbDownSkin",
         "overSkin":"thumbOverSkin",
         "upSkin":"thumbUpSkin",
         "icon":"thumbIcon",
         "textPadding":0
      };
      
      protected static const TRACK_STYLES:Object = {
         "disabledSkin":"trackDisabledSkin",
         "downSkin":"trackDownSkin",
         "overSkin":"trackOverSkin",
         "upSkin":"trackUpSkin",
         "repeatDelay":"repeatDelay",
         "repeatInterval":"repeatInterval"
      };
      
      protected static const UP_ARROW_STYLES:Object = {
         "disabledSkin":"upArrowDisabledSkin",
         "downSkin":"upArrowDownSkin",
         "overSkin":"upArrowOverSkin",
         "upSkin":"upArrowUpSkin",
         "repeatDelay":"repeatDelay",
         "repeatInterval":"repeatInterval"
      };
      
      private var _direction:String = "vertical";
      
      private var _minScrollPosition:Number = 0;
      
      private var _pageSize:Number = 10;
      
      private var _maxScrollPosition:Number = 0;
      
      protected var downArrow:BaseButton;
      
      private var _lineScrollSize:Number = 1;
      
      protected var upArrow:BaseButton;
      
      private var _scrollPosition:Number = 0;
      
      private var thumbScrollOffset:Number;
      
      protected var track:BaseButton;
      
      protected var thumb:LabelButton;
      
      protected var inDrag:Boolean = false;
      
      private var _pageScrollSize:Number = 0;
      
      public function ScrollBar()
      {
         super();
         setStyles();
         focusEnabled = false;
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         downArrow.enabled = track.enabled = thumb.enabled = upArrow.enabled = enabled && _maxScrollPosition > _minScrollPosition;
         updateThumb();
      }
      
      override public function setSize(width:Number, height:Number) : void
      {
         if(_direction == ScrollBarDirection.HORIZONTAL)
         {
            super.setSize(height,width);
         }
         else
         {
            super.setSize(width,height);
         }
      }
      
      public function set lineScrollSize(value:Number) : void
      {
         if(value > 0)
         {
            _lineScrollSize = value;
         }
      }
      
      public function get minScrollPosition() : Number
      {
         return _minScrollPosition;
      }
      
      protected function updateThumb() : void
      {
         var per:Number = _maxScrollPosition - _minScrollPosition + _pageSize;
         if(track.height <= 12 || _maxScrollPosition <= _minScrollPosition || (per == 0 || isNaN(per)))
         {
            thumb.height = 12;
            thumb.visible = false;
         }
         else
         {
            thumb.height = Math.max(13,_pageSize / per * track.height);
            thumb.y = track.y + (track.height - thumb.height) * ((_scrollPosition - _minScrollPosition) / (_maxScrollPosition - _minScrollPosition));
            thumb.visible = enabled;
         }
      }
      
      public function set minScrollPosition(value:Number) : void
      {
         setScrollProperties(_pageSize,value,_maxScrollPosition);
      }
      
      public function get lineScrollSize() : Number
      {
         return _lineScrollSize;
      }
      
      public function setScrollPosition(newScrollPosition:Number, fireEvent:Boolean = true) : void
      {
         var oldPosition:Number = scrollPosition;
         _scrollPosition = Math.max(_minScrollPosition,Math.min(_maxScrollPosition,newScrollPosition));
         if(oldPosition == _scrollPosition)
         {
            return;
         }
         if(fireEvent)
         {
            dispatchEvent(new ScrollEvent(_direction,scrollPosition - oldPosition,scrollPosition));
         }
         updateThumb();
      }
      
      public function get maxScrollPosition() : Number
      {
         return _maxScrollPosition;
      }
      
      public function get scrollPosition() : Number
      {
         return _scrollPosition;
      }
      
      override public function get height() : Number
      {
         return _direction == ScrollBarDirection.HORIZONTAL ? super.width : super.height;
      }
      
      public function get pageSize() : Number
      {
         return _pageSize;
      }
      
      public function set maxScrollPosition(value:Number) : void
      {
         setScrollProperties(_pageSize,_minScrollPosition,value);
      }
      
      protected function thumbReleaseHandler(event:MouseEvent) : void
      {
         inDrag = false;
         mouseChildren = true;
         thumb.mouseStateLocked = false;
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleThumbDrag);
         stage.removeEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler);
      }
      
      public function set pageScrollSize(value:Number) : void
      {
         if(value >= 0)
         {
            _pageScrollSize = value;
         }
      }
      
      public function set scrollPosition(newScrollPosition:Number) : void
      {
         setScrollPosition(newScrollPosition,true);
      }
      
      override public function get enabled() : Boolean
      {
         return super.enabled;
      }
      
      override protected function draw() : void
      {
         var h:Number = NaN;
         if(isInvalid(InvalidationType.SIZE))
         {
            h = super.height;
            downArrow.move(0,Math.max(upArrow.height,h - downArrow.height));
            track.setSize(WIDTH,Math.max(0,h - (downArrow.height + upArrow.height)));
            updateThumb();
         }
         if(isInvalid(InvalidationType.STYLES,InvalidationType.STATE))
         {
            setStyles();
         }
         downArrow.drawNow();
         upArrow.drawNow();
         track.drawNow();
         thumb.drawNow();
         validate();
      }
      
      override public function get width() : Number
      {
         return _direction == ScrollBarDirection.HORIZONTAL ? super.height : super.width;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         track = new BaseButton();
         track.move(0,14);
         track.useHandCursor = false;
         track.autoRepeat = true;
         track.focusEnabled = false;
         addChild(track);
         thumb = new LabelButton();
         thumb.label = "";
         thumb.setSize(WIDTH,15);
         thumb.move(0,15);
         thumb.focusEnabled = false;
         addChild(thumb);
         downArrow = new BaseButton();
         downArrow.setSize(WIDTH,14);
         downArrow.autoRepeat = true;
         downArrow.focusEnabled = false;
         addChild(downArrow);
         upArrow = new BaseButton();
         upArrow.setSize(WIDTH,14);
         upArrow.move(0,0);
         upArrow.autoRepeat = true;
         upArrow.focusEnabled = false;
         addChild(upArrow);
         upArrow.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
         downArrow.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
         track.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
         thumb.addEventListener(MouseEvent.MOUSE_DOWN,thumbPressHandler,false,0,true);
         enabled = false;
      }
      
      public function set pageSize(value:Number) : void
      {
         if(value > 0)
         {
            _pageSize = value;
         }
      }
      
      public function setScrollProperties(pageSize:Number, minScrollPosition:Number, maxScrollPosition:Number, pageScrollSize:Number = 0) : void
      {
         this.pageSize = pageSize;
         _minScrollPosition = minScrollPosition;
         _maxScrollPosition = maxScrollPosition;
         if(pageScrollSize >= 0)
         {
            _pageScrollSize = pageScrollSize;
         }
         enabled = _maxScrollPosition > _minScrollPosition;
         setScrollPosition(_scrollPosition,false);
         updateThumb();
      }
      
      public function get pageScrollSize() : Number
      {
         return _pageScrollSize == 0 ? _pageSize : _pageScrollSize;
      }
      
      protected function handleThumbDrag(event:MouseEvent) : void
      {
         var pos:Number = Math.max(0,Math.min(track.height - thumb.height,mouseY - track.y - thumbScrollOffset));
         setScrollPosition(pos / (track.height - thumb.height) * (_maxScrollPosition - _minScrollPosition) + _minScrollPosition);
      }
      
      protected function setStyles() : void
      {
         copyStylesToChild(downArrow,DOWN_ARROW_STYLES);
         copyStylesToChild(thumb,THUMB_STYLES);
         copyStylesToChild(track,TRACK_STYLES);
         copyStylesToChild(upArrow,UP_ARROW_STYLES);
      }
      
      protected function scrollPressHandler(event:ComponentEvent) : void
      {
         var mousePosition:Number = NaN;
         var pgScroll:Number = NaN;
         event.stopImmediatePropagation();
         if(event.currentTarget == upArrow)
         {
            setScrollPosition(_scrollPosition - _lineScrollSize);
         }
         else if(event.currentTarget == downArrow)
         {
            setScrollPosition(_scrollPosition + _lineScrollSize);
         }
         else
         {
            mousePosition = track.mouseY / track.height * (_maxScrollPosition - _minScrollPosition) + _minScrollPosition;
            pgScroll = pageScrollSize == 0 ? pageSize : pageScrollSize;
            if(_scrollPosition < mousePosition)
            {
               setScrollPosition(Math.min(mousePosition,_scrollPosition + pgScroll));
            }
            else if(_scrollPosition > mousePosition)
            {
               setScrollPosition(Math.max(mousePosition,_scrollPosition - pgScroll));
            }
         }
      }
      
      protected function thumbPressHandler(event:MouseEvent) : void
      {
         inDrag = true;
         thumbScrollOffset = mouseY - thumb.y;
         thumb.mouseStateLocked = true;
         mouseChildren = false;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,handleThumbDrag,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler,false,0,true);
      }
      
      public function set direction(value:String) : void
      {
         if(_direction == value)
         {
            return;
         }
         _direction = value;
         if(isLivePreview)
         {
            return;
         }
         setScaleY(1);
         var horizontal:Boolean = _direction == ScrollBarDirection.HORIZONTAL;
         if(horizontal && componentInspectorSetting)
         {
            if(rotation == 90)
            {
               return;
            }
            setScaleX(-1);
            rotation = -90;
         }
         if(!componentInspectorSetting)
         {
            if(horizontal && rotation == 0)
            {
               rotation = -90;
               setScaleX(-1);
            }
            else if(!horizontal && rotation == -90)
            {
               rotation = 0;
               setScaleX(1);
            }
         }
         invalidate(InvalidationType.SIZE);
      }
      
      public function get direction() : String
      {
         return _direction;
      }
   }
}

