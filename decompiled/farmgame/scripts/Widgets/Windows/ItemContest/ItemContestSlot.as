package Widgets.Windows.ItemContest
{
   import Cache.Classes.ZCacheUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ItemContestManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ItemContestSlot extends ZwSlotFrame
   {
      
      private var m_contestManager:ItemContestManager;
      
      private var m_window:ItemContestWindow;
      
      private var m_contestant:String;
      
      private var m_mulch:String;
      
      private var m_mulchFed:Number;
      
      private var m_mulchNeeded:Number;
      
      private var m_timer:Timer;
      
      private var m_expiring:Number = 0;
      
      public function ItemContestSlot(element:DisplayObject, parentWindow:ItemContestWindow)
      {
         super(element);
         this.m_window = parentWindow;
         if(m_element.hasOwnProperty("places_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.places_mc),false);
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(new FarmIcon(m_element.icon_mc),false);
         }
         if(m_element.hasOwnProperty("ribbon_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.ribbon_mc),false);
         }
         if(m_element.hasOwnProperty("magnify_bt"))
         {
            addWidget(new FarmAnimatedButton(m_element.magnify_bt),false);
         }
         if(m_element.hasOwnProperty("bucket_mc"))
         {
            addWidget(new FarmIcon(m_element.bucket_mc),false);
         }
         if(m_element.hasOwnProperty("counter_tf"))
         {
            addWidget(new ZwTextField(m_element.counter_tf),false);
         }
         if(m_element.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_element.timer_tf),false);
         }
         if(m_element.hasOwnProperty("meter_mc"))
         {
            addWidget(new FarmProgressBar(m_element.meter_mc),false);
         }
         if(m_element.hasOwnProperty("blank_bt"))
         {
            addWidget(new FarmButton(m_element.blank_bt),false);
         }
         if(m_element.hasOwnProperty("enter_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.enter_bt),false);
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.buy_bt),false);
         }
         if(m_element.hasOwnProperty("burst_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.burst_mc),false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var ribbon:MovieClip = null;
         var iconBox:FarmIcon = null;
         var magnifyButton:FarmAnimatedButton = null;
         var mulchAmount:Number = NaN;
         var percent:Number = NaN;
         var mulch:FarmItem = null;
         var countText:ZwTextField = null;
         var progress:FarmProgressBar = null;
         var progBar:FarmButton = null;
         var toolText:String = null;
         var bucket:FarmIcon = null;
         var enterButton:FarmAnimatedTextButton = null;
         var mulchUntilFull:int = 0;
         var addMulchButton:FarmAnimatedTextButton = null;
         var buttonText:String = null;
         var timer:ZwTextField = null;
         var burst:ZwBaseWidget = null;
         super.populate(data);
         this.m_contestant = data["itemName"];
         this.m_contestManager = ItemContestManager.getInstance();
         var finishedSlot:Boolean = false;
         var prizeLevel:Number = this.m_contestManager.getPrizeLevel(this.m_contestant);
         if(prizeLevel == 0)
         {
            finishedSlot = true;
         }
         if(m_element.hasOwnProperty("places_mc"))
         {
            ribbon = m_element.places_mc;
            this.m_contestManager.setUpRibbon(ribbon,prizeLevel);
         }
         var contestant:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_contestant);
         if(contestant != null && m_element.hasOwnProperty("icon_mc"))
         {
            iconBox = getWidget(m_element.icon_mc) as FarmIcon;
            iconBox.loadIcon(contestant.icon);
            iconBox.visible = true;
         }
         if(m_element.hasOwnProperty("ribbon_mc"))
         {
            getWidget(m_element.ribbon_mc).visible = finishedSlot;
         }
         if(m_element.hasOwnProperty("magnify_bt"))
         {
            magnifyButton = getWidget(m_element.magnify_bt) as FarmAnimatedButton;
            magnifyButton.callback = ZCacheUtil.applyPartial(this.m_window.showOverlay,this,[this.m_contestant]);
            magnifyButton.visible = true;
         }
         if(!finishedSlot)
         {
            this.m_mulch = data["mulch"];
            mulchAmount = this.m_contestManager.getMulchAmount(this.m_mulch);
            if(m_element.hasOwnProperty("counter_tf"))
            {
               countText = getWidget(m_element.counter_tf) as ZwTextField;
               countText.text = mulchAmount.toString();
               countText.visible = true;
            }
            this.setupTimer(data["expiring"]);
            this.m_mulchFed = data["mulchOwned"];
            this.m_mulchNeeded = data["mulchNeeded"];
            percent = this.m_mulchFed / this.m_mulchNeeded * 100;
            if(m_element.hasOwnProperty("meter_mc"))
            {
               progress = getWidget(m_element.meter_mc) as FarmProgressBar;
               progress.progress = percent;
               if(percent > 66)
               {
                  (m_element.meter_mc.bar_mc as MovieClip).gotoAndStop(3);
               }
               else if(percent > 33)
               {
                  (m_element.meter_mc.bar_mc as MovieClip).gotoAndStop(2);
               }
               else
               {
                  (m_element.meter_mc.bar_mc as MovieClip).gotoAndStop(1);
               }
               progress.visible = true;
            }
            if(m_element.hasOwnProperty("blank_bt"))
            {
               progBar = getWidget(m_element.blank_bt) as FarmButton;
               progBar.visible = true;
               progBar.detachTooltip();
               toolText = ZLocUtils.t("Dialogs","mulchFed",{
                  "owned":this.m_mulchFed,
                  "needed":this.m_mulchNeeded
               });
               if(percent != 100)
               {
                  toolText += ZLocUtils.t("Dialogs","mulchNeeded");
               }
               progBar.attachTooltip(new FarmTextTooltip(toolText));
            }
            mulch = Global.farmGameSettingsManager.getFarmItemByName(this.m_mulch);
            if(mulch != null && m_element.hasOwnProperty("bucket_mc"))
            {
               bucket = getWidget(m_element.bucket_mc) as FarmIcon;
               bucket.loadIcon(mulch.icon);
               bucket.visible = true;
               bucket.detachTooltip();
               bucket.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_mulch + "Help",{
                  "owned":mulchAmount.toString(),
                  "max":this.m_contestManager.getMulchMax().toString()
               })));
            }
            this.m_window.setupHelpText(mulchAmount != 0 ? ZLocUtils.tk_pk_asTitle(contestant.friendlyName) : "",this.m_mulchFed == this.m_mulchNeeded);
            if(m_element.hasOwnProperty("enter_bt"))
            {
               enterButton = getWidget(m_element.enter_bt) as FarmAnimatedTextButton;
               enterButton.text = ZLocUtils.t("Dialogs","Enter");
               enterButton.callback = this.enterCallback;
               enterButton.visible = true;
               mulchUntilFull = this.m_mulchNeeded - this.m_mulchFed;
               if(this.m_mulchFed == 0)
               {
                  enterButton.toggleClickableButton(false,ZLocUtils.t("Dialogs","NotEnoughMulchFed"));
               }
               else if(mulchUntilFull != 0)
               {
                  enterButton.toggleClickableButton(true,ZLocUtils.t("Dialogs","FeedToGuaranteeWin",{"count":mulchUntilFull.toString()}));
               }
               else
               {
                  enterButton.toggleClickableButton(true,ZLocUtils.t("Dialogs","GuaranteedWin"));
               }
            }
            if(m_element.hasOwnProperty("buy_bt"))
            {
               addMulchButton = getWidget(m_element.buy_bt) as FarmAnimatedTextButton;
               buttonText = ZLocUtils.t("Dialogs","AddMulch");
               addMulchButton.callback = this.addMulchCallback;
               addMulchButton.visible = true;
               if(this.m_mulchFed >= this.m_mulchNeeded)
               {
                  addMulchButton.toggleClickableButton(false,ZLocUtils.t("Dialogs","FullyHappy",{"item":ZLocUtils.tk_pk_asTitle(contestant.friendlyName)}));
                  buttonText = ZLocUtils.t("Dialogs","Full");
               }
               else if(mulchAmount == 0)
               {
                  addMulchButton.toggleClickableButton(false,ZLocUtils.t("Dialogs",this.m_mulch + "Help",{
                     "owned":mulchAmount.toString(),
                     "max":this.m_contestManager.getMulchMax().toString()
                  }));
               }
               else
               {
                  addMulchButton.toggleClickableButton(true);
               }
               addMulchButton.text = buttonText;
            }
         }
         else if(m_element.hasOwnProperty("timer_tf") && m_element.hasOwnProperty("timerBG_mc"))
         {
            timer = getWidget(m_element.timer_tf) as ZwTextField;
            timer.visible = false;
            m_element.timerBG_mc.visible = false;
         }
         if(m_element.hasOwnProperty("burst_mc"))
         {
            burst = getWidget(m_element.burst_mc) as ZwBaseWidget;
            if(data["shine"] == true)
            {
               burst.visible = true;
               (m_element.burst_mc as MovieClip).play();
            }
            else
            {
               burst.visible = false;
            }
         }
      }
      
      private function setupTimer(expiring:String = "") : void
      {
         var timer:ZwTextField = null;
         var expiringIn:Number = NaN;
         var timeLeft:String = null;
         if(m_element.hasOwnProperty("timer_tf") && m_element.hasOwnProperty("timerBG_mc"))
         {
            timer = getWidget(m_element.timer_tf) as ZwTextField;
            if(expiring == "0")
            {
               timer.visible = false;
               timer.text = "";
               m_element.timerBG_mc.visible = false;
               if(this.m_timer != null)
               {
                  this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer,false);
                  this.m_timer = null;
               }
            }
            else
            {
               timer.visible = true;
               if(expiring != "")
               {
                  this.m_expiring = Number(expiring);
               }
               expiringIn = this.m_expiring - GlobalEngine.serverTime / 1000;
               if(expiringIn <= 0)
               {
                  this.m_contestManager.updateMulches(this.m_window.refreshWindow);
               }
               if(this.m_timer == null)
               {
                  this.m_timer = new Timer(5000);
                  this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
               }
               if(!this.m_timer.running)
               {
                  this.m_timer.start();
               }
               timeLeft = ZLocUtils.t("Dialogs","SwapsIn") + " " + this.calculateTimeLeft(expiringIn);
               timer.text = timeLeft;
               m_element.timerBG_mc.visible = true;
            }
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.setupTimer();
      }
      
      private function enterCallback(event:Event) : void
      {
         if(!this.m_window.hasPopupOpen())
         {
            FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"enter_contestant",this.m_contestant,Math.floor(this.m_mulchFed / this.m_mulchNeeded * 100).toString());
            this.m_window.contestantEntered(this.m_contestant);
            this.m_contestManager.enterContestant(this.m_contestant,this.m_window.showResults);
         }
      }
      
      private function addMulchCallback(event:Event) : void
      {
         var sparkle:MovieClip = null;
         if(!this.m_window.hasPopupOpen())
         {
            FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"feed_mulch",this.m_contestant);
            this.m_contestManager.feedMulch(this.m_contestant,this.m_mulch);
            if(m_element.hasOwnProperty("sparkle_mc"))
            {
               sparkle = m_element.sparkle_mc as MovieClip;
               sparkle.visible = true;
               sparkle.play();
            }
            this.m_window.refreshWindow();
         }
      }
      
      private function calculateTimeLeft(expiringIn:Number, conversionUnit:Number = 86400) : String
      {
         var timeLeft:String = Math.floor(expiringIn / conversionUnit).toString();
         if(timeLeft <= "0")
         {
            switch(conversionUnit)
            {
               case FarmGameUtil.NUM_SECS_IN_DAY:
                  timeLeft = this.calculateTimeLeft(expiringIn,FarmGameUtil.NUM_SECS_IN_HOUR);
                  break;
               case FarmGameUtil.NUM_SECS_IN_HOUR:
                  timeLeft = this.calculateTimeLeft(expiringIn,FarmGameUtil.NUM_SECS_IN_MINUTE);
                  break;
               case FarmGameUtil.NUM_SECS_IN_MINUTE:
                  timeLeft = ZLocUtils.t("Dialogs","ltOneMin");
            }
         }
         else if(timeLeft == "1")
         {
            timeLeft += this.timeLeftUnit(conversionUnit,true);
         }
         else
         {
            timeLeft += this.timeLeftUnit(conversionUnit,false);
         }
         return timeLeft;
      }
      
      private function timeLeftUnit(conversionUnit:Number, singular:Boolean) : String
      {
         var result:String = "";
         switch(conversionUnit)
         {
            case FarmGameUtil.NUM_SECS_IN_DAY:
               result = " day";
               break;
            case FarmGameUtil.NUM_SECS_IN_HOUR:
               result = " hour";
               break;
            case FarmGameUtil.NUM_SECS_IN_MINUTE:
               result = " min";
         }
         if(!singular)
         {
            result += "s";
         }
         return result;
      }
      
      override public function release() : void
      {
         super.release();
         if(this.m_timer != null)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer,false);
            this.m_timer = null;
         }
         this.m_contestManager = null;
         this.m_window = null;
      }
   }
}

