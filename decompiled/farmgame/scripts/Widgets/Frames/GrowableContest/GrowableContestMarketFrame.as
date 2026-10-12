package Widgets.Frames.GrowableContest
{
   import Classes.Growable.GrowableContest;
   import Classes.util.ObjectUtil;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.GrowableObjectMarketSlot;
   import Widgets.Windows.GrowableContestWindow;
   import flash.display.DisplayObject;
   
   public class GrowableContestMarketFrame extends FarmSlotContainerFrame
   {
      
      private const FEATURE_DIALOG_PREFIX:String = "MarketSlotFrame_";
      
      private var m_contest:GrowableContest;
      
      private var m_isOnboarding:Boolean;
      
      private const SLOT_PREFIX:String = "cell";
      
      private var m_tutorialOverlay:ZwWidget;
      
      private var m_marketTextField:ZwTextField;
      
      private var m_window:GrowableContestWindow;
      
      public function GrowableContestMarketFrame(window:GrowableContestWindow, element:DisplayObject, contest:GrowableContest, isOnboarding:Boolean = false)
      {
         this.m_window = window;
         this.m_contest = contest;
         this.m_isOnboarding = isOnboarding;
         super(element);
         this.m_slotData = this.m_contest.getMarketCodes();
         if(m_element.tutorial_mc)
         {
            this.m_tutorialOverlay = new ZwWidget(m_element.tutorial_mc);
            addWidget(this.m_tutorialOverlay);
            this.m_tutorialOverlay.visible = this.m_isOnboarding;
         }
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
         if(ObjectUtil.pathExists(m_element,"marketText_tf"))
         {
            this.m_marketTextField = new ZwTextField(m_element["marketText_tf"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "MarketText"));
            addWidget(this.m_marketTextField);
         }
         refresh();
      }
      
      override public function release() : void
      {
         this.m_contest = null;
         this.m_window = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GrowableObjectMarketSlot(this.m_window,slotElement,this.m_contest);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.SLOT_PREFIX;
      }
   }
}

