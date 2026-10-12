package Display
{
   import Engine.Events.LoaderEvent;
   import Engine.Managers.InputManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.FreezeManager;
   import Managers.SmartPopupManager;
   import Widgets.View.Dialogs.DataDrivenDialogView;
   import fl.motion.easing.Back;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class Dialog extends MovieClip
   {
      
      public static const TWEEN_TIME:Number = 0.5;
      
      public static const DIALOG_ASSET_TYPE_SWF:Number = 100;
      
      public static const DIALOG_ASSET_TYPE_DDD:Number = 101;
      
      public static const CLICK_BLOCKER_COLOR:Number = 0;
      
      public static const CLICK_BLOCKER_ALPHA:Number = 0.2;
      
      protected var m_window:MovieClip;
      
      protected var m_nDialogAssetType:Number = 0;
      
      protected var m_dialogAsset:String = null;
      
      protected var m_loader:Loader = null;
      
      protected var m_pDDDialogView:DataDrivenDialogView = null;
      
      protected var m_modal:Boolean = true;
      
      protected var m_bAddClickBlocker:Boolean = false;
      
      protected var m_mcClickBlocker:MovieClip;
      
      protected var m_shown:Boolean = false;
      
      protected var m_loaded:Boolean = false;
      
      protected var m_showOnLoad:Boolean = false;
      
      protected var m_cursorId:int = 0;
      
      protected var m_showTween:Boolean = false;
      
      protected var m_trackerKey:String = "";
      
      private var m_zaspLoadHandle:int = 0;
      
      private var m_dialogOffset:Point = null;
      
      public function Dialog(modal:Boolean = true, bAddClickBlocker:Boolean = false, nDialogAssetType:Number = 100, aLocalizeParams:Array = null)
      {
         var xml:XML = null;
         this.m_mcClickBlocker = new MovieClip();
         super();
         this.m_modal = modal;
         this.m_bAddClickBlocker = bAddClickBlocker;
         addChild(this.m_mcClickBlocker);
         this.m_nDialogAssetType = nDialogAssetType;
         if(this.m_dialogAsset)
         {
            switch(this.m_nDialogAssetType)
            {
               case DIALOG_ASSET_TYPE_DDD:
                  xml = Global.dynamicDialogs.getDialogsXMLByName(this.m_dialogAsset);
                  if(xml != null)
                  {
                     this.m_pDDDialogView = new DataDrivenDialogView(xml,Global.getAssetURL(""),aLocalizeParams);
                     this.m_showOnLoad = true;
                     addChild(this.getWindow());
                     this.onLoadComplete();
                     this.onFinishLoad();
                  }
                  else if(Config.DEBUG_MODE == true)
                  {
                     GlobalEngine.log("dialogs","could not find XML Dialog: " + this.m_dialogAsset + " (do you need to compress the dialogs.xml.gz file?)");
                     UI.displayMessage("could not find XML Dialog: " + this.m_dialogAsset + " (do you need to compress the dialogs.xml.gz file?)",0,null,"",true);
                  }
                  break;
               default:
                  this.m_loader = LoadingManager.load(Global.getAssetURL(this.m_dialogAsset),this.onLoaderEvent,LoadingManager.PRIORITY_HIGH);
                  this.visible = false;
            }
         }
      }
      
      public function getWindow() : MovieClip
      {
         var mcRes:MovieClip = null;
         switch(this.m_nDialogAssetType)
         {
            case DIALOG_ASSET_TYPE_DDD:
               mcRes = this.m_pDDDialogView as MovieClip;
               break;
            default:
               mcRes = this.m_loader.content as MovieClip;
         }
         if(this.m_window == null && mcRes != null)
         {
            this.m_window = mcRes;
         }
         return mcRes;
      }
      
      public function isDataDrivenDialog() : Boolean
      {
         return this.m_nDialogAssetType == DIALOG_ASSET_TYPE_DDD;
      }
      
      public function getDataDrivenDialogView() : DataDrivenDialogView
      {
         var res:DataDrivenDialogView = null;
         if(this.m_nDialogAssetType == DIALOG_ASSET_TYPE_DDD)
         {
            res = this.m_pDDDialogView;
         }
         return res;
      }
      
      private function onLoaderEvent(event:Event) : void
      {
         if(Boolean(this.m_loader) && Boolean(this.m_loader.content) && Boolean(this.m_loader.content as MovieClip))
         {
            this.m_window = this.m_loader.content as MovieClip;
            if(this.m_window)
            {
               addChild(this.m_window);
               this.onLoadComplete();
            }
            this.m_loader.content.filters = [new DropShadowFilter()];
         }
         else
         {
            this.onLoadComplete();
         }
         this.onFinishLoad();
      }
      
      private function onFinishLoad() : void
      {
         dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
         this.m_loaded = true;
         if(this.m_showOnLoad)
         {
            this.m_showOnLoad = false;
            this.show();
         }
      }
      
      protected function onLoadComplete() : void
      {
      }
      
      protected function onHide() : void
      {
         if(this.m_shown == true)
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
      
      protected function onShow() : void
      {
         if(this.m_shown == false)
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
         SoundManager.playSound("dialogSpawn");
      }
      
      protected function onFullScreen(event:FullScreenEvent) : void
      {
         this.centerPopup();
      }
      
      protected function onResize(event:Event = null) : void
      {
         this.centerPopup();
      }
      
      public function close() : void
      {
         var dispObj:DisplayObject = null;
         if(this.m_showTween)
         {
            dispObj = this;
            this.hideTween(function():void
            {
               if(dispObj.parent)
               {
                  dispObj.parent.removeChild(dispObj);
                  dispObj = null;
               }
               dispatchEvent(new Event(Event.CLOSE));
            });
            this.onHide();
         }
         else
         {
            this.onHide();
            if(parent)
            {
               parent.removeChild(this);
            }
            else if(FreezeManager.isAllFrozen() == true)
            {
               FreezeManager.removeFrozenPopup(this);
            }
            else
            {
               this.visible = false;
            }
            dispatchEvent(new Event(Event.CLOSE));
         }
         if(this.m_pDDDialogView != null)
         {
            this.m_pDDDialogView.destroy();
            this.m_pDDDialogView = null;
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
            visible = false;
         }
      }
      
      protected function hideTween(callback:Function) : void
      {
         var matParams:Object = null;
         var startSize:Point = null;
         Utilities.toggleInputAndChildren(this,false);
         if(this.m_loader == null || this.m_loader.content == null)
         {
            if(callback != null)
            {
               callback();
            }
         }
         else
         {
            matParams = {"scale":1};
            startSize = new Point(this.m_loader.content.width,this.m_loader.content.height);
            TweenLite.to(matParams,TWEEN_TIME,{
               "scale":0,
               "ease":Back.easeIn,
               "onUpdate":function():void
               {
                  var mat:* = new Matrix();
                  mat.translate(-startSize.x / 2,-startSize.y / 2);
                  mat.scale(matParams.scale,matParams.scale);
                  mat.translate(startSize.x / 2,startSize.y / 2);
                  m_loader.content.transform.matrix = mat;
               },
               "onComplete":callback
            });
         }
         SoundManager.playSound("dialogClose");
      }
      
      protected function showTween() : void
      {
         var startSize:Point = null;
         var matParams:Object = null;
         var mat:Matrix = null;
         Utilities.toggleInputAndChildren(this,false);
         startSize = new Point(this.m_loader.content.width,this.m_loader.content.height);
         matParams = {"scale":0.01};
         this.centerPopup();
         mat = new Matrix();
         mat.translate(-startSize.x / 2,-startSize.y / 2);
         mat.scale(matParams.scale,matParams.scale);
         mat.translate(startSize.x / 2,startSize.y / 2);
         this.m_loader.content.transform.matrix = mat;
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
      
      public function show() : void
      {
         if(this.m_loaded)
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
      
      public function getDialogOffset() : Point
      {
         if(this.m_dialogOffset)
         {
            return this.m_dialogOffset;
         }
         return new Point(0,0);
      }
      
      public function setDialogOffset(offset:Point) : void
      {
         this.m_dialogOffset = offset;
      }
      
      public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var offset:Point = null;
         var rect:Rectangle = null;
         if(parent)
         {
            this.removeClickBlocker();
            offset = this.getDialogOffset();
            if(Boolean(this.m_window) && this.m_window.hasOwnProperty("size_mc"))
            {
               rect = new Rectangle(0,0,this.m_window.size_mc.width,this.m_window.size_mc.height);
            }
            else
            {
               rect = getRect(parent);
            }
            if(pAbsolutePos != null)
            {
               this.x = pAbsolutePos.x;
               this.y = pAbsolutePos.y;
            }
            else if(this.m_nDialogAssetType == DIALOG_ASSET_TYPE_DDD && Boolean(this.m_pDDDialogView))
            {
               this.x = (Global.stage.stageWidth - this.m_pDDDialogView.getWidth()) * 0.5 + offset.x;
               this.y = (Global.stage.stageHeight - this.m_pDDDialogView.getHeight()) * 0.5 + offset.y;
            }
            else
            {
               this.x = (Global.stage.stageWidth - rect.width) / 2 + offset.x;
               this.y = (Global.stage.stageHeight - rect.height) / 2 + offset.y;
            }
            this.addClickBlocker();
         }
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
         this.m_mcClickBlocker.x = -this.x;
         this.m_mcClickBlocker.y = -this.y;
      }
      
      private function removeClickBlocker() : void
      {
         this.m_mcClickBlocker.graphics.clear();
      }
      
      public function get shouldFreeze() : Boolean
      {
         return true;
      }
      
      public function getTrackerKey() : String
      {
         return this.m_trackerKey;
      }
      
      public function setTrackerKey(trackerKey:String = "") : void
      {
         this.m_trackerKey = trackerKey;
      }
      
      public function getTrackerEnabled() : Boolean
      {
         return this.m_trackerKey != "" && this.m_trackerKey != null;
      }
      
      public function onShareClick(event:MouseEvent) : void
      {
         if(this.getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(this.m_trackerKey,"Share");
         }
      }
      
      public function onCloseClick(event:MouseEvent) : void
      {
         if(this.getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupDeclined(this.m_trackerKey,"OK");
         }
      }
      
      public function getSuppress() : Boolean
      {
         if(!this.getTrackerEnabled())
         {
            return false;
         }
         return false;
      }
   }
}

