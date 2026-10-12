package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.util.ZLocUtils;
   import Managers.ClickTrackingManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.*;
   
   public class GenericButton
   {
      
      public static var UPSTATE:String = "up";
      
      public static var OVERSTATE:String = "over";
      
      public static var DOWNSTATE:String = "down";
      
      public static var HITSTATE:String = "hit";
      
      private static const COLOR_GRAY_PERCENTAGE:Number = 0.6;
      
      private var m_overStateScale:Number = 1.14;
      
      private var m_currentScaling:Number = 1;
      
      private var m_buttonValue:String = "";
      
      protected var m_target:MovieClip;
      
      private var m_text:String;
      
      private var m_disabled:Boolean = false;
      
      private var m_useGrayOnDisabled:Boolean = false;
      
      private var m_callback:Function = null;
      
      public var m_overlay:MovieClip;
      
      private var m_tfOver:TextFormat;
      
      protected var m_state:String = "up";
      
      protected var m_enableHitState:Boolean = false;
      
      private var m_hitFrameNumber:int = 3;
      
      private var m_curFrame:int = 1;
      
      protected var m_enterFrameOn:Boolean = false;
      
      private var normalTransform:Matrix;
      
      private var scaledTransform:Matrix;
      
      private var targetTransform:Matrix;
      
      public function GenericButton(target_mc:MovieClip, clickCallback:Function = null, val:String = "", overlayName:String = "")
      {
         var extraChild:MovieClip = null;
         this.m_overlay = new MovieClip();
         super();
         this.m_tfOver = new TextFormat();
         this.m_tfOver.size = 15;
         this.m_target = target_mc;
         var bounds:Rectangle = this.m_target.getBounds(this.m_target.parent);
         this.m_overlay.graphics.beginFill(255,0);
         this.m_overlay.graphics.drawRect(0,0,bounds.width,bounds.height);
         this.m_overlay.graphics.endFill();
         var parentClip:MovieClip = this.m_target.parent as MovieClip;
         if(overlayName != "")
         {
            extraChild = parentClip.getChildByName(overlayName) as MovieClip;
            if(extraChild != null)
            {
               parentClip.removeChild(extraChild);
            }
         }
         else
         {
            overlayName = "gb_Overlay";
         }
         this.m_target.parent.addChild(this.m_overlay);
         this.m_overlay.x = bounds.x;
         this.m_overlay.y = bounds.y;
         this.m_overlay.buttonMode = true;
         this.m_overlay.name = overlayName;
         this.m_overlay.buttonPointer = this;
         target_mc.buttonMode = true;
         target_mc.useHandCursor = true;
         target_mc.gotoAndStop(1);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         if(clickCallback != null)
         {
            this.m_callback = clickCallback;
            this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick);
         }
         target_mc.addFrameScript(0,this.frameScriptTextUpdate);
         target_mc.addFrameScript(1,this.frameScriptTextUpdate);
         target_mc.addFrameScript(2,this.frameScriptTextUpdate);
         target_mc.addFrameScript(3,this.frameScriptTextUpdate);
         this.m_text = "";
         if(Boolean(this.m_target.generic_tf) && Boolean(this.m_target.generic_tf.text))
         {
            this.m_text = this.m_target.generic_tf.text;
            this.normalTransform = this.m_target.generic_tf.transform.matrix.clone();
            this.calcScaledTransform();
            this.targetTransform = this.normalTransform;
         }
         this.buttonValue = val;
      }
      
      private function calcScaledTransform() : void
      {
         var xTrans:Number = this.m_target.generic_tf.x + this.m_target.generic_tf.width / 2;
         var yTrans:Number = this.m_target.generic_tf.y + this.m_target.generic_tf.height / 2;
         this.scaledTransform = this.normalTransform.clone();
         this.scaledTransform.translate(-xTrans,-yTrans);
         this.scaledTransform.scale(this.m_overStateScale,this.m_overStateScale);
         this.scaledTransform.translate(xTrans,yTrans);
      }
      
      protected function onOver(event:MouseEvent) : void
      {
         if(!this.disabled)
         {
            this.m_target.addFrameScript(1,this.frameScriptTextUpdate);
            this.m_enterFrameOn = false;
            if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
            {
               this.targetTransform = this.scaledTransform;
               this.m_currentScaling = this.m_overStateScale;
               this.m_state = OVERSTATE;
               this.m_target.gotoAndStop(this.m_target.totalFrames);
               this.m_target.gotoAndStop(2);
               Global.stage.invalidate();
               this.m_target.addEventListener(Event.RENDER,this.updateText);
            }
         }
      }
      
      private function onDown(event:MouseEvent) : void
      {
         this.m_target.addFrameScript(2,this.frameScriptTextUpdate);
         this.m_enterFrameOn = false;
         this.targetTransform = this.normalTransform;
         if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
         {
            this.m_state = DOWNSTATE;
            Global.stage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(3);
         }
      }
      
      protected function onOut(event:MouseEvent) : void
      {
         this.targetTransform = this.normalTransform;
         this.m_target.addFrameScript(0,this.frameScriptTextUpdate);
         this.m_enterFrameOn = false;
         if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
         {
            this.m_state = UPSTATE;
            Global.stage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(1);
         }
      }
      
      private function onClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         if(!this.disabled)
         {
            this.m_target.addFrameScript(this.m_hitFrameNumber - 1,this.frameScriptTextUpdate);
            this.m_enterFrameOn = false;
            this.targetTransform = this.normalTransform;
            this.m_state = HITSTATE;
            Global.stage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(this.m_hitFrameNumber);
            if(this.m_callback != null)
            {
               this.handleClickCallback(event);
            }
         }
      }
      
      protected function handleClickCallback(event:MouseEvent) : void
      {
         this.m_callback(event);
      }
      
      public function set text(txt:String) : void
      {
         this.m_curFrame = this.m_target.currentFrame;
         this.m_target.gotoAndStop(this.m_target.totalFrames);
         this.m_target.gotoAndStop(this.m_curFrame);
         this.m_text = txt;
         if(this.m_target.generic_tf)
         {
            this.m_target.generic_tf.text = txt;
            ZLocUtils.autoFormatSize(this.m_target.generic_tf,2237183);
         }
         else
         {
            this.m_target.addFrameScript(this.m_curFrame,this.frameScriptTextUpdate);
         }
      }
      
      public function set tfOver(tf:TextFormat) : void
      {
         this.m_tfOver = tf;
      }
      
      public function set state(newState:String) : void
      {
         switch(newState)
         {
            case UPSTATE:
               this.m_target.gotoAndStop(1);
               this.m_state = UPSTATE;
               break;
            case OVERSTATE:
               this.m_target.gotoAndStop(2);
               this.m_state = OVERSTATE;
               break;
            case DOWNSTATE:
               this.m_target.gotoAndStop(3);
               this.m_state = DOWNSTATE;
               break;
            case HITSTATE:
               this.m_target.gotoAndStop(this.m_hitFrameNumber);
               this.m_state = HITSTATE;
         }
      }
      
      public function get state() : String
      {
         return this.m_state;
      }
      
      public function enableHitState(enable:Boolean) : void
      {
         this.m_enableHitState = enable;
      }
      
      public function setHitFrameNumber(hitFrame:int) : void
      {
         if(hitFrame > 0 && hitFrame <= this.m_target.totalFrames)
         {
            this.m_hitFrameNumber = hitFrame;
         }
      }
      
      public function turnOff(keepButtonVisible:Boolean = false) : void
      {
         this.m_target.buttonMode = false;
         this.m_target.useHandCursor = false;
         this.m_target.visible = keepButtonVisible;
         this.m_overlay.buttonMode = false;
         this.m_overlay.visible = false;
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         if(this.m_callback != null)
         {
            this.m_overlay.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      public function turnOn() : void
      {
         this.turnOff();
         this.m_target.visible = true;
         this.m_target.buttonMode = true;
         this.m_target.useHandCursor = true;
         this.m_overlay.buttonMode = true;
         this.m_overlay.visible = true;
         this.m_overlay.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         if(this.m_callback != null)
         {
            this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      public function toggleDisable(setState:Boolean) : void
      {
         this.disabled = !setState;
      }
      
      protected function frameScriptTextUpdate() : void
      {
         if(Boolean(this.m_target.generic_tf) && this.m_text != "")
         {
            this.m_target.generic_tf.text = this.m_text;
            ZLocUtils.autoFormatSize(this.m_target.generic_tf,2237183);
            this.m_enterFrameOn = false;
            this.m_target.generic_tf.transform.matrix = this.targetTransform;
         }
         else if(!this.m_enterFrameOn)
         {
            this.m_target.addEventListener(Event.ENTER_FRAME,this.updateText);
            this.m_enterFrameOn = true;
         }
      }
      
      protected function updateText(event:Event) : void
      {
         if(Boolean(this.m_target.generic_tf) && this.m_text != "")
         {
            this.m_target.generic_tf.text = this.m_text;
            ZLocUtils.autoFormatSize(this.m_target.generic_tf,2237183);
            this.calcScaledTransform();
            if(this.m_target.hasEventListener(Event.ENTER_FRAME))
            {
               this.m_target.removeEventListener(Event.ENTER_FRAME,this.updateText);
            }
            if(this.m_target.hasEventListener(Event.RENDER))
            {
               this.m_target.removeEventListener(Event.RENDER,this.updateText);
            }
         }
      }
      
      public function getButton() : MovieClip
      {
         return this.m_target;
      }
      
      public function set useGrayOnDisabled(onOff:Boolean) : void
      {
         this.m_useGrayOnDisabled = onOff;
      }
      
      public function get useGrayOnDisabled() : Boolean
      {
         return this.m_useGrayOnDisabled;
      }
      
      public function set disabled(onOff:Boolean) : void
      {
         var matrix:Array = null;
         var g:Number = NaN;
         this.m_disabled = onOff;
         if(onOff)
         {
            this.m_overlay.buttonMode = false;
            this.m_overlay.visible = false;
            if(this.m_useGrayOnDisabled)
            {
               matrix = new Array();
               g = COLOR_GRAY_PERCENTAGE;
               matrix = matrix.concat([g,0,0,0,0]);
               matrix = matrix.concat([0,g,0,0,0]);
               matrix = matrix.concat([0,0,g,0,0]);
               matrix = matrix.concat([0,0,0,1,0]);
               this.m_target.filters = [new ColorMatrixFilter(matrix)];
            }
         }
         else
         {
            this.m_overlay.buttonMode = true;
            this.m_overlay.visible = true;
            this.m_target.filters = [];
         }
      }
      
      public function get disabled() : Boolean
      {
         return this.m_disabled;
      }
      
      public function get callback() : Function
      {
         return this.m_callback;
      }
      
      public function set buttonValue(val:String) : void
      {
         this.m_overlay.buttonValue = val;
         this.m_buttonValue = val;
      }
      
      public function get buttonValue() : String
      {
         return this.m_buttonValue;
      }
   }
}

