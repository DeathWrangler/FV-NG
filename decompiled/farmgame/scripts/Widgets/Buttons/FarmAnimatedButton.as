package Widgets.Buttons
{
   import Widgets.Constants.FarmAnimatedInteractiveState;
   import Widgets.Interfaces.IFarmAnimatedInteractive;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   
   public class FarmAnimatedButton extends FarmButton implements IFarmAnimatedInteractive
   {
      
      public static const BUTTON_ANIM_STATE_DEFAULT_FRAME:int = 1;
      
      public static const BUTTON_ANIM_STATE_NORMAL_FRAME:int = 1;
      
      public static const BUTTON_ANIM_STATE_OVER_FRAME:int = 2;
      
      public static const BUTTON_ANIM_STATE_DOWN_FRAME:int = 3;
      
      public static const BUTTON_ANIM_STATE_DISABLED_FRAME:int = 4;
      
      protected static const OVER_SCALE_VALUE:Number = 1.14;
      
      protected var m_autoSize:Boolean = false;
      
      protected var m_normalTransformMatrix:Matrix;
      
      protected var m_overTransformMatrix:Matrix;
      
      public function FarmAnimatedButton(element:MovieClip, callback:Function = null, autoSize:Boolean = false)
      {
         super(element,callback);
         this.m_autoSize = autoSize;
         this.m_normalTransformMatrix = element.transform.matrix.clone();
         this.m_overTransformMatrix = this.calculateOverTransformMatrix();
         this.animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
         this.registerAnimationEventListeners();
         m_element.buttonMode = true;
      }
      
      public function recalculateTransforms() : void
      {
         this.m_normalTransformMatrix = element.transform.matrix.clone();
         this.m_overTransformMatrix = this.calculateOverTransformMatrix();
      }
      
      override public function release() : void
      {
         this.unregisterAnimationEventListeners();
         super.release();
      }
      
      override public function set enabled(isEnabled:Boolean) : void
      {
         if(isEnabled)
         {
            this.animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
            this.registerAnimationEventListeners();
         }
         else
         {
            this.animateInteractiveState(FarmAnimatedInteractiveState.DISABLED);
            this.unregisterAnimationEventListeners();
         }
         super.enabled = isEnabled;
      }
      
      public function animateInteractiveState(animatedInteractiveState:String) : void
      {
         switch(animatedInteractiveState)
         {
            case FarmAnimatedInteractiveState.OVER:
               this.playButtonAnimation(BUTTON_ANIM_STATE_OVER_FRAME);
               m_element.transform.matrix = this.m_overTransformMatrix;
               break;
            case FarmAnimatedInteractiveState.SELECTED:
               this.playButtonAnimation(BUTTON_ANIM_STATE_DOWN_FRAME);
               m_element.transform.matrix = this.m_normalTransformMatrix;
               break;
            case FarmAnimatedInteractiveState.DISABLED:
               this.playButtonAnimation(BUTTON_ANIM_STATE_DISABLED_FRAME);
               m_element.transform.matrix = this.m_normalTransformMatrix;
               break;
            case FarmAnimatedInteractiveState.NORMAL:
            default:
               this.playButtonAnimation(BUTTON_ANIM_STATE_NORMAL_FRAME);
               if(Boolean(m_element) && Boolean(m_element.transform))
               {
                  m_element.transform.matrix = this.m_normalTransformMatrix;
               }
         }
      }
      
      protected function registerAnimationEventListeners() : void
      {
         registerEventListener(MouseEvent.MOUSE_OVER,this.playOverAnim);
         registerEventListener(MouseEvent.MOUSE_DOWN,this.playDownAnim);
         registerEventListener(MouseEvent.MOUSE_UP,this.playUpAnim);
         registerEventListener(MouseEvent.MOUSE_OUT,this.playOutAnim);
      }
      
      protected function unregisterAnimationEventListeners() : void
      {
         unregisterEventListener(MouseEvent.MOUSE_OVER,this.playOverAnim);
         unregisterEventListener(MouseEvent.MOUSE_DOWN,this.playDownAnim);
         unregisterEventListener(MouseEvent.MOUSE_UP,this.playUpAnim);
         unregisterEventListener(MouseEvent.MOUSE_OUT,this.playOutAnim);
      }
      
      protected function playOverAnim(event:MouseEvent) : void
      {
         this.animateInteractiveState(FarmAnimatedInteractiveState.OVER);
      }
      
      protected function playDownAnim(event:MouseEvent) : void
      {
         this.animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
      }
      
      protected function playUpAnim(event:MouseEvent) : void
      {
         this.animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
      }
      
      protected function playOutAnim(event:MouseEvent) : void
      {
         this.animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
      }
      
      protected function playButtonAnimation(buttonAnimStateFrame:int) : void
      {
         var button:MovieClip = m_element as MovieClip;
         if(button)
         {
            if(button.totalFrames >= buttonAnimStateFrame)
            {
               button.gotoAndStop(buttonAnimStateFrame);
            }
            else
            {
               button.gotoAndStop(BUTTON_ANIM_STATE_DEFAULT_FRAME);
            }
         }
      }
      
      protected function calculateOverTransformMatrix() : Matrix
      {
         var xTranslate:Number = NaN;
         var yTranslate:Number = NaN;
         var transformMatrix:Matrix = this.m_normalTransformMatrix.clone();
         if(this.m_autoSize)
         {
            xTranslate = x + width / 2;
            yTranslate = y + height / 2;
            transformMatrix.translate(-xTranslate,-yTranslate);
            transformMatrix.scale(OVER_SCALE_VALUE,OVER_SCALE_VALUE);
            transformMatrix.translate(xTranslate,yTranslate);
         }
         return transformMatrix;
      }
      
      override public function toggleClickableButton(onOff:Boolean, tooltipText:String = "") : void
      {
         if(onOff)
         {
            this.registerAnimationEventListeners();
         }
         else
         {
            this.unregisterAnimationEventListeners();
         }
         super.toggleClickableButton(onOff,tooltipText);
      }
   }
}

