package Widgets.Core.Toggles
{
   import Widgets.Core.Base.ZwEventObject;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Events.ZwToggleEvent;
   import Widgets.Core.Interfaces.IZwToggle;
   import flash.events.Event;
   
   public class ZwToggle extends ZwEventObject
   {
      
      protected var m_toggleObject:IZwToggle = null;
      
      protected var m_isSelected:Boolean = false;
      
      protected var m_isEnabled:Boolean = true;
      
      protected var m_callback:Function = null;
      
      public function ZwToggle(toggleObject:IZwToggle)
      {
         super();
         this.m_toggleObject = toggleObject;
      }
      
      override public function release() : void
      {
         this.m_callback = null;
         this.m_toggleObject.stopListenForToggle(this.onToggle);
         this.m_toggleObject = null;
         super.release();
      }
      
      public function get selected() : Boolean
      {
         return this.m_isSelected;
      }
      
      public function get enabled() : Boolean
      {
         return this.m_isEnabled;
      }
      
      public function startListenForToggle(callback:Function) : void
      {
         if(this.m_callback != null)
         {
            unregisterEventListener(ZwToggleEvent.TOGGLE,this.m_callback);
         }
         registerEventListener(ZwToggleEvent.TOGGLE,callback);
         this.m_callback = callback;
         this.m_toggleObject.startListenForToggle(this.onToggle);
      }
      
      public function stopListenForToggle(callback:Function) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback = null;
         }
         this.m_toggleObject.stopListenForToggle(this.onToggle);
      }
      
      public function select() : void
      {
         this.m_isSelected = true;
         this.m_toggleObject.setToggleState(ZwToggleState.SELECTED);
         this.onSelect();
      }
      
      public function deselect() : void
      {
         this.m_isSelected = false;
         this.m_toggleObject.setToggleState(ZwToggleState.DESELECTED);
         this.onDeselect();
      }
      
      public function enable() : void
      {
         if(!this.m_isEnabled)
         {
            this.m_isEnabled = true;
            this.m_isSelected = false;
            this.m_toggleObject.setToggleState(ZwToggleState.DESELECTED);
            this.m_toggleObject.startListenForToggle(this.onToggle);
         }
      }
      
      public function disable() : void
      {
         if(this.m_isEnabled)
         {
            this.m_isEnabled = false;
            this.m_isSelected = false;
            this.m_toggleObject.setToggleState(ZwToggleState.DISABLED);
            this.m_toggleObject.stopListenForToggle(this.onToggle);
         }
      }
      
      public function setToggleMode(toggleMode:String) : void
      {
         this.m_toggleObject.setToggleMode(toggleMode);
      }
      
      protected function onToggle(event:Event) : void
      {
         dispatchEvent(new ZwToggleEvent(this,ZwToggleEvent.TOGGLE));
      }
      
      protected function onSelect() : void
      {
      }
      
      protected function onDeselect() : void
      {
      }
   }
}

