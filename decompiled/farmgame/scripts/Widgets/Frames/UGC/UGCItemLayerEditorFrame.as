package Widgets.Frames.UGC
{
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.UGC.UGCItemLayerState;
   import Classes.UGC.UGCItemState;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Events.DynamicObjectEvent;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwAbstractToggleSlotContainerFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.UGC.UGCItemLayerItemSlot;
   import Widgets.Slots.ZwToggleSlotFrame;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class UGCItemLayerEditorFrame extends ZwAbstractToggleSlotContainerFrame
   {
      
      private static const SLOT_PREFIX:String = "slot";
      
      private static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_layerDefinition:UGCItemLayerDefinition;
      
      protected var m_ugcItemState:UGCItemState;
      
      public function UGCItemLayerEditorFrame(element:DisplayObject, ugcItemState:UGCItemState)
      {
         super(element);
         m_toggleManager.allowDeselectOnClick = true;
         this.m_ugcItemState = ugcItemState;
         if(ObjectUtil.pathExists(element,"arrowLeft_bt"))
         {
            m_pageBackWidget = new ZwButton(element["arrowLeft_bt"],this.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(ObjectUtil.pathExists(element,"arrowRight_bt"))
         {
            m_pageForwardWidget = new ZwButton(element["arrowRight_bt"],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      public function get ugcItemState() : UGCItemState
      {
         return this.m_ugcItemState;
      }
      
      public function set ugcItemState(value:UGCItemState) : void
      {
         if(this.m_ugcItemState != value)
         {
            this.m_ugcItemState = value;
            refresh();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:UGCItemLayerItemSlot = new UGCItemLayerItemSlot(slotElement);
         slot.registerEventListener(MouseEvent.CLICK,this.onItemClick);
         return slot;
      }
      
      override protected function populateSlots(dataIndex:uint = 0) : void
      {
         m_toggleManager.deselectToggles();
         super.populateSlots(dataIndex);
      }
      
      override protected function populateSlot(slot:ZwSlotFrame, data:Object) : void
      {
         super.populateSlot(slot,data);
         var toggleSlot:ZwToggleSlotFrame = slot as ZwToggleSlotFrame;
         var item:FarmItem = data as FarmItem;
         var ugcLayerState:UGCItemLayerState = this.m_ugcItemState.getLayerStateByDefinition(this.m_layerDefinition);
         if(ugcLayerState == null && item != null && this.m_ugcItemState != null && this.m_ugcItemState.itemCode == item.code)
         {
            m_toggleManager.performToggle(m_toggleMap[toggleSlot]);
         }
         else if(toggleSlot != null && item != null && ugcLayerState != null && ugcLayerState.itemCode == item.code)
         {
            m_toggleManager.performToggle(m_toggleMap[toggleSlot]);
         }
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_layerDefinition == null ? [] : this.m_layerDefinition.items;
      }
      
      public function get ugcLayer() : UGCItemLayerDefinition
      {
         return this.m_layerDefinition;
      }
      
      public function set ugcLayer(value:UGCItemLayerDefinition) : void
      {
         if(this.m_layerDefinition != value)
         {
            this.m_layerDefinition = value;
            m_pagingComponent.currentPageNumber = 0;
            this.setupData();
            refresh();
         }
      }
      
      protected function onItemClick(event:MouseEvent) : void
      {
         var slot:UGCItemLayerItemSlot = getWidgetFromEvent(event) as UGCItemLayerItemSlot;
         if(slot)
         {
            if(Boolean(slot.tooltip) && slot.item is IUGCItem)
            {
               slot.tooltip.release();
            }
            dispatchEvent(new DynamicObjectEvent(UGCConstants.EVENT_SELECT_ITEM,{
               "layer":this.m_layerDefinition,
               "item":slot.item,
               "showPreview":slot.showPreview()
            }));
         }
      }
      
      protected function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      protected function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
   }
}

