package Widgets.Windows
{
   import Display.UI;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.InputManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.FreezeManager;
   import Managers.PerformanceExperimentManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import fl.motion.easing.Back;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class FarmWindow extends ZwAbstractWindow
   {
      
      protected static const OPEN_SFX:String = "dialogSpawn";
      
      protected static const CLOSE_SFX:String = "dialogClose";
      
      protected static const TWEEN_TIME:Number = 0.5;
      
      public static const CLICK_BLOCKER_COLOR:Number = 0;
      
      public static const CLICK_BLOCKER_ALPHA:Number = 0.2;
      
      private static var m_dimColorTransform:ColorTransform = new ColorTransform(0.5,0.5,0.5,1,0,0,0,0);
      
      private static var m_normalColorTransform:ColorTransform = new ColorTransform();
      
      protected var m_modal:Boolean = true;
      
      protected var m_shown:Boolean = false;
      
      protected var m_showOnLoad:Boolean = false;
      
      protected var m_cursorId:int = 0;
      
      protected var m_showTween:Boolean = false;
      
      protected var m_mcClickBlocker:MovieClip = new MovieClip();
      
      protected var m_bAddClickBlocker:Boolean = false;
      
      protected var m_absolutePos:Point = null;
      
      protected var m_shouldFreeze:Boolean = true;
      
      protected var m_closeButton:FarmButton = null;
      
      private var m_zaspLoadHandle:int = 0;
      
      public function FarmWindow(windowAssetRelUrl:String, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         this.m_bAddClickBlocker = bAddClickBlocker;
         addChild(this.m_mcClickBlocker);
         super(Global.getAssetURL(windowAssetRelUrl));
         this.m_modal = modal;
      }
      
      private function addClickBlocker() : void
      {
         if(!this.m_bAddClickBlocker)
         {
            return;
         }
         this.m_mcClickBlocker.graphics.clear();
         this.m_mcClickBlocker.graphics.beginFill(CLICK_BLOCKER_COLOR,CLICK_BLOCKER_ALPHA);
         this.m_mcClickBlocker.graphics.drawRect(0,0,Global.stage.stageWidth,Global.stage.stageHeight);
         this.m_mcClickBlocker.graphics.endFill();
         var localPos:Point = new Point(this.m_window.x,this.m_window.y);
         var globalPos:Point = this.localToGlobal(localPos);
         this.m_mcClickBlocker.x = -globalPos.x;
         this.m_mcClickBlocker.y = -globalPos.y;
      }
      
      private function removeClickBlocker() : void
      {
         this.m_mcClickBlocker.graphics.clear();
      }
      
      override public function close() : void
      {
         var dispObj:DisplayObject = this;
         if(this.m_showTween)
         {
            this.hideTween(function():void
            {
               release();
               dispatchEvent(new Event(Event.CLOSE));
            });
            this.onHide();
         }
         else
         {
            this.onHide();
            this.release();
            dispatchEvent(new Event(Event.CLOSE));
         }
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
         if(Boolean(m_loader) && Boolean(m_loader.content))
         {
            m_loader.content.filters = [new DropShadowFilter()];
         }
         if(Boolean(m_window) && "close_bt" in m_window)
         {
            this.m_closeButton = addWidget(new FarmButton(m_window.close_bt,this.onClose)) as FarmButton;
         }
         this.afterLoad();
         if(this.m_showOnLoad)
         {
            this.m_showOnLoad = false;
            this.show();
         }
      }
      
      protected function afterLoad() : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
      }
      
      override protected function release() : void
      {
         this.m_closeButton = null;
         super.release();
      }
      
      public function setCloseButtonVisible(show:Boolean) : void
      {
         if(Boolean(this.m_closeButton) && this.m_closeButton.visible != show)
         {
            this.m_closeButton.visible = show;
         }
      }
      
      public function refreshWindow() : void
      {
      }
      
      protected function onClose(event:Event) : void
      {
         this.close();
      }
      
      public function getDialogOffset() : Point
      {
         return new Point(0,0);
      }
      
      public function getDialogRect(parent:DisplayObject) : Rectangle
      {
         var p:Point = null;
         if(PerformanceExperimentManager.isInOptimizedSwfExperiment)
         {
            p = this.localToGlobal(new Point(0,0));
            return new Rectangle(p.x,p.y,this.width,this.height);
         }
         return getRect(parent);
      }
      
      public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var offset:Point = null;
         var rect:Rectangle = null;
         if(parent)
         {
            this.removeClickBlocker();
            offset = this.getDialogOffset();
            if(!m_window.hasOwnProperty("size_mc"))
            {
               rect = this.getDialogRect(parent);
            }
            else
            {
               rect = new Rectangle(0,0,m_window.size_mc.width,m_window.size_mc.height);
            }
            if(null == pAbsolutePos)
            {
               pAbsolutePos = this.m_absolutePos;
            }
            if(null == pAbsolutePos)
            {
               this.x = (Global.stage.stageWidth - rect.width) / 2 + offset.x;
               this.y = (Global.stage.stageHeight - rect.height) / 2 + offset.y;
            }
            else
            {
               this.x = pAbsolutePos.x;
               this.y = pAbsolutePos.y;
            }
            this.addClickBlocker();
         }
      }
      
      public function show() : void
      {
         if(this.m_isLoaded)
         {
            if(this.shouldFreeze)
            {
               FreezeManager.freezeRender();
            }
            this.visible = true;
            if(this.m_showTween)
            {
               this.showTween();
            }
            else
            {
               this.centerPopup();
            }
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.zaspPopup();
               if(this.m_zaspLoadHandle > 0)
               {
                  GlobalEngine.zaspManager.zaspWaitEnd(this.m_zaspLoadHandle);
                  this.m_zaspLoadHandle = 0;
               }
            }
            this.onShow();
         }
         else
         {
            if(Boolean(GlobalEngine.zaspManager) && !this.m_zaspLoadHandle)
            {
               this.m_zaspLoadHandle = GlobalEngine.zaspManager.zaspWaitStart("DIALOG",getQualifiedClassName(this));
            }
            this.m_showOnLoad = true;
         }
      }
      
      public function hide() : void
      {
         if(this.m_showTween)
         {
            this.hideTween(function():void
            {
               this.visible = false;
            });
            this.onHide();
         }
         else
         {
            this.onHide();
            this.visible = false;
         }
      }
      
      override public function get shouldFreeze() : Boolean
      {
         return this.m_shouldFreeze;
      }
      
      public function isLoaded() : Boolean
      {
         return m_isLoaded;
      }
      
      public function set shouldFreeze(val:Boolean) : void
      {
         this.m_shouldFreeze = val;
      }
      
      public function setAbsolutePos(xPos:int, yPos:int, forceUpdate:Boolean = false) : void
      {
         this.m_absolutePos = new Point(xPos,yPos);
         if(forceUpdate)
         {
            this.x = this.m_absolutePos.x;
            this.y = this.m_absolutePos.y;
         }
      }
      
      protected function onShow() : void
      {
         if(!this.m_shown)
         {
            if(this.m_modal)
            {
               InputManager.disableInput();
               Utilities.toggleInputAndChildren(Global.ui,false);
            }
            this.m_cursorId = UI.setCursor(null);
            Utilities.toggleInputAndChildren(this,true);
            this.m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,this.onResize);
         }
         else
         {
            this.m_showOnLoad = true;
         }
         SoundManager.playSound(OPEN_SFX);
      }
      
      protected function onHide() : void
      {
         if(this.m_shown)
         {
            if(this.m_modal)
            {
               InputManager.enableInput();
               Utilities.toggleInputAndChildren(Global.ui,true);
            }
            this.m_shown = false;
            Utilities.toggleInputAndChildren(this,false);
            UI.removeCursor(this.m_cursorId);
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
            Global.stage.removeEventListener(Event.RESIZE,this.onResize);
         }
         this.m_showOnLoad = false;
      }
      
      protected function hideTween(callback:Function) : void
      {
         var matParams:Object = null;
         var startSize:Point = null;
         Utilities.toggleInputAndChildren(this,false);
         if(m_loader == null || m_loader.content == null)
         {
            if(callback != null)
            {
               callback();
            }
         }
         else
         {
            matParams = {"scale":1};
            startSize = new Point(m_loader.content.width,m_loader.content.height);
            TweenLite.to(matParams,TWEEN_TIME,{
               "scale":0,
               "ease":Back.easeIn,
               "onUpdate":function():void
               {
                  var mat:* = undefined;
                  if(m_loader != null && m_loader.content != null)
                  {
                     mat = new Matrix();
                     mat.translate(-startSize.x / 2,-startSize.y / 2);
                     mat.scale(matParams.scale,matParams.scale);
                     mat.translate(startSize.x / 2,startSize.y / 2);
                     m_loader.content.transform.matrix = mat;
                  }
               },
               "onComplete":callback
            });
         }
         SoundManager.playSound(CLOSE_SFX);
      }
      
      protected function showTween() : void
      {
         var startSize:Point = null;
         var matParams:Object = null;
         var mat:Matrix = null;
         Utilities.toggleInputAndChildren(this,false);
         startSize = new Point(m_loader.content.width,m_loader.content.height);
         matParams = {"scale":0.01};
         this.centerPopup();
         mat = new Matrix();
         mat.translate(-startSize.x / 2,-startSize.y / 2);
         mat.scale(matParams.scale,matParams.scale);
         mat.translate(startSize.x / 2,startSize.y / 2);
         m_loader.content.transform.matrix = mat;
         TweenLite.to(matParams,TWEEN_TIME,{
            "scale":1,
            "ease":Back.easeOut,
            "onUpdate":function():void
            {
               mat = new Matrix();
               mat.translate(-startSize.x / 2,-startSize.y / 2);
               mat.scale(matParams.scale,matParams.scale);
               mat.translate(startSize.x / 2,startSize.y / 2);
               m_loader.content.transform.matrix = mat;
               this.visible = true;
            },
            "onComplete":function():void
            {
               Utilities.toggleInputAndChildren(this,true);
            }
         });
      }
      
      protected function onFullScreen(event:FullScreenEvent) : void
      {
         this.centerPopup();
      }
      
      protected function onResize(event:Event = null) : void
      {
         this.centerPopup();
      }
      
      public function tintWindow() : void
      {
         if(m_window)
         {
            m_window.transform.colorTransform = m_dimColorTransform;
         }
      }
      
      public function untintWindow() : void
      {
         if(m_window)
         {
            m_window.transform.colorTransform = m_normalColorTransform;
         }
      }
   }
}

