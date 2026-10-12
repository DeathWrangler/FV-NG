package Widgets.Core.Interfaces
{
   public interface IZwToggle
   {
      
      function startListenForToggle(param1:Function) : void;
      
      function stopListenForToggle(param1:Function) : void;
      
      function setToggleState(param1:String) : void;
      
      function setToggleMode(param1:String) : void;
   }
}

