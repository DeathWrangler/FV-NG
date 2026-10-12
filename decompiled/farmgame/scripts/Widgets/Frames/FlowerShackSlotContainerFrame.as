package Widgets.Frames
{
   import Managers.FlowerShackManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FlowerShackSlot;
   import Widgets.Windows.FlowerShackWindow;
   import flash.display.DisplayObject;
   
   public class FlowerShackSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_owner:DisplayObject;
      
      private var m_featureName:String;
      
      public function FlowerShackSlotContainerFrame(element:DisplayObject, owner:DisplayObject, featureName:String)
      {
         this.m_owner = owner;
         this.m_featureName = featureName;
         super(element);
         m_pagingComponent.maxPageNumber = 1;
         if(m_element.back_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.back_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.next_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.next_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         this.refreshPage();
      }
      
      private function refreshPage() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         if(this.m_owner)
         {
            (this.m_owner as FlowerShackWindow).updatePagination(m_pagingComponent.currentPageNumber,m_pagingComponent.maxPageNumber);
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
         if(this.m_owner)
         {
            (this.m_owner as FlowerShackWindow).updatePagination(m_pagingComponent.currentPageNumber,m_pagingComponent.maxPageNumber);
         }
      }
      
      override protected function setupData() : void
      {
         var blossoms:Array = null;
         var bouquets:Array = null;
         var i:int = 0;
         m_slotData = new Array();
         var itemObj:Object = FlowerShackManager.getInstance(this.m_featureName).getFlowerShackBlossomItems();
         if(Boolean(itemObj) && itemObj.hasOwnProperty("blossoms"))
         {
            blossoms = itemObj["blossoms"] as Array;
            bouquets = itemObj["bouquets"] as Array;
            if(blossoms.length == bouquets.length)
            {
               for(i = 0; i < blossoms.length; i++)
               {
                  if(bouquets[i])
                  {
                     m_slotData.push({
                        "blossom":blossoms[i],
                        "bouquet":bouquets[i]
                     });
                  }
               }
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FlowerShackSlot(slotElement,this.m_owner,this.m_featureName);
      }
   }
}

