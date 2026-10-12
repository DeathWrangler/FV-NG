package Widgets.Frames
{
   import Classes.Constants.Experiments;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.DragonBreedingSlot;
   import Widgets.Windows.DragonBreedingWindow;
   import flash.display.DisplayObject;
   
   public class DragonBreedingLairFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = "dragon_pen_finished";
      
      private var m_owner:DisplayObject;
      
      private var m_window:DragonBreedingWindow;
      
      private var m_genderState:String;
      
      private var m_selectedSlot:DragonBreedingSlot = null;
      
      private var m_isSelectedSlotVisible:Boolean = false;
      
      public function DragonBreedingLairFrame(element:DisplayObject, featureName:String, parentWindow:DragonBreedingWindow, genderState:String)
      {
         if(!(!featureName || featureName == ""))
         {
            this.m_featureName = featureName;
         }
         this.m_window = parentWindow;
         this.m_genderState = genderState;
         super(element);
         m_pagingComponent.maxPageNumber = 1;
         if(m_element.leftArrow_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.rightArrow_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DragonBreedingSlot(slotElement,this.m_featureName,this.m_window,this);
      }
      
      override public function refresh() : void
      {
         var slot:DragonBreedingSlot = null;
         this.setupData();
         super.refresh();
         this.m_isSelectedSlotVisible = false;
         var selectedItemCode:String = this.m_genderState == DragonBreedingConfigManager.GENDER_CODE_FEMALE ? this.m_window.selectedFemaleDragonId : this.m_window.selectedMaleDragonId;
         var isVisitingDragonSlot:Boolean = false;
         var isVisitingDragonAvailable:Boolean = this.isValidVistingDragon();
         for each(slot in m_slots)
         {
            if(Boolean(selectedItemCode) && slot.itemCode == selectedItemCode)
            {
               this.m_isSelectedSlotVisible = true;
               slot.setSelectState(true);
            }
            if(isVisitingDragonAvailable)
            {
               if(DragonBreedingManager.getInstance(this.m_featureName).isValidVisitingDragonByItemCode(slot.itemCode))
               {
                  isVisitingDragonSlot = true;
               }
            }
         }
         if(isVisitingDragonAvailable && !isVisitingDragonSlot && this.m_window.isOpenWindow)
         {
            m_pagingComponent.onPageForward(null);
            this.m_window.isOpenWindow = false;
         }
         this.m_window.updateSelectDragonBtn();
      }
      
      private function isValidVistingDragon() : Boolean
      {
         var result:Boolean = false;
         var isTutorialMode:Boolean = DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode();
         var itemCode:String = DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(this.m_genderState);
         if(Boolean(!isTutorialMode && itemCode) && Boolean(itemCode != "") && this.isVisitingDragonSameGender(itemCode))
         {
            if(DragonBreedingManager.getInstance(this.m_featureName).getVistingDragonTimeRemainingByItemCode(itemCode) > -1)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isVisitingDragonSameGender(itemCode:String) : Boolean
      {
         var result:Boolean = false;
         if(DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonGenderType(itemCode) == this.m_genderState)
         {
            result = true;
         }
         return result;
      }
      
      override protected function setupData() : void
      {
         var dragonBreedingData:Object = null;
         var maleItemId:String = null;
         var femaleIndex:int = 0;
         var femaleItemId:String = null;
         m_slotData = new Array();
         if(this.m_genderState == DragonBreedingConfigManager.GENDER_CODE_MALE)
         {
            dragonBreedingData = DragonBreedingManager.getInstance(this.m_featureName).getMutableMaleData();
            for(maleItemId in dragonBreedingData)
            {
               m_slotData.push({
                  "itemCode":maleItemId,
                  "itemData":dragonBreedingData[maleItemId]
               });
            }
            m_slotData = DragonBreedingManager.sortParentDragonItemsBy(m_slotData,this.m_featureName);
         }
         else if(this.m_genderState == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
         {
            dragonBreedingData = DragonBreedingManager.getInstance(this.m_featureName).getMutableFemaleData();
            femaleIndex = 0;
            for(femaleItemId in dragonBreedingData)
            {
               m_slotData.push({
                  "itemCode":femaleItemId,
                  "itemData":dragonBreedingData[femaleItemId]
               });
            }
            m_slotData = DragonBreedingManager.sortParentDragonItemsBy(m_slotData,this.m_featureName);
         }
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BUGFIX_SLOT_CONTAINER_RELEASE) == 0)
         {
            for each(slot in m_slots)
            {
               slot.release();
            }
         }
         this.m_isSelectedSlotVisible = false;
         super.release();
      }
      
      public function set selectedSlot(selectedSlot:DragonBreedingSlot) : void
      {
         this.deselectSlots();
         if(selectedSlot)
         {
            selectedSlot.setSelectState(true);
            this.m_isSelectedSlotVisible = true;
         }
         this.m_selectedSlot = selectedSlot;
         this.m_window.refreshLairWindow();
      }
      
      private function deselectSlots() : void
      {
         var slot:DragonBreedingSlot = null;
         for each(slot in m_slots)
         {
            slot.setSelectState(false);
         }
      }
      
      public function get selectedSlot() : DragonBreedingSlot
      {
         return this.m_selectedSlot;
      }
      
      public function get isSelectedSlotVisible() : Boolean
      {
         return this.m_isSelectedSlotVisible;
      }
      
      public function setEnabled(enable:Boolean, index:int = -1, isTutorialMode:Boolean = false) : void
      {
         var slot:DragonBreedingSlot = null;
         var i:int = 0;
         enabled = enable;
         if(index == -1)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               slot = m_slots[i];
               slot.setEnabled(enable);
            }
            m_pageBackWidget.enabled = enable;
            m_pageForwardWidget.enabled = enable;
         }
         else
         {
            slot = m_slots[index];
            slot.setEnabled(enable,isTutorialMode);
            m_pageBackWidget.enabled = enable;
            m_pageForwardWidget.enabled = enable;
         }
      }
      
      public function getSlotIdByItemCode(itemCode:String) : Number
      {
         var slot:DragonBreedingSlot = null;
         var value:String = null;
         var result:Number = -1;
         for each(slot in m_slots)
         {
            if(Boolean(slot) && slot.itemCode == itemCode)
            {
               value = slot.name;
               result = Number(value.split("_")[1]);
            }
         }
         return Number(result);
      }
   }
}

