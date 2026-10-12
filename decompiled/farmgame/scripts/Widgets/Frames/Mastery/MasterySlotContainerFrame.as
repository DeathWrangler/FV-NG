package Widgets.Frames.Mastery
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BMasteryTimed;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Mastery.MasterySlot;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MasterySlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "itemCell";
      
      protected static const ZERO_TIMER:String = "00:00:00";
      
      protected static const MASTERY_KEY:String = "MasteryWindow_TimedConsumables_Time";
      
      private static const DIALOGS:String = "Dialogs";
      
      protected static const SLOT_POSTFIX:String = "";
      
      protected static const EMPTY_STRING:String = "";
      
      protected static const TIMER_LOOP_DELAY:int = 1000;
      
      protected var m_mainWindow:MasteryWindow;
      
      protected var m_masteryType:String = "";
      
      protected var m_masteryItems:Array;
      
      private var m_gameUpdateTimer:Timer;
      
      public function MasterySlotContainerFrame(element:DisplayObject, masteryItems:Array, mainWindow:MasteryWindow)
      {
         this.masteryType = MasteryWindow.TYPE_ANIMAL;
         this.m_mainWindow = mainWindow;
         this.m_masteryItems = masteryItems;
         super(element);
         var arrowLeft:FarmAnimatedButton = new FarmAnimatedButton(m_element.arrowLeft_mc,m_pagingComponent.onPageBack);
         addWidget(arrowLeft);
         m_pageBackWidget = arrowLeft;
         var arrowRight:FarmAnimatedButton = new FarmAnimatedButton(m_element.arrowRight_mc,m_pagingComponent.onPageForward);
         addWidget(arrowRight);
         m_pageForwardWidget = arrowRight;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_SURFACE) == 1)
         {
            if(ObjectUtil.pathExists(m_element,new Array("masteryTimer_mc","timeLeft_tf")))
            {
               addWidget(new ZwFrame(m_element.masteryTimer_mc),false);
               addWidget(new ZwTextField(m_element.masteryTimer_mc.timeLeft_tf,ZERO_TIMER));
               addWidget(new ZwTextField(m_element.masteryTimer_mc.timerText_tf,ZLocUtils.t(DIALOGS,MASTERY_KEY)));
               this.m_gameUpdateTimer = new Timer(TIMER_LOOP_DELAY);
               this.m_gameUpdateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimeLeft);
               this.m_gameUpdateTimer.start();
            }
         }
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MasterySlot(slotElement,this.m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_masteryItems;
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      public function changeData(newData:Array) : void
      {
         m_slotData = newData;
         pageNumber = 0;
      }
      
      protected function onUpdateTimeLeft(event:Event) : void
      {
         var timedBuffName:String = null;
         if(this.m_masteryType == MasteryWindow.TYPE_SEED)
         {
            timedBuffName = BMasteryTimed.TREE_ITEM_NAME;
         }
         else if(this.m_masteryType == MasteryWindow.TYPE_ANIMAL)
         {
            timedBuffName = BMasteryTimed.ANIMAL_ITEM_NAME;
         }
         this.updateTimeHelper(timedBuffName);
      }
      
      protected function updateTimeHelper(timedBuffName:String) : void
      {
         var itemXml:FarmItem = null;
         var permanentBuffName:String = null;
         var friendlyTime:Array = null;
         if(m_element.masteryTimer_mc != null)
         {
            m_element.masteryTimer_mc.visible = false;
            m_element.masteryTimer_mc.timeLeft_tf.text = ZERO_TIMER;
            itemXml = Global.farmGameSettingsManager.getFarmItemByName(timedBuffName);
            if(itemXml != null)
            {
               permanentBuffName = BMasteryTimed.getPermanemtBuffNameFromType(itemXml.subType);
               if(permanentBuffName != null && !Global.player.buffs[permanentBuffName])
               {
                  m_element.masteryTimer_mc.visible = true;
                  if(timedBuffName != null && Boolean(Global.player.buffs[timedBuffName]))
                  {
                     friendlyTime = this.calculateTimeRemaining(timedBuffName);
                     m_element.masteryTimer_mc.timeLeft_tf.text = FarmGameUtil.numberToStringPadZeros(friendlyTime[0]) + ":" + FarmGameUtil.numberToStringPadZeros(friendlyTime[1]) + ":" + FarmGameUtil.numberToStringPadZeros(friendlyTime[2]);
                  }
               }
            }
         }
      }
      
      protected function calculateTimeRemaining(buffName:String) : Array
      {
         var timeAdded:Number = Number(Global.player.buffs[buffName].time);
         var duration:Number = Number(Global.player.buffs[buffName].duration);
         var expirationTime:Number = timeAdded + duration;
         var timeLeft:Number = expirationTime - GlobalEngine.serverTime / 1000;
         return FarmGameUtil.parseTimeLeft(timeLeft);
      }
      
      override public function release() : void
      {
         super.release();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_SURFACE) == 1)
         {
            if(this.m_gameUpdateTimer != null)
            {
               this.m_gameUpdateTimer.stop();
               this.m_gameUpdateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimeLeft);
            }
         }
      }
      
      public function set masteryType(masteryType:String) : void
      {
         this.m_masteryType = masteryType;
      }
   }
}

