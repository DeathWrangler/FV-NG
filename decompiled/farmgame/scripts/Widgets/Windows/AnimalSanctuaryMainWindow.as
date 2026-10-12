package Widgets.Windows
{
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AnimalSanctuaryMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      private static const PROGRESS_BAR_FULL_WIDTH:Number = 156;
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_animal_name_array:Array = ["animal0_mc","animal1_mc","animal2_mc","animal3_mc"];
      
      private var m_animal_mc_array:Array = [];
      
      private var m_animal_tick_mc_array:Array = [];
      
      private var m_animal_highlight_mc_array:Array = [];
      
      private var m_animal_name_tf_array:Array = [];
      
      private var m_task_name_array:Array = ["task0_mc","task1_mc","task2_mc"];
      
      private var m_task_mc_array:Array = [];
      
      private var m_task_name_tf_array:Array = [];
      
      private var m_task_body_tf_array:Array = [];
      
      private var m_task_sink_bt_array:Array = [];
      
      private var m_states_name_array:Array = ["states1_mc","states2_mc","states3_mc","states4_mc","states5_mc"];
      
      private var m_states_mc_array:Array = [];
      
      private var m_states_preview_mc_array:Array = [];
      
      private var m_states_active_mc_array:Array = [];
      
      private var m_tutorialButtons:Array = [];
      
      private var m_survey_map_mc:MovieClip;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_stage_tf:ZwTextField;
      
      private var m_sink_bt:FarmAnimatedTextButton;
      
      private var m_talk_auto_mc:MovieClip;
      
      private var m_talk_mc:MovieClip;
      
      private var m_npc1_tf:ZwTextField;
      
      private var m_npc2_tf:ZwTextField;
      
      private var m_hover_name_array:Array = ["hover1_mc","hover2_mc","hover3_mc","hover4_mc"];
      
      private var m_hover_mc_array:Array = [];
      
      private var m_overlay_mc:MovieClip;
      
      private var m_overlay_tf:ZwTextField;
      
      private var m_travel_bt:FarmAnimatedTextButton;
      
      private var m_coupon1_mc:MovieClip;
      
      private var m_earn_bt:FarmAnimatedTextButton;
      
      private var m_resource_name_array:Array = ["resource_0_mc","resource_1_mc","resource_2_mc"];
      
      private var m_resource_mc_array:Array = [];
      
      private var m_resource_icon_mc_array:Array = [];
      
      private var m_resource_caution_mc_array:Array = [];
      
      private var m_resource_caution1_mc_array:Array = [];
      
      public var m_resource_sink_bt_array:Array = [];
      
      private var m_resource_timer_tf_array:Array = [];
      
      private var m_resource_score_needed_tf_array:Array = [];
      
      private var m_resource_score_available_tf_array:Array = [];
      
      private var m_resource_mc_highlight_array:Array = [];
      
      private var m_resource_txt_array:Array = [];
      
      private var m_resource_txt1_array:Array = [];
      
      private var m_resource_hover_mc:Array = [];
      
      private var m_task_hover_name_array:Array = ["hover0_area_mc","hover1_area_mc","hover2_area_mc"];
      
      private var m_task_hover_mc:Array = [];
      
      private var m_resource_progress_mc_array:Array = [];
      
      private var m_resource_progress_fill_mc_array:Array = [];
      
      private var m_world_tick_name_array:Array = ["tick0_mc","tick1_mc","tick2_mc","tick3_mc"];
      
      private var m_world_highlight_mc_name_array:Array = ["highlight0_mc","highlight1_mc","highlight2_mc","highlight3_mc"];
      
      private var m_world_tick_mc_array:Array = [];
      
      private var m_world_highlight_mc_array:Array = [];
      
      private var m_skip_timer:Timer;
      
      private var m_daysLeft_tf:ZwTextField;
      
      private var m_tooltipArray:Array = new Array();
      
      public function AnimalSanctuaryMainWindow(featureName:String, assetPath:String, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(this.m_featureName,assetPath,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var iconurl:String = null;
         var tutorial_mc:MovieClip = null;
         var j:int = 0;
         var buttonName1:String = null;
         var sinkTime:int = 0;
         var text:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Provide food, shelter and medicine to save this sanctuary!"));
         }
         if(m_window.hasOwnProperty("name_tf"))
         {
         }
         if(m_window.hasOwnProperty("stage_tf"))
         {
            this.m_stage_tf = new ZwTextField(m_window["stage_tf"],"Stage " + this.manager.getStageOfAnimal() + "/4");
            this.m_stage_tf.visible = true;
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            this.m_icon_mc = new FarmIcon(m_window["icon_mc"]);
            iconurl = "assets/dialogs/Animal_sanctury_2019/" + this.manager.MILESTONE_FINAL_REWARDS[this.manager.getSelectedAnimalSlot() - 1] + "_" + this.manager.getStageOfAnimal() + "_icon_400.png";
            this.m_icon_mc.loadIcon(iconurl);
            this.m_icon_mc.setIconSize(400,400);
            this.m_icon_mc.visible = true;
         }
         if(m_window.hasOwnProperty("coupon1_mc"))
         {
            this.m_coupon1_mc = m_window["coupon1_mc"] as MovieClip;
            this.m_coupon1_mc.visible = true;
            if(this.m_coupon1_mc.hasOwnProperty("earn_more_bt"))
            {
               addWidget(this.m_earn_bt = new FarmAnimatedTextButton(this.m_coupon1_mc["earn_more_bt"],"Buy More!",this.buyCouponsClick));
            }
         }
         if(m_window.hasOwnProperty("days_tf"))
         {
            addWidget(this.m_daysLeft_tf = new ZwTextField(m_window["days_tf"],this.getFeatureTimeLeft()));
            this.m_daysLeft_tf.visible = true;
         }
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            addWidget(new ZwButton(m_window["whatisthis_bt"],this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talk_auto_mc = m_window["talk_auto_mc"] as MovieClip;
            this.m_talk_auto_mc.visible = false;
            if(this.m_talk_auto_mc.hasOwnProperty("talk_mc"))
            {
               this.m_talk_mc = this.m_talk_auto_mc["talk_mc"] as MovieClip;
               this.m_talk_mc.visible = true;
            }
            if(this.m_talk_mc.hasOwnProperty("npc1_tf"))
            {
               this.m_npc1_tf = new ZwTextField(this.m_talk_mc["npc1_tf"],"");
            }
            if(this.m_talk_mc.hasOwnProperty("npc2_tf"))
            {
               this.m_npc2_tf = new ZwTextField(this.m_talk_mc["npc2_tf"],"");
            }
         }
         if(m_window.hasOwnProperty("sink_bt"))
         {
            addWidget(this.m_sink_bt = new FarmAnimatedTextButton(m_window["sink_bt"],"View!",this.onClickRewardBt));
         }
         this.m_resource_hover_mc = [];
         for(i = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty(this.m_task_hover_name_array[i]))
            {
               this.m_task_hover_mc[i] = new ZwFrame(m_window[this.m_task_hover_name_array[i]]);
               this.m_task_hover_mc[i].visible = true;
               this.m_task_hover_mc[i].attachTooltip(new FarmTextTooltip(this.getHoverTextForTasks(i)));
            }
            if(m_window.hasOwnProperty(this.m_task_name_array[i]))
            {
               this.m_task_mc_array[i] = m_window[this.m_task_name_array[i]] as MovieClip;
               this.m_task_mc_array[i].visible = true;
            }
            if(this.m_task_mc_array[i].hasOwnProperty("name_tf"))
            {
               this.m_task_name_tf_array[i] = new ZwTextField(this.m_task_mc_array[i]["name_tf"],this.manager.VAL_TASK_ARRAY[i]);
            }
            if(!this.m_task_mc_array[i].hasOwnProperty("body_tf"))
            {
            }
            if(this.m_task_mc_array[i].hasOwnProperty("sink_bt"))
            {
               this.m_task_sink_bt_array[i] = new FarmAnimatedTextButton(this.m_task_mc_array[i]["sink_bt"],"Let\'s do it!",this.onSelectTask(this.manager.VAL_TASK_ARRAY[i]));
               this.m_task_sink_bt_array[i].visible = true;
            }
            if(m_window.hasOwnProperty(this.m_resource_name_array[i]))
            {
               this.m_resource_mc_array[i] = m_window[this.m_resource_name_array[i]] as MovieClip;
               this.m_resource_mc_array[i].visible = true;
               if(this.m_resource_mc_array[i].hasOwnProperty("caution1_mc"))
               {
                  this.m_resource_caution1_mc_array[i] = this.m_resource_mc_array[i]["caution1_mc"] as MovieClip;
                  this.m_resource_caution1_mc_array[i].visible = false;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("caution_mc"))
               {
                  this.m_resource_caution_mc_array[i] = this.m_resource_mc_array[i]["caution_mc"] as MovieClip;
                  this.m_resource_caution_mc_array[i].visible = false;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("icon_mc"))
               {
                  this.m_resource_icon_mc_array[i] = this.m_resource_mc_array[i]["icon_mc"] as MovieClip;
                  this.m_resource_icon_mc_array[i].visible = true;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("mc_highlight"))
               {
                  this.m_resource_mc_highlight_array[i] = this.m_resource_mc_array[i]["mc_highlight"] as MovieClip;
                  this.m_resource_mc_highlight_array[i].visible = true;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("sink_bt"))
               {
                  this.m_resource_sink_bt_array[i] = new FarmAnimatedTextButton(this.m_resource_mc_array[i]["sink_bt"],"Use x10",this.onSinkClick(i));
                  this.m_resource_sink_bt_array[i].visible = true;
                  this.m_resource_sink_bt_array[i].enabled = this.manager.isSinkButtonEnabled(i);
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("score_tf"))
               {
                  this.m_resource_score_available_tf_array[i] = new ZwTextField(this.m_resource_mc_array[i]["score_tf"],"x0");
                  this.m_resource_score_available_tf_array[i].visible = true;
                  this.m_resource_score_available_tf_array[i].text = "x" + this.manager.consumableCount(i).toString();
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("score0_tf"))
               {
                  this.m_resource_score_needed_tf_array[i] = new ZwTextField(this.m_resource_mc_array[i]["score0_tf"],"0/100");
                  this.m_resource_score_needed_tf_array[i].visible = true;
                  this.m_resource_score_needed_tf_array[i].text = this.manager.getSinkedCouponCountByType(i).toString() + " / " + this.manager.CONSUMABLE_COUNT_ARRAY[this.manager.getStageOfAnimal()];
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("timer_tf"))
               {
                  this.m_resource_timer_tf_array[i] = new ZwTextField(this.m_resource_mc_array[i]["timer_tf"],"timer");
                  this.m_resource_timer_tf_array[i].visible = false;
                  this.startSinkWaitTime(i);
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("hover_mc"))
               {
                  this.m_resource_hover_mc[i] = new ZwFrame(this.m_resource_mc_array[i]["hover_mc"]);
                  this.m_resource_hover_mc[i].visible = true;
                  this.m_resource_hover_mc[i].attachTooltip(this.m_tooltipArray[i] = new FarmTextTooltip(this.getHoverText(i)));
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("txt_tf"))
               {
                  this.m_resource_txt_array[i] = new ZwTextField(this.m_resource_mc_array[i]["txt_tf"],"Use 10 Coupons to Rescue");
                  this.m_resource_txt_array[i].visible = false;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("txt1_tf"))
               {
                  this.m_resource_txt1_array[i] = new ZwTextField(this.m_resource_mc_array[i]["txt1_tf"],"");
                  this.m_resource_txt1_array[i].visible = false;
               }
               if(this.m_resource_mc_array[i].hasOwnProperty("progress_mc"))
               {
                  this.m_resource_progress_mc_array[i] = this.m_resource_mc_array[i]["progress_mc"] as MovieClip;
                  this.m_resource_progress_mc_array[i].visible = true;
                  if(this.m_resource_progress_mc_array[i].hasOwnProperty("fill_mc"))
                  {
                     this.m_resource_progress_fill_mc_array[i] = this.m_resource_progress_mc_array[i]["fill_mc"] as MovieClip;
                     this.m_resource_progress_fill_mc_array[i].visible = true;
                  }
               }
            }
         }
         for(var ind:int = 0; ind < 5; ind++)
         {
            if(m_window.hasOwnProperty(this.m_states_name_array[ind]))
            {
               this.m_states_mc_array[ind] = m_window[this.m_states_name_array[ind]] as MovieClip;
               this.m_states_mc_array[ind].visible = true;
               if(ind <= this.manager.getStageOfAnimal())
               {
                  this.m_states_mc_array[ind].gotoAndPlay(1);
               }
            }
            if(this.m_states_mc_array[ind].hasOwnProperty("active_mc"))
            {
               this.m_states_active_mc_array[ind] = this.m_states_mc_array[ind]["active_mc"] as MovieClip;
               this.m_states_active_mc_array[ind].visible = false;
            }
            if(ind == 0)
            {
               this.m_states_active_mc_array[ind].visible = true;
            }
         }
         if(m_window.hasOwnProperty("survey_map"))
         {
            this.m_survey_map_mc = m_window["survey_map"] as MovieClip;
            this.m_survey_map_mc.visible = true;
         }
         for(i = 0; i < 4; i++)
         {
            if(m_window.hasOwnProperty(this.m_animal_name_array[i]))
            {
               this.m_animal_mc_array[i] = m_window[this.m_animal_name_array[i]] as MovieClip;
               this.m_animal_mc_array[i].visible = true;
            }
            if(this.m_animal_mc_array[i].hasOwnProperty("mc_highlight"))
            {
               this.m_animal_highlight_mc_array[i] = this.m_animal_mc_array[i]["mc_highlight"] as MovieClip;
               this.m_animal_highlight_mc_array[i].visible = false;
            }
            if(this.m_animal_mc_array[i].hasOwnProperty("tick_mc"))
            {
               this.m_animal_tick_mc_array[i] = this.m_animal_mc_array[i]["tick_mc"] as MovieClip;
               this.m_animal_tick_mc_array[i].visible = false;
            }
            this.m_animal_name_tf_array[i] = new ZwTextField(this.m_animal_mc_array[i]["name_tf"],this.manager.VAL_ANIMAL_NAME_ARRAY[i]);
            if(m_window.hasOwnProperty(this.m_hover_name_array[i]))
            {
               this.m_hover_mc_array[i] = new FarmIcon(m_window[this.m_hover_name_array[i]]);
               this.m_hover_mc_array[i].visible = false;
            }
            if(m_window.hasOwnProperty(this.m_states_name_array[i]))
            {
               addWidget(this.m_states_preview_mc_array[i] = new ZwFrame(m_window[this.m_states_name_array[i + 1]]),true);
               this.m_states_preview_mc_array[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onstateMouseHover(i));
               this.m_states_preview_mc_array[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onstateMouseOut(i));
            }
            if(this.m_survey_map_mc.hasOwnProperty(this.m_world_tick_name_array[i]))
            {
               this.m_world_tick_mc_array[i] = this.m_survey_map_mc[this.m_world_tick_name_array[i]] as MovieClip;
               this.m_world_tick_mc_array[i].visible = false;
            }
            if(this.m_survey_map_mc.hasOwnProperty(this.m_world_highlight_mc_name_array[i]))
            {
               this.m_world_highlight_mc_array[i] = this.m_survey_map_mc[this.m_world_highlight_mc_name_array[i]] as MovieClip;
               this.m_world_highlight_mc_array[i].visible = false;
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlay_mc = m_window["overlay_mc"] as MovieClip;
            this.m_overlay_mc.visible = false;
            if(this.m_overlay_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_travel_bt = new FarmAnimatedTextButton(this.m_overlay_mc["okay_bt"],"Travel",this.onTravelWorld));
               this.m_travel_bt.visible = false;
            }
            if(this.m_overlay_mc.hasOwnProperty("text_tf"))
            {
               this.m_overlay_tf = new ZwTextField(this.m_overlay_mc["text_tf"],"It seems like you’re on the another farm! Travel to " + this.manager.VAL_FARM_NAMES_ARRAY[this.manager.getSelectedWorldSlot() - 1] + " to do these tasks!");
               this.m_overlay_tf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            tutorial_mc = m_window["tutorial_mc"] as MovieClip;
            if(m_tutorial)
            {
               for(j = 0; j < 5; j++)
               {
                  buttonName1 = "okay" + j.toString() + "_bt";
                  if(tutorial_mc.hasOwnProperty(buttonName1))
                  {
                     this.m_tutorialButtons[j] = new FarmAnimatedTextButton(tutorial_mc[buttonName1]);
                     m_tutorial.addWidget(this.m_tutorialButtons[j] as FarmAnimatedTextButton);
                     this.m_tutorialButtons[j].visible = false;
                  }
               }
            }
         }
         this.updateWindow();
         for(i = 0; i < 3; i++)
         {
            sinkTime = this.manager.getMaxResourceSinkTime() - this.manager.getResourceSinkWaitTime(this.manager.VAL_COUPON_NAME_ARRAY[i] + "_wait_time");
            if(this.manager.checkToShowStarvTime(i))
            {
               if(sinkTime < 0)
               {
                  text = this.manager.getCallOutTextByAnimal(this.manager.getSelectedAnimal(),i);
                  this.showNPCCallouts(this.manager.VAL_ANIMAL_NAME_ARRAY[this.manager.getSelectedAnimalSlot() - 1],text);
               }
            }
         }
      }
      
      public function onClickRewardBt(event:Event) : void
      {
         this.manager.openRewardWindow();
      }
      
      public function onTravelWorld(event:Event) : void
      {
         this.manager.onTravelButtonClick();
      }
      
      public function onSelectTask(type:String) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.openTasks(type);
         };
      }
      
      public function buyCouponsClick(event:Event) : void
      {
         this.manager.mainWindow.tintWindow();
         this.manager.mainWindow.enableInput = false;
         this.manager.buyConsumable(1,this.manager.mainWindow);
      }
      
      public function onstateMouseHover(ind:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var iconUrl:* = "assets/dialogs/Animal_sanctury_2019/animal" + manager.getSelectedAnimalSlot() + "_m" + (ind + 1) + ".png";
            m_hover_mc_array[ind].loadIcon(iconUrl);
            m_hover_mc_array[ind].setIconSize(300,300);
            m_hover_mc_array[ind].visible = true;
         };
      }
      
      public function onstateMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_hover_mc_array[slotIndex].visible = false;
         };
      }
      
      public function onSinkClick(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.sinkConsumable(slotIndex);
            refreshWindow();
         };
      }
      
      public function onStarvSinkClick(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            tintWindow();
            enableInput = false;
            m_resource_sink_bt_array[slotIndex].enabled = false;
            manager.sinkConsumableOnStarve(slotIndex);
            refreshWindow();
         };
      }
      
      public function onAccept(event:Event) : void
      {
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
      }
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText() + " left";
      }
      
      private function getHoverText(i:int = 0) : String
      {
         var txt:String = "";
         var sinkTime:int = this.manager.getMaxResourceSinkTime() - this.manager.getResourceSinkWaitTime(this.manager.VAL_COUPON_NAME_ARRAY[i] + "_wait_time");
         if(i == 0)
         {
            txt = sinkTime < 0 ? "The animals are starving! Provide food immediately" : "Provide food before the animals start starving!";
            if(!this.manager.checkToShowStarvTime(i))
            {
               txt = "Use other resources to Complete Milestone";
            }
         }
         else if(i == 1)
         {
            txt = sinkTime < 0 ? "The animals are unsafe! Provide shelter immediately" : "Provide shelter before the animals become unsafe!";
            if(!this.manager.checkToShowStarvTime(i))
            {
               txt = "Use other resources to Complete Milestone";
            }
         }
         else
         {
            txt = sinkTime < 0 ? "The animals are sick! Provide medicine immediately" : "Provide medicine before the animals get sick!";
            if(!this.manager.checkToShowStarvTime(i))
            {
               txt = "Use other resources to Complete Milestone";
            }
         }
         return txt;
      }
      
      public function updateProgressBar(slot:int = 0) : void
      {
         var dayPoints:int = this.manager.getSinkedCouponCountByType(slot);
         var level:int = this.manager.getStageOfAnimal();
         var maxPoint:int = 0;
         var progressPoints:int = 0;
         maxPoint = int(this.manager.CONSUMABLE_COUNT_ARRAY[level]);
         progressPoints = dayPoints;
         var barLength:Number = progressPoints * PROGRESS_BAR_FULL_WIDTH / maxPoint;
         if(this.m_resource_progress_fill_mc_array[slot])
         {
            if(dayPoints < 0)
            {
               this.m_resource_progress_fill_mc_array[slot].width = barLength;
            }
            else
            {
               this.m_resource_progress_fill_mc_array[slot].width = barLength;
            }
         }
      }
      
      private function startSinkWaitTime(slot:*) : void
      {
         this.m_skip_timer = new Timer(1000);
         this.m_skip_timer.addEventListener(TimerEvent.TIMER,this.onskipWaitTimer(slot));
         this.m_skip_timer.start();
      }
      
      public function onskipWaitTimer(slot:int) : Function
      {
         return function(evt:TimerEvent):void
         {
            var sinkTime:* = manager.getMaxResourceSinkTime() - manager.getResourceSinkWaitTime(manager.VAL_COUPON_NAME_ARRAY[slot] + "_wait_time");
            if(sinkTime <= 0)
            {
               m_resource_caution_mc_array[slot].visible = manager.checkToShowStarvTime(slot);
               m_resource_caution1_mc_array[slot].visible = manager.checkToShowStarvTime(slot);
               m_resource_timer_tf_array[slot].text = getStarvTextByType(slot);
               m_tooltipArray[slot].setText(getHoverText(slot));
               stopSinkTimer();
            }
            else
            {
               m_resource_timer_tf_array[slot].text = HUD.getformattedTimeLeft(sinkTime);
               m_resource_timer_tf_array[slot].visible = manager.checkToShowStarvTime(slot);
               m_tooltipArray[slot].setText(getHoverText(slot));
            }
         };
      }
      
      private function stopSinkTimer() : void
      {
         if(this.m_skip_timer)
         {
            this.m_skip_timer.stop();
            this.m_skip_timer.removeEventListener(TimerEvent.TIMER,this.onskipWaitTimer);
            this.m_skip_timer = null;
         }
      }
      
      private function getStarvTextByType(slot:int) : String
      {
         if(slot == 0)
         {
            return "The animals are starving! Provide food immediately";
         }
         if(slot == 1)
         {
            return "The animals are unsafe! Provide shelter immediately";
         }
         return "The animals are sick! Provide medicine immediately";
      }
      
      public function updateWindow() : void
      {
         var ind:int = 0;
         var sinkTime:int = 0;
         var iconurl:String = "assets/dialogs/Animal_sanctury_2019/" + this.manager.MILESTONE_FINAL_REWARDS[this.manager.getSelectedAnimalSlot() - 1] + "_" + this.manager.getStageOfAnimal() + "_icon_400.png";
         this.m_icon_mc.loadIcon(iconurl);
         this.m_icon_mc.setIconSize(400,400);
         this.m_icon_mc.visible = true;
         if(this.manager.getSelectedWorld() != Global.worldManager.currentWorldType)
         {
            this.m_overlay_mc.visible = true;
            this.m_overlay_tf.text = "It seems like you’re on the another farm! Travel to " + this.manager.VAL_FARM_NAMES_ARRAY[this.manager.getSelectedWorldSlot() - 1] + " to do these tasks!";
            this.m_overlay_tf.visible = true;
            if(this.m_travel_bt != null)
            {
               this.m_travel_bt.visible = true;
            }
         }
         else if(this.manager.isDropLimitReached())
         {
            this.m_overlay_mc.visible = true;
            this.m_overlay_tf.text = "You have reached the limit for coupon drop, use more coupons to continue getting the drop.";
            this.m_overlay_tf.visible = true;
            if(this.m_travel_bt != null)
            {
            }
         }
         else
         {
            this.m_overlay_mc.visible = false;
            if(this.m_travel_bt != null)
            {
            }
         }
         this.manager.showHudNotification();
         for(var i:int = 0; i < 3; i++)
         {
            this.m_task_sink_bt_array[i] = new FarmAnimatedTextButton(this.m_task_mc_array[i]["sink_bt"],"" + this.manager.VAL_TASK_ARRAY[i],this.onSelectTask(this.manager.VAL_TASK_ARRAY[i]));
            this.updateProgressBar(i);
            this.m_tooltipArray[i].setText(this.getHoverText(i));
            sinkTime = this.manager.getMaxResourceSinkTime() - this.manager.getResourceSinkWaitTime(this.manager.VAL_COUPON_NAME_ARRAY[i] + "_wait_time");
            if(this.manager.checkToShowStarvTime(i))
            {
               if(sinkTime < 0)
               {
                  this.m_resource_caution_mc_array[i].visible = true;
                  this.m_resource_caution1_mc_array[i].visible = true;
                  this.m_resource_timer_tf_array[i].text = this.getStarvTextByType(i);
                  this.m_resource_timer_tf_array[i].visible = true;
                  this.m_resource_progress_mc_array[i].visible = false;
                  this.m_resource_score_needed_tf_array[i].visible = false;
                  this.m_resource_sink_bt_array[i].enabled = this.manager.requiredCosumablesAvailable(i);
                  this.m_resource_sink_bt_array[i].callback = this.onStarvSinkClick(i);
                  this.m_resource_txt_array[i].visible = true;
                  StatsManager.count("AnimalSanctuary","critical","enter",this.manager.getSelectedAnimal(),this.manager.VAL_COUPON_NAME_ARRAY[i],"");
               }
               else
               {
                  this.m_resource_timer_tf_array[i].text = HUD.getformattedTimeLeft(sinkTime);
                  this.m_resource_timer_tf_array[i].visible = true;
                  this.m_resource_caution_mc_array[i].visible = false;
                  this.m_resource_caution1_mc_array[i].visible = false;
                  this.m_resource_sink_bt_array[i].enabled = this.manager.isSinkButtonEnabled(i);
                  this.m_resource_sink_bt_array[i].callback = this.onSinkClick(i);
                  this.m_resource_progress_mc_array[i].visible = true;
                  this.m_resource_score_needed_tf_array[i].visible = true;
                  this.m_resource_txt_array[i].visible = false;
               }
            }
            else
            {
               this.m_resource_sink_bt_array[i].enabled = this.manager.isSinkButtonEnabled(i);
               this.m_resource_sink_bt_array[i].callback = this.onSinkClick(i);
               this.m_resource_progress_mc_array[i].visible = true;
               this.m_resource_caution_mc_array[i].visible = false;
               this.m_resource_caution1_mc_array[i].visible = false;
               this.m_resource_timer_tf_array[i].visible = false;
               this.m_resource_score_needed_tf_array[i].visible = true;
               this.m_resource_txt_array[i].visible = false;
               this.startSinkWaitTime(i);
            }
         }
         for(ind = 0; ind < 5; ind++)
         {
            this.m_states_active_mc_array[ind].visible = ind <= this.manager.getStageOfAnimal();
         }
         for(ind = 0; ind < 4; ind++)
         {
            this.m_animal_highlight_mc_array[ind].visible = this.manager.isAnimalInProgress(ind);
            this.m_animal_tick_mc_array[ind].visible = this.manager.isAnimalCompleted(ind);
            this.m_world_tick_mc_array[ind].visible = this.manager.isWorldCompleted(ind);
            this.m_world_highlight_mc_array[ind].visible = ind == this.manager.getSelectedWorldSlot() - 1;
         }
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1_tf.text = title;
         this.m_npc2_tf.text = text;
         this.m_talk_auto_mc.visible = true;
         this.m_talk_auto_mc.gotoAndPlay(1);
      }
      
      override public function refreshWindow() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            this.m_resource_score_available_tf_array[i].text = "x" + this.manager.consumableCount(i).toString();
            this.m_resource_score_needed_tf_array[i].text = this.manager.getSinkedCouponCountByType(i).toString() + " / " + this.manager.CONSUMABLE_COUNT_ARRAY[this.manager.getStageOfAnimal()];
            this.m_stage_tf.text = "Stage " + this.manager.getStageOfAnimal() + "/4";
            this.m_resource_sink_bt_array[i].enabled = this.manager.isSinkButtonEnabled(i);
            this.updateProgressBar(i);
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function getHoverTextForTasks(slot:int = 0) : String
      {
         if(slot == 0)
         {
            return "Plant and Harvest 100 of a kind to get a coupon drop! More harvest time gives more coupons!";
         }
         if(slot == 1)
         {
            return "Craft these items to get a coupon drop!";
         }
         return "Harvest 5 of a kind to get a coupon drop! More harvest time more coupons!";
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
      }
      
      public function updateStagesMc() : void
      {
         this.m_states_mc_array[this.manager.getStageOfAnimal()].gotoAndPlay(1);
      }
   }
}

