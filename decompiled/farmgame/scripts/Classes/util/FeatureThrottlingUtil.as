package Classes.util
{
   public class FeatureThrottlingUtil
   {
      
      public static const DEFAULT_COOLDOWN_DAYS_FIRST:int = 2;
      
      public static const DEFAULT_COOLDOWN_DAYS_SECOND:int = 7;
      
      public static const DEFAULT_COOLDOWN_KILL:int = -1;
      
      private var m_cooldownDaysFirst:int;
      
      private var m_cooldownDaysSecond:int;
      
      private var m_cooldownKill:int;
      
      public function FeatureThrottlingUtil(cooldownDaysFirst:int = 2, cooldownDaysSecond:int = 7, cooldownKill:int = -1)
      {
         super();
         this.m_cooldownDaysFirst = cooldownDaysFirst;
         this.m_cooldownDaysSecond = cooldownDaysSecond;
         this.m_cooldownKill = cooldownKill;
      }
      
      private function shouldThrottleSurfacing(throttlingFlag:String) : Boolean
      {
         var shouldThrottle:Boolean = false;
         var closeCount:int = Global.player.getActionCount(throttlingFlag);
         var cooldownTime:Number = this.getCooldownTimeFromCloseCount(closeCount);
         var lastShown:Number = Global.player.getFeatureLastShown(throttlingFlag);
         if(lastShown != 0 && (cooldownTime == DEFAULT_COOLDOWN_KILL || GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShown < cooldownTime))
         {
            shouldThrottle = true;
         }
         return shouldThrottle;
      }
      
      private function getCooldownTimeFromCloseCount(closeCount:int) : Number
      {
         var cooldown:Number = 0;
         switch(closeCount)
         {
            case 0:
               break;
            case 1:
               cooldown = this.m_cooldownDaysFirst * FarmGameUtil.NUM_SECS_IN_DAY;
               break;
            case 2:
               cooldown = this.m_cooldownDaysSecond * FarmGameUtil.NUM_SECS_IN_DAY;
               break;
            case 3:
            default:
               cooldown = this.m_cooldownKill;
         }
         return cooldown;
      }
      
      public function isKeywordThrottled(keyword:String) : Boolean
      {
         return Global.player.getSeenSessionFlag(keyword) || this.shouldThrottleSurfacing(keyword);
      }
      
      public function throttleKeyword(keyword:String) : void
      {
         Global.player.setFeatureLastShown(keyword,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         Global.player.setSeenSessionFlag(keyword);
      }
      
      public function registerUserCancelAction(keyword:String) : void
      {
         if(keyword != null)
         {
            Global.player.incrementActionCount(keyword,true);
         }
      }
   }
}

