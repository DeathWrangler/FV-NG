package com.troyer.widget.event
{
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.Event;
   
   public class WidgetViewEvent extends Event
   {
      
      public static const CHILD_RESIZE:String = "childResize";
      
      private var m_view:BaseWidgetView;
      
      public function WidgetViewEvent(param1:String, param2:BaseWidgetView, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.m_view = param2;
      }
      
      public function getView() : BaseWidgetView
      {
         return this.m_view;
      }
      
      public function getDialog() : DynamicDialog
      {
         if(this.m_view)
         {
            return this.m_view.getDialog();
         }
         return null;
      }
   }
}

