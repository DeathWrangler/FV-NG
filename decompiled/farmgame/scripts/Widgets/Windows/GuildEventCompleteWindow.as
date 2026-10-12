package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Managers.GuildEventManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventCompleteWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "info1_tf";
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_backgroundMc:MovieClip;
      
      private var m_userData:Object;
      
      private var m_featureName:String;
      
      private var m_iconMc:FarmIcon;
      
      private var m_playerOBPoints:int;
      
      public function GuildEventCompleteWindow(featureName:String, assetPath:String, userData:Object, playerOBPoints:int)
      {
         this.m_featureName = featureName;
         this.m_userData = userData;
         this.m_playerOBPoints = playerOBPoints;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         var curTier:int = this.eventManager.getCurrentTier();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            m_window[TITLE_TF].visible = true;
            m_window[TITLE_TF].text = "Stats up!";
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            m_window[BODY_TF].visible = true;
            m_window[BODY_TF].text = "Your event points have boosted your stat points!";
         }
         if(m_window.hasOwnProperty("subtext1_tf"))
         {
            m_window["subtext1_tf"].visible = true;
            m_window["subtext1_tf"].text = "Your event score has given you " + this.m_playerOBPoints.toString() + " stat points!";
         }
         if(m_window.hasOwnProperty("subtext2_tf"))
         {
            m_window["subtext2_tf"].visible = true;
            m_window["subtext2_tf"].text = "Keep helping and completing tasks to upgrade your stats!";
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_window["icon_mc"],"assets/newsfeed/statpoints_200.png"));
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
         if(m_window.hasOwnProperty("background_mc"))
         {
            this.m_backgroundMc = m_window["background_mc"] as MovieClip;
            this.m_backgroundMc.visible = true;
            if(curTier <= 2)
            {
               this.m_backgroundMc.gotoAndStop(curTier);
            }
            else
            {
               this.m_backgroundMc.gotoAndStop(3);
            }
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

