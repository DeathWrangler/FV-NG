package Widgets.Windows
{
   import Managers.AmsterdamInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class AmsterdamInnovationLeagueInfoWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_talkMc:MovieClip;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_idleAniMc:MovieClip;
      
      private var m_informAniMc:MovieClip;
      
      private var m_jumpAniMc:MovieClip;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_titleTf:ZwTextField;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_weekMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_subtile1Tf:ZwTextField;
      
      private var m_contentMC:MovieClip;
      
      public function AmsterdamInnovationLeagueInfoWindow(assetPath:String = "", featureName:String = null)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"],"League of Elves!"));
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(this.m_subtile1Tf = new ZwTextField(m_window["subtitle_tf"],"Higher League = Higher Rewards!"));
         }
         if(m_window.hasOwnProperty("content_mc"))
         {
            this.m_contentMC = m_window["content_mc"] as MovieClip;
            this.m_contentMC.gotoAndStop(this.manager.getCurrentLeague() + 1);
            this.m_contentMC.visible = true;
         }
         if(m_window.hasOwnProperty("subtitle2_tf"))
         {
         }
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
      }
      
      override public function close() : void
      {
         if(this.manager.m_leaderboardWindow)
         {
            this.manager.m_leaderboardWindow.untintWindow();
            this.manager.m_leaderboardWindow.enableInput = true;
         }
         super.close();
      }
      
      private function get manager() : AmsterdamInnovationManager
      {
         return AmsterdamInnovationManager.getInstance(this.m_featureName);
      }
   }
}

