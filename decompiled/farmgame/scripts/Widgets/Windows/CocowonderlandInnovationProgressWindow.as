package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CocowonderlandInnovationProgressWindow extends GenericOrderBoardWindow
   {
      
      private static const AVERAGECOUNTER_TF:String = "ag_score_counter_tf";
      
      private static const GAMEPLAY_BT:String = "gameplay_bt";
      
      private const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const MAIN_BG_MC:String = "main_bg_mc";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      private const SIZE_MC:String = "size_mc";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const OVERLAY_BT:String = "overlay_bt";
      
      private const INVENTIONS_MC:String = "inventions_mc";
      
      private const TILE_UNLOCK_MC:String = "tileUnlock_mc";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private var GAMEPLAY_MC:String = "gameplay_mc";
      
      private const HALLOWEEN_GHOUL_FTUE_FLAG:String = "halloween_ghoul_ftue_flag";
      
      private const MAX_POINT:Number = 30;
      
      private var NUM_TUTORIAL_SCENES:int = 4;
      
      private var FINAL_BUILDINGS_ARRAY:Array = ["bakershaven","cafeespresso","poppatisserie"];
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Next","Let’s go!"];
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY_EA:Array = ["Next","Next","Next","Next","Let’s go!"];
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 70;
      
      private var m_featureName:String = null;
      
      private var m_mainBgMc:MovieClip = null;
      
      private var m_timerMc:MovieClip = null;
      
      private var m_size_Mc:MovieClip = null;
      
      private var m_daily_prize_mc:FarmIcon;
      
      private var m_averageScore_tf:ZwTextField;
      
      private var m_level_prize0_mc:MovieClip = null;
      
      private var m_level_prize1_mc:MovieClip = null;
      
      private var m_level_prize2_mc:MovieClip = null;
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_level_prize_0_icon:FarmIcon;
      
      private var m_level_prize_1_icon:FarmIcon;
      
      private var m_level_prize_2_icon:FarmIcon;
      
      private var m_progress_record_array:Array = [];
      
      private var m_session_mc:MovieClip;
      
      private var m_progressWidget:ZwFrame;
      
      private var m_talkMc:MovieClip;
      
      private var m_BarInd:int = 0;
      
      private var m_avg_points_info:ZwTextField;
      
      private var m_backToGameBt:FarmAnimatedTextButton;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private const PROGRESS_RECORDS_COUNTER:String = "feature_progress_small_mc";
      
      private const PROGRESS_RECORDS_COUNTER_GA:String = "feature_progress_small_GA_mc";
      
      private var m_tileMc:ZwFrame;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_imagepreviewFrame:Array = [];
      
      private var m_isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HOME);
      
      private var m_gamePlayMC:MovieClip;
      
      private var m_activePart:int;
      
      private var m_playGameBT:FarmAnimatedTextButton;
      
      public function CocowonderlandInnovationProgressWindow(windowURL:String)
      {
         this.setFTUForEA();
         super(this.FEATURE_NAME,windowURL,this.manager,this.NUM_TUTORIAL_SCENES);
         this.m_BarInd = this.manager.isGAPlayer() ? 35 : 42;
         this.m_featureName = this.FEATURE_NAME;
      }
      
      public function setFTUForEA() : void
      {
         if(this.m_isEA)
         {
            this.NUM_TUTORIAL_SCENES = 5;
         }
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var isGA:Boolean = false;
         var finalMileStoneItem:FarmItem = null;
         var index:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"VIEW PROGRESS"));
         }
         if(m_window.hasOwnProperty(this.MAIN_BG_MC))
         {
            this.m_mainBgMc = m_window.main_bg_mc as MovieClip;
            this.m_mainBgMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.WHAT_IS_THIS_MC))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[this.WHAT_IS_THIS_MC],"",this.onHowDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_size_Mc = m_window.size_mc as MovieClip;
            this.m_size_Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SUBTITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],"Collect more coupons from the orderboard tasks!"));
         }
         if(m_window.hasOwnProperty("icon_reward_mc"))
         {
            finalMileStoneItem = this.manager.getActiveDayReward(this.manager.HARD);
            if(finalMileStoneItem)
            {
               this.m_daily_prize_mc = new FarmIcon(m_window["icon_reward_mc"],finalMileStoneItem.iconUrl);
               this.m_daily_prize_mc.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
               this.m_daily_prize_mc.visible = true;
            }
         }
         if(m_window.hasOwnProperty(AVERAGECOUNTER_TF))
         {
            addWidget(this.m_averageScore_tf = new ZwTextField(m_window[AVERAGECOUNTER_TF]));
            this.m_averageScore_tf.text = "Average : " + this.manager.currentAverage.toString();
            this.m_averageScore_tf.visible = true;
         }
         if(m_window.hasOwnProperty("back_to_game_bt"))
         {
            addWidget(this.m_backToGameBt = new FarmAnimatedTextButton(m_window["back_to_game_bt"],"Awesome",this.onBackToGame));
         }
         isGA = this.manager.isGAPlayer();
         var progressRecordsCounter:String = isGA ? this.PROGRESS_RECORDS_COUNTER_GA : this.PROGRESS_RECORDS_COUNTER;
         var dayIndex:int = this.getDayNumberForPlayer();
         if(m_window.hasOwnProperty(progressRecordsCounter))
         {
            this.m_progress_record_mc = m_window[progressRecordsCounter] as MovieClip;
            this.m_progress_record_mc.visible = true;
            for(index = 0; index < this.m_BarInd; index++)
            {
               this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
               if(index >= dayIndex)
               {
                  this.m_progress_record_array[index].corck_mc.visible = false;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
               {
                  this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                  this.m_session_mc.visible = dayIndex == index;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("daymarker_mc"))
               {
                  this.m_progress_record_array[index].daymarker_mc.visible = true;
               }
            }
            if(this.m_progress_record_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_progressWidget = new ZwFrame(this.m_progress_record_mc["hit_area_mc"]);
            }
         }
         if(m_window.hasOwnProperty("level_prize0_mc"))
         {
            this.m_level_prize0_mc = m_window.level_prize0_mc as MovieClip;
            this.m_level_prize0_mc.visible = true;
            this.m_level_prize_0_icon = new FarmIcon(m_window["level_prize0_mc"].icon_reward_mc);
            this.m_level_prize_0_icon.setIconSize(150,150);
            this.m_level_prize_0_icon.loadIcon("assets/buildings/bakershaven_icon.png");
            this.m_level_prize_0_icon.setSmoothing(true);
            this.m_level_prize_0_icon.visible = true;
         }
         if(m_window.hasOwnProperty("level_prize1_mc"))
         {
            this.m_level_prize1_mc = m_window.level_prize1_mc as MovieClip;
            this.m_level_prize1_mc.visible = true;
            this.m_level_prize_1_icon = new FarmIcon(m_window["level_prize1_mc"].icon_reward_mc);
            this.m_level_prize_1_icon.setIconSize(150,150);
            this.m_level_prize_1_icon.loadIcon("assets/buildings/cafeespresso_icon.png");
            this.m_level_prize_1_icon.setSmoothing(true);
            this.m_level_prize_1_icon.visible = true;
         }
         if(m_window.hasOwnProperty("level_prize2_mc"))
         {
            this.m_level_prize2_mc = m_window.level_prize2_mc as MovieClip;
            this.m_level_prize2_mc.visible = true;
            this.m_level_prize_2_icon = new FarmIcon(m_window["level_prize2_mc"].icon_reward_mc);
            this.m_level_prize_2_icon.setIconSize(150,150);
            this.m_level_prize_2_icon.loadIcon("assets/buildings/poppatisserie_icon.png");
            this.m_level_prize_2_icon.setSmoothing(true);
            this.m_level_prize_2_icon.visible = true;
         }
         this.updateCurrentdaySmallProgressBars();
         this.updateSmallProgressBars();
      }
      
      public function updateSmallProgressBars() : void
      {
         var normalizedPoints:Number = NaN;
         var dayPoints:int = 0;
         var barLength:Number = 0;
         var dayInd:int = this.getDayNumberForPlayer();
         for(var index:int = 0; index < this.m_BarInd; index++)
         {
            dayPoints = this.manager.getpointsForTheDay(this.manager.isGAPlayer() ? int(index + 7) : index);
            if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
            {
               dayPoints = this.manager.VAL_THIRD_MILESTONE;
            }
            normalizedPoints = dayPoints;
            if(dayPoints > 20)
            {
               normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
            }
            barLength = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
            if(this.m_progress_record_array[index].bar_fill_mc)
            {
               if(dayPoints == 0)
               {
                  this.m_progress_record_array[index].bar_fill_mc.height = barLength;
               }
               else
               {
                  TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
               }
            }
            this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
            if(this.m_progress_record_array[index])
            {
               this.m_progress_record_array[index].corck_mc.visible = index < dayInd;
            }
         }
      }
      
      public function updateCurrentdaySmallProgressBars() : void
      {
         var dayNumber:int = this.getDayNumberForPlayer();
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_progress_record_array[dayNumber].bar_fill_mc)
         {
            if(dayPoints == 0)
            {
               this.m_progress_record_array[dayNumber].bar_fill_mc.height = barLength;
            }
            else
            {
               TweenMax.to(this.m_progress_record_array[dayNumber].bar_fill_mc,2,{"height":barLength});
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.updateSmallProgressBars();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function onBackToGame(event:Event) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.onCloseProgressWindow(event);
         }
         this.close();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
         if(this.m_isEA)
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY_EA[tutorialSceneNumber - 1];
         }
         else
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
         }
      }
      
      private function getDayNumberForPlayer() : int
      {
         var index:int = this.manager.isGAPlayer() ? int(this.manager.activeDayIndex - 7) : this.manager.activeDayIndex;
         return index < 0 ? 0 : index;
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         if(this.m_isEA)
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY_EA[tutorialSceneNumber - 1];
         }
         else
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
         }
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      override public function close() : void
      {
         super.close();
         this.manager.mainWindow.enableInput = true;
      }
   }
}

