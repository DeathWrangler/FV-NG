package Classes.Constants
{
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.FCSlotMachineWindow;
   import flash.events.Event;
   
   public class FCSlotMachineRewards
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_allRewards:Array = null;
      
      private static var m_mysteryGameRewards:Array = null;
      
      public function FCSlotMachineRewards()
      {
         super();
      }
      
      public static function initializeRewards(allRewards:Array, mysteryGameRewards:Array) : void
      {
         m_allRewards = allRewards;
         m_mysteryGameRewards = mysteryGameRewards;
         m_initialized = true;
         GlobalEventManager.getInstance().dispatchEvent(new Event(FCSlotMachineWindow.REWARDS_LOADED));
      }
      
      public static function isInitialized() : Boolean
      {
         return m_initialized;
      }
      
      public static function getAllRewards() : Array
      {
         return m_allRewards;
      }
      
      public static function getMysteryGameRewards() : Array
      {
         return m_mysteryGameRewards;
      }
   }
}

