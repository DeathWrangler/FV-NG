package Widgets.Slots.LESlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.LESlotMachine.LESlotMachinePanelFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LESlotMachineItemSlot extends ZwSlotFrame
   {
      
      protected var m_startPanelContainer:LESlotMachinePanelFrame = null;
      
      public function LESlotMachineItemSlot(element:DisplayObject)
      {
         super(element);
         this.addPanelContainer(element);
      }
      
      protected function addPanelContainer(element:DisplayObject) : void
      {
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.reelStart_mc != null && this.m_startPanelContainer == null)
         {
            this.m_startPanelContainer = addWidget(new LESlotMachinePanelFrame(elementMc.reelStart_mc)) as LESlotMachinePanelFrame;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var itemNames:Array = ["cow","cow","horse"];
         if(data != null && data is Array)
         {
            itemNames = data as Array;
         }
         if(this.m_startPanelContainer != null)
         {
            this.m_startPanelContainer.updateData(itemNames);
            this.m_startPanelContainer.visible = true;
         }
      }
      
      public function spinStart() : void
      {
         if(this.element != null)
         {
            (this.element as MovieClip).gotoAndPlay(0);
         }
      }
      
      public function spinStop(event:TimerEvent = null) : void
      {
         if(this.element != null)
         {
            (this.element as MovieClip).gotoAndPlay(30);
         }
         if(event != null)
         {
            (event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.spinStop);
         }
      }
   }
}

