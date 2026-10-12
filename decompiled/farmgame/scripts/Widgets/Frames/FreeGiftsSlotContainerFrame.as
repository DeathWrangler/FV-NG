package Widgets.Frames
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FreeGiftsSlot;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FreeGiftsSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public static var firstPage:int = 1;
      
      private var m_ref:String = "";
      
      private var m_freeGifts:Array = null;
      
      private var m_parentWindow:FarmWindow = null;
      
      private var m_removedSlots:Array = null;
      
      private const SLOT_RESERVED_FOR_SDB:int = 0;
      
      private var bgslotArray:Array = [1,2,6,7];
      
      public function FreeGiftsSlotContainerFrame(element:DisplayObject, freeGifts:Array = null, ref:String = "free_gifts_full_mfs", parentWindow:FarmWindow = null)
      {
         this.m_ref = ref;
         this.m_freeGifts = freeGifts;
         this.m_parentWindow = parentWindow;
         super(element);
         if(m_element.hasOwnProperty("arrowUp_bt"))
         {
            m_pageBackWidget = addWidget(new FarmAnimatedButton(m_element.arrowUp_bt,this.onPgaeBack)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("arrowDown_bt"))
         {
            m_pageForwardWidget = addWidget(new FarmAnimatedButton(m_element.arrowDown_bt,this.onPageForward)) as ZwWidget;
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         var itemCode:String = null;
         var currentTimeSeconds:int = 0;
         var endDate:String = null;
         var endTimeSeconds:int = 0;
         var sdb:FarmItem = null;
         var index:int = 0;
         var swapItem:FarmItem = null;
         if(this.m_freeGifts != null)
         {
            m_slotData = this.m_freeGifts;
         }
         else if(FreeGiftSelectionWindow.giftsLoaded())
         {
            m_slotData = FreeGiftSelectionWindow.freeGifts;
         }
         else
         {
            m_slotData = new Array();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FREE_GIFT_SELECTION_V1) >= 1)
         {
            itemCode = "Zg";
            currentTimeSeconds = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            endDate = Global.flashHotParams["FREE_GIFT_ITEM_END_DATE"];
            endTimeSeconds = 0;
            if(endDate != "")
            {
               endTimeSeconds = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND);
            }
            if(currentTimeSeconds < endTimeSeconds)
            {
               itemCode = Global.flashHotParams["FREE_GIFT_ITEM_CODE"];
            }
            sdb = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            index = m_slotData.indexOf(sdb);
            if((Boolean(m_pagingComponent && true == m_pagingComponent.isOnFirstPage()) || Boolean(firstPage == 1)) && index > -1)
            {
               if(Boolean(this.m_removedSlots) && this.m_removedSlots.length != 0)
               {
                  m_slots.unshift(this.m_removedSlots[0]);
                  m_slots[10].visible = true;
               }
               this.m_removedSlots = new Array();
               swapItem = m_slotData[this.SLOT_RESERVED_FOR_SDB];
               m_slotData[this.SLOT_RESERVED_FOR_SDB] = sdb;
               m_slotData[index] = swapItem;
               this.removeDuplicate(m_slotData);
               this.hideSlotsAppearingInBG();
            }
            else
            {
               this.showSlotsAppearingInBG();
               if(m_slots.length > 10)
               {
                  m_slots[this.SLOT_RESERVED_FOR_SDB].visible = false;
                  this.m_removedSlots = m_slots.splice(this.SLOT_RESERVED_FOR_SDB,1);
               }
            }
         }
      }
      
      public function update() : void
      {
         m_slotData = new Array();
         this.setupData();
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FreeGiftsSlot(slotElement,this.m_ref,this.m_parentWindow);
      }
      
      public function onPgaeBack(event:Event) : void
      {
         --firstPage;
         m_pagingComponent.onPageBack(event);
         this.update();
      }
      
      public function onPageForward(event:Event) : void
      {
         ++firstPage;
         m_pagingComponent.onPageForward(event);
         this.update();
      }
      
      public function removeDuplicate(arr:Array) : void
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < arr.length - 1; i++)
         {
            for(j = i + 1; j < arr.length; j++)
            {
               if(arr[i] === arr[j])
               {
                  arr.splice(j,1);
               }
            }
         }
      }
      
      public function hideSlotsAppearingInBG() : void
      {
         for(var index:int = 0; index < this.bgslotArray.length; index++)
         {
            m_slotData.push(m_slotData[this.bgslotArray[index]]);
            m_slots[this.bgslotArray[index]].visible = false;
         }
      }
      
      public function showSlotsAppearingInBG() : void
      {
         for(var index:int = 0; index < this.bgslotArray.length; index++)
         {
            m_slots[this.bgslotArray[index]].visible = true;
         }
      }
      
      override public function refresh() : void
      {
         super.refresh();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FREE_GIFT_SELECTION_V1) >= 1)
         {
            if(Boolean(m_pagingComponent) && Boolean(true == m_pagingComponent.isOnFirstPage()) && m_slotData.length > 11)
            {
               m_pagingComponent.maxPageNumber = Math.ceil(m_slotData.length / 10) - 1;
               redrawCurrentPageLabel();
            }
         }
      }
   }
}

