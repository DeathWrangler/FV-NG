package Widgets.Core.Events
{
   import Widgets.Core.Toggles.ZwToggle;
   import flash.events.Event;
   
   public class ZwToggleEvent extends Event
   {
      
      public static const TOGGLE:String = "ToggleEvent_Toggle";
      
      private var m_toggle:ZwToggle;
      
      public function ZwToggleEvent(toggle:ZwToggle, type:String)
      {
         this.m_toggle = toggle;
         super(type);
      }
      
      public function get toggle() : ZwToggle
      {
         return this.m_toggle;
      }
   }
}

