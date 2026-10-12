package Widgets.Buttons.Collections
{
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.display.MovieClip;
   
   public class CollectionsAnimatedButton extends FarmAnimatedButton
   {
      
      protected var m_buttonCode:String = "";
      
      public function CollectionsAnimatedButton(element:MovieClip, callback:Function = null, autoSize:Boolean = false, buttonCode:String = "")
      {
         super(element,callback,autoSize);
         this.m_buttonCode = buttonCode;
      }
      
      public function setButtonCode(code:String) : void
      {
         this.m_buttonCode = code;
      }
      
      public function getButtonCode() : String
      {
         return this.m_buttonCode;
      }
   }
}

