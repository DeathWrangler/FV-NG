package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.events.Event;
   import flash.system.System;
   
   public class ErrorWindow extends FarmWindow
   {
      
      protected var m_errorData:String;
      
      public function ErrorWindow(errorData:String)
      {
         super("assets/dialogs/FV_ErrorWindow.swf");
         this.m_errorData = errorData;
      }
      
      override protected function postLoadComplete() : void
      {
         m_window.tf_textfield.appendText(this.m_errorData);
         m_window.txt_header.text = "Server Error";
         m_window.txt_body.text = "A server error has occurred.";
         addWidget(new FarmAnimatedButton(m_window.bt_sendgifts,this.onClose));
      }
      
      override protected function onClose(evt:Event) : void
      {
         System.setClipboard(this.m_errorData);
         super.onClose(evt);
      }
   }
}

