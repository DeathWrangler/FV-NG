package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   
   public class DragonBreedingStationSlot extends ZwSlotFrame
   {
      
      private const READY_MC:String = "ready_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const GETEGG_BT:String = "GetEgg_bt";
      
      private const BREEDING_MC:String = "breedingstate_mc";
      
      private const ADDHERB_BT:String = "addherb_bt";
      
      private var m_readyMC:MovieClip;
      
      private var m_breedingMC:MovieClip;
      
      private var m_timerTF:ZwTextField;
      
      private var m_getEggBtn:FarmAnimatedButton;
      
      private var m_addHerbBtn:FarmAnimatedButton;
      
      private const STATE_IDLE:int = 0;
      
      private const STATE_BREEDING:int = 1;
      
      private const STATE_READY:int = 2;
      
      private const STATE_HATCHING:int = 3;
      
      private var m_window:DragonBreedingWindow;
      
      private var m_session:DragonBreedingSession;
      
      private var m_state:int;
      
      private var m_timer:Timer;
      
      private var m_timeLeft:String;
      
      private var m_hatcheryCallback:Function;
      
      private var m_featureName:String = "";
      
      public function DragonBreedingStationSlot(element:DisplayObject, hatcheryCallback:Function, window:DragonBreedingWindow)
      {
         this.m_window = window;
         if(Boolean(this.m_window) && this.m_window.featureName != "")
         {
            this.m_featureName = this.m_window.featureName;
         }
         super(element);
         this.m_hatcheryCallback = hatcheryCallback;
         if(m_element.hasOwnProperty(this.READY_MC))
         {
            this.m_readyMC = m_element[this.READY_MC];
            this.m_readyMC.visible = false;
         }
         if(m_element.hasOwnProperty(this.TIMER_TF))
         {
            this.m_timerTF = addWidget(new ZwTextField(element[this.TIMER_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_window.featureName + "_BreedingTimerText"))) as ZwTextField;
            this.m_timerTF.visible = false;
         }
         if(m_element.hasOwnProperty(this.GETEGG_BT))
         {
            this.m_getEggBtn = addWidget(new FarmAnimatedButton(m_element[this.GETEGG_BT],this.onGetEgg)) as FarmAnimatedButton;
            this.m_getEggBtn.visible = false;
         }
         if(m_element.hasOwnProperty(this.BREEDING_MC))
         {
            this.m_breedingMC = m_element[this.BREEDING_MC];
            this.m_breedingMC.visible = false;
         }
         if(m_element.hasOwnProperty(this.ADDHERB_BT))
         {
            this.m_addHerbBtn = addWidget(new FarmAnimatedButton(m_element[this.ADDHERB_BT],this.onAddLovePotion)) as FarmAnimatedButton;
            this.m_addHerbBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_window.featureName + "_BreedingTooltipText")));
            this.m_addHerbBtn.visible = false;
         }
         if(!this.m_timer)
         {
            this.m_timer = new Timer(1000);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var remainingTime:Number = NaN;
         if(data)
         {
            this.m_session = new DragonBreedingSession(this.m_window.featureName);
            if(data is DragonBreedingSession)
            {
               this.m_session = data as DragonBreedingSession;
            }
            else
            {
               this.m_session.loadObject(data);
            }
            if(this.isEmpty(this.m_session))
            {
               this.m_state = this.STATE_IDLE;
            }
            else if(this.isReady(this.m_session))
            {
               if(this.isCollected(this.m_session))
               {
                  this.m_state = this.STATE_HATCHING;
               }
               else
               {
                  this.m_state = this.STATE_READY;
               }
            }
            else
            {
               remainingTime = this.m_session.finishTime - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               this.m_timeLeft = HUD.getformattedTimeLeft(remainingTime);
               this.m_state = this.STATE_BREEDING;
            }
         }
         else
         {
            this.m_state = this.STATE_IDLE;
            this.m_session = null;
         }
         this.refresh();
      }
      
      private function isCollected(sessionData:DragonBreedingSession) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(sessionData) && sessionData.collected)
         {
            result = true;
         }
         return result;
      }
      
      private function isReady(sessionData:DragonBreedingSession) : Boolean
      {
         var finishTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         if(sessionData)
         {
            finishTime = sessionData.finishTime;
            timeLeft = finishTime - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeft <= 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isEmpty(sessionData:DragonBreedingSession) : Boolean
      {
         var result:Boolean = true;
         if(Boolean(sessionData) && Boolean(sessionData.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_MALE)) && Boolean(sessionData.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_FEMALE)))
         {
            result = false;
         }
         return result;
      }
      
      private function refresh() : void
      {
         clearView();
         switch(this.m_state)
         {
            case this.STATE_IDLE:
               this.stateIdle();
               break;
            case this.STATE_BREEDING:
               this.stateBreeding();
               break;
            case this.STATE_READY:
               this.stateReady();
               break;
            case this.STATE_HATCHING:
               this.stateHatching();
         }
      }
      
      private function stateIdle() : void
      {
         this.m_breedingMC.visible = false;
         this.m_readyMC.visible = false;
         this.m_timerTF.visible = false;
         this.m_addHerbBtn.visible = false;
      }
      
      private function stateBreeding() : void
      {
         this.m_breedingMC.visible = true;
         var timeLeft:String = this.getBreedingTimeRemaining();
         this.m_timerTF.text = timeLeft;
         this.m_timerTF.visible = true;
         this.conditionallyEnableAddHerbButton();
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimeRemaining);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshTimeRemaining);
            this.m_timer.start();
         }
      }
      
      private function conditionallyEnableAddHerbButton() : void
      {
         if(this.m_state == this.STATE_BREEDING)
         {
            this.m_addHerbBtn.visible = true;
            if(DragonBreedingManager.getInstance(this.m_featureName).getLovePotionItemCount() > 0)
            {
               (this.m_addHerbBtn.tooltip as FarmTextTooltip).setText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_window.featureName + "_BreedingTooltipText"));
               this.m_addHerbBtn.enabled = true;
            }
         }
         else
         {
            this.m_addHerbBtn.visible = false;
         }
      }
      
      private function refreshTimeRemaining(e:TimerEvent) : void
      {
         if(Boolean(this.m_timerTF) && this.m_timerTF.visible)
         {
            if(this.isReady(this.m_session))
            {
               this.m_timer.stop();
               this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimeRemaining);
               this.stateReady();
            }
            else
            {
               this.m_timerTF.text = this.getBreedingTimeRemaining();
            }
         }
      }
      
      private function stateReady() : void
      {
         this.m_timerTF.visible = false;
         this.m_readyMC.visible = true;
         this.m_getEggBtn.visible = true;
         this.m_addHerbBtn.visible = false;
      }
      
      private function stateHatching() : void
      {
         this.stateIdle();
      }
      
      private function getBreedingTimeRemaining() : String
      {
         var remainingTime:Number = this.m_session.finishTime - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(remainingTime);
      }
      
      private function onGetEgg(e:Event = null) : void
      {
         if(this.m_session)
         {
            DragonBreedingManager.getInstance(this.m_featureName).getEgg(this.m_session,this.m_hatcheryCallback);
            if(this.m_window)
            {
               this.m_window.switchToTab(null,DragonBreedingWindow.TAB_HATCHERY);
               if(this.m_window.isInTutorial() && this.m_window.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_6))
               {
                  this.m_window.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_7);
               }
            }
         }
      }
      
      private function onAddLovePotion(e:Event = null) : void
      {
         if(this.m_session)
         {
            if(DragonBreedingManager.getInstance(this.m_featureName).getLovePotionItemCount() <= 0)
            {
               DragonBreedingManager.getInstance(this.m_featureName).showDragonBreedingCraftWindow(DragonBreedingManager.HERB_ITEM_NAME);
            }
            else
            {
               this.m_addHerbBtn.enabled = false;
               setTimeout(function():void
               {
                  DragonBreedingManager.getInstance(m_featureName).addLovePotion(m_session,m_hatcheryCallback);
                  m_addHerbBtn.enabled = true;
                  m_window.updateLovePotion();
               },1000);
            }
         }
      }
      
      override public function release() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimeRemaining);
            this.m_timer = null;
         }
         this.m_addHerbBtn.release();
         this.m_addHerbBtn = null;
         this.m_getEggBtn.release();
         this.m_getEggBtn = null;
         super.release();
      }
   }
}

