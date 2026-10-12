package Widgets.Frames.Breeding
{
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.ProgressBars.BreedingMacroProgressBar;
   import Widgets.Slots.Breeding.BreedingProgressSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingProgressSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const SLOT_PAGE_DIVISOR:int = 5;
      
      private var m_featureName:String = null;
      
      private var m_skillState:AnimalBreedingSkillState = Global.player.getBreedingSkillStateForFeature(this.m_featureName);
      
      private var m_zoomFrame:ZwFrame = null;
      
      private var m_firstPageGraphic:ZwFrame = null;
      
      public function BreedingProgressSlotContainerFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         m_pageBackWidget = addWidget(new FarmAnimatedButton(m_element.largeArrowLeft_mc,this.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new FarmAnimatedButton(m_element.largeArrowRight_mc,this.onPageForward)) as ZwWidget;
         this.m_zoomFrame = new ZwFrame(m_element.zoom_mc);
         addWidget(this.m_zoomFrame);
         pageNumber = Math.floor(this.m_skillState.level / SLOT_PAGE_DIVISOR);
         (this.m_zoomFrame.element as MovieClip).gotoAndStop(pageNumber + 1);
         this.m_firstPageGraphic = new ZwFrame(m_element.level1Avatar_mc);
         this.m_firstPageGraphic.addWidget(new ZwFrame(this.m_firstPageGraphic.element.avatarCircle_mc));
         this.m_firstPageGraphic.addWidget(new ZwTextField(this.m_firstPageGraphic.element.generic_tf,ZLocUtils.t("Dialogs","Breeding_Progress_FirstPageGraphic")));
         addWidget(this.m_firstPageGraphic);
         this.m_firstPageGraphic.visible = pageNumber == 0;
      }
      
      public function update() : void
      {
         m_slotData = new Array();
         this.setupData();
         pageNumber = Math.floor(this.m_skillState.level / SLOT_PAGE_DIVISOR);
         (this.m_zoomFrame.element as MovieClip).gotoAndStop(pageNumber + 1);
         this.m_firstPageGraphic.visible = pageNumber == 0;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_featureName = null;
         this.m_skillState = null;
         this.m_zoomFrame = null;
         this.m_firstPageGraphic = null;
      }
      
      private function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         (this.m_zoomFrame.element as MovieClip).gotoAndStop(pageNumber + 1);
         this.m_firstPageGraphic.visible = pageNumber == 0;
      }
      
      private function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
         (this.m_zoomFrame.element as MovieClip).gotoAndStop(pageNumber + 1);
         this.m_firstPageGraphic.visible = pageNumber == 0;
      }
      
      override protected function setupData() : void
      {
         var data:Object = null;
         var maxLevel:int = Global.animalBreedingSettings.getMaxLevel(this.m_featureName);
         var nextMilestoneLevel:int = Global.animalBreedingSettings.getNextBigReward(this.m_skillState.level);
         for(var level:int = 0; level <= maxLevel; level++)
         {
            data = new Object();
            data.level = level;
            data.skillState = this.m_skillState;
            if(nextMilestoneLevel == level)
            {
               data.isNextBigReward = true;
            }
            else
            {
               data.isNextBigReward = false;
            }
            m_slotData.push(data);
            if(level < BreedingMacroProgressBar.NUM_LEVELS_PER_BAR && level % SLOT_PAGE_DIVISOR == 0)
            {
               m_slotData.push(data);
               if(level > 0)
               {
                  m_slotData.push(data);
               }
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BreedingProgressSlot(slotElement);
      }
   }
}

