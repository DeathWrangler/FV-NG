package Widgets.Frames.Collections
{
   import Classes.Collections.Collection;
   import Managers.CollectionsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Collections.CollectionThumbSlot;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   
   public class CollectionsThumbsFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:CollectionsWindow;
      
      public function CollectionsThumbsFrame(element:DisplayObject, parentWindow:CollectionsWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         m_slotData = CollectionsManager.getInstance().getAllCollections();
         this.refresh();
      }
      
      public function highlightThumbnail(collection:Collection, navigateTo:Boolean = false) : void
      {
         var collectionIndex:int = 0;
         var i:int = 0;
         var slotCollection:Collection = null;
         var slot:CollectionThumbSlot = null;
         if(collection != null)
         {
            collectionIndex = -1;
            for(i = 0; i < this.m_slotData.length; i++)
            {
               slotCollection = m_slotData[i];
               if(slotCollection.name == collection.name)
               {
                  collectionIndex = i;
                  break;
               }
            }
            if(collectionIndex >= 0)
            {
               if(navigateTo)
               {
                  pageNumber = Math.floor(collectionIndex / m_slots.length);
                  slot = m_slots[collectionIndex - Math.floor(collectionIndex / m_slots.length) * m_slots.length];
                  slot.highlightBackground();
               }
               else if(collectionIndex < m_slots.length)
               {
                  slot = m_slots[collectionIndex];
                  slot.highlightBackground();
               }
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CollectionThumbSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
      }
      
      override public function refresh() : void
      {
         super.refresh();
      }
   }
}

