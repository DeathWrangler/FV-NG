package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.MultiMasterySlot;
   import flash.display.DisplayObject;
   
   public class RecipeMultiMasterySlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot";
      
      protected var m_items:Array = null;
      
      public function RecipeMultiMasterySlotFrame(element:DisplayObject, items:Array)
      {
         this.m_items = items;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","Mastery_MultipleTitle")));
         refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MultiMasterySlot(slotElement);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
   }
}

