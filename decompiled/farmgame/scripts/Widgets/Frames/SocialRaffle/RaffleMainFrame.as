package Widgets.Frames.SocialRaffle
{
   import Classes.Friend;
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.SocialRaffleManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SocialRaffle.SocialRaffleWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class RaffleMainFrame extends ZwFrame
   {
      
      protected var m_ticketCounterText:FarmTextField = null;
      
      protected var m_ticketCounterSubTitle:FarmTextField = null;
      
      private var m_parentWindow:SocialRaffleWindow = null;
      
      public function RaffleMainFrame(element:DisplayObject, parentWindow:SocialRaffleWindow)
      {
         super(element);
         this.setupFrame(element);
         this.m_parentWindow = parentWindow;
      }
      
      override public function release() : void
      {
         this.m_ticketCounterText = null;
         this.m_ticketCounterSubTitle = null;
         super.release();
      }
      
      private function setupFrame(element:DisplayObject) : void
      {
         var friendAcceptsForToday:Array = null;
         var i:int = 0;
         var askForHelpFunc:Function = null;
         var askButton:FarmAnimatedTextButton = null;
         var prize:String = null;
         var showYourOdds:Boolean = false;
         var raffleManager:SocialRaffleManager = SocialRaffleManager.getInstance();
         this.addWidget(new FarmTextField(this.element.title_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_main_title")));
         this.addWidget(new FarmTextField(this.element.ticketheader_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_main_ticketheader")));
         var raffleEndTime:Number = raffleManager.raffleDataView.endTime;
         var prizeSubtitle:String = FarmGameUtil.getTimeLeftText(raffleEndTime,"socialrafflebuilding_drawing_");
         this.addWidget(new FarmTextField(this.element.prizetitle_tf,prizeSubtitle));
         var ticketCounter:ZwFrame = null;
         this.addWidget(ticketCounter = new ZwFrame(this.element.ticketcounter_mc));
         var totalTickets:Number = raffleManager.raffleDataView.getTotalNumTickets();
         if(Boolean(raffleManager) && Boolean(raffleManager.raffleDataView))
         {
            this.m_ticketCounterText = ticketCounter.addWidget(new FarmTextField(ticketCounter.element.ticketcounter_tf,totalTickets.toString())) as FarmTextField;
         }
         var ticketSubTitle:String = ZLocUtils.t("Dialogs","socialrafflebuilding_main_ticketsubtitle",{"ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",totalTickets)});
         this.m_ticketCounterSubTitle = new FarmTextField(ticketCounter.element.ticketsubtitle_tf,ticketSubTitle);
         ticketCounter.addWidget(this.m_ticketCounterSubTitle);
         var ticketCount:Number = SocialRaffleConstants.TICKETS_TO_BUY;
         var buyNowText:String = ZLocUtils.t("Dialogs","BuyTicketsNow",{
            "ticketCount":ticketCount,
            "ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",ticketCount)
         });
         if(this.element.buy_bt)
         {
            this.addWidget(new FarmAnimatedTextButton(this.element.buy_bt,buyNowText,this.onBuyRaffleTicket));
         }
         var friendData:Array = [{},{},{},{},{},{}];
         if(Boolean(raffleManager) && Boolean(raffleManager.raffleDataView) && Boolean(raffleManager.raffleDataView.friendAccepts))
         {
            friendAcceptsForToday = raffleManager.raffleDataView.friendAcceptsForToday;
            for(i = 0; i < SocialRaffleConstants.FRIENDS_PER_DAY; i++)
            {
               friendData[i]["friendUid"] = friendAcceptsForToday[i];
               friendData[i]["slotNum"] = i;
            }
            askForHelpFunc = this.onAskForHelp;
            if(friendAcceptsForToday.length >= SocialRaffleConstants.FRIENDS_PER_DAY)
            {
               askForHelpFunc = null;
            }
            askButton = new FarmAnimatedTextButton(this.element.asknow_bt,ZLocUtils.t("Dialogs","AskNow"),askForHelpFunc);
            this.addWidget(askButton);
            askButton.enabled = askForHelpFunc != null;
            askButton.applyGrayOut = askForHelpFunc == null;
            this.addWidget(new RaffleCrewSlotFrame(this.element.friendtickets_mc,friendData,"friendticket","_mc",askForHelpFunc));
         }
         var prizeData:Array = [[],[],[],[],[],[]];
         if(Boolean(raffleManager) && Boolean(raffleManager.raffleDataView) && Boolean(raffleManager.raffleDataView.rewards))
         {
            prizeData = [];
            for(prize in raffleManager.raffleDataView.rewards)
            {
               showYourOdds = false;
               if(parseInt(prize) == raffleManager.raffleDataView.rewards.length - 1)
               {
                  showYourOdds = true;
               }
               prizeData.push({
                  "reward":raffleManager.raffleDataView.rewards[prize],
                  "showYourOdds":showYourOdds,
                  "slotNum":prize
               });
            }
         }
         this.addWidget(new RafflePrizePreviewSlotFrame(this.element.prizes_mc,prizeData));
         var progressData:Array = this.constructProgressData();
         this.addWidget(new RaffleProgressSlotFrame(this.element.progressbar_mc,progressData));
      }
      
      public function constructProgressData() : Array
      {
         var dayOffset:int = 0;
         var i:int = 0;
         var ticketCount:int = 0;
         var names:Array = null;
         var uid:String = null;
         var friendData:Friend = null;
         var raffleManager:SocialRaffleManager = SocialRaffleManager.getInstance();
         var progressData:Array = [[],[],[],[],[],[],[]];
         if(Boolean(raffleManager && raffleManager.raffleDataView && raffleManager.raffleDataView.friendAccepts) && Boolean(raffleManager.raffleDataView.boughtTickets) && Boolean(raffleManager.raffleDataView.startDay))
         {
            dayOffset = raffleManager.raffleDataView.startDay;
            for(i = 0; i < SocialRaffleConstants.DAYS_PER_WEEK; i++)
            {
               ticketCount = 0;
               names = [];
               if(i == 0 && Boolean(raffleManager.raffleDataView.numGivenTickets))
               {
                  ticketCount += raffleManager.raffleDataView.numGivenTickets;
               }
               if(raffleManager.raffleDataView.friendAccepts[i])
               {
                  for each(uid in raffleManager.raffleDataView.friendAccepts[i])
                  {
                     friendData = Global.friendManager.getAppFriendData(uid);
                     if(Boolean(friendData) && Boolean(friendData.name))
                     {
                        names.push(friendData.name);
                     }
                  }
                  ticketCount += raffleManager.raffleDataView.friendAccepts[i].length;
               }
               if(raffleManager.raffleDataView.boughtTickets[i])
               {
                  ticketCount += raffleManager.raffleDataView.boughtTickets[i];
               }
               progressData[i]["tickets"] = ticketCount;
               progressData[i]["names"] = names;
               progressData[i]["slotNumber"] = i;
               progressData[i]["currentDay"] = raffleManager.raffleDataView.currentDay;
               progressData[i]["dayOffset"] = dayOffset;
            }
         }
         return progressData;
      }
      
      public function refreshView() : void
      {
         var prizePreview:RafflePrizePreviewSlotFrame = getWidget(element.prizes_mc) as RafflePrizePreviewSlotFrame;
         prizePreview.refresh();
         var progressBar:RaffleProgressSlotFrame = getWidget(element.progressbar_mc) as RaffleProgressSlotFrame;
         var progressData:Array = this.constructProgressData();
         progressBar.setData(progressData);
         progressBar.refresh();
      }
      
      public function onAskForHelp(event:MouseEvent) : void
      {
         SocialRaffleManager.getInstance().askForCrew("ui");
      }
      
      public function onBuyRaffleTicket(event:MouseEvent) : void
      {
         var canBuy:Boolean = false;
         var ticketText:String = null;
         var ticketsConfirm:GenericPopup = null;
         var dialog:ImpulseBuy = null;
         var impulseBuyCallback:Function = null;
         var ticketCount:Number = SocialRaffleConstants.TICKETS_TO_BUY;
         var totalPrice:Number = SocialRaffleConstants.DEFAULT_TICKET_PRICE * ticketCount;
         canBuy = Global.player.canBuyCash(totalPrice,false);
         this.m_parentWindow.enableInput = false;
         if(canBuy)
         {
            ticketText = ZLocUtils.t("Dialogs","socialrafflebuilding_UI_buy_tickets",{
               "ticketCount":ticketCount,
               "cashAmount":totalPrice,
               "ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",ticketCount)
            });
            ticketsConfirm = new GenericPopup(ticketText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyTicketsCallback);
            UI.displayPopup(ticketsConfirm,false);
         }
         else
         {
            dialog = new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH,"socialraffleticket");
            impulseBuyCallback = function(event:ImpulseBuyEvent):void
            {
               m_parentWindow.enableInput = true;
               (event.target as ImpulseBuy).removeEventListener(ImpulseBuyEvent.ACCEPT,impulseBuyCallback);
               (event.target as ImpulseBuy).removeEventListener(ImpulseBuyEvent.CANCEL,impulseBuyCallback);
            };
            dialog.addEventListener(ImpulseBuyEvent.ACCEPT,impulseBuyCallback);
            dialog.addEventListener(ImpulseBuyEvent.CANCEL,impulseBuyCallback);
            UI.displayPopup(dialog,false);
         }
      }
      
      private function buyTicketsCallback(event:GenericPopupEvent) : void
      {
         var totalTickets:Number = NaN;
         if(event.button == GenericPopup.ACCEPT)
         {
            SocialRaffleManager.getInstance().buyRaffleTickets(SocialRaffleConstants.TICKETS_TO_BUY);
            totalTickets = SocialRaffleManager.getInstance().raffleDataView.getTotalNumTickets();
            this.m_ticketCounterText.text = totalTickets.toString();
            this.m_ticketCounterSubTitle.text = ZLocUtils.t("Dialogs","socialrafflebuilding_main_ticketsubtitle",{"ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",totalTickets)});
            this.refreshView();
         }
         this.m_parentWindow.enableInput = true;
      }
   }
}

