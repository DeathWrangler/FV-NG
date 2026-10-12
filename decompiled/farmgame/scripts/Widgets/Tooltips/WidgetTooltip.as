package Widgets.Tooltips
{
   import Engine.Utilities;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class WidgetTooltip extends ZwAbstractTooltip
   {
      
      protected var m_fixed:Boolean = false;
      
      protected var m_interactive:Boolean = false;
      
      protected var m_widget:ZwWidget = null;
      
      protected var m_toggleCallback:Function = null;
      
      public function WidgetTooltip(widget:ZwWidget = null, toggleCallback:Function = null)
      {
         super();
         this.setWidget(widget);
         this.m_toggleCallback = toggleCallback;
      }
      
      override public function release() : void
      {
         if(this.m_widget)
         {
            this.m_widget.release();
            this.m_widget = null;
         }
         super.release();
      }
      
      override protected function updatePosition(event:MouseEvent) : void
      {
         var pos:Point = null;
         if(Boolean(event != null) && Boolean(this.m_widget) && !this.m_fixed)
         {
            pos = new Point(event.localX + 10 + event.target.x,event.localY + 10 + event.target.y);
            if(Global.stage.stageWidth - this.m_widget.width < event.stageX)
            {
               pos.x = event.localX - this.m_widget.width - 10 + event.target.x;
            }
            if(Global.stage.stageHeight - this.m_widget.height < event.stageY)
            {
               pos.y = event.localY - (event.stageY - Global.stage.stageHeight + this.m_widget.height) + event.target.y;
            }
            this.m_widget.x = pos.x;
            this.m_widget.y = pos.y;
         }
      }
      
      override protected function show(event:MouseEvent) : void
      {
         if(this.m_widget)
         {
            this.m_widget.visible = true;
            if(Boolean(this.m_widget.element) && !this.m_interactive)
            {
               if(this.m_widget.element is DisplayObjectContainer)
               {
                  Utilities.toggleInputAndChildren(this.m_widget.element as DisplayObjectContainer,false);
               }
               else if(this.m_widget.element is InteractiveObject)
               {
                  Utilities.toggleInputOnlySelf(this.m_widget.element as InteractiveObject,false);
               }
            }
            this.updatePosition(event);
         }
         if(this.m_toggleCallback != null)
         {
            this.m_toggleCallback();
         }
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         if(this.m_widget)
         {
            this.m_widget.visible = false;
         }
         if(this.m_toggleCallback != null)
         {
            this.m_toggleCallback();
         }
      }
      
      public function get fixed() : Boolean
      {
         return this.m_fixed;
      }
      
      public function set fixed(value:Boolean) : void
      {
         this.m_fixed = value;
      }
      
      public function get interactive() : Boolean
      {
         return this.m_interactive;
      }
      
      public function set interactive(value:Boolean) : void
      {
         this.m_interactive = value;
      }
      
      public function getWidget() : ZwWidget
      {
         return this.m_widget;
      }
      
      public function setWidget(widget:ZwWidget) : void
      {
         if(widget)
         {
            if(this.m_widget)
            {
               this.m_widget.release();
               this.m_widget = null;
            }
            this.m_widget = widget;
            this.m_widget.visible = false;
         }
      }
      
      public function onToggleVisible(toggle:Boolean) : void
      {
         if(toggle)
         {
            this.show(null);
         }
         else
         {
            this.hide(null);
         }
      }
   }
}

