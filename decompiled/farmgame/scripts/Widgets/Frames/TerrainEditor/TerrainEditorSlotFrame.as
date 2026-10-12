package Widgets.Frames.TerrainEditor
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.TerrainEditor.TerrainEditorSlot;
   import Widgets.Windows.TerrainEditor.TerrainEditorWindow;
   import flash.display.DisplayObject;
   
   public class TerrainEditorSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_terrainEditorWindow:TerrainEditorWindow;
      
      public function TerrainEditorSlotFrame(element:DisplayObject, items:Array, terrainEditorWindow:TerrainEditorWindow)
      {
         this.m_items = items;
         this.m_terrainEditorWindow = terrainEditorWindow;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward)) as ZwButton;
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         adjustPagingWidgetVisibility();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TerrainEditorSlot(slotElement,this.m_terrainEditorWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_terrainEditorWindow = null;
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

