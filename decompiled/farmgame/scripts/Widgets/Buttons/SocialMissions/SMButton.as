package Widgets.Buttons.SocialMissions
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Interfaces.IZwToggle;
   import flash.display.MovieClip;
   
   public class SMButton extends FarmAnimatedTextButton implements IZwToggle
   {
      
      protected static const TEXT_FIELD_OVER_SCALE_VALUE:Number = 1.14;
      
      private var m_isSelected:Boolean = false;
      
      private var m_toggleMode:String = null;
      
      public function SMButton(element:MovieClip, text:String = "", callback:Function = null)
      {
         super(element,text,callback);
      }
   }
}

