package Widgets.Windows
{
   import Engine.Managers.StatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CarribeanInnovationAchievementFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public class CarribeanInnovationAchievementWindow extends FarmWindow
   {
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const NAME_TF:String = "name_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const INVENTORY_MC:String = "inventory_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_inventory_mc:MovieClip;
      
      private var m_slots:CarribeanInnovationAchievementFrame;
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private var m_textPrefix:String = this.m_subFeatureName ? this.m_featureName + "_" + this.m_subFeatureName : this.m_featureName;
      
      private var m_npc:MovieClip;
      
      private var m_talkmc:MovieClip;
      
      private const NPC_MC:String = "npc_mc";
      
      private const TALK_MC:String = "talk_mc";
      
      private const NPC_HEAD:String = "npc1_tf";
      
      private const NPC_SUBTEXT:String = "npc2_tf";
      
      private var m_npcHeadingText:ZwTextField = null;
      
      private var m_npcSubText:ZwTextField = null;
      
      private const DEFAULT_SUBTEXT:String = "Default Subtext";
      
      private const DEFAULT_FIRSTSUBTEXT:String = "Default First Subtext";
      
      private const DEFAULT_HEADTEXT:String = "Default Header Text";
      
      private const ACHIEVEMENT_WELCOME_SEEN_FLAG:String = "CarribeanAchievement_Welcome_flag";
      
      public function CarribeanInnovationAchievementWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Awards";
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Reach Fame targets in time and bag exclusive rewards!";
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npc = m_window[this.NPC_MC] as MovieClip;
            this.m_npc.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.ACHIEVEMENT_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Awards bring Fame!","Win awards for hitting Fame targets in a week and get bonus fame and cool rewards.");
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_slots = new CarribeanInnovationAchievementFrame(m_window[this.SLOTS_MC],this.m_featureName,this);
            this.m_slots.visible = true;
            addWidget(this.m_slots,true);
         }
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
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
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.ACHIEVEMENT_WELCOME_SEEN_FLAG);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         StatsManager.count(this.m_featureName,"AchievementsUI","close");
         close();
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_slots)
         {
            this.hideNPCCallout();
            this.m_slots.refresh();
         }
      }
   }
}

