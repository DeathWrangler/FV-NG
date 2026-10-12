package Widgets.Windows
{
   import Managers.SouthindiaInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class SouthindiaInnovationLeaderboardRewardWindow extends FarmWindow
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
      
      private var m_body2Tf:ZwTextField;
      
      public function SouthindiaInnovationLeaderboardRewardWindow(assetPath:String = "", featureName:String = null)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var cureWeekObject:Object = this.manager.getCurrentWeek();
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window["body_tf"],this.getSubtileText()));
            this.m_bodyTf.visible = true;
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(this.m_body2Tf = new ZwTextField(m_window["body2_tf"],"Score at least 150 points this week to stay in the Silver League!"));
            this.m_body2Tf.visible = this.manager.getCurrentLeague() == 1;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"],"Week " + cureWeekObject.count + " League Reward"));
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window["talk_mc"] as MovieClip;
            if(this.m_talkMc.hasOwnProperty("npc1_tf"))
            {
               addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1_tf"));
               this.m_npc1Tf.visible = false;
            }
            if(this.m_talkMc.hasOwnProperty("npc2_tf"))
            {
               addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"npc2_tf"));
               this.m_npc2Tf.visible = false;
            }
            this.m_talkMc.visible = true;
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window["talk_auto_mc"] as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleAniMc = m_window["idle_ani_mc"] as MovieClip;
            this.m_idleAniMc.visible = true;
         }
         if(m_window.hasOwnProperty("inform_ani_mc"))
         {
            this.m_informAniMc = m_window["inform_ani_mc"] as MovieClip;
            this.m_informAniMc.visible = true;
         }
         if(m_window.hasOwnProperty("jump_ani_mc"))
         {
            this.m_jumpAniMc = m_window["jump_ani_mc"] as MovieClip;
            this.m_jumpAniMc.visible = true;
         }
         var weekName:String = "week" + cureWeekObject.count + "_mc";
         var league:int = this.manager.getCurrentLeague() + 1;
         if(m_window.hasOwnProperty(weekName))
         {
            this.m_weekMc = m_window[weekName] as MovieClip;
            this.m_weekMc.gotoAndStop(league);
            this.m_weekMc.visible = true;
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
      
      public function getSubtileText() : String
      {
         var league:int = this.manager.getCurrentLeague();
         var msg:String = "";
         if(league == 0)
         {
            msg = "Score at least 250 points this week to get promoted to the Silver League and win exciting rewards!";
         }
         else if(league == 1)
         {
            msg = "Score at least 350 points this week to get promoted to the Gold League and win the best rewards!";
         }
         else if(league == 2)
         {
            msg = "Score at least of 300 points to stay in Gold league for the best rewards.";
         }
         return msg;
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
      
      private function get manager() : SouthindiaInnovationManager
      {
         return SouthindiaInnovationManager.getInstance(this.m_featureName);
      }
   }
}

