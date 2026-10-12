package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.XBOPremarketingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class XBORewardsWindow extends FarmWindow
   {
      
      private const UNLOCK_ANIMATION:String = "unlockAnim_mc";
      
      private var m_timer:Timer;
      
      private var m_featureName:String;
      
      protected var m_milestone:int = 0;
      
      protected var m_rewardFrame:ZwFrame;
      
      protected var m_decoMC:ZwWidget;
      
      protected var m_leftDiscountMC:ZwWidget;
      
      protected var m_centerDiscountOnlyMC:ZwWidget;
      
      protected var m_timerFrame:ZwFrame;
      
      protected var m_keyMC:ZwWidget;
      
      protected var m_chestMC:ZwWidget;
      
      protected var m_awesomeBtn:FarmAnimatedTextButton;
      
      protected var m_desc:ZwTextField;
      
      protected var m_chestText:ZwTextField;
      
      protected var m_noReward:ZwWidget;
      
      public function XBORewardsWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(assetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var keyText:String = null;
         var j:int = 0;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.rewards_mc)
            {
               addWidget(this.m_rewardFrame = new ZwFrame(m_window.rewards_mc));
               this.m_milestone = this.manager.currentMilestone;
               if(this.m_rewardFrame.element.hasOwnProperty("title_tf"))
               {
                  addWidget(new ZwTextField(m_window.rewards_mc.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title")));
               }
               if(this.m_rewardFrame.element.hasOwnProperty("description_tf"))
               {
                  addWidget(this.m_desc = new ZwTextField(m_window.rewards_mc.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_precomplete_desc")));
               }
               if(this.m_rewardFrame.element.hasOwnProperty("close_bt"))
               {
                  m_closeButton = addWidget(new FarmButton(m_window.rewards_mc.close_bt,onClose)) as FarmButton;
               }
               if(this.m_rewardFrame.element.hasOwnProperty("deco_mc"))
               {
                  addWidget(this.m_decoMC = new ZwWidget(this.m_rewardFrame.element["deco_mc"]),false);
               }
               if(this.m_rewardFrame.element.hasOwnProperty("discount_mc"))
               {
                  addWidget(this.m_leftDiscountMC = new ZwWidget(this.m_rewardFrame.element["discount_mc"]),true);
               }
               if(this.m_rewardFrame.element.hasOwnProperty("key_mc"))
               {
                  addWidget(this.m_keyMC = new ZwWidget(this.m_rewardFrame.element["key_mc"]),false);
                  keyText = "Get this Key in the next expansion!";
                  addWidget(new ZwTextField(this.m_keyMC.element["key_tf"],keyText));
               }
               if(this.m_rewardFrame.element.hasOwnProperty("chest_tf"))
               {
                  addWidget(this.m_chestText = new FarmTextField(this.m_rewardFrame.element["chest_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_chest_locked")),false);
               }
               if(this.m_rewardFrame.element.hasOwnProperty("chestReward_mc"))
               {
                  addWidget(this.m_chestMC = new ZwWidget(this.m_rewardFrame.element["chestReward_mc"]),false);
                  this.setChestSize();
               }
               if(this.m_rewardFrame.element.hasOwnProperty("time_mc"))
               {
                  addWidget(this.m_timerFrame = new ZwFrame(this.m_rewardFrame.element["time_mc"]),true);
                  this.setTimerText();
               }
               if(this.m_rewardFrame.element.hasOwnProperty("ok_bt"))
               {
                  addWidget(this.m_awesomeBtn = new FarmAnimatedTextButton(this.m_rewardFrame.element["ok_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_CTA_OKtext"),this.onClickOkButton),true);
               }
               if(this.m_rewardFrame.element.hasOwnProperty("discountOnly_mc"))
               {
                  addWidget(this.m_centerDiscountOnlyMC = new ZwWidget(this.m_rewardFrame.element["discountOnly_mc"]),false);
               }
               if(this.m_rewardFrame.element.noReward_mc)
               {
                  addWidget(this.m_noReward = new ZwWidget(this.m_rewardFrame.element.noReward_mc),false);
               }
               if(this.m_milestone == this.manager.maxMilestone && this.manager.isFeaturePlayable())
               {
                  this.m_decoMC.visible = true;
                  this.m_keyMC.visible = true;
                  this.m_chestMC.visible = true;
                  this.m_timerFrame.visible = true;
               }
               else
               {
                  this.m_timerFrame.visible = false;
                  if(this.m_milestone == this.manager.maxMilestone)
                  {
                     this.m_decoMC.visible = true;
                  }
                  else if(this.m_milestone > 0)
                  {
                     for(j = 0; j < this.m_milestone; j++)
                     {
                        m_window.rewards_mc["icon_" + j + "_mc"].visible = true;
                     }
                  }
                  else
                  {
                     this.m_centerDiscountOnlyMC.visible = true;
                     this.m_leftDiscountMC.visible = false;
                  }
                  if(this.manager.isEAAvailable)
                  {
                     this.m_awesomeBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_CTA_text");
                     this.m_awesomeBtn.visible = true;
                     this.m_awesomeBtn.callback = this.onClickBuyButton;
                     this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_ea_desc");
                     this.m_keyMC.visible = true;
                     this.m_chestMC.visible = true;
                  }
                  else if(this.manager.isEAUser)
                  {
                     if(this.m_milestone > 0)
                     {
                        this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_unlocked_desc");
                     }
                     else
                     {
                        this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_unlocked_desc_noGifts");
                     }
                     this.m_awesomeBtn.visible = true;
                     this.showUnlockAnimation();
                  }
                  else if(this.manager.isGAAvailable)
                  {
                     this.m_awesomeBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_CTA_text");
                     this.m_leftDiscountMC.visible = false;
                     this.m_awesomeBtn.visible = true;
                     this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_ga_desc");
                     this.m_keyMC.visible = true;
                     this.m_chestMC.visible = true;
                  }
                  else if(this.manager.hasUnlockedLimbo)
                  {
                     this.m_leftDiscountMC.visible = false;
                     if(this.m_milestone == 0)
                     {
                        this.m_noReward.visible = true;
                        this.m_centerDiscountOnlyMC.visible = false;
                        this.m_desc.visible = false;
                     }
                     else if(this.m_milestone > 0)
                     {
                        this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_unlocked_desc");
                        this.showUnlockAnimation();
                     }
                     else
                     {
                        this.m_desc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Reward_unlocked_desc_noGifts");
                        this.showUnlockAnimation();
                     }
                  }
               }
            }
         }
      }
      
      private function setChestSize() : void
      {
         if(this.m_chestMC)
         {
            if(this.m_chestMC.element.hasOwnProperty("chestReward_mc"))
            {
               this.m_chestMC.element.chestReward_mc.visible = true;
               this.m_chestMC.element.chestReward_mc.gotoAndStop(this.m_milestone + 1);
            }
         }
      }
      
      private function showUnlockAnimation() : void
      {
         var unlockAnimationSeenFlag:String = this.m_featureName + "_unlockAnim";
         if(!Global.player.getSeenFlag(unlockAnimationSeenFlag) && Global.worldManager.currentWorldType == this.manager.WORLD_TYPE)
         {
            if(this.m_rewardFrame.element.hasOwnProperty(this.UNLOCK_ANIMATION))
            {
               this.m_rewardFrame.element[this.UNLOCK_ANIMATION].visible = true;
               (this.m_rewardFrame.element[this.UNLOCK_ANIMATION] as MovieClip).play();
               Global.player.setSeenFlag(unlockAnimationSeenFlag);
            }
            FarmStatsManager.count(this.m_featureName,"unlockAnimation","started","click");
         }
      }
      
      private function setTimerText() : void
      {
         var timeRemaining:Number = NaN;
         var numDays:int = 0;
         if(this.m_timerFrame)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.endTimeString) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            numDays = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
            this.m_timerFrame.element.timer_tf.text = HUD.getformattedTimeLeft(timeRemaining);
            this.m_timerFrame.visible = true;
            this.m_timerFrame.element.timer_tf.visible = true;
            if(!isNaN(timeRemaining))
            {
               if(numDays <= 2)
               {
                  if(numDays > 0)
                  {
                     this.startTimer();
                  }
               }
            }
         }
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.manager.endTimeString) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!isNaN(timeRemaining))
         {
            this.m_timerFrame.element.timer_tf.text = HUD.getformattedTimeLeft(timeRemaining);
         }
      }
      
      private function get manager() : XBOPremarketingManager
      {
         return XBOPremarketingManager.instance();
      }
      
      private function onClickBuyButton(event:Event) : void
      {
         if(this.m_awesomeBtn.enabled && this.manager.isEAAvailable)
         {
            this.close();
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
      }
      
      private function onClickOkButton(event:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         super.close();
      }
   }
}

