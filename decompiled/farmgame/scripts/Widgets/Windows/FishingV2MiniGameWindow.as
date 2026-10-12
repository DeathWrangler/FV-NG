package Widgets.Windows
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingV2MiniGameWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_SAFE_ZONES:Number = 3;
      
      private static const INITIALLY_VISIBLE_PEGS:Number = 15;
      
      private static const SAFE_ZONE_WIDTHS:Array = [6,10,14];
      
      private static const TIMER_TOTAL_WIDTH:Number = 156;
      
      private static const GAME_DURATION_IN_SECS:Number = 10;
      
      private static const GAME_BAR_MOVEMENT_DUARTION_IN_SECS:Number = 0.25;
      
      private static const UNSAFE_ZONE_DURATION_TICKS_THRESHOLD:Number = 10 / GAME_BAR_MOVEMENT_DUARTION_IN_SECS;
      
      private static const TIMER_UNIT_WIDTH:Number = TIMER_TOTAL_WIDTH / GAME_DURATION_IN_SECS * GAME_BAR_MOVEMENT_DUARTION_IN_SECS;
      
      private static const SAFE_ZONE_CALLOUTS:Array = [["Good Going!","That\'s the sweet spot!","Nice!"],["Great!","Keep Going!","Brilliant!"],["Almost There!","Last Push!","Almost yours now!"]];
      
      private static const LOW_TENSION_ZONE_CALLOUTS:Array = [["Reel Harder!","The fish will get away!","Increase the tension!"],["The fish is going to slip away!","You are going to lose your catch!","Reel faster or the fish will slip away soon!"]];
      
      private static const HIGH_TENSION_ZONE_CALLOUTS:Array = [["Don\'t reel too hard!","Easy there! The line will break!","Warning! You are putting too much pressure!"],["The line is close to breaking!","Lower the tension immediately!","The line is going to break!"]];
      
      private var m_featureName:String = null;
      
      private var m_wasReelingPreempted:Boolean = false;
      
      private var m_hasCasted:Boolean = false;
      
      private var m_gameStarted:Boolean = false;
      
      private var m_titleTF:ZwTextField;
      
      private var m_calloutTF:ZwTextField;
      
      private var m_timerWidth:Number;
      
      private var m_safeZoneDuration:Number;
      
      private var m_numPegs:Number;
      
      private var m_calloutIndex:Number = -1;
      
      private var m_increseContinously:Boolean;
      
      private var m_calloutTextTimeSlots:Object;
      
      private var m_numActivePegs:Number = 0;
      
      private var m_unsafeZoneDuration:Number = 0;
      
      private var m_safeZoneMC:MovieClip;
      
      private var m_reelTF:ZwTextField;
      
      private var m_hookedMC:MovieClip;
      
      private var m_lowTensionMC:MovieClip;
      
      private var m_highTensionMC:MovieClip;
      
      private var m_progressMC:MovieClip;
      
      private var m_reelMC:MovieClip;
      
      private var m_reelBT:FarmButton;
      
      private var m_reelPulseBT:FarmButton;
      
      private var m_backBT:FarmAnimatedTextButton;
      
      private var m_fillerPegsMC:Array = [];
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_okay_bt1:FarmAnimatedTextButton;
      
      private var m_okay_bt2:FarmAnimatedTextButton;
      
      private var m_tutorialSubTtile_tf:ZwTextField;
      
      private var m_tutorialTtile_tf:ZwTextField;
      
      private var m_arrow_mc:MovieClip;
      
      private var m_okay_bt3:FarmAnimatedTextButton;
      
      private var m_pre_something_hooked_mc:MovieClip;
      
      private var m_editTf:ZwTextField;
      
      public function FishingV2MiniGameWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetURL);
      }
      
      private static function getRandom(low:Number = 0, high:Number = 1) : int
      {
         return Math.floor(Math.random() * (high - low + 1)) + low;
      }
      
      override protected function postLoadComplete() : void
      {
         var fillerPegMC:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("new_tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["new_tutorial_mc"] as MovieClip;
            this.m_okay_bt1 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_0_bt,"Next",this.onOkay1Click);
            this.m_okay_bt2 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_1_bt,"Next",this.onOkay2Click);
            this.m_okay_bt3 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_2_bt,"Next",this.onOkay3Click);
            this.m_arrow_mc = this.m_tutorial_mc.arrow_mc as MovieClip;
            if(FishingV2Manager.isTutorial1Over())
            {
               this.m_tutorial_mc.visible = false;
            }
            else
            {
               this.m_tutorial_mc.gotoAndStop(1);
               this.m_tutorial_mc.visible = true;
               this.m_okay_bt1.visible = true;
               this.m_okay_bt2.visible = false;
               this.m_okay_bt3.visible = false;
               this.m_arrow_mc.visible = true;
            }
         }
         if(FishingV2Manager.isTutorial1Over())
         {
         }
         if(m_window["title_tf"])
         {
            this.m_titleTF = addWidget(new ZwTextField(m_window["title_tf"],"Fishing Frenzy!")) as ZwTextField;
            this.m_titleTF.visible = true;
         }
         if(m_window.hasOwnProperty("high_tension_zone_mc"))
         {
            this.m_highTensionMC = m_window.high_tension_zone_mc as MovieClip;
            this.m_highTensionMC.play();
            this.m_highTensionMC.visible = false;
         }
         if(m_window.hasOwnProperty("callout_tf_mc"))
         {
            addWidget(new ZwBaseWidget(m_window.callout_tf_mc));
            if(m_window.callout_tf_mc.callout_tf)
            {
               this.m_calloutTF = addWidget(new ZwTextField(m_window.callout_tf_mc.callout_tf,""),false) as ZwTextField;
            }
         }
         if(m_window.hasOwnProperty("low_tension_zone_mc"))
         {
            this.m_lowTensionMC = m_window.low_tension_zone_mc as MovieClip;
            this.m_lowTensionMC.play();
            this.m_lowTensionMC.visible = false;
         }
         if(m_window.hasOwnProperty("something_hooked_mc"))
         {
            this.m_hookedMC = m_window.something_hooked_mc as MovieClip;
            this.m_hookedMC.play();
            this.m_hookedMC.visible = true;
            if(this.m_hookedMC.hasOwnProperty("edit_tf"))
            {
               this.m_editTf = addWidget(new ZwTextField(this.m_hookedMC["edit_tf"],"Cast a line to hook a fish!")) as ZwTextField;
               this.m_editTf.text = "Cast a line to hook a fish!";
               this.m_editTf.visible = true;
            }
         }
         if(m_window.hasOwnProperty("safe_zone_mc"))
         {
            this.m_safeZoneMC = m_window["safe_zone_mc"] as MovieClip;
            this.m_safeZoneMC.gotoAndStop(NUM_SAFE_ZONES - FishingV2Manager.m_selectedBait);
            this.m_safeZoneMC.visible = false;
         }
         if(m_window.hasOwnProperty("reel_bt"))
         {
            this.m_reelBT = new FarmButton(m_window["reel_bt"],this.onReelClick) as FarmButton;
            if(m_window.reel_bt.btn_tf)
            {
               this.m_reelTF = addWidget(new ZwTextField(m_window.reel_bt.btn_tf,"Click To Cast")) as ZwTextField;
            }
            this.m_reelBT.visible = true;
            this.m_reelMC = m_window["reel_bt"] as MovieClip;
            this.m_reelMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onReelButtonMouseDown);
            this.m_reelMC.addEventListener(MouseEvent.MOUSE_UP,this.onReelButtonMouseUp);
            if(!FishingV2Manager.isTutorial1Over())
            {
               this.m_reelBT.visible = false;
            }
         }
         if(m_window.hasOwnProperty("reel_pulse_bt"))
         {
            this.m_reelPulseBT = new FarmButton(m_window["reel_pulse_bt"],this.onReelClick) as FarmButton;
         }
         if(m_window.hasOwnProperty("back_bt"))
         {
            this.m_backBT = new FarmAnimatedTextButton(m_window["back_bt"],"Back",onClose) as FarmAnimatedTextButton;
            this.m_backBT.visible = true;
         }
         if(m_window.hasOwnProperty("fish_energy_mc"))
         {
            this.m_progressMC = m_window["fish_energy_mc"] as MovieClip;
            this.m_progressMC.progress_fill_mc.width = TIMER_TOTAL_WIDTH;
            this.m_progressMC.visible = false;
         }
         var index:int = 0;
         while(m_window.hasOwnProperty("filler_peg_" + index.toString() + "_mc"))
         {
            fillerPegMC = m_window["filler_peg_" + index.toString() + "_mc"] as MovieClip;
            this.m_fillerPegsMC.push(fillerPegMC);
            fillerPegMC.visible = false;
            index++;
         }
         this.m_numActivePegs = INITIALLY_VISIBLE_PEGS;
         this.m_numPegs = index;
      }
      
      override protected function afterLoad() : void
      {
         super.afterLoad();
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         this.m_editTf.text = "Cast a line to hook a fish!";
         this.m_editTf.visible = true;
      }
      
      private function get manager() : FishingV2Manager
      {
         return FishingV2Manager.getInstance(this.m_featureName);
      }
      
      private function beginReeling() : void
      {
         if(this.m_numActivePegs < this.m_numPegs)
         {
            this.m_fillerPegsMC[this.m_numActivePegs++].visible = true;
         }
      }
      
      private function stopReeling() : void
      {
         if(this.m_numActivePegs > 0)
         {
            this.m_fillerPegsMC[--this.m_numActivePegs].visible = false;
         }
      }
      
      private function startTimer() : void
      {
         this.m_timerWidth = TIMER_TOTAL_WIDTH;
         this.m_safeZoneDuration = 0;
         this.onTimerTick();
      }
      
      private function generateCallOutTextTimeSlots() : void
      {
         this.m_calloutTextTimeSlots = {};
         this.m_calloutTextTimeSlots["low"] = [getRandom(0,5),getRandom(6,9)];
         this.m_calloutTextTimeSlots["high"] = [getRandom(0,5),getRandom(6,9)];
         this.m_calloutTextTimeSlots["safe"] = [getRandom(0,10),getRandom(11,20),getRandom(21,29)];
      }
      
      private function onReelClick(event:Event) : void
      {
         var barmc:MovieClip = null;
         var index:int = 0;
         if(!this.m_hasCasted)
         {
            this.m_hasCasted = true;
            this.m_editTf.visible = true;
            this.m_editTf.text = "You\'ve Got something hooked! Start Reeling!";
            this.m_hookedMC.visible = true;
            this.m_reelTF.text = "Click To Reel";
            this.generateCallOutTextTimeSlots();
            FarmStatsManager.count(this.m_featureName,"fishingwindow","reel","click");
            if(FishingV2Manager.isTutorial1Over())
            {
               this.m_tutorial_mc.gotoAndStop(5);
            }
            this.m_safeZoneMC.visible = true;
            index = 0;
            for each(barmc in this.m_fillerPegsMC)
            {
               barmc.visible = index < INITIALLY_VISIBLE_PEGS;
               index++;
            }
            return;
         }
         if(!this.m_gameStarted)
         {
            this.m_gameStarted = true;
            this.m_editTf.visible = false;
            this.m_progressMC.visible = true;
            this.m_hookedMC.visible = false;
            this.m_tutorial_mc.visible = false;
            this.m_reelPulseBT.visible = true;
            this.startTimer();
         }
         this.m_increseContinously = false;
         this.beginReeling();
      }
      
      private function onReelButtonMouseDown(event:MouseEvent) : void
      {
         this.m_increseContinously = true;
      }
      
      private function onReelButtonMouseUp(event:MouseEvent) : void
      {
         this.m_increseContinously = false;
      }
      
      private function inLowTensionZone() : Boolean
      {
         var leftMargin:Number = int(this.m_numPegs / 2) - SAFE_ZONE_WIDTHS[FishingV2Manager.m_selectedBait] / 2;
         return this.m_numActivePegs <= leftMargin;
      }
      
      private function inHighTensionZone() : Boolean
      {
         var rightMargin:Number = int(this.m_numPegs / 2) + SAFE_ZONE_WIDTHS[FishingV2Manager.m_selectedBait] / 2;
         return this.m_numActivePegs > rightMargin;
      }
      
      private function inSafeZone() : Boolean
      {
         return !this.inLowTensionZone() && !this.inHighTensionZone();
      }
      
      private function showCalloutTextForSafeZone() : void
      {
         var index:int = -1;
         if(this.m_safeZoneDuration <= 10)
         {
            index = 0;
         }
         else if(this.m_safeZoneDuration > 10 && this.m_safeZoneDuration <= 20)
         {
            index = 1;
         }
         else
         {
            index = 2;
         }
         var showTime:Number = Number(this.m_calloutTextTimeSlots["safe"][index]);
         if(this.m_calloutIndex == -1)
         {
            this.m_calloutIndex = getRandom(0,2);
         }
         if(showTime >= this.m_safeZoneDuration - 1.5 && showTime <= this.m_safeZoneDuration + 1.5)
         {
            this.m_calloutTF.text = SAFE_ZONE_CALLOUTS[index][this.m_calloutIndex];
            this.m_calloutTF.visible = true;
            return;
         }
         this.m_calloutIndex = -1;
         this.m_calloutTF.visible = false;
      }
      
      public function showCalloutTextForTensionZone(zone:String) : void
      {
         var callouts:Array = null;
         var index:int = this.m_unsafeZoneDuration <= 5 ? 0 : 1;
         var showTime:Number = Number(this.m_calloutTextTimeSlots[zone][index]);
         if(this.m_calloutIndex == -1 || this.m_calloutIndex > 1)
         {
            this.m_calloutIndex = getRandom();
         }
         if(showTime >= this.m_unsafeZoneDuration - 1.5 && showTime <= this.m_unsafeZoneDuration + 1.5)
         {
            callouts = zone == "high" ? HIGH_TENSION_ZONE_CALLOUTS : LOW_TENSION_ZONE_CALLOUTS;
            this.m_calloutTF.text = callouts[index][this.m_calloutIndex];
            this.m_calloutTF.visible = true;
            return;
         }
         this.m_calloutIndex = -1;
         this.m_calloutTF.visible = false;
      }
      
      private function assertTensionZone() : void
      {
         if(this.inSafeZone())
         {
            this.m_timerWidth -= TIMER_UNIT_WIDTH;
            this.m_safeZoneDuration += GAME_BAR_MOVEMENT_DUARTION_IN_SECS;
            this.m_unsafeZoneDuration = 0;
            this.m_lowTensionMC.visible = false;
            this.m_highTensionMC.visible = false;
            this.showCalloutTextForSafeZone();
            return;
         }
         if(this.inLowTensionZone())
         {
            this.m_lowTensionMC.visible = true;
            this.m_highTensionMC.visible = false;
            this.showCalloutTextForTensionZone("low");
         }
         if(this.inHighTensionZone())
         {
            this.m_lowTensionMC.visible = false;
            this.m_highTensionMC.visible = true;
            this.showCalloutTextForTensionZone("high");
         }
         this.m_unsafeZoneDuration += 1;
         if(this.m_unsafeZoneDuration >= UNSAFE_ZONE_DURATION_TICKS_THRESHOLD)
         {
            this.m_timerWidth = 0;
            this.m_wasReelingPreempted = true;
         }
      }
      
      private function onTimerTick() : void
      {
         if(!this.m_timerWidth || this.m_timerWidth <= 0)
         {
            this.stopTimer();
         }
         else
         {
            if(this.m_increseContinously)
            {
               this.beginReeling();
            }
            else
            {
               this.stopReeling();
            }
            this.assertTensionZone();
            TweenMax.to(this.m_progressMC.progress_fill_mc,GAME_BAR_MOVEMENT_DUARTION_IN_SECS,{"width":this.m_timerWidth});
            TweenLite.delayedCall(GAME_BAR_MOVEMENT_DUARTION_IN_SECS,this.onTimerTick);
         }
      }
      
      private function onFishingSuccess() : void
      {
         FarmStatsManager.count(this.m_featureName,"Success","" + FishingV2Manager.m_selectedBait,"" + FishingV2Manager.m_selectedRod,"" + FishingV2Manager.m_selectedBoost);
         this.manager.getFish(FishingV2Manager.m_selectedRod,FishingV2Manager.m_selectedBait,FishingV2Manager.m_selectedBoost,true);
      }
      
      private function onFishingFailure() : void
      {
         var tense:int = this.inLowTensionZone() ? 1 : 0;
         FarmStatsManager.count(this.m_featureName,"Failure",tense == 1 ? "Low Tension" : "High Tension","" + FishingV2Manager.m_selectedBait,"" + FishingV2Manager.m_selectedRod,"" + FishingV2Manager.m_selectedBoost);
         UI.displayPopup(new FishingV2FailurePopUp(this.manager.fishingFailurePopUpURL,tense),false);
         this.manager.getFish(FishingV2Manager.m_selectedRod,FishingV2Manager.m_selectedBait,FishingV2Manager.m_selectedBoost,false);
      }
      
      private function stopTimer() : void
      {
         TweenLite.killDelayedCallsTo(this.onTimerTick);
         this.m_reelMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onReelButtonMouseDown);
         this.m_reelMC.removeEventListener(MouseEvent.MOUSE_UP,this.onReelButtonMouseUp);
         this.m_reelBT.enabled = false;
         if(this.inSafeZone() && !this.m_wasReelingPreempted)
         {
            this.onFishingSuccess();
         }
         else
         {
            this.onFishingFailure();
         }
         close();
      }
      
      public function onOkay1Click(e:Event = null) : void
      {
         this.m_tutorial_mc.gotoAndStop(2);
         this.m_progressMC.visible = true;
         this.m_okay_bt2.visible = true;
         this.m_okay_bt1.visible = false;
         this.m_okay_bt3.visible = false;
      }
      
      public function onOkay2Click(e:Event = null) : void
      {
         var barmc:MovieClip = null;
         this.m_tutorial_mc.gotoAndStop(3);
         this.m_progressMC.visible = false;
         this.m_safeZoneMC.visible = true;
         this.m_okay_bt3.visible = true;
         this.m_okay_bt2.visible = false;
         var index:int = 0;
         for each(barmc in this.m_fillerPegsMC)
         {
            barmc.visible = index < INITIALLY_VISIBLE_PEGS;
            index++;
         }
      }
      
      public function onOkay3Click(e:Event = null) : void
      {
         this.m_tutorial_mc.visible = false;
         this.m_okay_bt3.visible = false;
         this.m_reelBT.visible = true;
      }
   }
}

