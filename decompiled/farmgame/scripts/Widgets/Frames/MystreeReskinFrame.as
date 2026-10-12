package Widgets.Frames
{
   import Classes.Constants.Experiments;
   import Managers.MystreeReskinManager;
   import Managers.MystreeReskinManagerWithEMH;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.MystreeReskinSlot;
   import Widgets.Windows.IMystreeReskinWindow;
   import flash.display.DisplayObject;
   
   public class MystreeReskinFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private var m_owner:DisplayObject;
      
      private var m_window:IMystreeReskinWindow;
      
      public function MystreeReskinFrame(element:DisplayObject, featureName:String, parentWindow:IMystreeReskinWindow)
      {
         this.m_featureName = featureName;
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
         return new MystreeReskinSlot(slotElement,this.m_featureName,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var plotId:String = null;
         var count:int = 0;
         var mystreeData:Object = MystreeReskinManager.getInstance(this.m_featureName).getPlotData();
         var MystreeEMHManager:MystreeReskinManagerWithEMH = MystreeReskinManagerWithEMH.getInstance(this.m_featureName);
         var difficulty:int = MystreeEMHManager.getDifficultyLevel();
         if(this.m_featureName == "mystree_v9")
         {
            count = 0;
            for(plotId in mystreeData)
            {
               switch(difficulty)
               {
                  case 0:
                     if(count >= 0 && count < 8)
                     {
                        m_slotData.push({"plotNumber":plotId});
                     }
                     break;
                  case 1:
                     if(count >= 8 && count < 16)
                     {
                        m_slotData.push({"plotNumber":plotId});
                     }
                     break;
                  case 2:
                     if(count >= 16 && count < 24)
                     {
                        m_slotData.push({"plotNumber":plotId});
                     }
               }
               count++;
            }
         }
         else
         {
            for(plotId in mystreeData)
            {
               m_slotData.push({"plotNumber":plotId});
            }
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

