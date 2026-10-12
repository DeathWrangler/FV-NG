package Widgets.Slots.Lottery
{
   import Classes.LotteryTicket;
   import Display.UI;
   import Managers.LotteryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Lottery.LotteryMainWindow;
   import Widgets.Windows.Lottery.LotteryTicketWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LotteryTicketSlot extends ZwSlotFrame
   {
      
      private var m_slots:Vector.<ZwBaseWidget>;
      
      private var m_purchaseTicket:ZwBaseWidget;
      
      private var m_powerballs:Vector.<ZwWidget>;
      
      private var m_numbers:Vector.<ZwTextField>;
      
      private var m_data:Object;
      
      private var m_parentWindow:LotteryMainWindow;
      
      private var m_frameType:String;
      
      private var m_winnings:ZwTextField;
      
      public function LotteryTicketSlot(element:DisplayObject, frameType:String)
      {
         var number:ZwTextField = null;
         this.m_frameType = frameType;
         super(element);
         this.m_slots = new Vector.<ZwBaseWidget>();
         this.m_numbers = new Vector.<ZwTextField>();
         var slotName:String = m_element.name;
         this.m_purchaseTicket = new ZwBaseWidget(m_element["purchaseTicket_mc"]);
         addWidget(new FarmAnimatedButton(m_element["purchaseTicket_mc"],this.onBuyTicket));
         addWidget(new ZwBaseWidget(m_element["unlocked_mc"]));
         addWidget(new ZwBaseWidget(m_element["redeem_mc"]));
         addWidget(new ZwBaseWidget(m_element["redeem_mc"]["redeemCost_mc"]));
         this.m_winnings = new ZwTextField(m_element["redeem_mc"]["redeemCost_mc"]["redeemCost_tf"],"?");
         addWidget(this.m_winnings);
         for(var i:int = 0; i < LotteryTicket.LIMIT_NUM_BALLS; i++)
         {
            number = new ZwTextField(m_element["pick_" + i + "_tf"],"");
            addWidget(number);
            this.m_numbers.push(number);
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         var i:int = 0;
         super.populate(data);
         this.m_data = data;
         var showPurchaseTickets:Boolean = false;
         if(this.m_data)
         {
            for(i = 0; i < LotteryTicket.LIMIT_NUM_BALLS; i++)
            {
               if(Boolean(this.m_data.hasOwnProperty("ticketData")) && Boolean(this.m_data.ticketData.hasOwnProperty("numbers")) && this.m_data.ticketData.numbers[i] != null)
               {
                  if(this.m_data.ticketData.numbers[i] == LotteryTicket.LOTTERY_TICKET_NO_DATA)
                  {
                     if(!LotteryManager.instance.hasEnteredCooldown())
                     {
                        showPurchaseTickets = true;
                        break;
                     }
                     (getWidget(m_element["pick_" + i + "_tf"]) as ZwTextField).text = "";
                     (getWidget(m_element["pick_" + i + "_tf"]) as ZwTextField).visible = true;
                  }
                  else
                  {
                     (getWidget(m_element["pick_" + i + "_tf"]) as ZwTextField).text = this.m_data.ticketData.numbers[i];
                     (getWidget(m_element["pick_" + i + "_tf"]) as ZwTextField).visible = true;
                  }
                  if(this.m_data.hasOwnProperty("currentState"))
                  {
                     if(this.m_data.currentState == LotteryManager.LOTTERY_REDEEM_STATE)
                     {
                        if(this.m_data.winningNumbers > 0)
                        {
                           (getWidget(m_element["redeem_mc"]) as ZwBaseWidget).visible = true;
                           (getWidget(m_element["redeem_mc"]["redeemCost_mc"]) as ZwBaseWidget).visible = true;
                           this.m_winnings.visible = true;
                           this.m_winnings.text = this.m_data.winningNumbers;
                        }
                        else
                        {
                           (getWidget(m_element["unlocked_mc"]) as ZwBaseWidget).visible = true;
                        }
                     }
                     else
                     {
                        (getWidget(m_element["unlocked_mc"]) as ZwBaseWidget).visible = true;
                     }
                  }
               }
            }
         }
         (getWidget(m_element.purchaseTicket_mc) as ZwBaseWidget).visible = showPurchaseTickets;
      }
      
      private function onBuyTicket(event:Event) : void
      {
         var statsPhylum:String = null;
         var ticketWindow:LotteryTicketWindow = null;
         if(!LotteryManager.instance.hasEnteredCooldown() && LotteryManager.instance.canBuyTickets())
         {
            statsPhylum = LotteryManager.instance.hasUnclaimedTickets() ? "main_ui_before" : "main_ui_after";
            LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,statsPhylum,"buy_ticket");
            ticketWindow = new LotteryTicketWindow();
            UI.displayPopup(ticketWindow,false,"lotteryTicket");
         }
      }
   }
}

