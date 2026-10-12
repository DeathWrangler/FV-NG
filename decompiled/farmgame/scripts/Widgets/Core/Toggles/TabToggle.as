package Widgets.Core.Toggles
{
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Interfaces.IZwToggle;
   
   public class TabToggle extends ZwToggle
   {
      
      public function TabToggle(toggleObject:IZwToggle)
      {
         super(toggleObject);
      }
      
      override public function select() : void
      {
         m_isSelected = true;
         m_toggleObject.setToggleState(ZwToggleState.DISABLED);
         onSelect();
      }
   }
}

