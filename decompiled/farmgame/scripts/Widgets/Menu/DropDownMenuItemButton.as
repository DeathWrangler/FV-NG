package Widgets.Menu
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class DropDownMenuItemButton extends FarmAnimatedTextButton
   {
      
      public function DropDownMenuItemButton(element:MovieClip, text:String, callBack:Function)
      {
         super(element,text,callBack);
         this.registerEventListener(MouseEvent.CLICK,this.killPropogation);
      }
      
      protected function killPropogation(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      override protected function scaleTextOverSize() : void
      {
      }
      
      override protected function scaleTextNormalSize() : void
      {
      }
   }
}

