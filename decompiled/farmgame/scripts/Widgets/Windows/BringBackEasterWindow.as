package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BringBackWinterFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.BringBackEasterCollectionSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BringBackEasterWindow extends BBWinterReskinnableWindow
   {
      
      private static var m_bonusDetailWindow:BringBackEasterRewardWindow;
      
      private static const NUM_TUTORIAL_FRAMES:int = 5;
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const NUM_TUTORIAL_SCENES_BEFORE_EASTER:int = 6;
      
      private static const FEATURE_CONSUMBLE_END_DATE:String = "01/14/2019";
      
      private const SERVICE_NAME:String = "BringBackChristmasService";
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 540;
      
      private const BAR_INITIAL_POSTION:int = -264;
      
      private const NO_OF_STEPS_IN_BAR:int = 4;
      
      private var sfcounter_mc:MovieClip;
      
      private var sfcounter_frame:ZwFrame;
      
      private var timeleft_frame:ZwFrame;
      
      private var clock_frame:ZwFrame;
      
      private var time_tf:FarmTextField;
      
      private var timeleft_tf:ZwTextField;
      
      private var title_tf:FarmTextField;
      
      private var congrats_tf:FarmTextField;
      
      private var subtitle1_tf:FarmTextField;
      
      private var subtitle2_tf:FarmTextField;
      
      private var subtitle3_tf:FarmTextField;
      
      private var bonusSubtitle1_tf:FarmTextField;
      
      private var bonusSubtitle2_tf:FarmTextField;
      
      private var m_chainedMc:MovieClip;
      
      private var m_freeMc:MovieClip;
      
      private var m_witchMc:MovieClip;
      
      private var m_npcMC:MovieClip;
      
      private var m_redeemloaderMC:MovieClip;
      
      private var m_bonusMc:ZwWidget;
      
      private var m_loaderMc:MovieClip;
      
      private var m_playerBadgeMc:MovieClip;
      
      private var m_cellframe1:ZwFrame;
      
      private var m_cellframe2:ZwFrame;
      
      private var m_cellframe3:ZwFrame;
      
      private var m_easterBenefit_mc:MovieClip;
      
      private var m_EasterEgg_1_mc:MovieClip;
      
      private var m_EasterEgg_2_mc:MovieClip;
      
      private var m_hitArea_mc:MovieClip;
      
      private var m_playerrankTf:ZwTextField;
      
      private var m_playerrank2Tf:ZwTextField;
      
      private var m_playerCellMc:MovieClip;
      
      private var m_playerTrophiesMc:MovieClip;
      
      private var m_playerScore:ZwTextField;
      
      private var m_playerName:ZwTextField;
      
      private var m_player1Score:ZwTextField;
      
      private var m_player1Name:ZwTextField;
      
      private var m_player2Score:ZwTextField;
      
      private var m_player2Name:ZwTextField;
      
      private var m_player3Score:ZwTextField;
      
      private var m_player3Name:ZwTextField;
      
      private var m_player_icon:FarmIcon;
      
      private var m_player1_icon:FarmIcon;
      
      private var m_player2_icon:FarmIcon;
      
      private var m_player3_icon:FarmIcon;
      
      private var m_rescueMc:MovieClip;
      
      private var m_sadTeamMc:MovieClip;
      
      private var m_happyAnimalMc:MovieClip;
      
      private var m_happyTeamMc:MovieClip;
      
      private var m_meterMc:MovieClip;
      
      private var m_bar_fillMc:MovieClip;
      
      private var m_reward_1_trigger_mc:MovieClip;
      
      private var m_completeIcon_1_mc:MovieClip;
      
      private var m_reward_1_mc:MovieClip;
      
      private var m_reward_2_mc:MovieClip;
      
      private var m_reward_3_mc:MovieClip;
      
      private var m_badge_1_mc:MovieClip;
      
      private var m_badge_2_mc:MovieClip;
      
      private var m_badge_3_mc:MovieClip;
      
      private var m_num_rewards_collected_mc:MovieClip;
      
      private var m_rewads_total_mc:MovieClip;
      
      private var m_item:FarmItem;
      
      private var m_BonusMc:MovieClip;
      
      private var m_Bonus1Mc:MovieClip;
      
      private var m_Bonus2Mc:MovieClip;
      
      private var m_Bonus1HitMc:MovieClip;
      
      private var m_Bonus2HitMc:MovieClip;
      
      private var m_bonusRewardDetailButton:FarmAnimatedTextButton;
      
      private var m_BonusSliderAni:MovieClip;
      
      private var m_BonusSliderMc:MovieClip;
      
      private var m_hitWidget1:ZwWidget;
      
      private var m_hitWidget2:ZwWidget;
      
      private var COLLECTED_ALL_BONUS:int = 3;
      
      private var m_stageRewardOneIcon:FarmIcon;
      
      private var m_stageRewardTwoIcon:FarmIcon;
      
      private var m_stageRewardThreeIcon:FarmIcon;
      
      private var m_friend_list:Object = null;
      
      public function BringBackEasterWindow(featureName:String)
      {
         super(featureName);
      }
      
      override protected function getNumTutorialScenes() : int
      {
         if(this.manager.hasTimeGatePassed() || this.manager.hasBonusBeenGranted() != 0)
         {
            return NUM_TUTORIAL_SCENES;
         }
         return NUM_TUTORIAL_SCENES_BEFORE_EASTER;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("witch_mc"))
         {
            this.m_witchMc = m_window["witch_mc"] as MovieClip;
            this.m_witchMc.visible = !BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems();
         }
         if(m_window.hasOwnProperty("NPC_mc"))
         {
            this.m_npcMC = m_window["NPC_mc"] as MovieClip;
            this.m_npcMC.visible = true;
         }
         if(m_window.hasOwnProperty("redeemloader_mc"))
         {
            this.m_redeemloaderMC = m_window["redeemloader_mc"] as MovieClip;
            this.m_redeemloaderMC.visible = false;
         }
         super.postLoadComplete();
         if(BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
         {
         }
         FarmStatsManager.count("GPF_royalrescue2018","mainui","open");
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
      }
      
      public function onMainWindowClose() : void
      {
         BringBackWinterManager.getInstance(m_featureName).onWindowClose();
         close();
      }
      
      override protected function showFTUE() : void
      {
         super.showFTUE();
         if(m_ftue)
         {
            if(this.m_witchMc)
            {
               this.m_witchMc.visible = false;
            }
            if(this.m_npcMC)
            {
               this.m_npcMC.visible = false;
            }
         }
      }
      
      private function resumeWindow(evt:Event = null) : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      override protected function onFTUEOKBtnClick(event:Event) : void
      {
         super.onFTUEOKBtnClick(event);
         if(m_tutorialScene > this.getNumTutorialScenes())
         {
            if(this.m_witchMc)
            {
               this.m_witchMc.visible = true;
            }
            if(this.m_npcMC)
            {
               this.m_npcMC.visible = true;
            }
         }
      }
      
      override protected function setUpMainWindow() : void
      {
         var sfcounter_mc:MovieClip = null;
         var isPegacornFreed:Boolean = false;
         var count:int = 0;
         var text:String = null;
         var consumableEndTimeStamp:Number = NaN;
         var currentTime:Number = NaN;
         var collectionSlot:BringBackEasterCollectionSlot = null;
         var i:int = 0;
         var timeleft_mc:MovieClip = null;
         var clock_mc:MovieClip = null;
         var bonusReward:String = null;
         var m_bonusitem:FarmItem = null;
         if(m_window.hasOwnProperty("sfcounter_mc"))
         {
            sfcounter_mc = m_window.sfcounter_mc as MovieClip;
            addWidget(this.sfcounter_frame = new ZwFrame(m_window.sfcounter_mc),true);
            if(m_window.slot_mc)
            {
               this.sfcounter_frame.addWidget(m_slotsFrame = new BringBackWinterFrame(m_window.slot_mc,m_featureName,this),true);
            }
            if(sfcounter_mc.hasOwnProperty("timeleft_mc") && !this.manager.isFeatureEnd())
            {
               if(sfcounter_mc.hasOwnProperty("clock_mc"))
               {
                  clock_mc = sfcounter_mc["clock_mc"] as MovieClip;
                  this.sfcounter_frame.addWidget(this.clock_frame = new ZwFrame(sfcounter_mc["clock_mc"]),true);
               }
               timeleft_mc = sfcounter_mc["timeleft_mc"] as MovieClip;
               this.sfcounter_frame.addWidget(this.timeleft_frame = new ZwFrame(sfcounter_mc.timeleft_mc),true);
               if(timeleft_mc.hasOwnProperty("time_tf"))
               {
                  this.timeleft_frame.addWidget(this.time_tf = new FarmTextField(timeleft_mc.time_tf),true);
                  this.time_tf.text = this.manager.getTimeRemainingInString();
                  this.time_tf.visible = true;
               }
               if(timeleft_mc.hasOwnProperty("left_tf"))
               {
                  this.timeleft_frame.addWidget(this.timeleft_tf = new ZwTextField(timeleft_mc.left_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_timeLeftText")),true);
                  this.timeleft_frame.visible = true;
                  this.timeleft_tf.visible = true;
               }
            }
            if(sfcounter_mc.hasOwnProperty("comment_tf") && BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
            {
               this.sfcounter_frame.addWidget(this.congrats_tf = new FarmTextField(sfcounter_mc.comment_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterCongratsTitle")),true);
            }
            if(sfcounter_mc.hasOwnProperty("subtitle1_tf"))
            {
               this.sfcounter_frame.addWidget(this.subtitle1_tf = new FarmTextField(sfcounter_mc.subtitle1_tf),true);
            }
            isPegacornFreed = BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems() || BringBackWinterManager.getInstance(m_featureName).isFeatureEnd();
            count = BringBackWinterManager.getInstance(m_featureName).numCollectedItem();
            text = null;
            if(sfcounter_mc.hasOwnProperty("subtitle2_tf"))
            {
               text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle2",{"count":count});
               this.sfcounter_frame.addWidget(this.subtitle2_tf = new FarmTextField(sfcounter_mc.subtitle2_tf,text),!isPegacornFreed);
            }
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            consumableEndTimeStamp = FarmGameUtil.synchronizedDateToNumber(FEATURE_CONSUMBLE_END_DATE) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(sfcounter_mc.hasOwnProperty("subtitle3_tf") && currentTime < consumableEndTimeStamp)
            {
               if(this.manager.hasTimeGatePassed())
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle3_AfterTimeGate");
               }
               else
               {
                  text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle3");
               }
               this.sfcounter_frame.addWidget(this.subtitle3_tf = new FarmTextField(sfcounter_mc.subtitle3_tf,text),!isPegacornFreed);
            }
            if(m_window.hasOwnProperty("bonus_reward_mc"))
            {
               bonusReward = BringBackWinterManager.getInstance(m_featureName).getBonusReward();
               m_bonusitem = Global.farmGameSettingsManager.getFarmItemByName(bonusReward);
               m_window.bonus_reward_mc.visible = true;
               m_window.bonus_reward_mc.hover_text_mc.text = m_bonusitem.friendlyTitle;
               m_window.bonus_reward_mc.hover_text_mc.visible = true;
               this.m_bonusMc = addWidget(new ZwWidget(m_window["bonus_reward_mc"])) as ZwWidget;
               text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_bonusRewardText");
               this.m_bonusMc.attachTooltip(new FarmTextTooltip(text));
            }
            for(i = 0; i < BringBackWinterManager.SFTYPES.length; i++)
            {
               if(sfcounter_mc.hasOwnProperty("snowflake_" + BringBackWinterManager.SFTYPES[i] + "_mc"))
               {
                  collectionSlot = new BringBackEasterCollectionSlot(sfcounter_mc["snowflake_" + BringBackWinterManager.SFTYPES[i] + "_mc"],m_featureName,BringBackWinterManager.SFTYPES[i],this);
                  this.sfcounter_frame.addWidget(collectionSlot,true);
                  m_collectionSlots.push(collectionSlot);
               }
            }
            if(sfcounter_mc.hasOwnProperty("buy_bt"))
            {
               this.sfcounter_frame.addWidget(new FarmAnimatedTextButton(sfcounter_mc["buy_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_Buy"),onBuyClick));
            }
            if(sfcounter_mc.hasOwnProperty("chained_mc"))
            {
               this.m_chainedMc = sfcounter_mc.chained_mc as MovieClip;
               this.m_chainedMc.visible = !isPegacornFreed;
            }
            if(sfcounter_mc.hasOwnProperty("free_mc"))
            {
               this.m_freeMc = sfcounter_mc.free_mc as MovieClip;
               this.m_freeMc.visible = isPegacornFreed;
            }
            if(sfcounter_mc.hasOwnProperty("bg_mc"))
            {
               this.m_rescueMc = sfcounter_mc.bg_mc as MovieClip;
               this.m_rescueMc.visible = true;
               if(isPegacornFreed)
               {
                  count += 1;
               }
               (this.m_rescueMc as MovieClip).gotoAndStop(count);
            }
            if(sfcounter_mc.hasOwnProperty("sadteam_mc"))
            {
               this.m_sadTeamMc = sfcounter_mc.sadteam_mc as MovieClip;
               this.m_sadTeamMc.visible = !isPegacornFreed;
            }
            if(sfcounter_mc.hasOwnProperty("happyanimal_mc"))
            {
               this.m_happyAnimalMc = sfcounter_mc.happyanimal_mc as MovieClip;
               this.m_happyAnimalMc.visible = isPegacornFreed;
            }
            if(sfcounter_mc.hasOwnProperty("happyteam_mc"))
            {
               this.m_happyTeamMc = sfcounter_mc.happyteam_mc as MovieClip;
               this.m_happyTeamMc.visible = isPegacornFreed;
            }
            if(!this.manager.isFeatureEnd())
            {
               this.updateBonusFrame();
            }
            this.updateText();
         }
      }
      
      private function updateBonusFrame() : void
      {
         var m_bonus1MCtooltip:FarmIcon = null;
         var m_bonus2MCtooltip:FarmIcon = null;
         var m_bonusMC1tooltip:FarmIcon = null;
         var m_bonusMC2tooltip:FarmIcon = null;
         var sfcounter_mc:MovieClip = m_window.sfcounter_mc as MovieClip;
         var bonusNo:int = this.manager.hasBonusBeenGranted();
         if(!this.manager.hasTimeGatePassed() || bonusNo == 3)
         {
            if(sfcounter_mc.hasOwnProperty("Bonus_BeforeEaster_mc"))
            {
               this.m_BonusMc = sfcounter_mc.Bonus_BeforeEaster_mc as MovieClip;
               if(this.m_BonusMc.hasOwnProperty("BonusSliderAni"))
               {
                  this.m_BonusSliderAni = this.m_BonusMc.BonusSliderAni;
                  this.m_BonusSliderAni.visible = false;
                  if(this.m_BonusSliderAni.hasOwnProperty("BonusSliderMc"))
                  {
                     this.m_BonusSliderMc = this.m_BonusSliderAni.BonusSliderMc;
                     this.m_BonusSliderMc.visible = false;
                     if(this.m_BonusSliderMc.hasOwnProperty("subtitle1_tf"))
                     {
                        addWidget(this.bonusSubtitle1_tf = new FarmTextField(this.m_BonusSliderMc.subtitle1_tf),true);
                        this.bonusSubtitle1_tf.text = "Kringle’s Bonus!";
                        this.bonusSubtitle1_tf.visible = true;
                     }
                     if(this.m_BonusSliderMc.hasOwnProperty("subtitle2_tf"))
                     {
                        addWidget(this.bonusSubtitle2_tf = new FarmTextField(this.m_BonusSliderMc.subtitle2_tf),true);
                        this.bonusSubtitle2_tf.text = "Something extra for your exceptional effort!";
                        this.bonusSubtitle2_tf.visible = true;
                     }
                  }
               }
            }
         }
         else if(sfcounter_mc.hasOwnProperty("Bonus_AfterEaster_mc"))
         {
            this.m_BonusMc = sfcounter_mc.Bonus_AfterEaster_mc as MovieClip;
         }
         if(this.m_BonusMc)
         {
            this.m_BonusMc.visible = true;
            if(this.m_BonusMc.hasOwnProperty("bonusRewardsDetail_bt"))
            {
               addWidget(this.m_bonusRewardDetailButton = new FarmAnimatedTextButton(this.m_BonusMc.bonusRewardsDetail_bt,"Know More",this.onBonusDetailClick));
               this.m_bonusRewardDetailButton.visible = this.manager.hasBonusBeenGranted() == 0;
            }
            if(this.m_BonusMc.hasOwnProperty("Bonus1_mc"))
            {
               this.m_Bonus1Mc = this.m_BonusMc.Bonus1_mc as MovieClip;
               this.m_Bonus1Mc.visible = true;
            }
            if(this.m_BonusMc.hasOwnProperty("Bonus2_mc"))
            {
               this.m_Bonus2Mc = this.m_BonusMc.Bonus2_mc as MovieClip;
               this.m_Bonus2Mc.visible = true;
            }
            if(this.m_BonusMc.hasOwnProperty("Bonus1Hit_mc"))
            {
               this.m_Bonus1HitMc = this.m_BonusMc.Bonus1Hit_mc as MovieClip;
               this.m_Bonus1HitMc.visible = true;
               m_bonus1MCtooltip = new FarmIcon(this.m_Bonus1HitMc);
               m_bonus1MCtooltip.attachTooltip(new FarmTextTooltip("Xmas Yearling Unicorn"));
            }
            if(this.m_BonusMc.hasOwnProperty("Bonus2Hit_mc"))
            {
               this.m_Bonus2HitMc = this.m_BonusMc.Bonus2Hit_mc as MovieClip;
               this.m_Bonus2HitMc.visible = true;
               m_bonus2MCtooltip = new FarmIcon(this.m_Bonus2HitMc);
               m_bonus2MCtooltip.attachTooltip(new FarmTextTooltip("Yule Pegasus"));
            }
            if(this.m_BonusMc.hasOwnProperty("easterBenefit_mc"))
            {
               this.m_easterBenefit_mc = this.m_BonusMc.easterBenefit_mc as MovieClip;
               this.m_easterBenefit_mc.visible = true;
               if(this.m_easterBenefit_mc.hasOwnProperty("EasterEgg_1_mc"))
               {
                  this.m_EasterEgg_1_mc = this.m_easterBenefit_mc.EasterEgg_1_mc as MovieClip;
                  this.m_EasterEgg_1_mc.visible = true;
               }
               if(this.m_easterBenefit_mc.hasOwnProperty("EasterEgg_2_mc"))
               {
                  this.m_EasterEgg_2_mc = this.m_easterBenefit_mc.EasterEgg_2_mc as MovieClip;
                  this.m_EasterEgg_2_mc.visible = true;
               }
               if(this.m_easterBenefit_mc.hasOwnProperty("hitArea_mc"))
               {
                  this.m_hitArea_mc = this.m_easterBenefit_mc.hitArea_mc as MovieClip;
                  this.m_hitArea_mc.visible = true;
                  addWidget(this.m_hitWidget1 = new ZwFrame(this.m_hitArea_mc),true);
                  if(!this.manager.hasTimeGatePassed())
                  {
                     this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
                     this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
                  }
               }
            }
            if(bonusNo == 3)
            {
               this.m_BonusMc.gotoAndStop(2);
            }
            else if(bonusNo == 2)
            {
               this.m_BonusMc.gotoAndStop(3);
               m_bonusMC1tooltip = new FarmIcon(this.m_BonusMc);
               m_bonusMC1tooltip.attachTooltip(new FarmTextTooltip("Yule Pegasus"));
            }
            else if(bonusNo == 1)
            {
               this.m_BonusMc.gotoAndStop(2);
               m_bonusMC2tooltip = new FarmIcon(this.m_BonusMc);
               m_bonusMC2tooltip.attachTooltip(new FarmTextTooltip("Xmas Yearling Unicorn"));
            }
         }
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_BonusSliderAni.visible = true;
            m_BonusSliderMc.visible = true;
            m_BonusSliderMc.gotoAndPlay(1);
            m_BonusSliderAni.gotoAndPlay("_show");
            m_easterBenefit_mc.gotoAndPlay(1);
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_BonusSliderMc.visible = false;
            m_BonusSliderAni.visible = false;
            m_BonusSliderAni.gotoAndStop("_show");
            m_easterBenefit_mc.gotoAndStop(1);
         };
      }
      
      private function get manager() : BringBackWinterManager
      {
         return BringBackWinterManager.getInstance(m_featureName);
      }
      
      private function onBonusDetailClick(event:Event) : void
      {
         m_bonusDetailWindow = new BringBackEasterRewardWindow("bonus_reward",m_featureName,this.resumeWindow);
         UI.displayPopup(m_bonusDetailWindow,false,"BonusRewardDetail",true);
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      override protected function initializeProgressBar() : void
      {
         var stageAtTheMoment:int = 0;
         if(m_window.hasOwnProperty("sfcounter_mc"))
         {
            m_window.sfcounter_mc.visible = true;
            m_window.sfcounter_mc.meter_mc.visible = true;
            stageAtTheMoment = BringBackWinterManager.getInstance(m_featureName).getNumofStageCompleted();
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"getFriendsInfoAboutCompletion",this.onGettingFriendsInfoAboutCompletion,[m_featureName]));
            this.updateProgressBar(stageAtTheMoment);
         }
      }
      
      private function onGettingFriendsInfoAboutCompletion(friends:Object) : void
      {
         var bonusRewardPkg:Array = null;
         var stage1:int = 0;
         var badgeText1:String = null;
         var badgeText11:String = null;
         var badgeText1111:String = null;
         var stage2:int = 0;
         var badgeText2:String = null;
         var badgeText22:String = null;
         var badgeText2222:String = null;
         var stage3:int = 0;
         var badgeText3:String = null;
         var badgeText33:String = null;
         var badgeText3333:String = null;
         var stage01:int = 0;
         var stage02:int = 0;
         var stage03:int = 0;
         var badgeText111:String = null;
         var badgeText222:String = null;
         var badgeText333:String = null;
         var count1:int = 0;
         var count2:int = 0;
         var count3:int = 0;
         var name1:String = "";
         var name2:String = "";
         var name3:String = "";
         this.m_friend_list = friends;
         if(Boolean(m_window) && m_window.hasOwnProperty("sfcounter_mc"))
         {
            bonusRewardPkg = BringBackWinterManager.getInstance(m_featureName).getBonusRewardPkgs();
            this.m_meterMc = m_window.sfcounter_mc.meter_mc;
            if(!BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
            {
               if(Boolean(friends) && friends["status"] === "success")
               {
                  if(this.m_meterMc.hasOwnProperty("badge_1_mc") && Boolean(friends["2"]))
                  {
                     stage1 = int(bonusRewardPkg[0]["stage"]);
                     count1 = friends["2"].length - 1;
                     name1 = friends["2"].name;
                     if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage1))
                     {
                        if(count1 > 0)
                        {
                           badgeText1 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friends ",{
                              "name":name1,
                              "num":count1
                           });
                           this.m_badge_1_mc.badgeMessage_2_tf.text = badgeText1;
                        }
                        else if(count1 == 0)
                        {
                           badgeText11 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friend",{"name":name1});
                           this.m_badge_1_mc.badgeMessage_2_tf.text = badgeText11;
                        }
                        else
                        {
                           badgeText1111 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                           this.m_badge_1_mc.badgeMessage_2_tf.text = badgeText1111;
                        }
                     }
                  }
                  if(this.m_meterMc.hasOwnProperty("badge_2_mc") && Boolean(friends["3"]))
                  {
                     stage2 = int(bonusRewardPkg[1]["stage"]);
                     count2 = friends["3"].length - 1;
                     name2 = friends["3"].name;
                     if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage2))
                     {
                        if(count2)
                        {
                           badgeText2 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friends ",{
                              "name":name2,
                              "num":count2
                           });
                           this.m_badge_2_mc.badgeMessage_2_tf.text = badgeText2;
                        }
                        else if(count2 == 0)
                        {
                           badgeText22 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friend",{"name":name1});
                           this.m_badge_2_mc.badgeMessage_2_tf.text = badgeText22;
                        }
                        else
                        {
                           badgeText2222 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                           this.m_badge_2_mc.badgeMessage_2_tf.text = badgeText2222;
                        }
                     }
                  }
                  if(this.m_meterMc.hasOwnProperty("badge_3_mc") && Boolean(friends["4"]))
                  {
                     stage3 = int(bonusRewardPkg[2]["stage"]);
                     count3 = friends["4"].length - 1;
                     name3 = friends["4"].name;
                     if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage3))
                     {
                        if(count3)
                        {
                           badgeText3 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friends ",{
                              "name":name3,
                              "num":count3
                           });
                           this.m_badge_3_mc.badgeMessage_2_tf.text = badgeText3;
                        }
                        else if(count3 == 0)
                        {
                           badgeText33 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_num_of_friend",{"name":name1});
                           this.m_badge_3_mc.badgeMessage_2_tf.text = badgeText33;
                        }
                        else
                        {
                           badgeText3333 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                           this.m_badge_3_mc.badgeMessage_2_tf.text = badgeText3333;
                        }
                     }
                  }
               }
               if(Boolean(friends) && friends["status"] === "failed")
               {
                  stage01 = int(bonusRewardPkg[0]["stage"]);
                  if(this.m_meterMc.hasOwnProperty("badge_1_mc") && BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage01))
                  {
                     badgeText111 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                     this.m_badge_1_mc.badgeMessage_2_tf.text = badgeText111;
                  }
                  stage02 = int(bonusRewardPkg[1]["stage"]);
                  if(this.m_meterMc.hasOwnProperty("badge_2_mc") && BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage02))
                  {
                     badgeText222 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                     this.m_badge_2_mc.badgeMessage_2_tf.text = badgeText222;
                  }
                  stage03 = int(bonusRewardPkg[2]["stage"]);
                  if(this.m_meterMc.hasOwnProperty("badge_3_mc") && BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage03))
                  {
                     badgeText333 = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_first_to_get");
                     this.m_badge_3_mc.badgeMessage_2_tf.text = badgeText333;
                  }
               }
            }
         }
      }
      
      override protected function updateProgressBar(percentValue:Number) : void
      {
         var stage:int = 0;
         var countOfCollectedItems:int = BringBackWinterManager.getInstance(m_featureName).numCollectedItem();
         var rewardPkgs:Array = BringBackWinterManager.getInstance(m_featureName).getRewardPkgs();
         var totalRewards:int = int(rewardPkgs.length);
         var percentValueOfRewards:int = Math.floor(countOfCollectedItems / totalRewards * 100);
         if(percentValueOfRewards > 100)
         {
            percentValueOfRewards = 100;
         }
         var barWidth:Number = percentValueOfRewards * this.PROGRESS_BAR_FULL_WIDTH / 100;
         if(m_window.hasOwnProperty("sfcounter_mc"))
         {
            this.m_meterMc = m_window.sfcounter_mc.meter_mc;
            if(this.m_meterMc.bar_fill_mc)
            {
               if(percentValue == 0)
               {
                  (this.m_meterMc.bar_fill_mc as MovieClip).width = barWidth;
               }
               else
               {
                  TweenMax.to(this.m_meterMc.bar_fill_mc,0.1,{"width":barWidth});
               }
            }
         }
         var itemCount:Number = BringBackWinterManager.getInstance(m_featureName).getNumberOfCollectedItems();
         if(Boolean(this.m_playerBadgeMc) && itemCount > 3)
         {
            this.m_playerBadgeMc.visible = true;
            if(itemCount >= 4 && itemCount < 10)
            {
               this.m_playerBadgeMc.gotoAndStop(1);
            }
            else if(itemCount >= 10 && itemCount < 18)
            {
               this.m_playerBadgeMc.gotoAndStop(2);
            }
            else if(itemCount >= 18)
            {
               this.m_playerBadgeMc.gotoAndStop(3);
            }
         }
         var bonusRewardPkg:Array = BringBackWinterManager.getInstance(m_featureName).getBonusRewardPkgs();
         if(this.m_meterMc.hasOwnProperty("reward_1_trigger_mc") && this.m_meterMc.hasOwnProperty("reward_1_mc"))
         {
            if(this.m_stageRewardOneIcon)
            {
               removeWidget(this.m_stageRewardOneIcon);
            }
            this.m_reward_1_mc = this.m_meterMc.reward_1_mc as MovieClip;
            this.m_reward_1_mc.visible = false;
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(bonusRewardPkg[0]["name"]);
            addWidget(this.m_stageRewardOneIcon = new FarmIcon(this.m_reward_1_mc.icon_1_mc),false);
            this.m_stageRewardOneIcon.visible = true;
            this.m_stageRewardOneIcon.loadIcon(this.m_item.getImageByName("icon",false));
            this.m_stageRewardOneIcon.setIconHeight(40);
            this.m_stageRewardOneIcon.setIconWidth(40);
            this.m_reward_1_mc.quantity_tf.text = "x1";
            this.m_meterMc.reward_1_trigger_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverStageOneCallback,false,0,true);
            this.m_meterMc.reward_1_trigger_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutStageOneCallback,false,0,true);
         }
         if(this.m_meterMc.hasOwnProperty("reward_2_trigger_mc") && this.m_meterMc.hasOwnProperty("reward_2_mc"))
         {
            if(this.m_stageRewardTwoIcon)
            {
               removeWidget(this.m_stageRewardTwoIcon);
            }
            this.m_reward_2_mc = this.m_meterMc.reward_2_mc;
            this.m_reward_2_mc.visible = false;
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(bonusRewardPkg[1]["name"]);
            addWidget(this.m_stageRewardTwoIcon = new FarmIcon(this.m_reward_2_mc.icon_2_mc),false);
            this.m_stageRewardTwoIcon.visible = true;
            this.m_stageRewardTwoIcon.loadIcon(this.m_item.getImageByName("icon",false));
            this.m_stageRewardTwoIcon.setIconHeight(40);
            this.m_stageRewardTwoIcon.setIconWidth(40);
            this.m_reward_2_mc.quantity_tf.text = "x1";
            this.m_meterMc.reward_2_trigger_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverStageTowCallback,false,0,true);
            this.m_meterMc.reward_2_trigger_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutStageTwoCallback,false,0,true);
         }
         if(this.m_meterMc.hasOwnProperty("reward_3_trigger_mc") && this.m_meterMc.hasOwnProperty("reward_3_mc"))
         {
            if(this.m_stageRewardThreeIcon)
            {
               removeWidget(this.m_stageRewardThreeIcon);
            }
            this.m_reward_3_mc = this.m_meterMc.reward_3_mc;
            this.m_reward_3_mc.visible = false;
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(bonusRewardPkg[2]["name"]);
            addWidget(this.m_stageRewardThreeIcon = new FarmIcon(this.m_reward_3_mc.icon_3_mc),false);
            this.m_stageRewardThreeIcon.visible = true;
            this.m_stageRewardThreeIcon.loadIcon(this.m_item.getImageByName("icon",false));
            this.m_stageRewardThreeIcon.setIconHeight(40);
            this.m_stageRewardThreeIcon.setIconWidth(40);
            this.m_reward_3_mc.quantity_tf.text = "x2";
            this.m_meterMc.reward_3_trigger_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverStageThreeCallback,false,0,true);
            this.m_meterMc.reward_3_trigger_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutStageThreeCallback,false,0,true);
         }
         var badgeText:String = null;
         var qty:int = 0;
         var name:String = null;
         if(this.m_meterMc.hasOwnProperty("badge_1_mc"))
         {
            qty = int(bonusRewardPkg[0]["quantity"]);
            this.m_badge_1_mc = this.m_meterMc.badge_1_mc;
            stage = int(bonusRewardPkg[0]["stage"]);
            if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardSatgeCompleted(stage))
            {
               this.m_badge_1_mc.gotoAndStop(3);
            }
            else if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage))
            {
               this.m_badge_1_mc.gotoAndStop(2);
               this.m_badge_1_mc.badgeMessage_1_tf.text = qty;
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_1_mc.badgeMessage_2_tf.text = badgeText;
            }
            else
            {
               this.m_badge_1_mc.gotoAndStop(1);
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_1_mc.badgeMessage_0_tf.text = badgeText;
            }
         }
         if(this.m_meterMc.hasOwnProperty("badge_2_mc"))
         {
            qty = int(bonusRewardPkg[1]["quantity"]);
            this.m_badge_2_mc = this.m_meterMc.badge_2_mc;
            stage = int(bonusRewardPkg[1]["stage"]);
            if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardSatgeCompleted(stage))
            {
               this.m_badge_2_mc.gotoAndStop(3);
            }
            else if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage))
            {
               this.m_badge_2_mc.gotoAndStop(2);
               this.m_badge_2_mc.badgeMessage_1_tf.text = qty;
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_2_mc.badgeMessage_2_tf.text = badgeText;
            }
            else
            {
               this.m_badge_2_mc.gotoAndStop(1);
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_2_mc.badgeMessage_0_tf.text = badgeText;
               this.m_badge_2_mc.badgeMessage_1_tf.text = qty;
            }
         }
         if(this.m_meterMc.hasOwnProperty("badge_3_mc"))
         {
            qty = int(bonusRewardPkg[2]["quantity"]);
            this.m_badge_3_mc = this.m_meterMc.badge_3_mc;
            stage = int(bonusRewardPkg[2]["stage"]);
            if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardSatgeCompleted(stage))
            {
               this.m_badge_3_mc.gotoAndStop(3);
            }
            else if(BringBackWinterManager.getInstance(m_featureName).isbonusRewardActive(stage))
            {
               this.m_badge_3_mc.gotoAndStop(2);
               this.m_badge_3_mc.badgeMessage_1_tf.text = qty;
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_3_mc.badgeMessage_2_tf.text = badgeText;
            }
            else
            {
               this.m_badge_3_mc.gotoAndStop(1);
               this.m_badge_3_mc.badgeMessage_1_tf.text = qty;
               badgeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_qty_for_badge",{"qty":qty});
               this.m_badge_3_mc.badgeMessage_0_tf.text = badgeText;
            }
         }
         if(this.m_meterMc.hasOwnProperty("rewads_collected_mc") && !BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems())
         {
            this.m_num_rewards_collected_mc = this.m_meterMc.rewads_collected_mc;
            if(this.m_num_rewards_collected_mc.hasOwnProperty("rewads_collected_tf"))
            {
               this.m_num_rewards_collected_mc.rewads_collected_tf.text = countOfCollectedItems;
               this.m_num_rewards_collected_mc.x = this.BAR_INITIAL_POSTION + barWidth;
            }
         }
         else if(this.m_meterMc.hasOwnProperty("rewads_collected_mc"))
         {
            this.m_num_rewards_collected_mc = this.m_meterMc.rewads_collected_mc;
            this.m_num_rewards_collected_mc.visible = false;
         }
         if(this.m_meterMc.hasOwnProperty("rewads_total_mc"))
         {
            this.m_rewads_total_mc = this.m_meterMc.rewads_total_mc;
            if(this.m_rewads_total_mc.hasOwnProperty("rewads_total_tf"))
            {
               this.m_rewads_total_mc.rewads_total_tf.text = BringBackWinterManager.getInstance(m_featureName).totalNumOfItems();
            }
         }
         if(this.m_friend_list)
         {
            this.onGettingFriendsInfoAboutCompletion(this.m_friend_list);
         }
         this.updatesInRedeemPeriod();
      }
      
      private function onMouseOverStageOneCallback(event:MouseEvent) : void
      {
         this.m_reward_1_mc.visible = true;
      }
      
      private function onMouseOutStageOneCallback(event:MouseEvent) : void
      {
         this.m_reward_1_mc.visible = false;
      }
      
      private function onMouseOverStageTowCallback(event:MouseEvent) : void
      {
         this.m_reward_2_mc.visible = true;
      }
      
      private function onMouseOutStageTwoCallback(event:MouseEvent) : void
      {
         this.m_reward_2_mc.visible = false;
      }
      
      private function onMouseOverStageThreeCallback(event:MouseEvent) : void
      {
         this.m_reward_3_mc.visible = true;
      }
      
      private function onMouseOutStageThreeCallback(event:MouseEvent) : void
      {
         this.m_reward_3_mc.visible = false;
      }
      
      override protected function updateSfCollection() : void
      {
         var i:int = 0;
         var collectionSlot:BringBackEasterCollectionSlot = null;
         var count:int = 0;
         var isPegacornFreed:Boolean = false;
         var counterText:String = null;
         if(m_collectionSlots)
         {
            for(i = 0; i < m_collectionSlots.length; i++)
            {
               if(m_collectionSlots[i])
               {
                  collectionSlot = m_collectionSlots[i] as BringBackEasterCollectionSlot;
                  collectionSlot.refreshCollectionCount();
               }
            }
         }
         if(this.subtitle2_tf)
         {
            count = BringBackWinterManager.getInstance(m_featureName).numCollectedItem();
            isPegacornFreed = BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems();
            counterText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle2",{"count":count});
            this.subtitle2_tf.text = counterText;
            this.subtitle2_tf.visible = !isPegacornFreed;
         }
      }
      
      private function updatesInRedeemPeriod() : void
      {
         if(BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
         {
            this.m_meterMc.reward_1_trigger_mc.visible = false;
            this.m_meterMc.reward_2_trigger_mc.visible = false;
            this.m_meterMc.reward_3_trigger_mc.visible = false;
            this.m_reward_1_mc.visible = false;
            this.m_reward_2_mc.visible = false;
            this.m_reward_3_mc.visible = false;
            this.m_badge_1_mc.gotoAndStop(1);
            this.m_badge_1_mc.badgeMessage_1_tf.visible = false;
            this.m_badge_1_mc.badgeMessage_0_tf.visible = false;
            this.m_badge_2_mc.gotoAndStop(1);
            this.m_badge_2_mc.badgeMessage_1_tf.visible = false;
            this.m_badge_2_mc.badgeMessage_0_tf.visible = false;
            this.m_badge_3_mc.gotoAndStop(1);
            this.m_badge_3_mc.badgeMessage_1_tf.visible = false;
            this.m_badge_3_mc.badgeMessage_0_tf.visible = false;
         }
      }
      
      override public function update() : void
      {
         var count:int = 0;
         var m_bonusMC1tooltip:FarmIcon = null;
         var m_bonusMC2tooltip:FarmIcon = null;
         super.update();
         this.updateText();
         var bonusNo:int = this.manager.hasBonusBeenGranted();
         var isPegacornFreed:Boolean = BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems();
         if(this.m_freeMc)
         {
            this.m_freeMc.visible = isPegacornFreed;
         }
         if(this.m_chainedMc)
         {
            this.m_chainedMc.visible = !isPegacornFreed;
         }
         if(this.m_witchMc)
         {
            this.m_witchMc.visible = !isPegacornFreed;
         }
         if(this.m_rescueMc)
         {
            count = BringBackWinterManager.getInstance(m_featureName).numCollectedItem();
            this.m_rescueMc.visible = true;
            if(isPegacornFreed)
            {
               count += 1;
            }
            this.m_rescueMc.gotoAndStop(count);
         }
         if(this.m_sadTeamMc)
         {
            this.m_sadTeamMc.visible = !isPegacornFreed;
         }
         if(this.m_happyAnimalMc)
         {
            this.m_happyAnimalMc.visible = isPegacornFreed;
         }
         if(this.m_happyTeamMc)
         {
            this.m_happyTeamMc.visible = isPegacornFreed;
         }
         if(this.manager.hasBonusBeenGranted())
         {
            this.m_bonusRewardDetailButton.visible = false;
         }
         if(this.subtitle3_tf)
         {
            this.subtitle3_tf.visible = !isPegacornFreed;
         }
         if(bonusNo == 3)
         {
            this.m_BonusMc.gotoAndStop(2);
         }
         else if(bonusNo == 2)
         {
            this.m_BonusMc.gotoAndStop(3);
            m_bonusMC1tooltip = new FarmIcon(this.m_BonusMc);
            m_bonusMC1tooltip.attachTooltip(new FarmTextTooltip("Yule Pegasus"));
         }
         else if(bonusNo == 1)
         {
            this.m_BonusMc.gotoAndStop(2);
            m_bonusMC2tooltip = new FarmIcon(this.m_BonusMc);
            m_bonusMC2tooltip.attachTooltip(new FarmTextTooltip("Xmas Yearling Unicorn"));
         }
      }
      
      private function updateText() : void
      {
         if(BringBackWinterManager.getInstance(m_featureName).isFeatureEnd())
         {
            new ZwTextField(m_window.title_tf,"Redeem one, Redeem all");
            if(BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems())
            {
               this.subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle1_expired_2");
            }
            else
            {
               this.subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle1_expired_1");
            }
         }
         else if(BringBackWinterManager.getInstance(m_featureName).hasCollectedAllItems())
         {
            this.subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle1_active_2");
         }
         else
         {
            this.subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_windowName + "_sfCounterSubtitle1_active_1");
         }
      }
   }
}

