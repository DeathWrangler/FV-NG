package fl.controls
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.events.ScrollEvent;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextField;
   
   public class UIScrollBar extends ScrollBar
   {
      
      private static var defaultStyles:Object = {};
      
      protected var inEdit:Boolean = false;
      
      protected var inScroll:Boolean = false;
      
      protected var _scrollTarget:TextField;
      
      public function UIScrollBar()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return UIComponent.mergeStyles(defaultStyles,ScrollBar.getStyleDefinition());
      }
      
      protected function updateScrollTargetProperties() : void
      {
         var horizontal:Boolean = false;
         var pageSize:Number = NaN;
         if(_scrollTarget == null)
         {
            setScrollProperties(pageSize,minScrollPosition,maxScrollPosition,pageScrollSize);
            scrollPosition = 0;
         }
         else
         {
            horizontal = direction == ScrollBarDirection.HORIZONTAL;
            pageSize = horizontal ? _scrollTarget.width : 10;
            setScrollProperties(pageSize,horizontal ? 0 : 1,horizontal ? _scrollTarget.maxScrollH : _scrollTarget.maxScrollV,pageScrollSize);
            scrollPosition = horizontal ? _scrollTarget.scrollH : _scrollTarget.scrollV;
         }
      }
      
      override public function setScrollProperties(pageSize:Number, minScrollPosition:Number, maxScrollPosition:Number, pageScrollSize:Number = 0) : void
      {
         var maxScrollPos:Number = maxScrollPosition;
         var minScrollPos:Number = minScrollPosition < 0 ? 0 : minScrollPosition;
         if(_scrollTarget != null)
         {
            if(direction == ScrollBarDirection.HORIZONTAL)
            {
               maxScrollPos = maxScrollPosition > _scrollTarget.maxScrollH ? _scrollTarget.maxScrollH : maxScrollPos;
            }
            else
            {
               maxScrollPos = maxScrollPosition > _scrollTarget.maxScrollV ? _scrollTarget.maxScrollV : maxScrollPos;
            }
         }
         super.setScrollProperties(pageSize,minScrollPos,maxScrollPos,pageScrollSize);
      }
      
      protected function handleTargetScroll(event:Event) : void
      {
         if(inDrag)
         {
            return;
         }
         if(!enabled)
         {
            return;
         }
         inEdit = true;
         updateScrollTargetProperties();
         scrollPosition = direction == ScrollBarDirection.HORIZONTAL ? _scrollTarget.scrollH : _scrollTarget.scrollV;
         inEdit = false;
      }
      
      override public function setScrollPosition(scrollPosition:Number, fireEvent:Boolean = true) : void
      {
         super.setScrollPosition(scrollPosition,fireEvent);
         if(!_scrollTarget)
         {
            inScroll = false;
            return;
         }
         updateTargetScroll();
      }
      
      [Inspectable]
      public function get scrollTargetName() : String
      {
         return _scrollTarget.name;
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.DATA))
         {
            updateScrollTargetProperties();
         }
         super.draw();
      }
      
      override public function set direction(dir:String) : void
      {
         if(isLivePreview)
         {
            return;
         }
         super.direction = dir;
         updateScrollTargetProperties();
      }
      
      protected function updateTargetScroll(event:ScrollEvent = null) : void
      {
         if(inEdit)
         {
            return;
         }
         if(direction == ScrollBarDirection.HORIZONTAL)
         {
            _scrollTarget.scrollH = scrollPosition;
         }
         else
         {
            _scrollTarget.scrollV = scrollPosition;
         }
      }
      
      override public function set minScrollPosition(minScrollPosition:Number) : void
      {
         super.minScrollPosition = minScrollPosition < 0 ? 0 : minScrollPosition;
      }
      
      override public function set maxScrollPosition(maxScrollPosition:Number) : void
      {
         var maxScrollPos:Number = maxScrollPosition;
         if(_scrollTarget != null)
         {
            if(direction == ScrollBarDirection.HORIZONTAL)
            {
               maxScrollPos = maxScrollPos > _scrollTarget.maxScrollH ? _scrollTarget.maxScrollH : maxScrollPos;
            }
            else
            {
               maxScrollPos = maxScrollPos > _scrollTarget.maxScrollV ? _scrollTarget.maxScrollV : maxScrollPos;
            }
         }
         super.maxScrollPosition = maxScrollPos;
      }
      
      protected function handleTargetChange(event:Event) : void
      {
         inEdit = true;
         setScrollPosition(direction == ScrollBarDirection.HORIZONTAL ? _scrollTarget.scrollH : _scrollTarget.scrollV,true);
         updateScrollTargetProperties();
         inEdit = false;
      }
      
      public function update() : void
      {
         inEdit = true;
         updateScrollTargetProperties();
         inEdit = false;
      }
      
      public function set scrollTargetName(target:String) : void
      {
         try
         {
            scrollTarget = parent.getChildByName(target) as TextField;
         }
         catch(error:Error)
         {
            throw new Error("ScrollTarget not found, or is not a TextField");
         }
      }
      
      public function set scrollTarget(target:TextField) : void
      {
         if(_scrollTarget != null)
         {
            _scrollTarget.removeEventListener(Event.CHANGE,handleTargetChange,false);
            _scrollTarget.removeEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false);
            _scrollTarget.removeEventListener(Event.SCROLL,handleTargetScroll,false);
            removeEventListener(ScrollEvent.SCROLL,updateTargetScroll,false);
         }
         _scrollTarget = target;
         if(_scrollTarget != null)
         {
            _scrollTarget.addEventListener(Event.CHANGE,handleTargetChange,false,0,true);
            _scrollTarget.addEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false,0,true);
            _scrollTarget.addEventListener(Event.SCROLL,handleTargetScroll,false,0,true);
            addEventListener(ScrollEvent.SCROLL,updateTargetScroll,false,0,true);
         }
         invalidate(InvalidationType.DATA);
      }
      
      public function get scrollTarget() : TextField
      {
         return _scrollTarget;
      }
      
      [Inspectable(defaultValue="vertical",type="list",enumeration="vertical,horizontal")]
      override public function get direction() : String
      {
         return super.direction;
      }
   }
}

