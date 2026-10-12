package GameMode.ModeComponents
{
   import flash.events.MouseEvent;
   
   public interface IGameModeComponent
   {
      
      function onMouseMove(param1:MouseEvent) : Boolean;
      
      function enableMode() : void;
      
      function disableMode() : void;
      
      function handleObjectDrop(param1:MouseEvent) : void;
   }
}

