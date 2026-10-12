package Replay
{
   public class IntUtils
   {
      
      public function IntUtils()
      {
         super();
      }
      
      public static function genPositive() : int
      {
         return Math.random();
      }
      
      public static function gen() : int
      {
         var returnValue:int = 0;
         var floatValue:Number = (Math.random() - 0.5) * 2;
         if(floatValue < 0)
         {
            returnValue = floatValue * int.MIN_VALUE;
         }
         else
         {
            returnValue = floatValue * int.MAX_VALUE;
         }
         return returnValue;
      }
      
      public static function genBetween(start:int, end:int) : int
      {
         var floatValue:Number = Math.random();
         var length:Number = end - start;
         return int(length * floatValue + start);
      }
   }
}

