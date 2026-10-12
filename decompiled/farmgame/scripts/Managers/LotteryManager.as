package Managers
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.CarnivalBoothQueuedIcon;
   import Display.UI;
   import Widgets.Windows.Lottery.LotteryMainWindow;
   import flash.utils.Dictionary;
   
   public class LotteryManager
   {
      
      public static const FEATURE_NAME:String = "lottery";
      
      public static const TOTAL_NUMBERS:int = 4;
      
      public static const TOTAL_BALLS_COUNT:int = 64;
      
      public static const LOTTERY_TOTALNUMBERS:String = "lotteryTotalNumbers";
      
      public static const LOTTERY_TICKETNUMBERS:String = "lotteryTicketNumbers";
      
      public static const LOTTERY_REDEEM_STATE:String = "lotteryRedeem";
      
      public static const LOTTERY_PLAYING_STATE:String = "lotteryPlay";
      
      public static const LOTTERY_HISTORY:String = "lotteryHistory";
      
      public static const LOTTERY_CURRENT:String = "lotteryCurrent";
      
      public static const LOTTERY_TICKETPRICE:String = "lotteryTicketPrice";
      
      public static const LOTTERY_MAXTICKETS:String = "lotteryMaxTickets";
      
      public static const LOTTERY_CONSOLATIONPRIZE:String = "lotteryConsolationPrize";
      
      public static const LOTTERY_PAYOUTPREFIX:String = "lotteryPayout_";
      
      public static const LOTTERY_COOLDOWN:String = "lotteryCooldownTime";
      
      private static const m_instance:LotteryManager = new LotteryManager(SingletonLock);
      
      private static const RUNTIME_BUY_SWITCH:String = "SWEEPSTAKES_BUY";
      
      public static const STATS_KINGDOM:String = "fv_paid_lottery";
      
      public static const TIMER_DELAY:Number = 30;
      
      private var m_pastWinningNumbers:Dictionary;
      
      private var m_pastGrandPrizes:Dictionary;
      
      private var m_lotteryStart:Number;
      
      private var m_lotteryEnd:Number;
      
      private var m_grandPrizeStart:Number;
      
      private var m_grandPrizeEnd:Number;
      
      private var m_scheduledMainUI:Boolean = false;
      
      private var m_scheduledCallback:Function = null;
      
      private var m_mainWindow:LotteryMainWindow;
      
      public function LotteryManager(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid LotteryManager Singleton access. Use LotteryManager.instance");
         }
      }
      
      public static function get instance() : LotteryManager
      {
         return m_instance;
      }
      
      public function get featureName() : String
      {
         return FEATURE_NAME;
      }
      
      public function init(data:Object) : void
      {
         var lotteryWindow:LotteryMainWindow = null;
         var index:String = null;
         var timestamp:Number = NaN;
         var experimentVariant:Number = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LOTTERY);
         if(experimentVariant > 0 && data != null)
         {
            this.m_pastWinningNumbers = new Dictionary();
            this.m_pastGrandPrizes = new Dictionary();
            if(data.hasOwnProperty("current") && data.current != null)
            {
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LOTTERY_HUD) > 0)
               {
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_HUD) >= 2)
                  {
                     CarnivalBoothQueuedIcon.showHUDIcon();
                  }
                  else
                  {
                     this.logLotteryStats("dialog","hud","view");
                     Global.hud.rightSideIconQueue.addIcon("lottery",DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
                  }
               }
               this.m_lotteryStart = data.current.start;
               this.m_lotteryEnd = data.current.end;
               this.m_grandPrizeStart = data.current.grandPrize.start;
               this.m_grandPrizeEnd = data.current.grandPrize.end;
               if(this.m_scheduledMainUI)
               {
                  lotteryWindow = new LotteryMainWindow();
                  UI.displayPopup(lotteryWindow,false,"lotteryMain",true);
                  if(this.m_scheduledCallback != null)
                  {
                     this.m_scheduledCallback();
                  }
               }
            }
            if(data.hasOwnProperty("pastLotteries") && data.pastLotteries.length != 0)
            {
               for(index in data.pastLotteries)
               {
                  if(data.pastLotteries[index])
                  {
                     timestamp = Number(index);
                     this.m_pastWinningNumbers[timestamp] = data.pastLotteries[index].numbers;
                     this.m_pastGrandPrizes[timestamp] = data.pastLotteries[index].grandPrize.end;
                  }
               }
            }
         }
      }
      
      public function queueMainUI(launchCallBack:Function = null) : void
      {
         var lotteryWindow:LotteryMainWindow = null;
         this.m_scheduledCallback = launchCallBack;
         if(this.m_pastGrandPrizes != null && this.m_pastWinningNumbers != null)
         {
            lotteryWindow = new LotteryMainWindow();
            UI.displayPopup(lotteryWindow,false,"lotteryMain",true);
            if(this.m_scheduledCallback != null)
            {
               this.m_scheduledCallback();
            }
         }
         else
         {
            this.m_scheduledMainUI = true;
         }
      }
      
      public function updateConfiguration(result:Object) : void
      {
         this.m_pastGrandPrizes[this.m_lotteryEnd] = this.m_grandPrizeEnd;
         this.m_lotteryStart = result.start;
         this.m_lotteryEnd = result.end;
         this.m_grandPrizeStart = result.grandPrize.start;
         this.m_grandPrizeEnd = result.grandPrize.end;
      }
      
      public function canBuyTickets() : Boolean
      {
         var buyEnabled:Boolean = Boolean(Global.flashHotParams[RUNTIME_BUY_SWITCH]);
         var experimentVariant:Number = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LOTTERY);
         var hasUnclaimedTickets:Boolean = this.hasUnclaimedTickets();
         return buyEnabled && !hasUnclaimedTickets && experimentVariant > 0;
      }
      
      public function getActiveTickets() : Array
      {
         var result:Array = new Array();
         var ticketsNumber:Number = Global.player.lotteryTickets.length;
         for(var i:int = 0; i < ticketsNumber; i++)
         {
            if(Global.player.lotteryTickets[i].redeemed == false)
            {
               result.push(Global.player.lotteryTickets[i]);
            }
         }
         return result;
      }
      
      public function getClaimedTickets() : Array
      {
         var result:Array = new Array();
         var ticketsNumber:Number = Global.player.lotteryTickets.length;
         for(var i:int = 0; i < ticketsNumber; i++)
         {
            if(Global.player.lotteryTickets[i].redeemed == true)
            {
               result.push(Global.player.lotteryTickets[i]);
            }
         }
         return result;
      }
      
      public function hasUnclaimedTickets() : Boolean
      {
         var ticket:Object = null;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         for(var i:int = 0; i < Global.player.lotteryTickets.length; i++)
         {
            ticket = Global.player.lotteryTickets[i];
            if(ticket.redeemed == false && this.getCurrentLotteryEnd(ticket.time) < now)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getWinningNumbers(timestamp:Number) : Array
      {
         return this.m_pastWinningNumbers.hasOwnProperty(timestamp) ? this.m_pastWinningNumbers[timestamp] : null;
      }
      
      public function updateWinningNumbers(timestamp:Number, winningNumbers:Array) : void
      {
         this.m_pastWinningNumbers[timestamp] = winningNumbers;
      }
      
      public function getGrandPrize(timestamp:uint) : Number
      {
         var progressionTotal:Number = this.m_grandPrizeEnd - this.m_grandPrizeStart;
         timestamp = timestamp < this.m_lotteryStart ? uint(this.m_lotteryStart) : timestamp;
         timestamp = timestamp > this.m_lotteryEnd ? uint(this.m_lotteryEnd) : timestamp;
         var lotteryOffset:Number = 1 - (this.m_lotteryEnd - timestamp) / (this.m_lotteryEnd - this.m_lotteryStart);
         var progressionIncrement:Number = Math.round((this.m_grandPrizeEnd - this.m_grandPrizeStart) * lotteryOffset);
         return this.m_grandPrizeStart + progressionIncrement;
      }
      
      public function getTicketsEndTime(timestamp:uint) : uint
      {
         var key:String = null;
         var endTime:Number = NaN;
         var startTime:Number = NaN;
         var result:uint = 0;
         var lotteryDuration:uint = FarmGameUtil.NUM_DAYS_IN_WEEK * FarmGameUtil.NUM_SECS_IN_DAY;
         if(this.m_lotteryStart <= timestamp && timestamp <= this.m_lotteryEnd)
         {
            result = this.m_lotteryEnd;
         }
         for(key in this.m_pastWinningNumbers)
         {
            endTime = Number(key);
            startTime = endTime - lotteryDuration;
            if(timestamp >= startTime && timestamp <= endTime)
            {
               result = endTime;
               break;
            }
         }
         return result;
      }
      
      public function getCurrentLotteryStart(timestamp:Number = 0) : uint
      {
         return this.m_lotteryStart;
      }
      
      public function getCurrentLotteryEnd(timestamp:Number = 0) : uint
      {
         return this.m_lotteryEnd;
      }
      
      public function hasEnteredCooldown() : Boolean
      {
         var serverTime:uint = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return this.m_lotteryEnd > serverTime && this.m_lotteryEnd - serverTime < Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_COOLDOWN,900);
      }
      
      public function offBoardLottery() : void
      {
         var ticket:Object = null;
         var numTickets:Number = Global.player.lotteryTickets.length;
         var newHistory:Array = new Array();
         for(var i:int = 0; i < numTickets; i++)
         {
            ticket = Global.player.lotteryTickets[i];
            if(ticket.redeemed == false)
            {
               ticket.redeemed = true;
               newHistory.push(ticket);
            }
         }
         Global.player.lotteryTickets = newHistory;
      }
      
      public function evaluateWinningsForTicket(ticket:Object) : int
      {
         var matches:int = 0;
         var i:int = 0;
         var result:int = 0;
         var endTime:uint = this.getTicketsEndTime(ticket.time);
         var winningNumbers:Array = this.getWinningNumbers(endTime);
         var ticketNumbers:Array = ticket.numbers;
         if(winningNumbers != null)
         {
            matches = 0;
            for(i = 0; i < ticketNumbers.length; i++)
            {
               if(winningNumbers.indexOf(int(ticketNumbers[i])) >= 0)
               {
                  matches++;
               }
            }
            if(matches > 0 && matches < LotteryManager.TOTAL_NUMBERS)
            {
               result = Math.round(Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_PAYOUTPREFIX + matches.toString()) * Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETPRICE,10));
            }
            else if(matches == LotteryManager.TOTAL_NUMBERS)
            {
               result = this.m_pastGrandPrizes[endTime] ? int(this.m_pastGrandPrizes[endTime]) : -1;
            }
         }
         return result;
      }
      
      public function logLotteryStats(counter:String, phylum:String, classKey:String, sample:Boolean = false) : void
      {
         if(sample)
         {
            FarmStatsManager.sample(100,counter,LotteryManager.STATS_KINGDOM,phylum,classKey,this.m_lotteryEnd.toString());
         }
         else
         {
            FarmStatsManager.count(counter,LotteryManager.STATS_KINGDOM,phylum,classKey,this.m_lotteryEnd.toString());
         }
      }
      
      public function get mainWindow() : LotteryMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(window:LotteryMainWindow) : void
      {
         this.m_mainWindow = window;
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
