package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Managers.RussiaInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CocowonderlandInnovationCustomerOrdersFrame;
   import Widgets.Frames.CocowonderlandInnovationIngredientsFrame;
   import Widgets.Frames.CocowonderlandInnovationStationsFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CocowonderlandInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static var m_tile_count:int;
      
      private static var m_congratsMc:MovieClip;
      
      private static var m_endFeatureDayMc:MovieClip;
      
      private static var m_duplicateOrderBt:FarmAnimatedTextButton;
      
      private static const NUM_TUTORIAL_SCENES:int = 10;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private static const WEEK_COUNT:int = 6;
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const HOWDOESTHISWORK_MC:String = "howDoesThisWork_mc";
      
      private static const SCORETIME_MC:String = "score_time_board_mc";
      
      private static const WEEKTIMER_TF:String = "week_timer_tf";
      
      private static const WEEKNAME_TF:String = "week_name_tf";
      
      private static const HOURTIMER_TF:String = "hour_timer_tf";
      
      private static const DAYTIMER_TF:String = "day_timer_tf";
      
      private static const ALLORDERS_MC:String = "all_orders_mc";
      
      private static const ALLSTATIONS_MC:String = "all_stations_mc";
      
      private static const ALLINGREDIENTS_MC:String = "all_ing_mc";
      
      private static const NEW_DAY_MC:String = "new_day_mc";
      
      private static const REDEEM_DAY_MC:String = "redeem_day_mc";
      
      private static const END_OVERLAY_MC:String = "end_day_mc";
      
      private static const START_WEEK_MC:String = "new_week_mc";
      
      private static const CONGRATS_DAY_MC:String = "congrats_day_mc";
      
      private static const DUPLICATE_MSG_MC:String = "duplicate_msg_mc";
      
      private static const LOCK_ING_MC:String = "lock_ing_mc";
      
      private static const DUPLICATE_OKAY_BT:String = "okay_dup_bt";
      
      private static const END_DAY_BT:String = "end_day_bt";
      
      private static const CONGRATS_DAY_BT:String = "congrats_day_bt";
      
      private static const END_DAY_FEATURE_BT:String = "end_day_feature_bt";
      
      private static const START_NEW_DAY_BT:String = "start_day_bt";
      
      private static const START_NEW_WEEK_BT:String = "start_week_bt";
      
      private static const REDEEM_DAY_BT:String = "redeem_day_bt";
      
      private static const DAY_BT:String = "day_bt";
      
      private static const NEW_DAY_TF:String = "new_day_tf";
      
      private static const GETCOUPONS_MC:String = "get_coupons_mc";
      
      private static const START_WEEK_ICON_MC:String = "icon_station_mc";
      
      private static const ORDERBOARD_BT:String = "earn_more_bt";
      
      private static const COUPONSCOUNT_TF:String = "coupons_count_tf";
      
      private static const STARTWEEK_STATION_NAME_TF:String = "station_name_tf";
      
      private static const ALLPROGRESS_MC:String = "all_progress_mc";
      
      private static const PROGRESSWINDOW_BT:String = "progress_bt";
      
      private static const PLAYERLEVEL_MC:String = "player_level_mc";
      
      private static const PROGRESSMETER_MC:String = "progress_meter_mc";
      
      private static const DAILYREWARDICON_MC:String = "icon_daily_reward_mc";
      
      private static const METER_MC:String = "meter_mc";
      
      private static const METERFILL_MC:String = "meter_fill_mc";
      
      private static const CHECKPOINT_MC:String = "checkpoint_mc";
      
      private static const HOTSPOT0_MC:String = "hotspot_checkpoint0_mc";
      
      private static const HOTSPOT1_MC:String = "hotspot_checkpoint1_mc";
      
      private static const MS0ICON_MC:String = "icon_mstone0_mc";
      
      private static const MS1ICON_MC:String = "icon_mstone1_mc";
      
      private static const ICONMSTONEIMG_MC:String = "icon_mstone_img_mc";
      
      private static const UNLOCKDESC_TF:String = "unlock_desc_tf";
      
      private static const UNLOCKSTATION_TF:String = "unlock_station_tf";
      
      private static const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private static const EARNED_POINTS_TF:String = "points_tf";
      
      private static const MINI_TUTORIAL_MC:String = "mini_tutorial_mc";
      
      private static const OKAY_BT:String = "okay_bt";
      
      private static const TUTORIAL_MC:String = "tutorial_mc";
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private static const TEXT_EARNMORE:String = "Earn More";
      
      private static const TEXT_PROGRESS_BT:String = "Progress";
      
      private static const DOOBER_MC:String = "lb_doober_mc";
      
      private var m_featureName:String = null;
      
      private const PACKAGE_REWARDS_ARRAY:Array = ["lp09","dlwc","bmx0","thm5","uv52","gz1k","26mu"];
      
      private var m_scoreTimeBoard_mc:MovieClip;
      
      private var m_weekNumber_tf:ZwTextField;
      
      private var m_weekName_tf:ZwTextField;
      
      private var m_hourTimer_tf:ZwTextField;
      
      private var m_startweek_name_tf:ZwTextField;
      
      private var m_dayTimer_tf:ZwTextField;
      
      private var m_all_progress_mc:MovieClip;
      
      public var m_player_level_mc:MovieClip;
      
      private var m_progress_meter_mc:MovieClip;
      
      private var m_daily_reward_icon:FarmIcon;
      
      private var m_icon_mstone1_img:FarmIcon;
      
      private var m_icon_mstone2_img:FarmIcon;
      
      private var m_meter_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_checkPoint_mc:MovieClip;
      
      private var m_lock1preview_mc:ZwFrame;
      
      private var m_lock2preview_mc:ZwFrame;
      
      private var m_level1preview_mc:ZwFrame;
      
      private var m_level2preview_mc:ZwFrame;
      
      public var m_dooberMc:MovieClip;
      
      public var m_dooberIconMc:MovieClip;
      
      public var m_dooberCountTf:ZwTextField;
      
      private var m_lock1Hover:MovieClip;
      
      private var m_lock2Hover:MovieClip;
      
      private var m_level1Hover:ZwFrame;
      
      private var m_level2Hover:ZwFrame;
      
      private var m_level1HoverDetail:MovieClip;
      
      private var m_level2HoverDetail:MovieClip;
      
      private var m_reward1_item:FarmItem;
      
      private var m_reward2_item:FarmItem;
      
      private var m_ea_ga_coupon_mc:MovieClip;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      private var m_mini_tutorial_frame:ZwFrame;
      
      private var m_close_tutorial_bt:FarmAnimatedTextButton;
      
      private var m_tutorialButtons:Array = [];
      
      public var m_ordersFrame:CocowonderlandInnovationCustomerOrdersFrame;
      
      public var m_stationsFrame:CocowonderlandInnovationStationsFrame;
      
      public var m_ingredientsFrame:CocowonderlandInnovationIngredientsFrame;
      
      private var m_unlock_desc1_tf:ZwTextField;
      
      private var m_unlock_desc2_tf:ZwTextField;
      
      private var m_unlock_station1_tf:ZwTextField;
      
      private var m_unlock_station2_tf:ZwTextField;
      
      private var m_free_count_tf:ZwTextField;
      
      private var m_coupon_ftue_tf:ZwTextField;
      
      private var m_unlock_coupon_tile_tf:ZwTextField;
      
      private var m_unlock_coupon_count_tf:ZwTextField;
      
      private var m_newDayMc:MovieClip;
      
      private var m_newWeekMc:MovieClip;
      
      private var m_startWeekIconMc:MovieClip;
      
      private var m_iconStationWeek5_grey_mc:MovieClip;
      
      private var m_StationWeekMC_Array:Array = [];
      
      private var m_redeemDayMc:MovieClip;
      
      private var m_startNewDay_bt:FarmAnimatedTextButton;
      
      private var m_startNewWeek_bt:FarmAnimatedTextButton;
      
      private var m_redeemDay_bt:FarmAnimatedTextButton;
      
      private var m_congratsDay_bt:FarmAnimatedTextButton;
      
      private var m_endFeatureDay_bt:FarmAnimatedTextButton;
      
      private var m_unlock_coupon_bt:FarmAnimatedTextButton;
      
      private var m_redeemDayTf:ZwTextField;
      
      private var m_endDayMc:MovieClip;
      
      private var m_redeemMc:MovieClip;
      
      public var m_duplicateMc:MovieClip;
      
      public var m_lockIng_mc:MovieClip;
      
      private var m_endDayBt:FarmAnimatedTextButton;
      
      private var m_redeemDayBt:FarmAnimatedTextButton;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 203;
      
      private var m_message_mc:MovieClip;
      
      private var m_messageTicket_mc:MovieClip;
      
      private var m_messageTitle:ZwTextField;
      
      private var m_messageInfo1:ZwTextField;
      
      private var m_messageInfo2:ZwTextField;
      
      private var m_messageOkay:FarmAnimatedCashButton;
      
      private var m_progress_bt:FarmAnimatedTextButton;
      
      private var m_earn_more_bt:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_totalcoupon_count_tf:ZwTextField;
      
      private var m_earnedPt_mc:MovieClip;
      
      private var m_earnedPt_tf:ZwTextField;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_isIconPreviewAdded:Boolean;
      
      private var m_best_icon_mc:FarmIcon;
      
      private const DAILY_DUMMY_MAX_POINT:Number = 30;
      
      private var m_getCoupons_mc:MovieClip;
      
      private var m_checkMark1_mc:MovieClip;
      
      private var m_checkMark2_mc:MovieClip;
      
      private var m_congrats_coupon_mc:MovieClip;
      
      public function CocowonderlandInnovationMainWindow(featureName:String = "CocowonderlandInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var slotForTheWeek:String = null;
         var tutorial_mc:MovieClip = null;
         var j:int = 0;
         var buttonName2:String = null;
         var buttonName1:String = null;
         var buttonName:String = null;
         this.visible = true;
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],"CAKE ME AWAY!"));
         }
         if(m_window.hasOwnProperty(GETCOUPONS_MC))
         {
            this.m_getCoupons_mc = m_window[GETCOUPONS_MC] as MovieClip;
            if(this.m_getCoupons_mc.hasOwnProperty(ORDERBOARD_BT))
            {
               addWidget(this.m_earn_more_bt = new FarmAnimatedTextButton(this.m_getCoupons_mc[ORDERBOARD_BT],TEXT_EARNMORE,this.onGetCouponsButtonClick));
            }
            if(this.m_getCoupons_mc.hasOwnProperty(COUPONSCOUNT_TF))
            {
               addWidget(this.m_totalcoupon_count_tf = new ZwTextField(this.m_getCoupons_mc[COUPONSCOUNT_TF],this.manager.getOrderboardProgress().toString()));
            }
            this.m_getCoupons_mc.visible = true;
         }
         if(m_window.hasOwnProperty(HOWDOESTHISWORK_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[HOWDOESTHISWORK_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(MINI_TUTORIAL_MC))
         {
            this.m_mini_tutorial_mc = m_window[MINI_TUTORIAL_MC] as MovieClip;
            this.m_mini_tutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
            if(this.m_mini_tutorial_mc.hasOwnProperty(OKAY_BT))
            {
               this.m_mini_tutorial_frame.addWidget(this.m_close_tutorial_bt = new FarmAnimatedTextButton(this.m_mini_tutorial_mc[OKAY_BT],"GREAT!",this.howDoesThisWorkFrameSwitch));
               this.m_close_tutorial_bt.visible = true;
            }
            this.m_mini_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty(SCORETIME_MC))
         {
            this.m_scoreTimeBoard_mc = m_window[SCORETIME_MC] as MovieClip;
            if(this.m_scoreTimeBoard_mc.hasOwnProperty(WEEKTIMER_TF))
            {
               addWidget(this.m_weekNumber_tf = new ZwTextField(this.m_scoreTimeBoard_mc[WEEKTIMER_TF]),this.manager.weekMenuNumber.toString());
               this.m_weekNumber_tf.visible = true;
            }
            if(this.m_scoreTimeBoard_mc.hasOwnProperty(WEEKNAME_TF))
            {
               addWidget(this.m_weekName_tf = new ZwTextField(this.m_scoreTimeBoard_mc[WEEKNAME_TF]),this.manager.weekMenuName.toString());
               this.m_weekName_tf.visible = true;
            }
            if(this.m_scoreTimeBoard_mc.hasOwnProperty(HOURTIMER_TF))
            {
               addWidget(this.m_dayTimer_tf = new ZwTextField(this.m_scoreTimeBoard_mc[DAYTIMER_TF]),this.getFeatureTimeLeft());
            }
            if(this.m_scoreTimeBoard_mc.hasOwnProperty(DAYTIMER_TF))
            {
               addWidget(this.m_hourTimer_tf = new ZwTextField(this.m_scoreTimeBoard_mc[HOURTIMER_TF]),this.getTimeLeftinDayText());
            }
            this.m_scoreTimeBoard_mc.visible = true;
         }
         if(m_window.hasOwnProperty(NEW_DAY_MC))
         {
            this.m_newDayMc = m_window[NEW_DAY_MC] as MovieClip;
            if(this.m_newDayMc.hasOwnProperty(START_NEW_DAY_BT))
            {
               addWidget(this.m_startNewDay_bt = new FarmAnimatedTextButton(this.m_newDayMc[START_NEW_DAY_BT],"Start Baking",this.manager.startNewDay));
               this.m_startNewDay_bt.visible = false;
            }
            this.m_newDayMc.visible = false;
         }
         if(m_window.hasOwnProperty(START_WEEK_MC))
         {
            this.m_newWeekMc = m_window[START_WEEK_MC] as MovieClip;
            if(this.m_newWeekMc.hasOwnProperty(START_NEW_WEEK_BT))
            {
               addWidget(this.m_startNewWeek_bt = new FarmAnimatedTextButton(this.m_newWeekMc[START_NEW_WEEK_BT],"Let\'s go!",this.manager.startNewWeek));
               this.m_startNewWeek_bt.visible = false;
            }
            if(this.m_newWeekMc.hasOwnProperty(STARTWEEK_STATION_NAME_TF))
            {
               addWidget(this.m_startweek_name_tf = new ZwTextField(this.m_newWeekMc[STARTWEEK_STATION_NAME_TF]),this.manager.stationNameAtWeekStart);
            }
            if(this.m_newWeekMc.hasOwnProperty(START_WEEK_ICON_MC))
            {
               this.m_startWeekIconMc = this.m_newWeekMc[START_WEEK_ICON_MC] as MovieClip;
               this.m_startWeekIconMc.visible = false;
               for(i = 0; i < WEEK_COUNT; i++)
               {
                  slotForTheWeek = "icon_station" + i + "_mc";
                  this.m_StationWeekMC_Array[i] = this.m_startWeekIconMc[slotForTheWeek] as MovieClip;
                  this.m_StationWeekMC_Array[i].visible = false;
               }
               if(this.m_startWeekIconMc.hasOwnProperty("icon_station5_grey_mc"))
               {
                  this.m_iconStationWeek5_grey_mc = this.m_startWeekIconMc["icon_station5_grey_mc"] as MovieClip;
                  this.m_iconStationWeek5_grey_mc.visible = false;
               }
            }
            this.m_newWeekMc.visible = false;
         }
         if(m_window.hasOwnProperty(REDEEM_DAY_MC))
         {
            this.m_redeemDayMc = m_window[REDEEM_DAY_MC] as MovieClip;
            if(this.m_redeemDayMc.hasOwnProperty(REDEEM_DAY_BT))
            {
               addWidget(this.m_redeemDay_bt = new FarmAnimatedTextButton(this.m_redeemDayMc[REDEEM_DAY_BT],"Start Baking",this.hideOverlay));
               this.m_redeemDay_bt.visible = false;
            }
            this.m_redeemDayMc.visible = false;
         }
         if(m_window.hasOwnProperty(END_OVERLAY_MC))
         {
            this.m_endDayMc = m_window[END_OVERLAY_MC] as MovieClip;
            if(this.m_endDayMc.hasOwnProperty(END_DAY_BT))
            {
               addWidget(this.m_endDayBt = new FarmAnimatedTextButton(this.m_endDayMc[END_DAY_BT],"Awesome!",this.closeMainWindow));
               this.m_endDayBt.visible = false;
            }
            this.m_endDayMc.visible = false;
         }
         if(m_window.hasOwnProperty(CONGRATS_DAY_MC))
         {
            m_congratsMc = m_window[CONGRATS_DAY_MC] as MovieClip;
            if(m_congratsMc.hasOwnProperty(CONGRATS_DAY_BT))
            {
               addWidget(this.m_congratsDay_bt = new FarmAnimatedTextButton(m_congratsMc[CONGRATS_DAY_BT],"Awesome!",this.closeMainWindow));
               this.m_congratsDay_bt.visible = false;
            }
            m_congratsMc.visible = false;
         }
         if(m_window.hasOwnProperty("end_feature_mc"))
         {
            m_endFeatureDayMc = m_window["end_feature_mc"] as MovieClip;
            if(m_endFeatureDayMc.hasOwnProperty(END_DAY_FEATURE_BT))
            {
               addWidget(this.m_endFeatureDay_bt = new FarmAnimatedTextButton(m_endFeatureDayMc[END_DAY_FEATURE_BT],"Awesome!",this.closeMainWindow));
               this.m_endFeatureDay_bt.visible = false;
            }
            m_endFeatureDayMc.visible = false;
         }
         if(m_window.hasOwnProperty(DUPLICATE_MSG_MC))
         {
            this.m_duplicateMc = m_window[DUPLICATE_MSG_MC] as MovieClip;
            if(this.m_duplicateMc.hasOwnProperty(DUPLICATE_OKAY_BT))
            {
               addWidget(m_duplicateOrderBt = new FarmAnimatedTextButton(this.m_duplicateMc[DUPLICATE_OKAY_BT],"Okay!",this.hideOverlay));
               m_duplicateOrderBt.visible = false;
            }
            this.m_duplicateMc.visible = false;
         }
         if(m_window.hasOwnProperty(LOCK_ING_MC))
         {
            this.m_lockIng_mc = m_window[LOCK_ING_MC] as MovieClip;
            this.m_lockIng_mc.visible = false;
         }
         if(m_window.hasOwnProperty(ALLPROGRESS_MC))
         {
            this.m_all_progress_mc = m_window[ALLPROGRESS_MC] as MovieClip;
            this.m_all_progress_mc.visible = true;
            if(this.m_all_progress_mc.hasOwnProperty(PROGRESSWINDOW_BT))
            {
               addWidget(this.m_progress_bt = new FarmAnimatedTextButton(this.m_all_progress_mc[PROGRESSWINDOW_BT],TEXT_PROGRESS_BT,this.onProgressButtonClick));
               this.m_progress_bt.visible = true;
            }
            if(this.m_all_progress_mc.hasOwnProperty(DOOBER_MC))
            {
               this.m_dooberMc = this.m_all_progress_mc[DOOBER_MC] as MovieClip;
               if(this.m_dooberMc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_dooberIconMc = this.m_dooberMc.dooberIcon_mc;
                  if(this.m_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     addWidget(this.m_dooberCountTf = new ZwTextField(this.m_dooberIconMc["dooberCount_tf"]));
                  }
               }
            }
            if(this.m_all_progress_mc.hasOwnProperty(PLAYERLEVEL_MC))
            {
               this.m_player_level_mc = this.m_all_progress_mc[PLAYERLEVEL_MC] as MovieClip;
               this.m_player_level_mc.gotoAndStop(1);
               if(this.m_player_level_mc.hasOwnProperty("range_s_detail_mc"))
               {
                  this.m_level1HoverDetail = this.m_player_level_mc["range_s_detail_mc"] as MovieClip;
                  this.m_level1HoverDetail.visible = false;
               }
               if(this.m_player_level_mc.hasOwnProperty("range_p_detail_mc"))
               {
                  this.m_level2HoverDetail = this.m_player_level_mc["range_p_detail_mc"] as MovieClip;
                  this.m_level2HoverDetail.visible = false;
               }
               if(this.m_player_level_mc.hasOwnProperty("range_sous_mc"))
               {
                  addWidget(this.m_level1Hover = new ZwFrame(this.m_player_level_mc["range_sous_mc"]),true);
                  this.m_level1Hover.registerEventListener(MouseEvent.MOUSE_OVER,this.onLevel1Hover);
                  this.m_level1Hover.registerEventListener(MouseEvent.MOUSE_OUT,this.onLevel1Out);
               }
               if(this.m_player_level_mc.hasOwnProperty("range_patissier_mc"))
               {
                  addWidget(this.m_level2Hover = new ZwFrame(this.m_player_level_mc["range_patissier_mc"]),true);
                  this.m_level2Hover.registerEventListener(MouseEvent.MOUSE_OVER,this.onLevel2Hover);
                  this.m_level2Hover.registerEventListener(MouseEvent.MOUSE_OUT,this.onLevel2Out);
               }
            }
            if(this.m_all_progress_mc.hasOwnProperty(PROGRESSMETER_MC))
            {
               this.m_progress_meter_mc = this.m_all_progress_mc[PROGRESSMETER_MC] as MovieClip;
               this.m_progress_meter_mc.visible = true;
               if(this.m_progress_meter_mc.hasOwnProperty(DAILYREWARDICON_MC))
               {
                  addWidget(this.m_daily_reward_icon = new FarmIcon(this.m_progress_meter_mc[DAILYREWARDICON_MC]));
                  this.m_daily_reward_icon.visible = true;
               }
               if(this.m_progress_meter_mc.hasOwnProperty(METER_MC))
               {
                  this.m_meter_mc = this.m_progress_meter_mc[METER_MC] as MovieClip;
                  this.m_meter_mc.visible = true;
                  if(this.m_meter_mc.hasOwnProperty(METERFILL_MC))
                  {
                     this.m_barMc = this.m_meter_mc[METERFILL_MC] as MovieClip;
                     this.m_barMc.visible = true;
                  }
                  if(this.m_meter_mc.hasOwnProperty(EARNED_POINTS_MC))
                  {
                     this.m_earnedPt_mc = this.m_meter_mc[EARNED_POINTS_MC] as MovieClip;
                     if(this.m_earnedPt_mc.hasOwnProperty(EARNED_POINTS_TF))
                     {
                        addWidget(this.m_earnedPt_tf = new ZwTextField(this.m_earnedPt_mc[EARNED_POINTS_TF]));
                        this.m_earnedPt_tf.visible = true;
                     }
                     this.m_earnedPt_mc.visible = true;
                  }
                  if(this.m_meter_mc.hasOwnProperty(CHECKPOINT_MC))
                  {
                     this.m_checkPoint_mc = this.m_meter_mc[CHECKPOINT_MC] as MovieClip;
                     if(this.m_checkPoint_mc.hasOwnProperty(MS0ICON_MC))
                     {
                        this.m_lock1Hover = this.m_checkPoint_mc[MS0ICON_MC] as MovieClip;
                        this.m_lock1Hover.visible = false;
                        if(this.m_lock1Hover.hasOwnProperty("checkmark_mc"))
                        {
                           this.m_checkMark1_mc = this.m_lock1Hover["checkmark_mc"] as MovieClip;
                           this.m_checkMark1_mc.visible = false;
                        }
                        if(this.m_lock1Hover.hasOwnProperty(ICONMSTONEIMG_MC))
                        {
                           this.m_icon_mstone1_img = new FarmIcon(this.m_lock1Hover[ICONMSTONEIMG_MC]);
                           this.m_reward1_item = this.manager.getActiveDayReward(0);
                           this.m_icon_mstone1_img.loadIcon(this.m_reward1_item.iconUrl);
                           this.m_icon_mstone1_img.setIconSize(40,40);
                        }
                        if(this.m_lock1Hover.hasOwnProperty(UNLOCKDESC_TF))
                        {
                           this.m_unlock_desc1_tf = new ZwTextField(this.m_lock1Hover[UNLOCKDESC_TF],"Reach milestone to get this reward");
                           this.m_unlock_desc1_tf.visible = false;
                        }
                        if(this.m_lock1Hover.hasOwnProperty(UNLOCKSTATION_TF))
                        {
                           this.m_unlock_station1_tf = new ZwTextField(this.m_lock1Hover[UNLOCKSTATION_TF],"Reach to unlock\nStation 1");
                           this.m_unlock_station1_tf.visible = false;
                        }
                        this.m_lock1Hover.visible = false;
                     }
                     if(this.m_checkPoint_mc.hasOwnProperty(MS1ICON_MC))
                     {
                        this.m_lock2Hover = this.m_checkPoint_mc[MS1ICON_MC] as MovieClip;
                        this.m_lock2Hover.visible = false;
                        if(this.m_lock2Hover.hasOwnProperty("checkmark_mc"))
                        {
                           this.m_checkMark2_mc = this.m_lock2Hover["checkmark_mc"] as MovieClip;
                           this.m_checkMark2_mc.visible = false;
                        }
                        if(this.m_lock2Hover.hasOwnProperty(ICONMSTONEIMG_MC))
                        {
                           this.m_icon_mstone2_img = new FarmIcon(this.m_lock2Hover[ICONMSTONEIMG_MC]);
                           this.m_reward2_item = this.manager.getActiveDayReward(1);
                           this.m_icon_mstone2_img.loadIcon(this.m_reward2_item.iconUrl);
                           this.m_icon_mstone2_img.setIconSize(40,40);
                        }
                        if(this.m_lock2Hover.hasOwnProperty(UNLOCKDESC_TF))
                        {
                           this.m_unlock_desc2_tf = new ZwTextField(this.m_lock2Hover[UNLOCKDESC_TF],"Reach milestone to get this reward");
                           this.m_unlock_desc2_tf.visible = false;
                        }
                        if(this.m_lock2Hover.hasOwnProperty(UNLOCKSTATION_TF))
                        {
                           this.m_unlock_station2_tf = new ZwTextField(this.m_lock2Hover[UNLOCKSTATION_TF],"Reach to unlock\nStation 2");
                           this.m_unlock_station2_tf.visible = false;
                        }
                        this.m_lock2Hover.visible = false;
                     }
                     if(this.m_checkPoint_mc.hasOwnProperty(HOTSPOT0_MC))
                     {
                        addWidget(this.m_lock1preview_mc = new ZwFrame(this.m_checkPoint_mc[HOTSPOT0_MC]),true);
                        this.m_lock1preview_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onLock1Over);
                        this.m_lock1preview_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onLock1Out);
                     }
                     if(this.m_checkPoint_mc.hasOwnProperty(HOTSPOT1_MC))
                     {
                        addWidget(this.m_lock2preview_mc = new ZwFrame(this.m_checkPoint_mc[HOTSPOT1_MC]),true);
                        this.m_lock2preview_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onLock2Over);
                        this.m_lock2preview_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onLock2Out);
                     }
                  }
               }
            }
         }
         if(m_window.hasOwnProperty(ALLORDERS_MC))
         {
            this.m_ordersFrame = new CocowonderlandInnovationCustomerOrdersFrame(m_window[ALLORDERS_MC],this,this.m_featureName);
         }
         if(m_window.hasOwnProperty(ALLINGREDIENTS_MC))
         {
            this.m_ingredientsFrame = new CocowonderlandInnovationIngredientsFrame(m_window[ALLINGREDIENTS_MC],this,this.m_featureName);
         }
         if(m_window.hasOwnProperty(ALLSTATIONS_MC))
         {
            this.m_stationsFrame = new CocowonderlandInnovationStationsFrame(m_window[ALLSTATIONS_MC],this,this.m_featureName);
         }
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TUTORIAL_MC))
         {
            tutorial_mc = m_window[TUTORIAL_MC] as MovieClip;
            if(m_tutorial)
            {
               if(tutorial_mc.hasOwnProperty("free_count_tf"))
               {
                  this.m_free_count_tf = new ZwTextField(tutorial_mc["free_count_tf"],this.manager.grantEAandGACoupons());
                  this.m_free_count_tf.visible = false;
               }
               if(tutorial_mc.hasOwnProperty("ea_ga_coupons_mc"))
               {
                  this.m_ea_ga_coupon_mc = tutorial_mc["ea_ga_coupons_mc"] as MovieClip;
                  if(this.m_ea_ga_coupon_mc.hasOwnProperty("coupon_ftue_tf"))
                  {
                     this.m_coupon_ftue_tf = new ZwTextField(this.m_ea_ga_coupon_mc["coupon_ftue_tf"],this.manager.grantEAandGACouponCount());
                     this.m_coupon_ftue_tf.visible = false;
                  }
                  this.m_ea_ga_coupon_mc.visible = false;
               }
               for(j = 0; j < 3; j++)
               {
                  buttonName1 = "okay_f" + (j + 1).toString() + "_bt";
                  if(tutorial_mc.hasOwnProperty(buttonName1))
                  {
                     this.m_tutorialButtons[j] = new FarmAnimatedTextButton(tutorial_mc[buttonName1]);
                     m_tutorial.addWidget(this.m_tutorialButtons[j] as FarmAnimatedTextButton);
                     this.m_tutorialButtons[j].visible = false;
                  }
               }
               for(i = 0; i < 6; i++)
               {
                  buttonName = "okay_" + i.toString() + "_bt";
                  if(tutorial_mc.hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[i + j] = new FarmAnimatedTextButton(tutorial_mc[buttonName]);
                     m_tutorial.addWidget(this.m_tutorialButtons[i + j] as FarmAnimatedTextButton);
                     this.m_tutorialButtons[i + j].visible = false;
                  }
               }
               buttonName2 = "okay_f4_bt";
               if(tutorial_mc.hasOwnProperty(buttonName2))
               {
                  this.m_tutorialButtons[i + j] = new FarmAnimatedTextButton(tutorial_mc[buttonName2]);
                  m_tutorial.addWidget(this.m_tutorialButtons[i + j] as FarmAnimatedTextButton);
                  this.m_tutorialButtons[i + j].visible = false;
               }
            }
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
         if(this.isFirstTimeTutorial())
         {
            this.preSwitchChanges(tutorialSceneNumber);
         }
         this.showTileUnlockDialog();
         this.updateProgressBar(true);
         this.updatePlayerLevel();
         this.updateDayBonus();
         this.startTimer();
         this.updateEarnedPoints(true);
         this.refreshCouponCount();
         this.refreshStationOrderAndIngredientFrames();
      }
      
      public function refreshCouponCount() : void
      {
         if(this.m_totalcoupon_count_tf)
         {
            this.m_totalcoupon_count_tf.text = this.manager.getOrderboardProgress().toString();
         }
      }
      
      public function hideOverlay(e:Event) : void
      {
         if(this.m_newDayMc)
         {
            this.m_newDayMc.visible = false;
         }
         if(this.m_redeemDayMc)
         {
            this.m_redeemDayMc.visible = false;
         }
         if(this.m_duplicateMc)
         {
            this.m_duplicateMc.visible = false;
         }
         if(this.m_newWeekMc)
         {
            this.m_newWeekMc.visible = false;
         }
      }
      
      public function showTileUnlockDialog() : void
      {
         var tileCount:int = this.manager.showTileUnlockCountMc();
         if(tileCount > 0)
         {
            this.m_congrats_coupon_mc.visible = true;
            this.m_unlock_coupon_count_tf.visible = false;
            this.m_unlock_coupon_tile_tf.text = "You have been granted " + (tileCount * this.manager.KEY_TILE_UNLOCK_POINTS).toString() + " Coupons for unlocking " + tileCount.toString() + " tiles!";
            this.m_unlock_coupon_tile_tf.visible = true;
            this.m_unlock_coupon_count_tf.text = (tileCount * 30).toString();
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
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         if(this.manager.hasActiveDayExpired())
         {
         }
         if(this.m_weekNumber_tf)
         {
            this.m_weekNumber_tf.text = this.manager.weekMenuNumber.toString();
            this.m_weekNumber_tf.visible = true;
         }
         if(this.m_weekName_tf)
         {
            this.m_weekName_tf.text = this.manager.weekMenuName.toString();
            this.m_weekName_tf.visible = true;
         }
         if(this.m_dayTimer_tf)
         {
            this.m_dayTimer_tf.text = this.getFeatureTimeLeft();
         }
         if(this.m_hourTimer_tf)
         {
            this.m_hourTimer_tf.text = this.getTimeLeftinDayText();
         }
      }
      
      private function onGetCouponsButtonClick(event:Event) : void
      {
         StatsManager.count(this.m_featureName,"Click","Coupon UI",null,null,this.manager.getDayPoints().toString(),this.manager.getOrderboardProgress());
         this.manager.openOrderBoardWindow();
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_ask_bt)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(RussiaInnovationManager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_ask_bt.enabled = true;
               this.m_ask_bt.detachTooltip();
            }
         }
      }
      
      public function disableProgressButton() : void
      {
         FarmGameUtil.disableButtonAndShowTooltip(this.m_progress_bt,"");
      }
      
      public function enableProgressButton() : void
      {
         this.m_progress_bt.enabled = true;
      }
      
      private function onProgressButtonClick(e:Event) : void
      {
         this.manager.openViewProgressWindow();
         m_closeButton.enabled = false;
         this.disableProgressButton();
      }
      
      public function onCloseProgressWindow(e:Event) : void
      {
         untintWindow();
         enableInput = true;
         this.enableProgressButton();
         m_closeButton.enabled = true;
      }
      
      private function closeMainWindow(e:Event) : void
      {
         this.close();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_mini_tutorial_frame)
         {
            (this.m_mini_tutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_mini_tutorial_frame.visible = true;
         }
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event) : void
      {
         var totalFrames:int = int(this.m_mini_tutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_mini_tutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_mini_tutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_mini_tutorial_frame.visible = false;
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         m_tutorial.element["arrow_mc"].visible = true;
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            ++tutorialSceneNumber;
            this.preSwitchChanges(tutorialSceneNumber);
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            this.hideTutorial();
            this.m_stationsFrame.hideStations(false);
         }
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         var button6:FarmAnimatedTextButton = null;
         var button7:FarmAnimatedTextButton = null;
         var button8:FarmAnimatedTextButton = null;
         var button9:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 1:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Next";
               button0.visible = true;
               button0.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(0);
               break;
            case 2:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Next";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(1);
               break;
            case 3:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Next";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(2);
               break;
            case 4:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "Free";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(3);
               break;
            case 5:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "3";
               button4.visible = true;
               (this.m_tutorialButtons[5] as FarmAnimatedTextButton).visible = true;
               (this.m_tutorialButtons[6] as FarmAnimatedTextButton).visible = true;
               button4.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(4);
               break;
            case 6:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "Add";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(5);
               break;
            case 7:
               button6 = this.m_tutorialButtons[6] as FarmAnimatedTextButton;
               button6.text = "Add";
               button6.visible = true;
               (this.m_tutorialButtons[5] as FarmAnimatedTextButton).enabled = false;
               button6.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(6);
               break;
            case 8:
               button7 = this.m_tutorialButtons[7] as FarmAnimatedTextButton;
               button7.text = "Cook!";
               button7.visible = true;
               (this.m_tutorialButtons[6] as FarmAnimatedTextButton).enabled = false;
               button7.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(7);
               break;
            case 9:
               button8 = this.m_tutorialButtons[8] as FarmAnimatedTextButton;
               button8.text = "Awesome!";
               button8.visible = true;
               button8.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(8);
               break;
            case 10:
               button9 = this.m_tutorialButtons[9] as FarmAnimatedTextButton;
               this.m_ea_ga_coupon_mc.visible = true;
               this.m_coupon_ftue_tf.visible = true;
               this.m_free_count_tf.text = this.manager.grantEAandGACoupons();
               this.m_free_count_tf.visible = true;
               button9.text = "Great!";
               button9.visible = true;
               button9.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(9);
         }
      }
      
      private function hideOtherTutorialButtonsExpect(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      public function updateProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = normalizedPoints * this.PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_barMc)
         {
            if(dayPoints < 0)
            {
               this.m_barMc.height = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
            }
         }
      }
      
      public function updateEarnedPoints(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         if(this.m_earnedPt_tf)
         {
            this.m_earnedPt_tf.text = dayPoints.toString();
         }
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = normalizedPoints * this.PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_earnedPt_mc)
         {
            if(dayPoints < 0)
            {
               this.m_earnedPt_mc.y = this.PROGRESS_BAR_FULL_WIDTH - barLength - 13;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_earnedPt_mc,2,{"y":this.PROGRESS_BAR_FULL_WIDTH - barLength - 13});
            }
            else
            {
               this.m_earnedPt_mc.y = this.PROGRESS_BAR_FULL_WIDTH - barLength - 13;
            }
         }
      }
      
      public function updatePlayerLevel() : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         this.m_level1HoverDetail.visible = false;
         this.m_level2HoverDetail.visible = false;
         if(dayPoints >= this.manager.VAL_SECOND_MILESTONE)
         {
            this.m_player_level_mc.gotoAndStop(3);
         }
         else if(dayPoints >= this.manager.VAL_FIRST_MILESTONE)
         {
            this.m_player_level_mc.gotoAndStop(2);
         }
         else
         {
            this.m_player_level_mc.gotoAndStop(1);
         }
      }
      
      public function showDoober(dimes:int) : void
      {
         this.m_dooberMc.visible = true;
         this.m_dooberMc.play();
         this.m_dooberIconMc.visible = true;
         this.m_dooberIconMc.play();
         this.m_dooberCountTf.text = dimes.toString();
         this.m_dooberCountTf.visible = true;
      }
      
      public function hideIngredientLockOverlay() : void
      {
         if(this.m_lockIng_mc)
         {
            this.m_lockIng_mc.visible = false;
         }
      }
      
      public function showIngredientLockOverlay() : void
      {
         if(this.m_lockIng_mc)
         {
            this.m_lockIng_mc.visible = true;
         }
      }
      
      private function refreshLockVisiblility() : void
      {
         switch(this.manager.getUserState())
         {
            case this.manager.DONE_FOR_THE_DAY:
               this.m_lock1preview_mc.visible = false;
               this.m_lock2preview_mc.visible = false;
               break;
            default:
               this.m_lock1preview_mc.visible = true;
               this.m_lock2preview_mc.visible = true;
         }
      }
      
      public function displayWelcomeBackMessage() : void
      {
         if(this.m_redeemDayMc)
         {
            this.m_redeemDayMc.visible = true;
            this.showIngredientLockOverlay();
            if(this.m_redeemDayTf)
            {
               this.m_redeemDayTf.visible = true;
            }
            if(this.m_redeemDay_bt)
            {
               this.m_redeemDay_bt.visible = true;
               this.m_redeemDay_bt.enabled = true;
            }
         }
      }
      
      public function getOldTasksRedeemedFromUser(e:Event = null) : void
      {
         this.m_message_mc.visible = false;
      }
      
      public function displayDayStartMessage() : void
      {
         if(this.manager.areStationsBusy())
         {
            if(this.m_redeemDayMc)
            {
               this.showIngredientLockOverlay();
               this.m_redeemDayMc.visible = true;
               if(this.m_redeemDay_bt)
               {
                  this.m_redeemDay_bt.visible = true;
                  this.m_redeemDay_bt.enabled = true;
               }
            }
         }
         else if(this.m_newDayMc)
         {
            this.hideIngredientLockOverlay();
            this.m_newDayMc.visible = true;
            if(this.m_startNewDay_bt)
            {
               this.m_startNewDay_bt.visible = true;
               this.m_startNewDay_bt.enabled = true;
            }
         }
      }
      
      public function displayFeatureStartMessage() : void
      {
         if(this.m_newDayMc)
         {
            this.m_newDayMc.visible = true;
            if(this.m_startNewDay_bt)
            {
               this.m_startNewDay_bt.visible = true;
               this.m_startNewDay_bt.enabled = true;
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.updateDayBonus();
         this.updateProgressBar();
         this.updateEarnedPoints();
         this.updatePlayerLevel();
         this.refreshCouponCount();
         this.refreshLockVisiblility();
      }
      
      public function refreshStationOrderAndIngredientFrames() : void
      {
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
            firstTimeFeatureAccess = true;
         }
         else if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.redeemableStationOrders() > 0 && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
            {
               if(this.manager.redeemHasStarted == false)
               {
                  redeemPreviousDayTask = true;
                  if(this.manager.redeemMessageShown == false)
                  {
                     this.displayWelcomeBackMessage();
                     this.manager.redeemMessageShown = true;
                  }
               }
            }
            else
            {
               if(this.manager.redeemHasStarted && this.manager.hasActiveWeekExpired())
               {
                  this.manager.onRedeemStarted();
               }
               this.displayDayStartMessage();
               firstTimeFeatureAccess = true;
            }
         }
         else if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            if(this.manager.activeDayIndex == 41)
            {
               this.showEODOverlayFeatureEnd();
            }
            else
            {
               this.showEODOverlay2();
            }
         }
         this.refreshLockVisiblility();
      }
      
      public function updateDayBonus() : void
      {
         if(this.m_best_icon_mc)
         {
            this.m_best_icon_mc.visible = false;
            (this.m_best_icon_mc as FarmIcon).release();
         }
         var finalMileStoneItem:FarmItem = this.manager.getActiveDayReward(this.manager.HARD);
         if(finalMileStoneItem)
         {
            if(Boolean(0) && this.PACKAGE_REWARDS_ARRAY.indexOf(finalMileStoneItem.code) == -1)
            {
               addWidget(this.m_iconPreview = new ObjectPreviewFrame(this.m_progress_meter_mc[DAILYREWARDICON_MC] as MovieClip,finalMileStoneItem,null,null,[100]),true);
               this.m_iconPreview.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
               this.m_isIconPreviewAdded = true;
            }
            else
            {
               this.m_best_icon_mc = new FarmIcon(this.m_progress_meter_mc[DAILYREWARDICON_MC],finalMileStoneItem.iconUrl);
               this.m_best_icon_mc.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
               this.m_best_icon_mc.visible = true;
            }
         }
         this.m_icon_mstone1_img.loadIcon(this.manager.getActiveDayReward(0).iconUrl);
         this.m_icon_mstone2_img.loadIcon(this.manager.getActiveDayReward(1).iconUrl);
      }
      
      private function getTimeLeftinDayText() : String
      {
         return HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
      }
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText();
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function onLock1Over(evt:MouseEvent) : void
      {
         this.m_lock1Hover.visible = true;
         this.m_icon_mstone1_img.visible = true;
         if(this.manager.getDayPoints() >= this.manager.VAL_FIRST_MILESTONE || this.manager.getDayPoints() >= this.manager.VAL_SECOND_MILESTONE)
         {
            if(this.manager.isGAPlayer() == false && this.manager.getCurrentWeek().count == 1)
            {
               this.m_lock1Hover.visible = false;
               this.m_icon_mstone1_img.visible = false;
            }
            else
            {
               this.m_checkMark1_mc.visible = true;
               this.m_unlock_desc1_tf.text = "\nCongrats! You have earned this reward!";
               this.m_unlock_desc1_tf.visible = true;
            }
         }
         else
         {
            if(this.m_unlock_station1_tf)
            {
               this.m_unlock_station1_tf.visible = true;
            }
            if(this.m_unlock_desc1_tf)
            {
               this.m_unlock_desc1_tf.text = "Reach milestone to get this reward";
               this.m_unlock_desc1_tf.visible = true;
            }
         }
      }
      
      private function onLock1Out(evt:MouseEvent) : void
      {
         this.m_lock1Hover.visible = false;
         this.m_icon_mstone1_img.visible = false;
         this.m_checkMark1_mc.visible = false;
         if(this.m_unlock_station1_tf)
         {
            this.m_unlock_station1_tf.visible = false;
         }
         this.m_unlock_desc1_tf.visible = false;
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
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints <= this.manager.VAL_SECOND_MILESTONE)
         {
            this.m_level1HoverDetail.visible = true;
         }
         else
         {
            this.m_level1HoverDetail.visible = false;
         }
      }
      
      private function onLevel1Out(evt:MouseEvent) : void
      {
         this.m_level1HoverDetail.visible = false;
      }
      
      private function onLevel2Hover(evt:MouseEvent) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints <= this.manager.VAL_THIRD_MILESTONE)
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
      
      private function onLock2Over(evt:MouseEvent) : void
      {
         this.m_lock2Hover.visible = true;
         this.m_icon_mstone2_img.visible = true;
         if(this.manager.getDayPoints() >= this.manager.VAL_SECOND_MILESTONE)
         {
            if(this.manager.isGAPlayer() == false && this.manager.getCurrentWeek().count == 1)
            {
               this.m_lock2Hover.visible = false;
               this.m_icon_mstone2_img.visible = false;
            }
            else
            {
               this.m_checkMark2_mc.visible = true;
               this.m_unlock_desc2_tf.text = "\nCongrats! You have earned this reward!";
               this.m_unlock_desc2_tf.visible = true;
            }
         }
         else
         {
            if(this.m_unlock_station2_tf)
            {
               this.m_unlock_station2_tf.visible = true;
            }
            if(this.m_unlock_desc2_tf)
            {
               this.m_unlock_desc2_tf.text = "Reach milestone to get this reward";
               this.m_unlock_desc2_tf.visible = true;
            }
         }
      }
      
      private function onLock2Out(evt:MouseEvent) : void
      {
         this.m_lock2Hover.visible = false;
         this.m_icon_mstone2_img.visible = false;
         this.m_checkMark2_mc.visible = false;
         if(this.m_unlock_station2_tf)
         {
            this.m_unlock_station2_tf.visible = false;
         }
         this.m_unlock_desc2_tf.visible = false;
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
      
      override protected function hideTutorial() : void
      {
         super.hideTutorial();
      }
      
      public function isFirstTimeTutorial() : Boolean
      {
         return m_tutorialFirstTime;
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
      }
      
      public function showEODOverlay1() : void
      {
         if(m_congratsMc)
         {
            m_congratsMc.visible = true;
            this.m_congratsDay_bt.text = "Awesome!";
            this.m_congratsDay_bt.visible = true;
         }
      }
      
      public function showEODOverlayFeatureEnd() : void
      {
         if(m_endFeatureDayMc)
         {
            m_endFeatureDayMc.visible = true;
            this.m_endFeatureDay_bt.text = "Awesome!";
            this.m_endFeatureDay_bt.visible = true;
         }
      }
      
      public function showDuplicateOrderOverlay() : void
      {
         if(this.m_duplicateMc)
         {
            this.m_duplicateMc.visible = true;
            m_duplicateOrderBt.text = "Okay!";
            m_duplicateOrderBt.visible = true;
         }
      }
      
      public function displayWeekStartMessage() : void
      {
         var weekcount:int = 0;
         if(this.m_newWeekMc)
         {
            this.m_newWeekMc.visible = true;
            weekcount = this.manager.weekCountAtStart;
            if(this.m_startNewWeek_bt)
            {
               this.m_startNewWeek_bt.visible = true;
               this.m_startNewWeek_bt.text = "Let\'s go!";
            }
            if(this.m_startweek_name_tf)
            {
               this.m_startweek_name_tf.visible = true;
               this.m_startweek_name_tf.text = this.manager.stationNameAtWeekStart;
            }
            if(this.m_startWeekIconMc)
            {
               this.m_startWeekIconMc.visible = true;
               if(this.m_StationWeekMC_Array)
               {
                  this.m_StationWeekMC_Array[weekcount].visible = true;
               }
            }
         }
         StatsManager.count(this.m_featureName,"Week End","Refresh",null,this.manager.getOrderboardProgress().toString(),this.manager.getDayPoints().toString());
      }
      
      public function showEODOverlay2() : void
      {
         if(this.m_endDayMc)
         {
            this.m_endDayMc.visible = true;
            this.m_endDayBt.text = "Awesome!";
            this.m_endDayBt.visible = true;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.manager.mainWindow = null;
         super.close();
         FarmStatsManager.count("RussiaInnovation","Main_UI","close_window");
      }
   }
}

