package Classes
{
   public class PermanentBuff extends Buff
   {
      
      public static const NEVER_EXPIRES_SECONDS:int = 1;
      
      public static const NEVER_EXPIRES_TTL:Number = 1;
      
      public function PermanentBuff(itemName:String)
      {
         super(itemName);
      }
      
      override public function isExpired() : Boolean
      {
         return false;
      }
      
      override public function get secondsRemaining() : int
      {
         return NEVER_EXPIRES_SECONDS;
      }
      
      override protected function getExpiresTTL() : Number
      {
         return NEVER_EXPIRES_TTL;
      }
   }
}

