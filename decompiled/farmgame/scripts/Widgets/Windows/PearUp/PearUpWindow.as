package Widgets.Windows.PearUp
{
   import Classes.Minigames.CardMatchingGameFeatureData;
   import Classes.Minigames.MinigameConstants;
   import Classes.Minigames.MinigameData;
   import Classes.Minigames.TokenPlayFeatureData;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Replay.ArrayUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.PearUpCardSlot;
   import Widgets.Windows.Minigame.MinigameWindow;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class PearUpWindow extends MinigameWindow
   {
      
      private static const SND_ID_CARD_CLICK:String = "pearup_card_click";
      
      private static const SND_ASSET_CARD_CLICK:String = "assets/sounds/minigames/pearup/sfx_card_click.mp3";
      
      private static const SND_ID_CLOCK_ENDING:String = "pearup_clock_end";
      
      private static const SND_ASSET_CLOCK_ENDING:String = "assets/sounds/minigames/pearup/sfx_clock_ending.mp3";
      
      private static const SND_ID_MATCH_CORRECT:String = "pearup_match_c";
      
      private static const SND_ASSET_MATCH_CORRECT:String = "assets/sounds/minigames/pearup/sfx_match_correct.mp3";
      
      private static const SND_ID_MATCH_WRONG:String = "pearup_match_w";
      
      private static const SND_ASSET_MATCH_WRONG:String = "assets/sounds/minigames/pearup/sfx_match_wrong.mp3";
      
      private static const SND_ID_READY_SET_GO:String = "pearup_ready";
      
      private static const SND_ASSET_READY_SET_GO:String = "assets/sounds/minigames/pearup/sfx_ready_set_go.mp3";
      
      private static const SND_ID_START_GAME:String = "pearup_start";
      
      private static const SND_ASSET_START_GAME:String = "assets/sounds/minigames/pearup/sfx_start_game.mp3";
      
      private static const SND_ID_TRY_AGAIN:String = "pearup_try_again";
      
      private static const SND_ASSET_TRY_AGAIN:String = "assets/sounds/minigames/pearup/sfx_try_again.mp3";
      
      private static const SND_ID_YOU_WIN:String = "pearup_you_win";
      
      private static const SND_ASSET_YOU_WIN:String = "assets/sounds/minigames/pearup/sfx_you_win.mp3";
      
      private static const UPDATE_LOOP_DELAY:uint = 10;
      
      private static const TIME_PLAY_HURRY_UP_SOUND:uint = 10;
      
      private static const TOTAL_FRAME_TIMER_BAR:uint = 100;
      
      private static const EXTRA_POINT_IF_SECS_LEFT_GREATER_THAN:uint = 7;
      
      private static const PEEK_ANIM_MIN_START_INDEX:int = -1;
      
      private static const PEEK_TYPE_NORTH_TO_SOUTH:uint = 0;
      
      private static const PEEK_TYPE_SOUTH_TO_NORTH:uint = 1;
      
      private static const PEEK_TYPE_WEST_TO_EAST:uint = 2;
      
      private static const PEEK_TYPE_EAST_TO_WEST:uint = 3;
      
      private static const TOTAL_PEEK_TYPES:uint = 4;
      
      private static const SECONDS_REMAIN_CAN_BUY_POWERUP:Number = 0.25;
      
      private static const PEEK_DELAY_SECONDS:Number = 0.75;
      
      private static const POWERUP_ID_PEEK:String = "peek";
      
      private static const POWERUP_ID_TIME:String = "extratime";
      
      private static const NUM_CARDS_TO_MATCH:uint = 2;
      
      private static const COUNTDOWN_TOTAL:uint = 3;
      
      private var m_firstPlay:Boolean = true;
      
      private var m_introDialogFrame:ZwFrame = null;
      
      private var m_introDialogAnimFrame:ZwFrame = null;
      
      private var m_introAcceptButton:FarmAnimatedTextButton = null;
      
      private var m_introBuyButton:FarmAnimatedCashButton = null;
      
      private var m_gameOverDialogFrame:ZwFrame = null;
      
      private var m_gameOverAcceptButton:FarmAnimatedTextButton = null;
      
      private var m_gameOverBuyButton:FarmAnimatedCashButton = null;
      
      private var m_gameOverMatchesFoundCountTextField:ZwTextField = null;
      
      private var m_gameOverBonusCountTextField:ZwTextField = null;
      
      private var m_gameOverTicketCountTextField:ZwTextField = null;
      
      private var m_gameTimerFrame:ZwFrame = null;
      
      private var m_curGameTimerBar:ZwFrame = null;
      
      private var m_countdownFrame:ZwFrame = null;
      
      private var m_countdownTextFrame:ZwTextField = null;
      
      private var m_gameboardSlotFrame:GenericSlotContainerFrame = null;
      
      private var m_clickedCards:Array = new Array();
      
      private var m_totalMatchesFound:uint = 0;
      
      private var m_peekIndex:int = -1;
      
      private var m_peeksLeft:uint = 0;
      
      private var m_peeksUsed:uint = 0;
      
      private var m_powerupCountExtraTime:uint = 0;
      
      private var m_purchasedPeeks:uint = 0;
      
      private var m_purchasedExtraTime:uint = 0;
      
      private var m_totalRoundTimeInSeconds:Number = 0;
      
      private var m_totalTimeElapsedMSec:int = 0;
      
      private var m_prevTimestamp:int = 0;
      
      private var m_curGameTimeTextField:ZwTextField = null;
      
      private var m_paused:Boolean = true;
      
      private var m_powerupsFrame:ZwFrame = null;
      
      private var m_peekBuyPowerupFrame:BuyPowerupFrame = null;
      
      private var m_timeBuyPowerupFrame:BuyPowerupFrame = null;
      
      private var m_gameUpdateTimer:Timer = null;
      
      private var m_countdownTime:uint = 3;
      
      public function PearUpWindow(minigameData:MinigameData)
      {
         super(minigameData);
         this.initializeSound();
      }
      
      public function isPaused() : Boolean
      {
         return this.m_paused;
      }
      
      public function get cardMatchingGameFeatureData() : CardMatchingGameFeatureData
      {
         return m_minigameData.getFeatureData(MinigameConstants.FEATURE_DATA_KEY_CARD_MATCHING_GAME) as CardMatchingGameFeatureData;
      }
      
      override protected function release() : void
      {
         this.stopBeforeGameCountdown();
         this.stopGameUpdateTimer();
         this.m_introDialogFrame = null;
         this.m_introDialogAnimFrame = null;
         this.m_introAcceptButton = null;
         this.m_introBuyButton = null;
         this.m_gameOverDialogFrame = null;
         this.m_gameOverMatchesFoundCountTextField = null;
         this.m_gameOverBonusCountTextField = null;
         this.m_gameOverTicketCountTextField = null;
         this.m_gameTimerFrame = null;
         this.m_curGameTimerBar = null;
         this.m_gameboardSlotFrame = null;
         this.m_curGameTimeTextField = null;
         this.m_powerupsFrame = null;
         this.m_peekBuyPowerupFrame = null;
         this.m_timeBuyPowerupFrame = null;
         this.m_gameUpdateTimer = null;
         super.release();
      }
      
      override public function close() : void
      {
         this.buildAndSendBuyPowerupsTransaction();
         super.close();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.resetRoundStartTime();
         this.resetPeeksLeft();
         this.initializePowerupFrames();
         this.initializePowerupCounts();
         this.initializeGameTimer();
         this.initializeGameBoard();
         this.initializeIntroWindow();
         this.initializeGameOverWindow();
         this.showIntroWindow();
         this.hideGameTimer();
         this.hidePowerups();
         this.m_paused = true;
      }
      
      private function initializePowerupFrames() : void
      {
         this.m_peekBuyPowerupFrame = this.initializeBuyUsePowerupFrame(0,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyPeekTitle"),this.getPeeksLeftAsString(),ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyPeekHeader"),ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_UsePeekButtonText"),ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyPeekButtonText"),tokenPlayFeatureData.getNumberPowerupValue(POWERUP_ID_PEEK,TokenPlayFeatureData.TAG_CASH_COST).toString(),this.onUsePeekPowerupButton,this.onBuyPeekPowerupButton);
         var powerupTimeAdded:String = tokenPlayFeatureData.getNumberPowerupValue(POWERUP_ID_TIME,TokenPlayFeatureData.TAG_EFFECT).toString();
         this.m_timeBuyPowerupFrame = this.initializeBuyUsePowerupFrame(1,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyTimeTitle"),ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyTimePlusAmount",{"amount":powerupTimeAdded}),ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyTimeHeader",{"amount":powerupTimeAdded}),null,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_BuyTimeButtonText"),tokenPlayFeatureData.getNumberPowerupValue(POWERUP_ID_TIME,TokenPlayFeatureData.TAG_CASH_COST).toString(),null,this.onBuyTimePowerupButton);
      }
      
      private function initializeSound() : void
      {
         SoundManager.addSound(SND_ID_CARD_CLICK,Global.getAssetURL(SND_ASSET_CARD_CLICK),false);
         SoundManager.addSound(SND_ID_CLOCK_ENDING,Global.getAssetURL(SND_ASSET_CLOCK_ENDING),false);
         SoundManager.addSound(SND_ID_MATCH_CORRECT,Global.getAssetURL(SND_ASSET_MATCH_CORRECT),false);
         SoundManager.addSound(SND_ID_MATCH_WRONG,Global.getAssetURL(SND_ASSET_MATCH_WRONG),false);
         SoundManager.addSound(SND_ID_READY_SET_GO,Global.getAssetURL(SND_ASSET_READY_SET_GO),false);
         SoundManager.addSound(SND_ID_START_GAME,Global.getAssetURL(SND_ASSET_START_GAME),false);
         SoundManager.addSound(SND_ID_TRY_AGAIN,Global.getAssetURL(SND_ASSET_TRY_AGAIN),false);
         SoundManager.addSound(SND_ID_YOU_WIN,Global.getAssetURL(SND_ASSET_YOU_WIN),false);
      }
      
      public function playSoundClickCard() : void
      {
         SoundManager.playSound(SND_ID_CARD_CLICK);
      }
      
      private function playSoundClockEnding() : void
      {
         SoundManager.playSound(SND_ID_CLOCK_ENDING);
      }
      
      private function playSoundMatchCorrect() : void
      {
         SoundManager.playSound(SND_ID_MATCH_CORRECT);
      }
      
      private function playSoundMatchWrong() : void
      {
         SoundManager.playSound(SND_ID_MATCH_WRONG);
      }
      
      private function playSoundReadySetGo() : void
      {
         SoundManager.playSound(SND_ID_READY_SET_GO);
      }
      
      private function playSoundStartGame() : void
      {
         SoundManager.playSound(SND_ID_START_GAME);
      }
      
      private function playSoundTryAgain() : void
      {
         SoundManager.playSound(SND_ID_TRY_AGAIN);
      }
      
      private function playSoundYouWin() : void
      {
         SoundManager.playSound(SND_ID_YOU_WIN);
      }
      
      override public function set redeemPrizesLocked(setTo:Boolean) : void
      {
         super.redeemPrizesLocked = false;
      }
      
      override public function get redeemPrizesLocked() : Boolean
      {
         return false;
      }
      
      private function startGameUpdateTimer() : void
      {
         if(this.m_gameUpdateTimer == null)
         {
            this.m_gameUpdateTimer = new Timer(UPDATE_LOOP_DELAY);
            this.m_gameUpdateTimer.addEventListener(TimerEvent.TIMER,this.onGameUpdateTimer);
            this.m_gameUpdateTimer.start();
            this.m_prevTimestamp = GlobalEngine.currentTime;
         }
      }
      
      private function stopGameUpdateTimer() : void
      {
         if(this.m_gameUpdateTimer)
         {
            this.m_gameUpdateTimer.stop();
            this.m_gameUpdateTimer.removeEventListener(TimerEvent.TIMER,this.onGameUpdateTimer);
            this.m_gameUpdateTimer = null;
         }
      }
      
      protected function onGameUpdateTimer(event:Event) : void
      {
         var curTimestamp:int = GlobalEngine.currentTime;
         var elapsedTimeMSec:int = curTimestamp - this.m_prevTimestamp;
         this.m_prevTimestamp = curTimestamp;
         if(!this.gameplayInterupted())
         {
            this.m_totalTimeElapsedMSec += elapsedTimeMSec;
            this.updateTimeLeftDisplay();
            this.checkForGameOver();
            if(!this.hasEnoughTimeLeftToBuyPowerup())
            {
               this.refreshPowerupButtons();
            }
         }
      }
      
      override public function gameplayInterupted() : Boolean
      {
         var result:Boolean = super.gameplayInterupted();
         return result || this.isPaused();
      }
      
      public function addClickedCard(cardSlot:PearUpCardSlot) : void
      {
         var clickedCardsLen:uint = 0;
         var iCard:uint = 0;
         if(!this.m_paused)
         {
            clickedCardsLen = this.m_clickedCards.length;
            if(clickedCardsLen < NUM_CARDS_TO_MATCH)
            {
               for(iCard = 0; iCard < clickedCardsLen; iCard++)
               {
                  if(this.m_clickedCards[iCard] == cardSlot)
                  {
                     ErrorManager.addError("addClickedCard() Error: card already clicked");
                  }
               }
               this.m_clickedCards.push(cardSlot);
            }
            else
            {
               ErrorManager.addError("addClickedCard() Error: too many cards clicked");
            }
            if(this.m_clickedCards.length == NUM_CARDS_TO_MATCH)
            {
               this.checkForMatch();
            }
         }
      }
      
      public function removeClickedCard(cardSlot:PearUpCardSlot) : void
      {
         var indexToRemove:int = 0;
         if(!this.m_paused)
         {
            if(this.m_clickedCards.length < NUM_CARDS_TO_MATCH)
            {
               indexToRemove = this.m_clickedCards.indexOf(cardSlot);
               if(indexToRemove >= 0)
               {
                  this.m_clickedCards.splice(indexToRemove,1);
               }
            }
         }
      }
      
      private function checkForMatch() : void
      {
         var hasMatch:Boolean = false;
         var clickedCardsLen:uint = 0;
         var firstCardId:uint = 0;
         var iCard:uint = 0;
         if(!this.m_paused)
         {
            hasMatch = false;
            clickedCardsLen = this.m_clickedCards.length;
            if(clickedCardsLen == NUM_CARDS_TO_MATCH)
            {
               firstCardId = uint(this.m_clickedCards[0].getCardId());
               for(iCard = 1; iCard < clickedCardsLen; iCard++)
               {
                  if(this.m_clickedCards[iCard].getCardId() != firstCardId)
                  {
                     break;
                  }
                  if(iCard == clickedCardsLen - 1)
                  {
                     hasMatch = true;
                  }
               }
               if(hasMatch)
               {
                  this.clearClickedCards(true);
                  ++this.m_totalMatchesFound;
                  this.playSoundMatchCorrect();
                  if(this.m_totalMatchesFound == this.maxNumberPossibleMatches())
                  {
                     this.showGameOverWindow();
                  }
               }
               else
               {
                  this.clearClickedCards(false);
                  this.playSoundMatchWrong();
               }
            }
         }
      }
      
      private function maxNumberPossibleMatches() : uint
      {
         var result:uint = 0;
         var boardsizeX:Number = this.cardMatchingGameFeatureData.boardsize.x;
         var boardsizeY:Number = this.cardMatchingGameFeatureData.boardsize.y;
         return uint(Math.floor(boardsizeX * boardsizeY / NUM_CARDS_TO_MATCH));
      }
      
      private function clearClickedCards(isMatch:Boolean = false, animate:Boolean = true) : void
      {
         var tmpCardSlot:PearUpCardSlot = null;
         while(this.m_clickedCards.length > 0)
         {
            tmpCardSlot = this.m_clickedCards.pop();
            if(isMatch)
            {
               this.match(tmpCardSlot);
            }
            else
            {
               this.noMatch(tmpCardSlot,animate);
            }
         }
      }
      
      private function match(cardSlot:PearUpCardSlot) : void
      {
         if(!this.m_paused)
         {
            cardSlot.match();
         }
      }
      
      private function noMatch(cardSlot:PearUpCardSlot, animate:Boolean) : void
      {
         if(!this.m_paused)
         {
            cardSlot.noMatch(animate);
         }
      }
      
      private function initializeGameBoard() : void
      {
         if(m_window.countdown_mc)
         {
            addWidget(this.m_countdownFrame = new ZwFrame(m_window.countdown_mc));
            if(this.m_countdownFrame.element.generic_tf)
            {
               this.m_countdownFrame.addWidget(this.m_countdownTextFrame = new ZwTextField(this.m_countdownFrame.element.generic_tf,"33"));
            }
            this.m_countdownFrame.visible = false;
         }
         if(m_window.slotContainer_mc != null)
         {
            addWidget(this.m_gameboardSlotFrame = new GenericSlotContainerFrame(m_window.slotContainer_mc,PearUpCardSlot,this.createRandomBoardSlotsData(),this));
            this.m_gameboardSlotFrame.visible = true;
         }
      }
      
      private function createRandomBoardSlotsData() : Array
      {
         var cards:Array = new Array();
         var maxMatches:uint = this.maxNumberPossibleMatches();
         var repeatedPairs:uint = 0;
         maxMatches -= repeatedPairs;
         for(var i:uint = 1; i <= maxMatches; i++)
         {
            cards.push({"cardIndex":i});
            cards.push({"cardIndex":i});
            if(i <= repeatedPairs)
            {
               cards.push({"cardIndex":i});
               cards.push({"cardIndex":i});
            }
         }
         ArrayUtils.shuffle(cards);
         return cards;
      }
      
      private function initializeGameTimer() : void
      {
         var tmpZw:ZwWidget = null;
         var tmpMeterFrame:ZwFrame = null;
         if(m_window.gameIntro_mc != null)
         {
            addWidget(this.m_gameTimerFrame = new ZwFrame(m_window.timer_mc));
            tmpZw = null;
            tmpMeterFrame = null;
            if(this.m_gameTimerFrame.element.timer_tf != null)
            {
               this.m_curGameTimeTextField = new ZwTextField(this.m_gameTimerFrame.element.timer_tf,this.getTotalRoundTimeAsString());
               this.m_gameTimerFrame.addWidget(this.m_curGameTimeTextField);
            }
            if(this.m_gameTimerFrame.element.meter_mc != null)
            {
               this.m_curGameTimerBar = new ZwFrame(this.m_gameTimerFrame.element.meter_mc);
               this.m_gameTimerFrame.addWidget(this.m_curGameTimerBar);
            }
         }
      }
      
      protected function showGameTimer() : void
      {
         if(this.m_gameTimerFrame)
         {
            this.m_gameTimerFrame.visible = true;
         }
      }
      
      protected function hideGameTimer() : void
      {
         if(this.m_gameTimerFrame)
         {
            this.m_gameTimerFrame.visible = false;
         }
      }
      
      protected function showPowerups() : void
      {
         if(this.m_powerupsFrame)
         {
            this.m_powerupsFrame.visible = true;
         }
      }
      
      protected function hidePowerups() : void
      {
         if(this.m_powerupsFrame)
         {
            this.m_powerupsFrame.visible = false;
         }
      }
      
      private function refreshPowerupButtons() : void
      {
         this.refreshPeekBuyPowerupFrame();
         this.refreshTimeBuyPowerupFrame();
      }
      
      private function onUsePeekPowerupButton(event:Event = null) : void
      {
         var unPauseFunciton:Function = null;
         if(!this.isPaused())
         {
            if(this.m_peeksLeft > 0)
            {
               --this.m_peeksLeft;
               ++this.m_peeksUsed;
               unPauseFunciton = function():void
               {
                  m_paused = false;
               };
               this.showPeek(unPauseFunciton);
               if(event != null)
               {
                  this.displayPeeksChangeStatusText();
               }
            }
         }
         this.refreshPeekBuyPowerupFrame();
      }
      
      private function displayPowerupButtonStatusText(element:Object, message:String) : void
      {
         var displayPoint:Point = null;
         if(element != null && message != null && message != "")
         {
            displayPoint = new Point(0,0);
            displayPoint = element.localToGlobal(displayPoint);
            UI.displayStatus(message,displayPoint.x,displayPoint.y);
         }
      }
      
      private function displayPeeksChangeStatusText(delta:int = -1) : void
      {
         if(Boolean(delta != 0 && this.m_peekBuyPowerupFrame && this.m_peekBuyPowerupFrame.m_useButton) && Boolean(this.m_peekBuyPowerupFrame.m_useButton.parent) && Boolean(this.m_peekBuyPowerupFrame.m_useButton.parent.element))
         {
            this.displayPowerupButtonStatusText(this.m_peekBuyPowerupFrame.m_useButton.parent.element,this.tokenPlayFeatureData.getPowerupCountChangeText(POWERUP_ID_PEEK,delta));
         }
      }
      
      private function displayPeekBuyStatusText() : void
      {
         if(Boolean(this.m_timeBuyPowerupFrame && this.m_peekBuyPowerupFrame && this.m_peekBuyPowerupFrame.m_useButton) && Boolean(this.m_peekBuyPowerupFrame.m_useButton.parent) && Boolean(this.m_peekBuyPowerupFrame.m_useButton.parent.element))
         {
            this.displayPowerupButtonStatusText(this.m_peekBuyPowerupFrame.m_useButton.parent.element,this.tokenPlayFeatureData.getPowerupCostChangeText(POWERUP_ID_PEEK));
         }
      }
      
      private function displayTimeChangeStatusText(delta:int = -1) : void
      {
         if(Boolean(delta != 0) && Boolean(this.m_curGameTimeTextField) && Boolean(this.m_curGameTimeTextField.element))
         {
            this.displayPowerupButtonStatusText(this.m_curGameTimeTextField.element,this.tokenPlayFeatureData.getPowerupCountChangeText(POWERUP_ID_TIME,delta));
         }
      }
      
      private function displayExtraTimeBuyStatusText() : void
      {
         if(Boolean(this.m_timeBuyPowerupFrame && this.m_timeBuyPowerupFrame.m_buyButton) && Boolean(this.m_timeBuyPowerupFrame.m_buyButton.parent) && Boolean(this.m_timeBuyPowerupFrame.m_buyButton.parent.element))
         {
            this.displayPowerupButtonStatusText(this.m_timeBuyPowerupFrame.m_buyButton.parent.element,this.tokenPlayFeatureData.getPowerupCostChangeText(POWERUP_ID_TIME));
         }
      }
      
      private function initializeIntroWindow() : void
      {
         if(m_window.gameIntro_mc != null)
         {
            addWidget(this.m_introDialogFrame = new ZwFrame(m_window.gameIntro_mc));
            if(this.m_introDialogFrame.element.accept_bt != null)
            {
               this.m_introDialogFrame.addWidget(this.m_introAcceptButton = new FarmAnimatedTextButton(this.m_introDialogFrame.element.accept_bt,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_IntroAcceptButton"),this.onIntroAcceptButton));
            }
            if(this.m_introDialogFrame.element.buy_bt != null)
            {
               this.m_introDialogFrame.addWidget(this.m_introBuyButton = new FarmAnimatedCashButton(this.m_introDialogFrame.element.buy_bt,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_IntroBuyButton"),getTokenCost().toString(),this.onIntroAcceptButton));
            }
            if(this.m_introDialogFrame.element.copy_tf != null)
            {
               this.m_introDialogFrame.addWidget(new ZwTextField(this.m_introDialogFrame.element.copy_tf,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_IntroTitle")));
            }
            if(this.m_introDialogFrame.element.header_mc != null)
            {
               this.m_introDialogFrame.addWidget(new ZwTextField(this.m_introDialogFrame.element.header_mc,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_IntroHeader")));
            }
            this.initializeIntroWindowPrize(0);
            this.initializeIntroWindowPrize(1);
            this.initializeIntroWindowPrize(2);
            if(this.m_introDialogFrame.element.animation_mc != null)
            {
               this.m_introDialogFrame.addWidget(this.m_introDialogAnimFrame = new ZwFrame(this.m_introDialogFrame.element.animation_mc));
            }
            if(this.m_introDialogFrame.element.ray2 != null)
            {
               this.m_introDialogFrame.addWidget(new ZwFrame(this.m_introDialogFrame.element.ray2));
            }
            if(this.m_introDialogFrame.element.ray1 != null)
            {
               this.m_introDialogFrame.addWidget(new ZwFrame(this.m_introDialogFrame.element.ray1));
            }
            if(this.m_introDialogFrame.element.back_mc != null)
            {
               this.m_introDialogFrame.addWidget(new ZwFrame(this.m_introDialogFrame.element.back_mc));
            }
            this.m_introDialogFrame.visible = false;
         }
      }
      
      private function showIntroWindow() : void
      {
         var curHasTokens:Boolean = false;
         var statsText:String = null;
         if(this.m_introDialogFrame)
         {
            this.m_introDialogFrame.visible = true;
            if(this.m_introDialogAnimFrame)
            {
               this.m_introDialogAnimFrame.element.gotoAndPlay(1);
            }
            curHasTokens = hasTokens();
            this.m_introAcceptButton.visible = curHasTokens;
            this.m_introBuyButton.visible = !curHasTokens;
            statsText = freeTokens > 0 ? "free_play" : "paid_play";
            if(!curHasTokens)
            {
               statsText = "paid_buy";
            }
            StatsManager.count(getGameStatCounterName(),"dialog_intro","impression_" + statsText);
         }
      }
      
      private function initializeIntroWindowPrize(index:uint) : void
      {
         var spotlightPrize:Object = null;
         var tmpPrizeMC:MovieClip = null;
         var tmpPrizeFrame:ZwFrame = null;
         var redeemData:Array = getRedeemData();
         var tmpIcon:FarmIcon = null;
         if(redeemData.length > index)
         {
            spotlightPrize = redeemablesFeatureData.getRewardSpotlight(index);
            if(spotlightPrize != null)
            {
               if(this.m_introDialogFrame.element["prize_" + index + "_mc"] != null)
               {
                  tmpPrizeMC = this.m_introDialogFrame.element["prize_" + index + "_mc"];
                  tmpPrizeFrame = new ZwFrame(tmpPrizeMC);
                  this.m_introDialogFrame.addWidget(tmpPrizeFrame);
                  if(tmpPrizeMC.icon_mc != null)
                  {
                     tmpPrizeFrame.addWidget(tmpIcon = new FarmIcon(tmpPrizeMC.icon_mc,spotlightPrize.icon));
                     tmpIcon.setSmoothing(true);
                  }
                  if(tmpPrizeMC.name_tf != null)
                  {
                     tmpPrizeFrame.addWidget(new ZwTextField(tmpPrizeMC.name_tf,spotlightPrize.title));
                  }
               }
            }
            else
            {
               ErrorManager.addError("initializeIntroWindowPrize() No spotlight prize found for index " + index);
            }
         }
      }
      
      private function onIntroAcceptButton(event:Event) : void
      {
         this.executeOnPlayButton("dialog_intro");
      }
      
      private function executeOnPlayButton(dialogNameForStats:String) : void
      {
         var statsText:String = null;
         var startedWithTokens:Boolean = hasTokens();
         buyToken(!this.m_firstPlay);
         if(hasTokens())
         {
            statsText = freeTokens > 0 ? "free_play" : "paid_play";
            if(!startedWithTokens)
            {
               statsText = "paid_buy";
            }
            StatsManager.count(getGameStatCounterName(),dialogNameForStats,"click_" + statsText);
            this.m_firstPlay = false;
            this.m_introDialogFrame.visible = false;
            this.startBeforeGamePeek();
         }
      }
      
      private function initializeGameOverWindow() : void
      {
         var tmpZw:ZwWidget = null;
         if(m_window.gameOver_mc != null)
         {
            tmpZw = null;
            addWidget(this.m_gameOverDialogFrame = new ZwFrame(m_window.gameOver_mc));
            if(this.m_gameOverDialogFrame.element.header_tf != null)
            {
               this.m_gameOverDialogFrame.addWidget(new ZwTextField(this.m_gameOverDialogFrame.element.header_tf,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverTitle")));
            }
            if(this.m_gameOverDialogFrame.element.pairsCopy_tf != null)
            {
               this.m_gameOverDialogFrame.addWidget(new ZwTextField(this.m_gameOverDialogFrame.element.pairsCopy_tf,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverPairsFound")));
            }
            if(this.m_gameOverDialogFrame.element.completeCopy_tf != null)
            {
               this.m_gameOverDialogFrame.addWidget(new ZwTextField(this.m_gameOverDialogFrame.element.completeCopy_tf,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverCompleteBonus")));
            }
            if(this.m_gameOverDialogFrame.element.pairsCopy2_tf != null)
            {
               this.m_gameOverDialogFrame.addWidget(new ZwTextField(this.m_gameOverDialogFrame.element.pairsCopy2_tf,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverTicketsWon")));
            }
            if(this.m_gameOverDialogFrame.element.pairs_tf != null)
            {
               this.m_gameOverMatchesFoundCountTextField = new ZwTextField(this.m_gameOverDialogFrame.element.pairs_tf,"xx");
               this.m_gameOverDialogFrame.addWidget(this.m_gameOverMatchesFoundCountTextField);
            }
            if(this.m_gameOverDialogFrame.element.complete_tf != null)
            {
               this.m_gameOverBonusCountTextField = new ZwTextField(this.m_gameOverDialogFrame.element.complete_tf,"yy");
               this.m_gameOverDialogFrame.addWidget(this.m_gameOverBonusCountTextField);
            }
            if(this.m_gameOverDialogFrame.element.count_tf != null)
            {
               this.m_gameOverTicketCountTextField = new ZwTextField(this.m_gameOverDialogFrame.element.count_tf,"zz");
               this.m_gameOverDialogFrame.addWidget(this.m_gameOverTicketCountTextField);
            }
            if(this.m_gameOverDialogFrame.element.accept_bt != null)
            {
               this.m_gameOverDialogFrame.addWidget(this.m_gameOverAcceptButton = new FarmAnimatedTextButton(this.m_gameOverDialogFrame.element.accept_bt,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverAcceptButton"),this.onGameOverAcceptButton));
            }
            if(this.m_gameOverDialogFrame.element.buy_bt != null)
            {
               this.m_gameOverDialogFrame.addWidget(this.m_gameOverBuyButton = new FarmAnimatedCashButton(this.m_gameOverDialogFrame.element.buy_bt,ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverAcceptButton"),getTokenCost().toString(),this.onGameOverAcceptButton));
            }
            if(this.m_gameOverDialogFrame.element.back_mc != null)
            {
               this.m_gameOverDialogFrame.addWidget(new ZwFrame(this.m_gameOverDialogFrame.element.back_mc));
            }
            this.m_gameOverDialogFrame.visible = false;
         }
      }
      
      private function checkForGameOver() : void
      {
         if(this.m_totalTimeElapsedMSec > this.m_totalRoundTimeInSeconds * FarmGameUtil.NUM_MSECS_IN_SECOND)
         {
            this.showGameOverWindow();
         }
      }
      
      private function showGameOverWindow() : void
      {
         var cardsLeft:uint = 0;
         var curHasTokens:Boolean = false;
         setCloseButtonVisible(true);
         this.m_paused = true;
         this.stopGameUpdateTimer();
         showRedeemables();
         showTicketsCounterFrame();
         this.hideGameTimer();
         this.hidePowerups();
         var statsText:String = freeTokens > 0 ? "free_play" : "paid_play";
         if(this.m_peeksUsed > 0)
         {
            StatsManager.count(getGameStatCounterName(),statsText,"used_" + POWERUP_ID_PEEK,this.m_peeksUsed.toString());
         }
         if(this.m_peeksLeft > 0)
         {
            StatsManager.count(getGameStatCounterName(),statsText,"unused_" + POWERUP_ID_PEEK,this.m_peeksLeft.toString());
         }
         var maxMatches:uint = this.maxNumberPossibleMatches();
         var didWin:Boolean = this.m_totalMatchesFound == maxMatches;
         var score:uint = this.m_totalMatchesFound;
         var timeLeftSec:Number = this.getCurrentTimeLeftInSeconds();
         if(score == maxMatches && timeLeftSec >= EXTRA_POINT_IF_SECS_LEFT_GREATER_THAN)
         {
            score++;
         }
         if(didWin)
         {
            StatsManager.count(getGameStatCounterName(),statsText,"finished_board","time_left",timeLeftSec.toString());
            StatsManager.count(getGameStatCounterName(),statsText,"finished_board","score",score.toString());
            this.playSoundYouWin();
         }
         else
         {
            cardsLeft = (maxMatches - this.m_totalMatchesFound) * NUM_CARDS_TO_MATCH;
            StatsManager.count(getGameStatCounterName(),statsText,"no_finished_board","cards_left",cardsLeft.toString());
            StatsManager.count(getGameStatCounterName(),statsText,"no_finished_board","score",score.toString());
            this.playSoundTryAgain();
         }
         var ticketsGained:uint = useToken(didWin,score,this.buildUsePowerupsTransactionArray());
         if(this.m_gameOverDialogFrame)
         {
            if(this.m_gameOverMatchesFoundCountTextField != null)
            {
               this.m_gameOverMatchesFoundCountTextField.text = this.m_totalMatchesFound.toString();
            }
            if(this.m_gameOverTicketCountTextField != null)
            {
               this.m_gameOverTicketCountTextField.text = ticketsGained.toString();
            }
            if(this.m_gameOverDialogFrame.element.header_tf != null)
            {
               if(didWin)
               {
                  this.m_gameOverDialogFrame.element.header_tf.text = ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverWinTitle");
               }
               else
               {
                  this.m_gameOverDialogFrame.element.header_tf.text = ZLocUtils.t("Dialogs",m_minigameData.zlocPrefix + "_GameOverLoseTitle");
               }
            }
            curHasTokens = hasTokens();
            this.m_gameOverAcceptButton.visible = curHasTokens;
            this.m_gameOverBuyButton.visible = !curHasTokens;
            this.m_gameOverDialogFrame.visible = true;
            statsText = freeTokens > 0 ? "free_play" : "paid_play";
            if(!curHasTokens)
            {
               statsText = "paid_buy";
            }
            StatsManager.count(getGameStatCounterName(),"dialog_gameover","impression_" + statsText);
         }
      }
      
      private function onGameOverAcceptButton(event:Event) : void
      {
         if(this.m_gameOverDialogFrame)
         {
            this.m_gameOverDialogFrame.visible = false;
         }
         this.resetGame();
         this.executeOnPlayButton("dialog_gameover");
      }
      
      private function getTotalRoundTimeAsString() : String
      {
         return this.m_totalRoundTimeInSeconds.toString();
      }
      
      private function getCurrentTimeLeftAsString() : String
      {
         var timeLeftSec:Number = this.getCurrentTimeLeftInSeconds();
         var timeArray:Array = FarmGameUtil.parseTimeLeft(timeLeftSec);
         var result:String = null;
         if(timeArray[2] > 0)
         {
            result = timeArray[2] + ":" + FarmGameUtil.numberToStringPadZeros(timeArray[3]);
         }
         else
         {
            result = timeArray[3];
         }
         return result;
      }
      
      private function getCurrentTimeLeftInSeconds() : uint
      {
         var elapsedSec:Number = Math.ceil(this.m_totalTimeElapsedMSec / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var timeLeftSec:Number = this.m_totalRoundTimeInSeconds - elapsedSec;
         if(timeLeftSec < 0)
         {
            timeLeftSec = 0;
         }
         return timeLeftSec;
      }
      
      private function getCurrentTimeLeftAsPercent() : Number
      {
         var maxTimeMSec:Number = this.m_totalRoundTimeInSeconds * FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeLeftMSec:Number = maxTimeMSec - this.m_totalTimeElapsedMSec;
         if(timeLeftMSec < 0)
         {
            timeLeftMSec = 0;
         }
         return timeLeftMSec / maxTimeMSec * 100;
      }
      
      private function resetRoundStartTime() : void
      {
         this.m_powerupCountExtraTime = 0;
         this.m_purchasedExtraTime = 0;
         this.m_totalRoundTimeInSeconds = this.cardMatchingGameFeatureData.maxGameTimeInSeconds;
         this.m_totalTimeElapsedMSec = 0;
      }
      
      private function addRoundStartTime(seconds:Number) : void
      {
         this.m_totalRoundTimeInSeconds += seconds;
      }
      
      private function updateTimeLeftDisplay() : void
      {
         var newText:String = this.getCurrentTimeLeftAsString();
         if(this.m_curGameTimeTextField.text != newText)
         {
            this.m_curGameTimeTextField.text = this.getCurrentTimeLeftAsString();
            if(this.getCurrentTimeLeftInSeconds() <= TIME_PLAY_HURRY_UP_SOUND)
            {
               this.playSoundClockEnding();
            }
         }
         (this.m_curGameTimerBar.element as MovieClip).gotoAndStop(TOTAL_FRAME_TIMER_BAR - Math.floor(this.getCurrentTimeLeftAsPercent()));
      }
      
      private function getPeeksLeftAsString() : String
      {
         return this.m_peeksLeft.toString();
      }
      
      private function resetPeeksLeft() : void
      {
         this.m_purchasedPeeks = 0;
         this.m_peeksLeft = 0;
         this.m_peeksUsed = 0;
         this.refreshPeekBuyPowerupFrame();
      }
      
      private function initializePowerupCounts() : void
      {
         this.m_peeksLeft = getCurrentPowerupCount(POWERUP_ID_PEEK);
         this.m_powerupCountExtraTime = getCurrentPowerupCount(POWERUP_ID_TIME);
         if(this.m_powerupCountExtraTime > 0)
         {
            this.addRoundStartTime(this.m_powerupCountExtraTime * tokenPlayFeatureData.getNumberPowerupValue(POWERUP_ID_TIME,TokenPlayFeatureData.TAG_EFFECT));
         }
         this.refreshPowerupButtons();
      }
      
      private function initializeBuyUsePowerupFrame(index:uint, title:String, amount:String, header:String, useButtonText:String, buyButtonText:String, buyButtonPrice:String, useCallback:Function, buyCallback:Function) : BuyPowerupFrame
      {
         var result:BuyPowerupFrame = null;
         if(m_window["powerups_mc"] != null && m_window["powerups_mc"]["powerup_" + index + "_bt"] != null)
         {
            if(this.m_powerupsFrame == null)
            {
               this.m_powerupsFrame = new ZwFrame(m_window["powerups_mc"]);
               addWidget(this.m_powerupsFrame);
            }
            result = new BuyPowerupFrame();
            result.frame = new ZwFrame(this.m_powerupsFrame.element["powerup_" + index + "_bt"]);
            this.m_powerupsFrame.addWidget(result.frame);
            if(buyCallback != null)
            {
               result.m_buyButton = new FarmAnimatedCashButton(result.frame.element.buyAll_bt,buyButtonText,buyButtonPrice,buyCallback);
               result.frame.addWidget(result.m_buyButton);
            }
            if(result.frame.element.use_bt != null && useCallback != null)
            {
               result.m_useButton = new FarmAnimatedTextButton(result.frame.element.use_bt,useButtonText,useCallback);
               result.frame.addWidget(result.m_useButton);
            }
            if(result.frame.element.header_tf != null)
            {
               result.m_titleTextField = new ZwTextField(result.frame.element.header_tf,title);
               result.frame.addWidget(result.m_titleTextField);
            }
            if(result.frame.element.value_tf != null)
            {
               result.m_amountTextField = new ZwTextField(result.frame.element.value_tf,amount);
               result.frame.addWidget(result.m_amountTextField);
            }
            if(result.frame.element.subheader_tf != null)
            {
               result.m_headerTextField = new ZwTextField(result.frame.element.subheader_tf,header);
               result.frame.addWidget(result.m_headerTextField);
            }
         }
         return result;
      }
      
      private function hasEnoughTimeLeftToBuyPowerup() : Boolean
      {
         return this.getCurrentTimeLeftInSeconds() > SECONDS_REMAIN_CAN_BUY_POWERUP;
      }
      
      private function onBuyPeekPowerupButton(event:Event) : void
      {
         var statsText:String = null;
         if(this.hasEnoughTimeLeftToBuyPowerup())
         {
            if(buyPowerupTokenClientSide(POWERUP_ID_PEEK))
            {
               ++this.m_peeksLeft;
               ++this.m_purchasedPeeks;
               this.buildAndSendBuyPowerupsTransaction();
               statsText = freeTokens > 0 ? "free_play" : "paid_play";
               StatsManager.count(getGameStatCounterName(),statsText,"buy_" + POWERUP_ID_PEEK);
               this.displayPeekBuyStatusText();
               this.onUsePeekPowerupButton();
            }
         }
      }
      
      private function refreshPeekBuyPowerupFrame() : void
      {
         if(this.m_peekBuyPowerupFrame)
         {
            this.m_peekBuyPowerupFrame.m_amountTextField.text = this.getPeeksLeftAsString();
            if(this.m_peeksLeft > 0)
            {
               this.m_peekBuyPowerupFrame.showUseButton();
               this.m_peekBuyPowerupFrame.m_amountTextField.visible = true;
            }
            else
            {
               this.m_peekBuyPowerupFrame.showBuyButton();
               this.m_peekBuyPowerupFrame.m_amountTextField.visible = false;
            }
            if(!this.hasEnoughTimeLeftToBuyPowerup())
            {
               this.m_peekBuyPowerupFrame.disableButtons();
            }
         }
      }
      
      private function onBuyTimePowerupButton(event:Event) : void
      {
         var statsText:String = null;
         var secsAdd:Number = NaN;
         if(this.hasEnoughTimeLeftToBuyPowerup())
         {
            if(buyPowerupTokenClientSide(POWERUP_ID_TIME))
            {
               ++this.m_powerupCountExtraTime;
               ++this.m_purchasedExtraTime;
               statsText = freeTokens > 0 ? "free_play" : "paid_play";
               StatsManager.count(getGameStatCounterName(),statsText,"buy_" + POWERUP_ID_TIME);
               this.buildAndSendBuyPowerupsTransaction();
               secsAdd = tokenPlayFeatureData.getNumberPowerupValue(POWERUP_ID_TIME,TokenPlayFeatureData.TAG_EFFECT);
               this.displayExtraTimeBuyStatusText();
               this.displayTimeChangeStatusText(secsAdd);
               this.addRoundStartTime(secsAdd);
               this.updateTimeLeftDisplay();
               this.refreshTimeBuyPowerupFrame();
            }
         }
      }
      
      private function refreshTimeBuyPowerupFrame() : void
      {
         if(this.m_timeBuyPowerupFrame)
         {
            this.m_timeBuyPowerupFrame.showBuyButton();
            if(!this.hasEnoughTimeLeftToBuyPowerup())
            {
               this.m_timeBuyPowerupFrame.disableButtons();
            }
         }
      }
      
      private function buildAndSendBuyPowerupsTransaction() : void
      {
         var powerupsArray:Array = null;
         if(this.m_purchasedPeeks > 0 || this.m_purchasedExtraTime > 0)
         {
            powerupsArray = new Array();
            if(this.m_purchasedExtraTime > 0)
            {
               powerupsArray.push(POWERUP_ID_TIME + ":" + this.m_purchasedExtraTime);
            }
            if(this.m_purchasedPeeks > 0)
            {
               powerupsArray.push(POWERUP_ID_PEEK + ":" + this.m_purchasedPeeks);
            }
            sendBuyPowerupTokensTransaction(powerupsArray);
            this.m_purchasedExtraTime = 0;
            this.m_purchasedPeeks = 0;
         }
      }
      
      private function buildUsePowerupsTransactionArray() : Dictionary
      {
         var powerupsArray:Dictionary = null;
         if(this.m_peeksUsed > 0 || this.m_powerupCountExtraTime > 0)
         {
            powerupsArray = new Dictionary();
            if(this.m_powerupCountExtraTime > 0)
            {
               powerupsArray[POWERUP_ID_TIME] = this.m_powerupCountExtraTime;
            }
            if(this.m_peeksUsed > 0)
            {
               powerupsArray[POWERUP_ID_PEEK] = this.m_peeksUsed;
            }
            this.m_peeksUsed = 0;
            this.m_powerupCountExtraTime = 0;
         }
         return powerupsArray;
      }
      
      private function prepForStartGame() : void
      {
         this.buildAndSendBuyPowerupsTransaction();
         hideRedeemables();
         hideTicketsCounterFrame();
         this.showGameTimer();
         this.showPowerups();
         this.refreshPowerupButtons();
         this.updateTimeLeftDisplay();
         setCloseButtonVisible(false);
      }
      
      private function startGame() : void
      {
         this.m_paused = false;
         this.startGameUpdateTimer();
         this.playSoundStartGame();
      }
      
      private function resetGame() : void
      {
         while(this.m_clickedCards.length > 0)
         {
            this.m_clickedCards.pop();
         }
         this.m_gameboardSlotFrame.setData(this.createRandomBoardSlotsData());
         this.m_totalMatchesFound = 0;
         this.resetRoundStartTime();
         this.resetPeeksLeft();
      }
      
      private function showPeek(doneCallback:Function) : void
      {
         this.clearClickedCards(false,false);
         this.m_paused = true;
         var type:uint = Math.floor(Math.random() * TOTAL_PEEK_TYPES);
         switch(type)
         {
            case PEEK_TYPE_NORTH_TO_SOUTH:
               this.m_peekIndex = PEEK_ANIM_MIN_START_INDEX;
               this.showPeekNorthToSouth(doneCallback);
               break;
            case PEEK_TYPE_SOUTH_TO_NORTH:
               this.m_peekIndex = this.cardMatchingGameFeatureData.boardsize.y;
               this.showPeekSouthToNorth(doneCallback);
               break;
            case PEEK_TYPE_WEST_TO_EAST:
               this.m_peekIndex = PEEK_ANIM_MIN_START_INDEX;
               this.showPeekWestToEast(doneCallback);
               break;
            case PEEK_TYPE_EAST_TO_WEST:
               this.m_peekIndex = this.cardMatchingGameFeatureData.boardsize.x;
               this.showPeekEastToWest(doneCallback);
         }
      }
      
      private function showPeekWestToEast(doneCallback:Function, allowSound:Boolean = true) : void
      {
         var soundTriggered:Boolean = false;
         if(this.m_peekIndex >= 0)
         {
            this.setPeekColumnCards(false);
            soundTriggered = true;
         }
         ++this.m_peekIndex;
         if(this.m_peekIndex < this.cardMatchingGameFeatureData.boardsize.x)
         {
            if(this.setPeekColumnCards(true) > 0)
            {
               soundTriggered = true;
               TweenLite.delayedCall(PEEK_DELAY_SECONDS,this.showPeekWestToEast,[doneCallback]);
            }
            else
            {
               this.showPeekWestToEast(doneCallback,!soundTriggered && allowSound);
            }
         }
         else if(doneCallback != null)
         {
            doneCallback();
         }
         if(soundTriggered && allowSound)
         {
            this.playSoundClickCard();
         }
      }
      
      private function showPeekEastToWest(doneCallback:Function, allowSound:Boolean = true) : void
      {
         var soundTriggered:Boolean = false;
         if(this.m_peekIndex < this.cardMatchingGameFeatureData.boardsize.x)
         {
            this.setPeekColumnCards(false);
            soundTriggered = true;
         }
         --this.m_peekIndex;
         if(this.m_peekIndex >= 0)
         {
            if(this.setPeekColumnCards(true) > 0)
            {
               soundTriggered = true;
               TweenLite.delayedCall(PEEK_DELAY_SECONDS,this.showPeekEastToWest,[doneCallback]);
            }
            else
            {
               this.showPeekEastToWest(doneCallback,!soundTriggered && allowSound);
            }
         }
         else if(doneCallback != null)
         {
            doneCallback();
         }
         if(soundTriggered && allowSound)
         {
            this.playSoundClickCard();
         }
      }
      
      private function setPeekColumnCards(show:Boolean) : uint
      {
         var totalCards:uint = 0;
         var tmpCardSlot:PearUpCardSlot = null;
         var boardsizeX:Number = NaN;
         var boardsizeY:Number = NaN;
         var firstInCol:uint = 0;
         var lastInCol:uint = 0;
         var peekableCard:Boolean = false;
         var cardIndex:uint = 0;
         var peekCardCount:uint = 0;
         if(this.m_gameboardSlotFrame)
         {
            totalCards = this.m_gameboardSlotFrame.totalSlots();
            tmpCardSlot = null;
            boardsizeX = this.cardMatchingGameFeatureData.boardsize.x;
            boardsizeY = this.cardMatchingGameFeatureData.boardsize.y;
            firstInCol = uint(this.m_peekIndex);
            lastInCol = firstInCol + boardsizeX * (boardsizeY - 1);
            peekableCard = false;
            cardIndex = firstInCol;
            while(cardIndex < totalCards && cardIndex <= lastInCol)
            {
               if(show)
               {
                  peekableCard = (this.m_gameboardSlotFrame.slots[cardIndex] as PearUpCardSlot).peekFaceUp();
               }
               else
               {
                  peekableCard = (this.m_gameboardSlotFrame.slots[cardIndex] as PearUpCardSlot).peekFaceDown();
               }
               if(peekableCard)
               {
                  peekCardCount++;
               }
               cardIndex += boardsizeX;
            }
         }
         return peekCardCount;
      }
      
      private function showPeekSouthToNorth(doneCallback:Function, allowSound:Boolean = true) : void
      {
         var soundTriggered:Boolean = false;
         if(this.m_peekIndex < this.cardMatchingGameFeatureData.boardsize.y)
         {
            this.setPeekRowCards(false);
            soundTriggered = true;
         }
         --this.m_peekIndex;
         if(this.m_peekIndex >= 0)
         {
            if(this.setPeekRowCards(true))
            {
               soundTriggered = true;
               TweenLite.delayedCall(PEEK_DELAY_SECONDS,this.showPeekSouthToNorth,[doneCallback]);
            }
            else
            {
               this.showPeekSouthToNorth(doneCallback,!soundTriggered && allowSound);
            }
         }
         else if(doneCallback != null)
         {
            doneCallback();
         }
         if(soundTriggered && allowSound)
         {
            this.playSoundClickCard();
         }
      }
      
      private function showPeekNorthToSouth(doneCallback:Function, allowSound:Boolean = true) : void
      {
         var soundTriggered:Boolean = false;
         if(this.m_peekIndex >= 0)
         {
            this.setPeekRowCards(false);
            soundTriggered = true;
         }
         ++this.m_peekIndex;
         if(this.m_peekIndex < this.cardMatchingGameFeatureData.boardsize.y)
         {
            if(this.setPeekRowCards(true) > 0)
            {
               soundTriggered = true;
               TweenLite.delayedCall(PEEK_DELAY_SECONDS,this.showPeekNorthToSouth,[doneCallback]);
            }
            else
            {
               this.showPeekNorthToSouth(doneCallback,!soundTriggered && allowSound);
            }
         }
         else if(doneCallback != null)
         {
            doneCallback();
         }
         if(soundTriggered && allowSound)
         {
            this.playSoundClickCard();
         }
      }
      
      private function setPeekRowCards(show:Boolean) : uint
      {
         var totalCards:uint = 0;
         var tmpCardSlot:PearUpCardSlot = null;
         var boardsizeX:Number = NaN;
         var firstInRow:uint = 0;
         var lastInRow:uint = 0;
         var peekableCard:Boolean = false;
         var cardIndex:uint = 0;
         var peekCardCount:uint = 0;
         if(this.m_gameboardSlotFrame)
         {
            totalCards = this.m_gameboardSlotFrame.totalSlots();
            tmpCardSlot = null;
            boardsizeX = this.cardMatchingGameFeatureData.boardsize.x;
            firstInRow = this.m_peekIndex * boardsizeX;
            lastInRow = firstInRow + boardsizeX;
            peekableCard = false;
            cardIndex = firstInRow;
            while(cardIndex < totalCards && cardIndex < lastInRow)
            {
               if(show)
               {
                  peekableCard = (this.m_gameboardSlotFrame.slots[cardIndex] as PearUpCardSlot).peekFaceUp();
               }
               else
               {
                  peekableCard = (this.m_gameboardSlotFrame.slots[cardIndex] as PearUpCardSlot).peekFaceDown();
               }
               if(peekableCard)
               {
                  peekCardCount++;
               }
               cardIndex++;
            }
         }
         return peekCardCount;
      }
      
      private function startBeforeGamePeek() : void
      {
         this.prepForStartGame();
         this.startBeforeGameCountdown();
      }
      
      private function startBeforeGameCountdown() : void
      {
         var countdownMC:MovieClip = null;
         if(this.m_countdownFrame != null)
         {
            countdownMC = this.m_countdownFrame.element as MovieClip;
            this.m_countdownTime = COUNTDOWN_TOTAL;
            this.updateBeforeGameCountdown();
            this.m_countdownFrame.visible = true;
         }
         else
         {
            this.startGame();
         }
      }
      
      private function updateBeforeGameCountdown() : void
      {
         var countdownMC:MovieClip = null;
         if(this.m_countdownFrame != null)
         {
            countdownMC = this.m_countdownFrame.element as MovieClip;
            if(this.m_countdownTime == 0)
            {
               this.stopBeforeGameCountdown();
               this.startGame();
            }
            else
            {
               countdownMC.scaleX = this.m_countdownTime;
               countdownMC.scaleY = this.m_countdownTime;
               countdownMC.generic_tf.text = String(this.m_countdownTime);
               TweenLite.delayedCall(1,this.updateBeforeGameCountdown);
               --this.m_countdownTime;
               this.playSoundReadySetGo();
            }
         }
      }
      
      private function stopBeforeGameCountdown() : void
      {
         if(this.m_countdownFrame != null)
         {
            this.m_countdownFrame.visible = false;
            TweenLite.killDelayedCallsTo(this.updateBeforeGameCountdown);
         }
      }
   }
}

