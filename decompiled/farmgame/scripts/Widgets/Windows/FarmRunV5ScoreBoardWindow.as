package Widgets.Windows
{
   import Engine.Utilities;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunV5OrderboardFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import mx.utils.StringUtil;
   
   public class FarmRunV5ScoreBoardWindow extends FarmWindowWithTutorial
   {
      
      private static const TIMER_DELAY_IN_MSECS:Number = 1000;
      
      private static const TIME_TO_REDIRECT_IN_SECS:Number = 10;
      
      private static const LAST_ROUND:Number = 2;
      
      private static const POWER_UP_COST:Number = 2;
      
      private var m_featureName:String = null;
      
      public var m_meter_mc:MovieClip;
      
      private var m_world1_mc:MovieClip;
      
      private var m_world2_mc:MovieClip;
      
      private var m_world3_mc:MovieClip;
      
      private var m_world4_mc:MovieClip;
      
      private var m_talkMc:MovieClip;
      
      private var m_talk_tf:ZwTextField;
      
      public var m_pointerMc:MovieClip;
      
      private var m_taskFrame:FarmRunV5OrderboardFrame;
      
      private var m_loadingTf:ZwTextField;
      
      protected var m_DumptutorialScene:int = 0;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private var m_titleTF:ZwTextField;
      
      private var m_okayBT:FarmAnimatedTextButton;
      
      private var m_introMC:MovieClip;
      
      private var m_introPointsMC:MovieClip;
      
      private var m_introTutorialMC:MovieClip;
      
      private var m_introHighlighMC:MovieClip;
      
      private var m_introPointsTF:ZwTextField;
      
      private var m_isGameOver:Boolean;
      
      private var m_body2TF:ZwTextField;
      
      private var m_timeRemaining:int;
      
      private var m_foundAllPairs:Boolean;
      
      private var m_timerRanOut:Boolean;
      
      private var m_SummaryFrames:Array = [];
      
      private var m_pointsEarnedSummaryTFs:Array = [];
      
      private var m_pairsFoundSummaryTFs:Array = [];
      
      private var m_summaryHeaderTFs:Array = [];
      
      private var m_summaryGameRoundTFs:Array = [];
      
      private var m_roundinfoMC:MovieClip;
      
      private var m_timerTF:ZwTextField;
      
      private var m_headerTF:ZwTextField;
      
      private var m_footerTF:ZwTextField;
      
      private var m_gameRoundTF:ZwTextField;
      
      private var m_pointsEarnedTF:ZwTextField;
      
      private var m_pairsCountTF:ZwTextField;
      
      private var m_powerUpFrame:MovieClip;
      
      private var m_replayBT:FarmAnimatedCashButton;
      
      private var m_npcMc:MovieClip;
      
      public function FarmRunV5ScoreBoardWindow(featureName:String, assetURL:String, gameOver:Boolean = false, foundAllPairs:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_isGameOver = gameOver;
         this.m_foundAllPairs = foundAllPairs;
         super(featureName,assetURL);
      }
      
      private static function setSummaryFrameTexts(textFields:Array, text1:String, text2:String) : void
      {
         if(textFields.length < 2)
         {
            return;
         }
         if(textFields[0])
         {
            textFields[0].text = text1;
            textFields[0].visible = true;
         }
         if(textFields[1])
         {
            textFields[1].text = text2;
            textFields[1].visible = true;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var summaryFrame:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTF = new ZwTextField(m_window["title_tf"],"FARM RUN"));
            this.m_titleTF.visible = true;
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(this.m_body2TF = new ZwTextField(m_window["body2_tf"],"body2 tf"));
            this.m_body2TF.visible = false;
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = this.m_isGameOver;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
            {
               addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
               this.m_talk_tf.visible = true;
            }
            this.m_talkMc.visible = this.m_isGameOver;
         }
         if(m_window.hasOwnProperty("intro_mc"))
         {
            this.m_introMC = m_window.intro_mc as MovieClip;
            if(this.m_introMC.highlight_mc)
            {
               this.m_introHighlighMC = this.m_introMC.highlight_mc as MovieClip;
               this.m_introHighlighMC.visible = true;
            }
            if(this.m_introMC.points_mc)
            {
               this.m_introPointsMC = this.m_introMC.points_mc as MovieClip;
               if(this.m_introPointsMC.points_tf)
               {
                  addWidget(this.m_introPointsTF = new ZwTextField(this.m_introPointsMC.points_tf,"16"));
                  this.m_introPointsTF.visible = true;
               }
               this.m_introPointsMC.visible = true;
            }
            if(this.m_introMC.tutorial_mc)
            {
               this.m_introTutorialMC = this.m_introMC.tutorial_mc as MovieClip;
               this.m_introTutorialMC.visible = true;
            }
            this.m_introMC.visible = !this.m_isGameOver;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okayBT = new FarmAnimatedTextButton(m_window["okay_bt"],"Play Game",this.onIntroOkayClick));
            this.m_okayBT.visible = true;
         }
         if(m_window.hasOwnProperty("world1BG_mc"))
         {
            this.m_world1_mc = m_window["world1BG_mc"] as MovieClip;
            this.m_world1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world2BG_mc"))
         {
            this.m_world2_mc = m_window["world2BG_mc"] as MovieClip;
            this.m_world2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world3BG_mc"))
         {
            this.m_world3_mc = m_window["world3BG_mc"] as MovieClip;
            this.m_world3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world4BG_mc"))
         {
            this.m_world4_mc = m_window["world4BG_mc"] as MovieClip;
            this.m_world4_mc.visible = false;
         }
         var worldId:int = this.manager.getworldIndexFromName(this.manager.getFarmrunWorldFromPoints());
         var worldElement:String = "world" + (worldId + 1) + "BG_mc";
         if(m_window.hasOwnProperty(worldElement))
         {
            m_window[worldElement].visible = true;
         }
         if(m_window.hasOwnProperty("roundinfo_mc"))
         {
            this.m_roundinfoMC = m_window.roundinfo_mc as MovieClip;
            if(this.m_roundinfoMC.timer_tf)
            {
               this.m_timerTF = new ZwTextField(this.m_roundinfoMC.timer_tf,TIME_TO_REDIRECT_IN_SECS.toString());
               this.m_timerTF.visible = true;
            }
            if(this.m_roundinfoMC.header_tf)
            {
               this.m_headerTF = new ZwTextField(this.m_roundinfoMC.header_tf,"STARTS IN");
               this.m_headerTF.visible = true;
            }
            if(this.m_roundinfoMC.footer_tf)
            {
               this.m_footerTF = new ZwTextField(this.m_roundinfoMC.footer_tf,"STARTS IN");
               this.m_footerTF.visible = true;
            }
            if(this.m_roundinfoMC.round_tf)
            {
               this.m_gameRoundTF = new ZwTextField(this.m_roundinfoMC.round_tf,"Round " + this.manager.miniGameActiveRound.toString());
               this.m_gameRoundTF.visible = true;
            }
            if(this.m_roundinfoMC.count_tf)
            {
               this.m_pointsEarnedTF = new ZwTextField(this.m_roundinfoMC.count_tf,"");
               this.m_pointsEarnedTF.visible = true;
            }
            if(this.m_roundinfoMC.count1_tf)
            {
               this.m_pairsCountTF = new ZwTextField(this.m_roundinfoMC.count1_tf,"");
               this.m_pairsCountTF.visible = true;
            }
            if(this.m_roundinfoMC.powerup_bt)
            {
               this.m_powerUpFrame = this.m_roundinfoMC.powerup_bt as MovieClip;
               if(this.m_powerUpFrame.buyAll_bt != null)
               {
                  this.m_replayBT = new FarmAnimatedCashButton(this.m_powerUpFrame.buyAll_bt,"buy","2",this.onBuyExtraTime);
                  this.m_replayBT.visible = true;
               }
               this.m_powerUpFrame.visible = false;
            }
            this.m_roundinfoMC.visible = false;
         }
         for(var i:int = 0; i < 2; i++)
         {
            if(m_window.hasOwnProperty("gameOver" + (i + 1).toString() + "_mc"))
            {
               summaryFrame = m_window["gameOver" + (i + 1).toString() + "_mc"] as MovieClip;
               if(summaryFrame.count_tf)
               {
                  this.m_pointsEarnedSummaryTFs[i] = new ZwTextField(summaryFrame.count_tf,"");
                  this.m_pointsEarnedSummaryTFs[i].visible = false;
               }
               if(summaryFrame.count1_tf)
               {
                  this.m_pairsFoundSummaryTFs[i] = new ZwTextField(summaryFrame.count1_tf,"");
                  this.m_pairsFoundSummaryTFs[i].visible = false;
               }
               if(summaryFrame.header_tf)
               {
                  this.m_summaryHeaderTFs[i] = new ZwTextField(summaryFrame.header_tf,"STARTS IN");
                  this.m_summaryHeaderTFs[i].visible = false;
               }
               if(summaryFrame.round_tf)
               {
                  this.m_summaryGameRoundTFs[i] = new ZwTextField(summaryFrame.round_tf,"Round " + (i + 1).toString());
                  this.m_summaryGameRoundTFs[i].visible = false;
               }
               summaryFrame.visible = false;
               this.m_SummaryFrames[i] = summaryFrame;
            }
         }
         this.setUp();
      }
      
      private function onBuyExtraTime(event:Event) : void
      {
         this.manager.spendFarmCashService(FarmRunV5Manager.TYPE_MINI_GAME_REPLAY,this.onBuyExtraTimeSuccess);
      }
      
      private function onBuyExtraTimeSuccess() : void
      {
         if(this.m_replayBT)
         {
            this.manager.displayPowerupButtonStatusText(this.m_replayBT.element,POWER_UP_COST,"Farm Cash",false);
         }
         this.onTimerEnd(true);
      }
      
      private function shouldShowGameSummary() : Boolean
      {
         return (this.m_timerRanOut || this.m_foundAllPairs) && this.manager.miniGameActiveRound == LAST_ROUND;
      }
      
      private function shouldShowCountdownScreen() : Boolean
      {
         return this.m_isGameOver && !this.shouldShowGameSummary();
      }
      
      private function setUpOkayButton() : void
      {
         if(!this.m_okayBT)
         {
            return;
         }
         this.m_okayBT.visible = true;
         this.m_okayBT.enabled = false;
         this.m_okayBT.text = "Loading...";
         this.m_okayBT.callback = this.manager.onSummaryConfirmationClick;
      }
      
      private function showCountdownScreen() : void
      {
         if(this.m_okayBT)
         {
            this.m_okayBT.visible = false;
         }
         if(this.m_roundinfoMC)
         {
            this.m_roundinfoMC.visible = true;
         }
         if(this.m_powerUpFrame)
         {
            this.m_powerUpFrame.visible = !this.m_foundAllPairs;
         }
         var round:String = this.manager.miniGameActiveRound.toString();
         var score:int = this.manager.miniGameActiveRound != LAST_ROUND ? this.manager.miniGameRound1Score : this.manager.miniGameRound2Score;
         if(this.m_pointsEarnedTF)
         {
            this.m_pointsEarnedTF.text = score.toString();
         }
         if(this.m_pairsCountTF)
         {
            this.m_pairsCountTF.text = score.toString() + " Pairs Found";
         }
         if(this.m_foundAllPairs)
         {
            if(this.m_headerTF)
            {
               this.m_headerTF.text = "ROUND " + (this.manager.miniGameActiveRound + 1).toString() + " STARTS IN";
            }
            if(this.m_footerTF)
            {
               this.m_footerTF.visible = false;
            }
         }
         else
         {
            if(this.m_headerTF)
            {
               this.m_headerTF.text = "ROUND " + round + " ENDS IN";
            }
            if(this.m_footerTF)
            {
               this.m_footerTF.text = "REPLAY ROUND " + round;
            }
         }
         this.m_timeRemaining = TIME_TO_REDIRECT_IN_SECS;
         this.updateNPCBuyMoreTimeText();
         this.manager.startTimer(TIMER_DELAY_IN_MSECS,this.onTimerTick);
      }
      
      private function showGameSummary() : void
      {
         var round1Score:int = this.manager.miniGameRound1Score;
         var round2Score:int = this.manager.miniGameRound2Score;
         var pairsFoundTemplate:String = "{0} Pairs Found";
         if(this.m_roundinfoMC)
         {
            this.m_roundinfoMC.visible = false;
         }
         if(this.m_SummaryFrames.length == 2)
         {
            if(this.m_SummaryFrames[0])
            {
               this.m_SummaryFrames[0].visible = true;
            }
            if(this.m_SummaryFrames[1])
            {
               this.m_SummaryFrames[1].visible = true;
            }
         }
         setSummaryFrameTexts(this.m_summaryGameRoundTFs,"ROUND 1","ROUND 2");
         setSummaryFrameTexts(this.m_summaryHeaderTFs,"SUMMARY","SUMMARY");
         setSummaryFrameTexts(this.m_pointsEarnedSummaryTFs,round1Score.toString(),round2Score.toString());
         setSummaryFrameTexts(this.m_pairsFoundSummaryTFs,StringUtil.substitute(pairsFoundTemplate,round1Score),StringUtil.substitute(pairsFoundTemplate,round2Score));
         this.setUpOkayButton();
         this.updateNPCBuyMoreTimeText();
         this.manager.onMiniGameEnd();
      }
      
      private function setUp() : void
      {
         if(!this.m_isGameOver)
         {
            this.manager.resetGameData();
         }
         this.m_timerRanOut = false;
         var showCountDown:Boolean = this.shouldShowCountdownScreen();
         var isShowGameSummary:Boolean = this.shouldShowGameSummary();
         if(showCountDown)
         {
            this.showCountdownScreen();
         }
         if(isShowGameSummary)
         {
            this.showGameSummary();
         }
      }
      
      private function redirectToGame(isReplay:Boolean = false) : void
      {
         if(!isReplay)
         {
            this.manager.miniGameActiveRound = Math.min(this.manager.miniGameActiveRound + 1,LAST_ROUND);
         }
         this.manager.showGameUI(isReplay);
         close();
      }
      
      private function onTimerEnd(isReplay:Boolean = false) : void
      {
         this.m_timerRanOut = !isReplay;
         this.manager.stopTimer(this.onTimerTick);
         if(!isReplay)
         {
            this.manager.updateAssetPoolIndex();
         }
         if(this.shouldShowGameSummary())
         {
            this.showGameSummary();
         }
         else
         {
            this.redirectToGame(isReplay);
         }
      }
      
      private function updateTimerText() : void
      {
         if(this.m_timerTF)
         {
            this.m_timerTF.text = this.m_timeRemaining.toString();
         }
      }
      
      private function onTimerTick(event:Event) : void
      {
         --this.m_timeRemaining;
         if(this.m_timeRemaining == 0)
         {
            this.onTimerEnd();
            return;
         }
         this.updateTimerText();
      }
      
      private function onIntroOkayClick(event:Event) : void
      {
         if(this.manager.m_window)
         {
            this.manager.m_window.refreshWindow();
         }
         if(this.manager.getFeatureProgress() < 1000 && !this.m_isGameOver)
         {
            this.manager.showGameUI();
         }
         this.closeWindow();
      }
      
      public function enableOkayButton() : void
      {
         this.m_okayBT.enabled = true;
         if(this.manager.getFeatureProgress() >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
         {
            this.m_okayBT.text = "Main Menu";
         }
         else
         {
            this.m_okayBT.text = "Do Orders";
         }
      }
      
      public function closeWindow() : void
      {
         m_window = null;
         this.manager.m_window.untintWindow();
         Utilities.toggleInputAndChildren(Global.ui,false);
         Utilities.toggleInputAndChildren(this.manager.m_window,true);
         this.manager.m_window.enableInput = true;
         super.close();
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
         }
         this.m_taskFrame.refresh();
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
      }
      
      public function updateNPCBuyMoreTimeText() : void
      {
         if(this.m_talkMc)
         {
            if(this.m_talk_tf)
            {
               if(this.m_foundAllPairs)
               {
                  this.m_talk_tf.text = this.manager.miniGameActiveRound != LAST_ROUND ? "Awesome! You got all the points. Get ready for round 2." : "Awesome! Complete more orders for another round of Pair Me Up!";
               }
               else if(this.m_timeRemaining == 0)
               {
                  if(this.manager.getFeatureProgress() + this.manager.miniGameScore >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
                  {
                     this.m_talk_tf.text = "\nYes! We did it!";
                  }
                  else
                  {
                     this.m_talk_tf.text = "\nUh oh! Time got over";
                  }
               }
               else
               {
                  this.m_talk_tf.text = "Get 10 seconds more to continue your game to earn all the points.";
               }
            }
         }
      }
   }
}

