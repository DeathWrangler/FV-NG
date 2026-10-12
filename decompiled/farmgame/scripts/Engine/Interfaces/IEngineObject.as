package Engine.Interfaces
{
   public interface IEngineObject
   {
      
      function get children() : Array;
      
      function cleanUp() : void;
      
      function update() : void;
      
      function attach() : void;
      
      function detach() : void;
   }
}

