package Widgets.Frames.Garage
{
   import Classes.GarageBuilding;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Garage.GarageSelectSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class GarageSelectSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_upgradeCallback:Function;
      
      private var m_mainWindow:FarmWindow;
      
      private var m_isGift:Boolean;
      
      public function GarageSelectSlotFrame(element:DisplayObject, garage:GarageBuilding, upgradeCallback:Function, mainWindow:FarmWindow, isGift:Boolean)
      {
         this.m_mainWindow = mainWindow;
         this.m_upgradeCallback = upgradeCallback;
         this.m_isGift = isGift;
         super(element);
         var leftArrow:ZwButton = new ZwButton(m_element.backArrow_bt,m_pagingComponent.onPageBack);
         var rightArrow:ZwButton = new ZwButton(m_element.nextArrow_bt,m_pagingComponent.onPageForward);
         addWidget(leftArrow);
         addWidget(rightArrow);
         m_slotData = this.parseGarageData(garage);
         m_slotData.sortOn("numParts",Array.NUMERIC);
         this.refresh();
      }
      
      private function parseGarageData(garage:GarageBuilding) : Array
      {
         var objectIdx:int = 0;
         var numObjects:Number = NaN;
         var objectNumIdx:int = 0;
         var garageData:Array = new Array();
         var objects:Array = garage.getContents();
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               numObjects = Number(objects[objectIdx].num);
               for(objectNumIdx = 0; objectNumIdx < numObjects; objectNumIdx++)
               {
                  garageData.push(objects[objectIdx]);
               }
            }
         }
         return garageData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GarageSelectSlot(slotElement,this.m_upgradeCallback,this.m_mainWindow,this.m_isGift);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         var leftArrow:ZwButton = null;
         var rightArrow:ZwButton = null;
         super.refresh();
         if(m_slotData.length <= m_slots.length)
         {
            leftArrow = getWidget(m_element.backArrow_bt) as ZwButton;
            rightArrow = getWidget(m_element.nextArrow_bt) as ZwButton;
            leftArrow.visible = false;
            rightArrow.visible = false;
         }
      }
   }
}

