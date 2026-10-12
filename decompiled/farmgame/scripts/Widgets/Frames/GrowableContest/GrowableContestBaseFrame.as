package Widgets.Frames.GrowableContest
{
   import Classes.Constants.Experiments;
   import Classes.Growable.GrowableContest;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.GrowableObjectBaseSlot;
   import Widgets.Windows.GrowableContestWindow;
   import flash.display.DisplayObject;
   
   public class GrowableContestBaseFrame extends FarmSlotContainerFrame
   {
      
      private const SLOT_PREFIX:String = "cell";
      
      private var m_isOnboarding:Boolean;
      
      private var m_contest:GrowableContest;
      
      private var m_window:GrowableContestWindow;
      
      public function GrowableContestBaseFrame(window:GrowableContestWindow, element:DisplayObject, contest:GrowableContest, isOnboarding:Boolean = false)
      {
         this.m_window = window;
         this.m_contest = contest;
         this.m_isOnboarding = isOnboarding;
         super(element);
         this.m_slotData = contest.getActiveObjects();
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         refresh();
      }
      
      public function setSlotData(items:Array) : void
      {
         this.m_slotData = items;
         refresh();
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GrowableObjectBaseSlot(this.m_window,slotElement,this.m_contest,this.m_isOnboarding);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.SLOT_PREFIX;
      }
      
      public function refreshSlotButtons() : void
      {
         var slot:GrowableObjectBaseSlot = null;
         for each(slot in m_slots)
         {
            slot.refreshFieldsAndButtons();
         }
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BUGFIX_SLOT_CONTAINER_RELEASE) == 0)
         {
            for each(slot in m_slots)
            {
               slot.release();
            }
         }
         super.release();
      }
   }
}

