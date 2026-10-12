package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunV5QuestWorldFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class FarmRunV5MainWindow extends GenericOrderBoardWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const METER_MC:String = "meter_mc";
      
      private static const POINTS_MC:String = "points_mc";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const POINTS_TF:String = "points_tf";
      
      private static const BAR_FULL_WIDTH:int = 1000;
      
      private static const POINTER_BAR_FULL_WIDTH:int = 800;
      
      private static const MAX_POINT_PROGRESS:int = 1000;
      
      private static const MAX_POINT_POINTER:int = 1000;
      
      private static const BAR_INITIAL_POSTION:Number = 0;
      
      private var m_featureName:String = null;
      
      public var m_meter_mc:MovieClip;
      
      public var m_points_mc:MovieClip;
      
      private var m_bonus_mc:FarmAnimatedButton;
      
      private var m_talkMc:MovieClip;
      
      private var m_npcMc:MovieClip;
      
      private var m_talk_tf:ZwTextField;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_body2Tf:ZwTextField;
      
      public var points_tf:ZwTextField;
      
      private var m_world1_mc:MovieClip;
      
      private var m_world2_mc:MovieClip;
      
      private var m_world3_mc:MovieClip;
      
      private var m_world4_mc:MovieClip;
      
      private var m_worldRewardButton:Array = [];
      
      private var m_worldRewardMC:Array = [];
      
      private var m_worldRewardTooltip:Array = [];
      
      private var m_bonusRewardToolTip:FarmTextTooltip;
      
      private const WORLD_REWARD_MC_ARRAY:Array = ["world1reward_mc","world2reward_mc","world3reward_mc","world4reward_mc"];
      
      private const WORLD_REWARD_POINTS_ARRAY:Array = [200,425,700,1000];
      
      private const WORLD_REWARD_NAMES_ARRAY:Array = ["pegasus_paleolithic","pegasus_adventurer","horse_ember","horse_fairyland"];
      
      private var m_timer:Timer;
      
      private var m_timerMc:MovieClip;
      
      private var m_timerTf:ZwTextField;
      
      private var m_farmRunWorldsSlotFrame:FarmRunV5QuestWorldFrame;
      
      public function FarmRunV5MainWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(featureName,assetURL,this.manager);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         var reward:FarmItem = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],"FARM RUN"));
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            this.m_descriptionTf = addWidget(new ZwTextField(m_window[BODY_TF],"Play across 4 old favorite farms. Finish tasks and play a mini game to win cool rewards!")) as ZwTextField;
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            this.m_body2Tf = addWidget(new ZwTextField(m_window["body2_tf"],"The first leg of the Farm Run begins in Caveman Club!")) as ZwTextField;
            this.m_body2Tf.visible = true;
         }
         this.refreshText();
         if(m_window.hasOwnProperty("world1_mc"))
         {
            this.m_world1_mc = m_window["world1_mc"] as MovieClip;
            this.m_world1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world2_mc"))
         {
            this.m_world2_mc = m_window["world2_mc"] as MovieClip;
            this.m_world2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world3_mc"))
         {
            this.m_world3_mc = m_window["world3_mc"] as MovieClip;
            this.m_world3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world4_mc"))
         {
            this.m_world4_mc = m_window["world4_mc"] as MovieClip;
            this.m_world4_mc.visible = false;
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_farmRunWorldsSlotFrame = new FarmRunV5QuestWorldFrame(m_window["slots_mc"],this,this.m_featureName);
            this.m_farmRunWorldsSlotFrame.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
            {
               addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
               this.m_talk_tf.visible = true;
            }
            this.m_talkMc.visible = false;
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = false;
         }
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timerMc = m_window.timer_mc as MovieClip;
            if(this.m_timerMc.hasOwnProperty(TIMER_TF))
            {
               addWidget(this.m_timerTf = new ZwTextField(this.m_timerMc[TIMER_TF],this.getTimeLeft()));
            }
            this.m_timerMc.visible = true;
         }
         for(var rewardIndex:int = 0; rewardIndex < 4; rewardIndex++)
         {
            rewardName = this.WORLD_REWARD_NAMES_ARRAY[rewardIndex];
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
            this.m_worldRewardMC[rewardIndex] = m_window[this.WORLD_REWARD_MC_ARRAY[rewardIndex]] as MovieClip;
            this.m_worldRewardMC[rewardIndex].visible = true;
            this.m_worldRewardMC[rewardIndex].enabled = true;
            this.m_worldRewardMC[rewardIndex].play();
            this.m_worldRewardButton[rewardIndex] = new FarmIcon(m_window[this.WORLD_REWARD_MC_ARRAY[rewardIndex]] as MovieClip) as FarmIcon;
            this.m_worldRewardButton[rewardIndex].attachTooltip(this.m_worldRewardTooltip[rewardIndex] = new FarmTextTooltip("Score " + this.WORLD_REWARD_POINTS_ARRAY[rewardIndex] + " points and win " + rewardItem.friendlyTitle)) as FarmTextTooltip;
            this.m_worldRewardButton[rewardIndex].visible = true;
         }
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            reward = Global.farmGameSettingsManager.getFarmItemByName("pegacorn_mapmaker");
            addWidget(this.m_bonus_mc = new FarmAnimatedButton(m_window["bonus_mc"]),true);
            this.m_bonus_mc.attachTooltip(this.m_bonusRewardToolTip = new FarmTextTooltip("Complete FarmRun and win " + reward.friendlyTitle));
         }
         if(m_window.hasOwnProperty(POINTS_MC))
         {
            this.m_points_mc = m_window[POINTS_MC];
            this.m_points_mc.visible = true;
            if(Boolean(this.m_points_mc) && this.m_points_mc.hasOwnProperty("points_tf"))
            {
               addWidget(this.points_tf = new ZwTextField(this.m_points_mc["points_tf"]));
               this.points_tf.visible = true;
               this.points_tf.text = this.manager.getFeatureProgress().toString();
            }
         }
         if(m_window.hasOwnProperty(METER_MC))
         {
            this.m_meter_mc = m_window[METER_MC];
            this.initializeMeterMC(this.m_meter_mc);
            this.updateProgressBar(this.manager.getFeatureProgress(),this.m_meter_mc);
         }
         this.startTimer();
         this.refreshWindow();
         this.displayNPC();
      }
      
      public function updatePoints() : void
      {
         if(Boolean(m_window) && Boolean(this.points_tf))
         {
            this.points_tf.text = this.manager.getFeatureProgress().toString();
            this.points_tf.visible = true;
         }
      }
      
      public function refreshText() : void
      {
         var worldName:String = this.manager.getFarmrunWorldFromPoints();
         var worldFriendlyName:String = Global.worldManager.getWorldFriendlyName(worldName);
         if(this.manager.getworldIndexFromName(worldName) > 0)
         {
            this.m_body2Tf.text = "This stage of the Farm Run plays out in " + worldFriendlyName;
         }
         if(this.manager.getFeatureProgress() >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
         {
            this.m_descriptionTf.text = "Congratulations! You have finished the Farm Run!";
            this.m_body2Tf.text = "";
         }
         if(Global.worldManager.currentWorldType != this.manager.getFarmrunWorldFromPoints())
         {
            this.m_body2Tf.text = "Travel to the new world to move ahead in Farm Run!";
         }
      }
      
      public function highlightWorldMc(slotIndex:int) : void
      {
         var worldElement:String = "world" + (slotIndex + 1) + "_mc";
         if(m_window.hasOwnProperty(worldElement))
         {
            m_window[worldElement].visible = true;
         }
      }
      
      public function dimWorldMc(slotIndex:int) : void
      {
         var worldElement:String = "world" + (slotIndex + 1) + "_mc";
         if(m_window.hasOwnProperty(worldElement))
         {
            m_window[worldElement].visible = false;
         }
      }
      
      public function updatePointerPosition(percentValue:Number, meter_mc:MovieClip) : void
      {
         var barWidth:Number = NaN;
         if(meter_mc.hasOwnProperty("points_tf"))
         {
            meter_mc.points_tf.text = percentValue;
            barWidth = percentValue * POINTER_BAR_FULL_WIDTH / MAX_POINT_PROGRESS;
            meter_mc.x = BAR_INITIAL_POSTION + barWidth;
            meter_mc.visible = true;
         }
      }
      
      private function initializeMeterMC(meter_mc:MovieClip) : void
      {
         if(meter_mc)
         {
            meter_mc.visible = true;
            this.updateProgressBar(0,meter_mc);
            if(meter_mc[POINTS_TF])
            {
               (meter_mc[POINTS_TF] as TextField).visible = true;
               (meter_mc[POINTS_TF] as TextField).text = "000";
            }
         }
      }
      
      public function updateProgressBar(percentValue:Number, meter_mc:MovieClip) : void
      {
         if(this.m_points_mc)
         {
            if(percentValue > MAX_POINT_POINTER)
            {
               percentValue = MAX_POINT_POINTER;
            }
            this.updatePointerPosition(percentValue,this.m_points_mc);
         }
         if(percentValue > MAX_POINT_PROGRESS)
         {
            percentValue = MAX_POINT_PROGRESS;
         }
         var barWidth:Number = percentValue * BAR_FULL_WIDTH / MAX_POINT_PROGRESS;
         if(Boolean(meter_mc) && Boolean(meter_mc["bar_fill_mc"]))
         {
            if(percentValue == 0)
            {
               (meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
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
      
      override public function refreshWindow() : void
      {
         var progress:Number = this.manager.getFeatureProgress();
         if(progress > 0 && Boolean(this.m_meter_mc))
         {
            this.updatePoints();
            this.updateProgressBar(progress,this.m_meter_mc);
         }
         this.refreshText();
         this.refreshWorldRewardTooltip();
         this.m_farmRunWorldsSlotFrame.refresh();
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
      }
      
      public function refreshWorldRewardTooltip() : void
      {
         var rewardItem:FarmItem = null;
         var score:int = this.manager.getFeatureProgress();
         if(Boolean(score > 0) && Boolean(this.m_worldRewardTooltip) && this.m_worldRewardTooltip.length == 4)
         {
            if(score >= FarmRunV5Manager.VAL_FIRST_MILESTONE)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.WORLD_REWARD_NAMES_ARRAY[0]);
               this.m_worldRewardTooltip[0].setText("You\'ve won a " + rewardItem.friendlyTitle + "!");
            }
            if(score >= FarmRunV5Manager.VAL_SECOND_MILESTONE)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.WORLD_REWARD_NAMES_ARRAY[1]);
               this.m_worldRewardTooltip[1].setText("You\'ve won a " + rewardItem.friendlyTitle + "!");
            }
            if(score >= FarmRunV5Manager.VAL_THIRD_MILESTONE)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.WORLD_REWARD_NAMES_ARRAY[2]);
               this.m_worldRewardTooltip[2].setText("You\'ve won a " + rewardItem.friendlyTitle + "!");
            }
            if(score >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.WORLD_REWARD_NAMES_ARRAY[3]);
               this.m_worldRewardTooltip[3].setText("You\'ve won a " + rewardItem.friendlyTitle + "!");
               this.m_bonusRewardToolTip.setText("You\'ve won a " + Global.farmGameSettingsManager.getFarmItemByName("pegacorn_mapmaker").friendlyTitle + "!");
            }
         }
      }
      
      public function displayNPC() : void
      {
         if(this.m_npcMc)
         {
            this.m_npcMc.visible = Global.worldManager.currentWorldType != this.manager.getFarmrunWorldFromPoints() || this.manager.getFeatureProgress() >= FarmRunV5Manager.VAL_FINAL_MILESTONE;
         }
         if(Global.worldManager.currentWorldType != this.manager.getFarmrunWorldFromPoints())
         {
            if(this.m_talkMc != null)
            {
               this.m_talkMc.visible = true;
               if(this.m_talk_tf)
               {
                  this.m_talk_tf.text = "The next stage of the Farm Run plays out in " + Global.worldManager.getWorldFriendlyName(this.manager.getFarmrunWorldFromPoints());
               }
            }
         }
         else if(this.m_talkMc)
         {
            this.m_talkMc.visible = false;
         }
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      public function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(Boolean(m_window) && Boolean(this.m_timerTf))
         {
            this.m_timerTf.text = this.getTimeLeft();
            this.m_timerTf.visible = true;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         super.close();
      }
   }
}

