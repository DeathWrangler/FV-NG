package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class BrowserAppRewardWindow extends FarmWindow
   {
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function BrowserAppRewardWindow(dialogPath:String)
      {
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Congrats!"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Thank you for trying out the Farmville Browser! Here are your rewards!"));
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(new ZwTextField(m_window["body2_tf"],"Keep playing farmville on this browser for a hassle free experience."));
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"limbo1PaidGiftingRecipient_accept"),this.onAccept));
         }
      }
      
      private function onAccept(evt:MouseEvent) : void
      {
         close();
      }
   }
}

