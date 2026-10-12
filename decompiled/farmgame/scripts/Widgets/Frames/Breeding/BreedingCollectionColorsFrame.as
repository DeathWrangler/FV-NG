package Widgets.Frames.Breeding
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Breeding.BreedingCollectionColorSlot;
   import flash.display.DisplayObject;
   
   public class BreedingCollectionColorsFrame extends FarmSlotContainerFrame
   {
      
      private var m_breedingCollectionFrame:BreedingCollectionFrame;
      
      public function BreedingCollectionColorsFrame(element:DisplayObject, breedingCollectionFrame:BreedingCollectionFrame)
      {
         this.m_breedingCollectionFrame = breedingCollectionFrame;
         super(element);
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
         adjustPagingWidgetVisibility();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BreedingCollectionColorSlot(slotElement,this.m_breedingCollectionFrame);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set colors(colors:Array) : void
      {
         m_slotData = colors;
         refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "btn_color";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "";
      }
   }
}

