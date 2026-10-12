package Widgets.Core.Toggles
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Interfaces.IZwToggle;
   
   public class ZwVisibilityToggle extends ZwToggle
   {
      
      protected var m_widget:ZwWidget;
      
      protected var m_onSelectCallback:Function = null;
      
      public function ZwVisibilityToggle(toggleObject:IZwToggle, widget:ZwWidget, onSelectCallback:Function = null)
      {
         super(toggleObject);
         this.m_widget = widget;
         this.m_onSelectCallback = onSelectCallback;
      }
      
      override public function release() : void
      {
         this.m_widget = null;
         super.release();
      }
      
      override protected function onSelect() : void
      {
         this.m_widget.visible = true;
         if(this.m_onSelectCallback != null)
         {
            this.m_onSelectCallback();
         }
      }
      
      override protected function onDeselect() : void
      {
         this.m_widget.visible = false;
      }
   }
}

