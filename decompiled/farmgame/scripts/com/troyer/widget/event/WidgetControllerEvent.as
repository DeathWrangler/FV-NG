package com.troyer.widget.event
{
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.DynamicDialog;
   import flash.events.Event;
   
   public class WidgetControllerEvent extends Event
   {
      
      public static const DIALOG_CREATE:String = "dialogCreate";
      
      public static const DIALOG_DESTROY:String = "dialogDestroy";
      
      public static const BUTTON_PRESSED:String = "buttonPressed";
      
      public static const MOUSE_OVER:String = "mouseOver";
      
      public static const MOUSE_OUT:String = "mouseOut";
      
      public static const BEGIN_DRAG_DIALOG:String = "beginDragDialog";
      
      public static const END_DRAG_DIALOG:String = "endDragDialog";
      
      public static const CLOSE:String = "close";
      
      public static const VIEW_PINNED:String = "viewPinned";
      
      public static const LOAD_CONTENT:String = "content_loaded";
      
      public static const LOAD_COMPLETE:String = "loadComplete";
      
      public static const ADD_CHILD_VIEW:String = "add_child_view";
      
      public static const REMOVE_CHILD_VIEW:String = "remove_child_view";
      
      public static const MOVE_CHILD_VIEW:String = "move_child_view";
      
      public static const UPDATED:String = "updated";
      
      private var m_controller:BaseWidgetController;
      
      public function WidgetControllerEvent(param1:String, param2:BaseWidgetController, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.m_controller = param2;
      }
      
      public function getController() : BaseWidgetController
      {
         return this.m_controller;
      }
      
      public function getDialog() : DynamicDialog
      {
         if(this.m_controller)
         {
            return this.m_controller.getDialog();
         }
         return null;
      }
   }
}

