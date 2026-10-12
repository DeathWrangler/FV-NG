package Widgets.Windows.Minigame
{
   import Classes.Minigames.DialogFeatureData;
   import Classes.Minigames.MinigameConstants;
   import Classes.Minigames.MinigameData;
   import Classes.Minigames.RedeemablesFeatureData;
   import Classes.Minigames.TokenPlayFeatureData;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.RedeemableSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class MinigameWindow extends FarmWindow
   {
      
      private static const POSTFIX_TICKETS:String = "_Tickets";
      
      private static const POSTFIX_FREE_TOKEN:String = "_FreeToken";
      
      private static const POSTFIX_PAID_TOKEN:String = "_PaidToken";
      
      private static const POSTFIX_POWERUP_TOKEN:String = "_PowerupToken_";
      
      private static const STATS_CATEGORY_POSTFIX_GAME:String = "_game";
      
      private static const FEATURE_OPTIONS_KEY_SEEN_TUTORIAL:String = "seenTutorial";
      
      private const DEFAULT_DIFFICULTY_LEVEL:int = 1;
      
      private const DEFAULT_TICKET_COUNT:int = 0;
      
      private const POSTFIX_DIFFICULTY_LEVEL:String = "_PrizeLevel";
      
      protected var m_minigameData:MinigameData = null;
      
      private var m_difficulty:int = 1;
      
      protected var m_tutorialFrame:ZwFrame = null;
      
      protected var m_tutorialPlayButton:FarmAnimatedTextButton = null;
      
      protected var m_tutorialAnimation:ZwFrame = null;
      
      protected var m_prizes:GenericSlotContainerFrame;
      
      private var m_redeemedFrame:ZwFrame = null;
      
      private var m_redeemableUIData:Array = null;
      
      private var m_redeemPrizesLocked:Boolean = false;
      
      private var m_freeTokens:int = 0;
      
      private var m_paidTokens:int = 0;
      
      private var m_tickets:int = 0;
      
      private var m_ticketsCounterFrame:ZwFrame = null;
      
      private var m_ticketCountTextField:ZwTextField = null;
      
      public function MinigameWindow(minigameData:MinigameData)
      {
         this.m_minigameData = minigameData;
         var dialogData:DialogFeatureData = this.dialogFeatureData;
         if(Boolean(dialogData) && Boolean(dialogData.dialogAsset))
         {
            super(dialogData.dialogAsset);
         }
         else
         {
            ErrorManager.addError(this.className + ", constructor() error: gameSettings.xml for minigame " + this.m_minigameData.name + ": missing dialog feature\'s <asset> tag.");
         }
         var featureOptionsEntryName:String = this.m_minigameData.featureOptionsEntryName;
         var featureOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureOptionsEntryName,featureOptionsEntryName);
         if(featureOptions != null)
         {
            this.m_tickets = featureOptions[this.getFeatureOptionsTicketName()];
            this.m_difficulty = featureOptions[this.getFeatureOptionsDifficultyLevelName()];
         }
         else
         {
            this.m_tickets = this.DEFAULT_TICKET_COUNT;
            this.m_difficulty = this.DEFAULT_DIFFICULTY_LEVEL;
         }
         this.m_freeTokens += Global.player.getActionCount(this.getActionCountKeyForFreeToken());
         this.m_paidTokens += Global.player.getActionCount(this.getActionCountKeyForPaidToken());
      }
      
      protected function getFeatureOptionsTicketName() : String
      {
         return this.redeemablesFeatureData.ticketPrefix + POSTFIX_TICKETS;
      }
      
      protected function getFeatureOptionsDifficultyLevelName() : String
      {
         return this.redeemablesFeatureData.ticketPrefix + this.POSTFIX_DIFFICULTY_LEVEL;
      }
      
      protected function getActionCountKeyForFreeToken() : String
      {
         return this.tokenPlayFeatureData.tokenPrefix + POSTFIX_FREE_TOKEN;
      }
      
      protected function getActionCountKeyForPaidToken() : String
      {
         return this.tokenPlayFeatureData.tokenPrefix + POSTFIX_PAID_TOKEN;
      }
      
      protected function getTokenCost() : int
      {
         return this.tokenPlayFeatureData.tokenCost;
      }
      
      private function get className() : String
      {
         return getQualifiedClassName(this);
      }
      
      public function get minigameData() : MinigameData
      {
         return this.m_minigameData;
      }
      
      public function get difficulty() : int
      {
         return this.m_difficulty;
      }
      
      public function get redeemedFrame() : ZwFrame
      {
         return this.m_redeemedFrame;
      }
      
      public function set redeemPrizesLocked(setTo:Boolean) : void
      {
         this.m_redeemPrizesLocked = setTo;
      }
      
      public function get redeemPrizesLocked() : Boolean
      {
         return this.m_redeemPrizesLocked;
      }
      
      public function get freeTokens() : int
      {
         return this.m_freeTokens;
      }
      
      public function get paidTokens() : int
      {
         return this.m_paidTokens;
      }
      
      public function get tickets() : int
      {
         return this.m_tickets;
      }
      
      public function get dialogFeatureData() : DialogFeatureData
      {
         return this.m_minigameData.getFeatureData(MinigameConstants.FEATURE_DATA_KEY_DIALOG) as DialogFeatureData;
      }
      
      public function get redeemablesFeatureData() : RedeemablesFeatureData
      {
         return this.m_minigameData.getFeatureData(MinigameConstants.FEATURE_DATA_KEY_REDEEMABLES) as RedeemablesFeatureData;
      }
      
      public function get tokenPlayFeatureData() : TokenPlayFeatureData
      {
         return this.m_minigameData.getFeatureData(MinigameConstants.FEATURE_DATA_KEY_TOKENPLAY) as TokenPlayFeatureData;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_minigameData.zlocPrefix + "_title")));
         }
         if(m_window.header_mc != null)
         {
            addWidget(new ZwTextField(m_window.header_mc,ZLocUtils.t("Dialogs",this.m_minigameData.zlocPrefix + "_header")));
         }
         if(m_window.whatisthis_mc)
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
         }
         this.initializeTicketCounter();
         this.initializeRedeemSlots();
         this.initializeRedeemWindow();
         this.initializeTutorialWindow();
         this.autoShowTutorialFirstTime();
         this.detectAndFixMaxTicketsReached();
      }
      
      override public function close() : void
      {
         StatsManager.count(this.getGameStatCounterName(),"main_ui","close");
         super.close();
      }
      
      public function gameplayInterupted() : Boolean
      {
         var currentPopup:DisplayObject = UI.getCurrentPopup();
         return currentPopup != this || this.m_tutorialFrame.visible || this.redeemedFrame.visible;
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         this.showTutorial();
      }
      
      private function initializeTutorialWindow() : void
      {
         if(m_window.tutorial_mc != null)
         {
            addWidget(this.m_tutorialFrame = new ZwFrame(m_window.tutorial_mc),false);
            if(this.m_tutorialFrame.element.header_tf != null)
            {
               this.m_tutorialFrame.addWidget(new ZwTextField(this.m_tutorialFrame.element.header_tf,ZLocUtils.t("Dialogs",this.m_minigameData.zlocPrefix + "_TutorialHeader")));
            }
            if(this.m_tutorialFrame.element.body_tf != null)
            {
               this.m_tutorialFrame.addWidget(new ZwTextField(this.m_tutorialFrame.element.body_tf,ZLocUtils.t("Dialogs",this.m_minigameData.zlocPrefix + "_TutorialBody")));
            }
            if(this.m_tutorialFrame.element.play_bt != null)
            {
               this.m_tutorialFrame.addWidget(this.m_tutorialPlayButton = new FarmAnimatedTextButton(this.m_tutorialFrame.element.play_bt,ZLocUtils.t("Dialogs",this.m_minigameData.zlocPrefix + "_TutorialAcceptButton"),this.onTutorialPlayButton));
            }
            if(this.m_tutorialFrame.element.animation_mc)
            {
               this.m_tutorialFrame.addWidget(this.m_tutorialAnimation = new ZwFrame(this.m_tutorialFrame.element.animation_mc),true);
            }
         }
      }
      
      private function autoShowTutorialFirstTime() : void
      {
         var featureOptionsEntryName:String = null;
         var featureOptions:Object = null;
         if(this.m_tutorialFrame)
         {
            featureOptionsEntryName = this.m_minigameData.featureOptionsEntryName;
            featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(featureOptionsEntryName,featureOptionsEntryName);
            if(featureOptions == null || !featureOptions.hasOwnProperty(FEATURE_OPTIONS_KEY_SEEN_TUTORIAL) || !featureOptions[FEATURE_OPTIONS_KEY_SEEN_TUTORIAL])
            {
               this.showTutorial();
            }
         }
      }
      
      private function tutorialWindowGoToFrame(frameNumber:uint) : void
      {
         var tutorialMC:MovieClip = null;
         if(this.m_tutorialFrame)
         {
            tutorialMC = this.m_tutorialFrame.element as MovieClip;
            if(frameNumber < tutorialMC.totalFrames)
            {
               tutorialMC.gotoAndStop(frameNumber);
               if(this.m_tutorialAnimation)
               {
                  this.m_tutorialAnimation.element.gotoAndPlay(1);
               }
            }
         }
      }
      
      private function showTutorial() : void
      {
         if(this.m_tutorialFrame)
         {
            this.tutorialWindowGoToFrame(0);
            this.m_tutorialFrame.visible = true;
         }
      }
      
      private function onTutorialPlayButton(event:Event) : void
      {
         var tutorialMC:MovieClip = null;
         var featureOptionsEntryName:String = null;
         var featureOptions:Object = null;
         var sawTutorial:TGenericTransaction = null;
         if(this.m_tutorialFrame)
         {
            tutorialMC = this.m_tutorialFrame.element as MovieClip;
            if(tutorialMC.currentFrame >= tutorialMC.totalFrames - 1)
            {
               this.m_tutorialFrame.visible = false;
               featureOptionsEntryName = this.m_minigameData.featureOptionsEntryName;
               featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(featureOptionsEntryName,featureOptionsEntryName);
               if(featureOptions != null && (!featureOptions.hasOwnProperty(FEATURE_OPTIONS_KEY_SEEN_TUTORIAL) || !featureOptions[FEATURE_OPTIONS_KEY_SEEN_TUTORIAL]))
               {
                  featureOptions[FEATURE_OPTIONS_KEY_SEEN_TUTORIAL] = true;
                  FeatureOptionsManager.getInstance().setFeatureOption(featureOptionsEntryName,featureOptionsEntryName,featureOptions);
                  sawTutorial = new TGenericTransaction("TokenPlayFeatureService","sawTutorial",null,[this.m_minigameData.name]);
                  TransactionManager.addTransaction(sawTutorial,true);
               }
            }
            else
            {
               this.tutorialWindowGoToFrame(tutorialMC.currentFrame + 1);
            }
         }
      }
      
      private function initializeRedeemSlots() : void
      {
         if(m_window.prizes_mc != null)
         {
            addWidget(this.m_prizes = new GenericSlotContainerFrame(m_window.prizes_mc,this.getRedeemSlotClass(),this.getRedeemData(),this));
         }
      }
      
      protected function showRedeemables() : void
      {
         if(this.m_prizes)
         {
            this.m_prizes.visible = true;
         }
      }
      
      protected function hideRedeemables() : void
      {
         if(this.m_prizes)
         {
            this.m_prizes.visible = false;
         }
      }
      
      protected function getRedeemSlotClass() : Class
      {
         return RedeemableSlot;
      }
      
      protected function getRedeemData() : Array
      {
         if(!this.m_redeemableUIData)
         {
            if(this.redeemablesFeatureData)
            {
               this.m_redeemableUIData = this.redeemablesFeatureData.getUIData();
            }
            else
            {
               ErrorManager.addError(this.className + " getRedeemData is missing redeemables Feature Data.");
            }
         }
         return this.m_redeemableUIData;
      }
      
      private function setSlotRedeemGray(value:Boolean) : void
      {
         var slot:RedeemableSlot = null;
         for each(slot in this.m_prizes.slots)
         {
            slot.grayOutRedeemButton(value);
         }
      }
      
      private function refreshRedeemableSlotFrame() : void
      {
         if(this.m_prizes)
         {
            this.m_prizes.refresh();
         }
      }
      
      private function initializeRedeemWindow() : void
      {
         if(m_window.hasOwnProperty("redeemed_mc"))
         {
            addWidget(this.m_redeemedFrame = new ZwFrame(m_window.redeemed_mc),false);
            if(this.m_redeemedFrame.element.copy_tf != null)
            {
               this.m_redeemedFrame.addWidget(new ZwTextField(this.m_redeemedFrame.element.copy_tf));
            }
            if(this.m_redeemedFrame.element.giftbox_tf != null)
            {
               this.m_redeemedFrame.addWidget(new ZwTextField(this.m_redeemedFrame.element.giftbox_tf,this.redeemablesFeatureData.getRedeemPrizeInGiftboxText()));
            }
            if(this.m_redeemedFrame.element.accept_bt != null)
            {
               this.m_redeemedFrame.addWidget(new FarmAnimatedTextButton(this.m_redeemedFrame.element.accept_bt,this.redeemablesFeatureData.getRedeemPrizeConfirmationText(),this.confirmPrize));
            }
            if(this.m_redeemedFrame.element.icon_mc)
            {
               this.m_redeemedFrame.addWidget(new FarmIcon(this.m_redeemedFrame.element.icon_mc));
            }
         }
         else
         {
            ErrorManager.addError(this.className + ": initializeRedeemWindow() error swf is missing redeemed_mc.");
         }
      }
      
      private function confirmPrize(event:Event = null) : void
      {
         this.m_redeemedFrame.visible = false;
      }
      
      private function detectAndFixMaxTicketsReached() : void
      {
         var ticketsName:String = null;
         var message:String = null;
         var maxTickets:uint = this.tokenPlayFeatureData.maxTickets;
         if(this.m_tickets >= maxTickets)
         {
            this.m_tickets = maxTickets;
            ticketsName = this.redeemablesFeatureData.getRedeemTicketsNameText();
            message = this.tokenPlayFeatureData.getMaxTicketsReachedText(ticketsName);
            UI.displayMessage(message,0,null,"",true);
         }
      }
      
      public function addTickets(amount:int) : void
      {
         if(amount > 0)
         {
            this.m_tickets += amount;
            this.detectAndFixMaxTicketsReached();
            this.displayTicketsUpdate(amount);
         }
      }
      
      public function redeemPrize(price:int) : void
      {
         this.displayTicketsUpdate(-price);
         this.m_tickets -= price;
         this.redeemPrizesLocked = true;
         this.refreshTicketCount();
         this.refreshRedeemableSlotFrame();
         this.saveGameData();
      }
      
      private function displayTicketsUpdate(delta:int) : void
      {
         var midPoint:Point = null;
         var message:String = null;
         if(Boolean(delta != 0 && this.m_ticketCountTextField) && Boolean(this.m_ticketCountTextField.element) && Boolean(this.m_ticketCountTextField.element.parent))
         {
            midPoint = new Point(0,0);
            midPoint = this.m_ticketCountTextField.element.parent.localToGlobal(midPoint);
            message = this.redeemablesFeatureData.getRedeemTicketChangeText(delta);
            UI.displayStatus(message,midPoint.x,midPoint.y - this.m_ticketCountTextField.height);
         }
      }
      
      private function initializeTicketCounter() : void
      {
         if(m_window.hasOwnProperty("tickets_mc"))
         {
            addWidget(this.m_ticketsCounterFrame = new ZwFrame(m_window.tickets_mc));
            if(this.m_ticketsCounterFrame.element.count_tf != null)
            {
               this.m_ticketsCounterFrame.addWidget(this.m_ticketCountTextField = new ZwTextField(this.m_ticketsCounterFrame.element.count_tf,this.m_tickets.toString()));
               this.m_ticketCountTextField.visible = true;
            }
            if(this.m_ticketsCounterFrame.element.title_tf != null)
            {
               this.m_ticketsCounterFrame.addWidget(new ZwTextField(this.m_ticketsCounterFrame.element.title_tf,this.redeemablesFeatureData.getRedeemTicketTitleText()));
            }
         }
         else
         {
            ErrorManager.addError(this.className + ": initializeTicketCounter() error swf is missing tickets_mc.");
         }
      }
      
      protected function showTicketsCounterFrame() : void
      {
         if(this.m_ticketsCounterFrame)
         {
            this.m_ticketsCounterFrame.visible = true;
         }
      }
      
      protected function hideTicketsCounterFrame() : void
      {
         if(this.m_ticketsCounterFrame)
         {
            this.m_ticketsCounterFrame.visible = false;
         }
      }
      
      protected function refreshTicketCount() : void
      {
         if(this.m_ticketCountTextField != null)
         {
            this.m_ticketCountTextField.text = this.m_tickets.toString();
         }
      }
      
      public function canAfford(price:int) : Boolean
      {
         return this.m_tickets >= price;
      }
      
      protected function saveGameData() : void
      {
         var featureOptionsEntryName:String = this.m_minigameData.featureOptionsEntryName;
         var featureOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureOptionsEntryName,featureOptionsEntryName);
         if(featureOptions == null)
         {
            featureOptions = new Object();
         }
         featureOptions[this.getFeatureOptionsTicketName()] = this.m_tickets;
         featureOptions[this.getFeatureOptionsDifficultyLevelName()] = this.m_difficulty;
         FeatureOptionsManager.getInstance().setFeatureOption(featureOptionsEntryName,featureOptionsEntryName,featureOptions);
         Global.player.setActionCount(this.getActionCountKeyForFreeToken(),this.m_freeTokens);
         Global.player.setActionCount(this.getActionCountKeyForPaidToken(),this.m_paidTokens);
      }
      
      private function showPrizeWindow(itemCode:String) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(Boolean(m_window) && Boolean(this.m_redeemedFrame))
         {
            (this.m_redeemedFrame.getWidget(this.m_redeemedFrame.element.copy_tf) as ZwTextField).text = item.friendlyTitle;
            (this.m_redeemedFrame.getWidget(this.m_redeemedFrame.element.icon_mc) as FarmIcon).loadIcon(item.iconUrl);
            this.m_redeemedFrame.visible = true;
         }
         this.refreshRedeemableSlotFrame();
      }
      
      public function prizeResult(result:Object) : void
      {
         var rewardsVector:Vector.<Object> = null;
         var itemCode:String = null;
         if(Boolean(result != null && result.hasOwnProperty("prize")) && Boolean(result.prize.hasOwnProperty("value")) && Boolean(result.prize.hasOwnProperty("type")))
         {
            rewardsVector = new Vector.<Object>();
            rewardsVector.push(result.prize);
            UserRewardUtil.grantUserRewards(rewardsVector);
            if(m_window)
            {
               itemCode = result.prize.value;
               this.showPrizeWindow(itemCode);
               this.m_prizes.refresh();
            }
            this.redeemPrizesLocked = false;
         }
      }
      
      override protected function release() : void
      {
         this.m_redeemableUIData = null;
         this.m_prizes = null;
         this.m_redeemedFrame = null;
         this.m_ticketCountTextField = null;
         super.release();
      }
      
      protected function hasTokens() : Boolean
      {
         return this.m_paidTokens + this.m_freeTokens > 0;
      }
      
      protected function subtractPlayableToken() : void
      {
         if(this.m_freeTokens > 0)
         {
            --this.m_freeTokens;
         }
         else if(this.m_paidTokens > 0)
         {
            --this.m_paidTokens;
         }
      }
      
      protected function sendBuyPowerupTokensTransaction(powerupsArray:Array) : void
      {
         var buyTransaction:TGenericTransaction = null;
         if(Boolean(powerupsArray) && powerupsArray.length > 0)
         {
            buyTransaction = new TGenericTransaction("TokenPlayFeatureService","buyPowerupTokens",null,[this.m_minigameData.name,powerupsArray]);
            TransactionManager.addTransaction(buyTransaction,true);
         }
      }
      
      protected function buyPowerupTokenClientSide(powerupType:String, count:uint = 1) : Boolean
      {
         var totalCost:uint = 0;
         var actionCountPowerupTokenName:String = null;
         var curCount:int = 0;
         var result:Boolean = false;
         if(this.tokenPlayFeatureData.hasPowerup(powerupType) && count > 0)
         {
            totalCost = this.tokenPlayFeatureData.getNumberPowerupValue(powerupType,TokenPlayFeatureData.TAG_CASH_COST) * count;
            if(totalCost > 0)
            {
               if(Global.player.canBuyCash(totalCost,true,this.getGameStatCounterName()))
               {
                  Global.player.cash -= totalCost;
                  actionCountPowerupTokenName = this.getActionCountKeyForPowerupToken(powerupType);
                  curCount = Global.player.getActionCount(actionCountPowerupTokenName);
                  Global.player.setActionCount(actionCountPowerupTokenName,curCount + count);
                  result = true;
               }
            }
         }
         return result;
      }
      
      protected function usePowerupTokenClientSide(powerupType:String, count:uint) : Boolean
      {
         var actionCountPowerupTokenName:String = null;
         var curCount:int = 0;
         var result:Boolean = false;
         if(this.tokenPlayFeatureData.hasPowerup(powerupType) && count > 0)
         {
            actionCountPowerupTokenName = this.getActionCountKeyForPowerupToken(powerupType);
            curCount = Global.player.getActionCount(actionCountPowerupTokenName);
            if(curCount >= count)
            {
               Global.player.setActionCount(actionCountPowerupTokenName,curCount - count);
               result = true;
            }
         }
         return result;
      }
      
      protected function getCurrentPowerupCount(powerupType:String) : uint
      {
         var actionCountPowerupTokenName:String = null;
         var result:uint = 0;
         if(this.tokenPlayFeatureData.hasPowerup(powerupType))
         {
            actionCountPowerupTokenName = this.getActionCountKeyForPowerupToken(powerupType);
            result = uint(Global.player.getActionCount(actionCountPowerupTokenName));
         }
         return result;
      }
      
      protected function canBuySinglePowerupToken(powerupName:String, count:uint = 1) : Boolean
      {
         var totalCost:uint = 0;
         var result:Boolean = false;
         if(this.tokenPlayFeatureData.hasPowerup(powerupName) && count > 0)
         {
            totalCost = this.tokenPlayFeatureData.getNumberPowerupValue(powerupName,TokenPlayFeatureData.TAG_CASH_COST) * count;
            if(totalCost > 0)
            {
               if(Global.player.canBuyCash(totalCost,true,this.getGameStatCounterName()))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      protected function resetPowerupTokens() : void
      {
         var powerupName:String = null;
         var actionCountPowerupTokenName:String = null;
         for(powerupName in this.tokenPlayFeatureData.powerups)
         {
            actionCountPowerupTokenName = this.getActionCountKeyForPowerupToken(powerupName);
            Global.player.setActionCount(actionCountPowerupTokenName,0);
         }
      }
      
      protected function getActionCountKeyForPowerupToken(powerupType:String) : String
      {
         var result:String = null;
         if(powerupType != null)
         {
            return this.tokenPlayFeatureData.tokenPrefix + POSTFIX_POWERUP_TOKEN + powerupType;
         }
         throw new Error("getActionCountKeyForPowerupToken() missing required params powerupType");
      }
      
      protected function buyToken(replay:Boolean) : void
      {
         var tokenCost:uint = 0;
         var statsText:String = null;
         var buyTransaction:TGenericTransaction = null;
         if(!this.hasTokens())
         {
            tokenCost = uint(this.getTokenCost());
            if(Global.player.canBuyCash(tokenCost,true,this.getGameStatCounterName()))
            {
               Global.player.cash -= tokenCost;
               statsText = replay ? "replay" : "first_play";
               StatsManager.count(this.getGameStatCounterName(),"buy_token",statsText);
               buyTransaction = new TGenericTransaction("TokenPlayFeatureService","buyToken",null,[this.m_minigameData.name]);
               TransactionManager.addTransaction(buyTransaction,true);
               ++this.m_paidTokens;
               Global.player.setActionCount(this.getActionCountKeyForPaidToken(),this.m_paidTokens);
            }
         }
      }
      
      protected function useToken(success:Boolean, score:uint, powerupsUsed:Dictionary) : uint
      {
         var originalTicketsCount:uint = 0;
         var parsedPowerupsUsed:Array = null;
         var endGameTransaction:TGenericTransaction = null;
         var maxDifficulty:uint = 0;
         var key:String = null;
         var resultTickets:uint = 0;
         if(this.hasTokens())
         {
            originalTicketsCount = uint(this.m_tickets);
            if(success)
            {
               if(this.tokenPlayFeatureData.hasDifficultyRewards())
               {
                  this.addTickets(this.tokenPlayFeatureData.getDifficultyTicketReward(this.m_difficulty));
               }
               ++this.m_difficulty;
               maxDifficulty = this.tokenPlayFeatureData.maxDifficulty;
               if(this.m_difficulty > maxDifficulty)
               {
                  this.m_difficulty = maxDifficulty;
               }
            }
            else
            {
               this.m_difficulty = TokenPlayFeatureData.DEFAULT_MAX_DIFFICULTY;
            }
            if(this.tokenPlayFeatureData.hasScoreRewards())
            {
               this.addTickets(this.tokenPlayFeatureData.getScoreTicketReward(score));
            }
            resultTickets = this.m_tickets - originalTicketsCount;
            parsedPowerupsUsed = null;
            if(powerupsUsed)
            {
               for(key in powerupsUsed)
               {
                  if(parsedPowerupsUsed == null)
                  {
                     parsedPowerupsUsed = new Array();
                  }
                  parsedPowerupsUsed.push(key + ":" + powerupsUsed[key]);
                  this.usePowerupTokenClientSide(key,powerupsUsed[key]);
               }
            }
            endGameTransaction = new TGenericTransaction("TokenPlayFeatureService","useToken",null,[this.minigameData.name,success,score,parsedPowerupsUsed]);
            TransactionManager.addTransaction(endGameTransaction,true);
            this.subtractPlayableToken();
            this.saveGameData();
            this.refreshTicketCount();
            this.refreshRedeemableSlotFrame();
         }
         return resultTickets;
      }
      
      protected function getGameStatCounterName() : String
      {
         return this.minigameData.name + STATS_CATEGORY_POSTFIX_GAME;
      }
   }
}

