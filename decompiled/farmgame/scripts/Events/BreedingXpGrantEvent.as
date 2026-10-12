package Events
{
   import flash.events.Event;
   
   public class BreedingXpGrantEvent extends Event
   {
      
      public static const BREEDING_XP_GRANT:String = "breedingXpGrant";
      
      public var xpGranted:int;
      
      public var rewardsGranted:Object;
      
      public function BreedingXpGrantEvent(type:String, xpAmount:int, rewards:Object, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.xpGranted = xpAmount;
         this.rewardsGranted = rewards;
      }
   }
}

