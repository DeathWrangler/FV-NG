package GameMode
{
   import AvatarMode.AMPath;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.FarmIsoViewport;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.State;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Events.AvatarEvent;
   import Events.GenericPopupEvent;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class GMDefault extends GMGiftReOpen
   {
      
      protected const CANCEL_WARNING_NUM:int = 1;
      
      protected const BORDER_COLOR:Number = 0;
      
      protected const BORDER_ALPHA:Number = 1;
      
      protected const PATH_COLOR:Number = 16755200;
      
      protected const PATH_ALPHA:Number = 1;
      
      private const isDebug:Boolean = false;
      
      protected var m_viewDragStartPos:Point = null;
      
      protected var m_dragging:Boolean = false;
      
      protected var m_highlightedObject:WorldObject = null;
      
      protected var m_currentCursor:Object = null;
      
      protected var m_moveToPos:Point;
      
      protected var m_mouseMoveEvent:MouseEvent;
      
      protected var m_mouseMovePosition:Point = new Point(0,0);
      
      protected var m_mouseMoveTimer:Timer;
      
      private var m_coordTxt:TextField;
      
      private var m_addedText:String;
      
      public function GMDefault(isGift:Boolean = false, shouldReOpenGift:Boolean = true)
      {
         super(isGift,shouldReOpenGift);
         if(this.isDebug)
         {
            this.showTileCoordinates();
         }
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         Global.world.addEventListener(AvatarEvent.SELECTED,this.onAvatarChanged);
         Global.world.addEventListener(AvatarEvent.MOVED,this.onAvatarChanged);
      }
      
      override public function disableMode() : void
      {
         this.deselectObject();
         Global.world.removeEventListener(AvatarEvent.SELECTED,this.onAvatarChanged);
         Global.world.removeEventListener(AvatarEvent.MOVED,this.onAvatarChanged);
         super.disableMode();
         if(this.m_mouseMoveTimer)
         {
            this.m_mouseMoveTimer.removeEventListener(TimerEvent.TIMER,this.onMouseMoveTimerComplete);
            this.m_mouseMoveTimer = null;
         }
      }
      
      protected function getSelectableTypes() : int
      {
         return Constants.WORLDOBJECT_ALL;
      }
      
      protected function onDragStart() : void
      {
         if(!this.m_dragging)
         {
            this.m_dragging = true;
            if(this.m_highlightedObject)
            {
               this.deselectObject();
            }
            Global.world.onDragStart();
            Global.world.enableSkipCulling = true;
         }
      }
      
      protected function onDragStop() : void
      {
         if(this.m_dragging)
         {
            this.m_dragging = false;
            this.m_viewDragStartPos = null;
            Global.world.onDragStop();
            Global.world.enableSkipCulling = false;
         }
      }
      
      protected function setMoveToPosition(position:Point) : void
      {
         this.m_moveToPos = position;
      }
      
      protected function cancelQueueAndMove() : void
      {
         var avatar:FarmAvatar = Global.selectedAvatar;
         avatar.getStateMachine().removeAllStates();
         if(this.m_moveToPos != null)
         {
            avatar.getStateMachine().addState(new AMPath(avatar,this.m_moveToPos.x,this.m_moveToPos.y,0.1));
            this.m_moveToPos = null;
         }
      }
      
      protected function pickObject(stagePosition:Point, event:MouseEvent, forceRepick:Boolean = false) : void
      {
         var object:WorldObject = null;
         var viewportPosition:Point = IsoMath.stageToViewport(stagePosition);
         if(forceRepick || !this.m_highlightedObject || !this.m_highlightedObject.pickObject(viewportPosition,this.getSelectableTypes()))
         {
            object = Global.world.pickObject(viewportPosition,this.getSelectableTypes()) as WorldObject;
            if(this.isObjectSelectable(object))
            {
               this.selectObject(object,event);
            }
            else
            {
               this.deselectObject();
            }
         }
      }
      
      protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         return true;
      }
      
      protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         if(object != this.m_highlightedObject)
         {
            this.deselectObject();
            this.m_highlightedObject = object;
            if(object)
            {
               object.onMouseOver(event);
            }
            this.updateCursor();
         }
      }
      
      protected function updateCursor() : void
      {
         var cursor:Object = this.getCursor();
         if(cursor != this.m_currentCursor)
         {
            if(m_cursorId > 0)
            {
               UI.removeCursor(m_cursorId);
               m_cursorId = 0;
            }
            m_cursorId = UI.setCursor(cursor,false,shouldScaleCursor());
            this.m_currentCursor = cursor;
         }
      }
      
      protected function getCursor() : Object
      {
         var result:Object = m_cursorImage;
         if(this.m_highlightedObject)
         {
            result = this.m_highlightedObject.getCursor();
         }
         return result;
      }
      
      protected function deselectObject() : void
      {
         if(this.m_highlightedObject)
         {
            this.m_highlightedObject.onMouseOut();
            this.m_highlightedObject = null;
         }
         this.updateCursor();
      }
      
      protected function updateOverlay() : void
      {
      }
      
      private function showTileCoordinates() : void
      {
         if(Global.stage.getChildByName("coord"))
         {
            Global.stage.removeChild(Global.stage.getChildByName("coord"));
         }
         if(this.m_coordTxt == null)
         {
            this.m_coordTxt = new TextField();
            this.m_coordTxt.name = "coord";
            this.m_coordTxt.text = "";
            this.m_coordTxt.x = 40;
            this.m_coordTxt.y = 75;
            this.m_coordTxt.width = 400;
            this.m_coordTxt.selectable = false;
            this.m_coordTxt.mouseEnabled = false;
            this.m_coordTxt.backgroundColor = 16777215;
            GlobalEngine.stage.addChild(this.m_coordTxt);
         }
      }
      
      private function updateCoordinates(tilePos:Vector2, pixelPos:Vector2) : void
      {
         if(this.m_coordTxt)
         {
            this.m_addedText = "";
            this.m_coordTxt.text = "";
            if(tilePos)
            {
               this.m_addedText = "Tile Pos:  " + Math.round(tilePos.x) + ", " + Math.round(tilePos.y) + "\n";
               this.m_addedText += "Pixel Pos: " + Math.round(pixelPos.x) + ", " + Math.round(pixelPos.y) + "\n";
            }
            else
            {
               this.m_addedText = "";
            }
            this.m_coordTxt.text = this.m_addedText;
         }
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         this.onDragStop();
         this.m_viewDragStartPos = GlobalEngine.viewport.getScrollPosition().clone();
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var stagePosition:Point = null;
         if(this.m_dragging == false)
         {
            if(!this.m_highlightedObject)
            {
               stagePosition = new Point(event.stageX,event.stageY);
               this.pickObject(stagePosition,event);
            }
            this.handleClick(event);
         }
         this.onDragStop();
         super.onMouseUp(event);
         return true;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var newPos:Vector2 = null;
         var viewportPosition:Point = null;
         var duration:int = 0;
         var pixelPos:Vector2 = null;
         var tilePos:Vector2 = null;
         this.m_mouseMovePosition = new Point(event.stageX,event.stageY);
         this.m_mouseMoveEvent = event;
         if(Boolean(this.m_viewDragStartPos) && Boolean(this.m_mouseMovePosition) && Boolean(m_mouseDownPos) && this.m_mouseMovePosition.subtract(m_mouseDownPos).length >= Constants.DRAG_CLICK_EPSILON)
         {
            this.onDragStart();
         }
         if(this.m_dragging && Boolean(this.m_viewDragStartPos))
         {
            newPos = new Vector2();
            newPos.x = this.m_viewDragStartPos.x + (event.stageX - m_mouseDownPos.x) / GlobalEngine.viewport.getZoom();
            newPos.y = this.m_viewDragStartPos.y + (event.stageY - m_mouseDownPos.y) / GlobalEngine.viewport.getZoom();
            GlobalEngine.viewport.setScrollPosition(newPos);
         }
         else
         {
            viewportPosition = IsoMath.stageToViewport(this.m_mouseMovePosition);
            if(Boolean(this.m_highlightedObject) && !this.m_highlightedObject.pickObject(viewportPosition,this.getSelectableTypes()))
            {
               this.deselectObject();
            }
            if(this.m_mouseMoveTimer == null)
            {
               duration = 1100 / Global.stage.frameRate;
               this.m_mouseMoveTimer = new Timer(duration,1);
               this.m_mouseMoveTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onMouseMoveTimerComplete,false,0,true);
            }
            else
            {
               this.m_mouseMoveTimer.reset();
            }
            this.m_mouseMoveTimer.start();
         }
         if(this.isDebug)
         {
            pixelPos = new Vector2(event.stageX,event.stageY);
            tilePos = IsoMath.screenPosToTilePos(event.stageX,event.stageY);
            this.updateCoordinates(tilePos,pixelPos);
         }
         this.updateOverlay();
         return true;
      }
      
      override public function onMouseWheel(event:MouseEvent) : Boolean
      {
         var zoomChanged:Boolean = false;
         var viewport:FarmIsoViewport = GlobalEngine.viewport as FarmIsoViewport;
         if(event.delta > 1)
         {
            zoomChanged = viewport.zoomIn();
         }
         else if(event.delta < -1)
         {
            zoomChanged = viewport.zoomOut();
         }
         if(zoomChanged)
         {
            FarmStatsManager.sample(100,"mouse_wheel","zoom",viewport.getZoom().toFixed(3));
            FarmStatsManager.countOncePerSession("zoom_once","mouse_wheel");
         }
         return true;
      }
      
      protected function onAvatarChanged(event:AvatarEvent) : void
      {
         this.updateOverlay();
      }
      
      protected function canBeClicked(event:MouseEvent) : Boolean
      {
         return true;
      }
      
      protected function handleClick(event:MouseEvent) : void
      {
         var tilePos:Vector2 = null;
         var avatar:FarmAvatar = null;
         var currentState:State = null;
         var numActionsPending:int = 0;
         if(this.m_highlightedObject)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_FARM_OBJECT);
            if(this.canBeClicked(event) && this.m_highlightedObject.isAttached() == true)
            {
               this.m_highlightedObject.onClick();
            }
            if(this.m_highlightedObject != null && this.m_highlightedObject.isAttached() == false)
            {
               this.deselectObject();
            }
         }
         else
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_NOTHING);
            if(Global.selectedAvatar)
            {
               tilePos = IsoMath.screenPosToTilePos(event.stageX,event.stageY);
               avatar = Global.selectedAvatar;
               if(tilePos.x >= 0 && tilePos.y >= 0 && tilePos.x < Global.world.getGridWidth() && tilePos.y < Global.world.getGridHeight())
               {
                  this.setMoveToPosition(tilePos.clone());
                  currentState = avatar.getStateMachine().getState();
                  if(currentState == null || currentState.getInterrupt() != State.NO_INTERRUPT)
                  {
                     numActionsPending = avatar.getStateMachine().getNumActionsPending();
                     if(numActionsPending < this.CANCEL_WARNING_NUM)
                     {
                        this.cancelQueueAndMove();
                     }
                  }
               }
            }
         }
      }
      
      protected function onConfirmCancelQueue(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.cancelQueueAndMove();
         }
      }
      
      protected function onMouseMoveTimerComplete(evt:TimerEvent) : void
      {
         this.pickObject(this.m_mouseMovePosition,this.m_mouseMoveEvent,true);
      }
   }
}

