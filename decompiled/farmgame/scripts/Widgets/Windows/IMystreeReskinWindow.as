package Widgets.Windows
{
   public interface IMystreeReskinWindow
   {
      
      function close() : void;
      
      function enableSpeedUp(param1:Boolean) : void;
      
      function enableWatchToSpeedup(param1:Boolean) : void;
      
      function updateSunshineBuckets() : void;
      
      function isNPCAnimationAvailable() : Boolean;
      
      function animateNpc(param1:Function) : void;
   }
}

