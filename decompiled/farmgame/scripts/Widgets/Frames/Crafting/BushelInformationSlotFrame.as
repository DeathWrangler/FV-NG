package Widgets.Frames.Crafting
{
   import Classes.crafting.BushelsFoundSummary;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.BushelSummarySlot;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BushelInformationSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_BushelSummariesItems:Array = null;
      
      protected var m_Element:MovieClip;
      
      protected var m_OnItemSharedCallback:Function;
      
      protected var m_OnCancelItemCallback:Function;
      
      private var m_leftButton:ZwButton;
      
      private var m_rightButton:ZwButton;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_checkBox:MovieClip;
      
      private var m_checkMark:MovieClip;
      
      private var m_selected:Boolean;
      
      private var m_checkBoxText:ZwTextField;
      
      private var m_cancelButton:FarmAnimatedTextButton;
      
      private var m_okayButton:FarmAnimatedTextButton;
      
      private var m_bottomText:ZwTextField;
      
      public function BushelInformationSlotFrame(element:MovieClip, items:Array, onSharedItemCallback:Function, onCancelItemCallback:Function)
      {
         this.m_BushelSummariesItems = items;
         this.m_OnItemSharedCallback = onSharedItemCallback;
         this.m_OnCancelItemCallback = onCancelItemCallback;
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            if(element.okay_bt)
            {
               this.m_shareButton = new FarmAnimatedTextButton(element.okay_bt,ZLocUtils.t("Dialogs","Continue"),this.onContinueClicked);
            }
            if(element.checkMark_mc)
            {
               this.m_checkMark = element.checkMark_mc as MovieClip;
               this.m_checkMark.mouseEnabled = true;
               this.m_checkMark.visible = this.m_selected = true;
               this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
            }
            if(element.checkBox_mc)
            {
               this.m_checkBox = element.checkBox_mc as MovieClip;
               this.m_checkBox.addEventListener(MouseEvent.CLICK,this.onClick);
               this.m_checkBox.visible = true;
            }
            if(element.checkbox_tf)
            {
               element.checkbox_tf.visible = true;
               this.m_checkBoxText = new ZwTextField(element.checkbox_tf);
               this.m_checkBoxText.text = ZLocUtils.t("Dialogs","OpenStallBushelFriendReward_stall_open");
            }
         }
         else
         {
            this.m_shareButton = new FarmAnimatedTextButton(element.share_bt,ZLocUtils.t("Dialogs","Share"),this.onShareClicked);
            this.m_okayButton = new FarmAnimatedTextButton(element.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onCancelClicked);
         }
         super(element);
         addWidget(new ZwTextField(element.goldTitle_tf,ZLocUtils.t("Crafting","BushelInformationWindow_Title")));
         addWidget(new ZwFrame(element.background_mc));
         this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         this.m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         this.m_Element = element;
         this.m_leftButton = new ZwButton(element.arrowButtonLeft_mc,m_pagingComponent.onPageBack);
         this.m_rightButton = new ZwButton(element.arrowButtonRight_mc,m_pagingComponent.onPageForward);
         addWidget(this.m_leftButton);
         addWidget(this.m_rightButton);
         m_pageBackWidget = this.m_leftButton;
         m_pageForwardWidget = this.m_rightButton;
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            addWidget(this.m_checkBoxText);
         }
         else
         {
            this.m_bottomText = new ZwTextField(element.friends_tf);
            addWidget(this.m_bottomText);
            this.m_cancelButton = new FarmAnimatedTextButton(element.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onCancelClicked);
            addWidget(this.m_cancelButton);
            addWidget(this.m_okayButton);
         }
         addWidget(this.m_shareButton);
         this.refresh();
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      protected function onCancelClicked(e:MouseEvent) : void
      {
         this.m_OnCancelItemCallback(e);
      }
      
      protected function onShareClicked(e:MouseEvent) : void
      {
         this.m_OnItemSharedCallback(this.selectedItem);
         if(this.m_shareButton != null)
         {
            this.m_shareButton.element.alpha = 0.7;
            Utilities.toggleInputOnlySelf(this.m_shareButton.element as InteractiveObject,false);
         }
      }
      
      protected function onContinueClicked(e:MouseEvent) : void
      {
         if(this.m_selected)
         {
            this.onShareClicked(e);
         }
         else
         {
            this.onCancelClicked(e);
         }
      }
      
      private function get selectedItem() : BushelsFoundSummary
      {
         var slot:BushelSummarySlot = null;
         if(m_slots != null && m_slots.length > 0)
         {
            slot = m_slots[0] as BushelSummarySlot;
            return slot.bushelSummaryData;
         }
         return null;
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_BushelSummariesItems;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BushelSummarySlot(slotElement,this.m_shareButton);
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         this.adjustButtonVisibility();
      }
      
      private function adjustButtonVisibility() : void
      {
         var currentItem:BushelsFoundSummary = null;
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            if(this.m_shareButton)
            {
               this.m_shareButton.visible = true;
            }
            if(this.m_checkBox)
            {
               this.m_checkBox.visible = true;
            }
            if(this.m_checkMark)
            {
               this.m_checkMark.visible = true;
            }
            if(this.m_checkBoxText)
            {
               this.m_checkBoxText.visible = true;
            }
         }
         else
         {
            this.m_okayButton.visible = true;
            currentItem = this.selectedItem;
            if(currentItem != null && currentItem.rewardUrl != null)
            {
               this.m_okayButton.visible = false;
               this.m_bottomText.text = ZLocUtils.t("Crafting","BushelInformationWindow_BottomText");
            }
            else
            {
               this.m_bottomText.text = ZLocUtils.t("Crafting","BushelInformationWindow_BottomTextNoFeed");
            }
            this.m_shareButton.visible = this.m_cancelButton.visible = !this.m_okayButton.visible;
         }
      }
      
      public function reload(items:Array) : void
      {
         this.m_BushelSummariesItems = items;
         this.setupData();
         this.m_pagingComponent.currentPageNumber = 0;
         this.refresh();
      }
      
      override protected function setupSlots() : void
      {
         super.setupSlots();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_leftButton = null;
         this.m_rightButton = null;
         this.m_shareButton = null;
         this.m_cancelButton = null;
         this.m_okayButton = null;
         this.m_BushelSummariesItems = null;
         this.m_Element = null;
      }
   }
}

