package Widgets.Windows.SnowballFight
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SnowballWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_title:String = "";
      
      private var m_iconUrl:String = "";
      
      private var m_message:String = "";
      
      private var m_acceptButtonText:String = "";
      
      private var m_acceptCallback:Function;
      
      private var m_cancelCallback:Function;
      
      public function SnowballWindow(title:String, iconUrl:String, message:String, acceptButtonText:String, acceptCallback:Function = null, cancelCallback:Function = null)
      {
         super("assets/dialogs/FV_Snowball_Dialog.swf");
         this.m_title = title;
         this.m_iconUrl = iconUrl;
         this.m_message = message;
         this.m_acceptButtonText = acceptButtonText;
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         addWidget(new ZwTextField(m_window.generic_tf,this.m_message));
         var icon:FarmIcon = addWidget(new FarmIcon(m_window.icon_mc,this.m_iconUrl)) as FarmIcon;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,this.m_acceptButtonText,this.onAcceptButtonClick));
      }
      
      private function onAcceptButtonClick(evt:MouseEvent) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_acceptCallback = null;
         this.m_cancelCallback = null;
         super.release();
      }
   }
}

