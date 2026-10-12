package Widgets.Windows.Lottery
{
   import Classes.Constants.Experiments;
   import Classes.LotteryTicket;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.LotteryManager;
   import Transactions.TLottery;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Lottery.LotteryTicketFrame;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LotteryMainWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Sweepstakes_mainUI.swf";
      
      private static const LOTTERY_MAIN_WINDOW_FEATURE_FLAG:String = "LotteryMainWindowOpen";
      
      public static const DIALOG_COUNTER:String = "dialog";
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_historyButton:FarmAnimatedTextButton;
      
      private var m_myPickUIFrame:ZwBaseWidget;
      
      private var m_mylottoOverFrame:ZwBaseWidget;
      
      private var m_mylottoWinningFrame:ZwBaseWidget;
      
      private var m_costText:ZwTextField;
      
      private var m_ticketsFrame:LotteryTicketFrame;
      
      private var m_timerText:ZwTextField;
      
      private var m_timer_days_tf:ZwTextField;
      
      private var m_timer_hours_tf:ZwTextField;
      
      private var m_timer_minutes_tf:ZwTextField;
      
      private var m_timer_seconds_tf:ZwTextField;
      
      private var m_timeTicker:Timer;
      
      protected var m_showWhatIsThisOnLoad:Boolean;
      
      private var m_currentTickets:Array;
      
      private var m_historyTickets:Object;
      
      private var m_showRedeemGraphic:Boolean;
      
      private var m_redeemRewardsButton:FarmAnimatedTextButton;
      
      private var m_winningNumbers:Array;
      
      private var m_numbers:Vector.<ZwTextField>;
      
      private var m_mysteryFrame:ZwBaseWidget;
      
      private var m_redeemReward_mc:ZwBaseWidget;
      
      private var m_grandPrize:ZwTextField;
      
      private var m_timerFrame:ZwBaseWidget;
      
      private var m_totalPrizeWon:Number;
      
      private var m_winningBalls:Vector.<ZwBaseWidget>;
      
      private var m_localActiveTickets:Array;
      
      public function LotteryMainWindow()
      {
         super(ASSET_PATH);
         LotteryManager.instance.mainWindow = this;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var winningNumbers:Array = null;
         var redeemEndTimeStamp:Number = NaN;
         var winningBall_mc:ZwFrame = null;
         var number:ZwTextField = null;
         var prizeFromLootTableValue:int = 0;
         var lootTable_mc:ZwTextField = null;
         var numPlayerTickets:Number = NaN;
         var playerTicket:Object = null;
         var ticket:LotteryTicket = null;
         var totalPurchaseTicket:Number = NaN;
         var k:int = 0;
         var minusOne:int = 0;
         var noTicketInfo:Array = null;
         var noTicket:LotteryTicket = null;
         super.onLoadComplete(event);
         var statsPhylum:String = LotteryManager.instance.hasUnclaimedTickets() ? "main_ui_before" : "main_ui_after";
         LotteryManager.instance.logLotteryStats(DIALOG_COUNTER,statsPhylum,"view");
         this.m_totalPrizeWon = 0;
         this.m_numbers = new Vector.<ZwTextField>();
         this.m_winningBalls = new Vector.<ZwBaseWidget>();
         addWidget(this.m_grandPrize = new ZwTextField(m_window.grandprize_tf,""));
         this.m_timeTicker = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND);
         this.m_timeTicker.addEventListener(TimerEvent.TIMER,this.onTickerUpdate);
         if(m_window.whatisthis_mc)
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.showWhatsThisPopUp));
         }
         addWidget(new ZwTextField(m_window.grandPrize_tf,ZLocUtils.t("Dialogs","LotteryGrandPrize")));
         addWidget(new ZwTextField(m_window.mypickUI_tf,ZLocUtils.t("Dialogs","LotteryPickYourNumbers")));
         addWidget(new ZwTextField(m_window.slotframe_tf,ZLocUtils.t("Dialogs","LotteryMatchGrandPrize",{"matches":Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETNUMBERS)})));
         addWidget(new ZwTextField(m_window.timer_tf,ZLocUtils.t("Dialogs","LotteryNextrDrawing")));
         this.m_timerFrame = new ZwBaseWidget(m_window.countdown_mc);
         addWidget(this.m_timerFrame);
         addWidget(this.m_timer_days_tf = new ZwTextField(m_window.countdown_mc.days_tf,"00"));
         addWidget(this.m_timer_hours_tf = new ZwTextField(m_window.countdown_mc.hours_tf,"00"));
         addWidget(this.m_timer_minutes_tf = new ZwTextField(m_window.countdown_mc.minutes_tf,"00"));
         addWidget(this.m_timer_seconds_tf = new ZwTextField(m_window.countdown_mc.seconds_tf,"00"));
         addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_window.buyTicket_bt,ZLocUtils.t("Dialogs","LotteryBuyButtonText"),this.onBuyTicket));
         addWidget(this.m_historyButton = new FarmAnimatedTextButton(m_window.history_bt,ZLocUtils.t("Dialogs","LotteryHistoryButtonText"),this.onViewHistory),LotteryManager.instance.getClaimedTickets().length > 0);
         addWidget(this.m_redeemRewardsButton = new FarmAnimatedTextButton(m_window.redeemReward_mc,ZLocUtils.t("Dialogs","LotteryCollectWinningsText"),this.onRedeemTickets));
         this.m_mylottoOverFrame = new ZwBaseWidget(m_window.lotteryOver_mc);
         addWidget(this.m_mylottoOverFrame,false);
         var bg_mc:ZwBaseWidget = new ZwBaseWidget(m_window.background_mc);
         addWidget(bg_mc,true);
         (bg_mc.element as MovieClip).play();
         this.m_mylottoWinningFrame = new ZwBaseWidget(m_window.winningFrame_mc);
         addWidget(this.m_mylottoWinningFrame);
         this.m_mysteryFrame = new ZwBaseWidget(m_window.mysteryFrame_mc);
         addWidget(this.m_mysteryFrame);
         this.m_ticketsFrame = new LotteryTicketFrame(m_window.slotFrame_mc,LotteryManager.LOTTERY_CURRENT);
         addWidget(this.m_ticketsFrame);
         for(var i:int = 0; i < Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETNUMBERS,4); i++)
         {
            winningBall_mc = new ZwFrame(m_window.winningFrame_mc["winningBall_" + i + "_mc"]);
            addWidget(winningBall_mc);
            this.m_winningBalls.push(winningBall_mc);
            number = new ZwTextField(m_window.winningFrame_mc["winningBall_" + i + "_mc"].winningNumber_tf,"??");
            winningBall_mc.addWidget(number);
            this.m_numbers.push(number);
         }
         var prizeTableFrame:ZwBaseWidget = new ZwBaseWidget(m_window.prizetable_mc);
         addWidget(prizeTableFrame,true);
         for(var j:int = 1; j < LotteryTicket.LIMIT_NUM_BALLS; j++)
         {
            prizeFromLootTableValue = Math.round(Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_PAYOUTPREFIX + j.toString()) * Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETPRICE,10));
            lootTable_mc = new ZwTextField(m_window.prizetable_mc["prizetableMatch_" + j + "_tf"],ZLocUtils.t("Dialogs","LotteryLootTableWinText",{
               "matches":j.toString(),
               "earnings":prizeFromLootTableValue.toString()
            }));
            addWidget(lootTable_mc,true);
         }
         this.m_totalPrizeWon = 0;
         var lottoMgr:LotteryManager = LotteryManager.instance;
         var ticketNumbers:Object = new Object();
         var populateWinningNumbers:Boolean = true;
         var enableRedeem:Boolean = false;
         this.m_currentTickets = new Array();
         this.m_localActiveTickets = this.m_localActiveTickets != null ? this.m_localActiveTickets : lottoMgr.getActiveTickets();
         var lotteryTickets:Array = this.m_localActiveTickets;
         var canBuyTicket:Boolean = lottoMgr.canBuyTickets();
         var maxTicketsAllowed:Number = Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_MAXTICKETS);
         var unClaimedTickets:Boolean = lottoMgr.hasUnclaimedTickets();
         if(lotteryTickets != null)
         {
            numPlayerTickets = lotteryTickets.length;
            this.m_buyButton.enabled = !LotteryManager.instance.hasEnteredCooldown() && LotteryManager.instance.canBuyTickets() && numPlayerTickets < maxTicketsAllowed;
            for(j = 0; j < numPlayerTickets; j++)
            {
               playerTicket = lotteryTickets[j];
               if(playerTicket != null)
               {
                  if(playerTicket.redeemed == false)
                  {
                     if(unClaimedTickets)
                     {
                        ticket = this.populateTicketClaimData(playerTicket);
                        enableRedeem = true;
                        redeemEndTimeStamp = lottoMgr.getTicketsEndTime(ticket.timestamp);
                     }
                     else
                     {
                        ticket = new LotteryTicket(playerTicket);
                        ticket.currentState = LotteryManager.LOTTERY_PLAYING_STATE;
                     }
                  }
                  this.m_currentTickets.push(ticket);
               }
            }
         }
         if(!unClaimedTickets && canBuyTicket)
         {
            totalPurchaseTicket = this.m_currentTickets.length;
            for(k = totalPurchaseTicket; k < maxTicketsAllowed; k++)
            {
               minusOne = LotteryTicket.LOTTERY_TICKET_NO_DATA;
               noTicketInfo = [minusOne,minusOne,minusOne,minusOne];
               ticketNumbers["numbers"] = noTicketInfo;
               noTicket = new LotteryTicket(ticketNumbers);
               this.m_currentTickets.push(noTicket);
            }
         }
         if(enableRedeem)
         {
            this.enableRedeemMode(redeemEndTimeStamp);
         }
         this.m_ticketsFrame.tickets = this.m_currentTickets;
         this.m_showWhatIsThisOnLoad = this.getShowWhatIsThis();
         if(this.m_showWhatIsThisOnLoad)
         {
            this.showWhatsThisPopUp(null);
         }
         this.onTickerUpdate(null);
         if(!LotteryManager.instance.hasUnclaimedTickets())
         {
            this.m_redeemRewardsButton.enabled = false;
            this.m_timeTicker.start();
         }
         this.setLotteryData();
      }
      
      private function showWhatsThisPopUp(event:Event = null) : void
      {
         TutorialUI.displayLotteryTutorialWindow(false,null);
      }
      
      public function getShowWhatIsThis() : Boolean
      {
         var showWhatIsThis:Boolean = false;
         if(!Global.player.getSeenFlag(LOTTERY_MAIN_WINDOW_FEATURE_FLAG))
         {
            Global.player.setSeenFlag(LOTTERY_MAIN_WINDOW_FEATURE_FLAG);
            showWhatIsThis = true;
         }
         return showWhatIsThis;
      }
      
      private function setLotteryData() : void
      {
         var lottoMgrInstance:LotteryManager = LotteryManager.instance;
         this.m_showRedeemGraphic = lottoMgrInstance.hasUnclaimedTickets();
         if(lottoMgrInstance.getClaimedTickets().length > 0)
         {
            this.m_historyTickets = new Object();
            this.m_historyTickets["tickets"] = lottoMgrInstance.getClaimedTickets().length > 0;
            this.m_historyButton.visible = true;
         }
         else
         {
            this.m_historyButton.visible = false;
         }
      }
      
      private function playLottoryOverAnimation(winningNumbers:Array) : void
      {
         var i:int = 0;
         if(this.m_mylottoOverFrame != null)
         {
            this.m_mylottoOverFrame.visible = true;
            (this.m_mylottoOverFrame.element as MovieClip).play();
         }
         if(this.m_mylottoWinningFrame != null)
         {
            i = 0;
            while(i < winningNumbers.length && i < this.m_numbers.length)
            {
               this.m_numbers[i].text = winningNumbers[i];
               this.m_numbers[i].visible = true;
               this.m_winningBalls[i].visible = true;
               i++;
            }
            (this.m_mylottoWinningFrame.element as MovieClip).play();
         }
      }
      
      private function populateTicketClaimData(playerTicket:Object) : LotteryTicket
      {
         var lottoMgr:LotteryManager = LotteryManager.instance;
         var ticket:LotteryTicket = new LotteryTicket(playerTicket);
         ticket.currentState = LotteryManager.LOTTERY_REDEEM_STATE;
         ticket.winningNumbers = lottoMgr.evaluateWinningsForTicket(playerTicket);
         if(ticket.winningNumbers > 0)
         {
            this.m_totalPrizeWon += ticket.winningNumbers;
         }
         return ticket;
      }
      
      private function initializeTicketFrame(newTicketData:Array = null, useNewTicketData:Boolean = false) : Array
      {
         var totalPurchaseTicket:Number = NaN;
         var k:int = 0;
         var minusOne:int = 0;
         var noTicketInfo:Array = null;
         var ticketNumbers:Object = null;
         var noTicket:LotteryTicket = null;
         this.m_localActiveTickets = LotteryManager.instance.getActiveTickets();
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var end:Number = LotteryManager.instance.getCurrentLotteryEnd();
         var hasUnclaimedTickets:Boolean = end < now;
         var playerTickets:Array = new Array();
         if(!hasUnclaimedTickets && LotteryManager.instance.canBuyTickets())
         {
            totalPurchaseTicket = playerTickets.length;
            k = totalPurchaseTicket;
            while(k < 3 && k < Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_MAXTICKETS))
            {
               minusOne = LotteryTicket.LOTTERY_TICKET_NO_DATA;
               noTicketInfo = [minusOne,minusOne,minusOne,minusOne];
               ticketNumbers = new Object();
               ticketNumbers["numbers"] = noTicketInfo;
               noTicket = new LotteryTicket(ticketNumbers);
               playerTickets.push(noTicket);
               k++;
            }
         }
         return playerTickets;
      }
      
      private function takeNewTicket(newTicketData:Array) : Array
      {
         var lotteryTicketObj:Object = null;
         if(newTicketData != null)
         {
            lotteryTicketObj = new Object();
            lotteryTicketObj["numbers"] = newTicketData;
            lotteryTicketObj["redeemed"] = false;
            this.m_localActiveTickets.push(lotteryTicketObj);
         }
         return this.m_localActiveTickets;
      }
      
      private function enableRedeemMode(timestamp:Number) : void
      {
         var lottoMgr:LotteryManager = LotteryManager.instance;
         m_closeButton.visible = false;
         this.m_buyButton.enabled = false;
         this.m_mysteryFrame.visible = false;
         var winningNumbers:Array = lottoMgr.getWinningNumbers(timestamp);
         if(this.m_totalPrizeWon > 0)
         {
            this.m_redeemRewardsButton.text = ZLocUtils.t("Dialogs","LotteryCollectWinningsText") + "\n" + this.m_totalPrizeWon;
         }
         else
         {
            this.m_redeemRewardsButton.text = ZLocUtils.t("Dialogs","LotteryThanksForPlayingText");
         }
         this.m_redeemRewardsButton.enabled = true;
         this.m_redeemRewardsButton.visible = true;
         this.playLottoryOverAnimation(winningNumbers);
      }
      
      private function disableRedeemMode() : void
      {
         var lottoMgr:LotteryManager = LotteryManager.instance;
         m_closeButton.visible = true;
         this.m_buyButton.enabled = true;
         this.m_timerFrame.visible = true;
         this.m_mysteryFrame.visible = true;
         this.m_redeemRewardsButton.enabled = false;
         if(this.m_mylottoOverFrame != null)
         {
            this.m_mylottoOverFrame.visible = false;
            (this.m_mylottoOverFrame.element as MovieClip).stop();
         }
      }
      
      private function resetTimerAndGrandPrize() : void
      {
         this.onTickerUpdate(null);
         if(!LotteryManager.instance.hasUnclaimedTickets())
         {
            this.m_redeemRewardsButton.enabled = false;
            this.m_timeTicker.start();
         }
         this.setLotteryData();
      }
      
      private function formatTimestamp(timestamp:uint) : void
      {
         var dateArray:Array = FarmGameUtil.parseTimeLeft(timestamp);
         if(dateArray != null)
         {
            this.m_timer_days_tf.text = dateArray[0] != null ? dateArray[0].toString() : "";
            this.m_timer_hours_tf.text = dateArray[1] != null ? dateArray[1].toString() : "";
            this.m_timer_minutes_tf.text = dateArray[2] != null ? dateArray[2].toString() : "";
            this.m_timer_seconds_tf.text = dateArray[3] != null ? dateArray[3].toString() : "";
         }
      }
      
      override protected function release() : void
      {
         super.release();
         if(this.m_timeTicker)
         {
            this.m_timeTicker.stop();
            this.m_timeTicker.removeEventListener(TimerEvent.TIMER,this.onTickerUpdate);
            this.m_timeTicker = null;
         }
      }
      
      private function onTickerUpdate(event:TimerEvent) : void
      {
         var lotteryTickets:Array = null;
         var winningNumbers:Array = null;
         var getWinningNumbers:TLottery = null;
         var fetchNextConfig:TLottery = null;
         var currentServerTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var endTime:Number = LotteryManager.instance.getCurrentLotteryEnd() + LotteryManager.TIMER_DELAY;
         var timeRemaining:uint = endTime > currentServerTime ? uint(endTime - currentServerTime) : 0;
         if(timeRemaining <= 0)
         {
            lotteryTickets = LotteryManager.instance.getActiveTickets();
            if(lotteryTickets.length > 0)
            {
               winningNumbers = LotteryManager.instance.getWinningNumbers(LotteryManager.instance.getCurrentLotteryEnd());
               if(winningNumbers != null)
               {
                  this.onGetWinningNumbers({"numbers":winningNumbers});
               }
               else
               {
                  getWinningNumbers = new TLottery(TLottery.TYPE_WINNINGNUMBERS,{"lotteryEnd":LotteryManager.instance.getCurrentLotteryEnd()},this.onGetWinningNumbers);
                  TransactionManager.addTransaction(getWinningNumbers,true);
               }
            }
            else
            {
               fetchNextConfig = new TLottery(TLottery.TYPE_FETCHNEXTCONFIG,null,this.onLotteryOver);
               TransactionManager.addTransaction(fetchNextConfig,true);
            }
            this.m_timeTicker.stop();
         }
         this.formatTimestamp(timeRemaining);
         this.m_grandPrize.text = LotteryManager.instance.getGrandPrize(currentServerTime).toString();
      }
      
      private function onGetWinningNumbers(result:Object) : void
      {
         var winningNumbers:Array = null;
         var i:int = 0;
         var rewardTickets:Array = null;
         var ticket:LotteryTicket = null;
         if(result != null && result.hasOwnProperty("numbers"))
         {
            m_closeButton.visible = false;
            this.m_buyButton.enabled = false;
            this.m_mysteryFrame.visible = false;
            this.m_mylottoWinningFrame.visible = true;
            winningNumbers = result.numbers;
            i = 0;
            while(i < winningNumbers.length && i < this.m_numbers.length)
            {
               this.m_numbers[i].text = winningNumbers[i];
               i++;
            }
            (this.m_mylottoWinningFrame.element as MovieClip).play();
            this.m_redeemRewardsButton.enabled = true;
            rewardTickets = new Array();
            for(i = 0; i < this.m_ticketsFrame.tickets.length; i++)
            {
               ticket = this.m_ticketsFrame.tickets[i];
               if(ticket.currentState == LotteryManager.LOTTERY_PLAYING_STATE || ticket.currentState == LotteryManager.LOTTERY_REDEEM_STATE)
               {
                  ticket.currentState = LotteryManager.LOTTERY_REDEEM_STATE;
                  ticket.winningNumbers = LotteryManager.instance.evaluateWinningsForTicket(ticket.ticketData);
                  rewardTickets.push(ticket);
               }
            }
            this.m_ticketsFrame.tickets = rewardTickets;
         }
      }
      
      private function onLotteryOver(result:Object) : void
      {
         var genericPopup:GenericPopup = null;
         if(result.hasOwnProperty("lotteryOver") && result.lotteryOver == true)
         {
            genericPopup = new GenericPopup(ZLocUtils.t("Dialogs","LotteryNoSweepStakesText"),GenericPopup.TYPE_OK);
            UI.displayPopup(genericPopup,false,ZLocUtils.t("Dialogs","LotteryNoSweepStakesText"));
            close();
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LOTTERY_HUD) > 0)
            {
               Global.hud.rightSideIconQueue.removeIconByName("lottery");
            }
         }
         else
         {
            this.m_timeTicker.start();
         }
      }
      
      private function disableCloseButton() : void
      {
         m_window.close_bt.visible = false;
         m_closeButton.enabled = false;
      }
      
      private function enableCloseButton() : void
      {
         m_window.close_bt.visible = true;
      }
      
      private function onBuyTicket(event:Event) : void
      {
         var ticketWindow:LotteryTicketWindow = null;
         var statsPhylum:String = LotteryManager.instance.hasUnclaimedTickets() ? "main_ui_before" : "main_ui_after";
         LotteryManager.instance.logLotteryStats(DIALOG_COUNTER,statsPhylum,"buy_action");
         var lottoMgr:LotteryManager = LotteryManager.instance;
         if(!lottoMgr.hasEnteredCooldown() && lottoMgr.canBuyTickets())
         {
            ticketWindow = new LotteryTicketWindow();
            UI.displayPopup(ticketWindow,false,"lotteryTicket");
         }
         else
         {
            this.m_buyButton.enabled = false;
         }
      }
      
      private function onViewHistory(event:Event) : void
      {
         var historyWindow:LotteryHistoryWindow = null;
         var statsPhylum:String = LotteryManager.instance.hasUnclaimedTickets() ? "main_ui_before" : "main_ui_after";
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,statsPhylum,"history");
         if(this.m_historyTickets != null)
         {
            historyWindow = new LotteryHistoryWindow(this.m_historyTickets);
            UI.displayPopup(historyWindow,false,"lotteryTicket");
         }
         else
         {
            this.m_historyButton.visible = false;
         }
      }
      
      private function onRedeemTickets(event:Event) : void
      {
         this.m_redeemRewardsButton.enabled = false;
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"main_ui_after","action");
         if(this.m_totalPrizeWon > 0)
         {
            LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"redeem_fc",LotteryManager.instance.getActiveTickets().length.toString());
         }
         else
         {
            LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"redeem_consumable",LotteryManager.instance.getActiveTickets().length.toString());
         }
         var redeemTickets:TLottery = new TLottery(TLottery.TYPE_REDEEMTICKETS);
         TransactionManager.addTransaction(redeemTickets,true);
      }
      
      private function refreshFrame(data:Object = null) : void
      {
         if(data.hasOwnProperty("lotteryOver") && data["lotteryOver"] == true)
         {
            close();
         }
      }
      
      public function onPurchaseRefresh(data:Object) : void
      {
         this.m_ticketsFrame.tickets = this.initializeTicketFrame(data["ticket"] as Array,true);
      }
      
      public function onRedeemRefresh(data:Object = null) : void
      {
         this.m_localActiveTickets = LotteryManager.instance.getActiveTickets();
         this.m_mysteryFrame.visible = true;
         this.disableRedeemMode();
         this.resetTimerAndGrandPrize();
      }
      
      private function refreshOnBuyTicket(data:Object = null) : void
      {
      }
      
      override protected function onClose(event:Event) : void
      {
         CarnivalBoothWindow.promoteCarnivalBooth();
         var statsPhylum:String = LotteryManager.instance.hasUnclaimedTickets() ? "main_ui_before" : "main_ui_after";
         LotteryManager.instance.logLotteryStats(DIALOG_COUNTER,statsPhylum,"x");
         LotteryManager.instance.mainWindow = null;
         super.onClose(event);
      }
   }
}

