package Widgets.Frames.SocialRaffle
{
   import Classes.Friend;
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.SocialRaffle.SocialRaffleReward;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.SocialRaffleManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.SocialRaffle.RafflePrizePreviewSlot;
   import Widgets.Slots.SocialRaffle.RaffleTicketSlot;
   import Widgets.Windows.SocialRaffle.SocialRaffleWindow;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public final class RaffleGameFrame extends ZwFrame
   {
      
      private static const STATE_INITIAL:int = 0;
      
      private static const STATE_WAITING_FOR_START:int = 1;
      
      private static const STATE_DECODING:int = 2;
      
      private static const STATE_WAITING_FOR_NEXT:int = 3;
      
      private static const STATE_SHARE_WIN:int = 4;
      
      private static const STATE_DONE:int = 5;
      
      private static const TICKET_SLOT_PREFIX:String = "gameticket";
      
      private static const OVERFLOW_TICKET_SLOT_PREFIX:String = "overflowTicket";
      
      public static const MAX_TICKET_SLOT:int = 6;
      
      public static const MAX_OVERFLOW_TICKET_SLOT:int = 21;
      
      private var m_window:SocialRaffleWindow;
      
      private var m_remainingRaffleTickets:Array;
      
      private var m_winningBurst:ZwFrame = null;
      
      private var m_winningTicket:Object;
      
      private var m_raffleTicketSlotFrame:RaffleTicketSlotFrame;
      
      private var m_overflowTicketSlotFrame:RaffleTicketSlotFrame;
      
      private var m_titleTextField:ZwTextField;
      
      private var m_skipButton:FarmAnimatedTextButton;
      
      private var m_startRaffleButton:FarmAnimatedTextButton;
      
      private var m_nextButton:FarmAnimatedTextButton;
      
      private var m_raffleTicketCounterFrame:RaffleTicketCounterFrame;
      
      private var m_ticketOverflowTextField:ZwTextField;
      
      private var m_winningNumberFrame:RaffleWinningNumberFrame;
      
      private var m_raffleIndex:int = 0;
      
      private var m_raffleReward:SocialRaffleReward = null;
      
      private var m_callback:Function;
      
      private var m_iState:int;
      
      private var m_prizePreviewSlotFrame:RafflePrizePreviewSlotFrame = null;
      
      private var m_tempData:Object = {};
      
      public function RaffleGameFrame(element:DisplayObject, window:SocialRaffleWindow)
      {
         super(element);
         this.m_window = window;
         this.m_iState = STATE_INITIAL;
         this.m_callback = null;
         this.resetTickets();
         this.setupFrame(element);
         this.m_iState = STATE_WAITING_FOR_START;
         this.m_winningBurst = addWidget(new ZwFrame(this.m_element.winningburst_mc),false) as ZwFrame;
      }
      
      public function startGame(callback:Function) : void
      {
         this.m_callback = callback;
         this.setupRaffle(0);
         this.m_iState = STATE_WAITING_FOR_START;
      }
      
      private function resetTickets() : void
      {
         var userTicket:Object = null;
         this.m_winningTicket = null;
         var userRaffleTickets:Array = SocialRaffleManager.getInstance().userRaffleTickets;
         this.m_remainingRaffleTickets = new Array();
         for(var iTicket:int = 0; iTicket < userRaffleTickets.length; iTicket++)
         {
            userTicket = userRaffleTickets[iTicket];
            this.m_remainingRaffleTickets.push({
               "uid":userTicket.uid,
               "number":userTicket.number
            });
         }
         if(this.m_raffleTicketSlotFrame != null)
         {
            this.m_raffleTicketSlotFrame.visible = false;
            this.m_raffleTicketSlotFrame.resetAllSlots();
            this.updateTicketFrame();
         }
      }
      
      private function setupRaffle(raffleIndex:int) : Boolean
      {
         var reward:Object = null;
         var chanceString:String = null;
         var userChance:Number = NaN;
         var userChanceString:String = null;
         var newX:Number = NaN;
         var newY:Number = NaN;
         var bResult:Boolean = false;
         var raffleDataView:Object = SocialRaffleManager.getInstance().raffleDataView;
         var rewards:Array = raffleDataView.rewards;
         var grantedRewards:Array = raffleDataView.grantedRewards;
         this.m_raffleIndex = raffleIndex;
         this.m_raffleReward = null;
         if(this.m_raffleIndex < rewards.length)
         {
            if(grantedRewards[this.m_raffleIndex].wonPrize)
            {
               this.m_raffleReward = grantedRewards[this.m_raffleIndex];
            }
            reward = rewards[this.m_raffleIndex];
            chanceString = SocialRaffleWindow.generateOddsString(reward.chance,"","0:1");
            userChance = reward.chance * raffleDataView.getTotalNumTickets();
            userChanceString = SocialRaffleWindow.generateOddsString(userChance,"","0:1");
            bResult = true;
         }
         this.m_winningNumberFrame.setTitleText(ZLocUtils.t("Dialogs","socialrafflebuilding_game_winningnumber_title"));
         var currentPrizeSlot:RafflePrizePreviewSlot = this.m_prizePreviewSlotFrame.getRafflePrizeFrame(this.m_raffleIndex);
         if(currentPrizeSlot != null)
         {
            newX = currentPrizeSlot.x - 50;
            newY = currentPrizeSlot.y - 85;
            this.m_prizePreviewSlotFrame.setArrowPosition(newX,newY);
            currentPrizeSlot.toggleHighlight(true);
            if(this.m_raffleIndex > 0)
            {
               this.m_prizePreviewSlotFrame.getRafflePrizeFrame(this.m_raffleIndex - 1).toggleHighlight(false);
            }
         }
         return bResult;
      }
      
      private function setupFrame(element:DisplayObject) : void
      {
         var prize:String = null;
         var showYourOdds:Boolean = false;
         this.m_titleTextField = new ZwTextField(this.element.rafflepartytitle_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_game_title"));
         addWidget(this.m_titleTextField);
         this.m_ticketOverflowTextField = new ZwTextField(this.element.ticketoverflow_tf);
         addWidget(this.m_ticketOverflowTextField,false);
         this.m_startRaffleButton = new FarmAnimatedTextButton(this.element.startraffle_bt,ZLocUtils.t("Dialogs","socialrafflebuilding_game_startButton"),this.onStartRaffle);
         addWidget(this.m_startRaffleButton);
         this.m_skipButton = new FarmAnimatedTextButton(this.element.skip_bt,ZLocUtils.t("Dialogs","socialrafflebuilding_game_skipButton"),this.onSkipToResults);
         addWidget(this.m_skipButton,false);
         this.m_nextButton = new FarmAnimatedTextButton(this.element.next_bt,ZLocUtils.t("Dialogs","socialrafflebuilding_game_nextButton"),this.onNextRaffle);
         addWidget(this.m_nextButton,false);
         this.m_raffleTicketSlotFrame = new RaffleTicketSlotFrame(this.element.gametickets_mc,this.m_remainingRaffleTickets,TICKET_SLOT_PREFIX,MAX_TICKET_SLOT);
         addWidget(this.m_raffleTicketSlotFrame,false);
         this.m_overflowTicketSlotFrame = new RaffleTicketSlotFrame(this.element.overflowTickets_mc,this.m_remainingRaffleTickets,OVERFLOW_TICKET_SLOT_PREFIX,MAX_OVERFLOW_TICKET_SLOT);
         addWidget(this.m_overflowTicketSlotFrame,true);
         this.updateTicketFrame();
         var raffleManager:SocialRaffleManager = SocialRaffleManager.getInstance();
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
         this.m_prizePreviewSlotFrame = this.addWidget(new RafflePrizePreviewSlotFrame(this.element.prizes_mc,prizeData)) as RafflePrizePreviewSlotFrame;
         this.m_raffleTicketCounterFrame = new RaffleTicketCounterFrame(this.element.ticketcounter_mc);
         addWidget(this.m_raffleTicketCounterFrame);
         this.m_winningNumberFrame = new RaffleWinningNumberFrame(this.element.winningnumber_mc);
         addWidget(this.m_winningNumberFrame,false);
      }
      
      private function onStartRaffle(event:MouseEvent) : void
      {
         var totalTickets:Number = NaN;
         if(this.m_iState == STATE_WAITING_FOR_START)
         {
            this.m_startRaffleButton.visible = false;
            this.m_winningNumberFrame.visible = true;
            this.m_skipButton.visible = true;
            this.m_skipButton.enabled = true;
            this.m_nextButton.visible = false;
            this.startDecoding();
            totalTickets = SocialRaffleManager.getInstance().raffleDataView.getTotalNumTickets();
            FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"drawing","open",String(totalTickets));
         }
      }
      
      private function onSkipToResults(event:MouseEvent) : void
      {
         if(this.m_iState == STATE_WAITING_FOR_NEXT)
         {
            this.onNextRaffle(event);
         }
         if(this.m_iState == STATE_DECODING)
         {
            this.m_winningNumberFrame.skipDecoding();
            this.onDecodeAllLetters();
         }
         if(this.m_raffleReward != null)
         {
            FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"drawing","skipped",this.m_raffleReward.itemName);
         }
      }
      
      private function onNextRaffle(event:MouseEvent) : void
      {
         if(this.m_iState == STATE_WAITING_FOR_NEXT)
         {
            this.setupNextRaffle();
            this.m_winningNumberFrame.resetColors();
         }
      }
      
      private function shareWin(isFarmCashTicket:Boolean) : void
      {
         var raffleItem:FarmItem = null;
         this.m_iState = STATE_SHARE_WIN;
         this.m_tempData.isFarmCashTicket = isFarmCashTicket;
         this.m_tempData.prizeItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_raffleReward.itemName);
         this.m_tempData.endRaffleRewardLink = this.m_raffleReward.rewardLink;
         var dialogText:String = "";
         var iconUrl:String = "";
         var friend:Friend = Global.friendManager.getFriendData(this.m_winningTicket.uid);
         if(isFarmCashTicket || friend == null)
         {
            raffleItem = Global.farmGameSettingsManager.getFarmItemByName("socialraffleticket");
            dialogText = ZLocUtils.t("Dialogs","socialrafflebuilding_game_share_win_feed");
            iconUrl = raffleItem.icon;
         }
         else
         {
            dialogText = ZLocUtils.t("Dialogs","socialrafflebuilding_game_share_win_w2w",{"user":ZLocUtils.tn(friend.firstName,ZLocUtils.tg(friend.snUser.gender))});
            iconUrl = friend.picture;
         }
         var dialog:GenericIconPopup = new GenericIconPopup(dialogText,GenericPopup.TYPE_SHARECANCEL,this.onCloseShareDialog,iconUrl,false,true);
         UI.displayPopup(dialog,false,"RaffleGameFrameShareWin",true);
         this.m_window.pause();
      }
      
      private function onCloseShareDialog(event:GenericPopupEvent) : void
      {
         var uids:Array = null;
         var friend:Friend = null;
         var prizeItem:FarmItem = null;
         var prizeItemName:String = null;
         var feedImage:String = null;
         var messageType:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.OK)
         {
            uids = new Array();
            friend = Global.friendManager.getFriendData(this.m_winningTicket.uid);
            prizeItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_raffleReward.itemName);
            prizeItemName = prizeItem.friendlyName;
            if(Boolean(this.m_tempData.isFarmCashTicket) || friend == null)
            {
               prizeItem = Global.farmGameSettingsManager.getFarmItemByName("socialraffleticket");
            }
            feedImage = this.m_tempData.imagePath;
            messageType = "";
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_tempData.endRaffleRewardLink,
                  "src":prizeItem.icon
               }],
               "user":Global.player.firstName,
               "reward_link":this.m_tempData.endRaffleRewardLink,
               "item":ZLocUtils.tk_pk_asTitle(prizeItemName)
            };
            if(Boolean(this.m_tempData.isFarmCashTicket) || friend == null)
            {
               messageType = "SocialRaffleShareWin_Feed";
               FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"drawing","prize_win_shared",prizeItemName);
            }
            else
            {
               uids.push(this.m_winningTicket.uid);
               messageType = "SocialRaffleShareWin_W2W";
               FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"drawing","prize_gifted",prizeItemName);
            }
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,uids,false,this.onShareComplete);
         }
         else
         {
            this.onShareComplete();
         }
         this.m_tempData = {};
      }
      
      private function onShareComplete() : void
      {
         if(this.m_iState == STATE_SHARE_WIN)
         {
            if(this.m_window)
            {
               this.m_window.unpause();
               this.m_window.toggleCloseButton(false);
            }
            if(this.m_nextButton)
            {
               this.m_nextButton.applyGrayOut = false;
            }
            this.m_iState = STATE_WAITING_FOR_NEXT;
         }
      }
      
      private function setupNextRaffle() : void
      {
         this.m_winningBurst.visible = false;
         this.m_nextButton.visible = false;
         this.m_skipButton.enabled = true;
         this.m_skipButton.applyGrayOut = false;
         this.resetTickets();
         if(this.setupRaffle(this.m_raffleIndex + 1))
         {
            this.updateTicketFrame();
            this.startDecoding();
         }
         else
         {
            hideAllWidgets();
            this.m_iState = STATE_DONE;
            this.m_callback();
         }
      }
      
      private function reduceRemainingTickets(numDecoded:int) : void
      {
         var ticket:Object = null;
         var prefix:String = this.m_winningTicket.number.substring(0,numDecoded);
         var newRemaining:Array = new Array();
         for each(ticket in this.m_remainingRaffleTickets)
         {
            if(Boolean(ticket.number) && ticket.number.substring(0,numDecoded) == prefix)
            {
               newRemaining.push(ticket);
            }
         }
         this.m_remainingRaffleTickets = newRemaining;
      }
      
      private function onDecodeLetter(fullText:String, numDecoded:int) : void
      {
         this.reduceRemainingTickets(numDecoded);
         this.updateTicketFrame();
         this.m_winningNumberFrame.updateDecodedText(fullText);
         if(this.m_remainingRaffleTickets.length > 0)
         {
            this.m_winningNumberFrame.changeColor(numDecoded - 1,65280);
         }
         else
         {
            this.m_winningNumberFrame.changeColor(numDecoded - 1,16711680);
         }
      }
      
      private function onDecodeAllLetters() : void
      {
         if(this.m_raffleReward != null && !this.m_raffleReward.hasProcessed)
         {
            SocialRaffleManager.getInstance().grantReward(this.m_raffleIndex);
         }
         this.reduceRemainingTickets(this.m_winningTicket.number.length);
         this.m_nextButton.visible = true;
         this.m_skipButton.enabled = false;
         this.m_skipButton.applyGrayOut = true;
         this.m_winningNumberFrame.updateDecodedText(this.m_winningTicket.number);
         this.m_raffleTicketCounterFrame.updateTicketCount();
         this.updateTicketFrame();
         var currentPrizeSlot:RafflePrizePreviewSlot = this.m_prizePreviewSlotFrame.getRafflePrizeFrame(this.m_raffleIndex);
         if(this.m_raffleReward != null)
         {
            this.m_winningNumberFrame.setTitleText(ZLocUtils.t("Dialogs","socialrafflebuilding_game_winningnumber_title_win"));
            currentPrizeSlot.toggleRaffleResult(true);
            this.playWinningAnimation();
            this.m_winningNumberFrame.changeColorsAll(65280);
         }
         else
         {
            this.m_winningNumberFrame.setTitleText(ZLocUtils.t("Dialogs","socialrafflebuilding_game_winningnumber_title_lose"));
            currentPrizeSlot.toggleRaffleResult(false);
            this.m_winningNumberFrame.changeColorsAll(16711680);
         }
         if(this.m_raffleReward != null && !this.m_raffleReward.hasProcessed && this.m_raffleReward.hasOwnProperty("rewardLink") && this.m_raffleReward.rewardLink.length > 0)
         {
            TweenLite.delayedCall(1.25,this.shareWin,[this.m_winningTicket.uid == "FC"]);
            this.m_nextButton.applyGrayOut = true;
            this.m_window.toggleCloseButton(true);
            this.m_iState = STATE_SHARE_WIN;
         }
         else
         {
            this.m_nextButton.applyGrayOut = false;
            this.m_iState = STATE_WAITING_FOR_NEXT;
         }
      }
      
      private function playWinningAnimation() : void
      {
         var winningSlot:RaffleTicketSlot = this.m_raffleTicketSlotFrame.getWinningTicketSlot();
         if(winningSlot != null)
         {
            this.m_winningBurst.x = winningSlot.x - 25;
            this.m_winningBurst.visible = true;
            (this.m_winningBurst.element as MovieClip).play();
         }
      }
      
      private function startDecoding() : void
      {
         var userTicket:Object = null;
         var losingTicket:Object = null;
         this.m_iState = STATE_DECODING;
         if(this.m_raffleReward != null)
         {
            userTicket = SocialRaffleManager.getInstance().selectUserTicket(this.m_raffleReward.friendUid);
            this.m_winningTicket = userTicket;
         }
         else
         {
            losingTicket = SocialRaffleManager.getInstance().removeLosingTicket();
            this.m_winningTicket = losingTicket;
         }
         this.m_winningNumberFrame.startDecoding(this.m_winningTicket.number,this.onDecodeLetter,this.onDecodeAllLetters);
      }
      
      private function updateTicketFrame() : void
      {
         var ticketCount:int = int(this.m_remainingRaffleTickets.length);
         if(ticketCount <= MAX_TICKET_SLOT)
         {
            this.m_ticketOverflowTextField.visible = false;
            this.m_overflowTicketSlotFrame.dissipate();
            if(this.m_raffleTicketSlotFrame.visible == true)
            {
               this.m_raffleTicketSlotFrame.hideMissingTickets(this.m_remainingRaffleTickets);
            }
            else
            {
               this.m_raffleTicketSlotFrame.resetAllSlots();
               this.m_raffleTicketSlotFrame.resetPosition();
               this.m_raffleTicketSlotFrame.setData(this.m_remainingRaffleTickets,false);
               this.m_raffleTicketSlotFrame.visible = true;
            }
         }
         else
         {
            this.m_raffleTicketSlotFrame.visible = false;
            this.m_ticketOverflowTextField.visible = true;
            this.m_overflowTicketSlotFrame.setData(this.m_remainingRaffleTickets);
            if(this.m_overflowTicketSlotFrame.dissipated == true)
            {
               this.m_overflowTicketSlotFrame.resetPosition();
               this.m_overflowTicketSlotFrame.resetAllSlots();
            }
            this.m_overflowTicketSlotFrame.visible = true;
            this.m_ticketOverflowTextField.text = ZLocUtils.t("Dialogs","socialrafflebuilding_game_ticketoverflow",{
               "ticketCount":ticketCount,
               "ticket_word_lower":ZLocUtils.tk("Dialogs","ticket_word_lower","",ticketCount)
            });
         }
      }
   }
}

