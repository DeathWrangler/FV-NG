package Widgets.Core.Interfaces
{
   public interface IZwEventHandling
   {
      
      function registerEventListener(param1:String, param2:Function) : void;
      
      function unregisterEventListener(param1:String, param2:Function) : void;
   }
}

