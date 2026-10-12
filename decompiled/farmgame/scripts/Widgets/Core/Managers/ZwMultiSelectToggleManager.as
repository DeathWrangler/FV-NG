package Widgets.Core.Managers
{
   import Widgets.Core.Base.ZwEventObject;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Events.ZwToggleEvent;
   import Widgets.Core.Toggles.ZwToggle;
   
   public class ZwMultiSelectToggleManager extends ZwEventObject
   {
      
      protected var m_toggles:Array = new Array();
      
      protected var m_selectedToggles:Array = new Array();
      
      protected var m_deselectedToggles:Array = new Array();
      
      public function ZwMultiSelectToggleManager()
      {
         super();
      }
      
      override public function release() : void
      {
         var toggle:ZwToggle = null;
         for each(toggle in this.m_toggles)
         {
            if(null != toggle)
            {
               toggle.stopListenForToggle(this.onToggle);
               toggle.release();
               toggle = null;
            }
         }
         this.m_toggles = null;
         this.m_selectedToggles = null;
         super.release();
      }
      
      public function addToggle(toggle:ZwToggle, isSelected:Boolean = false) : uint
      {
         var result:uint = 0;
         toggle.setToggleMode(ZwToggleMode.MULTI_SELECT);
         toggle.startListenForToggle(this.onToggle);
         result = this.m_toggles.push(toggle);
         if(isSelected)
         {
            toggle.select();
            this.m_selectedToggles.push(toggle);
         }
         return result - 1;
      }
      
      public function removeToggle(toggle:Object) : void
      {
         if(toggle.selected)
         {
            this.m_selectedToggles.splice(this.m_selectedToggles.indexOf(toggle),1);
         }
         this.m_toggles[this.m_toggles.indexOf(toggle)] = null;
         toggle.stopListenForToggle(this.onToggle);
      }
      
      public function setToggle(handle:uint) : void
      {
         if(handle < this.m_toggles.length && null != this.m_toggles[handle])
         {
            this.performToggle(this.m_toggles[handle]);
         }
      }
      
      public function setToggleEnabled(handle:uint, isEnabled:Boolean) : void
      {
         var toggle:ZwToggle = null;
         if(handle < this.m_toggles.length && null != this.m_toggles[handle])
         {
            toggle = this.m_toggles[handle] as ZwToggle;
            if(isEnabled)
            {
               toggle.enable();
            }
            else
            {
               toggle.disable();
            }
         }
      }
      
      public function getSelectedToggles() : Array
      {
         return this.m_selectedToggles;
      }
      
      protected function onToggle(event:ZwToggleEvent) : void
      {
         this.performToggle(event.toggle);
      }
      
      public function performToggle(toggle:ZwToggle) : void
      {
         if(toggle.selected)
         {
            toggle.deselect();
            this.m_selectedToggles.splice(this.m_selectedToggles.indexOf(toggle),1);
         }
         else
         {
            toggle.select();
            this.m_selectedToggles.push(toggle);
         }
      }
      
      public function deselectAll() : void
      {
         var toggle:ZwToggle = null;
         for each(toggle in this.m_toggles)
         {
            if(toggle.selected)
            {
               toggle.deselect();
               this.m_selectedToggles.splice(this.m_selectedToggles.indexOf(toggle),1);
               this.m_deselectedToggles.push(toggle);
            }
         }
      }
      
      public function restoreAllDeselected() : void
      {
         var toggle:ZwToggle = null;
         while(this.m_deselectedToggles.length > 0)
         {
            toggle = this.m_deselectedToggles.pop();
            toggle.select();
            this.m_selectedToggles.push(toggle);
         }
      }
   }
}

