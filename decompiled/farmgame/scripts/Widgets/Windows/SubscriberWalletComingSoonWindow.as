package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class SubscriberWalletComingSoonWindow extends FarmWindow
   {
      
      private var m_faqUrl:String;
      
      public function SubscriberWalletComingSoonWindow(faqUrl:String)
      {
         this.m_faqUrl = faqUrl;
         super("assets/dialogs/VIPWallet2017/FV_VIPWallet2017_OffBoard.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         (m_window.mainWindow as MovieClip).visible = true;
         if(m_window.mainWindow.hasOwnProperty("accept_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Learn More",this.onAccept),true);
         }
         if(m_window.mainWindow.hasOwnProperty("close_bt"))
         {
            m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
         }
      }
      
      private function onAccept(e:Event) : void
      {
         if(this.m_faqUrl != "")
         {
            navigateToURL(new URLRequest(this.m_faqUrl),"_blank");
         }
         close();
      }
   }
}

