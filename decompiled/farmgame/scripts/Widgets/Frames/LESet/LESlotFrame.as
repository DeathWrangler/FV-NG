package Widgets.Frames.LESet
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LESet.LESlot;
   import Widgets.Windows.FarmWindow;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class LESlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private static const ANIMATION_DELAY:Number = 0.3;
      
      private static const ANIMATION_DURATION:Number = 0.75;
      
      protected var m_parentWindow:FarmWindow;
      
      protected var m_leSet:Array = new Array();
      
      private var m_pageNumber:ZwTextField;
      
      protected var m_page:ZwTextField;
      
      public function LESlotFrame(element:DisplayObject, leSet:Array, parentWindow:FarmWindow)
      {
         this.m_leSet = leSet;
         this.m_parentWindow = parentWindow;
         super(element);
         if(this.allowPaging())
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
            if(m_element.page_tf)
            {
               this.m_pageNumber = new ZwTextField(m_element.page_tf);
               addWidget(this.m_pageNumber);
            }
         }
         var numSlots:Number = this.m_slots.length;
         for(var i:int = 0; i < numSlots; i++)
         {
            if(m_slots[i] is LESlot)
            {
               (m_slots[i] as LESlot).slotFrameIndex = i;
            }
            (m_slots[i].element as MovieClip).scaleX = 0;
            (m_slots[i].element as MovieClip).scaleY = 0;
            TweenLite.delayedCall(ANIMATION_DELAY * i,this.animateSlot,[m_slots[i].element]);
         }
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LESlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_leSet;
      }
      
      override public function refresh() : void
      {
         super.refresh();
         if(this.allowPaging())
         {
            if(this.m_pageNumber)
            {
               this.m_pageNumber.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
                  "current":m_pagingComponent.currentPageNumber + 1,
                  "total":m_pagingComponent.maxPageNumber + 1
               });
            }
         }
      }
      
      private function animateSlot(slot:Object) : void
      {
         if(Boolean(slot) && Boolean(slot.effect_mc))
         {
            slot.effect_mc.visible = true;
            slot.effect_mc.play();
         }
         TweenLite.to(slot,ANIMATION_DURATION,{
            "scaleX":1,
            "scaleY":1
         });
      }
      
      protected function allowPaging() : Boolean
      {
         return true;
      }
   }
}

