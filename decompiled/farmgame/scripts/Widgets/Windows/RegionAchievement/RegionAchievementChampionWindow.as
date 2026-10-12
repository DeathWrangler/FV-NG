package Widgets.Windows.RegionAchievement
{
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RegionAchievementChampionWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const TROPHY_TITLE_TF:String = "title1_tf";
      
      private static const REWARD_1_TF:String = "title2_tf";
      
      private static const REWARD_2_TF:String = "title3_tf";
      
      private static const COUNT_TF:String = "count_tf";
      
      private static const SUBTITLE_TF:String = "body_tf";
      
      private static const BODY_TF:String = "body1_tf";
      
      private static const TUTORIAL_BT:String = "tileTutorial_bt";
      
      private static const TROPHY_WON_MC:String = "largeTrophyWon_mc";
      
      private static const FINISHED_DRAGON_MC:String = "finishedDragon_mc";
      
      private static const TILE_MC:String = "tile_mc";
      
      private static const TILE_WIN_MC:String = "tilewin_mc";
      
      private static const FINTILE_MC:String = "fintile_mc";
      
      private static const NPC_MC:String = "npc_mc";
      
      private static const NPC_BUBBLE_MC:String = "npcBubble_mc";
      
      private var m_titleTf:ZwTextField;
      
      private var m_reward_1_titleTf:ZwTextField;
      
      private var m_reward_2_titleTf:ZwTextField;
      
      private var m_reward_3_titleTf:ZwTextField;
      
      private var m_trophyTitleTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_subtitleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_tutorialBt:FarmAnimatedTextButton;
      
      private var m_trophyWonMC:ZwFrame;
      
      private var m_dragonMC:MovieClip;
      
      private var m_tileMC:MovieClip;
      
      private var m_tileWinMC:ZwFrame;
      
      private var m_finTileMC:MovieClip;
      
      private var m_npcMC:MovieClip;
      
      private var m_npcBubbleMC:MovieClip;
      
      private var m_featureName:String;
      
      public function RegionAchievementChampionWindow(assetURL:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(assetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var counterText:String = null;
         var milestone:int = 0;
         super.postLoadComplete();
         var text:String = "";
         var isChampion:Boolean = RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO();
         var WON:String = "";
         if(isChampion)
         {
            WON = "_won";
         }
         m_window.gotoAndStop(2);
         if(m_window.hasOwnProperty(TROPHY_WON_MC))
         {
            this.m_trophyWonMC = addWidget(new ZwFrame(m_window[TROPHY_WON_MC]),true) as ZwFrame;
         }
         if(this.m_trophyWonMC)
         {
            if(this.m_trophyWonMC.element.hasOwnProperty(FINISHED_DRAGON_MC))
            {
               this.m_dragonMC = this.m_trophyWonMC.element[FINISHED_DRAGON_MC] as MovieClip;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(TILE_MC))
            {
               this.m_tileMC = this.m_trophyWonMC.element[TILE_MC] as MovieClip;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(TILE_WIN_MC))
            {
               this.m_tileWinMC = addWidget(new ZwFrame(this.m_trophyWonMC.element[TILE_WIN_MC]),true) as ZwFrame;
            }
            if(Boolean(this.m_tileWinMC) && this.m_tileWinMC.element.hasOwnProperty(FINTILE_MC))
            {
               this.m_finTileMC = this.m_tileWinMC.element[FINTILE_MC] as MovieClip;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(NPC_BUBBLE_MC))
            {
               this.m_npcBubbleMC = this.m_trophyWonMC.element[NPC_BUBBLE_MC] as MovieClip;
               this.m_npcBubbleMC.visible = true;
               if(this.m_npcBubbleMC.hasOwnProperty(NPC_MC))
               {
                  this.m_npcMC = this.m_npcBubbleMC[NPC_MC] as MovieClip;
                  this.m_npcMC.visible = true;
                  this.m_npcMC.gotoAndStop(1);
               }
            }
            if(this.m_dragonMC)
            {
               this.m_dragonMC.visible = true;
               this.m_dragonMC.play();
            }
            if(this.m_tileMC)
            {
               this.m_tileMC.visible = true;
               this.m_tileMC.play();
            }
            if(this.m_tileWinMC)
            {
               this.m_tileWinMC.visible = false;
            }
            if(isChampion)
            {
               if(this.m_tileMC)
               {
                  this.m_tileMC.stop();
                  this.m_tileMC.visible = false;
               }
               if(Boolean(this.m_tileWinMC) && Boolean(this.m_finTileMC))
               {
                  this.m_tileWinMC.visible = true;
                  this.m_finTileMC.visible = true;
                  this.m_finTileMC.play();
               }
               if(this.m_npcMC)
               {
                  this.m_npcMC.visible = true;
                  this.m_npcMC.gotoAndStop(2);
               }
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(TITLE_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_title" + WON);
               this.m_titleTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[TITLE_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(REWARD_1_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_reward_1");
               this.m_reward_1_titleTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[REWARD_1_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(REWARD_2_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_reward_2");
               this.m_reward_2_titleTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[REWARD_2_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(SUBTITLE_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_body" + WON);
               this.m_subtitleTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[SUBTITLE_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(TROPHY_TITLE_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_statue_title");
               this.m_trophyTitleTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[TROPHY_TITLE_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(COUNT_TF))
            {
               counterText = RegionAchievementManager.getInstance(this.m_featureName).completedChampionMilestoneText;
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_trophy_count",{"count":counterText});
               this.m_countTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[COUNT_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(BODY_TF))
            {
               milestone = RegionAchievementManager.getInstance(this.m_featureName).championMilestone;
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_trophy_desc" + WON,{"milestone":milestone});
               this.m_bodyTf = addWidget(new ZwTextField(this.m_trophyWonMC.element[BODY_TF],text)) as ZwTextField;
            }
            if(this.m_trophyWonMC.element.hasOwnProperty(TUTORIAL_BT))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_champion_window_cta" + WON);
               this.m_tutorialBt = addWidget(new FarmAnimatedTextButton(this.m_trophyWonMC.element[TUTORIAL_BT],text,this.onClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_titleTf = null;
         this.m_reward_1_titleTf = null;
         this.m_reward_2_titleTf = null;
         this.m_trophyTitleTf = null;
         this.m_countTf = null;
         this.m_subtitleTf = null;
         this.m_bodyTf = null;
         this.m_tutorialBt = null;
         if(this.m_tileMC)
         {
            this.m_tileMC = null;
         }
         this.m_tileWinMC = null;
         this.m_trophyWonMC = null;
         super.release();
      }
      
      private function onClick(e:Event) : void
      {
         this.onClose(e);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.EXECUTE_NEXT_ACTION));
      }
      
      override protected function onClose(event:Event) : void
      {
         var toggleNPCEvent:RegionAchievementEvent = new RegionAchievementEvent(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,{"visible":true});
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(toggleNPCEvent);
         super.onClose(event);
      }
   }
}

