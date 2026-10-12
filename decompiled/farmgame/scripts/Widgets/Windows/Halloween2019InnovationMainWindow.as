package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Halloween2019InnovationCandyKidFrame;
   import Widgets.Frames.Halloween2019InnovationNormalCandyFrame;
   import Widgets.Frames.Halloween2019InnovationSpeciallCandyFrame;
   import Widgets.Frames.Halloween2019InnovationStationsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Halloween2019InnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static var m_tile_count:int;
      
      private static const FEATURE_NAME:String = "Halloween2019Innovation";
      
      private static const HOWDOESTHISWORK_MC:String = "howDoesThisWork_mc";
      
      private var m_featureName:String = null;
      
      private var m_progressMc:MovieClip;
      
      public var m_normalCandyFrame:Halloween2019InnovationNormalCandyFrame;
      
      public var m_specialCandyFrame:Halloween2019InnovationSpeciallCandyFrame;
      
      public var m_stationsFrame:Halloween2019InnovationStationsFrame;
      
      public var m_candyKidFrame:Halloween2019InnovationCandyKidFrame;
      
      private var m_getOderboardBt:FarmAnimatedTextButton;
      
      public var m_endFeatureBt:FarmAnimatedTextButton;
      
      private var m_get_special_bt:FarmAnimatedTextButton;
      
      private var m_progress_bt:FarmAnimatedTextButton;
      
      private var m_player_level_mc:MovieClip;
      
      private var m_progress_meter_mc:MovieClip;
      
      private var m_icon_daily_reward_mc:FarmIcon;
      
      private var m_meter_mc:MovieClip;
      
      private var m_check_point_mc:MovieClip;
      
      private var m_meter_fill_mc:MovieClip;
      
      private var m_earned_points_mc:MovieClip;
      
      private var m_points_tf:ZwTextField;
      
      private var m_min_points_tf:ZwTextField;
      
      private var m_max_points_tf:ZwTextField;
      
      private var m_mstoneCounttf:ZwTextField;
      
      private var m_progress_day_timer_tf:ZwTextField;
      
      private var m_progress_week_day_tf:ZwTextField;
      
      private var m_progress_week_kids_tf:ZwTextField;
      
      private var orderCountTf:ZwTextField;
      
      private const MAX_POINT:int = 100;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 300;
      
      private var m_level1Hover:ZwFrame;
      
      private var m_level2Hover:ZwFrame;
      
      private var m_level1HoverDetail:MovieClip;
      
      private var m_level2HoverDetail:MovieClip;
      
      private var m_newDayMc:MovieClip;
      
      private var m_newday_tf:ZwTextField;
      
      private var m_npcCircleyMc:MovieClip;
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_startDayBt:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_newWeekMc:MovieClip;
      
      private var m_npcCircleyWeekMc:MovieClip;
      
      private var m_startWeekBt:FarmAnimatedTextButton;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      private var m_arrowMc:MovieClip;
      
      private var m_npcCircleMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      public var m_npcCalloutMc:MovieClip;
      
      public var m_npcTitleTf:ZwTextField;
      
      public var m_npcTextTf:ZwTextField;
      
      public var m_npcClodeBt:FarmAnimatedTextButton;
      
      private var m_endFeatureMc:MovieClip;
      
      private var m_hitAreaInfoMc:MovieClip;
      
      private var m_areaInfoMc:MovieClip;
      
      private var m_hitProgressMc:MovieClip;
      
      private var m_hoverProgressMc:MovieClip;
      
      private var m_newWeekTwoMc:MovieClip;
      
      private var m_newWeekTwotf:ZwTextField;
      
      private var m_startWeekTwoBt:FarmAnimatedTextButton;
      
      private var NUM_TUTORIAL_SCENES:int = 7;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Next","Next","Next","Next","Let’s go!"];
      
      private const HALLOWEEN2019_MIANWINDOW_FTUE_FLAG:String = "halloween2019_mainwindow_ftue_flag";
      
      private const HALLOWEEN2019_PROGRESSWINDOW_FTUE_FLAG:String = "halloween2019_progresswindow_ftue_flag";
      
      private var m_tutorialButtons:Array = [];
      
      private var m_congrats_coupon_mc:MovieClip;
      
      private var m_unlock_coupon_tile_tf:ZwTextField;
      
      private var m_unlock_coupon_count_tf:ZwTextField;
      
      private var m_unlock_coupon_bt:FarmAnimatedTextButton;
      
      public function Halloween2019InnovationMainWindow(featureName:String = "Halloween2019Innovation", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(FEATURE_NAME,assetUrl,this.NUM_TUTORIAL_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var buttonName:String = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Spooks N\' Treats"));
         }
         if(!this.manager.showFeatureEndPopUp())
         {
            if(m_window.hasOwnProperty("subtext_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext_tf"],"Give kids their candies to earn points. Get more points by giving special candy!"));
            }
            if(m_window.hasOwnProperty("candy_station_tf"))
            {
               addWidget(new ZwTextField(m_window["candy_station_tf"],"Candy Station"));
            }
            if(m_window.hasOwnProperty(HOWDOESTHISWORK_MC))
            {
               addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[HOWDOESTHISWORK_MC],"",this.onHowDoesThisWorkClick));
               this.m_whatIsThisBt.visible = true;
            }
            if(m_window.hasOwnProperty("npc_callout_mc"))
            {
               this.m_npcCalloutMc = m_window["npc_callout_mc"] as MovieClip;
               if(this.m_npcCalloutMc.hasOwnProperty("callout_title_tf"))
               {
                  addWidget(this.m_npcTitleTf = new ZwTextField(this.m_npcCalloutMc["callout_title_tf"]));
                  this.m_npcTitleTf.visible = true;
               }
               if(this.m_npcCalloutMc.hasOwnProperty("callout_text_tf"))
               {
                  addWidget(this.m_npcTextTf = new ZwTextField(this.m_npcCalloutMc["callout_text_tf"]));
                  this.m_npcTextTf.visible = true;
               }
               if(this.m_npcCalloutMc.hasOwnProperty("okay_bt"))
               {
                  addWidget(this.m_npcClodeBt = new FarmAnimatedTextButton(this.m_npcCalloutMc["okay_bt"],"Ok",this.onNpcClose));
                  this.m_npcClodeBt.visible = true;
               }
               this.m_npcCalloutMc.visible = false;
            }
            if(m_window.hasOwnProperty("tutorial_mc"))
            {
               this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
               m_tutorial = addWidget(new ZwFrame(this.m_tutorialMc),false) as ZwFrame;
               if(this.m_tutorialMc)
               {
                  for(i = 0; i < 7; i++)
                  {
                     buttonName = "okay_" + (i + 1).toString() + "_bt";
                     if(this.m_tutorialMc.hasOwnProperty(buttonName))
                     {
                        this.m_tutorialButtons[i] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName]);
                        this.m_tutorialButtons[i].visible = false;
                     }
                  }
               }
            }
            if(m_window.hasOwnProperty("mini_tutorial_mc"))
            {
               this.m_mini_tutorial_mc = m_window["mini_tutorial_mc"] as MovieClip;
               this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
               if(this.m_mini_tutorial_mc.hasOwnProperty("okay_bt"))
               {
                  this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_mini_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
                  this.m_mini_tutorial_mc["okay_bt"].visible = true;
               }
               this.m_mini_tutorial_mc.visible = false;
            }
            if(m_window.hasOwnProperty("all_candy_normal_mc"))
            {
               this.m_normalCandyFrame = new Halloween2019InnovationNormalCandyFrame(m_window["all_candy_normal_mc"],this,this.m_featureName);
               this.m_normalCandyFrame.visible = true;
               if(m_window.all_candy_normal_mc.get_normal_bt)
               {
                  this.m_getOderboardBt = new FarmAnimatedTextButton(m_window.all_candy_normal_mc["get_normal_bt"],"Get",this.onClickOrderboardOpenBt);
                  this.m_getOderboardBt.visible = true;
               }
               this.setOderboardText();
               if(m_window.all_candy_normal_mc.order_count_tf)
               {
                  addWidget(this.orderCountTf = new ZwTextField(m_window.all_candy_normal_mc["order_count_tf"],(this.manager.getMaxDailyOderboardCount() - this.manager.getDailyOderboardTaskCount()).toString()));
                  this.orderCountTf.visible = true;
               }
            }
            if(m_window.hasOwnProperty("all_candy_special_mc"))
            {
               this.m_specialCandyFrame = new Halloween2019InnovationSpeciallCandyFrame(m_window["all_candy_special_mc"],this,this.m_featureName);
               this.m_specialCandyFrame.visible = true;
            }
            if(m_window.hasOwnProperty("all_candy_kid_mc"))
            {
               this.m_candyKidFrame = new Halloween2019InnovationCandyKidFrame(m_window["all_candy_kid_mc"],this,this.m_featureName);
               this.m_candyKidFrame.visible = true;
            }
            if(m_window.hasOwnProperty("all_special_candy_station_mc"))
            {
               this.m_stationsFrame = new Halloween2019InnovationStationsFrame(m_window["all_special_candy_station_mc"],this,this.m_featureName);
               this.m_stationsFrame.visible = true;
            }
            if(m_window.hasOwnProperty("all_progress_mc"))
            {
               this.m_progressMc = m_window.all_progress_mc as MovieClip;
               this.m_progressMc.visible = true;
               if(this.m_progressMc.hasOwnProperty("hitarea_info_mc"))
               {
                  this.m_hitAreaInfoMc = this.m_progressMc["hitarea_info_mc"] as MovieClip;
                  this.m_hitAreaInfoMc.visible = true;
                  this.m_hitAreaInfoMc.addEventListener(MouseEvent.MOUSE_OVER,this.onAreaInfoHover);
                  this.m_hitAreaInfoMc.addEventListener(MouseEvent.MOUSE_OUT,this.onAreaInfoOut);
               }
               if(this.m_progressMc.hasOwnProperty("hover_info_mc"))
               {
                  this.m_areaInfoMc = this.m_progressMc["hover_info_mc"] as MovieClip;
                  this.m_areaInfoMc.visible = false;
               }
               if(this.m_progressMc.hasOwnProperty("player_level_mc"))
               {
               }
               if(this.m_progressMc.hasOwnProperty("player_level_mc"))
               {
                  this.m_player_level_mc = this.m_progressMc["player_level_mc"] as MovieClip;
                  this.m_player_level_mc.gotoAndStop(this.manager.getBadgeIndex());
                  if(this.m_player_level_mc.hasOwnProperty("range_s_detail_mc"))
                  {
                     this.m_level1HoverDetail = this.m_player_level_mc["range_s_detail_mc"] as MovieClip;
                     this.m_level1HoverDetail.visible = false;
                  }
                  this.m_player_level_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onLevel1Hover);
                  this.m_player_level_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onLevel1Out);
                  this.m_player_level_mc.visible = true;
               }
               if(this.m_progressMc.hasOwnProperty("week_ct_tf"))
               {
                  addWidget(this.m_progress_day_timer_tf = new ZwTextField(this.m_progressMc["week_ct_tf"],(8 - this.manager.getDatCount()).toString()));
                  if(this.manager.getactiveDayIndex() >= 35)
                  {
                     this.m_progress_day_timer_tf.text = "-";
                  }
                  this.m_progress_day_timer_tf.visible = true;
               }
               if(this.m_progressMc.hasOwnProperty("week_days_tf"))
               {
                  addWidget(this.m_progress_week_day_tf = new ZwTextField(this.m_progressMc["week_days_tf"],this.getTimeLeft()));
                  if(this.manager.getactiveDayIndex() == 41)
                  {
                     this.m_progress_week_day_tf.text = "--";
                  }
                  this.m_progress_week_day_tf.visible = true;
               }
               if(this.m_progressMc.hasOwnProperty("week_kids_tf"))
               {
                  addWidget(this.m_progress_week_kids_tf = new ZwTextField(this.m_progressMc["week_kids_tf"],this.manager.getKidsName()[0] + " and friends"));
                  this.m_progress_week_kids_tf.visible = true;
               }
               if(this.m_progressMc.hasOwnProperty("progress_bt"))
               {
                  this.m_progress_bt = new FarmAnimatedTextButton(this.m_progressMc["progress_bt"],"Progress",this.onClickProgressBt);
                  this.m_progress_bt.visible = true;
               }
               if(this.m_progressMc.hasOwnProperty("progress_meter_mc"))
               {
                  this.m_progress_meter_mc = this.m_progressMc["progress_meter_mc"] as MovieClip;
                  this.m_progress_meter_mc.visible = true;
                  if(this.m_progress_meter_mc.hasOwnProperty("hitarea_progress_mc"))
                  {
                     this.m_hitProgressMc = this.m_progress_meter_mc["hitarea_progress_mc"] as MovieClip;
                     this.m_hitProgressMc.visible = true;
                     this.m_hitProgressMc.addEventListener(MouseEvent.MOUSE_OVER,this.onProgressHover);
                     this.m_hitProgressMc.addEventListener(MouseEvent.MOUSE_OUT,this.onProgressOut);
                  }
                  if(this.m_progress_meter_mc.hasOwnProperty("hover_progress_mc"))
                  {
                     this.m_hoverProgressMc = this.m_progress_meter_mc["hover_progress_mc"] as MovieClip;
                     this.m_hoverProgressMc.visible = false;
                  }
                  if(this.m_progress_meter_mc.hasOwnProperty("icon_daily_reward_mc"))
                  {
                     addWidget(this.m_icon_daily_reward_mc = new FarmIcon(this.m_progress_meter_mc["icon_daily_reward_mc"]));
                     this.m_icon_daily_reward_mc.setIconSize(65,65);
                     this.m_icon_daily_reward_mc.visible = true;
                  }
                  if(this.m_progressMc.hasOwnProperty("mstone_count_tf"))
                  {
                     addWidget(this.m_mstoneCounttf = new ZwTextField(this.m_progressMc["mstone_count_tf"],""));
                     this.m_mstoneCounttf.visible = true;
                  }
                  if(this.m_progress_meter_mc.hasOwnProperty("meter_mc"))
                  {
                     this.m_meter_mc = this.m_progress_meter_mc["meter_mc"] as MovieClip;
                     this.m_meter_mc.visible = true;
                     if(this.m_meter_mc.hasOwnProperty("meter_fill_mc"))
                     {
                        this.m_meter_fill_mc = this.m_meter_mc["meter_fill_mc"] as MovieClip;
                        this.m_meter_fill_mc.visible = true;
                     }
                     if(this.m_meter_mc.hasOwnProperty("checkpoint_mc"))
                     {
                        this.m_check_point_mc = this.m_meter_mc["checkpoint_mc"] as MovieClip;
                        this.m_check_point_mc.visible = true;
                        if(this.m_check_point_mc.hasOwnProperty("coin_0_tf"))
                        {
                           addWidget(this.m_min_points_tf = new ZwTextField(this.m_check_point_mc["coin_0_tf"],""));
                           this.m_min_points_tf.visible = true;
                        }
                        if(this.m_check_point_mc.hasOwnProperty("coin_max_tf"))
                        {
                           addWidget(this.m_max_points_tf = new ZwTextField(this.m_check_point_mc["coin_max_tf"],""));
                           this.m_max_points_tf.visible = true;
                        }
                     }
                     if(this.m_meter_mc.hasOwnProperty("earned_points_mc"))
                     {
                        this.m_earned_points_mc = this.m_meter_mc["earned_points_mc"] as MovieClip;
                        this.m_earned_points_mc.visible = true;
                        if(this.m_earned_points_mc.hasOwnProperty("points_tf"))
                        {
                           addWidget(this.m_points_tf = new ZwTextField(this.m_earned_points_mc["points_tf"],""));
                           this.m_points_tf.visible = true;
                        }
                     }
                     this.updateMainWindow();
                  }
               }
            }
            if(m_window.hasOwnProperty("new_week_mc"))
            {
               this.m_newWeekMc = m_window["new_week_mc"] as MovieClip;
               this.m_newWeekMc.visible = false;
               if(this.m_newWeekMc.hasOwnProperty("npc_circle_mc"))
               {
                  this.m_npcCircleyWeekMc = this.m_newWeekMc["npc_circle_mc"] as MovieClip;
                  this.m_npcCircleyWeekMc.visible = true;
               }
               if(this.m_newWeekMc.hasOwnProperty("start_week_bt"))
               {
                  this.m_startWeekBt = new FarmAnimatedTextButton(this.m_newWeekMc["start_week_bt"],"Go!",this.onStartWeekBt);
                  this.m_startWeekBt.visible = true;
               }
            }
            if(m_window.hasOwnProperty("new_week_two_mc"))
            {
               this.m_newWeekTwoMc = m_window["new_week_two_mc"] as MovieClip;
               this.m_newWeekTwoMc.visible = false;
               if(this.m_newWeekTwoMc.hasOwnProperty("week_two_tf"))
               {
                  addWidget(this.m_newWeekTwotf = new ZwTextField(this.m_newWeekTwoMc["week_two_tf"],""));
                  this.m_newWeekTwotf.visible = true;
               }
               if(this.m_newWeekTwoMc.hasOwnProperty("start_week_two_bt"))
               {
                  this.m_startWeekTwoBt = new FarmAnimatedTextButton(this.m_newWeekTwoMc["start_week_two_bt"],"Go!",this.onStartWeekBt);
                  this.m_startWeekTwoBt.visible = true;
               }
            }
            if(m_window.hasOwnProperty("new_day_mc"))
            {
               this.m_newDayMc = m_window["new_day_mc"] as MovieClip;
               this.m_newDayMc.visible = false;
               if(this.m_newDayMc.hasOwnProperty("new_day_tf"))
               {
                  addWidget(this.m_newday_tf = new ZwTextField(this.m_newDayMc["new_day_tf"],"New Day, more candies!"));
                  this.m_newday_tf.visible = true;
               }
               if(this.m_newDayMc.hasOwnProperty("npc_circle_mc"))
               {
                  this.m_npcCircleyMc = this.m_newDayMc["npc_circle_mc"] as MovieClip;
                  this.m_npcCircleyMc.visible = true;
               }
               if(this.m_newDayMc.hasOwnProperty("start_day_bt"))
               {
                  this.m_startDayBt = new FarmAnimatedTextButton(this.m_newDayMc["start_day_bt"],"Go!",this.onStartNewBt);
                  this.m_startDayBt.visible = true;
               }
            }
            if(m_window.hasOwnProperty("end_feature_mc"))
            {
               this.m_endFeatureMc = m_window["end_feature_mc"] as MovieClip;
               if(this.m_endFeatureMc.hasOwnProperty("end_day_feature_bt"))
               {
                  this.m_endFeatureBt = new FarmAnimatedTextButton(this.m_endFeatureMc["end_day_feature_bt"],"Ok",this.endFeature);
                  this.m_endFeatureBt.visible = true;
               }
               this.m_endFeatureMc.visible = false;
            }
            if(m_window.hasOwnProperty("congrats_coupon_mc"))
            {
               this.m_congrats_coupon_mc = m_window["congrats_coupon_mc"] as MovieClip;
               this.m_congrats_coupon_mc.visible = false;
               if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_coupon_tile_tf"))
               {
                  this.m_unlock_coupon_tile_tf = new ZwTextField(this.m_congrats_coupon_mc["unlock_coupon_tile_tf"]);
                  this.m_unlock_coupon_tile_tf.visible = false;
               }
               if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_coupon_count_tf"))
               {
                  this.m_unlock_coupon_count_tf = new ZwTextField(this.m_congrats_coupon_mc["unlock_coupon_count_tf"]);
                  this.m_unlock_coupon_count_tf.visible = false;
               }
               if(this.m_congrats_coupon_mc.hasOwnProperty("unlock_thanks_bt"))
               {
                  this.m_unlock_coupon_bt = new FarmAnimatedTextButton(this.m_congrats_coupon_mc["unlock_thanks_bt"],"Awesome!",this.closeTileUnlockDialog);
                  this.m_unlock_coupon_bt.visible = false;
               }
            }
            this.showTileUnlockDialog();
            this.hideLevelOverlays();
            this.startTimer();
            if(!Global.player.getSeenFlag(this.HALLOWEEN2019_MIANWINDOW_FTUE_FLAG))
            {
               Global.player.setSeenFlag(this.HALLOWEEN2019_MIANWINDOW_FTUE_FLAG);
               this.showTutorial1();
            }
            this.manager.npcCalloutRedeem();
            this.checkFeatureReachedPoints();
         }
         else if(m_window.hasOwnProperty("end_feature_mc"))
         {
            this.m_endFeatureMc = m_window["end_feature_mc"] as MovieClip;
            if(this.m_endFeatureMc.hasOwnProperty("end_day_feature_bt"))
            {
               this.m_endFeatureBt = new FarmAnimatedTextButton(this.m_endFeatureMc["end_day_feature_bt"],"Ok",this.endFeature);
               this.m_endFeatureBt.visible = true;
            }
            this.m_endFeatureMc.visible = true;
         }
      }
      
      public function checkFeatureReachedPoints() : void
      {
         var points:int = this.manager.getFeaturePoints();
         if(points >= 4500)
         {
            this.m_candyKidFrame.stopAllKidsTimer();
            this.m_endFeatureMc.visible = true;
         }
      }
      
      public function updateEarnedPoints(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getFeaturePoints();
         var level:int = this.manager.getMilestoneLevel();
         var maxPoint:int = 0;
         var progressPoints:int = 0;
         if(level == 0)
         {
            maxPoint = int(this.manager.VAL_MILESTONE_POINTS_ARRAY[level]);
            progressPoints = dayPoints;
         }
         else
         {
            maxPoint = this.manager.VAL_MILESTONE_POINTS_ARRAY[level] - this.manager.VAL_MILESTONE_POINTS_ARRAY[level - 1];
            progressPoints = dayPoints - this.manager.VAL_MILESTONE_POINTS_ARRAY[level - 1];
         }
         if(this.m_points_tf)
         {
            this.m_points_tf.text = dayPoints.toString();
         }
         var barLength:Number = progressPoints * this.PROGRESS_BAR_FULL_WIDTH / maxPoint;
         if(this.m_earned_points_mc)
         {
            if(dayPoints < 0)
            {
               this.m_earned_points_mc.y = this.PROGRESS_BAR_FULL_WIDTH - barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_earned_points_mc,2,{"y":this.PROGRESS_BAR_FULL_WIDTH - barLength});
            }
            else
            {
               this.m_earned_points_mc.y = this.PROGRESS_BAR_FULL_WIDTH - barLength - 13;
            }
         }
      }
      
      public function updateProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getFeaturePoints();
         var level:int = this.manager.getMilestoneLevel();
         var maxPoint:int = 0;
         var progressPoints:int = 0;
         if(level == 0)
         {
            maxPoint = int(this.manager.VAL_MILESTONE_POINTS_ARRAY[level]);
            progressPoints = dayPoints;
         }
         else
         {
            maxPoint = this.manager.VAL_MILESTONE_POINTS_ARRAY[level] - this.manager.VAL_MILESTONE_POINTS_ARRAY[level - 1];
            progressPoints = dayPoints - this.manager.VAL_MILESTONE_POINTS_ARRAY[level - 1];
         }
         this.m_max_points_tf.text = "x" + this.manager.VAL_MILESTONE_POINTS_ARRAY[level];
         if(level == 0)
         {
            this.m_min_points_tf.text = "x0";
         }
         else
         {
            this.m_min_points_tf.text = "x" + this.manager.VAL_MILESTONE_POINTS_ARRAY[level - 1];
         }
         if(level == 7)
         {
            this.m_max_points_tf.text = "x4500";
         }
         var barLength:Number = progressPoints * this.PROGRESS_BAR_FULL_WIDTH / maxPoint;
         if(this.m_meter_fill_mc)
         {
            if(dayPoints < 0)
            {
               this.m_meter_fill_mc.height = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_meter_fill_mc,2,{"height":barLength});
            }
            else
            {
               this.m_meter_fill_mc.height = barLength;
            }
         }
      }
      
      public function updateMainWindow() : void
      {
         var mileStoneLevel:int = 0;
         var rewardItem:FarmItem = null;
         if(!(this.manager.isFeatureEnd() || this.manager.getFeaturePoints() >= 4500))
         {
            mileStoneLevel = this.manager.getMilestoneLevel();
            this.m_points_tf.text = "" + this.manager.getFeaturePoints();
            this.m_points_tf.visible = true;
            this.m_mstoneCounttf.text = (mileStoneLevel + 1).toString() + this.manager.getMilestonePostfix(mileStoneLevel) + " Milestone \n Reward";
            this.m_mstoneCounttf.visible = true;
            this.updateProgressBar();
            this.updateEarnedPoints();
            if(this.m_player_level_mc)
            {
               this.m_player_level_mc.gotoAndStop(this.manager.getBadgeIndex());
            }
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(Halloween2019InnovationManager.MILESTONE_REWARDS[this.manager.getMilestoneLevel()]);
            if(rewardItem)
            {
               this.m_icon_daily_reward_mc.loadIcon(rewardItem.iconUrl);
            }
            if(mileStoneLevel == 7)
            {
               this.m_icon_daily_reward_mc.loadIcon("assets/dialogs/spooky/innovation/buildings200.png");
            }
            this.m_icon_daily_reward_mc.setIconSize(65,65);
            if(this.m_icon_daily_reward_mc.tooltip != null)
            {
               this.m_icon_daily_reward_mc.detachTooltip();
            }
            if(rewardItem)
            {
               this.m_icon_daily_reward_mc.attachTooltip(new FarmTextTooltip(rewardItem.friendlyTitle));
            }
            if(mileStoneLevel == 7)
            {
               this.m_icon_daily_reward_mc.attachTooltip(new FarmTextTooltip("Spooky Buildings"));
            }
         }
      }
      
      public function hideLevelOverlays() : *
      {
         if(this.m_level1HoverDetail)
         {
            this.m_level1HoverDetail.visible = false;
         }
         if(this.m_level2HoverDetail)
         {
            this.m_level2HoverDetail.visible = false;
         }
      }
      
      private function onLevel1Hover(evt:MouseEvent) : void
      {
         this.m_level1HoverDetail.visible = true;
      }
      
      private function onLevel1Out(evt:MouseEvent) : void
      {
         this.m_level1HoverDetail.visible = false;
      }
      
      private function onAreaInfoHover(evt:MouseEvent) : void
      {
         this.m_areaInfoMc.visible = true;
      }
      
      private function onAreaInfoOut(evt:MouseEvent) : void
      {
         this.m_areaInfoMc.visible = false;
      }
      
      private function onProgressHover(evt:MouseEvent) : void
      {
         this.m_hoverProgressMc.visible = true;
      }
      
      private function onProgressOut(evt:MouseEvent) : void
      {
         this.m_hoverProgressMc.visible = false;
      }
      
      private function onLevel2Hover(evt:MouseEvent) : void
      {
         var dayPoints:int = this.manager.getFeaturePoints();
         var milestone:int = this.manager.getMilestoneLevel();
         if(dayPoints <= this.manager.VAL_MILESTONE_POINTS_ARRAY[milestone])
         {
            this.m_level2HoverDetail.visible = true;
         }
         else
         {
            this.m_level2HoverDetail.visible = false;
         }
      }
      
      private function onLevel2Out(evt:MouseEvent) : void
      {
         this.m_level2HoverDetail.visible = false;
      }
      
      private function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance(FEATURE_NAME);
      }
      
      public function onClickOrderboardOpenBt(event:Event) : void
      {
         var toolTipText:String = null;
         var maxOrder:int = this.manager.getMaxDailyOderboardCount();
         if(this.manager.getDailyOderboardTaskCount() != maxOrder)
         {
            this.manager.openOrderBoardWindow();
         }
      }
      
      public function onClickProgressBt(event:Event) : void
      {
         this.manager.openHalloween2019RewardWindow();
      }
      
      public function onNpcClose(event:Event) : void
      {
         this.m_npcCalloutMc.visible = false;
      }
      
      public function onClickSpecialCandyBt(event:Event) : void
      {
         this.manager.openCandyConversionWindow();
      }
      
      public function refreshStations() : void
      {
         this.m_stationsFrame.refresh();
      }
      
      public function refreshSpecialInventory() : void
      {
         this.m_specialCandyFrame.refresh();
      }
      
      public function onStartNewBt(event:Event) : void
      {
         this.manager.startNewDay();
      }
      
      public function onStartWeekBt(event:Event) : void
      {
         this.manager.resetDataAndSetNewWeek();
      }
      
      public function hideDayOverlay() : void
      {
         if(this.m_newDayMc)
         {
            this.m_newDayMc.visible = false;
         }
      }
      
      public function hideWeekOverlay() : void
      {
         if(this.m_newWeekMc)
         {
            this.m_newWeekMc.visible = false;
         }
         if(this.m_newWeekTwoMc)
         {
            this.m_newWeekTwoMc.visible = false;
         }
      }
      
      public function displayDayStartMessage() : void
      {
         if(this.manager.hasActiveDayExpired())
         {
            this.m_newDayMc.visible = true;
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
         var total:int = 0;
         var totalCandies:int = 0;
         var currentWeek:int = 0;
         if(this.manager.isFeatureEnd() || this.manager.getFeaturePoints() >= 4500)
         {
            if(this.manager.orderboardWindow)
            {
               this.manager.orderboardWindow.close();
            }
            if(this.manager.rewardWindow)
            {
               this.manager.rewardWindow.close();
            }
            this.m_candyKidFrame.stopAllKidsTimer();
            this.m_endFeatureMc.visible = true;
         }
         else if(this.manager.hasActiveWeekExpired())
         {
            if(this.manager.orderboardWindow)
            {
               this.manager.orderboardWindow.close();
            }
            if(this.manager.rewardWindow)
            {
               this.manager.rewardWindow.close();
            }
            total = this.manager.getCandyConversionWeekOver();
            totalCandies = this.manager.getTotalCandies();
            currentWeek = this.manager.getWeekNumber();
            if(currentWeek != 0 && totalCandies >= 150)
            {
               this.m_newWeekTwotf.text = "Also, don’t worry about candies from last time, they have be converted to " + total.toString() + " points.";
               this.m_newWeekTwotf.visible = true;
               this.m_newWeekTwoMc.visible = true;
            }
            else
            {
               this.m_newWeekMc.visible = true;
            }
         }
         else if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.orderboardWindow)
            {
               this.manager.orderboardWindow.close();
            }
            this.m_newDayMc.visible = true;
            this.manager.activeDay = true;
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
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.getFeatureExpiryTimeOnWall();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      public function getFeatureExpiryTimeOnWall() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("11/25/2019") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      override public function refreshWindow() : void
      {
         if(this.m_candyKidFrame)
         {
            this.m_candyKidFrame.refresh();
         }
      }
      
      public function refreshOrderboardCount() : void
      {
         if(this.orderCountTf)
         {
            this.orderCountTf.text = (this.manager.getMaxDailyOderboardCount() - this.manager.getDailyOderboardTaskCount()).toString();
            this.orderCountTf.visible = true;
         }
         this.setOderboardText();
      }
      
      public function setOderboardText() : void
      {
         if(this.manager.getDailyOderboardTaskCount() == this.manager.getMaxDailyOderboardCount())
         {
            this.m_getOderboardBt.enabled = false;
         }
         else
         {
            this.m_getOderboardBt.enabled = true;
         }
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
         }
         this.preSwitchChanges1(0);
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      public function endFeature(event:Event) : void
      {
         this.m_endFeatureBt.enabled = false;
         this.manager.featureEnd();
         this.close();
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_minitutorial_frame.visible = false;
         }
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
               button0.text = "Sure!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "OK!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "OK!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "OK!";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "OK!";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(4);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "OK!";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(5);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
               break;
            case 6:
               button6 = this.m_tutorialButtons[6] as FarmAnimatedTextButton;
               button6.text = "Progress";
               button6.visible = true;
               button6.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(6);
               (m_tutorial.element as MovieClip).gotoAndStop(7);
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes - 1)
         {
            ++tutorialSceneNumber;
            this.preSwitchChanges1(tutorialSceneNumber);
         }
         else
         {
            if(!Global.player.getSeenFlag(this.HALLOWEEN2019_PROGRESSWINDOW_FTUE_FLAG))
            {
               this.manager.openHalloween2019RewardWindow();
               Global.player.setSeenFlag(this.HALLOWEEN2019_PROGRESSWINDOW_FTUE_FLAG);
            }
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
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      public function refreshDaySlot() : void
      {
         this.m_progress_day_timer_tf.text = (8 - this.manager.getDatCount()).toString();
         if(this.manager.getactiveDayIndex() >= 35)
         {
            this.m_progress_day_timer_tf.text = "-";
         }
         this.m_progress_week_day_tf.text = this.getTimeLeft();
         if(this.manager.getactiveDayIndex() == 41)
         {
            this.m_progress_week_day_tf.text = "--";
         }
      }
      
      public function showTileUnlockDialog() : void
      {
         var tileString:String = null;
         var tileCount:int = this.manager.showTileUnlockCountMc();
         if(tileCount > 0)
         {
            this.m_congrats_coupon_mc.visible = true;
            this.m_unlock_coupon_count_tf.visible = false;
            tileString = tileCount > 1 ? " tiles!" : " tile!";
            this.m_unlock_coupon_tile_tf.text = "You have been granted " + (tileCount * this.manager.KEY_TILE_UNLOCK_POINTS).toString() + " Points for unlocking " + tileCount.toString() + tileString;
            this.m_unlock_coupon_tile_tf.visible = true;
            this.m_unlock_coupon_count_tf.text = "x" + (tileCount * 10).toString();
            this.m_unlock_coupon_count_tf.visible = true;
            this.m_unlock_coupon_bt.visible = true;
            this.m_unlock_coupon_bt.enabled = true;
         }
      }
      
      public function closeTileUnlockDialog(event:Event) : void
      {
         if(this.m_congrats_coupon_mc)
         {
            this.m_congrats_coupon_mc.visible = false;
            m_tile_count = this.manager.tileUnlockCount;
         }
         this.refreshWindow();
      }
      
      override public function close() : void
      {
         this.stopTimer();
         if(this.m_candyKidFrame)
         {
            this.m_candyKidFrame.stopAllKidsTimer();
         }
         super.close();
         FarmStatsManager.count("Halloween2019Innovation","Main_UI","close_window");
      }
   }
}

