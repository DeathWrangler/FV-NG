package Widgets.Frames
{
   import Classes.Constants.Experiments;
   import Classes.MystreeNursery;
   import Managers.MystreeNurseryManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.MystreeNurserySlot;
   import Widgets.Windows.MystreeNurseryWindow;
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   
   public class MystreeNurseryFrame extends FarmSlotContainerFrame
   {
      
      private var m_owner:DisplayObject;
      
      private var m_window:MystreeNurseryWindow;
      
      public function MystreeNurseryFrame(element:DisplayObject, parentWindow:MystreeNurseryWindow)
      {
         this.m_window = parentWindow;
         super(element);
         m_pagingComponent.maxPageNumber = 1;
         if(m_element.leftArrow_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.rightArrow_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MystreeNurserySlot(slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var plotId:String = null;
         var mystreeNursery:MystreeNursery = MystreeNurseryManager.getInstance().getNurseryInstance();
         var mystreeData:Dictionary = mystreeNursery.getStorageData();
         for(plotId in mystreeData)
         {
            m_slotData.push({"plotNumber":plotId});
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

