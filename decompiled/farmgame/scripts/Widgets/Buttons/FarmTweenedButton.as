package Widgets.Buttons
{
   import Widgets.Constants.FarmAnimatedInteractiveState;
   import Widgets.Core.Interfaces.IZwSimpleText;
   import flash.display.MovieClip;
   
   public class FarmTweenedButton extends FarmAnimatedTextButton implements IZwSimpleText
   {
      
      public function FarmTweenedButton(element:MovieClip, text:String = "", callback:Function = null)
      {
         super(element,text,callback,false,false);
      }
      
      override public function animateInteractiveState(animatedInteractiveState:String) : void
      {
         switch(animatedInteractiveState)
         {
            case FarmAnimatedInteractiveState.OVER:
               playButtonAnimation(BUTTON_ANIM_STATE_OVER_FRAME);
               break;
            case FarmAnimatedInteractiveState.SELECTED:
               playButtonAnimation(BUTTON_ANIM_STATE_DOWN_FRAME);
               break;
            case FarmAnimatedInteractiveState.DISABLED:
               playButtonAnimation(BUTTON_ANIM_STATE_DISABLED_FRAME);
               break;
            case FarmAnimatedInteractiveState.NORMAL:
            default:
               playButtonAnimation(BUTTON_ANIM_STATE_NORMAL_FRAME);
         }
      }
   }
}

