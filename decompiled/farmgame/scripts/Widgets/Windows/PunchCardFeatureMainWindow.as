package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.PunchCardFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class PunchCardFeatureMainWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "PunchCard";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const PUNCH_REWARDS_COUNT:int = 5;
      
      private const FLAG_GOLD_PUNCHCARD_UNLOCK:String = FEATURE_NAME + "_goldcard_unlock";
      
      private const FLAG_PUNCHCARD_FTUE_SEEN:String = FEATURE_NAME + "_ftue_seen";
      
      private const FLAG_PUNCHCARD_END_SEEN:String = FEATURE_NAME + "_end_seen";
      
      private var m_featureName:String = null;
      
      private var m_silvertitle_tf:TextField;
      
      private var m_goldtitle_tf:TextField;
      
      private var m_subtitle_tf:TextField;
      
      private var m_howthisworks_bt:FarmAnimatedTextButton;
      
      private var m_silvercard_mc:MovieClip;
      
      private var m_goldcard_mc:MovieClip;
      
      private var m_avenue_bt:FarmAnimatedTextButton;
      
      private var m_punch_slots:Array = [];
      
      private var m_reward_slots:Array = [];
      
      private var m_npcoverlay_mc:MovieClip;
      
      private var m_npccallout_tf:TextField;
      
      private var m_npcaccept_bt:FarmAnimatedTextButton;
      
      private var m_ftue_mc:MovieClip;
      
      private var m_ftue_tf:TextField;
      
      private var m_delayTimer:Timer;
      
      private var m_featureTimer:Timer;
      
      private var m_featuretime_tf:TextField;
      
      private var m_rewardsGrantList:* = new Array();
      
      private var m_active_npc:int = 1;
      
      public function PunchCardFeatureMainWindow(featureName:String = "PunchCard", assetUrl:String = null, rewardsGrantList:Array = null)
      {
         this.m_featureName = featureName;
         this.m_rewardsGrantList = rewardsGrantList;
         super(FEATURE_NAME,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var slot_name:String = null;
         var reward_name:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_howthisworks_bt = new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("silverheader_tf"))
         {
            this.m_silvertitle_tf = TextField(m_window["silverheader_tf"]);
         }
         if(m_window.hasOwnProperty("goldheader_tf"))
         {
            this.m_goldtitle_tf = TextField(m_window["goldheader_tf"]);
         }
         if(m_window.hasOwnProperty("subheadeer_tf"))
         {
            this.m_subtitle_tf = TextField(m_window["subheadeer_tf"]);
         }
         if(m_window.hasOwnProperty("silverpunchcard_mc"))
         {
            this.m_silvercard_mc = m_window["silverpunchcard_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("goldpunchcard_mc"))
         {
            this.m_goldcard_mc = m_window["goldpunchcard_mc"] as MovieClip;
         }
         for(var index:int = 0; index < this.PUNCH_REWARDS_COUNT; index++)
         {
            slot_name = "punch" + index.toString() + "_slot";
            if(m_window.hasOwnProperty(slot_name))
            {
               this.m_punch_slots[index] = m_window[slot_name] as MovieClip;
               this.m_punch_slots[index].visible = true;
            }
            reward_name = "reward" + index.toString();
            if(m_window.hasOwnProperty(reward_name))
            {
               this.m_reward_slots[index] = m_window[reward_name] as MovieClip;
            }
         }
         if(m_window.hasOwnProperty("loylty_bt"))
         {
            addWidget(this.m_avenue_bt = new FarmAnimatedTextButton(m_window["loylty_bt"],"Check Avenues",this.onAvenuesClick));
         }
         if(m_window.hasOwnProperty("npccallout_mc"))
         {
            this.m_npcoverlay_mc = m_window["npccallout_mc"] as MovieClip;
            if(this.m_npcoverlay_mc.hasOwnProperty("callout_tf"))
            {
               this.m_npccallout_tf = TextField(this.m_npcoverlay_mc["callout_tf"]);
            }
            if(this.m_npcoverlay_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_npcaccept_bt = new FarmAnimatedTextButton(this.m_npcoverlay_mc["okay_bt"],"Great!",this.onNPCButtonClick));
            }
            this.m_npcoverlay_mc.visible = false;
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_ftue_mc = m_window["ftue_mc"] as MovieClip;
            if(this.m_ftue_mc.hasOwnProperty("ftue_tf"))
            {
               this.m_ftue_tf = TextField(this.m_ftue_mc["ftue_tf"]);
            }
            if(this.m_ftue_mc.hasOwnProperty("okay_bt"))
            {
               new FarmAnimatedTextButton(this.m_ftue_mc["okay_bt"],"Let\'s Go!",this.onFTUEButtonClick);
            }
            this.m_ftue_mc.visible = false;
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            this.m_featuretime_tf = TextField(m_window["timeremains_tf"]);
         }
         if(!Global.player.getSeenFlag(this.FLAG_PUNCHCARD_FTUE_SEEN))
         {
            this.showFTUE();
         }
         if(this.manager.isFeatureCompletedByUser() && Global.player.getSeenFlag(this.FLAG_PUNCHCARD_END_SEEN))
         {
            this.updatePunchCardState();
            this.showNPCOverlay(1);
            FarmStatsManager.count(FEATURE_NAME,"npc_shown","feature_completed");
         }
         else
         {
            this.showPopupsAfterDelay();
         }
         if(this.manager.isFeatureCompletedByUser())
         {
            this.updateAfterFeatureComplete();
         }
         this.startFeatureTimer();
      }
      
      private function updatePunchCardState() : void
      {
         var rewardIndex:int = 0;
         var currentLevel:int = this.manager.currentMilestoneLevel;
         var tempLevel:int = this.manager.currentTempLevel;
         var punchIndex:int = this.getPunchIndex(currentLevel);
         for(var index:int = 0; index < this.PUNCH_REWARDS_COUNT; index++)
         {
            rewardIndex = this.getRewardIndex(index,currentLevel);
            if(punchIndex > index)
            {
               if(rewardIndex >= tempLevel && rewardIndex < currentLevel)
               {
                  this.playUnlockAnimationForIndex(index,rewardIndex);
               }
               else
               {
                  this.populatePunchSlots(index,true,rewardIndex);
               }
            }
            else
            {
               this.populatePunchSlots(index,false,rewardIndex);
            }
         }
         this.updateCardColor();
         this.manager.updateTempLevel();
      }
      
      public function populatePunchSlots(slotIndex:int = 0, isPunched:Boolean = false, rewardIndex:int = 0) : void
      {
         var rewardIcon:FarmIcon = null;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_REWARDS[rewardIndex]);
         if(isPunched == true)
         {
            if(this.m_punch_slots[slotIndex])
            {
               this.m_punch_slots[slotIndex]["afterpunch_mc"].visible = true;
               this.m_punch_slots[slotIndex]["checkmark_mc"].visible = true;
               this.m_punch_slots[slotIndex]["farmcash_mc"].visible = false;
               this.m_punch_slots[slotIndex]["count_tf"].visible = false;
               this.m_punch_slots[slotIndex]["claimed_tf"].text = " Claimed!";
               this.m_punch_slots[slotIndex]["claimed_tf"].visible = true;
               if(Boolean(rewardItem) && Boolean(this.m_punch_slots[slotIndex].hasOwnProperty("reward_icon")))
               {
                  rewardIcon = new FarmIcon(this.m_punch_slots[slotIndex]["reward_icon"],rewardItem.iconUrl);
                  if(rewardIcon)
                  {
                     rewardIcon.setIconSize(80,80);
                     rewardIcon.visible = true;
                  }
               }
            }
            if(this.m_reward_slots[slotIndex])
            {
               this.m_reward_slots[slotIndex].visible = false;
            }
         }
         else
         {
            if(this.m_punch_slots[slotIndex])
            {
               this.m_punch_slots[slotIndex]["afterpunch_mc"].visible = false;
               this.m_punch_slots[slotIndex]["checkmark_mc"].visible = false;
               this.m_punch_slots[slotIndex]["farmcash_mc"].visible = true;
               this.m_punch_slots[slotIndex]["claimed_tf"].visible = false;
               this.m_punch_slots[slotIndex]["count_tf"].text = this.manager.getMilestoneSpendAmount(rewardIndex);
               this.m_punch_slots[slotIndex]["count_tf"].visible = true;
            }
            if(this.m_reward_slots[slotIndex])
            {
               this.m_reward_slots[slotIndex].visible = true;
            }
         }
      }
      
      private function getPunchIndex(currentLevel:int) : int
      {
         var result:int = currentLevel >= this.PUNCH_REWARDS_COUNT ? int(currentLevel - this.PUNCH_REWARDS_COUNT) : currentLevel;
         if(this.isCardUpgradeMoment())
         {
            result = this.PUNCH_REWARDS_COUNT;
         }
         return result;
      }
      
      private function getRewardIndex(slotIndex:int, currentLevel:int) : int
      {
         var result:int = currentLevel >= this.PUNCH_REWARDS_COUNT ? int(slotIndex + this.PUNCH_REWARDS_COUNT) : slotIndex;
         if(this.isCardUpgradeMoment())
         {
            result = currentLevel > this.PUNCH_REWARDS_COUNT ? int(slotIndex + this.PUNCH_REWARDS_COUNT) : slotIndex;
         }
         return result;
      }
      
      private function updateCardColor() : void
      {
         var currentLevel:int = this.manager.currentMilestoneLevel;
         var isCardSilver:Boolean = currentLevel < this.PUNCH_REWARDS_COUNT;
         if(this.isCardUpgradeMoment())
         {
            isCardSilver = true;
         }
         if(isCardSilver)
         {
            if(this.m_goldtitle_tf)
            {
               this.m_goldtitle_tf.visible = false;
            }
            if(this.m_silvertitle_tf)
            {
               this.m_silvertitle_tf.text = "SILVER TICKET";
               this.m_silvertitle_tf.visible = true;
            }
            if(this.m_subtitle_tf)
            {
               this.m_subtitle_tf.text = "Spend FC anywhere in the Maple Frontier to reach FC milestones and win Huge rewards";
               this.m_subtitle_tf.visible = true;
            }
            if(this.m_goldcard_mc)
            {
               this.m_goldcard_mc.visible = false;
            }
            if(this.m_silvercard_mc)
            {
               this.m_silvercard_mc.visible = true;
            }
         }
         else
         {
            if(this.m_silvertitle_tf)
            {
               this.m_silvertitle_tf.visible = false;
            }
            if(this.m_goldtitle_tf)
            {
               this.m_goldtitle_tf.text = "GOLDEN TICKET";
               this.m_goldtitle_tf.visible = true;
            }
            if(this.m_subtitle_tf)
            {
               this.m_subtitle_tf.text = "Special rewards for special Farmers!";
               this.m_subtitle_tf.visible = true;
            }
            if(this.m_silvercard_mc)
            {
               this.m_silvercard_mc.visible = false;
            }
            if(this.m_goldcard_mc)
            {
               this.m_goldcard_mc.visible = true;
            }
         }
      }
      
      public function playUnlockAnimationForIndex(punchIndex:int, rewardIndex:int) : void
      {
         var rewardIcon:FarmIcon = null;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_REWARDS[rewardIndex]);
         if(Boolean(this.m_reward_slots[punchIndex]) && Boolean(this.m_reward_slots[punchIndex].hasOwnProperty("reward_icon")))
         {
            if(Boolean(rewardItem) && Boolean(this.m_reward_slots[punchIndex].hasOwnProperty("reward_icon")))
            {
               rewardIcon = new FarmIcon(this.m_reward_slots[punchIndex]["reward_icon"],rewardItem.iconUrl);
               if(rewardIcon)
               {
                  rewardIcon.setIconSize(80,80);
               }
            }
            this.m_reward_slots[punchIndex].visible = true;
            this.m_reward_slots[punchIndex].gotoAndPlay(2);
         }
         if(this.m_punch_slots[punchIndex])
         {
            this.m_punch_slots[punchIndex]["farmcash_mc"].visible = false;
            this.m_punch_slots[punchIndex]["count_tf"].visible = false;
            this.m_punch_slots[punchIndex]["claimed_tf"].text = " Claimed!";
            this.m_punch_slots[punchIndex]["claimed_tf"].visible = true;
         }
      }
      
      private function updateNPCCallouts() : void
      {
         if(this.manager.currentMilestoneLevel >= this.PUNCH_REWARDS_COUNT)
         {
            if(!Global.player.getSeenFlag(this.FLAG_GOLD_PUNCHCARD_UNLOCK))
            {
               Global.player.setSeenFlag(this.FLAG_GOLD_PUNCHCARD_UNLOCK);
               this.m_active_npc = 0;
               this.showNPCOverlay(0);
               FarmStatsManager.count(FEATURE_NAME,"npc_shown","gold_card_unlocked");
            }
            if(this.manager.isFeatureCompletedByUser())
            {
               Global.player.setSeenFlag(this.FLAG_PUNCHCARD_END_SEEN);
               this.m_active_npc = 1;
               this.showNPCOverlay(1);
               FarmStatsManager.count(FEATURE_NAME,"npc_shown","feature_completed");
            }
         }
      }
      
      private function showNPCOverlay(index:int) : void
      {
         switch(index)
         {
            case 0:
               this.m_active_npc = 0;
               if(this.m_npccallout_tf)
               {
                  this.m_npccallout_tf.text = "Hurray! Silver ticket is punched completely. You have unlocked the Golden Ticket with even bigger rewards.";
                  this.m_npccallout_tf.visible = true;
               }
               break;
            case 1:
               this.m_active_npc = 1;
               if(this.m_npccallout_tf)
               {
                  this.m_npccallout_tf.text = "You are a rockstar! Golden ticket is finished. Stay tuned to more exciting features.\n" + "Keep Farming!";
                  this.m_npccallout_tf.visible = true;
               }
         }
         if(this.m_npcoverlay_mc)
         {
            this.m_npcoverlay_mc.visible = true;
         }
      }
      
      private function onNPCButtonClick(e:Event = null) : void
      {
         if(this.m_npcoverlay_mc)
         {
            this.m_npcoverlay_mc.visible = false;
         }
         if(this.m_active_npc == 0)
         {
            this.manager.closeAndOpenMainWindow();
         }
         else
         {
            this.updatePunchCardState();
         }
      }
      
      private function showFTUE() : void
      {
         Global.player.setSeenFlag(this.FLAG_PUNCHCARD_FTUE_SEEN);
         if(this.m_ftue_tf)
         {
            this.m_ftue_tf.text = "Win surprise rewards with every FC spend in Maple Frontier.\n" + "Get your ticket punched to win huge rewards!";
            this.m_ftue_tf.visible = true;
         }
         if(this.m_ftue_mc)
         {
            this.m_ftue_mc.visible = true;
         }
      }
      
      private function onFTUEButtonClick(e:Event = null) : void
      {
         if(this.m_ftue_mc)
         {
            this.m_ftue_mc.visible = false;
         }
         this.updateNPCCallouts();
      }
      
      private function isCardUpgradeMoment() : Boolean
      {
         var result:Boolean = false;
         if(this.manager.currentMilestoneLevel == this.PUNCH_REWARDS_COUNT && !Global.player.getSeenFlag(this.FLAG_GOLD_PUNCHCARD_UNLOCK))
         {
            result = true;
         }
         return result;
      }
      
      private function onAvenuesClick(e:Event = null) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.showAvenuesWindow();
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         this.showFTUE();
      }
      
      private function showPopupsAfterDelay() : void
      {
         this.updatePunchCardState();
         this.m_delayTimer = new Timer(3000,1);
         this.m_delayTimer.addEventListener(TimerEvent.TIMER,this.showPopups);
         this.m_delayTimer.start();
      }
      
      private function showPopups(e:Event = null) : void
      {
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         if(this.manager.m_mainWindow)
         {
            this.updateNPCCallouts();
         }
         if(this.m_rewardsGrantList)
         {
            for each(rewardName in this.m_rewardsGrantList)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               if(rewardItem)
               {
                  this.manager.showRewardPopup(rewardItem);
               }
            }
         }
         if(this.m_delayTimer)
         {
            this.m_delayTimer.stop();
            this.m_delayTimer.removeEventListener(TimerEvent.TIMER,this.showPopups);
         }
      }
      
      private function updateAfterFeatureComplete() : void
      {
         if(this.m_avenue_bt)
         {
            this.m_avenue_bt.visible = false;
         }
         if(this.m_howthisworks_bt)
         {
            this.m_howthisworks_bt.visible = false;
         }
         if(this.m_subtitle_tf)
         {
            this.m_subtitle_tf.text = "Congrats! You have got all the rewards here!";
            this.m_subtitle_tf.visible = true;
         }
      }
      
      private function get manager() : PunchCardFeatureManager
      {
         return PunchCardFeatureManager.getInstance(FEATURE_NAME);
      }
      
      private function startFeatureTimer() : void
      {
         this.m_featureTimer = new Timer(1000);
         this.m_featureTimer.addEventListener(TimerEvent.TIMER,this.onFeatureTimer);
         this.m_featureTimer.start();
      }
      
      private function onFeatureTimer(event:TimerEvent) : void
      {
         if(this.m_featuretime_tf)
         {
            this.m_featuretime_tf.text = this.manager.getFeatureTimerText();
            this.m_featuretime_tf.visible = true;
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_featureTimer)
         {
            this.m_featureTimer.stop();
            this.m_featureTimer.removeEventListener(TimerEvent.TIMER,this.onFeatureTimer);
            this.m_featureTimer = null;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         super.close();
      }
   }
}

