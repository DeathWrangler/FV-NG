package Widgets.Windows.Lottery
{
   import Classes.LotteryTicket;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.InGamePaymentsManager;
   import Managers.LotteryManager;
   import Transactions.TLottery;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Lottery.LotteryNumSelectionFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class LotteryTicketWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Sweepstakes_myPickUI.swf";
      
      private static const TOTAL_NUMBERS:int = 64;
      
      private var m_ticketNumberWidgets:Vector.<ZwTextField>;
      
      private var m_lotteryNumbersFrame:LotteryNumSelectionFrame;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_costText:ZwTextField;
      
      private var m_selectedNumbers:Array;
      
      private var m_previewTicket:String;
      
      public function LotteryTicketWindow()
      {
         super(ASSET_PATH);
         this.m_selectedNumbers = new Array();
      }
      
      public static function getCashPackage(cashNeeded:int) : Number
      {
         var pack:Object = null;
         var difference:int = 0;
         var cashPackages:Array = InGamePaymentsManager.packages;
         var smallestViable:Number = -1;
         for each(pack in cashPackages)
         {
            difference = parseInt(pack["amount"]) + Global.player.cash - cashNeeded;
            if(difference >= 0 && (difference < smallestViable || smallestViable == -1))
            {
               smallestViable = difference;
            }
         }
         if(smallestViable == -1)
         {
            smallestViable = Global.player.cash - cashNeeded;
         }
         return smallestViable - Global.player.cash + cashNeeded;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var slotNumber:Object = null;
         var number:ZwTextField = null;
         super.onLoadComplete(event);
         this.m_ticketNumberWidgets = new Vector.<ZwTextField>();
         var selectedNumbers:Array = new Array();
         addWidget(new ZwTextField(m_window.mypickDescription_tf,ZLocUtils.t("Dialogs","LotteryPickUpNumbersTitle")),true);
         for(var i:int = 0; i < LotteryManager.TOTAL_BALLS_COUNT; i++)
         {
            slotNumber = new Object();
            slotNumber["data"] = i + 1;
            slotNumber["selected"] = false;
            selectedNumbers.push(slotNumber);
         }
         this.m_lotteryNumbersFrame = new LotteryNumSelectionFrame(m_window.mypickSlotframe_mc,this.onSlotClick);
         addWidget(this.m_lotteryNumbersFrame);
         this.m_lotteryNumbersFrame.lotteryNumbers = selectedNumbers;
         for(var k:int = 0; k < LotteryTicket.LIMIT_NUM_BALLS; k++)
         {
            number = addWidget(new ZwTextField(m_window["mypickSelection_" + k + "_tf"])) as ZwTextField;
            this.m_ticketNumberWidgets.push(number);
         }
         var ticketPrice:Number = Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETPRICE,10);
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ticketPrice.toString(),this.onBuyTicket)) as FarmAnimatedTextButton;
         this.m_buyButton.enabled = false;
         if(Global.player.cash < ticketPrice)
         {
            this.m_buyButton.callback = this.inAppPurchase;
         }
         addWidget(new FarmAnimatedButton(m_window.randomize_bt,this.onGenerateRandomTicket));
      }
      
      private function onSlotClick(slotdata:Object = null) : Boolean
      {
         var index:Number = NaN;
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","number_click",true);
         var shouldShowSelected:Boolean = false;
         if(slotdata != null)
         {
            index = this.m_selectedNumbers.indexOf(Number(slotdata));
            if(index == LotteryTicket.LOTTERY_TICKET_NO_DATA)
            {
               if(this.m_selectedNumbers.length < LotteryTicket.LIMIT_NUM_BALLS)
               {
                  this.m_selectedNumbers.push(Number(slotdata));
                  this.updateTicketText();
                  shouldShowSelected = true;
               }
            }
            else
            {
               this.m_selectedNumbers.splice(index,1);
               this.updateTicketText();
               shouldShowSelected = false;
            }
         }
         var showPurchaseButton:Boolean = this.m_selectedNumbers.length == LotteryTicket.LIMIT_NUM_BALLS ? true : false;
         this.m_buyButton.enabled = showPurchaseButton;
         return shouldShowSelected;
      }
      
      private function updateTicketText() : void
      {
         var totalSlots:Number = this.m_selectedNumbers.length;
         if(totalSlots == LotteryTicket.LIMIT_NUM_BALLS)
         {
            this.m_buyButton.enabled = true;
         }
         else
         {
            this.m_buyButton.enabled = false;
         }
         for(var index:int = 0; index < LotteryTicket.LIMIT_NUM_BALLS; index++)
         {
            this.m_ticketNumberWidgets[index].text = index < totalSlots ? this.m_selectedNumbers[index] : "";
         }
      }
      
      private function onBuyTicket(event:Event) : void
      {
         var payload:Object = null;
         var lotteryTransaction:TLottery = null;
         var newTicket:Object = new Object();
         newTicket["time"] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         newTicket["numbers"] = this.m_selectedNumbers;
         newTicket["redeemed"] = false;
         Global.player.addLotteryTicket(newTicket);
         if(LotteryManager.instance.mainWindow != null)
         {
            LotteryManager.instance.mainWindow.close();
            LotteryManager.instance.queueMainUI();
         }
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","purchase_click");
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","enough");
         var purchaseStatClass:String = "ticket_";
         for(var i:int = 0; i < this.m_selectedNumbers.length; i++)
         {
            purchaseStatClass += this.m_selectedNumbers[i].toString() + "_";
         }
         purchaseStatClass = purchaseStatClass.substr(0,purchaseStatClass.length - 1);
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket",purchaseStatClass);
         var lottoMgr:LotteryManager = LotteryManager.instance;
         if(!lottoMgr.hasEnteredCooldown() && lottoMgr.canBuyTickets())
         {
            Global.player.cash -= Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETPRICE,10);
            payload = new Object();
            payload.selectedNumbers = this.m_selectedNumbers;
            lotteryTransaction = new TLottery(TLottery.TYPE_PURCHASETICKET,payload);
            TransactionManager.addTransaction(lotteryTransaction);
         }
         close();
      }
      
      private function onGenerateRandomTicket(event:Event) : void
      {
         var number:int = 0;
         var slotNumber:Object = null;
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","random_click");
         var numbers:Array = new Array();
         while(numbers.length < Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETNUMBERS,4))
         {
            number = Math.ceil(Math.random() * LotteryManager.TOTAL_BALLS_COUNT);
            if(numbers.indexOf(number) == -1)
            {
               numbers.push(number);
            }
         }
         this.m_selectedNumbers = numbers;
         this.updateTicketText();
         var selectedNumbers:Array = new Array();
         for(var i:int = 0; i < LotteryManager.TOTAL_BALLS_COUNT; i++)
         {
            slotNumber = new Object();
            slotNumber["data"] = i + 1;
            slotNumber["selected"] = numbers.indexOf(slotNumber["data"]) >= 0;
            selectedNumbers.push(slotNumber);
         }
         this.m_lotteryNumbersFrame.lotteryNumbers = selectedNumbers;
      }
      
      private function inAppPurchase(event:Event) : void
      {
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","purchase_click");
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","insufficient");
         var ticketPrice:Number = Global.farmGameSettingsManager.getNumber(LotteryManager.LOTTERY_TICKETPRICE,10);
         PaymentUtil.instance.addCashToCart(getCashPackage(ticketPrice * 2),"LotteryTicket",this.onSuccessGetMoreCash);
      }
      
      protected function onSuccessGetMoreCash(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(this.balanceRefreshed),true);
      }
      
      protected function balanceRefreshed(result:Object) : void
      {
         this.m_buyButton.callback = this.onBuyTicket;
      }
      
      override protected function onClose(event:Event) : void
      {
         LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"buy_ticket","x");
         super.onClose(event);
      }
   }
}

