package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Managers.GuildEventManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventElderWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "info1_tf";
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_backgroundMc:MovieClip;
      
      private var m_userData:Object;
      
      private var m_featureName:String;
      
      public function GuildEventElderWindow(featureName:String, assetPath:String, userData:Object)
      {
         this.m_featureName = featureName;
         this.m_userData = userData;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            m_window[TITLE_TF].visible = true;
            m_window[TITLE_TF].text = "General In-charge";
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            m_window[BODY_TF].visible = true;
            m_window[BODY_TF].text = "Your effort in the event was tremendous!";
         }
         if(m_window.hasOwnProperty("subtext1_tf"))
         {
            m_window["subtext1_tf"].visible = true;
            m_window["subtext1_tf"].text = "Your effort in the event was tremendous!";
         }
         if(m_window.hasOwnProperty("subtext2_tf"))
         {
            m_window["subtext2_tf"].visible = true;
            m_window["subtext2_tf"].text = "Keep contributing to hold on to your title!";
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            iconUrl = "assets/newsfeed/topperformertag_200.png";
            addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_gift_mc = m_window.giftbox_mc;
            this.m_gift_mc.visible = false;
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Okay",this.buttonCallback));
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            this.m_backgroundMc = m_window["background_mc"] as MovieClip;
            this.m_backgroundMc.visible = true;
         }
      }
      
      public function buttonCallback(e:Event) : void
      {
         this.close();
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
   }
}

