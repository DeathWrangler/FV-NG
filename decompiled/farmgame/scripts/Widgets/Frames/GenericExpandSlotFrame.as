package Widgets.Frames
{
   import Classes.FeatureComponents.IExpandComponent;
   import Classes.ImageLoader;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GenericExpandSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class GenericExpandSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "giftPanel";
      
      protected static const SLOT_POSTFIX:String = "";
      
      private var m_parentWindow:FarmWindow = null;
      
      private var m_building:StorageBuilding = null;
      
      protected var m_items:Array = null;
      
      protected var m_expandComponent:IExpandComponent = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      private const SLOT_V_PREFIX:String = "mc_Slot_V_";
      
      public function GenericExpandSlotFrame(element:DisplayObject, items:Array, parentWindow:FarmWindow, building:StorageBuilding, expandComponent:IExpandComponent)
      {
         var topTextKey:String = null;
         var topText:String = null;
         var bottomTextKey:String = null;
         var bottomText:String = null;
         var slot80BGPath:String = null;
         this.m_parentWindow = parentWindow;
         this.m_building = building;
         this.m_items = items;
         this.m_expandComponent = expandComponent;
         super(element);
         var buildingItemName:String = building.getItem().name;
         var expansionComplete:Boolean = !this.m_expandComponent.hasNextExpansion();
         if(m_element.generic_tf)
         {
            topTextKey = buildingItemName + (expansionComplete ? "_Expansion_Complete" : "_Expansion_NotComplete");
            topText = ZLocUtils.hasString("Dialogs",topTextKey) ? ZLocUtils.t("Dialogs",topTextKey) : "";
            addWidget(new ZwTextField(m_element.generic_tf,topText));
         }
         if(m_element.generic1_tf)
         {
            bottomTextKey = buildingItemName + (expansionComplete ? "_Expansion_BottomText_Complete" : "_Expansion_BottomText_NotComplete");
            bottomText = ZLocUtils.hasString("Dialogs",bottomTextKey) ? ZLocUtils.t("Dialogs",bottomTextKey) : "";
            if(bottomText)
            {
               addWidget(new ZwTextField(m_element.generic1_tf,bottomText));
            }
         }
         for(var levelIndex:int = 0; m_element.hasOwnProperty(this.SLOT_V_PREFIX + levelIndex); levelIndex++)
         {
            slot80BGPath = Global.worldSettingsManager.getSlotBGImagePath("V80");
            if(slot80BGPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(slot80BGPath)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_element[this.SLOT_V_PREFIX + levelIndex].addChild(this.m_slotBGIcon);
                  m_element[this.SLOT_V_PREFIX + levelIndex].visible = true;
               }
            }
         }
         refresh();
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      public function setItemData(items:Array) : void
      {
         this.m_items = items;
         this.setupData();
         populateSlots();
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var expansionComplete:Boolean = !this.m_expandComponent.hasNextExpansion();
         var index:uint = 1;
         if(!expansionComplete)
         {
            while(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()])
            {
               slot = this.createSlot(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()]);
               addWidget(slot,false);
               m_slots.push(slot);
               index++;
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var forceFrictionless:Boolean = false;
         if(Boolean(this.m_building) && Boolean(this.m_expandComponent))
         {
            forceFrictionless = this.m_expandComponent.frictionless;
         }
         return new GenericExpandSlot(slotElement,this.m_parentWindow,this.m_building,this.m_expandComponent,forceFrictionless);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_items;
         var numSlots:int = int(m_slots.length);
         if(Boolean(this.m_items) && Boolean(this.m_items.length < numSlots) && numSlots > 0)
         {
            this.recenterSlots();
         }
      }
      
      private function recenterSlots() : void
      {
         var numSlotsShown:int = int(this.m_items.length);
         var numSlotsTotal:int = int(m_slots.length);
         var slotWidth:Number = (m_slots[0] as ZwSlotFrame).width;
         for(var idx:int = 0; idx < numSlotsShown; idx++)
         {
            (m_slots[idx] as ZwSlotFrame).x += slotWidth / 2 * (numSlotsTotal - numSlotsShown);
         }
      }
   }
}

