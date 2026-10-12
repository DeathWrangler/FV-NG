package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.LESetManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LESet.LESetSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class LESetWindow extends FarmWindow
   {
      
      private const CURRENT_PROGRESS:int = 0;
      
      private const ASSET_NAME:String = "assets/dialogs/FV_PurchaseSetReward.swf";
      
      private const CONGRATS_ASSET_NAME:String = "Something";
      
      private const MAX_ITEMS_PER_PAGE:int = 5;
      
      private const PROGRESS_ANIMATION_MAX_FRAMES:int = 110;
      
      private const PROGRESS_ANIMATION_START:int = 2;
      
      private const PROGRESS_BAR_COMPLETED_LEVEL:int = 10;
      
      private const MINI_ICON_SIZE:int = 20;
      
      private const REWARD_ICON_SIZE:int = 125;
      
      private const MAIN_ICON_SIZE:int = 100;
      
      private const ANIMATION_SPEED:int = 2;
      
      private const EMPTY_BAR_FRAME:int = 0;
      
      private const FADE_LEVEL:Number = 0.5;
      
      private var m_completed:Boolean;
      
      private var m_featureFrame:LESetSlotContainerFrame;
      
      private var m_set:Array;
      
      private var m_curProgress:int;
      
      private var m_pageCountMc:MovieClip;
      
      private var m_pageCountFrame:ZwFrame;
      
      private var m_rewardFrame:ZwFrame;
      
      private var m_progressBarMc:MovieClip;
      
      private var m_progressBarFrame:ZwFrame;
      
      private var m_progressBarMeterMc:MovieClip;
      
      private var m_countdownMc:MovieClip;
      
      private var m_countdownFrame:ZwFrame;
      
      private var m_buySetBtn:FarmAnimatedTextButton;
      
      private var m_whatsthisBtn:FarmAnimatedTextButton;
      
      private var m_ownedTF:ZwTextField;
      
      private var m_targetFrameNum:int = 0;
      
      private var m_progressBarAnimationStart:int;
      
      private var m_animatedIcon:FarmIcon;
      
      private var day1:ZwTextField;
      
      private var day0:ZwTextField;
      
      private var hrs1:ZwTextField;
      
      private var hrs0:ZwTextField;
      
      private var min1:ZwTextField;
      
      private var min0:ZwTextField;
      
      public function LESetWindow(completed:Boolean = false)
      {
         this.m_completed = completed;
         super(this.ASSET_NAME,true);
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_featureFrame = new LESetSlotContainerFrame(m_window,this);
         this.m_progressBarMc = m_window.progression_mc;
         this.m_progressBarMeterMc = this.m_progressBarMc.progression_meter_mc;
         this.m_countdownMc = m_window.timer_mc;
         this.m_curProgress = this.CURRENT_PROGRESS;
         this.m_progressBarAnimationStart = this.PROGRESS_ANIMATION_START;
         this.initFeatureWidgets();
         this.initTimeRemaining();
         this.initProgress();
         this.m_featureFrame.refresh();
      }
      
      private function initFeatureWidgets() : void
      {
         this.m_featureFrame.addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","LESetBonus_Title",{"theme":ZLocUtils.t("Dialogs",LESetManager.themeName)})));
         this.m_featureFrame.addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t("Dialogs","LESetBonus_Message",{"theme":ZLocUtils.t("Dialogs",LESetManager.themeName)})));
         this.m_featureFrame.addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.onWhatsThisClick));
         var buyAllBtn:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.completesetbtn_mc,ZLocUtils.t("Dialogs","LESetBonus_Complete"),null);
         this.m_featureFrame.addWidget(buyAllBtn,true);
         buyAllBtn.enabled = false;
         buyAllBtn.visible = false;
         this.m_countdownFrame = new ZwFrame(this.m_countdownMc);
         this.m_countdownFrame.addWidget(new ZwTextField(this.m_countdownMc.timertitle_tf,ZLocUtils.t("Dialogs","LESetBonus_TimeTitle")));
         this.day1 = new ZwTextField(this.m_countdownMc.dayvalue_1_tf,"0");
         this.day0 = new ZwTextField(this.m_countdownMc.dayvalue_2_tf,"0");
         this.m_countdownFrame.addWidget(this.day1);
         this.m_countdownFrame.addWidget(this.day0);
         this.hrs1 = new ZwTextField(this.m_countdownMc.hrsvalue_1_tf,"0");
         this.hrs0 = new ZwTextField(this.m_countdownMc.hrsvalue_2_tf,"0");
         this.m_countdownFrame.addWidget(this.hrs1);
         this.m_countdownFrame.addWidget(this.hrs0);
         this.min1 = new ZwTextField(this.m_countdownMc.minvalue_1_tf,"0");
         this.min0 = new ZwTextField(this.m_countdownMc.minvalue_2_tf,"0");
         this.m_countdownFrame.addWidget(this.min1);
         this.m_countdownFrame.addWidget(this.min0);
         this.m_countdownFrame.addWidget(new ZwTextField(this.m_countdownMc.days_tf,ZLocUtils.t("Dialogs","LESetBonus_Days")));
         this.m_countdownFrame.addWidget(new ZwTextField(this.m_countdownMc.hrs_tf,ZLocUtils.t("Dialogs","LESetBonus_Hours")));
         this.m_countdownFrame.addWidget(new ZwTextField(this.m_countdownMc.min_tf,ZLocUtils.t("Dialogs","LESetBonus_Minutes")));
         this.m_featureFrame.addWidget(this.m_countdownFrame);
         this.m_progressBarFrame = new ZwFrame(this.m_progressBarMc);
         this.m_progressBarFrame.addWidget(new ZwFrame(this.m_progressBarMeterMc));
         this.m_featureFrame.addWidget(this.m_progressBarFrame);
         this.m_rewardFrame = new ZwFrame(m_window.slot_reward_mc);
         this.m_rewardFrame.addWidget(new ZwTextField(m_window.slot_reward_mc.itemsowned_tf,ZLocUtils.t("Dialogs","LESetBonus_Owned")));
         this.m_ownedTF = new ZwTextField(m_window.slot_reward_mc.ownedct_tf,ZLocUtils.t("Dialogs","LESetBonus_Count",{
            "current":LESetManager.getNumberOwned(),
            "total":LESetManager.getCurrentCollectionSize()
         }));
         this.m_rewardFrame.addWidget(this.m_ownedTF);
         var rewardIcon:ObjectPreviewFrame = new ObjectPreviewFrame(m_window.slot_reward_mc.rewardicon_mc,LESetManager.getCurrentCollectionRewardData());
         this.m_rewardFrame.addWidget(rewardIcon);
         this.m_featureFrame.addWidget(this.m_rewardFrame);
      }
      
      private function initTimeRemaining() : void
      {
         var serverSecond:Number = NaN;
         var timeRemaining:Array = null;
         var day10s:int = 0;
         var day1s:int = 0;
         var hrs10s:int = 0;
         var hrs1s:int = 0;
         var min10s:int = 0;
         var min1s:int = 0;
         if(GlobalEngine.isServerTimeValid())
         {
            serverSecond = GlobalEngine.serverTime / 1000;
         }
         var timeLeft:Number = LESetManager.getRemainingTime() - serverSecond;
         if(timeLeft > 0)
         {
            timeRemaining = FarmGameUtil.parseTimeLeftZLoc(timeLeft);
            day10s = int(timeRemaining["Days"] / 10);
            day1s = int(timeRemaining["Days"] - day10s * 10);
            hrs10s = int(timeRemaining["Hours"] / 10);
            hrs1s = int(timeRemaining["Hours"] - hrs10s * 10);
            min10s = int(timeRemaining["Minutes"] / 10);
            min1s = int(timeRemaining["Minutes"] - min10s * 10);
            this.day1.text = day10s.toString();
            this.day0.text = day1s.toString();
            this.hrs1.text = hrs10s.toString();
            this.hrs0.text = hrs1s.toString();
            this.min1.text = min10s.toString();
            this.min0.text = min1s.toString();
         }
      }
      
      private function initProgress() : void
      {
         var item:Object = null;
         var data:Object = this.m_featureFrame.getData();
         for each(item in data)
         {
            if(item["owned"] == true)
            {
               this.m_curProgress += 1;
            }
         }
         if(this.m_curProgress > 0 || this.m_completed)
         {
            if(this.m_completed)
            {
               this.m_completed = false;
               this.completeCollection();
            }
            else
            {
               this.updateProgressBar(this.m_curProgress);
            }
         }
      }
      
      private function onBuyAll(evt:Event) : void
      {
         if(Global.player.canBuy(LESetManager.getRemaingCost(),true))
         {
            LESetManager.buyAll();
            this.completeCollection();
         }
      }
      
      private function onWhatsThisClick(evt:Event) : void
      {
         LESetManager.displayWhatsThis();
      }
      
      public function updateProgress(amount:int) : void
      {
         this.m_curProgress += amount;
         this.updateProgressBar(this.m_curProgress);
      }
      
      private function updateProgressBar(amount:int) : void
      {
         this.m_targetFrameNum = int(amount / LESetManager.getCurrentCollectionSize() * this.PROGRESS_ANIMATION_MAX_FRAMES);
         this.m_progressBarMeterMc.gotoAndPlay(this.m_progressBarAnimationStart);
         this.m_progressBarMeterMc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.m_ownedTF.text = ZLocUtils.t("Dialogs","LESetBonus_Count",{
            "current":this.m_curProgress,
            "total":LESetManager.getCurrentCollectionSize()
         });
      }
      
      private function resetProgressBar() : void
      {
         this.m_progressBarMeterMc.gotoAndStop(this.EMPTY_BAR_FRAME);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         this.m_progressBarAnimationStart = (this.m_progressBarMeterMc as MovieClip).currentFrame;
         if(this.m_progressBarAnimationStart == this.m_targetFrameNum)
         {
            this.m_progressBarMeterMc.stop();
            this.m_progressBarMeterMc.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_progressBarAnimationStart = this.m_targetFrameNum;
         }
      }
      
      public function animateItemIcon(startIcon:FarmIcon) : void
      {
         startIcon.alpha = 0.5;
      }
      
      public function completeCollection() : void
      {
         this.updateProgressBar(this.PROGRESS_BAR_COMPLETED_LEVEL);
         TweenLite.to(this,5,{"onComplete":this.resetProgress});
      }
      
      public function resetProgress() : void
      {
         this.m_curProgress = 0;
         this.m_targetFrameNum = 0;
         this.m_progressBarAnimationStart = 0;
         this.resetProgressBar();
         this.m_featureFrame.refreshData();
         this.initProgress();
         this.m_featureFrame.refresh();
         LESetManager.displayCongratulationsDialog();
      }
      
      public function closeWindow(evt:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         StatsManager.count("dialog","reward_purch_set_1","cancel");
         super.close();
      }
   }
}

