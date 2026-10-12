package Classes
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.StrokeTextField;
   import Display.UI;
   import Engine.Classes.Observer.IObservable;
   import Engine.Classes.Observer.IObserver;
   import Engine.Classes.Observer.ObserverComponent;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import GameMode.GMObjectMove;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Transactions.TSell;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import gs.TweenLite;
   
   public class FarmGameObject extends WorldObject implements IObservable
   {
      
      public static const OBSERVABLE_EVENT_MOVE:String = "MOVE";
      
      public static const OBSERVABLE_EVENT_PLACE:String = "PLACE";
      
      protected static var ACTIONBAR_WIDTH:int = 100;
      
      protected static var ACTIONBAR_HEIGHT:int = 19;
      
      public static const OVERLAY_SCALE:Number = 1;
      
      public static const OVERLAY_OFFSET:Vector2 = new Vector2();
      
      public static const TOOLTIP_TOP:String = "top";
      
      public static var WALK_SPEED:Number = 100;
      
      public static const SPARKLE_URL:String = "assets/overlays/effect_dairyfarm_sparkle.swf";
      
      private var m_toolTip:DisplayObject = null;
      
      private var m_toolTipText:TextField = null;
      
      protected var m_menuItems:Array = [];
      
      protected var m_clearLock:int = 0;
      
      protected var m_filters:Array = [];
      
      protected var m_actionText:TextField;
      
      protected var m_actionMessage:String;
      
      protected var m_actionProgress:Number;
      
      protected var m_actionBar:Sprite;
      
      protected var m_strokeField:StrokeTextField = null;
      
      public var m_WalkSpeed:Number = WALK_SPEED;
      
      private var m_walkPath:Array = [];
      
      private var m_walkStart:Number = 0;
      
      protected var m_walkStartPos:Vector3;
      
      protected var m_overlayURL:String;
      
      private var m_isSparkling:Boolean = false;
      
      private var m_stopSparkling:Boolean = false;
      
      protected var m_highlight:GlowFilter = null;
      
      protected var m_toolGenerated:Boolean = false;
      
      protected var m_surfacingKeyword:String = "";
      
      protected var m_observer:ObserverComponent;
      
      public function FarmGameObject()
      {
         super();
         this.m_WalkSpeed = WALK_SPEED;
         this.m_observer = new ObserverComponent(this.getObservableEvents());
      }
      
      public function get isToolGenerated() : Boolean
      {
         return this.m_toolGenerated;
      }
      
      override public function detach() : void
      {
         this.setToolTip(null);
         if(Boolean(this.m_actionBar) && Boolean(this.m_actionBar.parent))
         {
            this.m_actionBar.parent.removeChild(this.m_actionBar);
         }
         this.stopOverlay();
         super.detach();
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         var spr:Sprite = m_displayObject as Sprite;
         if(spr == null)
         {
            createDisplayObject();
         }
         this.drawActionBar();
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var position:Vector3 = null;
         var screenPos:Point = null;
         super.updateDisplayObjectTransform();
         if(Boolean(this.m_actionBar) && this.m_actionBar.visible)
         {
            position = getReference().getPosition();
            screenPos = IsoMath.tilePosToPixelPos(position.x,position.y);
            screenPos.y -= m_displayObject.height;
            screenPos = IsoMath.viewportToStage(screenPos);
            this.m_actionBar.x = screenPos.x - ACTIONBAR_WIDTH / 2;
            this.m_actionBar.y = screenPos.y - ACTIONBAR_HEIGHT;
         }
      }
      
      public function updateAnimation(delta:int) : void
      {
      }
      
      protected function drawActionBar() : void
      {
         var cornerWidth:Number = NaN;
         var lineThickness:Number = NaN;
         var txt:String = null;
         var txtFormat:TextFormat = null;
         if(this.m_actionMessage)
         {
            if(this.m_actionBar == null)
            {
               this.m_actionBar = new Sprite();
               this.m_actionBar.visible = false;
               Utilities.toggleInputAndChildren(this.m_actionBar,false);
               txtFormat = new TextFormat("Merkin2",10,16777215);
               this.m_actionText = new TextField();
               this.m_actionText.embedFonts = true;
               this.m_actionText.defaultTextFormat = txtFormat;
               this.m_actionText.setTextFormat(txtFormat);
               this.m_actionText.x = lineThickness / 2;
               this.m_actionBar.addChild(this.m_actionText);
            }
            if(this.m_actionBar.parent == null)
            {
               GlobalEngine.viewport.hudBase.addChild(this.m_actionBar);
            }
            cornerWidth = 6;
            lineThickness = 1;
            this.m_actionBar.graphics.clear();
            this.m_actionBar.graphics.lineStyle(lineThickness,0,0.5);
            this.m_actionBar.graphics.beginFill(26112);
            this.m_actionBar.graphics.drawRoundRect(0,0,ACTIONBAR_WIDTH,ACTIONBAR_HEIGHT,cornerWidth,cornerWidth);
            this.m_actionBar.graphics.lineStyle(0,0,0);
            this.m_actionBar.graphics.beginFill(43520);
            this.m_actionBar.graphics.drawRoundRect(lineThickness / 2,lineThickness / 2,ACTIONBAR_WIDTH * this.m_actionProgress - lineThickness,ACTIONBAR_HEIGHT - lineThickness,cornerWidth,cornerWidth);
            this.m_actionBar.graphics.endFill();
            txt = this.m_actionMessage + ": " + Math.floor(this.m_actionProgress * 100) + "%";
            if(this.m_actionText.text != txt)
            {
               this.m_actionText.text = txt;
            }
            if(this.m_actionBar.visible == false)
            {
               this.m_actionBar.visible = true;
               this.updateDisplayObjectTransform();
            }
         }
      }
      
      public function setActionProgress(message:String, progress:Number = 0) : void
      {
         if(this.m_actionMessage != message || this.m_actionProgress != progress)
         {
            this.m_actionMessage = message;
            this.m_actionProgress = progress;
            setDisplayObjectDirty(true);
            conditionallyRedraw(true);
         }
      }
      
      public function hasValidId() : Boolean
      {
         var result:Boolean = true;
         if(m_id == 0 && !this.isToolGenerated)
         {
            FarmStatsManager.count("errors","has_valid_id_is_zero");
            result = false;
         }
         return result;
      }
      
      public function showObjectBusy() : void
      {
         this.displayStatus(ZLocUtils.t("FarmGame","ObjectBusy"));
      }
      
      public function displayStatus(message:String, iconUrl:String = "", iconFilters:Array = null, tweenDuration:Number = 1.5, tweenDisplacement:int = 32, fontSize:int = 16, fontColor:Object = null) : void
      {
         var screen:Point = this.displayStatusStartPos();
         UI.displayStatus(message,screen.x,screen.y,iconUrl,iconFilters,tweenDuration,tweenDisplacement,fontSize,fontColor);
      }
      
      public function displayStatusStartPos() : Point
      {
         var screen:Point = IsoMath.tilePosToPixelPos(m_position.x,m_position.y);
         if(m_displayObject)
         {
            screen.y -= m_displayObject.height;
         }
         return IsoMath.viewportToStage(screen);
      }
      
      public function showMenu() : void
      {
         this.sortMenu();
         if(!this.hasValidId())
         {
            this.showObjectBusy();
         }
         else if(!FreezeManager.isAnythingFrozen())
         {
            UI.displayMenu(this.m_menuItems,this.onMenuClick);
         }
      }
      
      public function sortMenu() : void
      {
      }
      
      public function onMenuClick(event:MouseEvent) : void
      {
      }
      
      public function onObjectDrop() : void
      {
         this.m_observer.notifyObservers(OBSERVABLE_EVENT_PLACE,{"obj":this});
      }
      
      public function isDecoMoveSupported() : Boolean
      {
         return true;
      }
      
      public function handleDecoMoveUnsupported() : void
      {
      }
      
      public function move() : void
      {
         Global.world.addGameMode(new GMObjectMove(this),false);
      }
      
      public function sell() : void
      {
         var sellPrice:int = this.getSellPrice();
         if((Global.quickDeleteOn || Global.persistentSell) && sellPrice < 1000)
         {
            this.sellConfirmationHandler();
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("FarmGame","SellObject"),GenericPopup.TYPE_YESNO,this.sellConfirmationHandler);
         }
      }
      
      public function sellWithOutAsking() : void
      {
         this.sellConfirmationHandler();
      }
      
      protected function getSellPrice() : int
      {
         return 0;
      }
      
      public function isSellable() : Boolean
      {
         return false;
      }
      
      public function allowDelete() : Boolean
      {
         return false;
      }
      
      public function getToolTip() : DisplayObject
      {
         return this.m_toolTip;
      }
      
      public function getToolTipText() : TextField
      {
         return this.m_toolTipText;
      }
      
      public function setToolTip(toolTip:String) : void
      {
         if(this.canSetToolTip(toolTip))
         {
            if(this.m_toolTip)
            {
               if(this.m_toolTip.parent)
               {
                  this.m_toolTip.parent.removeChild(this.m_toolTip);
               }
               this.m_toolTip = null;
               this.m_toolTipText = null;
            }
            if(Boolean(toolTip) && !Global.disableToolTips)
            {
               if(this.m_strokeField == null)
               {
                  this.m_strokeField = new StrokeTextField(2105376,0.8);
                  this.m_strokeField.width = 200;
                  this.m_strokeField.multiline = true;
                  this.m_strokeField.wordWrap = true;
                  this.m_strokeField.autoSize = TextFieldAutoSize.LEFT;
               }
               this.m_strokeField.toolTipText = toolTip;
               this.m_strokeField.setTextFormat(new TextFormat("Arial",14,16777215,true));
               this.m_toolTipText = this.m_strokeField;
               this.m_toolTip = this.m_strokeField;
               this.updateToolTipPosition();
               GlobalEngine.viewport.hudBase.addChild(this.m_strokeField);
            }
         }
      }
      
      protected function canSetToolTip(toolTip:String) : Boolean
      {
         return !Global.toolMode && (this.m_toolTipText == null && toolTip != null || this.m_toolTipText && this.m_toolTipText.text != toolTip);
      }
      
      protected function getCustomToolTipOffset() : Point
      {
         return new Point(0,0);
      }
      
      protected function updateToolTipPosition(position:String = null) : void
      {
         var screenPos:Point = null;
         if(this.m_toolTip)
         {
            screenPos = IsoMath.tilePosToPixelPos(m_position.x,m_position.y).add(this.getCustomToolTipOffset());
            if(m_displayObject)
            {
               screenPos.y -= m_displayObject.height / 2;
            }
            screenPos = IsoMath.viewportToStage(screenPos);
            screenPos.x -= this.m_toolTipText.textWidth / 2;
            if(position == null || position == "")
            {
               screenPos.y -= this.m_toolTipText.textHeight / 2;
            }
            else
            {
               screenPos.y -= this.m_toolTipText.textHeight;
            }
            if(screenPos.x != this.m_toolTip.x || screenPos.y != this.m_toolTip.y)
            {
               this.m_toolTip.x = screenPos.x;
               this.m_toolTip.y = screenPos.y;
            }
         }
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         m_highlighted = highlighted;
         this.showHighlight(highlighted,color);
      }
      
      protected function createHighlightGlowFilter(color:uint, startingAlpha:Number) : GlowFilter
      {
         return new GlowFilter(color,startingAlpha,8,8,20);
      }
      
      public function showHighlight(isShowing:Boolean, color:uint = 16755200) : void
      {
         if(m_displayObject)
         {
            if(isShowing)
            {
               m_displayObject.filters = [this.createHighlightGlowFilter(color,1)];
            }
            else
            {
               m_displayObject.filters = this.m_filters.concat([]);
            }
         }
      }
      
      public function fadeHighlight(isShowing:Boolean, color:uint = 16755200, duration:int = 1) : void
      {
         if(this.m_highlight == null)
         {
            this.m_highlight = this.createHighlightGlowFilter(color,0);
         }
         if(isShowing)
         {
            this.m_highlight.alpha = 0;
            TweenLite.to(this,duration,{
               "highlightAlpha":1,
               "onComplete":this.onFadeInComplete
            });
         }
         else
         {
            this.m_highlight.alpha = 1;
            TweenLite.to(this,duration,{
               "highlightAlpha":0,
               "onComplete":this.onFadeOutComplete
            });
         }
      }
      
      public function get highlightAlpha() : Number
      {
         var currGlowFilterAplha:Number = 0;
         if(this.m_highlight != null)
         {
            currGlowFilterAplha = this.m_highlight.alpha;
         }
         return currGlowFilterAplha;
      }
      
      public function set highlightAlpha(value:Number) : void
      {
         this.m_highlight.alpha = value;
         m_displayObject.filters = [this.m_highlight];
      }
      
      private function onFadeInComplete() : void
      {
      }
      
      private function onFadeOutComplete() : void
      {
      }
      
      public function isMovable() : Boolean
      {
         return true;
      }
      
      public function isStorable() : Boolean
      {
         return true;
      }
      
      public function isClearable() : Boolean
      {
         return this.m_clearLock <= 0;
      }
      
      public function lock() : void
      {
         ++this.m_clearLock;
      }
      
      public function unlock() : void
      {
         --this.m_clearLock;
      }
      
      public function onSell() : void
      {
      }
      
      protected function sellConfirmationHandler(event:GenericPopupEvent = null) : void
      {
         var result:Boolean = false;
         var sellPrice:int = 0;
         if(event != null)
         {
            result = event.button == GenericPopup.YES;
         }
         else
         {
            result = true;
         }
         if(result == true)
         {
            if(this.isSellable())
            {
               this.onSell();
               this.addTransaction(new TSell(this));
               this.detach();
               sellPrice = this.getSellPrice();
               Global.player.gold += sellPrice;
               this.displayStatus(ZLocUtils.t("FarmGame","Status_ObjectSold",{"coinNum":sellPrice}));
            }
         }
      }
      
      public function preDisableMove(oldState:String) : void
      {
      }
      
      public function postDisableMove() : void
      {
      }
      
      public function getCurrentPath() : Array
      {
         return this.m_walkPath;
      }
      
      public function getCurrentDestination() : Vector3
      {
         var res:Vector3 = null;
         if(this.m_walkPath.length > 0)
         {
            res = this.m_walkPath[this.m_walkPath.length - 1];
         }
         else
         {
            res = getPosition();
         }
         return res;
      }
      
      public function stopWalking() : void
      {
         this.m_walkPath = [];
      }
      
      public function reloadImage() : void
      {
         setDisplayObjectDirty(true);
         conditionallyRedraw();
      }
      
      public function addTMoveParams(params:Object) : Object
      {
         return params;
      }
      
      protected function onDoneWalking() : void
      {
      }
      
      public function walkTo(x:int, y:int, minDistance:Number = 0.1) : Boolean
      {
         if(this.m_walkStartPos == null)
         {
            this.m_walkStartPos = m_position.clone();
         }
         this.m_walkPath = [];
         var foundPath:Boolean = Global.world.getCollisionMap().getPath(m_position,new Vector3(x,y,0),[this],false,minDistance,this.m_walkPath);
         if(foundPath)
         {
            if(this.m_walkPath.length > 1)
            {
               this.m_walkPath.splice(0,1);
               if(!this.findNextPathPoint())
               {
                  this.onDoneWalking();
               }
               this.updateCharacterDirection();
            }
            else
            {
               foundPath = false;
            }
         }
         if(!foundPath)
         {
            this.m_walkPath = [];
         }
         return foundPath;
      }
      
      private function findNextPathPoint() : Boolean
      {
         var nextPoint:Vector3 = null;
         var newDirection:int = 0;
         var res:Boolean = false;
         if(this.m_walkPath.length > 0)
         {
            nextPoint = this.m_walkPath[0];
            this.m_walkStart = GlobalEngine.currentTime;
            this.m_walkStartPos = m_position.clone();
            if(nextPoint.x > Math.round(m_position.x))
            {
               newDirection = Constants.DIRECTION_NE;
            }
            else if(nextPoint.x < Math.round(m_position.x))
            {
               newDirection = Constants.DIRECTION_SW;
            }
            else if(nextPoint.y > Math.round(m_position.y))
            {
               newDirection = Constants.DIRECTION_NW;
            }
            else
            {
               newDirection = Constants.DIRECTION_SE;
            }
            if(newDirection != m_direction)
            {
               m_direction = newDirection;
               this.updateCharacterDirection();
            }
            res = true;
         }
         else
         {
            this.stopWalking();
         }
         return res;
      }
      
      public function isWalking() : Boolean
      {
         return this.m_walkPath.length > 0;
      }
      
      protected function updateCharacterDirection() : void
      {
      }
      
      protected function onWalkUpdate() : void
      {
      }
      
      protected function onUpdateWalk(delta:Number) : void
      {
         var nextPoint:Vector3 = null;
         var walkDistance:Number = NaN;
         var walkTime:Number = NaN;
         var interp:Number = NaN;
         var newPos:Vector3 = null;
         var done:Boolean = false;
         if(this.m_walkPath.length)
         {
            nextPoint = this.m_walkPath[0];
            walkDistance = nextPoint.subtract(this.m_walkStartPos).length();
            walkTime = walkDistance * this.m_WalkSpeed;
            interp = (GlobalEngine.currentTime - this.m_walkStart) / walkTime;
            done = false;
            if(interp > 1)
            {
               interp = 1;
               newPos = Vector3.lerp(this.m_walkStartPos,nextPoint,interp);
               this.m_walkPath.splice(0,1);
               done = !this.findNextPathPoint();
            }
            else
            {
               newPos = Vector3.lerp(this.m_walkStartPos,nextPoint,interp);
            }
            setPosition(newPos.x,newPos.y,newPos.z);
            this.updateDisplayObjectTransform();
            conditionallyReattach();
            if(done)
            {
               this.onDoneWalking();
            }
            this.onWalkUpdate();
         }
      }
      
      override public function centerOn() : void
      {
         Global.world.centerOnObject(this);
      }
      
      public function canBeClickedOnVisit() : Boolean
      {
         return false;
      }
      
      public function canUpdateCursorOnVisit() : Boolean
      {
         return false;
      }
      
      public function startOverlay(url:String, overlayParams:Object = null) : void
      {
         this.m_stopSparkling = false;
         if(!this.m_isSparkling)
         {
            this.dispOverlay(url,overlayParams);
            this.m_isSparkling = true;
         }
      }
      
      public function stopOverlay() : void
      {
         this.m_stopSparkling = true;
      }
      
      public function dispOverlay(url:String, overlayParams:Object = null) : void
      {
         var pt:Point = null;
         var overlayScale:Number = NaN;
         var overlayOffset:Vector2 = null;
         var displayObjectSize:Vector2 = null;
         var scale:Vector2 = null;
         if(this.m_overlayURL != url)
         {
            this.m_overlayURL = url;
         }
         if(this.m_overlayURL)
         {
            pt = this.getOverlayStartPos();
            overlayScale = this.getOverlayScale();
            overlayOffset = this.getOverlayOffset();
            pt.x += overlayOffset.x;
            pt.y += overlayOffset.y;
            displayObjectSize = getActualDisplayObjectSize();
            scale = new Vector2(displayObjectSize.x * overlayScale,displayObjectSize.y * overlayScale);
            if(Boolean(overlayParams) && overlayParams.hasOwnProperty("offsetX"))
            {
               pt.x += overlayParams.offsetX;
            }
            if(Boolean(overlayParams) && overlayParams.hasOwnProperty("offsetY"))
            {
               pt.y += overlayParams.offsetY;
            }
            Global.ui.displayOverlaySWF(Global.getAssetURL(this.m_overlayURL),pt,scale,0,this.overlayComplete,overlayParams);
         }
      }
      
      protected function getOverlayScale() : Number
      {
         return FarmGameObject.OVERLAY_SCALE;
      }
      
      protected function getOverlayOffset() : Vector2
      {
         return FarmGameObject.OVERLAY_OFFSET;
      }
      
      public function getOverlayUrl() : String
      {
         return FarmGameObject.SPARKLE_URL;
      }
      
      protected function getOverlayStartPos() : Point
      {
         return new Point(this.getScreenPosition().x,this.getScreenPosition().y - 1);
      }
      
      protected function overlayComplete() : Boolean
      {
         if(this.m_stopSparkling)
         {
            this.m_stopSparkling = this.m_isSparkling = false;
         }
         return this.m_isSparkling;
      }
      
      public function setScale(scale:Number) : void
      {
         if(m_displayObject)
         {
            m_displayObject.scaleX = scale;
            m_displayObject.scaleY = scale;
         }
      }
      
      public function updatePersonalName(value:String) : void
      {
      }
      
      public function canBeSurfaced() : Boolean
      {
         return this.m_surfacingKeyword != "";
      }
      
      public function get surfacingKeyword() : String
      {
         return this.m_surfacingKeyword;
      }
      
      public function addTransaction(transaction:Transaction, performImmediately:Boolean = false) : void
      {
         if(!this.isToolGenerated)
         {
            TransactionManager.addTransaction(transaction,performImmediately);
         }
      }
      
      public function addObserver(observer:IObserver, events:Vector.<String> = null) : void
      {
         this.m_observer.addObserver(observer,events);
      }
      
      public function removeObserver(observer:IObserver, events:Vector.<String> = null) : void
      {
         this.m_observer.removeObserver(observer,events);
      }
      
      public function getObservableEvents() : Vector.<String>
      {
         var events:Vector.<String> = new Vector.<String>();
         events.push(OBSERVABLE_EVENT_MOVE);
         events.push(OBSERVABLE_EVENT_PLACE);
         return events;
      }
      
      public function startMove() : void
      {
         this.m_observer.notifyObservers(OBSERVABLE_EVENT_MOVE,{"obj":this});
      }
   }
}

