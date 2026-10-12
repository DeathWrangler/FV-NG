package Widgets.Frames
{
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FishingCollectionSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FishingCollectionWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FishingCollectionFrame extends FarmSlotContainerFrame
   {
      
      private static const BACK_BT:String = "back_bt";
      
      private static const NEXT_BT:String = "next_bt";
      
      private var m_featureName:String = null;
      
      private var m_buyBT:FarmAnimatedCashButton;
      
      private var m_collectionType:int;
      
      private var m_parentWindow:FishingCollectionWindow;
      
      public function FishingCollectionFrame(element:DisplayObject, featureName:String, collectionType:int, parentWindow:FishingCollectionWindow)
      {
         var collectionCost:Number;
         this.m_featureName = featureName;
         this.m_collectionType = collectionType;
         this.m_parentWindow = parentWindow;
         super(element);
         collectionCost = FishingV2Manager.getInstance().getFishCollectionPrice(collectionType);
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buyBT = new FarmAnimatedCashButton(m_element.buy_bt,"Buy",collectionCost.toString(),function(event:Event):void
            {
               FishingV2Manager.getInstance().buyFishCollection(collectionType);
            }),collectionCost > 0);
         }
         if(m_element[BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[BACK_BT],this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[NEXT_BT],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(this.m_buyBT)
         {
            this.m_buyBT.attachTooltip(new FarmTextTooltip("Get one fish of each kind in this collection!"));
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         switch(this.m_collectionType)
         {
            case 0:
               m_slotData = FishingV2Manager.getInstance().getCommonFishCollection();
               break;
            case 1:
               m_slotData = FishingV2Manager.getInstance().getUnCommonFishCollection();
               break;
            case 2:
               m_slotData = FishingV2Manager.getInstance().getRareFishCollection();
         }
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FishingCollectionSlot(slotElement,this.m_featureName,this.m_collectionType,this.m_parentWindow);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "fish_collect_";
      }
      
      private function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      private function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
      
      override public function refresh() : void
      {
         var collectionCost:Number = FishingV2Manager.getInstance().getFishCollectionPrice(this.m_collectionType);
         this.m_buyBT.visible = collectionCost > 0;
         this.m_buyBT.setAmountText(collectionCost.toString());
         this.setupData();
         super.refresh();
      }
   }
}

