package Widgets.Core.Managers
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwObject;
   import Widgets.Core.Util.ZwWidgetUtils;
   
   public class ZwWidgetManager extends ZwObject
   {
      
      protected var m_widgetContainer:Object = new Object();
      
      public function ZwWidgetManager()
      {
         super();
      }
      
      override public function release() : void
      {
         var widget:ZwBaseWidget = null;
         for each(widget in this.m_widgetContainer)
         {
            if(widget)
            {
               widget.release();
            }
         }
         this.m_widgetContainer = null;
         super.release();
      }
      
      final public function addWidget(widget:ZwBaseWidget, visible:Boolean = true) : ZwBaseWidget
      {
         if(null == this.m_widgetContainer[widget.name])
         {
            widget.visible = visible;
            this.m_widgetContainer[widget.name] = widget;
            return widget;
         }
         throw new Error("Error: ZwWidgetManager:addWidget: " + widget.name + " is already being used.");
      }
      
      final public function removeWidget(widget:Object) : void
      {
         var widgetName:String = null;
         var widgetToRemove:ZwBaseWidget = this.getWidget(widget);
         if(widgetToRemove)
         {
            widgetName = ZwWidgetUtils.getWidgetName(widget);
            this.m_widgetContainer[widgetName] = null;
            widgetToRemove.visible = false;
            widgetToRemove.release();
            widgetToRemove = null;
         }
         delete this.m_widgetContainer[widgetName];
      }
      
      final public function getWidget(widget:Object) : ZwBaseWidget
      {
         var widgetName:String = ZwWidgetUtils.getWidgetName(widget);
         return this.m_widgetContainer[widgetName] as ZwBaseWidget;
      }
      
      final public function hideAllWidgets() : void
      {
         var widget:ZwBaseWidget = null;
         for each(widget in this.m_widgetContainer)
         {
            widget.visible = false;
         }
      }
      
      final public function removeAllWidgets() : void
      {
         var widget:ZwBaseWidget = null;
         for each(widget in this.m_widgetContainer)
         {
            if(widget != null)
            {
               this.removeWidget(widget);
            }
         }
      }
   }
}

