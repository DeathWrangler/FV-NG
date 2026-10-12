package Widgets.Windows.Bingo
{
   import Cache.Classes.ZCacheUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.BingoManager;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BingoRewardWindow;
   import Widgets.Windows.FarmWindowWithTutorial;
   import Widgets.Windows.IconToasterWindow;
   import com.greensock.TweenMax;
   import com.greensock.easing.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   
   public class BingoWindow extends FarmWindowWithTutorial
   {
      
      private static const BINGO_WINDOW_ASSET:String = "assets/dialogs/FV_Bingo.swf";
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const BINGO_NUMBER_PREFIX:String = "board_";
      
      private static const BINGO_NUMBER_POSTFIX:String = "_bt";
      
      private static const BINGO_PRIZE_IMAGE_PREFIX:String = "prize_mc_";
      
      private static const BINGO_PRIZE_NAME_PREFIX:String = "prizename_";
      
      private static const BINGO_PRIZE_BUY_PREFIX:String = "buy_";
      
      private static const BINGO_PRIZE_NAME_POSTFIX:String = "_txt";
      
      private static const BINGO_PRIZE_CHECKMARK:String = "prize_checkmark_mc_";
      
      private static const BINGO_STAR_PREFIX:String = "star_animation_";
      
      private static const BINGO_STAMP_IMAGE_PREFIX:String = "stamp_mc_";
      
      private static const STAMP_FRAME:int = 2;
      
      private static const STAMP_DOWN_FRAME:String = "down";
      
      private static const BINGO_B:String = "red";
      
      private static const BINGO_I:String = "blue";
      
      private static const BINGO_N:String = "orange";
      
      private static const BINGO_G:String = "green";
      
      private static const BINGO_O:String = "purple";
      
      private static const BINGO_DEFAULT_BALL:String = "default";
      
      private static const BALL_DELAY_FRAME:String = "delay";
      
      private static const BALL_SUCCESS_FRAME:int = 2;
      
      private static const BALL_LOSE_FRAME:int = 2;
      
      private var m_buyRandomPrice:int = 0;
      
      private var m_buySpecificPrice:int = 0;
      
      private var m_prizeItemToBuy:FarmItem = null;
      
      private var m_remainingPrizesCost:int = 0;
      
      private var m_reset:MovieClip = null;
      
      private var m_resetButton:FarmAnimatedTextButton = null;
      
      private var m_bingoNumberArray:Array = null;
      
      private var m_bingoNumberArrayLength:int = 0;
      
      private var m_ballColour:String = null;
      
      private var m_ballYPosition:int = 0;
      
      private var m_ball:MovieClip = null;
      
      private var m_playButton:FarmAnimatedButton = null;
      
      private var m_askForButton:FarmAnimatedTextButton = null;
      
      private var m_buyRandomNumberButton:FarmAnimatedCashButton = null;
      
      private var m_buySpecificNumberButton:FarmAnimatedCashButton = null;
      
      private var m_buyRemainingPrizesButton:FarmAnimatedCashButton = null;
      
      private var m_ballCountText:ZwTextField = null;
      
      private var m_mouseShow:Boolean = false;
      
      private var m_stamp:MovieClip = null;
      
      private var m_isClickTracked:Boolean = false;
      
      private var m_bingoManager:BingoManager = BingoManager.getInstance();
      
      public function BingoWindow()
      {
         Global.player.setFeatureLastShown(BingoManager.BINGO_FEATURE,GlobalEngine.serverTime,true);
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"dialog","impression",this.m_bingoManager.getNumberOfSuccessfulBallsOnCard().toString(),this.m_bingoManager.getRemainingBallCount().toString());
         this.m_mouseShow = true;
         super(BingoManager.BINGO_FEATURE,BINGO_WINDOW_ASSET,NUM_TUTORIAL_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         var windowBackground:String = null;
         var themeTitle:String = null;
         var ball:ZwFrame = null;
         if(m_window)
         {
            this.m_bingoManager.initializePrizeArrayIfNew();
            windowBackground = BingoManager.getWindowBackground();
            if(windowBackground == null || windowBackground == "")
            {
               windowBackground = BingoManager.BINGO_DEFAULT_WINDOW_BACKGROUND;
            }
            if(Boolean(m_window.scene_mc) && Boolean(windowBackground))
            {
               addWidget(new FarmIcon(m_window.scene_mc,windowBackground));
            }
            this.setupBingoNumbers();
            this.setupPrizes();
            if(m_window.complete_bt)
            {
               this.m_buyRemainingPrizesButton = new FarmAnimatedCashButton(m_window.complete_bt,ZLocUtils.t("Dialogs","Bingo_Complete_Now"),this.m_remainingPrizesCost.toString(),this.onClickCompleteNow);
               addWidget(this.m_buyRemainingPrizesButton);
            }
            if(m_window.whatisthis_mc)
            {
               addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onClickMoreInfo));
            }
            if(m_window.subHead_tf)
            {
               addWidget(new ZwTextField(m_window.subHead_tf,this.getExpiryDateText()));
            }
            if(m_window.buyBall_tf)
            {
               addWidget(new ZwTextField(m_window.buyBall_tf,ZLocUtils.t("Dialogs","Bingo_buyBall_text")));
            }
            if(m_window.theme_mc.theme_tf)
            {
               themeTitle = BingoManager.getTitle().toUpperCase();
               if(themeTitle != null || themeTitle != "")
               {
                  addWidget(new ZwTextField(m_window.theme_mc.theme_tf,themeTitle));
               }
            }
            this.setupBuyButtons();
            if(m_window.askFor_bt)
            {
               this.setupAskForButton();
            }
            if(m_window.spin_bt)
            {
               this.m_playButton = new FarmAnimatedButton(m_window.spin_bt,this.onClickPlay);
               addWidget(this.m_playButton);
               this.updatePlayButton();
            }
            if(m_window.ballRemaing_tf)
            {
               this.m_ballCountText = new ZwTextField(m_window.ballRemaing_tf,"0");
               addWidget(this.m_ballCountText);
               this.updateBallCountText();
            }
            if(m_window.ball_mc)
            {
               this.m_ball = m_window.ball_mc as MovieClip;
               this.m_ball.gotoAndStop(BINGO_DEFAULT_BALL);
               this.m_ballYPosition = this.m_ball.y;
               ball = new ZwFrame(this.m_ball);
               ball.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","Bingo_ball_tooltip")));
               this.updateBallUI();
            }
            this.initializeStamp();
            if(m_window.stamp_mc)
            {
               this.m_stamp = m_window.stamp_mc;
               Utilities.toggleInputOnlySelf(this.m_stamp,false);
               this.m_stamp.visible = false;
            }
            if(this.m_bingoManager.isBingoBuyNumberTransactionInProgress() == true)
            {
               this.m_ballCountText.text = this.m_bingoManager.getBallCount().toString();
               this.m_ball.gotoAndStop(BALL_DELAY_FRAME);
               this.m_ball.visible = true;
               this.m_playButton.enabled = false;
               if(this.m_bingoManager.isUserOverBingoCardLengthWithNextBall() == true)
               {
                  this.updateBuyButtons(false);
               }
               this.m_bingoManager.addEventListener(BingoManager.BUY_RANDOM_NUMBER_EVENT_NAME,this.onFinishBuyRandomNumber);
            }
            this.intializeReset();
            super.postLoadComplete();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"dialog","cancel",this.m_bingoManager.getNumberOfSuccessfulBallsOnCard().toString(),this.m_bingoManager.getRemainingBallCount().toString());
         super.onClose(event);
      }
      
      private function intializeReset() : void
      {
         if(m_window.reset_mc)
         {
            this.m_reset = m_window.reset_mc as MovieClip;
            if(this.m_reset.reset_bt)
            {
               this.m_resetButton = new FarmAnimatedTextButton(m_window.reset_mc.reset_bt,ZLocUtils.t("Dialogs","Bingo_Reset_button"),this.onResetButton);
               addWidget(this.m_resetButton);
            }
            if(this.m_reset.copy_tf)
            {
               addWidget(new ZwTextField(this.m_reset.copy_tf,ZLocUtils.t("Dialogs","Bingo_Reset_message")));
            }
            this.m_reset.visible = this.m_bingoManager.isBoardComplete();
         }
      }
      
      private function setupBingoNumbers() : void
      {
         var numberButton:FarmAnimatedTextButton = null;
         var bingoNumberElement:String = null;
         this.m_bingoNumberArray = BingoManager.getCardNumbers();
         if(this.m_bingoNumberArray == null)
         {
            this.m_bingoNumberArray = BingoManager.BINGO_DEFAULT_CARD_NUMBERS.split(",");
         }
         this.m_bingoNumberArrayLength = this.m_bingoNumberArray.length;
         for(var i:int = 0; i < this.m_bingoNumberArrayLength; i++)
         {
            bingoNumberElement = BINGO_NUMBER_PREFIX + i + BINGO_NUMBER_POSTFIX;
            if(m_window[bingoNumberElement])
            {
               numberButton = new FarmAnimatedTextButton(m_window[bingoNumberElement],this.m_bingoNumberArray[i],this.onSelectBingoNumber);
               numberButton.enabled = false;
               addWidget(numberButton);
            }
         }
      }
      
      private function updateBallCountText() : void
      {
         if(this.m_ballCountText)
         {
            this.m_ballCountText.text = this.m_bingoManager.getBallCount().toString();
         }
      }
      
      private function updatePlayButton() : void
      {
         if(this.m_playButton)
         {
            this.m_playButton.enabled = this.m_bingoManager.getRemainingBallCount() > 0;
         }
      }
      
      private function updateBallUI() : void
      {
         var shouldShow:Boolean = false;
         if(this.m_bingoManager.getRemainingBallCount() > 0)
         {
            shouldShow = true;
         }
         this.m_ball.visible = shouldShow;
      }
      
      private function setupAskForButton() : void
      {
         var canPost:Boolean = this.m_bingoManager.canPost();
         var postButtonText:String = "";
         if(canPost)
         {
            postButtonText = ZLocUtils.t("Dialogs","Ask");
         }
         else
         {
            postButtonText = ZLocUtils.t("Dialogs","Posted");
         }
         this.m_askForButton = new FarmAnimatedTextButton(m_window.askFor_bt,postButtonText,this.onClickAskForMore);
         addWidget(this.m_askForButton);
         this.m_askForButton.enabled = canPost;
      }
      
      private function setupBuyButtons() : void
      {
         if(m_window.buyRandom_bt)
         {
            this.m_buyRandomPrice = BingoManager.getBuyRandomPrice();
            if(this.m_buyRandomPrice <= 0)
            {
               this.m_buyRandomPrice = BingoManager.BINGO_BUY_DEFAULT_RANDOM_PRICE;
            }
            this.m_buyRandomNumberButton = new FarmAnimatedCashButton(m_window.buyRandom_bt,ZLocUtils.t("Dialogs","BuyPlain"),this.m_buyRandomPrice.toString(),this.onClickBuyBingoNumber);
            addWidget(this.m_buyRandomNumberButton);
         }
         if(m_window.buySpecific_bt)
         {
            this.m_buySpecificPrice = BingoManager.getBuySpecificPrice();
            if(this.m_buySpecificPrice <= 0)
            {
               this.m_buySpecificPrice = BingoManager.BINGO_BUY_SPECIFIC_PRICE;
            }
            this.m_buySpecificNumberButton = new FarmAnimatedCashButton(m_window.buySpecific_bt,ZLocUtils.t("Dialogs","BuyPlain"),this.m_buySpecificPrice.toString(),this.onClickBuySpecificBingoNumber);
            addWidget(this.m_buySpecificNumberButton);
         }
         this.updateBuyButtons(!this.m_bingoManager.canUserFinishGame());
      }
      
      private function updateBuyButtons(isEnabled:Boolean) : void
      {
         if(isEnabled)
         {
            if(this.m_buyRandomNumberButton)
            {
               this.m_buyRandomNumberButton.applyGrayOut = false;
               this.m_buyRandomNumberButton.callback = this.onClickBuyBingoNumber;
               this.m_buyRandomNumberButton.detachTooltip();
            }
            if(this.m_buySpecificNumberButton)
            {
               this.m_buySpecificNumberButton.applyGrayOut = false;
               this.m_buySpecificNumberButton.callback = this.onClickBuySpecificBingoNumber;
               this.m_buySpecificNumberButton.detachTooltip();
            }
         }
         else
         {
            if(this.m_buyRandomNumberButton)
            {
               this.m_buyRandomNumberButton.applyGrayOut = true;
               this.m_buyRandomNumberButton.callback = null;
               this.m_buyRandomNumberButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","Bingo_buy_button_tooltip")));
            }
            if(this.m_buySpecificNumberButton)
            {
               this.m_buySpecificNumberButton.applyGrayOut = true;
               this.m_buySpecificNumberButton.callback = null;
               this.m_buySpecificNumberButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","Bingo_buy_button_tooltip")));
            }
         }
      }
      
      private function useStamp() : void
      {
         this.m_mouseShow = false;
         m_window.addEventListener(MouseEvent.MOUSE_MOVE,this.onWindowMouseMove);
         m_window.addEventListener(MouseEvent.ROLL_OUT,this.onWindowMouseRollOut);
         Mouse.hide();
         this.m_stamp.visible = true;
         this.m_stamp.x = mouseX;
         this.m_stamp.y = mouseY;
      }
      
      private function useCursor() : void
      {
         this.m_mouseShow = true;
         m_window.removeEventListener(MouseEvent.MOUSE_MOVE,this.onWindowMouseMove);
         m_window.removeEventListener(MouseEvent.ROLL_OUT,this.onWindowMouseRollOut);
         Mouse.show();
         this.m_stamp.visible = false;
      }
      
      private function onWindowMouseMove(evt:MouseEvent) : void
      {
         if(!this.m_mouseShow)
         {
            Mouse.hide();
            this.m_stamp.visible = true;
         }
         this.m_stamp.x = mouseX;
         this.m_stamp.y = mouseY;
      }
      
      private function onWindowMouseRollOut(evt:MouseEvent) : void
      {
         if(!this.m_mouseShow)
         {
            Mouse.show();
            this.m_stamp.visible = false;
         }
      }
      
      override protected function release() : void
      {
         m_window.removeEventListener(MouseEvent.MOUSE_MOVE,this.onWindowMouseMove);
         m_window.removeEventListener(MouseEvent.ROLL_OUT,this.onWindowMouseRollOut);
         this.m_bingoManager.removeEventListener(BingoManager.BUY_RANDOM_NUMBER_EVENT_NAME,this.onFinishBuyRandomNumber);
         Mouse.show();
         this.m_stamp = null;
         super.release();
      }
      
      private function getExpiryDateText() : String
      {
         var expiryTimeSecond:int = 0;
         var secondsLeft:int = 0;
         var timeLeftFriendlyName:String = null;
         var expiryDateString:String = null;
         var currentTimeSeconds:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var endDateString:String = BingoManager.getEndDate();
         if(endDateString)
         {
            expiryTimeSecond = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDateString) / FarmGameUtil.NUM_MSECS_IN_SECOND);
            secondsLeft = expiryTimeSecond - currentTimeSeconds;
            timeLeftFriendlyName = FarmGameUtil.toFriendlyTime(secondsLeft);
            expiryDateString = ZLocUtils.t("Dialogs","Bingo_ExpiryText",{"time":timeLeftFriendlyName});
         }
         return expiryDateString;
      }
      
      private function setupPrizes() : void
      {
         var prizeName:String = null;
         var prize:FarmItem = null;
         var friendlyName:String = null;
         var bingoPrizes:Array = this.m_bingoManager.getBingoPrizesArray();
         var prizeTextElementName:String = null;
         var prizeImageElementName:String = null;
         var prizeBuyElementName:String = null;
         var prizeCheckMarkElementName:String = null;
         var isCheckMarkVisible:Boolean = false;
         var bingoPrizesLength:int = int(bingoPrizes.length);
         for(var i:int = 0; i < bingoPrizesLength; i++)
         {
            prizeName = bingoPrizes[i].prize;
            prize = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
            if(prize)
            {
               friendlyName = prize.friendlyTitle;
               prizeTextElementName = BINGO_PRIZE_NAME_PREFIX + i + BINGO_PRIZE_NAME_POSTFIX;
               if(m_window[prizeTextElementName])
               {
                  addWidget(new ZwTextField(m_window[prizeTextElementName],ZLocUtils.t("Dialogs","Bingo_Prize_Name",{"prize":friendlyName})));
               }
               prizeImageElementName = BINGO_PRIZE_IMAGE_PREFIX + i;
               if(m_window[prizeImageElementName])
               {
                  addWidget(new FarmIcon(m_window[prizeImageElementName],prize.icon));
               }
               prizeBuyElementName = BINGO_PRIZE_BUY_PREFIX + i;
               if(m_window[prizeBuyElementName])
               {
                  addWidget(new FarmAnimatedCashButton(m_window[prizeBuyElementName],ZLocUtils.t("Dialogs","BuyPlain"),prize.realCashCost.toString(),this.onClickBuyPrize));
               }
               prizeCheckMarkElementName = BINGO_PRIZE_CHECKMARK + i;
               if(m_window[prizeCheckMarkElementName])
               {
                  isCheckMarkVisible = false;
                  if(bingoPrizes[i].isClaimed)
                  {
                     isCheckMarkVisible = true;
                  }
                  else
                  {
                     this.m_remainingPrizesCost += prize.cash;
                  }
                  m_window[prizeCheckMarkElementName].visible = isCheckMarkVisible;
               }
            }
         }
      }
      
      private function updateAllPrizes() : void
      {
         var prizeName:String = null;
         var prize:FarmItem = null;
         var prizeCheckMarkElementName:String = null;
         var bingoPrizes:Array = this.m_bingoManager.getBingoPrizesArray();
         var bingoPrizesLength:int = int(bingoPrizes.length);
         var prizeImageElementName:String = null;
         this.m_remainingPrizesCost = 0;
         for(var i:int = 0; i < bingoPrizesLength; i++)
         {
            prizeName = bingoPrizes[i].prize;
            prize = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
            prizeCheckMarkElementName = null;
            if(prize)
            {
               prizeCheckMarkElementName = BINGO_PRIZE_CHECKMARK + i;
               if(m_window[prizeCheckMarkElementName])
               {
                  m_window[prizeCheckMarkElementName].visible = bingoPrizes[i].isClaimed;
               }
               if(bingoPrizes[i].isClaimed == false)
               {
                  this.m_remainingPrizesCost += prize.cash;
               }
               prizeImageElementName = BINGO_PRIZE_IMAGE_PREFIX + i;
               if(m_window[prizeImageElementName])
               {
                  removeWidget(m_window[prizeImageElementName]);
                  addWidget(new FarmIcon(m_window[prizeImageElementName],prize.icon));
               }
            }
         }
         this.m_buyRemainingPrizesButton.setAmountText(this.m_remainingPrizesCost.toString());
      }
      
      private function updatePrizeInfoByName(prizeName:String) : void
      {
         var bingoPrizes:Array = this.m_bingoManager.getBingoPrizesArray();
         var bingoPrizesLength:int = int(bingoPrizes.length);
         var prizeCheckMarkElementName:String = null;
         var prize:FarmItem = null;
         this.m_remainingPrizesCost = 0;
         for(var i:int = 0; i < bingoPrizesLength; i++)
         {
            prize = Global.farmGameSettingsManager.getFarmItemByName(bingoPrizes[i].prize);
            if(prize)
            {
               if(bingoPrizes[i].prize == prizeName && bingoPrizes[i].isClaimed == true)
               {
                  prizeCheckMarkElementName = BINGO_PRIZE_CHECKMARK + i;
                  if(m_window[prizeCheckMarkElementName])
                  {
                     m_window[prizeCheckMarkElementName].visible = true;
                  }
               }
               else if(bingoPrizes[i].isClaimed == false)
               {
                  this.m_remainingPrizesCost += prize.cash;
               }
            }
         }
         this.m_buyRemainingPrizesButton.setAmountText(this.m_remainingPrizesCost.toString());
      }
      
      private function initializeStamp() : void
      {
         var stampElement:String = null;
         var stampImageElement:String = null;
         for(var i:int = 0; i < this.m_bingoNumberArrayLength; i++)
         {
            stampElement = BINGO_STAR_PREFIX + i;
            stampImageElement = BINGO_STAMP_IMAGE_PREFIX + i;
            m_window[stampElement].visible = false;
         }
         this.updateStamps(true);
      }
      
      private function updateStamps(isInitialized:Boolean = false) : void
      {
         var i:int = 0;
         var j:int = 0;
         var userBingoNumArray:Array = this.m_bingoManager.getBingoNums();
         var userBingoNumArrayLength:int = int(userBingoNumArray.length);
         var stampElement:String = null;
         var numIndex:int = 0;
         if(!isInitialized)
         {
            for(i = 0; i < this.m_bingoNumberArrayLength; i++)
            {
               stampElement = BINGO_STAR_PREFIX + i;
               m_window[stampElement].visible = false;
            }
         }
         if(userBingoNumArray != null)
         {
            for(j = 0; j < userBingoNumArrayLength; j++)
            {
               if(userBingoNumArray[j].isClaimed == true)
               {
                  numIndex = int(userBingoNumArray[j].bingoIndex);
                  stampElement = BINGO_STAR_PREFIX + numIndex;
                  if(m_window[stampElement])
                  {
                     m_window[stampElement].visible = true;
                     m_window[stampElement].gotoAndPlay(STAMP_FRAME);
                  }
               }
            }
         }
      }
      
      private function toggleBingoCard(isEnabled:Boolean) : void
      {
         var numberButton:FarmAnimatedTextButton = null;
         var bingoNumberElement:String = null;
         var stampElement:String = null;
         for(var i:int = 0; i < this.m_bingoNumberArrayLength; i++)
         {
            bingoNumberElement = BINGO_NUMBER_PREFIX + i + BINGO_NUMBER_POSTFIX;
            stampElement = BINGO_STAR_PREFIX + i;
            if(Boolean(m_window[bingoNumberElement]) && Boolean(m_window[stampElement]) && m_window[stampElement].visible == false)
            {
               numberButton = getWidget(m_window[bingoNumberElement]) as FarmAnimatedTextButton;
               numberButton.enabled = isEnabled;
            }
         }
         if(isEnabled)
         {
            this.useStamp();
         }
         else
         {
            this.useCursor();
         }
      }
      
      private function claimWinningPrizes() : void
      {
         var prizeItem:FarmItem = null;
         var isFinal:Boolean = false;
         var bingoRewardWindow:BingoRewardWindow = null;
         var prizesClaimed:Array = this.m_bingoManager.claimWinningPrizes();
         var prizesClaimedLength:int = int(prizesClaimed.length);
         for(var i:int = 0; i < prizesClaimedLength; i++)
         {
            prizeItem = prizesClaimed[i].prizeItem;
            isFinal = Boolean(prizesClaimed[i].isFinal);
            this.updatePrizeInfoByName(prizeItem.name);
            this.m_reset.visible = isFinal;
            bingoRewardWindow = new BingoRewardWindow(prizeItem,isFinal);
            UI.displayPopup(bingoRewardWindow);
         }
      }
      
      private function onResetButton(evt:MouseEvent) : void
      {
         this.resetBingoCard();
         this.trackClick();
      }
      
      private function resetBingoCard() : void
      {
         this.m_bingoManager.resetGame();
         this.m_reset.visible = false;
         this.m_ball.visible = false;
         this.updateBuyButtons(true);
         this.updateBallCountText();
         this.updatePlayButton();
         this.updateAllPrizes();
         this.updateStamps();
         this.m_bingoManager.removeEventListener(BingoManager.BUY_RANDOM_NUMBER_EVENT_NAME,this.onFinishBuyRandomNumber);
      }
      
      private function onClickAskForMore(event:MouseEvent) : void
      {
         this.m_askForButton.enabled = false;
         this.m_askForButton.text = ZLocUtils.t("Dialogs","Posted");
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onAskForMore",this.onCompleteAskForTransaction));
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"ask_button");
         this.trackClick();
      }
      
      private function onCompleteAskForTransaction(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         var currentTimeSec:int = 0;
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         if(success)
         {
            currentTimeSec = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(BingoManager.BINGO_VIRAL_POST_FREQUENCY_FLAG,currentTimeSec,true);
            if(this.m_askForButton)
            {
               this.m_askForButton.enabled = false;
               this.m_askForButton.text = ZLocUtils.t("Dialogs","Posted");
            }
         }
         else if(this.m_askForButton)
         {
            this.m_askForButton.enabled = true;
            this.m_askForButton.text = ZLocUtils.t("Dialogs","Ask");
         }
      }
      
      private function onClickBuyPrize(event:MouseEvent) : void
      {
         var prizeIndexSelected:int = 0;
         var prizesArray:Array = null;
         var prizeName:String = null;
         var prizeCost:String = null;
         var prizeSelectedEventName:String = event.target.name;
         if(prizeSelectedEventName)
         {
            prizeIndexSelected = int(prizeSelectedEventName.split("_")[1]);
            prizesArray = this.m_bingoManager.getBingoPrizesArray();
            if(prizesArray)
            {
               prizeName = prizesArray[prizeIndexSelected].prize;
               this.m_prizeItemToBuy = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
               if(this.m_prizeItemToBuy)
               {
                  prizeCost = this.m_prizeItemToBuy.cash.toString();
                  UI.displayMessage(ZLocUtils.t("Dialogs","Bingo_Buy_Prize_Message",{
                     "cost":prizeCost,
                     "prizeName":this.m_prizeItemToBuy.friendlyTitle
                  }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyPrizeDialog,"",true);
               }
            }
         }
         this.trackClick();
      }
      
      private function onConfirmBuyPrizeDialog(event:GenericPopupEvent) : void
      {
         var prizeCost:int = 0;
         if(event.button == GenericPopup.YES)
         {
            prizeCost = this.m_prizeItemToBuy.cash;
            if(Global.player.canBuyCash(prizeCost,true))
            {
               Global.player.cash -= prizeCost;
               Global.player.addGift(this.m_prizeItemToBuy.name);
               this.displayBuyToaster(this.m_prizeItemToBuy);
               TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onBuyPrize",null,[this.m_prizeItemToBuy.name]));
            }
         }
      }
      
      private function displayBuyToaster(prizeItem:FarmItem) : void
      {
         var toasterMessage:String = ZLocUtils.t("Dialogs","Bingo_buy_prize_toaster_message",{"prize":prizeItem.friendlyTitle});
         var icon:String = prizeItem.iconUrl;
         ToasterManager.getInstance().togglePause(false);
         ToasterManager.getInstance().add(new IconToasterWindow(icon,toasterMessage));
      }
      
      private function onClickCompleteNow(event:MouseEvent) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","Bingo_Complete_Now_Message",{"cost":this.m_remainingPrizesCost}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteNow,"",true);
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"click_completenow",this.m_bingoManager.getRemainingBallCount().toString());
         this.trackClick();
      }
      
      private function onConfirmCompleteNow(event:GenericPopupEvent) : void
      {
         var bingoPrizes:Array = null;
         var prize:FarmItem = null;
         var bingoRewardWindow:BingoRewardWindow = null;
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.canBuyCash(this.m_remainingPrizesCost,true))
            {
               Global.player.cash -= this.m_remainingPrizesCost;
               this.m_bingoManager.completeNow();
               bingoPrizes = this.m_bingoManager.getBingoPrizesArray();
               prize = Global.farmGameSettingsManager.getFarmItemByName(bingoPrizes[4].prize);
               if(prize)
               {
                  bingoRewardWindow = new BingoRewardWindow(prize,true);
                  UI.displayPopup(bingoRewardWindow);
               }
               this.updateStamps();
               this.updateAllPrizes();
               this.m_reset.visible = true;
            }
         }
      }
      
      private function onClickMoreInfo(event:MouseEvent) : void
      {
         this.showTutorial();
         this.trackClick();
      }
      
      override protected function showTutorial() : void
      {
         this.toggleAnimationState(false);
         super.showTutorial();
      }
      
      override protected function hideTutorial() : void
      {
         this.toggleAnimationState(true);
         super.hideTutorial();
      }
      
      private function toggleAnimationState(visible:Boolean) : void
      {
         if(m_window.playGlint_anim)
         {
            m_window.playGlint_anim.visible = visible;
         }
         if(m_window.playSparkle_anim)
         {
            m_window.playSparkle_anim.visible = visible;
         }
         if(m_window.ring_mc.rays_anim)
         {
            m_window.ring_mc.rays_anim.visible = visible;
         }
      }
      
      private function onClickBuyBingoNumber(event:MouseEvent) : void
      {
         var ballCountDuringTransaction:int = 0;
         if(Global.player.canBuyCash(this.m_buyRandomPrice,true))
         {
            this.m_ball.gotoAndStop(BALL_DELAY_FRAME);
            this.m_ball.visible = true;
            this.m_playButton.enabled = false;
            ballCountDuringTransaction = this.m_bingoManager.getBallCount() + 1;
            this.m_ballCountText.text = ballCountDuringTransaction.toString();
            Global.player.cash -= this.m_buyRandomPrice;
            this.m_bingoManager.buyRandomNum();
            this.m_bingoManager.addEventListener(BingoManager.BUY_RANDOM_NUMBER_EVENT_NAME,this.onFinishBuyRandomNumber);
            if(this.m_bingoManager.isUserOverBingoCardLengthWithNextBall() == true)
            {
               this.updateBuyButtons(false);
            }
         }
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"click_buynumber",this.m_bingoManager.getRemainingBallCount().toString());
         this.trackClick();
      }
      
      private function onFinishBuyRandomNumber(event:Event) : void
      {
         if(this.m_bingoManager.isBingoBuyNumberTransactionInProgress() == false)
         {
            this.m_bingoManager.removeEventListener(BingoManager.BUY_RANDOM_NUMBER_EVENT_NAME,this.onFinishBuyRandomNumber);
            this.m_ball.gotoAndStop(BINGO_DEFAULT_BALL);
            this.m_ball.visible = true;
            this.updatePlayButton();
         }
      }
      
      private function onClickBuySpecificBingoNumber(event:MouseEvent) : void
      {
         if(!this.m_bingoManager.isUserOverBingoCardLengthWithNextBall())
         {
            if(Global.player.canBuyCash(this.m_buySpecificPrice,true))
            {
               this.toggleBingoCard(true);
            }
         }
         else
         {
            this.updateBuyButtons(false);
         }
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"click_buyspecificnumber");
         this.trackClick();
      }
      
      private function onClickPlay(event:MouseEvent) : void
      {
         var randomRotation:int = 0;
         var bingoNumPlayedData:Array = this.m_bingoManager.playBingoNum();
         var bingoNum:int = int(bingoNumPlayedData[0].bingoNum);
         var bingoIndex:int = int(bingoNumPlayedData[0].bingoIndex);
         var isNumOnCard:Boolean = Boolean(bingoNumPlayedData[0].isNumberOnCard);
         this.updateBallCountText();
         this.updatePlayButton();
         this.setBallColourByNumber(bingoNum);
         this.m_ball.value_tf.text = bingoNum.toString();
         this.m_ball.gotoAndStop(this.m_ballColour);
         if(isNumOnCard)
         {
            Global.player.xp += BingoManager.BINGO_DEFAULT_XP_POINTS;
            Global.player.avatar.displayStatus("+" + BingoManager.BINGO_DEFAULT_XP_POINTS.toString());
            randomRotation = Math.random() * 360 - Math.random() * 360;
            this.m_ball.y = this.m_ballYPosition;
            this.m_ball.rotation = 0;
            TweenMax.from(this.m_ball,0.5,{
               "y":"-50",
               "ease":Bounce.easeOut
            });
            TweenMax.from(this.m_ball,0.5,{
               "rotation":randomRotation,
               "ease":Cubic.easeOut
            });
            this.m_ball.visible = true;
            this.m_ball.effect_mc.gotoAndPlay(BALL_SUCCESS_FRAME);
            this.successBingoNumberOnBoard(bingoIndex);
         }
         else
         {
            TweenMax.from(this.m_ball,0,{
               "y":"-50",
               "ease":Bounce.easeOut
            });
            this.m_ball.visible = true;
            this.m_ball.effectLose_mc.gotoAndPlay(BALL_LOSE_FRAME);
         }
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"play_button");
         this.trackClick();
      }
      
      private function onSelectBingoNumber(event:MouseEvent) : void
      {
         var indexSelected:int = 0;
         this.m_stamp.gotoAndStop(STAMP_DOWN_FRAME);
         this.toggleBingoCard(false);
         var numberSelectedEventName:String = event.target.parent.name;
         if(numberSelectedEventName)
         {
            if(Global.player.canBuyCash(this.m_buySpecificPrice,true))
            {
               Global.player.cash -= this.m_buySpecificPrice;
               Global.player.xp += BingoManager.BINGO_DEFAULT_XP_POINTS;
               Global.player.avatar.displayStatus("+" + BingoManager.BINGO_DEFAULT_XP_POINTS.toString());
               indexSelected = int(numberSelectedEventName.split("_")[1]);
               this.m_bingoManager.buySpecificNum(indexSelected);
               this.successBingoNumberOnBoard(indexSelected);
            }
         }
      }
      
      private function successBingoNumberOnBoard(index:int) : void
      {
         this.claimWinningPrizes();
         var stampElement:String = BINGO_STAR_PREFIX + index;
         if(m_window[stampElement])
         {
            m_window[stampElement].visible = true;
            m_window[stampElement].gotoAndPlay(STAMP_FRAME);
            m_window[stampElement].effect1.gotoAndPlay(STAMP_FRAME);
            m_window[stampElement].effect2.gotoAndPlay(STAMP_FRAME);
         }
         FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"daub_applied");
      }
      
      private function setBallColourByNumber(ballNum:int) : void
      {
         if(ballNum >= 1 && ballNum <= 15)
         {
            this.m_ballColour = BINGO_B;
         }
         else if(ballNum >= 16 && ballNum <= 30)
         {
            this.m_ballColour = BINGO_I;
         }
         else if(ballNum >= 31 && ballNum <= 45)
         {
            this.m_ballColour = BINGO_N;
         }
         else if(ballNum >= 46 && ballNum <= 60)
         {
            this.m_ballColour = BINGO_G;
         }
         else if(ballNum >= 61 && ballNum <= 75)
         {
            this.m_ballColour = BINGO_O;
         }
      }
      
      private function trackClick() : void
      {
         if(!this.m_isClickTracked)
         {
            this.m_isClickTracked = true;
            FarmStatsManager.count(this.m_bingoManager.getStatsCounter(),"dialog","first_click",this.m_bingoManager.getNumberOfSuccessfulBallsOnCard().toString());
         }
      }
   }
}

