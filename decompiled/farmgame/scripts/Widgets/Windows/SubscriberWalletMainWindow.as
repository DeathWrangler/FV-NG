package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.TutorialUI;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.SubscriberWalletManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SubscriberWalletMainWindowRewards;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   
   public class SubscriberWalletMainWindow extends FarmWindowWithTutorial
   {
      
      protected var m_featureName:String;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_vipTimer_mc:MovieClip;
      
      private var m_token_mc:MovieClip;
      
      private var m_tokenCounter_tf:ZwTextField;
      
      private var m_tokenSpin_bt:FarmAnimatedCashButton;
      
      private var m_knowMoreToken_bt:FarmAnimatedTextButton;
      
      private var m_viewRewards_bt:FarmAnimatedTextButton;
      
      private var m_spin_mc:MovieClip;
      
      private var m_freeSpin_mc:MovieClip;
      
      private var m_freeSpinMeter_mc:MovieClip;
      
      private var m_vipDailySpin_mc:MovieClip;
      
      private var m_spinCounter_tf:ZwTextField;
      
      private var m_vipTimer_tf:ZwTextField;
      
      private var m_vipTitle_tf:ZwTextField;
      
      private var m_tokensAdded_tf:ZwTextField;
      
      private var m_tenSpinBody1_tf:ZwTextField;
      
      private var m_freeSpinBody_tf:ZwTextField;
      
      private var m_tokenSpinBody1_tf:ZwTextField;
      
      private var m_tenSpinBody2_tf:ZwTextField;
      
      private var m_tenSpinBody3_tf:ZwTextField;
      
      private var m_vipBody_tf:ZwTextField;
      
      private var m_rewardTitle_tf:ZwTextField;
      
      private var m_tutorialButton1:FarmAnimatedTextButton;
      
      private var m_bypassSeenFlag1:Boolean = false;
      
      private var m_ftueTutorialCurrentFrame:int = 1;
      
      private var m_ftueTutorial:ZwFrame = null;
      
      private var m_ftueTutorialButton:FarmAnimatedTextButton;
      
      private var m_paid1Spin_bt:FarmAnimatedCashButton;
      
      private var m_paid10Spin_bt:FarmAnimatedCashButton;
      
      private var m_vipSpin_bt:FarmAnimatedTextButton;
      
      private var m_earnedSpin_bt:FarmAnimatedTextButton;
      
      private var m_featureData:Object;
      
      private var m_vip:Boolean;
      
      private var m_lastTokenCount:int;
      
      private var m_lastFreeSpinCounter:int;
      
      private var m_timer:Timer;
      
      private var m_timerForAnimation:Timer;
      
      private var m_mainWindowTutorialSceneNumbers:Array;
      
      private var m_mainWindowTutorialCurrentSceneIndex:int;
      
      private var m_freeSpinFrameInitial:int;
      
      private var m_freeSpinFrameCurrent:int;
      
      private var m_freeSpinFrameFinal:int;
      
      private var m_rewardsSlot:SubscriberWalletMainWindowRewards;
      
      private var m_buttonStates:Object;
      
      private var m_paid1Cost:String;
      
      private var m_paid10Cost:String;
      
      private var m_freeSpinLastVisibleStatus:Boolean;
      
      private var m_timerDelayForEarnedSpinAnimation:int = 200;
      
      public function SubscriberWalletMainWindow(featureName:String, vip:Boolean, assetPath:String, featureData:Object)
      {
         this.m_featureName = featureName;
         var tutorialSceneCount:int = SubscriberWalletManager.getInstance().isVip() ? 7 : 5;
         super(this.m_featureName,assetPath,tutorialSceneCount,true,true);
         this.m_featureData = featureData;
         this.m_vip = vip;
         this.m_freeSpinFrameCurrent = 1;
         this.m_lastTokenCount = this.m_featureData[SubscriberWalletManager.KEY_TOKEN_COUNT];
         this.m_mainWindowTutorialSceneNumbers = new Array();
         this.m_buttonStates = new Object();
         this.m_paid1Cost = SubscriberWalletManager.getInstance().getPaid1Cost();
         this.m_paid10Cost = SubscriberWalletManager.getInstance().getPaid10Cost();
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_title")));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("vipTimer_mc"))
         {
            this.m_vipTimer_mc = m_window["vipTimer_mc"] as MovieClip;
            if(this.m_vipTimer_mc.hasOwnProperty("timer_tf"))
            {
               addWidget(this.m_vipTimer_tf = new ZwTextField(this.m_vipTimer_mc["timer_tf"],"11:11:11"));
            }
            if(this.m_vipTimer_mc.hasOwnProperty("title_tf"))
            {
               this.m_vipTitle_tf = new ZwTextField(this.m_vipTimer_mc["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBtnText"));
            }
            if(this.m_vipTimer_mc.hasOwnProperty("body_tf"))
            {
               addWidget(this.m_vipBody_tf = new ZwTextField(this.m_vipTimer_mc["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBody")));
            }
         }
         if(m_window.hasOwnProperty("token_mc"))
         {
            this.m_token_mc = m_window["token_mc"] as MovieClip;
            this.m_token_mc.visible = true;
            if(this.m_token_mc.hasOwnProperty("body_tf"))
            {
               this.m_tokenSpinBody1_tf = new ZwTextField(this.m_token_mc["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_redeemTokensBody"));
            }
            this.m_tokensAdded_tf = new ZwTextField(this.m_token_mc["added_tf"],"");
            addWidget(this.m_tokensAdded_tf);
            if(this.m_token_mc.hasOwnProperty("counter_tf"))
            {
               addWidget(this.m_tokenCounter_tf = new ZwTextField(this.m_token_mc["counter_tf"],""));
            }
            if(this.m_token_mc.hasOwnProperty("knowMore_bt"))
            {
               addWidget(this.m_knowMoreToken_bt = new FarmAnimatedTextButton(this.m_token_mc["knowMore_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_redeemTokenKnowMore"),this.howDoesTokenSpinWorkCallback));
            }
            if(this.m_token_mc.hasOwnProperty("redeem_bt"))
            {
               this.m_tokenSpin_bt = new FarmAnimatedCashButton(this.m_token_mc["redeem_bt"],"Token Spin",SubscriberWalletManager.getInstance().tokenCountForSpin().toString(),this.tokenSpinCallback);
               addWidget(this.m_tokenSpin_bt);
            }
         }
         if(m_window.hasOwnProperty("spin_mc"))
         {
            this.m_spin_mc = m_window["spin_mc"] as MovieClip;
            this.m_spin_mc.visible = true;
            this.m_tenSpinBody1_tf = new ZwTextField(this.m_spin_mc["body1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_tenspinBody1"));
            this.m_tenSpinBody2_tf = new ZwTextField(this.m_spin_mc["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_tenspinBody2"));
            this.m_tenSpinBody3_tf = new ZwTextField(this.m_spin_mc["body3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_tenspinBody3"));
            addWidget(this.m_paid10Spin_bt = new FarmAnimatedCashButton(this.m_spin_mc["tenSpins_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenSpinBtnText"),this.m_paid10Cost,this.confirmTenSpinCallback));
            addWidget(this.m_paid1Spin_bt = new FarmAnimatedCashButton(this.m_spin_mc["spin_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_freeSpinBtnText"),this.m_paid1Cost,this.spinCallback));
            addWidget(this.m_earnedSpin_bt = new FarmAnimatedTextButton(this.m_spin_mc["freeSpin_bt"],"Free Spin",this.earnedSpinCallback));
            this.m_earnedSpin_bt.visible = false;
         }
         if(m_window.hasOwnProperty("freeSpin_mc"))
         {
            this.m_freeSpin_mc = m_window["freeSpin_mc"] as MovieClip;
            this.m_freeSpin_mc.visible = true;
            this.m_freeSpinBody_tf = new ZwTextField(this.m_freeSpin_mc["body_tf"],"");
            this.m_spinCounter_tf = new ZwTextField(this.m_freeSpin_mc["spinCounter_tf"],"111");
         }
         this.m_vipDailySpin_mc = m_window.vipDailySpin_mc as MovieClip;
         this.m_freeSpinMeter_mc = this.m_freeSpin_mc["spinMeter_mc"] as MovieClip;
         this.m_vipDailySpin_mc.visible = false;
         new ZwTextField(this.m_vipDailySpin_mc.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBtnText"));
         new ZwTextField(this.m_vipDailySpin_mc.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinReady"));
         addWidget(this.m_vipSpin_bt = new FarmAnimatedTextButton(this.m_vipDailySpin_mc["vipFreeSpin_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBtnText"),this.vipSpinCallback));
         this.m_rewardsSlot = new SubscriberWalletMainWindowRewards(m_window["rewards_mc"],this.m_featureName);
         this.m_rewardsSlot.visible = true;
         addWidget(this.m_viewRewards_bt = new FarmAnimatedTextButton(m_window["rewards_mc"]["viewAll_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_viewRewardsBtnText"),this.rewardsCallback));
         var newRewardsTag:MovieClip = m_window["rewards_mc"]["newTag_mc"] as MovieClip;
         newRewardsTag.visible = SubscriberWalletManager.getInstance().areRewardsNew();
         this.updateFreeSpin();
         this.updateVipSpin();
         this.updateVipTimer();
         this.updateFreeTokenSpin();
         this.mainFTUE();
      }
      
      private function mainFTUE() : void
      {
         if(m_window.FTUE_Main_mc)
         {
            m_tutorial = addWidget(new ZwFrame(m_window.FTUE_Main_mc),false) as ZwFrame;
            if(m_window.FTUE_Main_mc.okay_bt)
            {
               m_tutorial.addWidget(this.m_tutorialButton1 = new FarmAnimatedTextButton(m_window.FTUE_Main_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.okayCallBack)) as FarmAnimatedTextButton;
            }
            if(!SubscriberWalletManager.getInstance().isTutorialSeen())
            {
               this.mainTutorialFrame1();
            }
         }
      }
      
      public function mainTutorialFrame1() : void
      {
         this.m_vipDailySpin_mc.visible = false;
         this.m_paid1Spin_bt.enabled = true;
         this.m_paid1Spin_bt.setAmountText("0");
         (m_window.FTUE_step1 as MovieClip).visible = true;
         (m_window.FTUE_step1.arrow_ani_1_mc as MovieClip).visible = true;
         (m_window.FTUE_step1.arrow_ani_1_mc as MovieClip).play();
      }
      
      public function resumeTut() : void
      {
         this.m_paid1Spin_bt.setAmountText(this.m_paid1Cost);
         this.m_mainWindowTutorialSceneNumbers = [2,3,4,5];
         if(SubscriberWalletManager.getInstance().isVip())
         {
            this.m_mainWindowTutorialSceneNumbers.push(6);
         }
         this.m_mainWindowTutorialCurrentSceneIndex = 0;
         this.showTutorial();
      }
      
      override protected function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         tutorialSceneNumber = 1;
         this.m_vipDailySpin_mc.visible = false;
         this.m_freeSpinLastVisibleStatus = this.m_earnedSpin_bt.visible;
         this.m_earnedSpin_bt.visible = false;
         this.m_paid10Spin_bt.visible = true;
         this.m_paid1Spin_bt.visible = true;
         this.m_tenSpinBody1_tf.visible = true;
         if(m_tutorial != null)
         {
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(this.m_mainWindowTutorialSceneNumbers[this.m_mainWindowTutorialCurrentSceneIndex++]);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.FTUE_Main_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            m_tutorial.visible = true;
         }
      }
      
      private function okayCallBack(event:MouseEvent) : void
      {
         if(this.m_mainWindowTutorialCurrentSceneIndex < this.m_mainWindowTutorialSceneNumbers.length)
         {
            (m_tutorial.element as MovieClip).gotoAndStop(this.m_mainWindowTutorialSceneNumbers[this.m_mainWindowTutorialCurrentSceneIndex++]);
         }
         else
         {
            SubscriberWalletManager.getInstance().setTutorialSeen();
            FarmStatsManager.count(m_tutorialFeatureName,"FTUE","completed");
            hideTutorial();
            this.m_earnedSpin_bt.visible = this.m_freeSpinLastVisibleStatus;
            this.m_paid10Spin_bt.visible = !this.m_freeSpinLastVisibleStatus;
            this.m_paid1Spin_bt.visible = !this.m_freeSpinLastVisibleStatus;
            this.m_tenSpinBody1_tf.visible = !this.m_freeSpinLastVisibleStatus;
            this.updateVipSpin();
         }
      }
      
      private function createLeftBouncingArrow(xpos:int, ypos:int) : void
      {
         var mat:Matrix = new Matrix(0,-1,-1,0,xpos,ypos);
         TutorialUI.addBouncingArrowsForStage(mat);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_mainWindowTutorialSceneNumbers = [1,2,3,4,5];
         if(SubscriberWalletManager.getInstance().isVip())
         {
            this.m_mainWindowTutorialSceneNumbers.push(6);
         }
         this.m_mainWindowTutorialCurrentSceneIndex = 0;
         this.showTutorial();
      }
      
      private function howDoesTokenSpinWorkCallback(event:Event) : void
      {
         this.showTokenTutorial();
      }
      
      private function showTokenTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(this.m_ftueTutorial == null)
         {
            this.m_ftueTutorial = addWidget(new ZwFrame(m_window.FTUE_token_mc),false) as ZwFrame;
            this.m_ftueTutorial.addWidget(this.m_ftueTutorialButton = new FarmAnimatedTextButton(m_window.FTUE_token_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.okayFtueCallBack)) as FarmAnimatedTextButton;
         }
         this.m_ftueTutorialCurrentFrame = 1;
         if(this.m_ftueTutorial != null)
         {
            element = this.m_ftueTutorial.element as MovieClip;
            element.gotoAndStop(this.m_ftueTutorialCurrentFrame++);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.FTUE_token_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_ftueTutorial.visible = true;
         }
      }
      
      private function okayFtueCallBack(event:MouseEvent) : void
      {
         if(this.m_ftueTutorialCurrentFrame <= 4)
         {
            (this.m_ftueTutorial.element as MovieClip).gotoAndStop(this.m_ftueTutorialCurrentFrame++);
         }
         else
         {
            this.m_ftueTutorial.visible = false;
         }
      }
      
      private function tokenSpinCallback(event:Event) : void
      {
         this.m_tokenSpin_bt.enabled = false;
         SubscriberWalletManager.getInstance().doOneSpin(SubscriberWalletManager.SPIN_TOKEN);
      }
      
      private function rewardsCallback(event:Event) : void
      {
         (m_window.FTUE_step1.arrow_ani_1_mc as MovieClip).stop();
         SubscriberWalletManager.getInstance().showRewardCollection();
      }
      
      private function spinCallback(event:Event) : void
      {
         this.m_paid1Spin_bt.enabled = false;
         (m_window.FTUE_step1.arrow_ani_1_mc as MovieClip).stop();
         (m_window.FTUE_step1 as MovieClip).visible = false;
         SubscriberWalletManager.getInstance().doOneSpin(SubscriberWalletManager.SPIN_PAID_1);
      }
      
      private function confirmTenSpinCallback(event:Event) : void
      {
         UI.displayMessage("Are you sure you want to spin for " + this.m_paid10Cost + " Farm Cash?",GenericPopup.TYPE_ACCEPTCANCEL,this.tenSpinCallback,"",true);
      }
      
      private function tenSpinCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.m_paid10Spin_bt.enabled = false;
            Global.player.setSeenFlag(this.m_featureName + "_tenSpinClick");
            SubscriberWalletManager.getInstance().doTenSpin(SubscriberWalletManager.SPIN_PAID_10);
         }
      }
      
      private function earnedSpinCallback(event:Event) : void
      {
         this.m_earnedSpin_bt.enabled = false;
         SubscriberWalletManager.getInstance().doOneSpin(SubscriberWalletManager.SPIN_EARNED);
      }
      
      public function updateFreeSpin() : void
      {
         var lightsMc:MovieClip = null;
         var spinCount:int = int(this.m_featureData[SubscriberWalletManager.SPIN_PAID_1]) + 10 * int(this.m_featureData[SubscriberWalletManager.SPIN_PAID_10]) - 10 * int(this.m_featureData[SubscriberWalletManager.SPIN_EARNED]);
         lightsMc = m_window.IightsAnim_mc as MovieClip;
         this.m_spinCounter_tf.text = spinCount.toString() + "/" + SubscriberWalletManager.getInstance().minCountForEarnedSpin().toString();
         var spinDiff:int = SubscriberWalletManager.getInstance().minCountForEarnedSpin() - spinCount;
         this.m_earnedSpin_bt.enabled = true;
         if(spinDiff <= 0)
         {
            this.m_earnedSpin_bt.visible = true;
            this.m_paid10Spin_bt.visible = false;
            this.m_paid1Spin_bt.visible = false;
            this.m_tenSpinBody1_tf.visible = false;
            this.m_tenSpinBody2_tf.visible = false;
            this.m_freeSpinBody_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_freeSpinBody");
            this.m_tenSpinBody3_tf.visible = true;
            this.m_freeSpinBody_tf.visible = true;
            (this.m_spin_mc["offer_mc"] as MovieClip).visible = false;
            this.m_timerDelayForEarnedSpinAnimation = 200;
            lightsMc.visible = true;
            lightsMc.play();
         }
         else
         {
            this.m_earnedSpin_bt.visible = false;
            lightsMc.visible = false;
            lightsMc.stop();
            this.m_paid1Spin_bt.visible = true;
            this.m_paid10Spin_bt.visible = true;
            this.m_tenSpinBody1_tf.visible = true;
            this.m_tenSpinBody2_tf.visible = true;
            this.m_tenSpinBody3_tf.visible = false;
            (this.m_spin_mc["offer_mc"] as MovieClip).visible = true;
            this.m_timerDelayForEarnedSpinAnimation = 100;
            this.m_freeSpinBody_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainUI_freeSpinBody",{"spinRemaining":spinDiff});
            this.m_freeSpinBody_tf.visible = true;
         }
         this.animateSpinMeter(this.m_lastFreeSpinCounter,spinCount);
         this.m_lastFreeSpinCounter = spinCount;
      }
      
      public function animateSpinMeter(initialCount:int, finalCount:int) : void
      {
         if(finalCount > 10)
         {
            finalCount = 10;
         }
         var countDifference:int = finalCount - initialCount;
         this.m_freeSpinFrameInitial = initialCount;
         this.m_freeSpinFrameFinal = finalCount;
         this.m_freeSpinFrameCurrent = initialCount + 1;
         this.m_freeSpinMeter_mc.visible = true;
         if(countDifference > 0)
         {
            if(this.m_timerForAnimation)
            {
               this.m_timerForAnimation.stop();
               this.m_timerForAnimation = null;
            }
            this.m_timerForAnimation = new Timer(this.m_timerDelayForEarnedSpinAnimation);
            this.m_timerForAnimation.addEventListener(TimerEvent.TIMER,this.freeSpinFrameSetup);
            this.m_timerForAnimation.start();
         }
         else
         {
            this.m_freeSpinMeter_mc.gotoAndStop(this.m_freeSpinFrameFinal + 1);
         }
      }
      
      private function freeSpinFrameSetup(event:TimerEvent) : void
      {
         if(this.m_freeSpinFrameCurrent >= this.m_freeSpinFrameFinal + 1)
         {
            this.m_timerForAnimation.stop();
            this.m_timerForAnimation = null;
         }
         else
         {
            this.m_freeSpinMeter_mc.gotoAndStop(this.m_freeSpinFrameCurrent % 11 + 1 + int(this.m_freeSpinFrameCurrent / 11));
            ++this.m_freeSpinFrameCurrent;
         }
      }
      
      public function updateVipSpin() : void
      {
         var timeRemaining:Number = this.m_featureData[SubscriberWalletManager.KEY_VIP_SPIN_AVAILABLE] - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var vipSpin:Boolean = timeRemaining <= 0 ? true : false;
         if(SubscriberWalletManager.getInstance().isVip() && vipSpin)
         {
            this.m_vipDailySpin_mc.visible = true;
            this.m_vipSpin_bt.enabled = true;
         }
      }
      
      public function updateFreeTokenSpin() : void
      {
         this.m_token_mc.visible = SubscriberWalletManager.getInstance().isTokenFeatureAvailable();
         var tokenCount:int = int(this.m_featureData[SubscriberWalletManager.KEY_TOKEN_COUNT]);
         var tokensAdded:int = tokenCount - this.m_lastTokenCount;
         this.m_tokensAdded_tf.text = tokensAdded.toString() + " " + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tokensAdded");
         this.m_tokensAdded_tf.visible = tokensAdded > 0;
         this.m_tokenCounter_tf.text = tokenCount.toString() + "/" + SubscriberWalletManager.getInstance().tokenMaxCount();
         this.m_tokenSpin_bt.enabled = tokenCount >= SubscriberWalletManager.getInstance().tokenCountForSpin();
         if(m_window.hasOwnProperty("tokenGlow_mc"))
         {
            (m_window["tokenGlow_mc"] as MovieClip).visible = tokenCount >= SubscriberWalletManager.getInstance().tokenCountForSpin();
         }
         this.m_tokenSpinBody1_tf.text = tokenCount >= SubscriberWalletManager.getInstance().tokenCountForSpin() ? ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_redeemTokensBody2") : ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_redeemTokensBody");
         this.m_lastTokenCount = tokenCount;
      }
      
      public function updateVipTimer() : void
      {
         if(this.m_vip)
         {
            this.m_vipTimer_mc.visible = true;
            this.m_vipTimer_tf.text = this.timeLeftFromNextDay();
            this.m_vipTitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBtnText");
            this.m_vipBody_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vipSpinBody");
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshVipSpinCountdown);
               this.m_timer.start();
            }
         }
         else
         {
            this.m_vipTimer_mc.visible = false;
         }
      }
      
      private function refreshVipSpinCountdown(event:TimerEvent) : void
      {
         this.m_vipTimer_tf.text = this.timeLeftFromNextDay();
      }
      
      private function vipSpinCallback(event:Event) : void
      {
         this.m_vipSpin_bt.enabled = false;
         SubscriberWalletManager.getInstance().doOneSpin(SubscriberWalletManager.SPIN_VIP);
         this.m_vipDailySpin_mc.visible = false;
      }
      
      public function updateUI(featureData:Object) : void
      {
         this.m_featureData = featureData;
         this.m_paid10Spin_bt.enabled = true;
         this.m_paid1Spin_bt.enabled = true;
         this.updateVipTimer();
         this.updateFreeTokenSpin();
         this.updateFreeSpin();
         this.updateVipSpin();
      }
      
      public function updateFeatureData(featureData:Object) : void
      {
         this.m_featureData = featureData;
      }
      
      public function timeLeftFromNextDay() : String
      {
         var timeRemaining:Number = this.m_featureData[SubscriberWalletManager.KEY_VIP_SPIN_AVAILABLE] - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeRemaining);
      }
      
      override public function close() : void
      {
         (m_window.FTUE_step1.arrow_ani_1_mc as MovieClip).stop();
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
      }
   }
}

