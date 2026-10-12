package Widgets.Frames.Breeding
{
   import Classes.Animal;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.MutableAnimalState;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BreedingFixedMatingFrame extends BreedingMatingFrame
   {
      
      protected var m_previewCollection:Array = [];
      
      public function BreedingFixedMatingFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         super(element,parentWindow);
         if(Global.animalBreedingSettings.isAsexualBreeding(m_featureName))
         {
            m_leftArrowButton1.callback = this.onLeftArrowPress1Fixed;
            m_rightArrowButton1.callback = this.onRightArrowPress1Fixed;
            m_leftArrowButton2.callback = this.onLeftArrowPress2Fixed;
            m_rightArrowButton2.callback = this.onRightArrowPress2Fixed;
         }
      }
      
      override public function loadData(breedingSession:AnimalBreedingSession, keyPress:Boolean = false) : void
      {
         var muteState1:MutableAnimalState = null;
         var breedItem1:FarmItem = null;
         var widgetImage1:ZwWidget = null;
         var muteState2:MutableAnimalState = null;
         var breedItem2:FarmItem = null;
         var widgetImage2:ZwWidget = null;
         var outcomes:Vector.<MutableAnimalState> = null;
         var index:int = 0;
         var previewSlot:int = 0;
         m_breedingSession = breedingSession.clone(this.m_parentWindow.building.getItem().name);
         m_breedObjs = breedingSession.getBreedObjects().slice();
         if(m_breedObjs.length >= 2)
         {
            releasePreviewFrames();
            muteState1 = m_breedObjs[0] as MutableAnimalState;
            breedItem1 = FeatureBuilding.getFarmItemForHash(muteState1.hash);
            m_objectBreedFrame1 = new ObjectPreviewFrame(m_element.holder1_mc,breedItem1,null,[BREEDING_ANIMAL_ZOOM_LEVEL],null,Animal.STATE_FRONT_IDLE,muteState1.jsonString);
            widgetImage1 = addWidget(m_objectBreedFrame1) as ZwWidget;
            m_animalName1 = new ZwTextField(m_element.animalName1_tf,getFriendlyName(muteState1.name));
            addWidget(m_animalName1);
            muteState2 = m_breedObjs[1] as MutableAnimalState;
            breedItem2 = FeatureBuilding.getFarmItemForHash(muteState2.hash);
            m_objectBreedFrame2 = new ObjectPreviewFrame(m_element.holder2_mc,breedItem2,null,[BREEDING_ANIMAL_ZOOM_LEVEL],null,Animal.STATE_FRONT_IDLE,muteState2.jsonString);
            widgetImage2 = addWidget(m_objectBreedFrame2) as ZwWidget;
            m_animalName2 = new ZwTextField(m_element.animalName2_tf,getFriendlyName(muteState2.name));
            addWidget(m_animalName2);
            m_thoughtBubbleItems = new Array();
            outcomes = null;
            if(Global.animalBreedingSettings.getFeatureConfigAttr(m_featureName,"fixedOutcome"))
            {
               outcomes = AnimalBreedingManager.getInstance().generateFixedBreedItemState(m_breedingSession);
            }
            if(outcomes != null && outcomes.length > 0)
            {
               index = 0;
               while(m_element.previewGroup_mc.hasOwnProperty("slot" + index + "_mc"))
               {
                  m_thoughtBubbleItems.push(addWidget(this.setUpFixedObjectPreviewFrame(index,outcomes[index % outcomes.length])));
                  index++;
               }
            }
            else
            {
               for(previewSlot = 0; previewSlot < BreedingMatingFrame.NUM_PREVIEW_SLOTS; previewSlot++)
               {
                  m_thoughtBubbleItems.push(addWidget(setUpObjectPreviewFrame(previewSlot)));
               }
            }
            (m_element as MovieClip).addEventListener(Event.ENTER_FRAME,this.onPreviewEnterFrame);
            m_heartAnimationFrame.visible = muteState1.pattern == muteState2.pattern;
            (m_element as MovieClip).gotoAndStop(m_breedingSession.suiteSlot + 1);
            if(!keyPress)
            {
               this.m_previewCollection = [];
               updateContents();
            }
            this.setCounters(muteState1,muteState2);
            updatePatternInheritenceButtonState();
         }
      }
      
      override protected function setCounters(muteState1:MutableAnimalState, muteState2:MutableAnimalState) : void
      {
         if(this.m_previewCollection.length <= 2)
         {
            m_leftArrowButton1.enabled = false;
            m_rightArrowButton1.enabled = false;
            m_leftArrowButton2.enabled = false;
            m_rightArrowButton2.enabled = false;
         }
      }
      
      override protected function onPreviewEnterFrame(event:Event) : void
      {
         var scrollerWidget:ZwFrame = null;
         var scrollerMc:MovieClip = null;
         var nextIndex:int = 0;
         for(var previewSlotIndex:int = 0; previewSlotIndex < m_thoughtBubbleItems.length; previewSlotIndex++)
         {
            scrollerWidget = m_thoughtBubbleItems[previewSlotIndex] as ZwFrame;
            scrollerMc = scrollerWidget.element as MovieClip;
            scrollerMc.x += 1;
            if(scrollerMc.x > m_thoughtBubbleWidth)
            {
               nextIndex = previewSlotIndex + 1;
               if(nextIndex >= m_thoughtBubbleItems.length)
               {
                  nextIndex = 0;
               }
               scrollerMc.x = m_thoughtBubbleItems[nextIndex].x - ROLLBACK_OFFSET;
            }
         }
      }
      
      protected function setUpFixedObjectPreviewFrame(previewSlot:int, breedingData:MutableAnimalState) : ObjectPreviewFrame
      {
         var breedItem3:FarmItem = FeatureBuilding.getFarmItemForHash(breedingData.hash);
         var slotName:String = "slot" + previewSlot + "_mc";
         var slotMc:MovieClip = m_element.previewGroup_mc[slotName];
         if(slotMc.numChildren > 0)
         {
            slotMc.removeChildAt(0);
         }
         return new ObjectPreviewFrame(slotMc,breedItem3,null,[BreedingMatingFrame.PREVIEW_ZOOM_LEVEL],null,Animal.STATE_FRONT_CYCLE,breedingData.jsonString);
      }
      
      override public function storeMutableAnimal(mutableAnimalState:MutableAnimalState) : void
      {
         if(Global.animalBreedingSettings.isAsexualBreeding(m_featureName))
         {
            this.m_previewCollection.push(mutableAnimalState);
         }
         else
         {
            super.storeMutableAnimal(mutableAnimalState);
         }
      }
      
      protected function onLeftArrowPress1Fixed(event:MouseEvent) : void
      {
         m_maleCounter = m_maleCounter == 0 ? int(this.m_previewCollection.length - 1) : int(m_maleCounter - 1);
         while(this.m_previewCollection[m_maleCounter] == this.m_previewCollection[m_femaleCounter])
         {
            m_maleCounter = m_maleCounter == 0 ? int(this.m_previewCollection.length - 1) : int(m_maleCounter - 1);
         }
         m_breedingSession.addBreedObjectAtFirst(this.m_previewCollection[m_maleCounter]);
         this.loadData(m_breedingSession,true);
      }
      
      protected function onRightArrowPress1Fixed(event:MouseEvent) : void
      {
         m_maleCounter = m_maleCounter == this.m_previewCollection.length - 1 ? 0 : int(m_maleCounter + 1);
         while(this.m_previewCollection[m_maleCounter] == this.m_previewCollection[m_femaleCounter])
         {
            m_maleCounter = m_maleCounter == this.m_previewCollection.length - 1 ? 0 : int(m_maleCounter + 1);
         }
         m_breedingSession.addBreedObjectAtFirst(this.m_previewCollection[m_maleCounter]);
         this.loadData(m_breedingSession,true);
      }
      
      protected function onLeftArrowPress2Fixed(event:MouseEvent) : void
      {
         m_femaleCounter = m_femaleCounter == 0 ? int(this.m_previewCollection.length - 1) : int(m_femaleCounter - 1);
         while(this.m_previewCollection[m_maleCounter] == this.m_previewCollection[m_femaleCounter])
         {
            m_femaleCounter = m_femaleCounter == 0 ? int(this.m_previewCollection.length - 1) : int(m_femaleCounter - 1);
         }
         m_breedingSession.removeBreedObject();
         m_breedingSession.addBreedObjectAtLast(this.m_previewCollection[m_femaleCounter]);
         this.loadData(m_breedingSession,true);
      }
      
      protected function onRightArrowPress2Fixed(event:MouseEvent) : void
      {
         m_femaleCounter = m_femaleCounter == this.m_previewCollection.length - 1 ? 0 : int(m_femaleCounter + 1);
         while(this.m_previewCollection[m_maleCounter] == this.m_previewCollection[m_femaleCounter])
         {
            m_femaleCounter = m_femaleCounter == this.m_previewCollection.length - 1 ? 0 : int(m_femaleCounter + 1);
         }
         m_breedingSession.removeBreedObject();
         m_breedingSession.addBreedObjectAtLast(this.m_previewCollection[m_femaleCounter]);
         this.loadData(m_breedingSession,true);
      }
   }
}

