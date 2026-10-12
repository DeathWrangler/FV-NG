package Widgets.Windows.Lottery
{
   import Classes.LotteryTicket;
   import Classes.util.ZLocUtils;
   import Managers.LotteryManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Lottery.LotteryTicketFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class LotteryHistoryWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Sweepstakes_myhistoryUI.swf";
      
      private var m_winningNumbers:Array;
      
      private var m_ticketsFrame:LotteryTicketFrame;
      
      private var m_tickets:Array;
      
      private var m_data:Object;
      
      public function LotteryHistoryWindow(data:Object = null)
      {
         super(ASSET_PATH);
         this.m_data = data;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.m_winningNumbers = new Array();
         var claimedTicket:Object = LotteryManager.instance.getClaimedTickets()[0];
         this.m_winningNumbers = LotteryManager.instance.getWinningNumbers(LotteryManager.instance.getTicketsEndTime(claimedTicket["time"]));
         addWidget(new ZwTextField(m_window.historyDescription_tf,ZLocUtils.t("Dialogs","LotteryHistoryNumbers")));
         this.m_ticketsFrame = new LotteryTicketFrame(m_window.historyslotFrame_mc,LotteryManager.LOTTERY_HISTORY);
         addWidget(this.m_ticketsFrame);
         this.m_ticketsFrame.tickets = this.initializeTicketFrame();
         var historyTotWinningNos:int = this.m_winningNumbers != null ? int(this.m_winningNumbers.length) : 0;
         var k:int = 0;
         while(k < Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETNUMBERS) && k < historyTotWinningNos)
         {
            addWidget(new ZwTextField(m_window["historySelection_" + k + "_tf"],this.m_winningNumbers[k]),true) as ZwTextField;
            k++;
         }
      }
      
      private function initializeTicketFrame() : Array
      {
         var j:int = 0;
         var playerTicket:Object = null;
         var ticket:LotteryTicket = null;
         var lottoMgr:LotteryManager = LotteryManager.instance;
         var ticketNumbers:Object = new Object();
         var checkWinningNumbers:Boolean = true;
         var lotteryTickets:Array = lottoMgr.getClaimedTickets();
         this.m_tickets = new Array();
         if(lotteryTickets != null)
         {
            for(j = 0; j < lotteryTickets.length; j++)
            {
               playerTicket = lotteryTickets[j];
               if(playerTicket != null)
               {
                  ticket = new LotteryTicket(playerTicket);
                  ticket.currentState = LotteryManager.LOTTERY_REDEEM_STATE;
                  ticket.winningNumbers = lottoMgr.evaluateWinningsForTicket(playerTicket);
                  this.m_tickets.push(ticket);
               }
            }
         }
         return this.m_tickets;
      }
      
      private function onSlotClick(slotdata:Object = null) : Boolean
      {
         return false;
      }
      
      private function updateTicketText() : void
      {
      }
      
      private function updateButtonText() : void
      {
      }
      
      override protected function release() : void
      {
         super.release();
      }
   }
}

