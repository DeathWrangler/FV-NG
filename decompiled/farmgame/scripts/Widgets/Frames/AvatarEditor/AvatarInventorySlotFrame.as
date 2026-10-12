package Widgets.Frames.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.AvatarEditor.AvatarInventorySlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AvatarInventorySlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_selectedItems:Array;
      
      private var m_useItemCallback:Function;
      
      private var m_removeItemCallback:Function;
      
      public function AvatarInventorySlotFrame(element:MovieClip, useItemCallback:Function, removeItemCallback:Function)
      {
         this.m_useItemCallback = useItemCallback;
         this.m_removeItemCallback = removeItemCallback;
         super(element);
         addWidget(new ZwTextField(element.generic_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Inventory_Title")));
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwButton;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      public function get selectedItems() : Array
      {
         return this.m_selectedItems;
      }
      
      public function set selectedItems(value:Array) : void
      {
         var slot:AvatarInventorySlot = null;
         var slotData:AvatarItem = null;
         this.m_selectedItems = value;
         for each(slot in m_slots)
         {
            slotData = slot.data;
            if(this.m_selectedItems != null && slotData != null)
            {
               slot.selected = this.isItemSelected(slotData.itemId);
            }
            else
            {
               slot.selected = false;
            }
         }
      }
      
      public function isItemSelected(itemId:String) : Boolean
      {
         var isItemSelected:Boolean = false;
         if(this.m_selectedItems != null && this.m_selectedItems.indexOf(itemId) >= 0)
         {
            isItemSelected = true;
         }
         else
         {
            isItemSelected = false;
         }
         return isItemSelected;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AvatarInventorySlot(slotElement,this,this.m_useItemCallback,this.m_removeItemCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         this.m_selectedItems = null;
         this.m_useItemCallback = null;
         this.m_removeItemCallback = null;
         super.release();
      }
   }
}

