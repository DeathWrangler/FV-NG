package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Managers.BoatRushManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BoatRushMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_TRACKING:String = "landbundle";
      
      private static const FEATURE_NAME:String = "BoatRush2020";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN:String = "land_bundle_unlock_feature_ftue_seen";
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var LAST_MILESTONE:int = 13;
      
      private var PROGRESS_BAR_FULL_LENGTH:Number = 450;
      
      private const BOATRUSH2020_MIANWINDOW_FTUE_PART1_FLAG:String = "boatrush2020_mainwindow_ftue_part1_flag";
      
      private const BOATRUSH2020_MIANWINDOW_FTUE_PART2_FLAG:String = "boatrush2020_mainwindow_ftue_part2_flag";
      
      private var m_milestonesArray:Array = [];
      
      private var m_locksArray:Array = [];
      
      private var m_hitAreasArray:Array = [];
      
      private var m_checkMarksArray:Array = [];
      
      private var m_daysLeftMC:MovieClip;
      
      private var m_congrats_coupon_mc:MovieClip;
      
      private var m_unlock_coupon_tile_tf:ZwTextField;
      
      private var m_unlock_coupon_count_tf:ZwTextField;
      
      private var m_unlock_thanks_bt:FarmAnimatedTextButton;
      
      private var m_consumable_craft_mc:MovieClip;
      
      private var m_gift_collect_mc:MovieClip;
      
      private var m_gift_collect_bt:FarmAnimatedTextButton;
      
      private var m_gift_know_bt:FarmAnimatedTextButton;
      
      private var m_gift_timer_tf:ZwTextField;
      
      private var m_gift_count_tf:ZwTextField;
      
      private var m_multiplier_tf:ZwTextField;
      
      private var m_move_mc:MovieClip;
      
      private var m_unblock_mc:MovieClip;
      
      private var m_okay_move_bt:FarmAnimatedTextButton;
      
      private var m_unblock_bt:FarmAnimatedTextButton;
      
      private var m_craft_bt:FarmAnimatedTextButton;
      
      private var m_consumable_count_tf:ZwTextField;
      
      private var m_sledge_progress_mc:MovieClip;
      
      private var m_progress_tf:ZwTextField;
      
      private var m_featureTimeMc:MovieClip;
      
      private var m_weekDaysTf:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_unblockTimer:Timer;
      
      private var m_unblock_timer_mc:MovieClip;
      
      private var m_unblock_timer_tf:ZwTextField;
      
      private var m_collectTimerTf:ZwTextField;
      
      private var m_sledIcon_mc:MovieClip;
      
      private var m_npc_icon:FarmIcon;
      
      private var m_success_overlay_mc:MovieClip;
      
      private var m_npc_move_mc:MovieClip;
      
      private var m_npc_unblock_mc:MovieClip;
      
      private var m_collectReadyTf:ZwTextField;
      
      private var m_overlay_title_tf:ZwTextField;
      
      private var m_overlay_fixed_tf:ZwTextField;
      
      private var m_overlay_reward_mc:FarmIcon;
      
      private var m_overlay_img_mc:FarmIcon;
      
      private var m_overlay_reward_tf:ZwTextField;
      
      private var m_endflow_overlay_mc:MovieClip;
      
      private var m_end_overlay_title_tf:ZwTextField;
      
      private var m_buildinng_reward_tf:ZwTextField;
      
      private var m_building_img_mc:FarmIcon;
      
      private var m_lock_overlay_mc:MovieClip;
      
      private var m_overlay_subtitle_tf:ZwTextField;
      
      private var m_ski_counter_tf:ZwTextField;
      
      private var m_gift_counter_tf:ZwTextField;
      
      private var m_dialog_move_tf:ZwTextField;
      
      private var m_dialog_unblock_tf:ZwTextField;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_tutorialMc:MovieClip;
      
      private var m_tutorialPart2Mc:MovieClip;
      
      private var m_tutorialButtonsPart2:Array = [];
      
      private var m_dialog_thumbsup_mc:MovieClip;
      
      private var m_thumbsup_dialog_tf:ZwTextField;
      
      private var m_help_mc:MovieClip;
      
      private var m_okay_dismiss_bt:FarmAnimatedTextButton;
      
      public function BoatRushMainWindow(featureName:String = "BoatRush2020", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      private static function get manager() : BoatRushManager
      {
         return BoatRushManager.getInstance(FEATURE_NAME);
      }
      
      public static function getFeatureExpiryTimeOnWall() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("09/28/2020") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var sled_icon:MovieClip = null;
         var milestoneName:String = null;
         var lockName:String = null;
         var hitAreaName:String = null;
         var checkMarkName:String = null;
         var milestoneLevel:int = 0;
         var rewards_mc:MovieClip = null;
         var multiplier_mc:MovieClip = null;
         var i:int = 0;
         var buttonName:String = null;
         var indexTemp:int = 0;
         var j:int = 0;
         var buttonNamePart2:String = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Build It Up"));
         }
         if(m_window.hasOwnProperty("cons_craft_mc"))
         {
            this.m_consumable_craft_mc = m_window["cons_craft_mc"] as MovieClip;
            if(this.m_consumable_craft_mc.hasOwnProperty("cons_count_tf"))
            {
               addWidget(this.m_consumable_count_tf = new ZwTextField(this.m_consumable_craft_mc["cons_count_tf"],"x" + manager.getConsumableCount().toString()));
            }
            if(this.m_consumable_craft_mc.hasOwnProperty("plant_bt"))
            {
               addWidget(this.m_craft_bt = new FarmAnimatedTextButton(this.m_consumable_craft_mc["plant_bt"],"Craft",this.onCraftButtonClick));
            }
            this.m_consumable_craft_mc.visible = true;
         }
         if(m_window.hasOwnProperty("dialog_thumbsup_mc"))
         {
            this.m_dialog_thumbsup_mc = m_window["dialog_thumbsup_mc"] as MovieClip;
            if(this.m_dialog_thumbsup_mc.hasOwnProperty("thumbsup_dialog_tf"))
            {
               addWidget(this.m_thumbsup_dialog_tf = new ZwTextField(this.m_dialog_thumbsup_mc["thumbsup_dialog_tf"],"Yay! We have reached our destination. Now let\'s collect as many Crates as possible to build our villa!!"));
               this.m_thumbsup_dialog_tf.visible = true;
            }
            this.m_dialog_thumbsup_mc.visible = false;
         }
         if(m_window.hasOwnProperty("help_mc"))
         {
            this.m_help_mc = m_window["help_mc"] as MovieClip;
            if(this.m_help_mc.hasOwnProperty("okay_dismiss_bt"))
            {
               addWidget(this.m_okay_dismiss_bt = new FarmAnimatedTextButton(this.m_help_mc["okay_dismiss_bt"],"Got it!",this.onFTUEPart2));
            }
            if(this.m_help_mc.hasOwnProperty("help_close_bt"))
            {
               addWidget(new FarmButton(this.m_help_mc.help_close_bt,this.closeFtue));
            }
            this.m_help_mc.visible = false;
         }
         if(m_window.hasOwnProperty("move_mc"))
         {
            this.m_move_mc = m_window["move_mc"] as MovieClip;
            if(this.m_move_mc.hasOwnProperty("okay_move_bt"))
            {
               addWidget(this.m_okay_move_bt = new FarmAnimatedTextButton(this.m_move_mc["okay_move_bt"],"Move",this.onMoveButtonClick));
            }
            if(this.m_move_mc.hasOwnProperty("ski_counter_tf"))
            {
               addWidget(this.m_ski_counter_tf = new ZwTextField(this.m_move_mc["ski_counter_tf"],"x" + manager.getSkiCounter().toString()));
            }
            this.m_move_mc.visible = true;
         }
         if(m_window.hasOwnProperty("unblock_mc"))
         {
            this.m_unblock_mc = m_window["unblock_mc"] as MovieClip;
            if(this.m_unblock_mc.hasOwnProperty("okay_unblock_bt"))
            {
               addWidget(this.m_unblock_bt = new FarmAnimatedTextButton(this.m_unblock_mc["okay_unblock_bt"],"Unblock Now",this.onUnblockButtonClick));
            }
            if(this.m_unblock_mc.hasOwnProperty("unblock_timer_mc"))
            {
               this.m_unblock_timer_mc = this.m_unblock_mc["unblock_timer_mc"] as MovieClip;
               if(this.m_unblock_timer_mc.hasOwnProperty("unblock_timer_tf"))
               {
                  addWidget(this.m_unblock_timer_tf = new ZwTextField(this.m_unblock_timer_mc["unblock_timer_tf"]));
               }
               this.m_unblock_timer_mc.visible = false;
            }
            if(this.m_unblock_mc.hasOwnProperty("gift_counter_tf"))
            {
               addWidget(this.m_gift_counter_tf = new ZwTextField(this.m_unblock_mc["gift_counter_tf"],"x" + manager.getGiftCounter().toString()));
            }
            this.m_unblock_mc.visible = true;
         }
         if(m_window.hasOwnProperty("npc_img_mc"))
         {
            this.m_npc_icon = new FarmIcon(m_window["npc_img_mc"]);
            this.m_npc_icon.visible = true;
         }
         if(m_window.hasOwnProperty("dialog_move_mc"))
         {
            this.m_npc_move_mc = m_window["dialog_move_mc"] as MovieClip;
            if(this.m_npc_move_mc.hasOwnProperty("move_dialog_tf"))
            {
               addWidget(this.m_dialog_move_tf = new ZwTextField(this.m_npc_move_mc["move_dialog_tf"],""));
            }
            this.m_npc_move_mc.visible = true;
         }
         if(m_window.hasOwnProperty("dialog_unblock_mc"))
         {
            this.m_npc_unblock_mc = m_window["dialog_unblock_mc"] as MovieClip;
            if(this.m_npc_unblock_mc.hasOwnProperty("unblock_dialog_tf"))
            {
               addWidget(this.m_dialog_unblock_tf = new ZwTextField(this.m_npc_unblock_mc["unblock_dialog_tf"],""));
            }
            this.m_npc_unblock_mc.visible = true;
         }
         this.updateMoveAndUnblockButton();
         if(m_window.hasOwnProperty("success_overlay_mc"))
         {
            this.m_success_overlay_mc = m_window["success_overlay_mc"] as MovieClip;
            this.m_success_overlay_mc.visible = false;
            if(this.m_success_overlay_mc.hasOwnProperty("overlay_title_tf"))
            {
               addWidget(this.m_overlay_title_tf = new ZwTextField(this.m_success_overlay_mc["overlay_title_tf"]));
            }
            if(this.m_success_overlay_mc.hasOwnProperty("fixed_tf"))
            {
               addWidget(this.m_overlay_fixed_tf = new ZwTextField(this.m_success_overlay_mc["fixed_tf"]));
            }
            if(this.m_success_overlay_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_success_overlay_mc["okay_bt"],"Awesome!",this.onOverlayButtonClick));
            }
            if(this.m_success_overlay_mc.hasOwnProperty("consumable_name_tf"))
            {
               addWidget(this.m_overlay_reward_tf = new ZwTextField(this.m_success_overlay_mc["consumable_name_tf"]));
            }
            if(this.m_success_overlay_mc.hasOwnProperty("overlay_img_mc"))
            {
               this.m_overlay_img_mc = new FarmIcon(this.m_success_overlay_mc["overlay_img_mc"]);
            }
            if(this.m_success_overlay_mc.hasOwnProperty("consumable_icon_mc"))
            {
               this.m_overlay_reward_mc = new FarmIcon(this.m_success_overlay_mc["consumable_icon_mc"]);
            }
            if(this.m_success_overlay_mc.hasOwnProperty("lock_overlay_mc"))
            {
               this.m_lock_overlay_mc = this.m_success_overlay_mc["lock_overlay_mc"] as MovieClip;
            }
            if(this.m_success_overlay_mc.hasOwnProperty("overlay_subtitle_tf"))
            {
               addWidget(this.m_overlay_subtitle_tf = new ZwTextField(this.m_success_overlay_mc["overlay_subtitle_tf"]));
            }
         }
         if(m_window.hasOwnProperty("endflow_overlay_mc"))
         {
            this.m_endflow_overlay_mc = m_window["endflow_overlay_mc"] as MovieClip;
            this.m_endflow_overlay_mc.visible = false;
            if(this.m_endflow_overlay_mc.hasOwnProperty("end_overlay_title_tf"))
            {
               addWidget(this.m_end_overlay_title_tf = new ZwTextField(this.m_endflow_overlay_mc["end_overlay_title_tf"],"FEATURE END!"));
            }
            if(this.m_endflow_overlay_mc.hasOwnProperty("end_okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_endflow_overlay_mc["end_okay_bt"],"Awesome!",this.onFeatureEndOverlayButtonClick));
            }
            if(this.m_endflow_overlay_mc.hasOwnProperty("buildinng_name_tf"))
            {
               addWidget(this.m_buildinng_reward_tf = new ZwTextField(this.m_endflow_overlay_mc["buildinng_name_tf"]));
            }
            if(this.m_endflow_overlay_mc.hasOwnProperty("building_icon_mc"))
            {
               this.m_building_img_mc = new FarmIcon(this.m_endflow_overlay_mc["building_icon_mc"]);
            }
         }
         if(m_window.hasOwnProperty("sled_progress_mc"))
         {
            this.m_sledge_progress_mc = m_window["sled_progress_mc"] as MovieClip;
            if(this.m_sledge_progress_mc.hasOwnProperty("progress_tf"))
            {
               addWidget(this.m_progress_tf = new ZwTextField(this.m_sledge_progress_mc["progress_tf"],"Completed: " + manager.getCurrentMilestoneLevel() + "/14"));
            }
            if(this.m_sledge_progress_mc.hasOwnProperty("sled_icon_mc"))
            {
               this.m_sledIcon_mc = this.m_sledge_progress_mc["sled_icon_mc"] as MovieClip;
               if(this.m_sledIcon_mc.hasOwnProperty("s_icon_mc"))
               {
                  sled_icon = this.m_sledIcon_mc["s_icon_mc"] as MovieClip;
               }
               this.m_sledIcon_mc.visible = true;
            }
            for(index = 0; index < this.LAST_MILESTONE; index++)
            {
               milestoneName = "m_reward_" + index.toString() + "_mc";
               lockName = "lock" + index.toString() + "_mc";
               hitAreaName = "hitarea_mstone" + index.toString() + "_mc";
               checkMarkName = "checkmark_" + index.toString() + "_mc";
               if(this.m_sledge_progress_mc.hasOwnProperty(milestoneName))
               {
                  this.m_milestonesArray[index] = this.m_sledge_progress_mc[milestoneName] as MovieClip;
                  this.m_milestonesArray[index].visible = manager.getCurrentMilestoneLevel() == index ? true : false;
               }
               if(this.m_sledge_progress_mc.hasOwnProperty(lockName))
               {
                  this.m_locksArray[index] = this.m_sledge_progress_mc[lockName] as MovieClip;
                  this.m_locksArray[index].visible = manager.isLevelLocked(index + 1) ? true : false;
               }
               if(this.m_sledge_progress_mc.hasOwnProperty(checkMarkName))
               {
                  this.m_checkMarksArray[index] = this.m_sledge_progress_mc[checkMarkName] as MovieClip;
                  milestoneLevel = manager.getCurrentMilestoneLevel();
                  if(milestoneLevel == 0)
                  {
                     this.m_checkMarksArray[index].visible = milestoneLevel > index;
                  }
                  else
                  {
                     this.m_checkMarksArray[index].visible = milestoneLevel - 1 > index;
                  }
               }
               if(this.m_sledge_progress_mc.hasOwnProperty(hitAreaName))
               {
                  this.m_hitAreasArray[index] = this.m_sledge_progress_mc[hitAreaName] as MovieClip;
                  this.m_hitAreasArray[index].visible = true;
                  this.m_hitAreasArray[index].addEventListener(MouseEvent.MOUSE_OVER,this.onOver(index));
                  this.m_hitAreasArray[index].addEventListener(MouseEvent.MOUSE_OUT,this.onOut(index));
               }
            }
            this.m_sledge_progress_mc.visible = true;
         }
         this.updateSledgeProgress(true);
         if(m_window.hasOwnProperty("view_rewards_mc"))
         {
            rewards_mc = m_window["view_rewards_mc"] as MovieClip;
            if(rewards_mc.hasOwnProperty("view_bt"))
            {
               addWidget(new FarmAnimatedTextButton(rewards_mc["view_bt"],"View",this.openRewardsWindow));
            }
            rewards_mc.visible = true;
         }
         if(m_window.hasOwnProperty("gift_craft_mc"))
         {
            this.m_gift_collect_mc = m_window["gift_craft_mc"] as MovieClip;
            if(this.m_gift_collect_mc.hasOwnProperty("collect_bt"))
            {
               addWidget(this.m_gift_collect_bt = new FarmAnimatedTextButton(this.m_gift_collect_mc["collect_bt"],"Collect",this.onGiftCollect));
               this.m_gift_collect_bt.visible = true;
               this.m_gift_collect_bt.enabled = manager.hasGiftTimerExpired();
            }
            if(this.m_gift_collect_mc.hasOwnProperty("collect_timer_mc"))
            {
               addWidget(this.m_collectReadyTf = new ZwTextField(this.m_gift_collect_mc["collect_timer_mc"]["collect_ready_tf"],""));
               this.m_collectReadyTf.visible = true;
            }
            if(this.m_gift_collect_mc.hasOwnProperty("collect_timer_mc"))
            {
               addWidget(this.m_collectTimerTf = new ZwTextField(this.m_gift_collect_mc["collect_timer_mc"]["timer_tf"],""));
               this.m_collectTimerTf.visible = true;
            }
            if(this.m_gift_collect_mc.hasOwnProperty("gifts_count_tf"))
            {
               addWidget(this.m_gift_count_tf = new ZwTextField(this.m_gift_collect_mc["gifts_count_tf"],"x" + manager.getGiftsCount().toString()));
            }
            if(this.m_gift_collect_mc.hasOwnProperty("know_bt"))
            {
               addWidget(this.m_gift_know_bt = new FarmAnimatedTextButton(this.m_gift_collect_mc["know_bt"],"Crates Boost",this.openTilesWindow));
            }
            if(this.m_gift_collect_mc.hasOwnProperty("multiplier_info_mc"))
            {
               multiplier_mc = this.m_gift_collect_mc["multiplier_info_mc"] as MovieClip;
               if(multiplier_mc.hasOwnProperty("multiplier_count_tf"))
               {
                  addWidget(this.m_multiplier_tf = new ZwTextField(multiplier_mc["multiplier_count_tf"],manager.getGiftSpeed().toString()));
               }
               multiplier_mc.visible = true;
            }
            this.m_gift_collect_mc.visible = true;
         }
         if(m_window.hasOwnProperty("congrats_coupon_mc"))
         {
            this.m_congrats_coupon_mc = m_window["congrats_coupon_mc"] as MovieClip;
            if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_coupon_tile_tf"))
            {
               addWidget(this.m_unlock_coupon_tile_tf = new ZwTextField(this.m_congrats_coupon_mc["unlock_coupon_tile_tf"],"Coupon Unlock"));
            }
            if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_coupon_count_tf"))
            {
               addWidget(this.m_unlock_coupon_count_tf = new ZwTextField(this.m_congrats_coupon_mc["unlock_coupon_count_tf"],"100"));
            }
            if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_thanks_bt"))
            {
               addWidget(this.m_unlock_thanks_bt = new FarmAnimatedTextButton(this.m_congrats_coupon_mc["unlock_thanks_bt"],"Thanks",null));
            }
            this.m_congrats_coupon_mc.visible = false;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            m_tutorial = addWidget(new ZwFrame(this.m_tutorialMc),false) as ZwFrame;
            if(this.m_tutorialMc)
            {
               for(i = 0; i < 7; i++)
               {
                  buttonName = "okay" + i.toString() + "_bt";
                  if(this.m_tutorialMc.hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[i] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName]);
                     this.m_tutorialButtons[i].visible = false;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("tutorial_partii_mc"))
         {
            this.m_tutorialPart2Mc = m_window["tutorial_partii_mc"] as MovieClip;
            if(this.m_tutorialPart2Mc)
            {
               indexTemp = 0;
               for(j = 6; j < 10; j++)
               {
                  buttonNamePart2 = "okay" + j.toString() + "_bt";
                  if(this.m_tutorialPart2Mc.hasOwnProperty(buttonNamePart2))
                  {
                     this.m_tutorialButtonsPart2[indexTemp] = new FarmAnimatedTextButton(this.m_tutorialPart2Mc[buttonNamePart2]);
                     this.m_tutorialButtonsPart2[indexTemp].visible = false;
                     indexTemp++;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("feature_time_mc"))
         {
            this.m_featureTimeMc = m_window["feature_time_mc"] as MovieClip;
            if(this.m_featureTimeMc.hasOwnProperty("feature_count_mc"))
            {
               addWidget(this.m_weekDaysTf = new ZwTextField(this.m_featureTimeMc["feature_count_mc"]["week_days_tf"],this.getTimeLeft()));
               this.m_weekDaysTf.visible = true;
            }
            this.m_featureTimeMc.visible = true;
         }
         this.moveVisibility();
         this.startTimer();
         if(!manager.isLastMilestoneReached())
         {
            if(manager.isLevelLocked(manager.getCurrentMilestoneLevel()))
            {
               this.startUnblockTimer();
               this.showUnblockTimer();
            }
            if(!Global.player.getSeenFlag(this.BOATRUSH2020_MIANWINDOW_FTUE_PART1_FLAG))
            {
               Global.player.setSeenFlag(this.BOATRUSH2020_MIANWINDOW_FTUE_PART1_FLAG);
               this.showTutorial1();
            }
         }
         else
         {
            this.finalMilestoneReached();
         }
      }
      
      private function openRewardsWindow(e:Event = null) : void
      {
         tintWindow();
         UI.displayPopup(new BoatRushRewardWindow(FEATURE_NAME,"assets/dialogs/boat_rush_aug_2020/FV_boat_rewards.swf"),false);
      }
      
      private function openTilesWindow(e:Event) : void
      {
         manager.openTilesWindow();
      }
      
      private function onGiftCollect(e:Event) : void
      {
         this.m_gift_collect_bt.enabled = false;
         manager.onGiftCollect();
      }
      
      public function disableMoveButton() : void
      {
         if(this.m_okay_move_bt)
         {
            this.m_okay_move_bt.enabled = false;
         }
      }
      
      public function updateMoveAndUnblockButton() : void
      {
         var userState:int = manager.getCurrentMilestoneLevel();
         if(userState == 0)
         {
            this.onMoveActive();
            this.sledgeProgress();
         }
         else if(userState % 2 == 0 && userState != 0)
         {
            if(this.m_npc_icon)
            {
               if(manager.isLevelLocked(userState))
               {
                  this.onBlockActive();
                  this.m_npc_icon.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_blocked.jpg");
               }
               else
               {
                  this.onMoveActive();
                  this.sledgeProgress();
                  if(this.m_locksArray[userState - 1])
                  {
                     this.m_locksArray[userState - 1].visible = false;
                  }
               }
            }
         }
         else
         {
            this.onMoveActive();
            this.sledgeProgress();
         }
      }
      
      private function onMoveActive() : void
      {
         if(Boolean(this.m_okay_move_bt && this.m_unblock_bt && this.m_npc_move_mc) && Boolean(this.m_npc_unblock_mc) && Boolean(this.m_npc_icon))
         {
            this.m_unblock_bt.enabled = false;
            this.m_npc_unblock_mc.visible = false;
            if(manager.hasEnoughConsumablesToMove())
            {
               this.m_okay_move_bt.enabled = true;
               this.m_npc_move_mc.visible = true;
            }
            else
            {
               this.m_okay_move_bt.enabled = false;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_okay_move_bt,"Craft Required Fuel Barrels.");
            }
         }
      }
      
      private function onBlockActive() : void
      {
         if(Boolean(this.m_okay_move_bt && this.m_unblock_bt && this.m_npc_move_mc) && Boolean(this.m_npc_unblock_mc) && Boolean(this.m_npc_icon))
         {
            this.m_okay_move_bt.enabled = false;
            if(manager.hasEnoughGiftsToUnblock())
            {
               this.m_unblock_bt.enabled = true;
               this.m_npc_unblock_mc.visible = true;
               if(this.isUnblockTimerGreater())
               {
                  this.m_dialog_unblock_tf.text = "Hurry up! We are running out of time. Unblock now!";
               }
               else
               {
                  this.m_dialog_unblock_tf.text = "Rocks..too heavy..We can spare a few Crates to unblock our Tugboat.";
               }
               this.m_npc_move_mc.visible = false;
            }
            else
            {
               this.m_unblock_bt.enabled = false;
               this.m_npc_move_mc.visible = false;
               this.m_npc_unblock_mc.visible = true;
               this.m_dialog_unblock_tf.text = "We do not have enough Crates to spare. Collect faster!";
               FarmGameUtil.disableButtonAndShowTooltip(this.m_unblock_bt,"Collect more Crates.");
            }
         }
      }
      
      private function sledgeProgress() : void
      {
         if(manager.hasEnoughConsumablesToMove())
         {
            if(this.m_dialog_move_tf)
            {
               this.m_dialog_move_tf.text = "Use the required Fuel Barrels to move ahead. Let’s Hurry up.";
            }
            if(this.m_npc_icon)
            {
               this.m_npc_icon.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_ready.jpg");
            }
         }
         else
         {
            if(this.m_dialog_move_tf)
            {
               this.m_dialog_move_tf.text = "Let’s quickly craft a few Fuel Barrels to move ahead.";
            }
            if(this.m_npc_icon)
            {
               this.m_npc_icon.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_broke.jpg");
            }
         }
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(manager.hasGiftTimerExpired())
         {
            this.stopTimer();
            if(this.m_gift_collect_bt)
            {
               this.m_gift_collect_bt.enabled = true;
            }
            if(this.m_collectReadyTf)
            {
               this.m_collectReadyTf.text = "Ready to";
            }
            if(this.m_collectTimerTf)
            {
               this.m_collectTimerTf.text = "Collect";
            }
         }
         else
         {
            if(this.m_gift_collect_bt)
            {
               this.m_gift_collect_bt.enabled = false;
            }
            if(this.m_collectReadyTf)
            {
               this.m_collectReadyTf.text = "Collect in";
            }
            if(this.m_collectTimerTf)
            {
               this.m_collectTimerTf.text = HUD.getformattedTimeLeft(manager.getGiftTimeRemain());
            }
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      public function startUnblockTimer() : void
      {
         this.m_unblockTimer = new Timer(1000);
         this.m_unblockTimer.addEventListener(TimerEvent.TIMER,this.onUnblockTimer);
         this.m_unblockTimer.start();
      }
      
      private function onUnblockTimer(event:TimerEvent) : void
      {
         if(manager.hasUnblockTimerExpired())
         {
            this.stopUnblockTimer();
            this.hideUnblockTimer();
            manager.unblockOnTimeEnd(manager.getCurrentMilestoneLevel());
            this.refreshWindow();
            if(this.m_unblock_bt)
            {
               this.m_unblock_bt.enabled = false;
            }
         }
         else if(manager.isWinterRacing2019Active())
         {
            if(this.m_unblock_timer_tf)
            {
               this.m_unblock_timer_tf.text = HUD.getformattedTimeLeft(manager.getUnblockTimeRemaining());
            }
         }
         else
         {
            this.stopUnblockTimer();
            this.hideUnblockTimer();
            manager.featureEndFlow();
         }
      }
      
      public function stopUnblockTimer() : void
      {
         if(this.m_unblockTimer)
         {
            this.m_unblockTimer.stop();
            this.m_unblockTimer.removeEventListener(TimerEvent.TIMER,this.onUnblockTimer);
            this.m_unblockTimer = null;
         }
      }
      
      public function showUnblockTimer() : void
      {
         if(this.m_unblock_timer_mc)
         {
            this.m_unblock_timer_mc.visible = true;
         }
      }
      
      public function hideUnblockTimer() : void
      {
         if(this.m_unblock_timer_mc)
         {
            this.m_unblock_timer_mc.visible = false;
         }
      }
      
      private function refreshMilestoneRewards() : void
      {
         var milestoneName:String = null;
         for(var index:int = 0; index < this.LAST_MILESTONE; index++)
         {
            milestoneName = "m_reward_" + index.toString() + "_mc";
            if(this.m_sledge_progress_mc.hasOwnProperty(milestoneName))
            {
               this.m_milestonesArray[index] = this.m_sledge_progress_mc[milestoneName] as MovieClip;
               this.m_milestonesArray[index].visible = manager.getCurrentMilestoneLevel() == index ? true : false;
            }
         }
      }
      
      public function refreshGifts() : void
      {
         if(this.m_gift_count_tf)
         {
            this.m_gift_count_tf.text = "x" + manager.getGiftsCount().toString();
         }
         if(!this.m_gift_counter_tf)
         {
         }
         this.stopTimer();
         this.startTimer();
      }
      
      private function onCraftButtonClick(e:Event = null) : void
      {
         manager.craftConsumable();
      }
      
      private function onMoveButtonClick(e:Event = null) : void
      {
         if(this.m_okay_move_bt.enabled)
         {
            manager.sinkConsumable();
         }
      }
      
      private function onUnblockButtonClick(e:Event = null) : void
      {
         if(this.m_unblock_bt.enabled)
         {
            manager.sinkGifts();
         }
      }
      
      public function refreshProgress() : void
      {
         if(this.m_consumable_count_tf)
         {
            this.m_consumable_count_tf.text = "x" + manager.getConsumableCount().toString();
         }
         if(this.m_gift_count_tf)
         {
            this.m_gift_count_tf.text = "x" + manager.getGiftsCount().toString();
         }
         if(this.m_progress_tf)
         {
            this.m_progress_tf.text = "Completed: " + manager.getCurrentMilestoneLevel() + "/14";
         }
      }
      
      public function showSuccessOverlay(unblock:Boolean = false, rewardItem:FarmItem = null, rewardLocked:Boolean = false) : void
      {
         var milestoneLevel:int = 0;
         if(Boolean(this.m_success_overlay_mc) && Boolean(rewardItem))
         {
            if(this.m_overlay_title_tf)
            {
               if(unblock == true)
               {
                  this.m_overlay_title_tf.text = "Clean Water!";
               }
               else
               {
                  this.m_overlay_title_tf.text = "Ready to go!";
               }
            }
            milestoneLevel = manager.getCurrentMilestoneLevel();
            if(milestoneLevel >= 2)
            {
               this.m_checkMarksArray[milestoneLevel - 2].visible = true;
            }
            if(this.m_overlay_reward_mc)
            {
               this.m_overlay_reward_mc.loadIcon(rewardItem.iconUrl,null);
            }
            if(this.m_overlay_img_mc)
            {
               if(unblock == true)
               {
                  this.m_overlay_img_mc.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_success.jpg");
               }
               else
               {
                  this.m_overlay_img_mc.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_success.jpg");
               }
            }
            if(this.m_overlay_fixed_tf)
            {
               if(unblock == true)
               {
                  this.m_overlay_fixed_tf.text = "Thanks Farmer, we are one step closer to our destination!";
               }
               else
               {
                  this.m_overlay_fixed_tf.text = "Thanks Farmer, we are one step closer to our destination!";
               }
            }
            if(this.m_lock_overlay_mc)
            {
               if(rewardLocked == true)
               {
                  this.m_lock_overlay_mc.visible = true;
               }
               else
               {
                  this.m_lock_overlay_mc.visible = false;
               }
            }
            if(this.m_overlay_reward_tf)
            {
               if(rewardLocked == true)
               {
                  this.m_overlay_reward_tf.text = "Use your crates to unlock the " + rewardItem.friendlyTitle + "!";
               }
               else if(manager.getCurrentMilestoneLevel() % 2 == 0 || manager.isLastMilestoneReached())
               {
                  this.m_overlay_reward_tf.text = "You won a \n" + rewardItem.friendlyTitle;
               }
               else
               {
                  this.m_overlay_reward_tf.text = "You won 2 \n" + rewardItem.friendlyTitle;
               }
            }
            if(this.m_overlay_subtitle_tf)
            {
               if(rewardLocked == true)
               {
                  this.m_overlay_subtitle_tf.text = "Hurray!";
               }
               else
               {
                  this.m_overlay_subtitle_tf.text = "Congrats!";
               }
            }
            if(this.m_ski_counter_tf)
            {
               this.m_ski_counter_tf.text = "x" + manager.getSkiCounter().toString();
            }
            if(this.m_gift_counter_tf)
            {
               this.m_gift_counter_tf.text = "x" + manager.getGiftCounter().toString();
            }
            this.m_success_overlay_mc.visible = true;
         }
         if(Boolean(this.m_okay_move_bt) && manager.hasEnoughConsumablesToMove())
         {
            this.m_okay_move_bt.enabled = true;
         }
         else
         {
            this.m_okay_move_bt.enabled = false;
         }
         this.updateSledgeProgress();
      }
      
      private function onOverlayButtonClick(e:Event) : void
      {
         this.refreshWindow();
         if(this.m_success_overlay_mc)
         {
            this.m_success_overlay_mc.visible = false;
         }
         if(manager.getCurrentMilestoneLevel() == 2)
         {
            if(!Global.player.getSeenFlag(this.BOATRUSH2020_MIANWINDOW_FTUE_PART2_FLAG))
            {
               Global.player.setSeenFlag(this.BOATRUSH2020_MIANWINDOW_FTUE_PART2_FLAG);
               tutorialSceneNumber = 0;
               this.showTutorial2();
            }
         }
         if(manager.isLastMilestoneReached())
         {
            this.finalMilestoneReached();
         }
      }
      
      public function finalMilestoneReached() : void
      {
         if(this.m_unblock_mc)
         {
            this.m_unblock_mc.visible = false;
         }
         if(this.m_move_mc)
         {
            this.m_move_mc.visible = false;
         }
         if(Boolean(this.m_consumable_craft_mc) && Boolean(this.m_craft_bt))
         {
            this.m_craft_bt.enabled = false;
         }
         if(this.m_dialog_thumbsup_mc)
         {
            this.m_dialog_thumbsup_mc.visible = true;
         }
         if(this.m_npc_move_mc)
         {
            this.m_npc_move_mc.visible = false;
         }
         if(this.m_npc_unblock_mc)
         {
            this.m_npc_unblock_mc.visible = false;
         }
         if(this.m_npc_icon)
         {
            this.m_npc_icon.loadIcon("assets/dialogs/boat_rush_aug_2020/boat_ready.jpg");
         }
      }
      
      private function onFeatureEndOverlayButtonClick(e:Event) : void
      {
      }
      
      public function updateSledgeProgress(onOpenWindow:Boolean = false) : void
      {
         var progress:int = manager.getCurrentMilestoneLevel();
         if(progress > this.LAST_MILESTONE)
         {
            progress = this.LAST_MILESTONE;
         }
         var barLength:Number = progress * (this.PROGRESS_BAR_FULL_LENGTH / this.LAST_MILESTONE);
         if(this.m_sledIcon_mc)
         {
            this.m_sledIcon_mc.x = progress * 32.5 + 15;
         }
      }
      
      private function onOver(index:int) : Function
      {
         return function(evt:MouseEvent):*
         {
            if(manager.getCurrentMilestoneLevel() != index && m_milestonesArray.hasOwnProperty(index.toString()))
            {
               m_milestonesArray[index].visible = true;
            }
         };
      }
      
      private function onOut(index:int) : Function
      {
         return function(evt:MouseEvent):*
         {
            if(manager.getCurrentMilestoneLevel() != index && m_milestonesArray.hasOwnProperty(index.toString()))
            {
               m_milestonesArray[index].visible = false;
            }
         };
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_tutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_tutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_tutorial_frame.visible = false;
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_help_mc)
         {
            this.m_help_mc.visible = true;
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            this.hideTutorial();
         }
      }
      
      protected function showTutorial1() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            m_tutorial.visible = true;
            m_tutorial.element["arrow_mc"].visible = true;
            this.m_craft_bt.enabled = false;
            this.m_gift_collect_bt.enabled = false;
            this.m_gift_know_bt.enabled = false;
         }
         this.preSwitchChanges1(0);
      }
      
      protected function preSwitchChanges1(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         var button6:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "OK!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button1.text = "OK!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button2.text = "Move";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button3.text = "OK!";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button4.text = "OK!";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(3);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button5.text = "Collect";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(4);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
               break;
            case 6:
               button6 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button6.text = "OK!";
               button6.visible = true;
               button6.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(5);
               (m_tutorial.element as MovieClip).gotoAndStop(7);
         }
      }
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
         if(this.m_gift_collect_bt)
         {
            this.m_gift_collect_bt.enabled = false;
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < 6)
         {
            ++tutorialSceneNumber;
            if(tutorialSceneNumber == 3)
            {
               manager.sinkConsumableFTUEMove();
            }
            else if(tutorialSceneNumber == 6)
            {
               manager.onGiftCollectFTUE();
            }
            this.preSwitchChanges1(tutorialSceneNumber);
         }
         else
         {
            this.m_craft_bt.enabled = true;
            this.m_gift_collect_bt.enabled = manager.hasGiftTimerExpired();
            this.m_gift_know_bt.enabled = true;
            this.hideTutorial();
         }
      }
      
      override protected function hideTutorial() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = false;
            m_tutorial.visible = false;
         }
      }
      
      protected function showTutorial2() : void
      {
         m_tutorial = addWidget(new ZwFrame(this.m_tutorialPart2Mc),false) as ZwFrame;
         if(this.m_tutorialPart2Mc)
         {
            this.m_tutorialPart2Mc.visible = true;
            m_tutorial.visible = true;
            m_tutorial.element["arrow_mc"].visible = true;
            this.m_unblock_bt.enabled = false;
         }
         this.preSwitchChanges2(0);
      }
      
      protected function preSwitchChanges2(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtonsPart2[0] as FarmAnimatedTextButton;
               button0.text = "OK!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick2;
               this.hideOtherTutorialButtonsExpect2(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtonsPart2[1] as FarmAnimatedTextButton;
               button1.text = "OK!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick2;
               this.hideOtherTutorialButtonsExpect2(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtonsPart2[2] as FarmAnimatedTextButton;
               button2.text = "Unblock Now";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick2;
               this.hideOtherTutorialButtonsExpect2(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtonsPart2[3] as FarmAnimatedTextButton;
               button3.text = "SURE!";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick2;
               this.hideOtherTutorialButtonsExpect2(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
         }
      }
      
      private function hideOtherTutorialButtonsExpect2(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtonsPart2.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtonsPart2[i].visible = false;
            }
         }
      }
      
      protected function onTutorialOkayButtonClick2(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < 3)
         {
            ++tutorialSceneNumber;
            if(tutorialSceneNumber == 3)
            {
               manager.sinkGiftsFTUEUnblock();
            }
            this.preSwitchChanges2(tutorialSceneNumber);
         }
         else
         {
            this.m_unblock_bt.enabled = true;
            this.hideTutorial2();
         }
      }
      
      protected function hideTutorial2() : void
      {
         if(this.m_tutorialPart2Mc)
         {
            this.m_tutorialPart2Mc.visible = false;
            m_tutorial.visible = false;
         }
      }
      
      override public function refreshWindow() : void
      {
         this.updateMoveAndUnblockButton();
         this.refreshMilestoneRewards();
         this.refreshGifts();
         this.refreshProgress();
         this.moveVisibility();
         super.refreshWindow();
      }
      
      public function moveVisibility() : void
      {
         if(manager.getCurrentMilestoneLevel() % 2 != 0 || manager.getCurrentMilestoneLevel() == 0 || !manager.isLevelLocked(manager.getCurrentMilestoneLevel()))
         {
            this.m_move_mc.visible = true;
            this.m_unblock_mc.visible = false;
         }
         else
         {
            this.m_move_mc.visible = false;
            this.m_unblock_mc.visible = true;
         }
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = getFeatureExpiryTimeOnWall();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = timeRemaining[0].toString();
         }
         else
         {
            timeLeft = "1";
         }
         return timeLeft;
      }
      
      private function isUnblockTimerGreater() : Boolean
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("09/28/2020") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay;
         }
         return manager.getCurrentMilestoneUnblockTimer() > remainingTime[0];
      }
      
      private function onFTUEPart2(e:Event = null) : void
      {
         if(this.m_help_mc)
         {
            this.m_help_mc.visible = false;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.stopUnblockTimer();
         super.close();
         FarmStatsManager.count("LandBundleUnlockFeatureWindow","Main_UI","close_window");
      }
      
      private function closeFtue(e:Event = null) : void
      {
         if(this.m_help_mc)
         {
            this.m_help_mc.visible = false;
         }
      }
   }
}

