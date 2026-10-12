package Widgets.Windows
{
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildEventOrderSelectionFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventOrderSelectionWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var TASKS_MC:String = "tasks_mc";
      
      private var m_taskFrame:GuildEventOrderSelectionFrame;
      
      public var m_reqSlotNumber:int;
      
      private var m_backgroundMc:MovieClip;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_okay1Bt:FarmAnimatedTextButton;
      
      private var m_okay2Bt:FarmAnimatedTextButton;
      
      private var m_npcMc:MovieClip;
      
      private var m_npcTalkMc:MovieClip;
      
      private var m_npcTf1:ZwTextField;
      
      private var m_npcTf2:ZwTextField;
      
      public function GuildEventOrderSelectionWindow(featureName:String = null, assetPath:String = "", reqSlotNumber:int = 0)
      {
         this.m_featureName = featureName;
         this.m_reqSlotNumber = reqSlotNumber;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var curTier:int = 0;
         super.postLoadComplete();
         curTier = this.eventManager.getCurrentTier();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Pick a Task"));
            m_window["title_tf"].visible = true;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],""));
            if(this.eventManager.allSlotsFull())
            {
               m_window["body_tf"].text = "Complete your pending tasks before taking up additional tasks";
            }
            else
            {
               m_window["body_tf"].text = "Select a task and complete it to contribute to your clan’s victory!";
            }
            m_window["body_tf"].visible = true;
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            this.m_backgroundMc = m_window["background_mc"] as MovieClip;
            this.m_backgroundMc.visible = true;
            if(curTier <= 2)
            {
               this.m_backgroundMc.gotoAndStop(curTier + 1);
            }
            else
            {
               this.m_backgroundMc.gotoAndStop(3);
            }
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            if(this.m_tutorialMc.hasOwnProperty("okay1_bt"))
            {
               this.m_okay1Bt = new FarmAnimatedTextButton(this.m_tutorialMc["okay1_bt"],"Okay",this.onOkayButtonClick);
               this.m_okay1Bt.visible = false;
            }
            if(this.m_tutorialMc.hasOwnProperty("okay2_bt"))
            {
               this.m_okay2Bt = new FarmAnimatedTextButton(this.m_tutorialMc["okay2_bt"],"Okay",this.onOkayButtonClick);
               this.m_okay2Bt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = false;
            this.m_npcMc.play();
            if(this.m_npcMc.hasOwnProperty("talk_mc"))
            {
               this.m_npcTalkMc = this.m_npcMc.talk_mc as MovieClip;
               this.m_npcTalkMc.visible = true;
               this.m_npcTf1 = new ZwTextField(this.m_npcTalkMc["npc1_tf"],"Orders In");
               this.m_npcTf2 = new ZwTextField(this.m_npcTalkMc["npc2_tf"],"These are tasks you and your clan can see. Click on select to choose a task for a slot.");
            }
         }
         if(m_window.hasOwnProperty(this.TASKS_MC))
         {
            this.m_taskFrame = new GuildEventOrderSelectionFrame(m_window[this.TASKS_MC],this,this.m_featureName,this.m_reqSlotNumber);
            this.m_taskFrame.visible = true;
         }
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance();
      }
      
      public function refreshOrderboardFrame() : void
      {
         if(this.m_taskFrame)
         {
            this.m_taskFrame.refresh();
         }
         if(GuildEventMainWindow.m_FTUEState == 2)
         {
            if(this.m_tutorialMc)
            {
               this.m_tutorialMc.visible = true;
               this.m_npcMc.visible = true;
               this.m_npcTalkMc.visible = true;
               this.m_npcTf1.visible = true;
               this.m_npcTf2.visible = true;
            }
         }
      }
      
      public function onOkayButtonClick(e:Event) : void
      {
      }
      
      override public function close() : void
      {
         if(this.eventManager.m_guildEventMainWindow)
         {
            this.eventManager.m_guildEventMainWindow.untintWindow();
            this.eventManager.m_guildEventMainWindow.enableInput = true;
            this.eventManager.m_guildEventMainWindow.m_tutorial1Mc.visible = false;
            this.eventManager.m_guildEventMainWindow.refreshTaskFrame();
         }
         GuildEventManager.getInstance().m_orderSelectionWindow = null;
         super.close();
      }
   }
}

