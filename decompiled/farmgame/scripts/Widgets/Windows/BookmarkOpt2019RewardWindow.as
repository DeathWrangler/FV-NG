package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class BookmarkOpt2019RewardWindow extends FarmWindow
   {
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function BookmarkOpt2019RewardWindow(dialogPath:String)
      {
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Congratulations!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Enjoy your Farmcash and consumable rewards!"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Playing Farmville is a just a click away now!"));
         }
         if(m_window.hasOwnProperty("body0_tf"))
         {
            addWidget(new ZwTextField(m_window["body0_tf"],"Playing Farmville is a just a click away now!"));
         }
         if(m_window.hasOwnProperty("body1_tf"))
         {
            addWidget(new ZwTextField(m_window["body1_tf"],"Playing Farmville is a just a click away now!"));
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(new ZwTextField(m_window["body2_tf"],"Enjoy your free Farmcash and consumable rewards!"));
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

