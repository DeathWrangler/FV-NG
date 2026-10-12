package Managers
{
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Utilities;
   import com.adobe.images.PNGEncoder;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import mx.utils.Base64Encoder;
   
   public class FreezeManager
   {
      
      private static var m_frozenBitmap:Bitmap;
      
      private static var m_frozenSprite:Sprite;
      
      public static var freezingUnlocked:Boolean = false;
      
      private static var m_frozenDispObj:Array = null;
      
      protected static var m_state:int = 0;
      
      protected static const STATE_THAWED:int = 0;
      
      protected static const STATE_RENDER_FROZEN:int = 1;
      
      protected static const STATE_ALL_FROZEN:int = 2;
      
      protected static var m_frozenTime:Number = 0;
      
      protected static const CLICK_TO_THAW_TIME:int = 3000;
      
      protected static var m_postThawCallbackArray:Array = [];
      
      public function FreezeManager()
      {
         super();
      }
      
      public static function freezeAll(allowClickUnfreeze:Boolean = true, alpha:Number = 0.3) : void
      {
         var stage:Stage = null;
         var bData:BitmapData = null;
         var rect:Shape = null;
         if(freezingUnlocked && !FreezeManager.isAllFrozen())
         {
            FreezeManager.thawRender();
            if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Global.stage.displayState = StageDisplayState.NORMAL;
            }
            stage = Global.stage;
            bData = new BitmapData(stage.stageWidth,stage.stageHeight,false,0);
            bData.draw(stage);
            rect = new Shape();
            rect.graphics.beginFill(0,alpha);
            rect.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            rect.graphics.endFill();
            bData.draw(rect);
            if(allowClickUnfreeze)
            {
               createFrozenSprite(bData,onFrozenAllClick);
            }
            else
            {
               createFrozenSprite(bData);
            }
            freezeObjects();
            stage.addChild(m_frozenSprite);
            Global.farmGame.setGameUpdateFunction(FreezeManager.onEnterFrame);
            m_frozenTime = GlobalEngine.currentTime;
            m_state = STATE_ALL_FROZEN;
         }
      }
      
      public static function freezeRender() : void
      {
         var stage:Stage = null;
         var viewport:Sprite = null;
         var bData:BitmapData = null;
         var errorMessage:String = null;
         var hud:HUD = null;
         var rect:Shape = null;
         if(freezingUnlocked && !FreezeManager.isAnythingFrozen())
         {
            stage = Global.stage;
            viewport = GlobalEngine.viewport;
            if(Boolean(stage) && Boolean(viewport))
            {
               try
               {
                  bData = new BitmapData(stage.stageWidth,stage.stageHeight,true,0);
               }
               catch(e:ArgumentError)
               {
                  errorMessage = e.message;
                  errorMessage += ",source=FreezeManager.freezeRender";
                  errorMessage += ",stage.stageWidth=" + stage.stageWidth;
                  errorMessage += ",stage.stageHeight=" + stage.stageHeight;
                  FarmGameUtil.reportClientLog(errorMessage);
               }
               if(bData)
               {
                  bData.draw(viewport);
                  hud = Global.hud;
                  if(shouldFreezeHUD() && hud != null)
                  {
                     bData.draw(hud);
                     if(hud.parent != null)
                     {
                        hud.parent.removeChild(hud);
                     }
                  }
                  rect = new Shape();
                  rect.graphics.beginFill(0,0.3);
                  rect.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
                  rect.graphics.endFill();
                  bData.draw(rect);
                  createFrozenSprite(bData,onFrozenRenderClick);
                  if(viewport != null && viewport.parent != null)
                  {
                     swapElements(viewport,m_frozenSprite);
                  }
                  m_state = STATE_RENDER_FROZEN;
               }
            }
         }
      }
      
      protected static function freezeObjects() : void
      {
         var ind:* = 0;
         var stage:Stage = Global.stage;
         if(m_frozenDispObj == null)
         {
            m_frozenDispObj = new Array();
         }
         for(ind = 0; ind < stage.numChildren; ind++)
         {
            m_frozenDispObj.push(stage.getChildAt(ind));
         }
         for(ind = int(stage.numChildren - 1); ind >= 0; ind--)
         {
            stage.removeChildAt(ind);
         }
      }
      
      public static function pushPostThawCallback(callback:Function) : void
      {
         m_postThawCallbackArray.push(callback);
      }
      
      public static function thaw(forceThawRender:Boolean = false) : void
      {
         var callback:Function = null;
         var stage:Stage = null;
         var dispObj:DisplayObject = null;
         var root:DisplayObject = null;
         if(FreezeManager.isAnythingFrozen())
         {
            if(!UI.isShowingPopup() || forceThawRender)
            {
               FreezeManager.thawRender();
            }
            if(FreezeManager.isAllFrozen())
            {
               stage = Global.stage;
               stage.removeChild(m_frozenSprite);
               if(m_frozenBitmap.bitmapData)
               {
                  m_frozenBitmap.bitmapData.dispose();
               }
               Global.farmGame.resetGameUpdateFunction();
               m_frozenSprite.removeEventListener(MouseEvent.CLICK,onFrozenAllClick);
               m_frozenSprite = null;
               m_frozenBitmap = null;
               freezeObjects();
               for each(dispObj in m_frozenDispObj)
               {
                  if(dispObj)
                  {
                     Global.stage.addChildAt(dispObj,Global.stage.numChildren);
                  }
               }
               root = Global.stage.getChildByName("root1");
               if(Boolean(root) && root is FarmGame)
               {
                  stage.setChildIndex(root,0);
               }
               m_frozenDispObj.splice(0,m_frozenDispObj.length);
               m_state = STATE_THAWED;
               InputManager.enableInput();
               if(UI.isShowingPopup())
               {
                  FreezeManager.freezeRender();
               }
               else
               {
                  Utilities.toggleInputAndChildren(Global.ui,true);
                  UI.pumpPopupQueue();
               }
               Global.world.resetPerformanceTracking();
            }
            while(m_postThawCallbackArray.length > 0)
            {
               callback = m_postThawCallbackArray.shift();
               callback();
            }
         }
      }
      
      protected static function thawRender() : void
      {
         if(FreezeManager.isRenderFrozen())
         {
            swapElements(m_frozenSprite,GlobalEngine.viewport);
            if(shouldFreezeHUD())
            {
               Global.ui.addChild(Global.hud);
            }
            m_frozenSprite.removeEventListener(MouseEvent.CLICK,onFrozenRenderClick);
            if(m_frozenBitmap.bitmapData)
            {
               m_frozenBitmap.bitmapData.dispose();
            }
            m_frozenBitmap = null;
            m_frozenSprite = null;
            m_state = STATE_THAWED;
         }
      }
      
      public static function isRenderFrozen() : Boolean
      {
         return STATE_RENDER_FROZEN == m_state;
      }
      
      public static function isAllFrozen() : Boolean
      {
         return STATE_ALL_FROZEN == m_state;
      }
      
      public static function isAnythingFrozen() : Boolean
      {
         return STATE_THAWED != m_state;
      }
      
      protected static function onFrozenRenderClick(event:Event) : void
      {
         if(FreezeManager.isRenderFrozen() && !UI.isShowingPopup())
         {
            FreezeManager.thaw();
         }
      }
      
      protected static function onFrozenAllClick(event:Event) : void
      {
         if(FreezeManager.isAllFrozen() && CLICK_TO_THAW_TIME + m_frozenTime < GlobalEngine.currentTime)
         {
            FreezeManager.thaw();
         }
      }
      
      public static function removeFrozenPopup(dispObj:DisplayObject) : void
      {
         var ind:int = 0;
         if(m_frozenDispObj)
         {
            for(ind = 0; ind < m_frozenDispObj.length; ind++)
            {
               if(m_frozenDispObj[ind] as DisplayObject == dispObj)
               {
                  m_frozenDispObj.splice(ind,1);
                  break;
               }
            }
         }
      }
      
      protected static function onEnterFrame(event:Event) : void
      {
         if(FreezeManager.isAllFrozen())
         {
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.preUpdate();
            }
            if(Global.world)
            {
               Global.world.updateFrozen();
            }
            if(Global.ui)
            {
               Global.ui.update();
            }
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.postUpdate();
            }
         }
      }
      
      public static function exportScreenshot() : String
      {
         var encoder:Base64Encoder = null;
         var screenshotBase64:String = null;
         var result:String = null;
         var stage:Stage = Global.stage;
         var bData:BitmapData = new BitmapData(stage.stageWidth,stage.stageHeight,false,0);
         bData.draw(stage);
         var rect:Shape = new Shape();
         rect.graphics.beginFill(0,0.3);
         rect.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         rect.graphics.endFill();
         bData.draw(rect);
         var pngBytes:ByteArray = PNGEncoder.encode(bData);
         if(pngBytes)
         {
            encoder = new Base64Encoder();
            encoder.encodeBytes(pngBytes);
            screenshotBase64 = encoder.toString();
            if(screenshotBase64)
            {
               result = screenshotBase64;
            }
         }
         return result;
      }
      
      protected static function createFrozenSprite(bData:BitmapData, mouseFunc:Function = null) : void
      {
         m_frozenBitmap = new Bitmap(bData);
         m_frozenSprite = new Sprite();
         m_frozenSprite.addChild(m_frozenBitmap);
         if(mouseFunc != null)
         {
            Utilities.toggleInputAndChildren(m_frozenSprite,true);
            m_frozenSprite.addEventListener(MouseEvent.CLICK,mouseFunc);
         }
      }
      
      private static function swapElements(existing:DisplayObject, replacement:DisplayObject) : void
      {
         var idx:int = 0;
         var container:DisplayObjectContainer = existing.parent;
         if(container != null)
         {
            idx = container.getChildIndex(existing);
            if(idx != -1)
            {
               container.removeChildAt(idx);
               container.addChildAt(replacement,idx);
            }
         }
      }
      
      private static function shouldFreezeHUD() : Boolean
      {
         return Global.experimentManager.getExperimentVariant("fv_perf_freeze_hud") > 1 || PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment;
      }
   }
}

