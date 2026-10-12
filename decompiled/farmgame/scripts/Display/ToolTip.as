package Display
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ToolTip extends FarmGameSprite
   {
      
      public function ToolTip()
      {
         super();
      }
      
      public function attachToolTip(displayObj:DisplayObject) : void
      {
         displayObj.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         displayObj.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
         displayObj.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
      }
      
      public function detachToolTip(displayObj:DisplayObject) : void
      {
         displayObj.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         displayObj.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
         displayObj.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
      }
      
      public function show() : void
      {
         onRollOver(null);
      }
      
      public function hide() : void
      {
         onRollOut(null);
      }
      
      public function updatePosition() : void
      {
         this.updateToolTipPosition();
      }
   }
}

