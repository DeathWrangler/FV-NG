package Engine.Interfaces
{
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public interface IInputHandler
   {
      
      function onMouseDown(param1:MouseEvent) : Boolean;
      
      function onMouseUp(param1:MouseEvent) : Boolean;
      
      function onMouseOut(param1:MouseEvent) : Boolean;
      
      function onMouseMove(param1:MouseEvent) : Boolean;
      
      function onMouseDoubleClick(param1:MouseEvent) : Boolean;
      
      function onMouseWheel(param1:MouseEvent) : Boolean;
      
      function onKeyDown(param1:KeyboardEvent) : Boolean;
      
      function onKeyUp(param1:KeyboardEvent) : Boolean;
   }
}

