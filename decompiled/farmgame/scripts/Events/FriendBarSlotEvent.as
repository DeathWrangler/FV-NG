package Events
{
   import Display.FriendBar.FriendBarSlot;
   import flash.events.Event;
   
   public class FriendBarSlotEvent extends Event
   {
      
      public static const FRIEND_BAR_SLOT_CLICK:String = "friendBarSlotClick";
      
      public var slot:FriendBarSlot;
      
      public var m_counter:String = "";
      
      public var m_kingdom:String = "";
      
      public var m_zClass:String = "";
      
      public function FriendBarSlotEvent(type:String, slot:FriendBarSlot, counter:String, kingdom:String, zClass:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.slot = slot;
         this.m_counter = counter;
         this.m_kingdom = kingdom;
         this.m_zClass = zClass;
         super(type,bubbles,cancelable);
      }
   }
}

