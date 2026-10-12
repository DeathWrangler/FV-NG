package Widgets.Frames.Breeding
{
   import Classes.Animal;
   import Classes.AnimalBreedingConfigSettings;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.AnimalBreedingState;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class BreedingMatingFrame extends ZwFrame
   {
      
      public static const ROLLBACK_OFFSET:int = 80;
      
      public static const PREVIEW_SLOT_Y_OFFSET:int = 35;
      
      public static const NUM_PREVIEW_SLOTS:int = 6;
      
      private static const THOUGHT_BUBBLE_ADDITIONAL_OFFSET:int = 62;
      
      private static const PIGPEN_FEATURE_NAME:String = "pigpenv2";
      
      public static const BREEDING_ANIMAL_ZOOM_LEVEL:Number = 2.5;
      
      public static const PREVIEW_ZOOM_LEVEL:Number = 1.75;
      
      protected var m_parentWindow:BreedingWindow = null;
      
      protected var m_breedObjs:Array = null;
      
      protected var m_numBreedPotions:Number = 0;
      
      protected var m_breedingSession:AnimalBreedingSession = null;
      
      protected var DEFAULT_BREEDING_PERCENTAGE:Number = 50;
      
      protected var m_objectBreedFrame1:ObjectPreviewFrame = null;
      
      protected var m_objectBreedFrame2:ObjectPreviewFrame = null;
      
      protected var m_breedButton:FarmAnimatedTextButton = null;
      
      protected var m_cancelButton:FarmAnimatedTextButton = null;
      
      protected var m_thoughtBubbleFrame:ZwFrame = null;
      
      protected var m_leftArrowButton1:FarmAnimatedButton = null;
      
      protected var m_rightArrowButton1:FarmAnimatedButton = null;
      
      protected var m_leftArrowButton2:FarmAnimatedButton = null;
      
      protected var m_rightArrowButton2:FarmAnimatedButton = null;
      
      protected var m_featureName:String = "";
      
      protected var m_thoughtBubbleItems:Array = null;
      
      protected var m_thoughtBubbleWidth:int = 0;
      
      protected var m_animalName1:ZwTextField = null;
      
      protected var m_animalName2:ZwTextField = null;
      
      protected var m_heartAnimationFrame:ZwFrame;
      
      protected var m_maleCollection:Array = [];
      
      protected var m_femaleCollection:Array = [];
      
      protected var m_featureBuilding:FeatureBuilding = null;
      
      protected var m_femaleCounter:int = 0;
      
      protected var m_maleCounter:int = 0;
      
      protected var m_slotPosition:int = 0;
      
      private var m_guaranteePatternButton:ZwButton = null;
      
      private var m_isPatternInheritenceButtonEnabled:Boolean = false;
      
      private var m_isPatternInheritenceOn:Boolean = false;
      
      public function BreedingMatingFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         this.m_featureBuilding = this.m_parentWindow.building;
         this.m_breedButton = addWidget(new FarmAnimatedTextButton(m_element.generic1_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_button_breed"),this.onBreedCallback)) as FarmAnimatedTextButton;
         this.m_cancelButton = addWidget(new FarmAnimatedTextButton(m_element.generic2_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_button_cancel"),this.onCancelCallback)) as FarmAnimatedTextButton;
         addWidget(new ZwTextField(m_element.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_potion_text")));
         addWidget(new ZwTextField(m_element.generic1_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_time_desc")));
         addWidget(new ZwTextField(m_element.value1_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_time",{
            "quantity":AnimalBreedingManager.getDefaultBreedTimes(this.m_featureName)[this.m_numBreedPotions],
            "hourword":ZLocUtils.tk("Dialogs","Hour_word","",AnimalBreedingManager.getDefaultBreedTimes(this.m_featureName)[this.m_numBreedPotions])
         })));
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_success_desc")));
         addWidget(new ZwTextField(m_element.value2_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_success",{"quantity":this.DEFAULT_BREEDING_PERCENTAGE})));
         var counterFrame:ZwFrame = new ZwFrame(m_element.quantity_mc);
         var upFrame:ZwFrame = new ZwFrame(m_element.quantity_mc.arrowUp_bt);
         upFrame.element.addEventListener(MouseEvent.MOUSE_DOWN,this.onPotionUpArrowPress);
         counterFrame.addWidget(upFrame);
         var downFrame:ZwFrame = new ZwFrame(m_element.quantity_mc.arrowDown_bt);
         downFrame.element.addEventListener(MouseEvent.MOUSE_DOWN,this.onPotionDownArrowPress);
         counterFrame.addWidget(downFrame);
         counterFrame.addWidget(new ZwTextField(m_element.quantity_mc.input_tf,String(this.m_numBreedPotions)));
         addWidget(counterFrame);
         this.m_thoughtBubbleWidth = m_element.previewGroup_mc.width + THOUGHT_BUBBLE_ADDITIONAL_OFFSET;
         this.m_thoughtBubbleFrame = new ZwFrame(m_element.previewGroup_mc);
         addWidget(this.m_thoughtBubbleFrame);
         var whatsThisThoughtBubbleElement:FarmAnimatedButton = new FarmAnimatedButton(m_element.questionMark_mc);
         addWidget(whatsThisThoughtBubbleElement);
         whatsThisThoughtBubbleElement.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","breeding_Preview_Tooltip")));
         var arrowFrame1:ZwFrame = new ZwFrame(m_element.animalLeft_mc);
         this.m_leftArrowButton1 = new FarmAnimatedButton(m_element.animalLeft_mc.leftArrow_bt,this.onLeftArrowPress1);
         this.m_rightArrowButton1 = new FarmAnimatedButton(m_element.animalLeft_mc.rightArrow_bt,this.onRightArrowPress1);
         arrowFrame1.addWidget(this.m_leftArrowButton1);
         arrowFrame1.addWidget(this.m_rightArrowButton1);
         addWidget(arrowFrame1);
         var arrowFrame2:ZwFrame = new ZwFrame(m_element.animalRight_mc);
         this.m_leftArrowButton2 = new FarmAnimatedButton(m_element.animalRight_mc.leftArrow_bt,this.onLeftArrowPress2);
         this.m_rightArrowButton2 = new FarmAnimatedButton(m_element.animalRight_mc.rightArrow_bt,this.onRightArrowPress2);
         arrowFrame2.addWidget(this.m_leftArrowButton2);
         arrowFrame2.addWidget(this.m_rightArrowButton2);
         addWidget(arrowFrame2);
         this.m_heartAnimationFrame = new ZwFrame(m_element.heartAnimation_mc);
         addWidget(this.m_heartAnimationFrame);
         var heartAnimation:ZwFrame = new ZwFrame(m_element.heartAnimation_mc.heartObject_mc);
         this.m_heartAnimationFrame.addWidget(heartAnimation);
         this.m_heartAnimationFrame.visible = false;
         this.m_guaranteePatternButton = new ZwButton(m_element.pattern_bt,this.onGuaranteePatternButtonClick);
         addWidget(this.m_guaranteePatternButton);
         m_element.pattern_bt.addEventListener(MouseEvent.MOUSE_OUT,this.onGuaranteePatternButtonOut);
         m_element.pattern_bt.addEventListener(MouseEvent.MOUSE_OVER,this.onGuaranteePatternButtonOver);
         addWidget(new ZwTextField(this.m_guaranteePatternButton.element.guarantee_tf,ZLocUtils.t("Dialogs","breeding_guarantee_pattern_button_text")));
         addWidget(new ZwTextField(this.m_guaranteePatternButton.element.price_tf,AnimalBreedingManager.getInstance().guaranteePatternPrice.toString()));
      }
      
      override public function release() : void
      {
         this.releasePreviewFrames();
         if(this.m_heartAnimationFrame != null)
         {
            removeWidget(this.m_heartAnimationFrame);
            this.m_heartAnimationFrame = null;
         }
         if(this.m_leftArrowButton1 != null)
         {
            removeWidget(this.m_leftArrowButton1);
         }
         if(this.m_rightArrowButton1 != null)
         {
            removeWidget(this.m_rightArrowButton1);
         }
         if(this.m_leftArrowButton2 != null)
         {
            removeWidget(this.m_leftArrowButton2);
         }
         if(this.m_rightArrowButton2 != null)
         {
            removeWidget(this.m_rightArrowButton2);
         }
         if(m_element.pattern_bt != null)
         {
            m_element.pattern_bt.removeEventListener(MouseEvent.MOUSE_OUT,this.onGuaranteePatternButtonOut);
            m_element.pattern_bt.removeEventListener(MouseEvent.MOUSE_OVER,this.onGuaranteePatternButtonOver);
         }
         if(this.m_cancelButton != null)
         {
            removeWidget(this.m_cancelButton);
            this.m_cancelButton = null;
         }
         if(this.m_breedButton != null)
         {
            removeWidget(this.m_breedButton);
            this.m_breedButton = null;
         }
         super.release();
      }
      
      protected function releasePreviewFrames() : void
      {
         var previewSlotWidget:ZwFrame = null;
         if(this.m_objectBreedFrame1 != null)
         {
            removeWidget(this.m_objectBreedFrame1);
            removeWidget(this.m_animalName1);
            this.m_objectBreedFrame1 = null;
            this.m_animalName1 = null;
            this.m_leftArrowButton1.enabled = true;
            this.m_rightArrowButton1.enabled = true;
         }
         if(this.m_objectBreedFrame2 != null)
         {
            removeWidget(this.m_objectBreedFrame2);
            removeWidget(this.m_animalName2);
            this.m_objectBreedFrame2 = null;
            this.m_animalName2 = null;
            this.m_leftArrowButton2.enabled = true;
            this.m_rightArrowButton2.enabled = true;
         }
         for each(previewSlotWidget in this.m_thoughtBubbleItems)
         {
            removeWidget(previewSlotWidget);
            previewSlotWidget = null;
         }
         this.m_thoughtBubbleItems = null;
         (m_element as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onPreviewEnterFrame);
      }
      
      public function loadData(breedingSession:AnimalBreedingSession, keyPress:Boolean = false) : void
      {
         var muteState1:MutableAnimalState = null;
         var breedItem1:FarmItem = null;
         var widgetImage1:ZwWidget = null;
         var muteState2:MutableAnimalState = null;
         var breedItem2:FarmItem = null;
         var widgetImage2:ZwWidget = null;
         var previewSlot:int = 0;
         this.m_breedingSession = breedingSession.clone(this.m_parentWindow.building.getItem().name);
         this.m_breedObjs = breedingSession.getBreedObjects().slice();
         if(this.m_breedObjs.length >= 2)
         {
            this.releasePreviewFrames();
            muteState1 = this.m_breedObjs[0] as MutableAnimalState;
            breedItem1 = FeatureBuilding.getFarmItemForHash(muteState1.hash);
            this.m_objectBreedFrame1 = new ObjectPreviewFrame(m_element.holder1_mc,breedItem1,null,[BREEDING_ANIMAL_ZOOM_LEVEL],null,Animal.STATE_FRONT_IDLE,muteState1.jsonString);
            widgetImage1 = addWidget(this.m_objectBreedFrame1) as ZwWidget;
            this.m_animalName1 = new ZwTextField(m_element.animalName1_tf,this.getFriendlyName(muteState1.name));
            addWidget(this.m_animalName1);
            muteState2 = this.m_breedObjs[1] as MutableAnimalState;
            breedItem2 = FeatureBuilding.getFarmItemForHash(muteState2.hash);
            this.m_objectBreedFrame2 = new ObjectPreviewFrame(m_element.holder2_mc,breedItem2,null,[BREEDING_ANIMAL_ZOOM_LEVEL],null,Animal.STATE_FRONT_IDLE,muteState2.jsonString);
            widgetImage2 = addWidget(this.m_objectBreedFrame2) as ZwWidget;
            this.m_animalName2 = new ZwTextField(m_element.animalName2_tf,this.getFriendlyName(muteState2.name));
            addWidget(this.m_animalName2);
            this.m_thoughtBubbleItems = new Array();
            for(previewSlot = 0; previewSlot < NUM_PREVIEW_SLOTS; previewSlot++)
            {
               this.m_thoughtBubbleItems.push(addWidget(this.setUpObjectPreviewFrame(previewSlot)));
            }
            (m_element as MovieClip).addEventListener(Event.ENTER_FRAME,this.onPreviewEnterFrame);
            this.m_heartAnimationFrame.visible = muteState1.pattern == muteState2.pattern;
            (m_element as MovieClip).gotoAndStop(this.m_breedingSession.suiteSlot + 1);
            if(!keyPress)
            {
               this.m_femaleCollection = [];
               this.m_maleCollection = [];
               this.updateContents();
            }
            this.setCounters(muteState1,muteState2);
            this.updatePatternInheritenceButtonState();
         }
      }
      
      protected function setUpObjectPreviewFrame(previewSlot:int) : ObjectPreviewFrame
      {
         var muteState3:MutableAnimalState = AnimalBreedingManager.getInstance().generateBreedItemState(this.m_breedingSession);
         var breedItem3:FarmItem = FeatureBuilding.getFarmItemForHash(muteState3.hash);
         var slotName:String = "slot" + previewSlot + "_mc";
         var slotMc:MovieClip = m_element.previewGroup_mc[slotName];
         if(slotMc.numChildren > 0)
         {
            slotMc.removeChildAt(0);
         }
         slotMc.y = PREVIEW_SLOT_Y_OFFSET;
         return new ObjectPreviewFrame(slotMc,breedItem3,null,[PREVIEW_ZOOM_LEVEL],null,Animal.STATE_FRONT_CYCLE,muteState3.jsonString);
      }
      
      protected function onPreviewEnterFrame(event:Event) : void
      {
         var scrollerWidget:ZwFrame = null;
         var scrollerMc:MovieClip = null;
         var nextIndex:int = 0;
         for(var previewSlotIndex:int = 0; previewSlotIndex < this.m_thoughtBubbleItems.length; previewSlotIndex++)
         {
            scrollerWidget = this.m_thoughtBubbleItems[previewSlotIndex] as ZwFrame;
            scrollerMc = scrollerWidget.element as MovieClip;
            scrollerMc.x += 1;
            if(scrollerMc.x > this.m_thoughtBubbleWidth)
            {
               nextIndex = previewSlotIndex + 1;
               if(nextIndex >= this.m_thoughtBubbleItems.length)
               {
                  nextIndex = 0;
               }
               scrollerMc.x = this.m_thoughtBubbleItems[nextIndex].x - ROLLBACK_OFFSET;
               removeWidget(scrollerWidget);
               this.m_thoughtBubbleItems[previewSlotIndex] = addWidget(this.setUpObjectPreviewFrame(previewSlotIndex));
            }
         }
      }
      
      public function updateContents() : void
      {
         var farmItem:FarmItem = null;
         var count:int = 0;
         var key:String = null;
         var j:int = 0;
         var inUseHashes:Dictionary = (this.m_parentWindow.building.extraDataState as AnimalBreedingState).getInUseBreedHashes();
         var storageMetaData:Object = this.m_parentWindow.building.storageMetaData;
         var storageDataForCode:Array = null;
         var metaDataArray:Array = null;
         var metaData:Object = {};
         for(key in this.m_parentWindow.building.contents)
         {
            count = int(this.m_parentWindow.building.contents[key]);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
            storageDataForCode = this.m_parentWindow.building.getStorageMetaDataForCode(key);
            for(j = 0; j < count; j++)
            {
               if(storageDataForCode != null && storageDataForCode.length > 0)
               {
                  metaData = storageDataForCode.pop();
               }
               if(metaData.key == null)
               {
                  metaData.key = FeatureBuilding.buildMetaDataHash(key,"");
               }
               if(inUseHashes[metaData.key] <= 0 || inUseHashes[metaData.key] == null)
               {
                  if(metaData.data == null)
                  {
                     metaData.data = Global.animalBreedingSettings.getVariantJSONByItemName(farmItem.name,farmItem.name);
                  }
                  this.addObject(metaData.key,this.m_parentWindow.building.getItem().name);
               }
               metaData = {};
            }
         }
      }
      
      public function addObject(hash:String, featureName:String = null) : void
      {
         var skillState:AnimalBreedingSkillState = null;
         var patternName:String = null;
         var patternLevel:int = 0;
         var jsonString:Object = this.m_featureBuilding.getStorageMetaDataForHash(hash);
         var parsedArray:Array = FeatureBuilding.parseMetaDataHash(hash);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(parsedArray[0]);
         if(jsonString == null)
         {
            if(featureName == null)
            {
               featureName = Global.animalBreedingSettings.getFeatureNameByItem(farmItem.name);
            }
            jsonString = Global.animalBreedingSettings.getVariantJSON(featureName,farmItem.name);
         }
         var mutableAnimalState:MutableAnimalState = MutableAnimalState.createFromPhpString(hash,String(jsonString));
         if(mutableAnimalState.isValid())
         {
            skillState = Global.player.getBreedingSkillStateForFeature(featureName);
            patternName = Global.animalBreedingSettings.getPatternTrait(featureName,mutableAnimalState.pattern);
            patternLevel = Global.animalBreedingSettings.getLevelForReward(AnimalBreedingConfigSettings.REWARD_TYPE_PATTERN_UNLOCK,patternName,featureName);
            if(skillState.level >= patternLevel)
            {
               this.storeMutableAnimal(mutableAnimalState);
            }
         }
      }
      
      public function storeMutableAnimal(mutableAnimalState:MutableAnimalState) : void
      {
         if(mutableAnimalState.gender == MutableAnimalState.GENDER_CODE_FEMALE)
         {
            this.m_femaleCollection.push(mutableAnimalState);
         }
         else
         {
            this.m_maleCollection.push(mutableAnimalState);
         }
      }
      
      protected function onLeftArrowPress1(event:MouseEvent) : void
      {
         if(this.m_slotPosition == 0)
         {
            this.m_maleCounter = this.m_maleCounter == 0 ? int(this.m_maleCollection.length - 1) : int(this.m_maleCounter - 1);
            this.m_breedingSession.addBreedObjectAtFirst(this.m_maleCollection[this.m_maleCounter]);
         }
         else
         {
            this.m_femaleCounter = this.m_femaleCounter == 0 ? int(this.m_femaleCollection.length - 1) : int(this.m_femaleCounter - 1);
            this.m_breedingSession.addBreedObjectAtFirst(this.m_femaleCollection[this.m_femaleCounter]);
         }
         this.loadData(this.m_breedingSession,true);
      }
      
      protected function onRightArrowPress1(event:MouseEvent) : void
      {
         if(this.m_slotPosition == 0)
         {
            this.m_maleCounter = this.m_maleCounter == this.m_maleCollection.length - 1 ? 0 : int(this.m_maleCounter + 1);
            this.m_breedingSession.addBreedObjectAtFirst(this.m_maleCollection[this.m_maleCounter]);
         }
         else
         {
            this.m_femaleCounter = this.m_femaleCounter == this.m_femaleCollection.length - 1 ? 0 : int(this.m_femaleCounter + 1);
            this.m_breedingSession.addBreedObjectAtFirst(this.m_femaleCollection[this.m_femaleCounter]);
         }
         this.loadData(this.m_breedingSession,true);
      }
      
      protected function onLeftArrowPress2(event:MouseEvent) : void
      {
         if(this.m_slotPosition == 1)
         {
            this.m_maleCounter = this.m_maleCounter == 0 ? int(this.m_maleCollection.length - 1) : int(this.m_maleCounter - 1);
            this.m_breedingSession.removeBreedObject();
            this.m_breedingSession.addBreedObjectAtLast(this.m_maleCollection[this.m_maleCounter]);
         }
         else
         {
            this.m_femaleCounter = this.m_femaleCounter == 0 ? int(this.m_femaleCollection.length - 1) : int(this.m_femaleCounter - 1);
            this.m_breedingSession.removeBreedObject();
            this.m_breedingSession.addBreedObjectAtLast(this.m_femaleCollection[this.m_femaleCounter]);
         }
         this.loadData(this.m_breedingSession,true);
      }
      
      protected function onRightArrowPress2(event:MouseEvent) : void
      {
         if(this.m_slotPosition == 1)
         {
            this.m_maleCounter = this.m_maleCounter == this.m_maleCollection.length - 1 ? 0 : int(this.m_maleCounter + 1);
            this.m_breedingSession.removeBreedObject();
            this.m_breedingSession.addBreedObjectAtLast(this.m_maleCollection[this.m_maleCounter]);
         }
         else
         {
            this.m_femaleCounter = this.m_femaleCounter == this.m_femaleCollection.length - 1 ? 0 : int(this.m_femaleCounter + 1);
            this.m_breedingSession.removeBreedObject();
            this.m_breedingSession.addBreedObjectAtLast(this.m_femaleCollection[this.m_femaleCounter]);
         }
         this.loadData(this.m_breedingSession,true);
      }
      
      protected function updatePatternInheritenceButtonState() : void
      {
         var parent:MutableAnimalState = null;
         var blankPattern:String = null;
         for each(parent in this.m_breedingSession.getBreedObjects())
         {
            if(parent.isMale())
            {
               blankPattern = String(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_featureBuilding.featureName,"defaultPatternCode"));
               if(parent.pattern == blankPattern || AnimalBreedingManager.getInstance().getRuntimePatternChance(this.m_breedingSession.owner.getItemName()) == 1)
               {
                  (this.m_guaranteePatternButton.element as MovieClip).gotoAndStop(4);
                  this.m_isPatternInheritenceButtonEnabled = false;
                  this.togglePatternInheritence(false);
               }
               else
               {
                  if(this.m_isPatternInheritenceOn && this.m_numBreedPotions == 5)
                  {
                     (this.m_guaranteePatternButton.element as MovieClip).gotoAndStop(3);
                  }
                  else
                  {
                     (this.m_guaranteePatternButton.element as MovieClip).gotoAndStop(1);
                     this.togglePatternInheritence(false);
                  }
                  this.m_isPatternInheritenceButtonEnabled = true;
               }
               break;
            }
         }
      }
      
      private function onGuaranteePatternButtonClick(event:Event) : void
      {
         if(this.m_isPatternInheritenceButtonEnabled)
         {
            if(this.m_isPatternInheritenceOn)
            {
               this.togglePatternInheritence(false);
            }
            else
            {
               this.togglePatternInheritence(true);
               this.m_numBreedPotions = 5;
               this.updateBreedRate();
            }
            this.loadData(this.m_breedingSession,true);
         }
      }
      
      private function onGuaranteePatternButtonOver(event:Event) : void
      {
         if(this.m_isPatternInheritenceButtonEnabled)
         {
            (this.m_guaranteePatternButton.element as MovieClip).gotoAndStop(2);
         }
      }
      
      private function onGuaranteePatternButtonOut(event:Event) : void
      {
         if(this.m_isPatternInheritenceButtonEnabled)
         {
            this.updatePatternInheritenceButtonState();
         }
      }
      
      private function togglePatternInheritence(toggle:Boolean) : void
      {
         this.m_isPatternInheritenceOn = toggle;
         this.m_breedingSession.patternGuarantee = toggle;
      }
      
      protected function onPotionUpArrowPress(event:MouseEvent) : void
      {
         if(this.m_numBreedPotions < AnimalBreedingManager.MAX_NUM_POTIONS)
         {
            ++this.m_numBreedPotions;
            this.updateBreedRate();
         }
      }
      
      protected function onPotionDownArrowPress(event:MouseEvent) : void
      {
         if(this.m_numBreedPotions > 0)
         {
            --this.m_numBreedPotions;
            this.updateBreedRate();
            this.updatePatternInheritenceButtonState();
         }
      }
      
      private function updateBreedRate() : void
      {
         var counterFrame:ZwFrame = getWidget(m_element.quantity_mc) as ZwFrame;
         var inputField:ZwTextField = counterFrame.getWidget(m_element.quantity_mc.input_tf) as ZwTextField;
         inputField.text = String(this.m_numBreedPotions);
         var timeField:ZwTextField = getWidget(m_element.value1_tf) as ZwTextField;
         var timeNeeded:Number = Number(AnimalBreedingManager.getDefaultBreedTimes(this.m_featureName)[this.m_numBreedPotions]);
         if(timeNeeded >= 1)
         {
            timeField.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_time",{
               "quantity":timeNeeded,
               "hourword":ZLocUtils.tk("Dialogs","Hour_word","",timeNeeded)
            });
         }
         else
         {
            timeField.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_time_instant");
         }
         var successField:ZwTextField = getWidget(m_element.value2_tf) as ZwTextField;
         successField.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_breed_success",{"quantity":this.DEFAULT_BREEDING_PERCENTAGE + this.m_numBreedPotions * 10});
      }
      
      private function setBreedCancelButtonsEnabled(enabled:Boolean) : void
      {
         this.m_breedButton.enabled = enabled;
         this.m_cancelButton.enabled = enabled;
      }
      
      protected function onBreedCallback(event:MouseEvent) : void
      {
         var message:String = null;
         this.m_breedingSession.numPotions = this.m_numBreedPotions;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(AnimalBreedingManager.LOVE_POTION_ITEM_NAME_1);
         var numPotionsInventory:Number = AnimalBreedingManager.getInstance().getNumPotions();
         var numPotionsToBuy:Number = Math.max(this.m_numBreedPotions - numPotionsInventory,0);
         var patternGuarantee:Boolean = this.m_breedingSession.patternGuarantee;
         var guaranteePatternCashPrice:int = patternGuarantee ? AnimalBreedingManager.getInstance().guaranteePatternPrice : 0;
         var cashCost:int = numPotionsToBuy * farmItem.cash + guaranteePatternCashPrice;
         this.setBreedCancelButtonsEnabled(false);
         if(cashCost > 0)
         {
            message = null;
            if(patternGuarantee)
            {
               if(numPotionsInventory < this.m_numBreedPotions)
               {
                  message = ZLocUtils.t("Dialogs","Pattern_Guarantee_LovePotion_Need_More_Smart",{
                     "quantity":numPotionsInventory,
                     "remainingNum":numPotionsToBuy,
                     "cashQuantity":cashCost
                  });
                  StatsManager.count("dialog",this.m_featureName + "_breeding_buy_guarantee","view");
               }
               else
               {
                  StatsManager.count("dialog",this.m_featureName + "_breeding_buy_guarantee","view");
                  message = ZLocUtils.t("Dialogs","Pattern_Guarantee_Confirm",{"cashQuantity":guaranteePatternCashPrice});
               }
            }
            else
            {
               message = ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Need_More_Smart",{
                  "quantity":numPotionsInventory,
                  "remainingNum":numPotionsToBuy,
                  "cashQuantity":cashCost
               });
            }
            UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.breedButtonSpendCashCallback),false);
         }
         else
         {
            this.setBreedCancelButtonsEnabled(true);
            this.beginBreed();
         }
      }
      
      private function breedButtonSpendCashCallback(event:GenericPopupEvent) : void
      {
         var i:Number = NaN;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(AnimalBreedingManager.LOVE_POTION_ITEM_NAME_1);
         var numPotionsInventory:Number = AnimalBreedingManager.getInstance().getNumPotions();
         var numPotionsToBuy:Number = Math.max(this.m_numBreedPotions - numPotionsInventory,0);
         var patternGuarantee:Boolean = this.m_breedingSession.patternGuarantee;
         var guaranteePatternCashPrice:int = patternGuarantee ? AnimalBreedingManager.getInstance().guaranteePatternPrice : 0;
         var cashCost:int = numPotionsToBuy * farmItem.cash + guaranteePatternCashPrice;
         this.setBreedCancelButtonsEnabled(true);
         if(event.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(cashCost,true))
            {
               for(i = 0; i < numPotionsToBuy; i++)
               {
                  farmItem.onBuy(farmItem.name,{"displayBuyMessage":false});
               }
               this.beginBreed();
               if(patternGuarantee)
               {
                  Global.player.cash -= guaranteePatternCashPrice;
                  StatsManager.count("dialog",this.m_featureName + "_breeding_buy_guarantee","okay");
               }
            }
         }
         else if(patternGuarantee)
         {
            StatsManager.count("dialog",this.m_featureName + "_breeding_buy_guarantee","x");
         }
      }
      
      private function beginBreed() : void
      {
         this.m_breedingSession.buildingId = this.m_parentWindow.building.getId();
         this.m_parentWindow.onBeginBreed(this.m_breedingSession);
         this.visible = false;
         this.m_isPatternInheritenceButtonEnabled = false;
         this.togglePatternInheritence(false);
         this.m_numBreedPotions = 0;
         this.updateBreedRate();
      }
      
      protected function setCounters(muteState1:MutableAnimalState, muteState2:MutableAnimalState) : void
      {
         var i:int = 0;
         var muteState:MutableAnimalState = null;
         if(muteState1.gender == MutableAnimalState.GENDER_CODE_FEMALE)
         {
            this.m_slotPosition = 1;
            if(this.m_femaleCollection.length <= 1)
            {
               this.m_leftArrowButton1.enabled = false;
               this.m_rightArrowButton1.enabled = false;
            }
            if(this.m_maleCollection.length <= 1)
            {
               this.m_leftArrowButton2.enabled = false;
               this.m_rightArrowButton2.enabled = false;
            }
            for(i = 0; i < this.m_femaleCollection.length; i++)
            {
               muteState = this.m_femaleCollection[i];
               if(muteState === muteState1)
               {
                  this.m_femaleCounter = i;
                  break;
               }
            }
            for(i = 0; i < this.m_maleCollection.length; i++)
            {
               muteState = this.m_maleCollection[i];
               if(muteState === muteState2)
               {
                  this.m_maleCounter = i;
                  break;
               }
            }
         }
         else
         {
            this.m_slotPosition = 0;
            if(this.m_femaleCollection.length <= 1)
            {
               this.m_leftArrowButton2.enabled = false;
               this.m_rightArrowButton2.enabled = false;
            }
            if(this.m_maleCollection.length <= 1)
            {
               this.m_leftArrowButton1.enabled = false;
               this.m_rightArrowButton1.enabled = false;
            }
            for(i = 0; i < this.m_maleCollection.length; i++)
            {
               muteState = this.m_maleCollection[i];
               if(muteState === muteState1)
               {
                  this.m_maleCounter = i;
                  break;
               }
            }
            for(i = 0; i < this.m_femaleCollection.length; i++)
            {
               muteState = this.m_femaleCollection[i];
               if(muteState === muteState2)
               {
                  this.m_femaleCounter = i;
                  break;
               }
            }
         }
      }
      
      protected function getFriendlyName(itemName:String) : String
      {
         var result:String = "";
         if(ZLocUtils.hasString("Items",itemName + "_friendlyName"))
         {
            result = ZLocUtils.tk_pk_asTitle("Items:" + itemName + "_friendlyName");
         }
         else
         {
            result = itemName;
         }
         return result;
      }
      
      protected function onCancelCallback(event:MouseEvent) : void
      {
         this.visible = false;
      }
   }
}

