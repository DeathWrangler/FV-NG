package Widgets.Slots.FCSlotMachine
{
   import Engine.Managers.SoundManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.FCSlotMachine.FCSlotMachinePanelFrame;
   import Widgets.Slots.LESlotMachine.LESlotMachineItemSlot;
   import Widgets.Windows.FCSlotMachineWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class FCSlotMachineItemSlot extends LESlotMachineItemSlot
   {
      
      private var m_reelMatch:ZwFrame;
      
      public function FCSlotMachineItemSlot(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function addPanelContainer(element:DisplayObject) : void
      {
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.reelStart_mc != null && m_startPanelContainer == null)
         {
            m_startPanelContainer = addWidget(new FCSlotMachinePanelFrame(elementMc.reelStart_mc)) as FCSlotMachinePanelFrame;
         }
         this.m_reelMatch = addWidget(new ZwFrame(elementMc.match_mc),false) as ZwFrame;
      }
      
      public function toggleMatchField(on:Boolean) : void
      {
         this.m_reelMatch.visible = on;
      }
      
      override public function spinStop(event:TimerEvent = null) : void
      {
         var elementMc:MovieClip = null;
         if(this.element != null)
         {
            elementMc = element as MovieClip;
            elementMc.gotoAndPlay(30);
            elementMc.addEventListener(Event.ENTER_FRAME,this.checkTimeline);
         }
         if(event != null)
         {
            (event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.spinStop);
         }
      }
      
      private function checkTimeline(e:Event) : void
      {
         if(e.target.currentFrame == e.target.totalFrames)
         {
            e.target.stop();
            this.playStopSound();
            (element as MovieClip).removeEventListener(Event.ENTER_FRAME,this.checkTimeline);
         }
      }
      
      private function playStopSound() : void
      {
         SoundManager.playSound(FCSlotMachineWindow.SFX_DING_ID);
      }
      
      override public function release() : void
      {
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.hasEventListener(Event.ENTER_FRAME))
         {
            elementMc.removeEventListener(Event.ENTER_FRAME,this.checkTimeline);
         }
         super.release();
      }
   }
}

