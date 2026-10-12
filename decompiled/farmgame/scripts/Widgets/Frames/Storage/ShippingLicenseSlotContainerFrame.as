package Widgets.Frames.Storage
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.ExpansionData;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Storage.ShippingLicenseSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ShippingLicenseSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function ShippingLicenseSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         this.m_pageBackWidget = addWidget(new ZwButton(MovieClip(element).arrowUp_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new ZwButton(MovieClip(element).arrowDown_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         var worlds:Array = Global.worldManager.unlockedWorldTypes;
         var expansionData:ExpansionData = null;
         var worldsLength:int = int(worlds.length);
         for(var worldIdx:* = int(worldsLength - 1); worldIdx >= 0; worldIdx--)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worlds[worldIdx]);
            if(Boolean(expansionData) && this.showWorldLicenceOrNot(worlds[worldIdx]))
            {
               m_slotData.push({
                  "type":worlds[worldIdx],
                  "friendlyName":expansionData.friendlyName,
                  "itemName":expansionData.shippingLicenseItemName,
                  "hasLicense":Global.worldManager.hasWorldContentLicense(worlds[worldIdx],"world"),
                  "iconUrl":expansionData.hudIcon
               });
            }
         }
      }
      
      private function showWorldLicenceOrNot(worldType:String) : Boolean
      {
         var flag:Boolean = true;
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_HALLOW:
               flag = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HALLOW_SHIPPING_LICENSE) > 0;
               break;
            case WorldsConstants.WORLD_ID_HTOWN:
               flag = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HTOWN_SHIPPING_LICENSE) > 0;
         }
         return flag;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:ShippingLicenseSlot = new ShippingLicenseSlot(slotElement as MovieClip);
         slot.addEventListener(Event.CLOSE,this.onShippingLicenseSlotEvent);
         return slot;
      }
      
      override public function release() : void
      {
         var numSlots:int = int(this.m_slots.length);
         for(var idx:int = 0; idx < numSlots; idx++)
         {
            ShippingLicenseSlot(m_slots[idx]).removeEventListener(Event.CLOSE,this.onShippingLicenseSlotEvent);
         }
         super.release();
      }
      
      private function onShippingLicenseSlotEvent(event:Event) : void
      {
         dispatchEvent(event);
      }
   }
}

