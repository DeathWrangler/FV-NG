package Widgets.Windows
{
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BookmarkOpt2019InstallWindow extends FarmWindow
   {
      
      public static const BOOKMARKOPT_POPUP_SHOWN_FLAG:String = "BookmarkOpt2019_PopupShown";
      
      public var m_URL:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_subtext_Tf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_closeBt:FarmButton;
      
      public function BookmarkOpt2019InstallWindow(assetPath:String = "", url:String = null)
      {
         super(assetPath);
         this.m_URL = url;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"],"Shortcut to Rewards!"));
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(this.m_subtext_Tf = new ZwTextField(m_window["subtext_tf"],"Earn bonus Farmcash and Consumables when you create the shortcut on your FB page!"));
            this.m_subtext_Tf.visible = true;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window["body_tf"],"Follow the steps below to create shortcut to play Farmville!"));
            this.m_bodyTf.visible = true;
         }
         if(m_window.hasOwnProperty("tut_video_mc"))
         {
            this.m_tutorial_mc = m_window["tut_video_mc"] as MovieClip;
            this.m_tutorial_mc.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_closeBt = new FarmButton(m_window["close_bt"],this.onCloseWindow);
            this.m_closeBt.visible = true;
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Let\'s Go!",this.onCloseBrowserInstallWindow));
            this.m_accept_bt.enabled = true;
         }
         StatsManager.count("MOTD","impressions","BookmarkOptMOTDWindow");
      }
      
      private function onCloseBrowserInstallWindow(evt:MouseEvent) : void
      {
         navigateToURL(new URLRequest("https://www.facebook.com"),"_blank");
         Global.player.setSeenFlag(BOOKMARKOPT_POPUP_SHOWN_FLAG);
         StatsManager.count("MOTD","Go","BookmarkOpt2019");
         super.onClose(evt);
      }
      
      private function onCloseWindow(evt:MouseEvent) : void
      {
         super.onClose(evt);
      }
   }
}

