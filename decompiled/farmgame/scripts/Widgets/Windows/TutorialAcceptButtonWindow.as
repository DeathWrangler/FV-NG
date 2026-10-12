package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class TutorialAcceptButtonWindow extends TutorialAnimatedWindow
   {
      
      private var m_message:String = "";
      
      private var m_buttonString:String = "";
      
      private var m_offset:Point = null;
      
      private var m_acceptCallback:Function = null;
      
      private var m_closeCallback:Function = null;
      
      public function TutorialAcceptButtonWindow(message:String, buttonString:String, offset:Point, acceptCallback:Function = null, closeCallback:Function = null, asset:String = "assets/dialogs/FV_Craft_tutorial_next.swf")
      {
         super(asset);
         this.m_message = message;
         this.m_buttonString = buttonString;
         this.m_offset = offset;
         this.m_acceptCallback = acceptCallback;
         this.m_closeCallback = closeCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwWidget(m_window.messageLarge_mc));
         addWidget(new ZwTextField(m_window.messageLarge_mc.generic_tf,this.m_message));
         addWidget(new FarmAnimatedTextButton(m_window.messageLarge_mc.use_bt,this.m_buttonString,this.onUse));
      }
      
      private function onUse(event:MouseEvent) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         close();
      }
      
      override public function getDialogOffset() : Point
      {
         return this.m_offset;
      }
   }
}

