package Widgets.Frames.LESlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LESlotMachine.LESlotMachineItemSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LESlotMachineSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_slotPrefix:String = "slot_";
      
      private var m_slotSuffix:String = "_mc";
      
      private var m_spinStoppedCallback:Function = null;
      
      public const NUM_SLOTS:int = 3;
      
      protected var m_items:Array = null;
      
      public function LESlotMachineSlotFrame(element:DisplayObject, prizes:Array)
      {
         this.m_items = prizes;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LESlotMachineItemSlot(slotElement);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
      
      override protected function getSlotPostfix() : String
      {
         return this.m_slotSuffix;
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      public function repopulateData(items:Array) : void
      {
         this.m_items = items;
         this.setupData();
         this.refresh();
      }
      
      public function startSpin() : void
      {
         var element:LESlotMachineItemSlot = null;
         for each(element in m_slots)
         {
            element.spinStart();
         }
      }
      
      public function stopSpin(callback:Function = null) : void
      {
         var timer:Timer = null;
         this.m_spinStoppedCallback = callback;
         for(var i:int = 0; i < this.NUM_SLOTS; i++)
         {
            timer = new Timer(this.slotStopSpinGap(i),1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE,m_slots[i].spinStop);
            timer.start();
         }
         (m_slots[this.NUM_SLOTS - 1] as LESlotMachineItemSlot).element.addEventListener("LESlotSpinEnd",this.onSpinStopped);
      }
      
      protected function slotStopSpinGap(slotNum:int) : int
      {
         return (slotNum + 1) * 500;
      }
      
      protected function onSpinStopped(event:Event) : void
      {
         (m_slots[this.NUM_SLOTS - 1] as LESlotMachineItemSlot).element.removeEventListener("LESlotSpinEnd",this.onSpinStopped);
         if(this.m_spinStoppedCallback != null)
         {
            this.m_spinStoppedCallback();
         }
      }
   }
}

