package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class HalloweenUSAInnovationGameWindow extends FarmWindowWithTutorial
   {
      
      private static const HALLOWEENUSA_INNOVATION_FEATURE_SEEN_FLAG:String = "HalloweenUSAInnovation_Tutorial";
      
      private static const ICON_SIZE:int = 100;
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const PROFILE1_MC:String = "profile1_mc";
      
      private static const PROFILE2_MC:String = "profile2_mc";
      
      private static const SCORE_MC:String = "score_mc";
      
      private static const CONNECT_MC_STR:String = "connect_mc";
      
      private static const OVERLAY_MC_STR:String = "overlay_mc";
      
      private static const CHOICE1_MC:String = "choice1_mc";
      
      private static const CHOICE2_MC:String = "choice2_mc";
      
      private static const HIGHLIGHT1_MC:String = "highlight1_mc";
      
      private static const HIGHLIGHT2_MC:String = "highlight2_mc";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const CONNECT1_TF:String = "overlay1_tf";
      
      private static const CONNECT2_TF:String = "overlay2_tf";
      
      private static const ANIMATION_MC:String = "animation_mc";
      
      private static const LOST_MC:String = "lost_mc";
      
      private static const WIN_MC:String = "win_mc";
      
      private static const TEXT1_TF:String = "text1_tf";
      
      private static const TEXT2_TF:String = "text2_tf";
      
      private static const GAMES_TF:String = "games_tf";
      
      private static const COUNT_TF:String = "count_tf";
      
      private static const COUNTDOWN_TF:String = "countdown_tf";
      
      private static const HELP_TF:String = "help_tf";
      
      private static const CHOICES_MC:String = "choices_mc";
      
      private static const SELECT_TF:String = "select_tf";
      
      private static const WINNER_TF:String = "winner_tf";
      
      private static const TIE_BREAKER_TF:String = "tiebreaker_tf";
      
      private static const NEXT_TF:String = "next_tf";
      
      private static const SCORE_TF:String = "score_tf";
      
      private static const SELECT_MC:String = "select_mc";
      
      private static const SECONDS_TF:String = "seconds_tf";
      
      private static const CLOCK_MC:String = "clock_mc";
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      private static const DRAW:int = 0;
      
      private static const WIN:int = 1;
      
      private static const LOOSE:int = -1;
      
      private static const ROCK:Number = 1;
      
      private static const PAPER:Number = 2;
      
      private static const SCISSORS:Number = 3;
      
      private static const NO_CHOICE:Number = 4;
      
      protected var m_featureName:String;
      
      private var m_score_mc:MovieClip;
      
      private var m_choice1_mc:MovieClip;
      
      private var m_choice2_mc:MovieClip;
      
      private var m_highlight1_mc:MovieClip;
      
      private var m_highlight2_mc:MovieClip;
      
      private var m_connect_mc:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      private var m_profile1_mc:MovieClip;
      
      private var m_profile2_mc:MovieClip;
      
      private var m_player1_icon:FarmIcon;
      
      private var m_player2_icon:FarmIcon;
      
      private var m_player2_icon_url:String;
      
      private var m_playerTurnCount:int = 0;
      
      private var m_connectOkay_button:FarmAnimatedTextButton;
      
      private var m_connectText1:FarmTextField;
      
      private var m_connectText2:FarmTextField;
      
      private var m_postGameOkay_button:FarmAnimatedTextButton;
      
      private var m_gameId:String;
      
      private var m_player2UID:String;
      
      private var m_timer:Timer;
      
      private var m_timerText:ZwTextField;
      
      private var m_currentTimeCount:Number;
      
      private var m_selectButtonArray:Array = new Array();
      
      private var m_playerCounterArray:Array = new Array();
      
      private var m_player2FirstName:String;
      
      private var m_score_tf:ZwTextField;
      
      private var m_gameStarted:Boolean = false;
      
      private var m_playercurrentChoice:Number = 0;
      
      private var m_showTutorial:Boolean;
      
      private var m_bodyText:ZwTextField;
      
      private var m_next_tf:ZwTextField;
      
      private var m_gameFinished:Boolean = false;
      
      private var m_selectText:ZwTextField;
      
      private var m_select_mc:MovieClip;
      
      private var m_winner_tf:ZwTextField;
      
      private var m_tiebreaker_tf:ZwTextField;
      
      private var m_playerScore:int = 0;
      
      private var m_opponentChoice:int = -1;
      
      private var m_resultScreenTimerCount:int = 0;
      
      private var m_resultScreenTimer:Timer;
      
      private var m_checkMarkArray:Array = new Array();
      
      private var m_tiebreakerMode:Boolean = false;
      
      private var m_soloMode:Boolean = false;
      
      private var m_overlayText1:FarmTextField;
      
      private var m_overlayText2:FarmTextField;
      
      private var m_overlayOkay_button:FarmAnimatedTextButton;
      
      private var m_choices_mc:MovieClip;
      
      private var m_animation_mc:MovieClip;
      
      private var m_win_mc:MovieClip;
      
      private var m_lost_mc:MovieClip;
      
      private var m_winText1:FarmTextField;
      
      private var m_winText2:FarmTextField;
      
      private var m_lostText1:FarmTextField;
      
      private var m_lostText2:FarmTextField;
      
      private var m_helpText:FarmTextField;
      
      private var m_countdownTimer:ZwTextField;
      
      private var m_games_tf:FarmTextField;
      
      private var m_count_tf:FarmTextField;
      
      private var m_seconds_tf:ZwTextField;
      
      private var m_clock_mc:MovieClip;
      
      private var m_firstSwitch:Boolean = true;
      
      private var m_fixingTurn:int = Math.floor(Math.random() * 3 + 1);
      
      public function HalloweenUSAInnovationGameWindow(featureName:String, assetPath:String, showTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorial = showTutorial;
         Global.player.setSeenFlag(HALLOWEENUSA_INNOVATION_FEATURE_SEEN_FLAG);
         super(this.m_featureName,assetPath,NUM_TUTORIAL_SCENES,true,true,showTutorial);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         var counterIndex:int = 0;
         var selectedFarmItem:FarmItem = null;
         var buttonIndex:int = 0;
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_Title")));
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            addWidget(this.m_bodyText = new ZwTextField(m_window[BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_body")));
            this.m_bodyText.visible = true;
         }
         if(m_window.hasOwnProperty(NEXT_TF))
         {
            addWidget(this.m_next_tf = new ZwTextField(m_window[NEXT_TF],""));
            this.m_next_tf.visible = false;
         }
         if(m_window.hasOwnProperty(SECONDS_TF))
         {
            addWidget(this.m_seconds_tf = new ZwTextField(m_window[SECONDS_TF],""));
            this.m_seconds_tf.visible = false;
         }
         if(m_window.hasOwnProperty(WINNER_TF))
         {
            addWidget(this.m_winner_tf = new ZwTextField(m_window[WINNER_TF],""));
            this.m_winner_tf.visible = false;
         }
         if(m_window.hasOwnProperty(TIE_BREAKER_TF))
         {
            addWidget(this.m_tiebreaker_tf = new ZwTextField(m_window[TIE_BREAKER_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_TiebreakerText")));
            this.m_tiebreaker_tf.visible = false;
         }
         if(m_window.hasOwnProperty(SCORE_MC))
         {
            this.m_score_mc = m_window[SCORE_MC] as MovieClip;
            this.m_score_mc.visible = true;
            for(counterIndex = 0; counterIndex < this.manager.turnsInGame; counterIndex++)
            {
               this.m_playerCounterArray[counterIndex] = this.m_score_mc["count_mc_" + counterIndex.toString()] as MovieClip;
               (this.m_playerCounterArray[counterIndex] as MovieClip).gotoAndStop(1);
            }
            if(this.m_score_mc.hasOwnProperty(SCORE_TF))
            {
               this.m_score_tf = new ZwTextField(this.m_score_mc[SCORE_TF],"Score");
            }
         }
         if(m_window.hasOwnProperty(ANIMATION_MC))
         {
            this.m_animation_mc = m_window[ANIMATION_MC];
            this.m_animation_mc.visible = false;
         }
         if(m_window.hasOwnProperty(CLOCK_MC))
         {
            this.m_clock_mc = m_window[CLOCK_MC];
            this.m_clock_mc.visible = false;
         }
         if(m_window.hasOwnProperty(CHOICES_MC))
         {
            this.m_choices_mc = m_window[CHOICES_MC] as MovieClip;
            this.m_choices_mc.visible = false;
            if(this.m_choices_mc.hasOwnProperty(CHOICE1_MC))
            {
               this.m_choice1_mc = this.m_choices_mc[CHOICE1_MC] as MovieClip;
               this.m_choice1_mc.gotoAndStop(1);
            }
            if(this.m_choices_mc.hasOwnProperty(CHOICE2_MC))
            {
               this.m_choice2_mc = this.m_choices_mc[CHOICE2_MC] as MovieClip;
               this.m_choice2_mc.gotoAndStop(1);
            }
         }
         if(m_window.hasOwnProperty(HIGHLIGHT1_MC))
         {
            this.m_highlight1_mc = m_window[HIGHLIGHT1_MC] as MovieClip;
            this.m_highlight1_mc.visible = false;
         }
         if(m_window.hasOwnProperty(HIGHLIGHT2_MC))
         {
            this.m_highlight2_mc = m_window[HIGHLIGHT2_MC] as MovieClip;
            this.m_highlight2_mc.visible = false;
         }
         if(m_window.hasOwnProperty(WIN_MC))
         {
            this.m_win_mc = m_window[WIN_MC] as MovieClip;
            this.m_winText1 = new FarmTextField(this.m_win_mc[TEXT1_TF]);
            this.m_winText2 = new FarmTextField(this.m_win_mc[TEXT2_TF]);
            if(this.m_win_mc.hasOwnProperty("icon_mc"))
            {
               selectedFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.selectedItemCodeForGame);
               if(selectedFarmItem)
               {
                  iconUrl = selectedFarmItem.iconUrl;
                  if(iconUrl == null)
                  {
                     iconUrl = selectedFarmItem.getImageByName(FarmItem.ICON_200);
                     if(iconUrl == null)
                     {
                        iconUrl = selectedFarmItem.getImageByName(FarmItem.ICON_FEED);
                     }
                  }
               }
               this.m_games_tf = new FarmTextField(this.m_win_mc[GAMES_TF]);
               this.m_count_tf = new FarmTextField(this.m_win_mc[COUNT_TF]);
               addWidget(new FarmIcon(this.m_win_mc["icon_mc"],iconUrl));
            }
            this.m_win_mc.visible = false;
         }
         if(m_window.hasOwnProperty(LOST_MC))
         {
            this.m_lost_mc = m_window[LOST_MC] as MovieClip;
            this.m_lost_mc.visible = false;
            this.m_lostText1 = new FarmTextField(this.m_lost_mc[TEXT1_TF]);
            this.m_lostText2 = new FarmTextField(this.m_lost_mc[TEXT2_TF]);
         }
         if(m_window.hasOwnProperty(CONNECT_MC_STR))
         {
            this.m_connect_mc = m_window[CONNECT_MC_STR] as MovieClip;
            if(this.m_showTutorial)
            {
               this.m_connect_mc.visible = false;
            }
            else
            {
               this.m_connect_mc.visible = true;
            }
            this.m_connectText1 = new FarmTextField(this.m_connect_mc[CONNECT1_TF]);
            this.m_helpText = new FarmTextField(this.m_connect_mc[HELP_TF]);
            this.m_helpText.text = "Get ready to make a Terrorific Choice once the game starts!";
            this.m_connectText2 = new FarmTextField(this.m_connect_mc[CONNECT2_TF]);
            this.m_connectOkay_button = new FarmAnimatedTextButton(this.m_connect_mc["okay_bt"],null);
            this.m_connectOkay_button.visible = false;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            this.m_postGameOkay_button = new FarmAnimatedTextButton(m_window["okay_bt"],null);
            this.m_postGameOkay_button.visible = false;
         }
         if(m_window.hasOwnProperty(OVERLAY_MC_STR))
         {
            this.m_overlay_mc = m_window[OVERLAY_MC_STR] as MovieClip;
            this.m_overlay_mc.visible = false;
            this.m_overlayText1 = new FarmTextField(this.m_overlay_mc[CONNECT1_TF]);
            this.m_overlayText2 = new FarmTextField(this.m_overlay_mc[CONNECT2_TF]);
            this.m_overlayOkay_button = new FarmAnimatedTextButton(this.m_overlay_mc["okay_bt"],null);
         }
         if(m_window.hasOwnProperty(PROFILE1_MC))
         {
            this.m_profile1_mc = m_window[PROFILE1_MC] as MovieClip;
            if(this.m_profile1_mc)
            {
               this.m_profile1_mc.visible = true;
               this.m_player1_icon = new FarmIcon(this.m_profile1_mc[ICON_MC]);
               this.m_player1_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player1_icon.setSmoothing(true);
               iconUrl = Global.player.picture;
               this.m_player1_icon.loadIcon(iconUrl);
               this.m_profile1_mc["name_tf"].text = Global.player.firstName;
            }
         }
         if(m_window.hasOwnProperty(PROFILE2_MC))
         {
            this.m_profile2_mc = m_window[PROFILE2_MC] as MovieClip;
            if(this.m_profile2_mc)
            {
               this.m_profile2_mc.visible = true;
               this.m_player2_icon = new FarmIcon(this.m_profile2_mc[ICON_MC]);
               this.m_player2_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player2_icon.setSmoothing(true);
               this.m_profile2_mc["name_tf"].text = "Player 2";
            }
         }
         if(m_window.hasOwnProperty(SELECT_MC))
         {
            this.m_select_mc = m_window[SELECT_MC] as MovieClip;
            this.m_select_mc.visible = true;
            for(buttonIndex = 1; buttonIndex <= 3; buttonIndex++)
            {
               this.m_selectButtonArray[buttonIndex] = new FarmAnimatedTextButton(this.m_select_mc["select" + buttonIndex.toString() + "_bt"],"",this.makeClickListener(buttonIndex));
               this.m_checkMarkArray[buttonIndex] = this.m_select_mc["checkmark" + buttonIndex.toString() + "_mc"];
               if(buttonIndex == 1)
               {
                  this.m_selectButtonArray[buttonIndex].text = "Rock";
               }
               if(buttonIndex == 2)
               {
                  this.m_selectButtonArray[buttonIndex].text = "Paper";
               }
               if(buttonIndex == 3)
               {
                  this.m_selectButtonArray[buttonIndex].text = "Scissor";
               }
               this.m_checkMarkArray[buttonIndex].visible = false;
            }
            if(this.m_select_mc.hasOwnProperty(COUNTDOWN_TF))
            {
               addWidget(this.m_countdownTimer = new ZwTextField(this.m_select_mc[COUNTDOWN_TF],"Countdown Timer"));
            }
            if(this.m_select_mc.hasOwnProperty(TIMER_TF))
            {
               addWidget(this.m_timerText = new ZwTextField(this.m_select_mc[TIMER_TF],"00:00:07"));
            }
            if(this.m_select_mc.hasOwnProperty(SELECT_TF))
            {
               addWidget(this.m_selectText = new ZwTextField(this.m_select_mc[SELECT_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_choiceText")));
            }
         }
         super.postLoadComplete();
         if(this.m_showTutorial)
         {
            this.showTutorial();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function startGame(soloMode:Boolean = false, player2Id:String = "", gameId:String = "") : void
      {
         this.m_select_mc.visible = true;
         this.m_playercurrentChoice = 0;
         this.m_soloMode = soloMode;
         this.m_gameStarted = true;
         this.m_connect_mc.visible = false;
         this.m_overlay_mc.visible = false;
         this.enableUserChoices();
         if(this.m_soloMode)
         {
            this.startGameWithSoloMode();
         }
         else
         {
            this.m_player2UID = player2Id;
            this.m_player2_icon_url = Global.getFBPicUrl(player2Id);
            if(this.m_player2_icon)
            {
               this.m_player2_icon.loadIcon(this.m_player2_icon_url);
            }
            this.m_gameId = gameId;
            MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            this.exchangeFirstName();
         }
         this.startTurnResponseTimer();
      }
      
      public function startGameWithSoloMode() : void
      {
         this.m_player2_icon.release();
         this.m_player2_icon = null;
         this.m_player2_icon = new FarmIcon(this.m_profile2_mc[ICON_MC]);
         this.m_player2_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_player2_icon.setSmoothing(true);
         this.m_player2_icon.loadIcon("assets/dialogs/halloweenusa/innovation/NPC_profile.jpg");
         this.m_profile2_mc["name_tf"].text = "Miss Mulberry";
      }
      
      public function reStartGameWithSoloMode(e:Event = null) : void
      {
         this.m_overlay_mc.visible = false;
         --this.m_playerTurnCount;
         this.startGame(true);
      }
      
      private function get manager() : HalloweenInnovationManager
      {
         return HalloweenInnovationManager.getInstance(this.m_featureName);
      }
      
      public function get gameStarted() : Boolean
      {
         return this.m_gameStarted;
      }
      
      override protected function release() : void
      {
         this.m_playerTurnCount = 0;
         super.release();
      }
      
      public function makeClickListener(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            switch(slotIndex)
            {
               case PAPER:
                  m_playercurrentChoice = PAPER;
                  FarmStatsManager.count("RockPaperShivers_Game",m_playerTurnCount.toString(),"paper",m_gameId);
                  break;
               case ROCK:
                  m_playercurrentChoice = ROCK;
                  FarmStatsManager.count("RockPaperShivers_Game",m_playerTurnCount.toString(),"rock",m_gameId);
                  break;
               case SCISSORS:
                  m_playercurrentChoice = SCISSORS;
                  FarmStatsManager.count("RockPaperShivers_Game",m_playerTurnCount.toString(),"scissors",m_gameId);
                  break;
               default:
                  m_playercurrentChoice = 4;
                  FarmStatsManager.count("RockPaperShivers_Game",m_playerTurnCount.toString(),"missed",m_gameId);
            }
            m_checkMarkArray[slotIndex].visible = true;
            disableUserChoices();
            m_timerText.visible = false;
            if(m_soloMode == false)
            {
               MatchMakingManager.getInstance().sendMessage("GameMove" + m_gameId + ":" + m_playercurrentChoice,m_player2UID);
            }
         };
      }
      
      public function exchangeFirstName() : void
      {
         MatchMakingManager.getInstance().sendMessage("FirstName" + this.m_gameId + ":" + Global.player.firstName,this.m_player2UID);
      }
      
      override public function close() : void
      {
         this.m_timerText = null;
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         this.stopTurnResponseTimer();
         this.stopResultScreenTimer();
         this.m_gameStarted = false;
         super.close();
      }
      
      private function refreshTimerText() : void
      {
         var randResponse:Number = NaN;
         if(this.m_currentTimeCount > this.manager.DEFAULT_WAITING_PERIOD)
         {
            this.stopTurnResponseTimer();
            this.m_animation_mc.visible = false;
            if(this.m_opponentChoice == -1)
            {
               if(this.m_playerTurnCount == 3 && (this.m_playerScore == 2 || this.m_playerScore == -2))
               {
                  this.m_opponentChoice = NO_CHOICE;
                  if(this.m_tiebreakerMode)
                  {
                     this.displayTieBreakerResult();
                  }
                  else
                  {
                     this.displayTurnResults();
                  }
               }
               else
               {
                  this.switchToSoloMode();
               }
            }
            else if(this.m_tiebreakerMode)
            {
               this.displayTieBreakerResult();
            }
            else
            {
               this.displayTurnResults();
            }
         }
         else if(this.m_currentTimeCount == this.manager.PLAYER_RESPONSE_PERIOD + 1)
         {
            if(this.m_playercurrentChoice == 0)
            {
               this.m_playercurrentChoice = 4;
            }
            this.m_select_mc.visible = false;
            this.disableUserChoices();
            this.m_animation_mc.visible = true;
            this.m_animation_mc.play();
            this.m_timerText.visible = false;
            ++this.m_playerTurnCount;
            if(this.m_soloMode)
            {
               randResponse = Math.floor(Math.random() * 3) + 1;
               this.m_opponentChoice = randResponse;
               if(!this.m_tiebreakerMode && this.m_playerTurnCount == this.m_fixingTurn)
               {
                  this.m_opponentChoice = (this.m_playercurrentChoice + 1) % 3 + 1;
               }
            }
         }
         else if(this.m_playercurrentChoice == 0 && this.m_currentTimeCount <= this.manager.PLAYER_RESPONSE_PERIOD)
         {
            if(this.m_timerText)
            {
               this.m_timerText.text = HUD.getformattedTimeLeft(this.manager.PLAYER_RESPONSE_PERIOD - this.m_currentTimeCount);
               this.m_timerText.visible = true;
            }
         }
         this.m_currentTimeCount += 1;
      }
      
      public function displayTieBreakerResult() : void
      {
         this.startResultScreenTimer();
         this.m_select_mc.visible = false;
         this.m_choices_mc.visible = true;
         this.m_choice1_mc.gotoAndStop(this.m_playercurrentChoice);
         this.m_choice2_mc.gotoAndStop(this.m_opponentChoice);
         this.m_choices_mc.play();
         this.m_playerScore = this.getResult(this.m_playercurrentChoice,this.m_opponentChoice);
         this.m_winner_tf.visible = true;
         if(this.m_playerScore > 0)
         {
            this.m_highlight1_mc.visible = true;
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : You Win";
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"tiebreaker_resuslt","win",this.m_gameId);
         }
         else if(this.m_playerScore < 0)
         {
            this.m_highlight2_mc.visible = true;
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : Opponent Win";
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"tiebreaker_resuslt","lose",this.m_gameId);
         }
         else
         {
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : It\'s a Draw";
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"tiebreaker_resuslt","draw",this.m_gameId);
         }
      }
      
      public function displayTurnResults() : void
      {
         this.startResultScreenTimer();
         this.m_select_mc.visible = false;
         this.m_choices_mc.visible = true;
         this.m_choice1_mc.gotoAndStop(this.m_playercurrentChoice);
         this.m_choice2_mc.gotoAndStop(this.m_opponentChoice);
         this.m_choices_mc.play();
         var turnScore:int = this.getResult(this.m_playercurrentChoice,this.m_opponentChoice);
         this.m_winner_tf.visible = true;
         if(turnScore > 0)
         {
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"turn_resuslt","win",this.m_gameId);
            this.m_highlight1_mc.visible = true;
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : You Win";
            (this.m_playerCounterArray[this.m_playerTurnCount - 1] as MovieClip).gotoAndStop(2);
         }
         else if(turnScore < 0)
         {
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"turn_resuslt","lose",this.m_gameId);
            this.m_highlight2_mc.visible = true;
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : Opponent Win";
            (this.m_playerCounterArray[this.m_playerTurnCount - 1] as MovieClip).gotoAndStop(3);
         }
         else
         {
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"turn_resuslt","draw",this.m_gameId);
            this.m_winner_tf.text = "Round " + this.m_playerTurnCount.toString() + " : It\'s a Draw";
            (this.m_playerCounterArray[this.m_playerTurnCount - 1] as MovieClip).gotoAndStop(4);
         }
         this.m_playerScore += turnScore;
      }
      
      public function disableUserChoices() : void
      {
         for(var buttonIndex:int = 1; buttonIndex <= 3; buttonIndex++)
         {
            this.m_selectButtonArray[buttonIndex].enabled = false;
            this.m_selectButtonArray[buttonIndex].visible = false;
         }
         this.m_countdownTimer.visible = false;
         this.m_selectText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_choiceSelectedText");
      }
      
      public function enableUserChoices() : void
      {
         for(var buttonIndex:int = 1; buttonIndex <= 3; buttonIndex++)
         {
            this.m_selectButtonArray[buttonIndex].enabled = true;
            this.m_selectButtonArray[buttonIndex].visible = true;
            this.m_checkMarkArray[buttonIndex].visible = false;
         }
         this.m_countdownTimer.visible = true;
         this.m_selectText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindow_choiceText");
      }
      
      public function getResult(playerChoice:Number, opponentChoice:Number) : int
      {
         var result:int = DRAW;
         if(playerChoice == opponentChoice)
         {
            result = DRAW;
         }
         else if(playerChoice == NO_CHOICE)
         {
            result = LOOSE;
         }
         else if(opponentChoice == NO_CHOICE)
         {
            result = WIN;
         }
         else if(playerChoice == PAPER)
         {
            if(opponentChoice == ROCK)
            {
               result = WIN;
            }
            if(opponentChoice == SCISSORS)
            {
               result = LOOSE;
            }
         }
         else if(playerChoice == ROCK)
         {
            if(opponentChoice == SCISSORS)
            {
               result = WIN;
            }
            if(opponentChoice == PAPER)
            {
               result = LOOSE;
            }
         }
         else if(playerChoice == SCISSORS)
         {
            if(opponentChoice == PAPER)
            {
               result = WIN;
            }
            if(opponentChoice == ROCK)
            {
               result = LOOSE;
            }
         }
         return result;
      }
      
      private function startResultScreenTimer() : void
      {
         this.m_resultScreenTimerCount = 0;
         this.m_resultScreenTimer = new Timer(1000);
         this.m_resultScreenTimer.addEventListener(TimerEvent.TIMER,this.onResultScreenTimerUpdate);
         this.m_resultScreenTimer.start();
      }
      
      private function onResultScreenTimerUpdate(event:TimerEvent) : void
      {
         this.refreshResultScreenTimerText();
      }
      
      private function refreshResultScreenTimerText() : void
      {
         if(this.m_resultScreenTimerCount > 5)
         {
            this.stopResultScreenTimer();
            if(this.m_gameFinished == false)
            {
               if(this.m_tiebreakerMode)
               {
                  this.startTieBreakerTurn();
               }
               else
               {
                  this.startNextTurn();
               }
            }
         }
         else
         {
            this.m_next_tf.visible = true;
            this.m_seconds_tf.visible = true;
            this.m_clock_mc.visible = true;
            if(this.m_playerTurnCount == 3 && this.m_playerScore == 0)
            {
               this.m_next_tf.text = "Tiebreaker starts in";
               this.m_seconds_tf.text = (5 - this.m_resultScreenTimerCount).toString();
            }
            else if(this.m_tiebreakerMode && this.m_playerScore == 0)
            {
               this.m_next_tf.text = "Next tiebreaker starts in";
               this.m_seconds_tf.text = (5 - this.m_resultScreenTimerCount).toString();
            }
            else if(this.m_playerTurnCount < 3)
            {
               this.m_next_tf.text = "Round " + (this.m_playerTurnCount + 1).toString() + " starts in";
               this.m_seconds_tf.text = (5 - this.m_resultScreenTimerCount).toString();
            }
            else
            {
               this.m_next_tf.visible = false;
               this.m_seconds_tf.visible = false;
               this.m_clock_mc.visible = false;
            }
            ++this.m_resultScreenTimerCount;
         }
      }
      
      private function startNextTurn() : void
      {
         this.m_highlight2_mc.visible = false;
         this.m_highlight1_mc.visible = false;
         this.m_playercurrentChoice = 0;
         this.m_opponentChoice = -1;
         if(this.m_playerTurnCount >= 30)
         {
            this.declareResult();
         }
         if(this.m_playerTurnCount == 3)
         {
            if(this.m_playerScore != 0)
            {
               this.declareResult();
            }
            else
            {
               this.m_score_mc.visible = false;
               this.m_tiebreaker_tf.visible = true;
               this.m_tiebreakerMode = true;
            }
         }
         else
         {
            this.m_choices_mc.visible = false;
            this.m_select_mc.visible = true;
            this.enableUserChoices();
            this.startTurnResponseTimer();
         }
         if(this.m_tiebreakerMode == true)
         {
            this.startTieBreakerTurn();
         }
      }
      
      public function startTieBreakerTurn() : void
      {
         if(this.m_playerTurnCount >= 30)
         {
            this.declareResult();
         }
         if(this.m_playerScore != 0)
         {
            this.declareResult();
         }
         else
         {
            this.m_highlight2_mc.visible = false;
            this.m_highlight1_mc.visible = false;
            this.m_choices_mc.visible = false;
            this.m_select_mc.visible = true;
            this.m_playercurrentChoice = 0;
            this.m_opponentChoice = -1;
            this.enableUserChoices();
            this.startTurnResponseTimer();
         }
      }
      
      public function stopResultScreenTimer() : void
      {
         if(this.m_resultScreenTimer)
         {
            this.m_next_tf.visible = false;
            this.m_seconds_tf.visible = false;
            this.m_clock_mc.visible = false;
            this.m_winner_tf.visible = false;
            this.m_resultScreenTimerCount = 0;
            this.m_resultScreenTimer.stop();
            this.m_resultScreenTimer.removeEventListener(TimerEvent.TIMER,this.onResultScreenTimerUpdate);
            this.m_resultScreenTimer = null;
         }
      }
      
      private function startTurnResponseTimer() : void
      {
         this.m_currentTimeCount = 0;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshTimerText();
      }
      
      public function stopTurnResponseTimer() : void
      {
         if(this.m_timer)
         {
            this.m_currentTimeCount = 0;
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         super.onTutorialOkayButtonClick(event);
         tutorialButtonText = "Next";
         if(tutorialSceneNumber >= totalScenes)
         {
            this.close();
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         var opponentChoice:int = 0;
         var firstName:String = null;
         if(e.data.indexOf("GameMove" + this.m_gameId) != -1)
         {
            opponentChoice = int(e.data.split(":")[1]);
            this.updatePlayer2Response(opponentChoice);
         }
         else if(e.data.indexOf("FirstName" + this.m_gameId) != -1)
         {
            firstName = e.data.split(":")[1];
            this.m_profile2_mc["name_tf"].text = firstName;
            this.m_player2FirstName = firstName;
         }
      }
      
      private function updatePlayer2Response(opponentChoice:int) : void
      {
         this.m_opponentChoice = opponentChoice;
      }
      
      public function switchToSoloMode() : void
      {
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         FarmStatsManager.count("RockPaperShivers_Game","switch_to_solo",this.m_playerTurnCount.toString(),this.m_gameId);
         if(this.m_playerTurnCount == 3 && (this.m_playerScore == 2 || this.m_playerScore == -2))
         {
            this.declareResult();
         }
         else
         {
            this.m_timerText.visible = false;
            this.setOverlayText("Oops! Looks like the connection was lost with your friend!","Continue playing with Miss Mulberry!","Okay",this.reStartGameWithSoloMode);
         }
      }
      
      public function setConnectOverlayText(text1:String, text2:String, buttonText:String = null, callback:Function = null) : void
      {
         if(this.m_connectText1)
         {
            this.m_connectText1.text = text1;
         }
         if(this.m_connectText2)
         {
            this.m_connectText2.text = text2;
         }
         if(buttonText != null && buttonText != "")
         {
            if(this.m_connectOkay_button)
            {
               this.m_connectOkay_button.visible = true;
               this.m_connectOkay_button.enabled = true;
               this.m_connectOkay_button.text = buttonText;
            }
         }
         if(callback is Function)
         {
            if(this.m_connectOkay_button)
            {
               this.m_connectOkay_button.callback = callback;
            }
         }
      }
      
      public function declareResult() : void
      {
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         this.m_winner_tf.visible = false;
         this.m_choices_mc.visible = false;
         this.m_postGameOkay_button.visible = true;
         this.m_postGameOkay_button.text = "Okay";
         this.m_gameFinished = true;
         if(this.m_playerScore > 0)
         {
            this.m_highlight1_mc.visible = true;
            this.m_highlight2_mc.visible = false;
            this.m_win_mc.visible = true;
            this.m_winText1.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostwinTex1");
            this.m_winText2.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostwinTex2");
            this.m_games_tf.text = "Games Won";
            this.m_count_tf.text = (this.manager.getWinCountForReward(this.manager.selectedItemCodeForGame) + 1).toString() + "/" + this.manager.getWinCountGoalForReward(this.manager.selectedItemCodeForGame);
            this.manager.updateWinCountForReward();
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"game_resuslt","win",this.m_gameId);
         }
         else if(this.m_playerScore < 0)
         {
            this.m_highlight1_mc.visible = false;
            this.m_highlight2_mc.visible = true;
            this.m_lost_mc.visible = true;
            this.m_lostText1.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostloseTex1");
            this.m_lostText2.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostloseTex2");
            this.manager.deActivateGameMode();
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"game_resuslt","lose",this.m_gameId);
         }
         else
         {
            this.m_highlight1_mc.visible = false;
            this.m_highlight2_mc.visible = false;
            this.m_lost_mc.visible = true;
            this.m_lostText1.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostloseTex1");
            this.m_lostText2.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_GameWindowPostloseTex2");
            this.manager.deActivateGameMode();
            FarmStatsManager.count("RockPaperShivers_Game",this.m_playerTurnCount.toString(),"game_resuslt","lose",this.m_gameId,"max_round_limit_reached");
         }
         this.m_postGameOkay_button.callback = this.manager.conditionallyOpenPostGamewindows;
      }
      
      public function setOverlayText(text1:String, text2:String, buttonText:String = null, callback:Function = null) : void
      {
         this.m_connect_mc.visible = false;
         this.m_overlay_mc.visible = true;
         if(this.m_overlayText1)
         {
            this.m_overlayText1.text = text1;
         }
         if(this.m_overlayText2)
         {
            this.m_overlayText2.text = text2;
         }
         if(buttonText != null && buttonText != "")
         {
            if(this.m_overlayOkay_button)
            {
               this.m_overlayOkay_button.visible = true;
               this.m_overlayOkay_button.enabled = true;
               this.m_overlayOkay_button.text = buttonText;
            }
         }
         if(callback is Function)
         {
            if(this.m_overlayOkay_button)
            {
               this.m_overlayOkay_button.callback = callback;
            }
         }
      }
   }
}

