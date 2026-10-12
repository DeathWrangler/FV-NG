package Widgets.Windows
{
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.FeatureComponents.DragonBreedingState;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.DragonBreedingThankYouFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class DragonBreedingHatcheryFrame extends FarmSlotContainerFrame
   {
      
      private var HATCHERY_SLOT_PREFIX:String = "slot_";
      
      private var HATCHERY_SLOT_POSTFIX:String = "";
      
      private var LEFT_ARROW_BT:String = "leftarrow_bt";
      
      private var RIGHT_ARROW_BT:String = "rightarrow_bt";
      
      private var THANK_YOU_CARD:String = "thankfriend_mc";
      
      private var m_mainWindow:DragonBreedingWindow;
      
      private var m_thankYouFrame:DragonBreedingThankYouFrame;
      
      private var m_featureName:String;
      
      public function DragonBreedingHatcheryFrame(element:DisplayObject, parentWindow:DragonBreedingWindow, featureName:String = "")
      {
         this.m_mainWindow = parentWindow;
         if(Boolean(this.m_mainWindow) && this.m_mainWindow.featureName != "")
         {
            this.m_featureName = this.m_mainWindow.featureName;
         }
         super(element);
         if(m_element)
         {
            if(m_element.hasOwnProperty(this.LEFT_ARROW_BT))
            {
               m_pageBackWidget = addWidget(new ZwButton(m_element[this.LEFT_ARROW_BT],m_pagingComponent.onPageBack)) as ZwButton;
            }
            if(m_element.hasOwnProperty(this.RIGHT_ARROW_BT))
            {
               m_pageForwardWidget = addWidget(new ZwButton(m_element[this.RIGHT_ARROW_BT],m_pagingComponent.onPageForward)) as ZwButton;
            }
            if(m_element.hasOwnProperty(this.THANK_YOU_CARD))
            {
               this.m_thankYouFrame = addWidget(new DragonBreedingThankYouFrame(m_element[this.THANK_YOU_CARD],this.m_featureName,""),false) as DragonBreedingThankYouFrame;
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DragonBreedingHatcherySlot(slotElement,this.refresh,this.m_mainWindow);
      }
      
      private function removeSlots() : void
      {
         for(var slotIndex:uint = 0; slotIndex < m_slots.length; slotIndex++)
         {
            removeWidget(m_slots[slotIndex]);
         }
      }
      
      private function toggleWidgets(toggle:Boolean) : void
      {
         for(var slotIndex:uint = 0; slotIndex < m_slots.length; slotIndex++)
         {
            if(m_slots[slotIndex])
            {
               m_slots[slotIndex].visible = toggle;
            }
         }
      }
      
      private function testThankYouCard() : void
      {
         this.m_thankYouFrame.senderId = "705422147";
         this.m_thankYouFrame.visible = true;
      }
      
      private function setThankYouCardVisibility() : void
      {
         var thankYouSession:DragonBreedingSession = DragonBreedingManager.getInstance(this.m_featureName).getThankYouCardSession();
         if(Boolean(thankYouSession) && Boolean(thankYouSession.visitingDragonSender) && thankYouSession.visitingDragonSender != "")
         {
            this.m_thankYouFrame.senderId = thankYouSession.visitingDragonSender;
            this.m_thankYouFrame.visible = true;
         }
         else
         {
            this.m_thankYouFrame.visible = false;
         }
         if(Boolean(thankYouSession) && Boolean(thankYouSession.maleVDSender) && thankYouSession.maleVDSender != "")
         {
            this.m_thankYouFrame.maleSenderId = thankYouSession.maleVDSender;
            this.m_thankYouFrame.visible = true;
         }
         else
         {
            this.m_thankYouFrame.maleSenderId = null;
            this.m_thankYouFrame.visible = false;
         }
         if(Boolean(thankYouSession) && Boolean(thankYouSession.femaleVDSender) && thankYouSession.femaleVDSender != "")
         {
            this.m_thankYouFrame.femaleSenderId = thankYouSession.femaleVDSender;
            this.m_thankYouFrame.visible = true;
         }
         else
         {
            this.m_thankYouFrame.femaleSenderId = null;
            this.m_thankYouFrame.visible = false;
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         this.setThankYouCardVisibility();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var m_data:Object = null;
         m_slotData = new Array();
         var skillState:DragonBreedingSkillState = DragonBreedingManager.getInstance(this.m_featureName).getBreedingSkillState();
         var breedingData:Object = DragonBreedingManager.getInstance(this.m_featureName).getBreedingData();
         for(var i:int = 0; i < DragonBreedingState.MAX_SESSIONS; i++)
         {
            m_data = new Object();
            if(i < skillState.unlockedSuites)
            {
               m_data.isUnlocked = true;
            }
            else
            {
               m_data.isUnlocked = false;
               m_data.unlockLevel = DragonBreedingConfigManager.getInstance(this.m_featureName).getLevelForReward(DragonBreedingSkillState.REWARD_BREEDINGSTATION_UNLOCK,(i + 1).toString());
            }
            m_data.breedingData = breedingData[i];
            m_data.hatcheryData = {"plotNumber":i};
            m_slotData.push(m_data);
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.HATCHERY_SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return this.HATCHERY_SLOT_POSTFIX;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         this.refresh();
      }
      
      public function setEnabled(enable:Boolean) : void
      {
         m_pageBackWidget.enabled = enable;
         m_pageForwardWidget.enabled = enable;
      }
   }
}

