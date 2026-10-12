package Widgets.Slots.LESlotMachine
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.LESlotMachine.LESlotMachinePanelFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class LESlotMachineDiscountSlot extends ZwFrame
   {
      
      private var m_discountStartReel:LESlotMachinePanelFrame = null;
      
      private var m_spinStopCallback:Function = null;
      
      public const RESULT_FRAME_INDEX:int = 100;
      
      public function LESlotMachineDiscountSlot(element:DisplayObject)
      {
         super(element);
         var elementMc:MovieClip = element as MovieClip;
         this.m_discountStartReel = addWidget(new LESlotMachinePanelFrame(elementMc.reelStart_discount_mc,true)) as LESlotMachinePanelFrame;
         (this.element as MovieClip).gotoAndStop(this.RESULT_FRAME_INDEX);
      }
      
      public function repopulatePanels(data:Array) : void
      {
         this.m_discountStartReel.updateData(data);
      }
      
      public function spinStart() : void
      {
         if(this.element != null)
         {
            (this.element as MovieClip).gotoAndPlay(0);
         }
      }
      
      public function spinStopSchedule(delay:Number, callback:Function = null) : void
      {
         this.m_spinStopCallback = callback;
         var timer:Timer = new Timer(delay,1);
         timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.spinStop);
         timer.start();
      }
      
      private function spinStop(event:TimerEvent = null) : void
      {
         (event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.spinStop);
         if(this.element != null)
         {
            (this.element as MovieClip).gotoAndPlay(30);
         }
         if(event != null)
         {
            (event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.spinStop);
         }
         (this.element as MovieClip).addEventListener("LESlotSpinEnd",this.triggerStopCallback);
      }
      
      private function triggerStopCallback(event:Event = null) : void
      {
         (this.element as MovieClip).removeEventListener("LESlotSpinEnd",this.triggerStopCallback);
         if(this.m_spinStopCallback != null)
         {
            this.m_spinStopCallback();
         }
      }
   }
}

