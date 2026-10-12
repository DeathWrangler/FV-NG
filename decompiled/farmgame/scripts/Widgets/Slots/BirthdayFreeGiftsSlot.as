package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.BirthdayFreeGiftsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BirthdayFreeGiftsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const UPDATE_LOOP_DELAY:Number = 50;
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private var m_checkMark:ZwWidget;
      
      private var secondsTillMidnight:Number;
      
      protected var m_buyButton:ZwWidget = null;
      
      private var m_checkBox:MovieClip = null;
      
      protected var m_claimButton:ZwWidget = null;
      
      private var m_coinClip:ZwWidget = null;
      
      private var m_coinsText:ZwTextField;
      
      protected var m_data:Object;
      
      private var m_dateText:ZwTextField;
      
      private var m_edgeCaseScenario:Boolean = false;
      
      private var m_expiredText:ZwTextField;
      
      private var m_highlight:MovieClip;
      
      private var m_icon:FarmIcon;
      
      private var m_manager:BirthdayFreeGiftsManager;
      
      protected var m_owner:DisplayObject;
      
      private var m_presentIcon:MovieClip;
      
      private var m_presentWidget:ZwWidget;
      
      private var m_selected:Boolean = true;
      
      private var m_shareText:ZwTextField;
      
      private var m_shareTick:MovieClip = null;
      
      private var m_timerText:ZwTextField;
      
      private var m_unlocksInText:ZwTextField;
      
      private var m_updateTimer:Timer = null;
      
      private var m_movieClip:MovieClip = null;
      
      public function BirthdayFreeGiftsSlot(element:DisplayObject, owner:DisplayObject)
      {
         super(element);
         this.m_owner = owner;
         this.m_manager = BirthdayFreeGiftsManager.getInstance();
         if(m_element.hasOwnProperty("present_to_open_mc"))
         {
            addWidget(this.m_presentWidget = new ZwWidget(m_element.present_to_open_mc),false);
            if(m_element.present_to_open_mc.hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_icon = new FarmIcon(m_element.present_to_open_mc.icon_mc.imagePlaceHolder_mc));
               if(this.m_icon)
               {
                  this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               }
            }
            if(m_element.present_to_open_mc.hasOwnProperty("present_mc"))
            {
               this.m_presentIcon = m_element.present_to_open_mc.present_mc;
            }
            this.m_movieClip = m_element.getChildByName("present_to_open_mc") as MovieClip;
         }
         if(m_element.hasOwnProperty("date_tf"))
         {
            this.m_dateText = new ZwTextField(m_element.date_tf,"");
            addWidget(this.m_dateText);
         }
         if(m_element.hasOwnProperty("highlight_mc"))
         {
            this.m_highlight = m_element.highlight_mc;
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_element.buy_bt,"Buy",this.onBuy));
         }
         if(m_element.hasOwnProperty("claim_bt"))
         {
            addWidget(this.m_claimButton = new FarmAnimatedTextButton(m_element.claim_bt,"Claim",this.onClaim));
         }
         if(m_element.hasOwnProperty("timeleft_tf"))
         {
            this.m_timerText = new ZwTextField(m_element.timeleft_tf,"");
            addWidget(this.m_timerText);
         }
         if(m_element.hasOwnProperty("timeleft_unlock_tf"))
         {
            this.m_unlocksInText = new ZwTextField(m_element.timeleft_unlock_tf,"");
            addWidget(this.m_unlocksInText);
         }
         if(m_element.hasOwnProperty("coins_tf"))
         {
            this.m_coinsText = new ZwTextField(m_element.coins_tf,"");
            addWidget(this.m_coinsText);
         }
         if(m_element.hasOwnProperty("coin_mc"))
         {
            this.m_coinClip = new ZwWidget(m_element.coin_mc);
            addWidget(this.m_coinClip);
         }
         if(m_element.hasOwnProperty("checkmark_1"))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_element.checkmark_1),false);
         }
         if(m_element.hasOwnProperty("checkBox"))
         {
            this.m_checkBox = m_element.checkBox as MovieClip;
            this.m_shareTick = m_element.checkBox.checkmark_0 as MovieClip;
            this.m_checkBox.addEventListener(MouseEvent.CLICK,this.onClick);
            this.m_checkBox.buttonMode = true;
         }
         if(m_element.hasOwnProperty("expired_tf"))
         {
            this.m_expiredText = new ZwTextField(m_element.expired_tf,"");
            addWidget(this.m_expiredText);
         }
         if(m_element.hasOwnProperty("share_tf"))
         {
            this.m_shareText = new ZwTextField(m_element.share_tf,"");
            addWidget(this.m_shareText);
         }
      }
      
      private function onClick(event:Event) : void
      {
         this.m_shareTick.visible = this.m_selected = !this.m_selected;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_presentWidget)
         {
            this.m_presentWidget.visible = true;
         }
         switch(this.m_data[BirthdayFreeGiftsManager.ITEM_STATE])
         {
            case BirthdayFreeGiftsManager.CLAIMED_STATE:
               this.setClaimedState();
               break;
            case BirthdayFreeGiftsManager.CLAIMABLE_STATE:
               this.setClaimableState();
               break;
            case BirthdayFreeGiftsManager.EXPIRED_STATE:
               this.setExpiredState();
               break;
            case BirthdayFreeGiftsManager.TIMER_STATE:
               this.m_presentWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,BirthdayFreeGiftsManager.FEATURE_NAME + "_defaultToolTip",{"quantity":this.m_data[BirthdayFreeGiftsManager.DAY_NUMBER_STRING]})));
               this.setTimerState();
               break;
            default:
               this.setDefaultState();
         }
      }
      
      private function setDate() : void
      {
         var nthDay:int = 0;
         if(this.m_dateText)
         {
            nthDay = int(this.m_data[BirthdayFreeGiftsManager.DAY_NUMBER_STRING]);
            this.m_dateText.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"Day") + " " + nthDay;
            this.m_dateText.visible = true;
         }
      }
      
      private function setDefaultState() : void
      {
         this.m_presentWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,BirthdayFreeGiftsManager.FEATURE_NAME + "_defaultToolTip",{"quantity":this.m_data[BirthdayFreeGiftsManager.DAY_NUMBER_STRING]})));
         this.m_icon.visible = true;
         this.m_movieClip.alpha = 0.6;
         this.m_presentIcon.alpha = 0.6;
         this.setDate();
      }
      
      private function setClaimedState() : void
      {
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         if(Boolean(giftItem) && Boolean(this.m_icon))
         {
            this.m_icon.loadIcon(giftItem.iconUrl);
            this.m_icon.visible = true;
            this.m_icon.alpha = 1;
            this.m_presentWidget.detachTooltip();
            this.m_presentWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,BirthdayFreeGiftsManager.FEATURE_NAME + "_claimedToolTip",{"itemName":ZLocUtils.tk_pk_asTitle(giftItem.friendlyName)})));
         }
         this.m_movieClip.gotoAndStop(this.m_movieClip.totalFrames);
         this.m_checkMark.visible = true;
      }
      
      private function setClaimableState() : void
      {
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         if(Boolean(giftItem) && Boolean(this.m_icon))
         {
            this.m_icon.loadIcon(giftItem.iconUrl);
         }
         if(this.m_dateText)
         {
            this.m_dateText.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"Today");
            this.m_dateText.visible = true;
         }
         this.m_edgeCaseScenario = true;
         this.m_claimButton.visible = true;
         this.m_checkBox.visible = true;
         this.m_shareTick.visible = this.m_selected = true;
         this.m_shareText.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"Share");
         this.m_shareText.visible = true;
         this.m_highlight.visible = true;
         this.startUpdateTimer();
      }
      
      private function setExpiredState() : void
      {
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         this.m_movieClip.gotoAndStop(this.m_movieClip.totalFrames);
         if(Boolean(giftItem) && Boolean(this.m_icon))
         {
            this.m_icon.loadIcon(giftItem.iconUrl);
            this.m_icon.visible = true;
            this.m_presentWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,BirthdayFreeGiftsManager.FEATURE_NAME + "_expiredToolTip")));
         }
         this.m_buyButton.visible = true;
         this.m_buyButton.enabled = true;
         this.m_buyButton.alpha = 1;
         this.m_coinsText.visible = true;
         this.m_coinsText.text = giftItem.cost.toString();
         this.m_expiredText.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"Expired");
         this.m_expiredText.visible = true;
         this.m_coinClip.visible = true;
         this.m_icon.alpha = 0.6;
      }
      
      private function setTimerState() : void
      {
         this.m_timerText.visible = true;
         this.m_unlocksInText.visible = true;
         this.m_unlocksInText.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,BirthdayFreeGiftsManager.FEATURE_NAME + "_unlocksInText");
         this.m_movieClip.alpha = 0.6;
         this.setDate();
         this.startUpdateTimer();
      }
      
      private function startUpdateTimer() : void
      {
         var msTillNextMidnightTime:Number = NaN;
         if(this.m_updateTimer == null)
         {
            msTillNextMidnightTime = FarmGameUtil.getMidnightTimestamp() + FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime;
            this.secondsTillMidnight = msTillNextMidnightTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_updateTimer = new Timer(UPDATE_LOOP_DELAY);
            this.m_updateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimer);
         }
         if(!this.m_updateTimer.running)
         {
            this.m_updateTimer.start();
         }
      }
      
      private function onUpdateTimer(event:Event) : void
      {
         this.updateTimeLeft();
      }
      
      private function updateTimeLeft() : void
      {
         var timeLastHarvested:int = 0;
         var currentTime:int = 0;
         var timeSinceLastHarvest:int = 0;
         var timeLeft:int = 0;
         var timeLeftArray:Array = null;
         var hours:String = null;
         var minutes:String = null;
         var seconds:String = null;
         if(Boolean(this.m_timerText) || this.m_edgeCaseScenario)
         {
            timeLastHarvested = this.m_manager.getFeatureLastShown();
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timeSinceLastHarvest = currentTime - timeLastHarvested;
            timeLeft = this.secondsTillMidnight - timeSinceLastHarvest;
            if(timeLeft < 0)
            {
               timeLeft = 0;
               if(this.m_updateTimer)
               {
                  this.m_updateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimer);
               }
               if(this.m_claimButton)
               {
                  this.m_claimButton.enabled = false;
               }
               closeParentWindow();
            }
            if(!this.m_edgeCaseScenario && timeLeft > 0)
            {
               timeLeftArray = FarmGameUtil.parseTimeLeft(timeLeft);
               if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
               {
                  hours = int(timeLeftArray[1]).toString();
                  if(hours.length == 1)
                  {
                     hours = "0" + hours;
                  }
                  minutes = int(timeLeftArray[2]).toString();
                  if(minutes.length == 1)
                  {
                     minutes = "0" + minutes;
                  }
                  seconds = int(timeLeftArray[3]).toString();
                  if(seconds.length == 1)
                  {
                     seconds = "0" + seconds;
                  }
                  this.m_timerText.text = hours + ":" + minutes + ":" + seconds;
               }
            }
         }
      }
      
      public function reveal() : void
      {
         if(Boolean(this.m_movieClip) && this.m_movieClip.currentFrame == 1)
         {
            this.m_movieClip.addEventListener(Event.ENTER_FRAME,this.onClipEnterFrame);
            this.m_movieClip.play();
            this.m_icon.visible = true;
            this.m_checkMark.visible = true;
         }
      }
      
      private function onClipEnterFrame(event:Event) : void
      {
         if(this.m_movieClip.currentFrame == this.m_movieClip.totalFrames)
         {
            this.m_movieClip.removeEventListener(Event.ENTER_FRAME,this.onClipEnterFrame);
            this.m_checkBox.visible = false;
            this.m_shareTick.visible = false;
            BirthdayFreeGiftsManager.getInstance().refreshEverything();
         }
      }
      
      private function onClaim(event:Event) : void
      {
         this.m_claimButton.enabled = false;
         BirthdayFreeGiftsManager.getInstance().setStateAndGift(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME],BirthdayFreeGiftsManager.CLAIMED_STATE);
         FarmStatsManager.count("dialog","birthdayFG2014","claim","",this.m_data[BirthdayFreeGiftsManager.ITEM_NAME],"",this.m_data[BirthdayFreeGiftsManager.DAY_NUMBER_STRING]);
         if(this.m_selected)
         {
            BirthdayFreeGiftsManager.getInstance().onBragFeed(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         }
         this.reveal();
      }
      
      private function onBuy(event:Event) : void
      {
         this.m_buyButton.enabled = false;
         this.m_buyButton.alpha = 0.6;
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         var canBuy:Boolean = Global.player.canBuyWithCurrency(Currency.COINS,gift.cost);
         if(canBuy)
         {
            FarmStatsManager.count("dialog","birthdayFG2014","buy","",this.m_data[BirthdayFreeGiftsManager.ITEM_NAME],"",this.m_data[BirthdayFreeGiftsManager.DAY_NUMBER_STRING]);
            BirthdayFreeGiftsManager.getInstance().onBuy(this.m_data[BirthdayFreeGiftsManager.ITEM_NAME]);
         }
         else
         {
            this.m_buyButton.enabled = true;
            this.m_buyButton.alpha = 1;
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_presentWidget = null;
         this.m_checkMark = null;
         this.m_claimButton = null;
         this.m_expiredText = null;
         this.m_timerText = null;
         this.m_unlocksInText = null;
         this.m_icon = null;
         this.m_buyButton = null;
         this.m_coinClip = null;
         this.m_coinsText = null;
         this.m_checkBox = null;
         this.m_shareTick = null;
         this.m_shareText = null;
         this.m_presentIcon = null;
         this.m_highlight = null;
         if(this.m_updateTimer)
         {
            this.m_updateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimer);
            this.m_updateTimer = null;
         }
         this.m_manager = null;
         super.release();
      }
   }
}

