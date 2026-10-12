package Widgets.Windows.QuestManager
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class QMWReplayableQuestsBaseSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_mainWindow:QuestManagerWindowV2 = null;
      
      public function QMWReplayableQuestsBaseSlotFrame(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         this.m_mainWindow = mainWindow;
         super(element);
      }
      
      override public function refresh() : void
      {
         setupData();
         super.refresh();
      }
      
      protected function setUpPagingArrows() : void
      {
         if(m_element.arrowUp_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.arrowDown_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
   }
}

