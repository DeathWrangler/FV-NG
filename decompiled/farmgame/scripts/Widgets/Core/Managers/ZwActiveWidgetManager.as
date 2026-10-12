package Widgets.Core.Managers
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwEventObject;
   
   public class ZwActiveWidgetManager extends ZwEventObject
   {
      
      public static const ACTIVE_WIDGET_HANDLE_INVALID:uint = uint.MAX_VALUE;
      
      protected var m_widgets:Array = new Array();
      
      public function ZwActiveWidgetManager()
      {
         super();
      }
      
      override public function release() : void
      {
         var widget:ZwBaseWidget = null;
         for each(widget in this.m_widgets)
         {
            if(null != widget)
            {
               widget.release();
               widget = null;
            }
         }
         this.m_widgets = null;
         super.release();
      }
      
      public function getWidget(handle:uint) : ZwBaseWidget
      {
         var widget:ZwBaseWidget = null;
         if(handle < this.m_widgets.length)
         {
            widget = this.m_widgets[handle] as ZwBaseWidget;
         }
         return widget;
      }
      
      public function addWidget(widget:ZwBaseWidget, isSelected:Boolean = false) : uint
      {
         var result:uint = 0;
         result = this.m_widgets.push(widget);
         if(isSelected)
         {
            widget.visible = true;
         }
         else
         {
            widget.visible = false;
         }
         return result - 1;
      }
      
      public function removeWidget(widget:ZwBaseWidget) : void
      {
         this.m_widgets[this.m_widgets.indexOf(widget)] = null;
      }
      
      public function selectWidget(handle:uint) : void
      {
         if(handle < this.m_widgets.length && null != this.m_widgets[handle])
         {
            this.deselectAllWidgets();
            this.m_widgets[handle].visible = true;
         }
      }
      
      public function deselectAllWidgets() : void
      {
         var widget:ZwBaseWidget = null;
         for each(widget in this.m_widgets)
         {
            if(null != widget)
            {
               widget.visible = false;
            }
         }
      }
   }
}

