package Events
{
   import flash.events.Event;
   
   public class FarmGameWorldEvent extends Event
   {
      
      public static const USER_CHANGED:String = "user_changed";
      
      public static const SFX_CHANGED:String = "sfx_changed";
      
      public static const VIEWPORT_CHANGED:String = "viewport_changed";
      
      public static const WORLD_SWAP:String = "world_swap";
      
      public static const WORLD_LOADED:String = "world_loaded";
      
      public static const USER_POST_INIT_COMPLETE:String = "user_post_init_complete";
      
      public static const UNLOCK_TILE:String = "unlock_tile";
      
      public function FarmGameWorldEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

