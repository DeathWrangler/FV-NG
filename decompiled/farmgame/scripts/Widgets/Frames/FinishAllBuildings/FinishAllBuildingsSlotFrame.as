package Widgets.Frames.FinishAllBuildings
{
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FinishAllBuildings.FinishAllBuildingsSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FinishAllBuildingsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_POSTFIX:String = "";
      
      public static const NUM_SLOTS:int = 5;
      
      private var m_saleItemsInfo:Array = null;
      
      private var m_pageNumTextField:ZwTextField;
      
      public function FinishAllBuildingsSlotFrame(element:DisplayObject, items:Array)
      {
         this.m_saleItemsInfo = items;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,this.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,this.onPageForward)) as ZwButton;
         refresh();
         this.m_pageNumTextField = addWidget(new ZwTextField(m_element.page_tf,ZLocUtils.t("Dialogs","limitedSalePageCount",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         }))) as ZwTextField;
      }
      
      override public function release() : void
      {
         var slot:FinishAllBuildingsSlot = null;
         for each(slot in m_slots)
         {
            slot.removeEventListener(FinishAllBuildingsSlot.BUY_CLICKED_EVENT,this.onSlotBuyClicked);
         }
         super.release();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slotNumIndex:int = slotElement.name.indexOf("_") + 1;
         var slotNum:int = parseInt(slotElement.name.charAt(slotNumIndex));
         var result:FinishAllBuildingsSlot = new FinishAllBuildingsSlot(slotElement,slotNum);
         result.addEventListener(FinishAllBuildingsSlot.BUY_CLICKED_EVENT,this.onSlotBuyClicked);
         return result;
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_saleItemsInfo;
      }
      
      private function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         this.updatePageText();
      }
      
      private function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
         this.updatePageText();
      }
      
      private function updatePageText() : void
      {
         this.m_pageNumTextField.text = ZLocUtils.t("Dialogs","limitedSalePageCount",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
      }
      
      private function onSlotBuyClicked(event:Event) : void
      {
         var building:StorageBuilding = null;
         var idx:int = 0;
         var len:int = 0;
         if(event.target.hasOwnProperty("data"))
         {
            building = (event.target as FinishAllBuildingsSlot).data;
            len = int(this.m_saleItemsInfo.length);
            for(idx = 0; idx < len; idx++)
            {
               if(building == this.m_saleItemsInfo[idx])
               {
                  break;
               }
            }
            GlobalEngine.assert(idx < len,"building not found in main array");
            this.m_saleItemsInfo.splice(idx,1);
            if(this.m_saleItemsInfo.length > 0)
            {
               this.refresh();
               this.updatePageText();
            }
         }
         dispatchEvent(event);
      }
   }
}

