package Widgets.Core.Frames
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Core.Util.ZwWidgetUtils;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   
   public class ZwFrame extends ZwWidget
   {
      
      protected var m_widgetManager:ZwWidgetManager;
      
      public function ZwFrame(element:DisplayObject)
      {
         var value:DisplayObject = null;
         this.m_widgetManager = new ZwWidgetManager();
         super(element);
         for each(value in m_element)
         {
            if(ZwWidgetUtils.isValidElement(value))
            {
               value.visible = false;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_widgetManager.release();
         this.m_widgetManager = null;
         super.release();
      }
      
      public function addWidget(widget:ZwBaseWidget, visible:Boolean = true) : ZwBaseWidget
      {
         widget.parent = this;
         return this.m_widgetManager.addWidget(widget,visible);
      }
      
      public function removeWidget(widget:Object) : void
      {
         this.m_widgetManager.removeWidget(widget);
      }
      
      public function removeAllWidgets() : void
      {
         this.m_widgetManager.removeAllWidgets();
      }
      
      public function getWidget(widget:Object) : ZwBaseWidget
      {
         return this.m_widgetManager.getWidget(widget);
      }
      
      public function hideAllWidgets() : void
      {
         this.m_widgetManager.hideAllWidgets();
      }
      
      final public function getWidgetFromEvent(event:Event) : ZwBaseWidget
      {
         return this.getWidget(event.currentTarget);
      }
      
      public function set grayOut(onOff:Boolean) : void
      {
         var matrix:Array = null;
         if(onOff)
         {
            matrix = new Array();
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0,0,0,1,0]);
            this.element.filters = [new ColorMatrixFilter(matrix)];
         }
         else
         {
            this.element.filters = [];
         }
      }
   }
}

