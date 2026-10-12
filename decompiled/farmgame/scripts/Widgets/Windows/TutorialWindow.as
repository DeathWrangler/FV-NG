package Widgets.Windows
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class TutorialWindow extends TutorialAnimatedWindow
   {
      
      private var m_message:String = "";
      
      private var m_offset:Point = null;
      
      private var m_closeCallback:Function = null;
      
      public function TutorialWindow(message:String, offset:Point = null, closeCallback:Function = null, dialogUrl:String = "assets/dialogs/FV_Craft_tutorial.swf")
      {
         super(dialogUrl);
         this.m_message = message;
         this.m_offset = offset;
         this.m_closeCallback = closeCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            addWidget(new ZwWidget(m_window.tutorial_mc));
            if(m_window.tutorial_mc.hasOwnProperty("task_tf"))
            {
               addWidget(new ZwTextField(m_window.tutorial_mc.task_tf,this.m_message));
            }
         }
         if(m_window.hasOwnProperty("messageSmall_mc"))
         {
            addWidget(new ZwWidget(m_window.messageSmall_mc));
            if(m_window.messageSmall_mc.hasOwnProperty("generic_tf"))
            {
               addWidget(new ZwTextField(m_window.messageSmall_mc.generic_tf,this.m_message));
            }
         }
      }
      
      override public function getDialogOffset() : Point
      {
         return this.m_offset;
      }
      
      override protected function onClose(event:Event) : void
      {
         if(event.type == MouseEvent.CLICK && this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         close();
      }
   }
}

