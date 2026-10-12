package Widgets.Core.Managers
{
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Events.ZwToggleEvent;
   import Widgets.Core.Toggles.ZwToggle;
   
   public class ZwToggleManager extends ZwMultiSelectToggleManager
   {
      
      private var m_allowDeselectOnClick:Boolean;
      
      public function ZwToggleManager()
      {
         super();
         this.m_allowDeselectOnClick = false;
      }
      
      public function get allowDeselectOnClick() : Boolean
      {
         return this.m_allowDeselectOnClick;
      }
      
      public function set allowDeselectOnClick(value:Boolean) : void
      {
         this.m_allowDeselectOnClick = value;
      }
      
      override public function addToggle(toggle:ZwToggle, isSelected:Boolean = false) : uint
      {
         toggle.setToggleMode(ZwToggleMode.SINGLE_SELECT);
         if(isSelected)
         {
            this.deselectToggles();
            toggle.select();
            m_selectedToggles.push(toggle);
         }
         else
         {
            toggle.deselect();
         }
         toggle.startListenForToggle(onToggle);
         var result:uint = m_toggles.push(toggle);
         return result - 1;
      }
      
      public function get selectedToggle() : ZwToggle
      {
         var result:ZwToggle = null;
         if(m_selectedToggles.length > 0)
         {
            result = m_selectedToggles[0];
         }
         return result;
      }
      
      override public function performToggle(toggle:ZwToggle) : void
      {
         var toggleIdx:int = m_selectedToggles.indexOf(toggle);
         if(toggleIdx < 0)
         {
            this.deselectToggles();
            m_selectedToggles.push(toggle);
            toggle.select();
         }
         else if(this.m_allowDeselectOnClick)
         {
            m_selectedToggles.splice(toggleIdx,1);
            toggle.deselect();
         }
         dispatchEvent(new ZwToggleEvent(toggle,ZwToggleEvent.TOGGLE));
      }
      
      public function deselectToggles() : void
      {
         var toggle:ZwToggle = null;
         var index:uint = 0;
         var len:uint = m_selectedToggles.length;
         while(index < len)
         {
            toggle = m_selectedToggles[index] as ZwToggle;
            if(toggle.enabled)
            {
               toggle.deselect();
            }
            index++;
         }
         m_selectedToggles = new Array();
         dispatchEvent(new ZwToggleEvent(toggle,ZwToggleEvent.TOGGLE));
      }
   }
}

