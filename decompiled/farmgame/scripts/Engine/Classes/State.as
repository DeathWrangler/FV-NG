package Engine.Classes
{
   public class State
   {
      
      public static const FULL_INTERRUPT:int = 1;
      
      public static const NORMAL_INTERRUPT:int = 2;
      
      public static const NO_INTERRUPT:int = 3;
      
      public function State()
      {
         super();
      }
      
      public function added() : void
      {
      }
      
      public function removed() : void
      {
      }
      
      public function enter() : void
      {
      }
      
      public function exit() : void
      {
      }
      
      public function reenter() : void
      {
      }
      
      public function update(param1:Number) : void
      {
      }
      
      public function getInterrupt() : int
      {
         return NORMAL_INTERRUPT;
      }
   }
}

