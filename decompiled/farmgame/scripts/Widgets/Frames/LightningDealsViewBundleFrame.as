package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.LightningDealsViewBundleSlot;
   import flash.display.DisplayObject;
   
   public class LightningDealsViewBundleFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private var m_bundleItem:FarmItem;
      
      public function LightningDealsViewBundleFrame(element:DisplayObject, featureName:String, bundleItem:FarmItem)
      {
         this.m_featureName = featureName;
         this.m_bundleItem = bundleItem;
         super(element);
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         if(m_element.page_tf)
         {
            m_currentPageLabel = new ZwTextField(m_element.page_tf);
            addWidget(m_currentPageLabel,true);
            m_currentPageLabel.visible = true;
         }
         if(m_element.back_bt)
         {
            m_pageBackWidget = new ZwButton(m_element["back_bt"],m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element["next_bt"] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element["next_bt"],m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
            m_pageForwardWidget.visible = m_pagingComponent.maxPageNumber > 0;
         }
         m_currentPageLabel.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
         m_currentPageLabel.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LightningDealsViewBundleSlot(slotElement,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         var data:Array = null;
         var itemName:String = null;
         var result:Object = this.m_bundleItem.getRewardsPackageHash();
         data = new Array();
         var index:* = 1;
         for(itemName in result)
         {
            data.push({
               "itemName":itemName,
               "index":index++
            });
         }
         m_slotData = data;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
   }
}

