package Widgets.Frames
{
   import Managers.TurtleInnovationManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.TurtleInnovationGiftSlot;
   import Widgets.Windows.TurtleInnovationCollectionWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TurtleInnovationGiftFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private var m_collectionWindow:TurtleInnovationCollectionWindow;
      
      private const PAGE_TF:String = "page_tf";
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private const MAX_PAGE:int = 4;
      
      public function TurtleInnovationGiftFrame(element:DisplayObject, featureName:String, collectionWindow:TurtleInnovationCollectionWindow)
      {
         this.m_featureName = featureName;
         this.m_collectionWindow = collectionWindow;
         super(element);
         m_pagingComponent.maxPageNumber = this.MAX_PAGE;
         if(m_element[this.PAGE_TF])
         {
            m_currentPageLabel = new ZwTextField(m_element[this.PAGE_TF],"Page 1 of " + m_pagingComponent.maxPageNumber);
            addWidget(m_currentPageLabel);
         }
         if(m_element[this.BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[this.BACK_BT],this.onpageBackward);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[this.NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[this.NEXT_BT],this.onpageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      private function onpageBackward(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         if(pageNumber == 0)
         {
            this.m_collectionWindow.showR2Highlight();
         }
      }
      
      private function onpageForward(event:Event) : void
      {
         if(pageNumber == 0)
         {
            this.m_collectionWindow.hideR2Highlight();
         }
         m_pagingComponent.onPageForward(event);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TurtleInnovationGiftSlot(slotElement,this.m_featureName,this);
      }
      
      override protected function setupData() : void
      {
         var turtleInnovationSlotData:Object = TurtleInnovationManager.getInstance().collections;
         for(var i:int = 0; i < turtleInnovationSlotData.length; i++)
         {
            if(!(turtleInnovationSlotData[i].region == 2 && !TurtleInnovationManager.getInstance().isR2Unlocked()))
            {
               m_slotData.push(turtleInnovationSlotData[i]);
            }
         }
      }
   }
}

