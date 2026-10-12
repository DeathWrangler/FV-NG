package by.blooddy.crypto.image.palette
{
   public interface IPalette
   {
      
      function getColors() : Vector.<uint>;
      
      function getIndexByColor(param1:uint) : uint;
   }
}

