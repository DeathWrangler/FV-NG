package Classes
{
   public interface IRotatable
   {
      
      function syncRotationChange() : void;
      
      function rotate(param1:Boolean = true) : void;
      
      function canRotate() : Boolean;
   }
}

