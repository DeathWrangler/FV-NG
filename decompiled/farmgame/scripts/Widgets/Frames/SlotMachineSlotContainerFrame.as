package Widgets.Frames
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.SlotMachineFManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SlotMachine.SlotMachineCollectionComplete;
   import Widgets.Frames.SlotMachine.SlotMachineCollectionLocked;
   import Widgets.Frames.SlotMachine.SlotMachineRewardLocked;
   import Widgets.Frames.SlotMachine.SlotMachineRewardUnlocked;
   import Widgets.Slots.SlotMachine.SlotMachineCollectionsSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class SlotMachineSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_building:FeatureBuilding;
      
      private var m_titleLabel:ZwTextField;
      
      private var m_levelNumLabel:ZwTextField;
      
      private var m_inProgressMessage:ZwTextField;
      
      private var m_lockedFrame:SlotMachineCollectionLocked;
      
      private var m_collectionCompleteFrame:SlotMachineCollectionComplete;
      
      private var m_rewardLockedFrame:SlotMachineRewardLocked;
      
      private var m_rewardUnlockedFrame:SlotMachineRewardUnlocked;
      
      public function SlotMachineSlotContainerFrame(element:DisplayObject, fbuilding:FeatureBuilding)
      {
         var buildingName:String = null;
         super(element);
         this.m_building = fbuilding;
         if(this.m_building.slotmachine)
         {
            buildingName = this.m_building.getItem().name;
            this.m_titleLabel = addWidget(new ZwTextField(m_element.title_tf,"")) as ZwTextField;
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",buildingName + "_SlotBarLvl")));
            this.m_levelNumLabel = addWidget(new ZwTextField(m_element.generic2_tf,"")) as ZwTextField;
            this.m_lockedFrame = addWidget(new SlotMachineCollectionLocked(m_element.collectionLocked_mc,buildingName)) as SlotMachineCollectionLocked;
            this.m_inProgressMessage = addWidget(new ZwTextField(m_element.generic3_tf,ZLocUtils.t("Dialogs",buildingName + "_CompleteToLevelUp"))) as ZwTextField;
            m_pageBackWidget = addWidget(new ZwButton(m_element.arrowLeft_bt,this.onPageBack)) as ZwWidget;
            m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowRight_bt,this.onPageForward)) as ZwWidget;
            this.m_collectionCompleteFrame = addWidget(new SlotMachineCollectionComplete(m_element.collectionComplete_mc,buildingName)) as SlotMachineCollectionComplete;
            this.m_rewardLockedFrame = addWidget(new SlotMachineRewardLocked(m_element.rewardLocked_mc,buildingName)) as SlotMachineRewardLocked;
            this.m_rewardUnlockedFrame = addWidget(new SlotMachineRewardUnlocked(m_element.rewardUnlocked_mc,buildingName,this.m_building.slotmachine.onClaimReward)) as SlotMachineRewardUnlocked;
            this.refreshCollectibleData(false);
            this.scrollToCurrentTier();
            this.refresh();
            return;
         }
         throw new Error("Error: SlotMachineSlotContainterFrame can\'t be initialized without a FeatureComponents.SlotMachineFManager.");
      }
      
      public function onPageBack(event:Event) : void
      {
         this.refreshCollectibleData(false);
         m_pagingComponent.onPageBack(event);
      }
      
      public function onPageForward(event:Event) : void
      {
         this.refreshCollectibleData(false);
         m_pagingComponent.onPageForward(event);
      }
      
      public function refreshCollectibleData(doUIRefresh:Boolean = true) : void
      {
         this.m_building.slotmachine.refreshPrizes();
         m_slotData = this.m_building.slotmachine.collectibleData;
         if(doUIRefresh)
         {
            this.refresh();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SlotMachineCollectionsSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         super.refresh();
         this.refreshReward();
         if(m_pagingComponent != null)
         {
            this.m_levelNumLabel.text = String(Global.player.getActionCount(SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE) * this.m_building.slotmachine.levelCollections.length + m_pagingComponent.currentPageNumber + 1);
            this.m_titleLabel.text = ZLocUtils.tk_pk_asTitle(this.m_building.slotmachine.getCollectionLevelName(m_pagingComponent.currentPageNumber + 1));
         }
      }
      
      public function update(data:Array) : void
      {
         this.refresh();
      }
      
      private function refreshReward() : void
      {
         var buildingName:String = null;
         var slotmachine:SlotMachineFManager = null;
         var currentProgressionLevel:Number = NaN;
         var currentPageNumber:Number = NaN;
         var tabComplete:Boolean = false;
         var rewardReadyToClaim:Boolean = false;
         var rewardItem:FarmItem = null;
         if(m_pagingComponent != null)
         {
            buildingName = this.m_building.getItem().name;
            slotmachine = this.m_building.slotmachine;
            currentProgressionLevel = parseInt(slotmachine.currentLevel);
            currentPageNumber = Number(m_pagingComponent.currentPageNumber);
            tabComplete = false;
            if(slotmachine.currentLevel == SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE || currentPageNumber < currentProgressionLevel)
            {
               tabComplete = true;
            }
            this.m_collectionCompleteFrame.visible = tabComplete;
            this.m_rewardUnlockedFrame.updateClaimed(tabComplete);
            rewardReadyToClaim = currentPageNumber == currentProgressionLevel && slotmachine.canCompleteCurrentLevel;
            this.m_rewardUnlockedFrame.visible = true;
            this.m_rewardLockedFrame.visible = false;
            rewardItem = this.getRewardItem();
            if(rewardItem != null)
            {
               this.m_rewardUnlockedFrame.setReward(rewardItem,rewardReadyToClaim,currentPageNumber - currentProgressionLevel + 1);
            }
            if(tabComplete)
            {
               this.m_lockedFrame.visible = false;
               this.m_inProgressMessage.visible = false;
            }
            else
            {
               this.m_lockedFrame.visible = currentPageNumber > 0 && currentPageNumber > currentProgressionLevel;
               this.m_inProgressMessage.visible = !this.m_lockedFrame.visible;
               if(this.m_inProgressMessage.visible)
               {
                  if(rewardReadyToClaim)
                  {
                     this.m_inProgressMessage.text = ZLocUtils.t("Dialogs",buildingName + "_CollectionComplete");
                  }
                  else
                  {
                     this.m_inProgressMessage.text = ZLocUtils.t("Dialogs",buildingName + "_CompleteToLevelUp");
                  }
               }
            }
         }
      }
      
      public function scrollToCurrentTier() : void
      {
         var slotmachine:SlotMachineFManager = this.m_building.slotmachine;
         var currentProgressionLevel:Number = parseInt(slotmachine.currentLevel);
         m_pagingComponent.currentPageNumber = currentProgressionLevel;
      }
      
      public function slotIndexOfItem(item:FarmItem) : Number
      {
         var result:Number = 0;
         for(var i:Number = 0; i < m_slotData.length; i++)
         {
            if(m_slotData[i].item.name == item.name)
            {
               result = i % this.totalSlots();
               break;
            }
         }
         return result;
      }
      
      private function getRewardItem() : FarmItem
      {
         var rewardItem:FarmItem = null;
         var rewardData:Array = this.m_building.slotmachine.rewardData;
         if(m_pagingComponent.currentPageNumber < rewardData.length && rewardData[m_pagingComponent.currentPageNumber] != null)
         {
            rewardItem = rewardData[m_pagingComponent.currentPageNumber].item;
         }
         return rewardItem;
      }
      
      override public function release() : void
      {
         m_pageBackWidget = null;
         m_pageForwardWidget = null;
         super.release();
      }
   }
}

