package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Display.HUD.HUD;
   import Managers.Dec19InnovationManager;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Dec19InnovationLeaderboardSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class Dec19InnovationLeaderboardWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "Dec19InnovationService";
      
      private static const VAL_GLOBAL_LEADERBOARD:String = "globalLeaderboardData";
      
      private static const VAL_PREVIOUS_LEADERBOARD:String = "previousLeaderboardData";
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_timer_mc:MovieClip;
      
      private var m_rewards_mc:MovieClip;
      
      private var m_Reward_mc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      protected var m_highlightbgMc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "Dec19Innovation";
      
      private var m_playerRank:Number;
      
      private var m_leaderboards:Vector.<Dec19InnovationLeaderboardSlotFrame> = new Vector.<Dec19InnovationLeaderboardSlotFrame>();
      
      private const LEADERBOARD_WELCOME_SEEN_FLAG:String = "Dec19_Leaderboard_Reward_Welcome_flag";
      
      private const LAST_DAY_WEEK:String = "Dec19_last_Day_Of_Week";
      
      private const LeagueTextArray:Array = ["BRONZE","SILVER","GOLD","DIAMOND"];
      
      private const LeaguePointsArray:Array = ["15","15","15","40"];
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_weekTf:ZwTextField;
      
      private var m_weekRewardTf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_weekCount:int = 0;
      
      private var m_weekMc:MovieClip;
      
      private var m_showGift:Boolean;
      
      private var m_showCommunity:Boolean = false;
      
      private var m_messageTf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private const MAX_NO_OF_REWARDS:Number = 5;
      
      private const NO_OF_WEEKS:int = 6;
      
      private var m_result:Object;
      
      private var m_nextIconMc:FarmIcon;
      
      private var m_nextMc:MovieClip;
      
      private var m_nextBt:FarmAnimatedTextButton;
      
      private var m_leagues_mc:MovieClip;
      
      private var m_weeklyLeagueArray_mc:Array;
      
      private var m_weeklyLeagueTipArray_mc:Array;
      
      private var m_idle4AniMc:MovieClip;
      
      private var m_idle3AniMc:MovieClip;
      
      private var m_idle2AniMc:MovieClip;
      
      private var m_idle1AniMc:MovieClip;
      
      private var m_leagueTf:ZwTextField;
      
      private var m_leagueLockMc:MovieClip;
      
      private var m_leagueInfoBt:FarmAnimatedTextButton;
      
      private var m_overlayMc:MovieClip;
      
      private var m_leagueHead_tf:ZwTextField;
      
      private var m_nextUpgrade_tf:ZwTextField;
      
      private var m_nextIconhitWidget:ZwFrame;
      
      private var m_weeklyLeagueHitWidget_Array:Array = [];
      
      private var m_reward_bg_mc:MovieClip;
      
      private var m_league_bg_mc:MovieClip;
      
      private var m_leagueLock1Mc:MovieClip;
      
      public function Dec19InnovationLeaderboardWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null, showGift:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         this.m_showGift = showGift;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var leagueText:String = null;
         var timeLeftInWeek:Number = NaN;
         var i:int = 0;
         var j:int = 0;
         var leaderBoardData:Object = null;
         var weekCount:int = 0;
         var weekText:String = null;
         var leaderboard:Dec19InnovationLeaderboardSlotFrame = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"League Of Elves!"));
         }
         if(m_window.hasOwnProperty("next_mc"))
         {
            this.m_nextMc = m_window.next_mc as MovieClip;
            if(this.m_nextMc.hasOwnProperty("icon_mc"))
            {
               this.m_nextIconMc = new FarmIcon(this.m_nextMc.icon_mc);
               if(this.manager.hasFeatureExpired() == false)
               {
                  this.m_nextIconMc.loadIcon(this.manager.getNextLeagueRewardItem().iconUrl);
               }
               this.m_nextIconMc.visible = true;
            }
            if(this.m_nextMc.hasOwnProperty("view_bt"))
            {
               addWidget(this.m_nextBt = new FarmAnimatedTextButton(this.m_nextMc.view_bt,"See Rewards",this.manager.showLeaderboardRewardUI));
               this.m_nextBt.visible = true;
            }
            if(this.m_nextMc.hasOwnProperty("hit_area_mc"))
            {
               this.m_nextIconhitWidget = new ZwFrame(this.m_nextMc["hit_area_mc"]);
               leagueText = "These awesome rewards can be yours if you be among the top " + this.LeaguePointsArray[this.manager.getNextLeague()] + " before the week ends.";
               this.m_nextIconhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("League Rewards!",leagueText));
               this.m_nextIconhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
            this.m_nextMc.visible = !this.m_showGift;
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("idle1_ani_mc"))
         {
            this.m_idle1AniMc = m_window.idle1_ani_mc as MovieClip;
            this.m_idle1AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("idle2_ani_mc"))
         {
            this.m_idle2AniMc = m_window.idle2_ani_mc as MovieClip;
            this.m_idle2AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("idle3_ani_mc"))
         {
            this.m_idle3AniMc = m_window.idle3_ani_mc as MovieClip;
            this.m_idle3AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("idle4_ani_mc"))
         {
            this.m_idle4AniMc = m_window.idle4_ani_mc as MovieClip;
            this.m_idle4AniMc.visible = false;
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Leaderboard of Elves!","Daily meter points add to the Leaderboard score. Rank up after reaching Champion milestone and get promoted.");
         }
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timer_mc = m_window["timer_mc"] as MovieClip;
            this.m_timer_mc.visible = true;
            if(this.m_timer_mc.hasOwnProperty("timer_tf"))
            {
               addWidget(this.m_timer_tf = new ZwTextField(this.m_timer_mc["timer_tf"]));
               timeLeftInWeek = this.manager.getTimeLeftInWeek();
               if(timeLeftInWeek == -1)
               {
                  this.m_timer_mc.visible = false;
               }
               else
               {
                  this.m_timer_tf.text = HUD.getformattedTimeLeft(timeLeftInWeek) + " remaining";
               }
            }
         }
         if(m_window.hasOwnProperty("leagues_mc"))
         {
            this.m_leagues_mc = m_window["leagues_mc"] as MovieClip;
            this.m_leagues_mc.visible = true;
            this.m_weeklyLeagueArray_mc = [];
            this.m_weeklyLeagueTipArray_mc = [];
            for(i = 0; i < 4; i++)
            {
               this.m_weeklyLeagueArray_mc[i] = this.m_leagues_mc["league" + (i + 1).toString() + "_mc"] as MovieClip;
               this.m_weeklyLeagueTipArray_mc[i] = new ZwFrame(this.m_weeklyLeagueArray_mc[i]);
               this.m_weeklyLeagueArray_mc[i].visible = true;
            }
            for(j = 0; j < 4; j++)
            {
               this.m_weeklyLeagueHitWidget_Array[j] = new ZwFrame(this.m_leagues_mc["hit_area" + (j + 1).toString() + "_mc"]);
               this.m_weeklyLeagueHitWidget_Array[j].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(this.getLeagueHoverTitleText(j),this.getLeagueHoverSubtext(j)));
               this.m_weeklyLeagueHitWidget_Array[j].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
            if(this.m_leagues_mc.hasOwnProperty("info_bt"))
            {
               addWidget(this.m_leagueInfoBt = new FarmAnimatedTextButton(this.m_leagues_mc.info_bt,"Know More",this.manager.showLeagueInfoUI));
               if(this.m_showGift)
               {
                  this.m_leagueInfoBt.visible = false;
               }
               else
               {
                  this.m_leagueInfoBt.visible = true;
               }
            }
            if(this.m_leagues_mc.hasOwnProperty("lock_mc"))
            {
               this.m_leagueLockMc = this.m_leagues_mc["lock_mc"] as MovieClip;
               this.m_leagueLockMc.visible = this.manager.getCurrentLeague() == 0;
            }
            if(this.m_leagues_mc.hasOwnProperty("lock1_mc"))
            {
               this.m_leagueLock1Mc = this.m_leagues_mc["lock1_mc"] as MovieClip;
               this.m_leagueLock1Mc.visible = this.manager.getCurrentLeague() < 2;
            }
            this.updateLeagueButtons();
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            if(this.manager.getOverlaySeenFlag() == false && !this.m_showGift && this.manager.isFeatureInActivePeriod())
            {
               this.m_overlayMc = m_window["overlay_mc"] as MovieClip;
               this.m_overlayMc.visible = true;
            }
         }
         if(this.m_weekMc)
         {
            this.m_weekMc.visible = false;
         }
         if(this.m_weekCount == 0)
         {
            leaderBoardData = this.manager.getCurrentLeaderboard();
            if(leaderBoardData)
            {
               this.m_weekCount = leaderBoardData.count;
               weekCount = this.m_weekCount;
               if(this.m_showGift)
               {
                  this.m_weekCount = int(this.manager.getActiveWeek());
               }
            }
            else
            {
               this.m_weekCount = this.NO_OF_WEEKS;
            }
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],this.getSubtitleText()));
         }
         if(m_window.hasOwnProperty("rewards_mc"))
         {
            this.m_rewards_mc = m_window["rewards_mc"] as MovieClip;
            this.m_rewards_mc.visible = true;
            if(this.m_rewards_mc.hasOwnProperty("Reward_mc"))
            {
               this.m_Reward_mc = this.m_rewards_mc.Reward_mc;
               this.m_Reward_mc.gotoAndStop(this.m_weekCount);
            }
            if(this.m_rewards_mc.hasOwnProperty("rewardBG_mc"))
            {
               this.m_reward_bg_mc = this.m_rewards_mc["rewardBG_mc"] as MovieClip;
               this.m_reward_bg_mc.visible = true;
               this.m_reward_bg_mc.gotoAndStop(this.manager.getCurrentLeague() + 1);
            }
            if(this.m_rewards_mc.hasOwnProperty("week_tf"))
            {
               weekText = "Weekly Rewards";
               addWidget(this.m_weekTf = new ZwTextField(this.m_rewards_mc["week_tf"],weekText));
            }
         }
         if(m_window.hasOwnProperty("leagueBG_mc"))
         {
            this.m_league_bg_mc = m_window["leagueBG_mc"] as MovieClip;
            this.m_league_bg_mc.visible = false;
            this.m_league_bg_mc.gotoAndStop(this.manager.getCurrentLeague() + 1);
         }
         if(m_window.hasOwnProperty("leaderboard_mc"))
         {
            this.m_leaderboard_mc = m_window["leaderboard_mc"] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            leaderboard = new Dec19InnovationLeaderboardSlotFrame(this.m_leaderboard_mc,null,this.m_featureName,this);
            this.m_leaderboards.push(leaderboard);
            addWidget(leaderboard,true);
            if(this.m_leaderboard_mc.hasOwnProperty("message_tf"))
            {
               addWidget(this.m_messageTf = new ZwTextField(this.m_leaderboard_mc["message_tf"]));
               this.m_messageTf.visible = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("league_tf"))
            {
               addWidget(this.m_leagueTf = new ZwTextField(this.m_leaderboard_mc["league_tf"],this.manager.getCurrentLeagueName() + " Leaderboard!"));
               this.m_leagueTf.visible = true;
            }
            if(this.m_leaderboard_mc.mc_highlightbg != null)
            {
               this.m_highlightbgMc = this.m_leaderboard_mc.mc_highlightbg;
               this.m_highlightbgMc.visible = false;
            }
         }
         if(this.m_leaderboard_mc.hasOwnProperty("loader_mc"))
         {
            this.m_loader_mc = this.m_leaderboard_mc["loader_mc"] as MovieClip;
            this.m_loader_mc.visible = true;
         }
         if(this.manager.getWeeklyLeaderboardPoints() > 0)
         {
            this.manager.initializeLeaderBoardProgress();
         }
         else
         {
            this.m_loader_mc.visible = false;
            this.m_messageTf.visible = true;
            this.m_messageTf.text = "Redeem a completed task from your orders to be a part of this Leaderboard and win exciting prizes!";
         }
         if(this.manager.checkLastDayInWeek() <= 1 && Global.player.getSeenFlag(this.LAST_DAY_WEEK) == false && this.manager.getTimeLeftInWeek() != -1 && this.manager.hasFeatureExpired() == false)
         {
            if(this.isLastDayOfFeature())
            {
               this.showAutoHideNPCCallouts("Tick Tock...","Time is almost up! Collect as many points as you can! Competition ends in " + HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()));
            }
            else
            {
               this.showAutoHideNPCCallouts("Tick Tock...","Time is almost up! Collect points to win awesome rewards! Leaderboard refreshes in " + HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()));
            }
            Global.player.setSeenFlag(this.LAST_DAY_WEEK);
         }
         if(this.m_showGift)
         {
            this.m_timer_mc.visible = false;
         }
         this.startTimer();
         this.showIdleNPCForCurrentLeague();
      }
      
      private function showIdleNPCForCurrentLeague() : void
      {
         var npcs:Array = [this.m_idle1AniMc,this.m_idle2AniMc,this.m_idle3AniMc,this.m_idle4AniMc];
         var league:int = this.manager.getCurrentLeague();
         if(npcs[league])
         {
            npcs[league].visible = true;
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_messageTf.visible == false)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function getSubtitleText() : String
      {
         var league:int = this.manager.getCurrentLeague();
         var msg:String = "Be among the top {0} in weekly leaderboard to get promoted to the {1} League by the end of week" + this.m_weekCount.toString() + "!";
         if(!this.m_showGift)
         {
            if(league == 0 || league == 1 || league == 2)
            {
               return StringUtil.substitute(msg,this.manager.LEAGUE_UPGRADE_MAP[league],this.manager.DEC19_LEAGUE_MAP[league + 1]);
            }
            if(league == 3)
            {
               msg = "Be among the top 40 in weekly leaderboard to stay in the Diamond League by the end of week" + this.m_weekCount.toString() + "!";
            }
         }
         else
         {
            msg = "Check your leaderboard rank in week " + this.manager.getActiveWeek() + "!";
         }
         return msg;
      }
      
      private function isLastDayOfFeature() : Boolean
      {
         var dayIndex:int = this.manager.currentDayIndex;
         var totalDays:int = this.NO_OF_WEEKS * 7;
         return dayIndex == totalDays - 1;
      }
      
      private function getLeagueHoverTitleText(i:int) : String
      {
         return this.manager.getLeagueName(i) + " League!";
      }
      
      private function getLeagueHoverSubtext(i:int) : String
      {
         var league:int = this.manager.getCurrentLeague();
         var msg:String = "";
         switch(league)
         {
            case 0:
               if(i == 0)
               {
                  msg = "You are in the Bronze League! Keep ranking up to get promoted to the Silver League at the end of the week!";
               }
               else if(i == 1)
               {
                  msg = "Be among the top 15 in the weekly leaderboard to reach in the Silver League by the end of the week.";
               }
               else if(i == 2)
               {
                  msg = "To unlock the Gold League, reach the Silver League first!";
               }
               else if(i == 3)
               {
                  msg = "To unlock the Diamond League, reach the Gold League first!";
               }
               break;
            case 1:
               if(i == 0)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 1)
               {
                  msg = "You are in the Silver League! Keep ranking up to get promoted to the Gold League at the end of the week!";
               }
               else if(i == 2)
               {
                  msg = "Be among the top 15 in the weekly leaderboard to reach in the Gold League by the end of the week.";
               }
               else if(i == 3)
               {
                  msg = "To unlock the Diamond League, reach the Gold League first!";
               }
               break;
            case 2:
               if(i == 0)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 1)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 2)
               {
                  msg = "You are in the Gold League! Keep ranking up to get promoted to the Diamond League at the end of the week!";
               }
               else if(i == 3)
               {
                  msg = "Be among the top 15 in the weekly leaderboard to reach in the Diamond League by the end of the week.";
               }
               break;
            case 3:
               if(i == 0)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 1)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 2)
               {
                  msg = "You have already crossed this League. Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
               else if(i == 3)
               {
                  msg = "You are in the Diamond League! Be among the top 40 in the weekly leaderboard to avoid getting demoted.";
               }
         }
         return msg;
      }
      
      private function showgift() : void
      {
         this.m_rewards_mc.visible = false;
         var weekMc:String = "week" + this.m_weekCount.toString() + "_mc";
         this.m_weekMc = m_window[weekMc];
         this.m_weekMc.visible = true;
         if(this.m_league_bg_mc)
         {
            this.m_league_bg_mc.visible = true;
         }
         var giftFrame:Number = this.getGiftFrameNumber(this.m_playerRank);
         this.m_weekMc.gotoAndStop(giftFrame);
         if(this.m_weekMc.hasOwnProperty("title_tf"))
         {
            this.m_weekRewardTf = new ZwTextField(this.m_weekMc["title_tf"],"You have won these rewards!");
            this.m_weekRewardTf.visible = true;
         }
         var no_of_rewards:Number = this.getRewardCountForPlayer(this.m_playerRank);
         var calloutText:String = "In Week " + this.m_weekCount.toString() + " Leaderboard, your position is " + this.m_playerRank.toString() + ". You have won " + no_of_rewards.toString() + (no_of_rewards == 1 ? " Reward" : " Rewards");
         this.showNPCCallouts("Leaderboard Results",calloutText);
         if(Global.player.getSeenFlag(this.LAST_DAY_WEEK))
         {
            Global.player.resetSeenFlag(this.LAST_DAY_WEEK);
         }
         this.m_highlightbgMc.visible = false;
      }
      
      private function getRewardCountForPlayer(playerRank:Number) : Number
      {
         var result:Number = 1;
         if(playerRank == 1)
         {
            result = 5;
         }
         else if(playerRank == 2)
         {
            result = 4;
         }
         else if(playerRank == 3)
         {
            result = 3;
         }
         else if(playerRank < 11)
         {
            result = 2;
         }
         else if(playerRank < 21)
         {
            result = 2;
         }
         else
         {
            result = 1;
         }
         return result;
      }
      
      private function getGiftFrameNumber(playerRank:Number) : Number
      {
         var result:Number = 6;
         if(playerRank == 1)
         {
            result = 1;
         }
         else if(playerRank == 2)
         {
            result = 2;
         }
         else if(playerRank == 3)
         {
            result = 3;
         }
         else if(playerRank < 11)
         {
            result = 4;
         }
         else if(playerRank < 21)
         {
            result = 5;
         }
         else
         {
            result = 6;
         }
         return result;
      }
      
      public function populateLeaderboard(result:Object, giftLeaderboardRank:Number, giftLeaderboardName:String) : void
      {
         var finished:Boolean = false;
         var winner:Boolean = false;
         var userData:Object = null;
         var leaderboardData:Object = null;
         if(result)
         {
            this.m_result = result;
            if(this.m_showGift && Boolean(giftLeaderboardRank))
            {
               result = result.previousLeaderboardData;
               this.m_playerRank = giftLeaderboardRank;
            }
            if(!this.m_showGift && Boolean(result["userData"]))
            {
               userData = result["userData"];
               this.m_playerRank = userData.rank;
            }
            if(this.m_playerRank > 4)
            {
               this.m_highlightbgMc.visible = true;
            }
            finished = TimedSlotGiveawaysManager.isDisabled(this.m_featureName);
            winner = false;
            if(finished)
            {
               winner = this.conditionallyAwardLeaderboarGift(result);
            }
            if(this.m_leaderboards)
            {
               leaderboardData = null;
               if(this.m_showGift)
               {
                  leaderboardData = this.m_result[VAL_GLOBAL_LEADERBOARD];
               }
               else
               {
                  leaderboardData = result[VAL_GLOBAL_LEADERBOARD];
               }
               this.m_leaderboards[0].finishLoading(leaderboardData,false,winner);
            }
            if(Boolean(this.m_showGift) && Boolean(giftLeaderboardRank) && Boolean(giftLeaderboardName))
            {
               this.showgift();
            }
            if(this.m_messageTf != null)
            {
               this.m_messageTf.visible = false;
            }
            if(this.m_timer)
            {
               this.stopTimer();
            }
         }
         m_closeButton.visible = true;
         this.m_loader_mc.visible = false;
      }
      
      private function conditionallyAwardLeaderboarGift(leaderboardData:Object) : Boolean
      {
         var globalLeaderboardData:Object = null;
         var globalLeadersSlotData:Array = null;
         var data:Object = null;
         var winner:Boolean = false;
         if(leaderboardData[VAL_GLOBAL_LEADERBOARD])
         {
            globalLeaderboardData = leaderboardData[VAL_GLOBAL_LEADERBOARD];
            if(globalLeaderboardData.slotData is Array)
            {
               globalLeadersSlotData = globalLeaderboardData.slotData as Array;
               if(globalLeadersSlotData)
               {
                  for each(data in globalLeadersSlotData)
                  {
                     if(Boolean(data.rank) && data.uid == String(Global.player.uid))
                     {
                        TimedSlotGiveawaysManager.awardLeaderboardGift(this.m_featureName,data.rank);
                        winner = true;
                        break;
                     }
                  }
               }
            }
         }
         return winner;
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         else if(this.m_showGift)
         {
            this.manager.showMainUI();
         }
         this.hideNPCCallout();
         this.stopTimer();
         this.manager.leaderboardCallback();
         super.close();
      }
      
      private function get manager() : Dec19InnovationManager
      {
         return Dec19InnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
      }
      
      public function onMouseOver(title:String = "", text:String = "") : Function
      {
         return function(evt:MouseEvent):void
         {
            if(manager.hasFeatureExpired() == false)
            {
               showNPCCallouts(title,text);
            }
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(manager.hasFeatureExpired() == false)
            {
               hideNPCCallout();
            }
         };
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
      }
      
      public function updateOverlay() : void
      {
         if(this.m_overlayMc)
         {
            this.m_overlayMc.visible = false;
         }
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(20000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
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
      
      private function updateLeagueButtons() : void
      {
         var i:int = 0;
         if(this.m_weeklyLeagueArray_mc)
         {
            for(i = 0; i < 4; i++)
            {
               if(i == this.manager.getCurrentLeague())
               {
                  this.m_weeklyLeagueArray_mc[i].gotoAndStop(2);
               }
               else
               {
                  this.m_weeklyLeagueArray_mc[i].gotoAndStop(1);
               }
            }
         }
      }
      
      public function updateLeagueCriteriaTooltip() : void
      {
         var i:int = 0;
         if(this.m_weeklyLeagueTipArray_mc)
         {
            for(i = 1; i < 4; i++)
            {
               if(this.m_weeklyLeagueTipArray_mc[i])
               {
                  if(this.m_weeklyLeagueTipArray_mc[i].tooltip)
                  {
                     this.m_weeklyLeagueTipArray_mc[i].tooltip.release();
                  }
                  this.m_weeklyLeagueTipArray_mc[i].detachTooltip();
                  this.m_weeklyLeagueTipArray_mc[i].attachTooltip(new FarmTextTooltip(this.manager.getLeagueName(i) + " League: Be in top " + this.LeaguePointsArray[i]));
               }
            }
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         m_closeButton.visible = true;
      }
   }
}

