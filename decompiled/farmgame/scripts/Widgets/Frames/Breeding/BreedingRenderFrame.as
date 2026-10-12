package Widgets.Frames.Breeding
{
   import Classes.Animal;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.AnimalBreedingState;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Constants;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Breeding.BreedingWindow;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.utils.Dictionary;
   
   public class BreedingRenderFrame extends ZwFrame
   {
      
      private static const BREEDING_LOCKED:Number = 1;
      
      private static const BREEDING_NORMAL:Number = 2;
      
      private static const BREEDING_PRE_START:Number = 3;
      
      private static const BREEDING_IN_PROGRESS:Number = 4;
      
      private static const BREEDING_MODE_NONE:Number = 0;
      
      private static const BREEDING_MODE_WAITING_FOR_CLICK:Number = 1;
      
      private static const BREEDING_MODE_READY:Number = 2;
      
      private var m_parentWindow:BreedingWindow = null;
      
      private var m_menuBreedWithImage:ZwFrame = null;
      
      private var m_menuBreed:ZwFrame = null;
      
      private var m_penItems:MovieClip = null;
      
      private var m_objectPreviewFrames:Array;
      
      private var m_breedingPens:Array;
      
      private var m_graphicsFrame:ZwFrame = null;
      
      private var m_infoFrame:ZwFrame = null;
      
      private var m_potionStats:ZwFrame = null;
      
      private var m_breedingSession:AnimalBreedingSession = null;
      
      private var m_breedingIndex:int = -1;
      
      private var m_glowFilter:GlowFilter;
      
      private var m_activeSprite:FarmGameSprite = null;
      
      private var m_maxGifts:Number = 0;
      
      private var m_lovePotionWidth:Number = 0;
      
      private var m_dialogEventData:Object;
      
      private var m_keepRolloverOpen:Boolean = false;
      
      private var m_disabledFrame:ZwFrame = null;
      
      private var m_featureName:String = "";
      
      private var m_breederRolloverImage:FarmIcon = null;
      
      private var m_askForPotionsButton:FarmAnimatedTextButton = null;
      
      private var m_displayOrdering:Array;
      
      public function BreedingRenderFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         var breedingPen:ZwFrame = null;
         var finishBut:FarmAnimatedTextButton = null;
         var finishNowBut:FarmAnimatedTextButton = null;
         var unlockFrame:ZwFrame = null;
         this.m_objectPreviewFrames = [];
         this.m_breedingPens = [];
         this.m_glowFilter = new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20);
         this.m_dialogEventData = {};
         this.m_displayOrdering = [23,22,14,15,24,31,30,29,21,13,7,8,16,32,39,38,37,28,20,12,6,2,3,9,17,25,40,36,27,19,11,5,1,4,10,18,26,33,35,34];
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         this.m_disabledFrame = new ZwFrame(m_element.modal_mc);
         addWidget(this.m_disabledFrame,false);
         this.m_breedingSession = new AnimalBreedingSession(this.m_parentWindow.building);
         this.m_penItems = m_element.items40_mc;
         this.m_graphicsFrame = new ZwFrame(this.m_penItems);
         this.m_graphicsFrame.element.addEventListener(MouseEvent.ROLL_OVER,this.backgroundMouseOverHandler);
         this.addWidget(this.m_graphicsFrame);
         if(m_element.market_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_element.market_bt,ZLocUtils.t("Dialogs","Market"),this.openMarket),this.m_parentWindow.building.count < 2);
         }
         var introField:ZwTextField = new ZwTextField(m_element.intro_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Empty_Text"));
         this.addWidget(introField,this.m_parentWindow.building.count <= 0 ? true : false);
         for(var i:int = 0; i < 3; i++)
         {
            breedingPen = new ZwFrame(m_element["pen" + (i + 1) + "_mc"]);
            finishBut = new FarmAnimatedTextButton(m_element["pen" + (i + 1) + "_mc"].finish_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_finish"),this.onFinishCallback);
            finishBut.id = String(i);
            breedingPen.addWidget(finishBut,false);
            finishNowBut = new FarmAnimatedTextButton(m_element["pen" + (i + 1) + "_mc"].finishNow_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_finish_now"),this.onFinishNowCallback);
            finishNowBut.id = String(i);
            breedingPen.addWidget(finishNowBut,false);
            breedingPen.element.addEventListener(MouseEvent.ROLL_OVER,this.penMouseOverHandler);
            breedingPen.element.addEventListener(MouseEvent.ROLL_OUT,this.penMouseOutHandler);
            this.addWidget(breedingPen);
            this.m_breedingPens.push(breedingPen);
         }
         this.m_infoFrame = new ZwFrame(m_element.counter_mc);
         this.addWidget(this.m_infoFrame);
         this.m_infoFrame.addWidget(new ZwTextField(m_element.counter_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_CompletedCapacity")));
         this.m_infoFrame.addWidget(new ZwTextField(m_element.counter_mc.counter_tf,this.m_parentWindow.building.count + "/" + this.m_parentWindow.building.capacity));
         this.m_menuBreed = new ZwFrame(m_element.rollover_mc);
         this.m_menuBreed.element.x = -this.m_menuBreed.element.width / 4;
         this.m_menuBreed.element.y = -this.m_menuBreed.element.height / 4;
         this.m_menuBreed.addWidget(new ZwTextField(m_element.rollover_mc.title_tf));
         if(m_element.rollover_mc.hasOwnProperty("cantBreed_mc"))
         {
            unlockFrame = new ZwFrame(m_element.rollover_mc.cantBreed_mc);
            unlockFrame.addWidget(new ZwTextField(m_element.rollover_mc.cantBreed_mc.unlock_tf));
            unlockFrame.addWidget(new FarmAnimatedButton(m_element.rollover_mc.cantBreed_mc.questionMark_mc,this.onLockedLevelWhatIsThisClick));
            this.m_menuBreed.addWidget(unlockFrame);
         }
         this.m_menuBreed.addWidget(new FarmButton(m_element.rollover_mc.close_bt,this.closeRolloverCallback));
         this.m_menuBreed.addWidget(new FarmAnimatedTextButton(m_element.rollover_mc.breed_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Breed_Button"),this.breedCallback));
         this.m_menuBreed.addWidget(new FarmAnimatedTextButton(m_element.rollover_mc.remove_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Remove_Button"),this.removeCallback));
         this.m_menuBreedWithImage = new ZwFrame(m_element.rollover2_mc);
         this.m_menuBreedWithImage.element.x = -this.m_menuBreedWithImage.element.width / 4;
         this.m_menuBreedWithImage.element.y = -this.m_menuBreedWithImage.element.height / 4;
         this.m_menuBreedWithImage.addWidget(new ZwTextField(m_element.rollover2_mc.title_tf));
         if(m_element.rollover2_mc.hasOwnProperty("cantBreed_mc"))
         {
            unlockFrame = new ZwFrame(m_element.rollover2_mc.cantBreed_mc);
            unlockFrame.addWidget(new ZwTextField(m_element.rollover2_mc.cantBreed_mc.unlock_tf));
            unlockFrame.addWidget(new FarmAnimatedButton(m_element.rollover2_mc.cantBreed_mc.questionMark_mc,this.onLockedLevelWhatIsThisClick));
            this.m_menuBreedWithImage.addWidget(unlockFrame);
         }
         this.m_menuBreedWithImage.addWidget(new ZwTextField(m_element.rollover2_mc.breeder_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Breeder_Title")));
         this.m_breederRolloverImage = new FarmIcon(m_element.rollover2_mc.icon_mc);
         this.m_menuBreedWithImage.addWidget(this.m_breederRolloverImage);
         this.m_menuBreedWithImage.addWidget(new FarmButton(m_element.rollover2_mc.close_bt,this.closeRolloverCallback));
         this.m_menuBreedWithImage.addWidget(new FarmAnimatedTextButton(m_element.rollover2_mc.breed_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Breed_Button"),this.breedCallback));
         this.m_menuBreedWithImage.addWidget(new FarmAnimatedTextButton(m_element.rollover2_mc.remove_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Remove_Button"),this.removeCallback));
         this.m_potionStats = new ZwFrame(m_element.potions_mc);
         this.m_potionStats.addWidget(new ZwTextField(m_element.potions_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Title")));
         var lovePotionLimit:Number = Global.farmGameSettingsManager.getFarmItemByName(AnimalBreedingManager.LOVE_POTION_ITEM_NAME_1).limit;
         this.m_maxGifts = lovePotionLimit;
         this.m_potionStats.addWidget(new ZwTextField(m_element.potions_mc.counter_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Progress",{
            "quantity":AnimalBreedingManager.getInstance().getNumPotions(),
            "maximum":this.m_maxGifts
         })));
         this.m_askForPotionsButton = new FarmAnimatedTextButton(m_element.potions_mc.ask_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Ask_For_More"),this.onAskForMorePotions);
         this.m_potionStats.addWidget(this.m_askForPotionsButton);
         this.m_potionStats.addWidget(new FarmAnimatedTextButton(m_element.potions_mc.buy_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Buy_More"),this.onBuyMorePotions));
         var lovePotionFrame:ZwFrame = new ZwFrame(m_element.potions_mc.slopBar_mc);
         this.m_lovePotionWidth = lovePotionFrame.width;
         lovePotionFrame.width = 0;
         this.m_potionStats.addWidget(lovePotionFrame);
         addWidget(this.m_potionStats);
         this.updateUI();
      }
      
      override public function release() : void
      {
         var objectPreviewFrame:ObjectPreviewFrame = null;
         this.m_graphicsFrame = null;
         while(this.m_objectPreviewFrames.length > 0)
         {
            objectPreviewFrame = this.m_objectPreviewFrames.shift();
            objectPreviewFrame = null;
         }
         var breedingPen:ZwFrame = null;
         while(this.m_breedingPens.length > 0)
         {
            breedingPen = this.m_breedingPens.shift();
            breedingPen.element.removeEventListener(MouseEvent.ROLL_OVER,this.penMouseOverHandler);
            breedingPen.element.removeEventListener(MouseEvent.ROLL_OUT,this.penMouseOutHandler);
            breedingPen = null;
         }
         this.m_parentWindow = null;
         this.m_menuBreedWithImage = null;
         this.m_potionStats = null;
         this.m_menuBreed = null;
         this.m_infoFrame = null;
         this.m_penItems = null;
         this.m_activeSprite = null;
         this.m_disabledFrame = null;
         this.m_breedingSession = null;
         this.m_breederRolloverImage = null;
         this.m_askForPotionsButton = null;
         super.release();
      }
      
      public function getSelectedGender() : String
      {
         var muteState:MutableAnimalState = null;
         var breedObjs:Array = this.m_breedingSession.getBreedObjects();
         var selectedGender:String = "";
         if(breedObjs[0] != null)
         {
            muteState = breedObjs[0] as MutableAnimalState;
            selectedGender = muteState.gender;
         }
         return selectedGender;
      }
      
      private function updateExpansionStatus() : void
      {
         var breedingPen:ZwFrame = null;
         var currentState:Number = NaN;
         var finishButton:FarmAnimatedTextButton = null;
         var finishNowButton:FarmAnimatedTextButton = null;
         for(var i:int = 0; i < this.m_breedingPens.length; i++)
         {
            breedingPen = this.m_breedingPens[i] as ZwFrame;
            currentState = BREEDING_NORMAL;
            finishButton = breedingPen.getWidget(breedingPen.element.finish_btn) as FarmAnimatedTextButton;
            finishButton.visible = false;
            finishNowButton = breedingPen.getWidget(breedingPen.element.finishNow_btn) as FarmAnimatedTextButton;
            finishNowButton.visible = false;
            if(this.m_parentWindow.building.storageLevel >= i + 1)
            {
               (breedingPen.element as MovieClip).gotoAndStop(BREEDING_NORMAL);
            }
            else
            {
               (breedingPen.element as MovieClip).gotoAndStop(BREEDING_LOCKED);
               breedingPen.detachTooltip();
               breedingPen.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_featureName + "_Expansion_Unlock")));
            }
         }
      }
      
      private function updateSuiteState() : void
      {
         var i:int = 0;
         var breedingPen:ZwFrame = null;
         var breedSession:AnimalBreedingSession = null;
         var finishButton:FarmAnimatedTextButton = null;
         var finishNowButton:FarmAnimatedTextButton = null;
         var textTooltip:FarmTextTooltip = null;
         var animalBreedingState:AnimalBreedingState = this.m_parentWindow.building.extraDataState as AnimalBreedingState;
         if(animalBreedingState != null)
         {
            for(i = 0; i < this.m_breedingPens.length; i++)
            {
               breedingPen = this.m_breedingPens[i] as ZwFrame;
               breedSession = animalBreedingState.getBreedSession(i);
               finishButton = breedingPen.getWidget(breedingPen.element.finish_btn) as FarmAnimatedTextButton;
               finishNowButton = breedingPen.getWidget(breedingPen.element.finishNow_btn) as FarmAnimatedTextButton;
               if(breedSession != null)
               {
                  if(breedSession.isComplete())
                  {
                     (breedingPen.element as MovieClip).gotoAndStop(BREEDING_PRE_START);
                     finishButton.visible = true;
                     finishNowButton.visible = false;
                     textTooltip = breedingPen.tooltip as FarmTextTooltip;
                     if(textTooltip != null)
                     {
                        textTooltip.setText("");
                     }
                  }
                  else
                  {
                     (breedingPen.element as MovieClip).gotoAndStop(BREEDING_IN_PROGRESS);
                     this.updateTimeRemaining(breedingPen,breedSession);
                     finishButton.visible = false;
                  }
               }
            }
         }
      }
      
      private function updateTimeRemaining(breedingPen:ZwFrame, breedSession:AnimalBreedingSession) : void
      {
         var timeLeft:String = null;
         var timeLeft2:String = null;
         var time:int = 0;
         var timeRemaining:Number = breedSession.finishTime - GlobalEngine.serverTime / 1000;
         var breedingTooltip:FarmTextTooltip = breedingPen.tooltip as FarmTextTooltip;
         if(breedingTooltip != null)
         {
            breedingTooltip.setText("");
         }
         if(timeRemaining > 0)
         {
            if(timeRemaining > 3600)
            {
               time = int(0.5 + timeRemaining / 3600);
               timeLeft = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_FriendlyTimeHours",{
                  "hourNum":time,
                  "hourword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_hour","",time)
               });
               timeLeft2 = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_FriendlyTimeHoursMins",{
                  "hourNum":int(timeRemaining / 3600),
                  "hourword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_hour","",int(timeRemaining / 3600)),
                  "minNum":int(timeRemaining / 60 % 60),
                  "minuteword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_minute","",int(timeRemaining / 3600))
               });
            }
            else if(timeRemaining > 60)
            {
               timeLeft = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_FriendlyTimeMins",{
                  "minNum":int(timeRemaining / 60),
                  "minuteword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_minute","",int(timeRemaining / 60))
               });
               timeLeft2 = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_FriendlyTimeMinsSecs",{
                  "minNum":int(timeRemaining / 60),
                  "minuteword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_minute","",int(timeRemaining / 60)),
                  "secNum":timeRemaining % 60,
                  "secondword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_second","",timeRemaining % 60)
               });
            }
            else
            {
               timeLeft = timeLeft2 = ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_FriendlyTimeSecs",{
                  "secNum":int(timeRemaining),
                  "secondword":ZLocUtils.tk("Dialogs","sheep_pen_Mating_breed_time_second","",int(timeRemaining))
               });
            }
            if(breedingTooltip != null)
            {
               breedingTooltip.setText(timeLeft);
            }
            else
            {
               breedingPen.detachTooltip();
               breedingPen.attachTooltip(new FarmTextTooltip(timeLeft));
            }
         }
      }
      
      public function updateUI(enable:Boolean = true) : void
      {
         if(enable)
         {
            this.updateExpansionStatus();
            this.updateRender(enable);
            this.updateSuiteState();
            this.updatePotionsCount();
            this.m_disabledFrame.visible = false;
         }
         else
         {
            this.m_disabledFrame.visible = true;
         }
      }
      
      private function updateRender(enable:Boolean = true) : void
      {
         var count:int = 0;
         var farmItem:FarmItem = null;
         var key:String = null;
         var objectPreviewFrame:ObjectPreviewFrame = null;
         var holder:MovieClip = null;
         var j:int = 0;
         var canSelect:Boolean = false;
         var currFarmItemGender:String = null;
         var hasCompatibleGender:Boolean = false;
         this.removeObjects();
         var selectedGender:String = this.getSelectedGender();
         var asexualBreeding:Boolean = Global.animalBreedingSettings.getItemNameFromGender(this.m_parentWindow.building.getItem().name,MutableAnimalState.GENDER_CODE_FEMALE) == Global.animalBreedingSettings.getItemNameFromGender(this.m_parentWindow.building.getItem().name,MutableAnimalState.GENDER_CODE_MALE);
         var breedingMode:Number = this.getBreedingMode();
         var r:Number = 0.212671;
         var g:Number = 0.71516;
         var b:Number = 0.072169;
         var matrix:Array = [];
         matrix = matrix.concat([r,g,b,0,0]);
         matrix = matrix.concat([r,g,b,0,0]);
         matrix = matrix.concat([r,g,b,0,0]);
         matrix = matrix.concat([0,0,0,1,0]);
         var i:int = 1;
         var displayOrdering:Array = this.m_displayOrdering.slice();
         var storageMetaData:Object = this.m_parentWindow.building.storageMetaData;
         var storageDataForCode:Array = null;
         var inUseHashes:Dictionary = (this.m_parentWindow.building.extraDataState as AnimalBreedingState).getInUseBreedHashes();
         var breedingSignItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("messageSign");
         var metaDataArray:Array = null;
         var metaData:Object = {};
         for(key in this.m_parentWindow.building.contents)
         {
            count = int(this.m_parentWindow.building.contents[key]);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
            storageDataForCode = this.m_parentWindow.building.getStorageMetaDataForCode(key);
            for(j = 0; j < count; j++)
            {
               i = displayOrdering.shift();
               holder = this.m_penItems["holder" + i + "_mc"];
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
                  objectPreviewFrame = new ObjectPreviewFrame(holder,farmItem,null,[1.7],null,Animal.STATE_FRONT_IDLE,metaData.data);
                  if(objectPreviewFrame.sprite)
                  {
                     canSelect = false;
                     currFarmItemGender = MutableAnimalState.createFromPhpString("",metaData.data).gender;
                     hasCompatibleGender = currFarmItemGender != selectedGender;
                     if(!asexualBreeding)
                     {
                        if(hasCompatibleGender || breedingMode == BREEDING_MODE_READY)
                        {
                           objectPreviewFrame.sprite.useHandCursor = true;
                           objectPreviewFrame.sprite.buttonMode = true;
                           objectPreviewFrame.sprite.mouseChildren = true;
                           objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OVER,this.animalMouseOverHandler);
                           objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OUT,this.animalMouseOutHandler);
                           objectPreviewFrame.sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.animalMouseDownHandler);
                        }
                        else
                        {
                           objectPreviewFrame.sprite.useHandCursor = false;
                           objectPreviewFrame.sprite.buttonMode = false;
                           objectPreviewFrame.sprite.mouseChildren = false;
                           objectPreviewFrame.sprite.filters = [new ColorMatrixFilter(matrix)];
                           objectPreviewFrame.sprite.alpha = 0.5;
                        }
                     }
                     else if(i == this.m_breedingIndex)
                     {
                        objectPreviewFrame.sprite.useHandCursor = false;
                        objectPreviewFrame.sprite.buttonMode = false;
                        objectPreviewFrame.sprite.mouseChildren = false;
                        objectPreviewFrame.sprite.filters = [new ColorMatrixFilter(matrix)];
                        objectPreviewFrame.sprite.alpha = 0.5;
                     }
                     else
                     {
                        objectPreviewFrame.sprite.useHandCursor = true;
                        objectPreviewFrame.sprite.buttonMode = true;
                        objectPreviewFrame.sprite.mouseChildren = true;
                        objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OVER,this.animalMouseOverHandler);
                        objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OUT,this.animalMouseOutHandler);
                        objectPreviewFrame.sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.animalMouseDownHandler);
                     }
                  }
               }
               else
               {
                  --inUseHashes[metaData.key];
                  objectPreviewFrame = new ObjectPreviewFrame(holder,breedingSignItem,null,[2],null,"");
                  objectPreviewFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_Message_Sign")));
                  objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OVER,this.signMouseOverHandler);
                  objectPreviewFrame.sprite.addEventListener(MouseEvent.ROLL_OUT,this.signMouseOutHandler);
               }
               objectPreviewFrame.id = metaData.key;
               metaData = {};
               this.m_objectPreviewFrames[i] = objectPreviewFrame;
               this.m_graphicsFrame.addWidget(objectPreviewFrame);
            }
         }
      }
      
      private function getBreedingMode() : Number
      {
         var breedingMode:Number = BREEDING_MODE_NONE;
         var numBreedObjects:Number = this.m_breedingSession.getNumBreedObjects();
         if(numBreedObjects == BREEDING_MODE_WAITING_FOR_CLICK)
         {
            breedingMode = BREEDING_MODE_WAITING_FOR_CLICK;
         }
         else if(numBreedObjects == BREEDING_MODE_READY)
         {
            breedingMode = BREEDING_MODE_READY;
         }
         return breedingMode;
      }
      
      public function updatePotionsCount() : void
      {
         var potionsLeft:ZwTextField = this.m_potionStats.getWidget(m_element.potions_mc.counter_tf) as ZwTextField;
         potionsLeft.text = ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Progress",{
            "quantity":AnimalBreedingManager.getInstance().getNumPotions(),
            "maximum":this.m_maxGifts
         });
         var potionBar:ZwFrame = this.m_potionStats.getWidget(m_element.potions_mc.slopBar_mc) as ZwFrame;
         var potionRatio:Number = AnimalBreedingManager.getInstance().getNumPotions() / this.m_maxGifts;
         TweenLite.to(potionBar.element,1,{
            "width":potionRatio * this.m_lovePotionWidth,
            "onComplete":null
         });
         var askButton:FarmAnimatedTextButton = this.m_potionStats.getWidget(m_element.potions_mc.ask_btn) as FarmAnimatedTextButton;
         var buyButton:FarmAnimatedTextButton = this.m_potionStats.getWidget(m_element.potions_mc.buy_btn) as FarmAnimatedTextButton;
         if(potionRatio >= 1)
         {
            this.toggleLovePotionButtons(false);
         }
         else
         {
            this.toggleLovePotionButtons(true);
         }
      }
      
      private function toggleLovePotionButtons(enable:Boolean) : void
      {
         var askButton:FarmAnimatedTextButton = this.m_potionStats.getWidget(m_element.potions_mc.ask_btn) as FarmAnimatedTextButton;
         askButton.enabled = enable;
         var buyButton:FarmAnimatedTextButton = this.m_potionStats.getWidget(m_element.potions_mc.buy_btn) as FarmAnimatedTextButton;
         buyButton.enabled = enable;
      }
      
      private function onBuyMorePotions(event:MouseEvent) : void
      {
         var numPotions:Number = AnimalBreedingManager.getInstance().getNumPotions();
         var messageText:String = "";
         var farmItem:FarmItem = null;
         var cashToBuy:Number = 0;
         var numToBuy:Number = 0;
         if(numPotions < AnimalBreedingManager.MAX_POTION_LIMIT - AnimalBreedingManager.MAX_NUM_POTIONS)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(AnimalBreedingManager.LOVE_POTION_ITEM_NAME_5);
            cashToBuy = farmItem.cash;
            numToBuy = 1;
            messageText = ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Buy_More_Popup",{
               "item":ZLocUtils.tk_pk(farmItem.friendlyName),
               "quantity":farmItem.cash
            });
         }
         else
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(AnimalBreedingManager.LOVE_POTION_ITEM_NAME_1);
            numToBuy = AnimalBreedingManager.MAX_POTION_LIMIT - numPotions;
            cashToBuy = numToBuy * farmItem.cash;
            messageText = ZLocUtils.t("Dialogs",this.m_featureName + "_LovePotion_Buy_More_Popup_Smart",{
               "quantity":numToBuy,
               "item":ZLocUtils.tk_pk(farmItem.friendlyName,"",numToBuy),
               "cashQuantity":cashToBuy
            });
         }
         this.m_dialogEventData.item = farmItem;
         this.m_dialogEventData.numToBuy = numToBuy;
         var canBuy:Boolean = Global.player.canBuyCash(cashToBuy,false);
         if(canBuy)
         {
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyMorePotionsAccept),false);
            this.m_disabledFrame.visible = true;
         }
         else
         {
            UI.displayPopup(new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH,farmItem.type),false,"buyMoreCashPopup",true);
         }
      }
      
      private function onBuyMorePotionsAccept(event:GenericPopupEvent) : void
      {
         var farmItem:FarmItem = null;
         var i:Number = NaN;
         if(event.button == GenericPopup.ACCEPT)
         {
            farmItem = this.m_dialogEventData.item;
            if(farmItem != null)
            {
               for(i = 0; i < this.m_dialogEventData.numToBuy; i++)
               {
                  farmItem.onBuy(farmItem.name,{"displayBuyMessage":false});
               }
               this.updatePotionsCount();
            }
         }
         this.m_dialogEventData = {};
         this.m_disabledFrame.visible = false;
         FarmStatsManager.count(this.m_featureName,"love_potions","buy_more",this.m_dialogEventData.numToBuy);
      }
      
      private function onAskForMorePotions(event:MouseEvent) : void
      {
         if(this.m_askForPotionsButton != null)
         {
            this.m_askForPotionsButton.enabled = false;
         }
         AnimalBreedingManager.getInstance().askForLovePotions(this.m_featureName);
         FarmStatsManager.count(this.m_featureName,"love_potions","ask_for_more");
      }
      
      private function removeObjects() : void
      {
         var objectPreviewFrame:ObjectPreviewFrame = null;
         var holder:MovieClip = null;
         var animalAsset:Sprite = null;
         while(this.m_objectPreviewFrames.length > 0)
         {
            objectPreviewFrame = this.m_objectPreviewFrames.shift();
            if(objectPreviewFrame)
            {
               animalAsset = objectPreviewFrame.sprite;
               if(animalAsset)
               {
                  animalAsset.removeEventListener(MouseEvent.ROLL_OVER,this.animalMouseOverHandler);
                  animalAsset.removeEventListener(MouseEvent.ROLL_OUT,this.animalMouseOutHandler);
                  animalAsset.removeEventListener(MouseEvent.ROLL_OVER,this.signMouseOverHandler);
                  animalAsset.removeEventListener(MouseEvent.ROLL_OUT,this.signMouseOutHandler);
               }
               this.m_graphicsFrame.removeWidget(objectPreviewFrame);
               objectPreviewFrame = null;
            }
         }
      }
      
      private function breedCallback(event:MouseEvent) : void
      {
         var item:Object = event.target;
         event.stopPropagation();
         this.hideRolloverMenu();
         var pattern:String = "\\d+";
         var parentName:String = this.m_activeSprite.parent.name as String;
         var regExp:RegExp = new RegExp(pattern,this.m_activeSprite.parent.name as String);
         this.m_breedingIndex = regExp.exec(this.m_activeSprite.parent.name as String as String);
         if(this.m_activeSprite != null)
         {
            this.m_breedingSession.addBreedObject(this.m_activeSprite.id,this.m_parentWindow.building.getItem().name);
            this.m_keepRolloverOpen = false;
            this.m_activeSprite = null;
         }
         this.updateUI();
         if(this.m_breedingSession.getNumBreedObjects() == BREEDING_MODE_READY)
         {
            this.m_parentWindow.displayMatingWindow(this.m_breedingSession);
            this.cancelBreedFlow();
         }
      }
      
      private function removeCallback(event:MouseEvent) : void
      {
         var farmItem:FarmItem = null;
         var extraData:Object = null;
         var hashSplit:Array = null;
         var realItemName:String = null;
         var jsonString:Object = null;
         var breedingMode:Number = this.getBreedingMode();
         if(this.m_activeSprite != null && breedingMode != BREEDING_MODE_WAITING_FOR_CLICK)
         {
            farmItem = FeatureBuilding.getFarmItemForHash(this.m_activeSprite.id);
            extraData = new Object();
            extraData.isGift = false;
            extraData.repopGift = false;
            hashSplit = FeatureBuilding.parseMetaDataHash(this.m_activeSprite.id);
            realItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(hashSplit[0]);
            jsonString = this.m_breedingSession.owner.getStorageMetaDataForHash(this.m_activeSprite.id);
            extraData.itemMetadata = jsonString;
            if(realItemName != farmItem.name)
            {
               extraData.realItemName = realItemName;
            }
            farmItem.onUse(this.m_parentWindow.building.getId(),extraData);
            this.m_parentWindow.close();
         }
         else
         {
            this.cancelBreedFlow();
         }
      }
      
      private function onFinishCallback(event:MouseEvent) : void
      {
         var breedingSession:AnimalBreedingSession = null;
         var itemName:String = event.target.name;
         var breedingPen:ZwFrame = getWidget(event.currentTarget.parent) as ZwFrame;
         var clickedButton:FarmAnimatedTextButton = breedingPen.getWidget(event.currentTarget.parent[itemName]) as FarmAnimatedTextButton;
         var animalState:AnimalBreedingState = this.m_parentWindow.building.extraDataState as AnimalBreedingState;
         if(animalState != null)
         {
            breedingSession = animalState.getBreedSession(Number(clickedButton.id));
            if(breedingSession != null)
            {
               this.m_disabledFrame.visible = true;
               AnimalBreedingManager.getInstance().finishBreed(breedingSession,function(result:Object):void
               {
                  m_parentWindow.displayPostBreedingWindow(result,breedingSession);
                  updateUI();
               });
            }
         }
         FarmStatsManager.count(this.m_featureName,"breeding","finish");
      }
      
      private function onFinishNowCallback(event:MouseEvent) : void
      {
         var itemName:String = event.target.name;
         var breedingPen:ZwFrame = getWidget(event.currentTarget.parent) as ZwFrame;
         var clickedButton:FarmAnimatedTextButton = breedingPen.getWidget(event.currentTarget.parent[itemName]) as FarmAnimatedTextButton;
         var cashToCompleteNow:Number = Number(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"cashToFinishNow"));
         var canBuy:Boolean = Global.player.canBuyCash(cashToCompleteNow,false);
         if(canBuy)
         {
            this.m_dialogEventData.finishNowSlot = clickedButton.id;
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs",this.m_featureName + "_Mating_Finish_Now_Prompt",{"quantity":cashToCompleteNow}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptFinishNowCallback),false);
         }
         else
         {
            UI.displayPopup(new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH),false,"buyMoreCashPopup",true);
         }
      }
      
      private function onAcceptFinishNowCallback(event:GenericPopupEvent) : void
      {
         var animalState:AnimalBreedingState = null;
         var cashToCompleteNow:Number = NaN;
         var breedingSession:AnimalBreedingSession = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            animalState = this.m_parentWindow.building.extraDataState as AnimalBreedingState;
            cashToCompleteNow = Number(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"cashToFinishNow"));
            if(animalState != null)
            {
               this.m_disabledFrame.visible = true;
               breedingSession = animalState.getBreedSession(Number(this.m_dialogEventData.finishNowSlot));
               AnimalBreedingManager.getInstance().finishBreedNow(breedingSession,cashToCompleteNow,function(result:Object):void
               {
                  m_parentWindow.displayPostBreedingWindow(result,breedingSession);
                  updateUI();
               });
            }
            FarmStatsManager.count(this.m_featureName,"breeding","finish_now","accept");
         }
         else
         {
            FarmStatsManager.count(this.m_featureName,"breeding","finish_now","cancel");
         }
         this.m_dialogEventData = {};
      }
      
      private function penMouseOverHandler(event:MouseEvent) : void
      {
         var finishNowButton:FarmAnimatedTextButton = null;
         var item:Object = event.target;
         var itemName:String = item.name;
         var breedingPen:ZwFrame = getWidget(m_element[itemName]) as ZwFrame;
         if(breedingPen != null)
         {
            if((breedingPen.element as MovieClip).currentFrame == BREEDING_IN_PROGRESS)
            {
               finishNowButton = breedingPen.getWidget(breedingPen.element.finishNow_btn) as FarmAnimatedTextButton;
               finishNowButton.visible = true;
            }
         }
         this.updateSuiteState();
      }
      
      private function penMouseOutHandler(event:MouseEvent) : void
      {
         var finishNowButton:FarmAnimatedTextButton = null;
         var item:Object = event.target;
         var itemName:String = item.name;
         var breedingPen:ZwFrame = getWidget(m_element[itemName]) as ZwFrame;
         if(breedingPen != null)
         {
            if((breedingPen.element as MovieClip).currentFrame == BREEDING_IN_PROGRESS)
            {
               finishNowButton = breedingPen.getWidget(breedingPen.element.finishNow_btn) as FarmAnimatedTextButton;
               finishNowButton.visible = false;
            }
         }
      }
      
      private function backgroundMouseOverHandler(event:MouseEvent) : void
      {
         if(!this.m_keepRolloverOpen)
         {
            this.hideRolloverMenu();
            this.m_activeSprite = null;
         }
      }
      
      private function hideRolloverMenu() : void
      {
         this.m_menuBreed.visible = false;
         (this.m_menuBreed.element as MovieClip).visible = false;
         this.m_menuBreedWithImage.visible = false;
         (this.m_menuBreedWithImage.element as MovieClip).visible = false;
      }
      
      private function getPopulateRolloverMenu(farmItem:FarmItem, metaData:String, spriteX:Number, spriteY:Number) : ZwFrame
      {
         var tempState:MutableAnimalState = null;
         var breederFriend:Friend = null;
         var rolloverMenu:ZwFrame = null;
         var hasBreeder:Boolean = false;
         var breedDisplayBut:FarmAnimatedTextButton = null;
         var removeDisplayBut:FarmAnimatedTextButton = null;
         var animalCustomName:String = farmItem.friendlyName;
         var cantBreedFrame:ZwFrame = null;
         var unlockTf:ZwTextField = null;
         var patternLevel:int = Global.animalBreedingSettings.getPatternLevelFromItem(farmItem,metaData);
         var skillStateFeatureName:String = this.m_parentWindow.building.getItem().name;
         var skillState:AnimalBreedingSkillState = Global.player.getBreedingSkillStateForFeature(skillStateFeatureName);
         var animalCustomNameIsFriendlyName:Boolean = true;
         if(null != metaData && metaData != "")
         {
            tempState = MutableAnimalState.createFromPhpString("",metaData);
            breederFriend = Global.friendManager.getAppFriendData(tempState.breederUid);
            if(null != breederFriend)
            {
               this.m_breederRolloverImage.loadIcon(breederFriend.picture);
               this.m_breederRolloverImage.attachTooltip(new FarmTextTooltip(breederFriend.firstName));
               this.m_breederRolloverImage.visible = true;
               hasBreeder = true;
            }
            if("" != tempState.name && !Global.animalBreedingSettings.isReservedAnimalName(tempState.name))
            {
               animalCustomName = tempState.name;
               animalCustomNameIsFriendlyName = false;
            }
         }
         if(hasBreeder)
         {
            rolloverMenu = this.m_menuBreedWithImage;
            (rolloverMenu.element as MovieClip).visible = true;
            (rolloverMenu.element as MovieClip).x = spriteX + 20;
            (rolloverMenu.element as MovieClip).y = spriteY - 105;
            breedDisplayBut = rolloverMenu.getWidget(m_element.rollover2_mc.breed_bt) as FarmAnimatedTextButton;
            removeDisplayBut = rolloverMenu.getWidget(m_element.rollover2_mc.remove_bt) as FarmAnimatedTextButton;
            if(m_element.rollover2_mc.hasOwnProperty("cantBreed_mc"))
            {
               cantBreedFrame = rolloverMenu.getWidget(m_element.rollover2_mc.cantBreed_mc) as ZwFrame;
               unlockTf = cantBreedFrame.getWidget(m_element.rollover2_mc.cantBreed_mc.unlock_tf) as ZwTextField;
            }
         }
         else
         {
            rolloverMenu = this.m_menuBreed;
            (rolloverMenu.element as MovieClip).visible = true;
            (rolloverMenu.element as MovieClip).x = spriteX + 20;
            (rolloverMenu.element as MovieClip).y = spriteY - 60;
            breedDisplayBut = rolloverMenu.getWidget(m_element.rollover_mc.breed_bt) as FarmAnimatedTextButton;
            removeDisplayBut = rolloverMenu.getWidget(m_element.rollover_mc.remove_bt) as FarmAnimatedTextButton;
            if(m_element.rollover2_mc.hasOwnProperty("cantBreed_mc"))
            {
               cantBreedFrame = rolloverMenu.getWidget(m_element.rollover_mc.cantBreed_mc) as ZwFrame;
               unlockTf = cantBreedFrame.getWidget(m_element.rollover_mc.cantBreed_mc.unlock_tf) as ZwTextField;
            }
         }
         if(null != animalCustomName)
         {
            if(animalCustomNameIsFriendlyName)
            {
               (rolloverMenu.getWidget(m_element.rollover_mc.title_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(animalCustomName);
            }
            else
            {
               (rolloverMenu.getWidget(m_element.rollover_mc.title_tf) as ZwTextField).text = animalCustomName;
            }
         }
         else
         {
            (rolloverMenu.getWidget(m_element.rollover_mc.title_tf) as ZwTextField).text = farmItem.friendlyTitle;
         }
         if(AnimalBreedingManager.getInstance().canBreed(this.m_parentWindow.building) && AnimalBreedingManager.getInstance().findFreeSlot(this.m_breedingSession) >= 0)
         {
            breedDisplayBut.enabled = true;
         }
         else
         {
            breedDisplayBut.enabled = false;
         }
         if(cantBreedFrame != null)
         {
            if(skillState.level < patternLevel)
            {
               breedDisplayBut.visible = false;
               cantBreedFrame.visible = true;
               unlockTf.text = ZLocUtils.t("Dialogs","BreedingUnlockAtLevel",{"levelNum":patternLevel.toString()});
            }
            else
            {
               breedDisplayBut.visible = true;
               cantBreedFrame.visible = false;
            }
         }
         var breedingMode:Number = this.getBreedingMode();
         if(breedingMode == BREEDING_MODE_WAITING_FOR_CLICK)
         {
            removeDisplayBut.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Cancel_Button");
         }
         else
         {
            removeDisplayBut.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Remove_Button");
         }
         return rolloverMenu;
      }
      
      private function animalMouseOverHandler(event:MouseEvent) : void
      {
         var farmItem:FarmItem = null;
         var metaData:Object = null;
         var rolloverMenu:ZwFrame = null;
         var item:Object = event.target;
         var animalSprite:FarmGameSprite = item as FarmGameSprite;
         if(animalSprite != null)
         {
            this.hideRolloverMenu();
            farmItem = FeatureBuilding.getFarmItemForHash(animalSprite.id);
            metaData = this.m_parentWindow.building.getStorageMetaDataForHash(animalSprite.id);
            animalSprite.filters = [this.m_glowFilter];
            if(!this.m_keepRolloverOpen)
            {
               rolloverMenu = this.getPopulateRolloverMenu(farmItem,metaData as String,animalSprite.parent.x,animalSprite.parent.y);
               rolloverMenu.visible = true;
               this.m_activeSprite = animalSprite;
            }
         }
      }
      
      private function animalMouseOutHandler(event:MouseEvent) : void
      {
         event.stopPropagation();
         var item:Object = event.target;
         var animalSprite:Sprite = item as Sprite;
         if(animalSprite != null)
         {
            animalSprite.filters = [];
         }
      }
      
      private function animalMouseDownHandler(event:MouseEvent) : void
      {
         var item:Object = event.target;
         var sprite:FarmGameSprite = item as FarmGameSprite;
         if(sprite != null)
         {
            this.m_keepRolloverOpen = false;
            this.animalMouseOutHandler(event);
            this.animalMouseOverHandler(event);
            this.m_keepRolloverOpen = true;
         }
         else
         {
            this.m_keepRolloverOpen = false;
         }
      }
      
      private function signMouseOverHandler(event:MouseEvent) : void
      {
         var farmItem:FarmItem = null;
         var item:Object = event.target;
         var sprite:FarmGameSprite = item as FarmGameSprite;
         if(sprite != null)
         {
            if(!this.m_keepRolloverOpen)
            {
               farmItem = FeatureBuilding.getFarmItemForHash(sprite.id);
               sprite.filters = [this.m_glowFilter];
            }
         }
      }
      
      private function signMouseOutHandler(event:MouseEvent) : void
      {
         var item:Object = null;
         var sprite:Sprite = null;
         event.stopPropagation();
         if(!this.m_keepRolloverOpen)
         {
            item = event.target;
            sprite = item as Sprite;
            if(sprite != null)
            {
               sprite.filters = [];
            }
         }
      }
      
      private function closeRolloverCallback(event:MouseEvent) : void
      {
         event.stopPropagation();
         this.cancelBreedFlow();
      }
      
      private function cancelBreedFlow() : void
      {
         this.m_breedingIndex = -1;
         this.hideRolloverMenu();
         this.m_breedingSession.clearBreedObjects();
         this.updateUI();
      }
      
      private function openMarket(event:Event) : void
      {
         var buildingName:String = this.m_parentWindow.building.getItemName();
         var animalName:String = Global.animalBreedingSettings.getItemNameFromGender(this.m_parentWindow.building.getItem().name,MutableAnimalState.GENDER_CODE_MALE) + "_friendlyName";
         this.m_parentWindow.close();
         switch(buildingName)
         {
            case "turtlepen_finished":
               UI.displayMarketDialog(buildingName + "_breedingWindow","animal",null,"all",null,"turtles");
         }
      }
      
      private function onLockedLevelWhatIsThisClick(event:MouseEvent) : void
      {
         UI.displayMessage("This pattern is locked. Level up to unlock it!",0,null,"",true,true,"breeding_levels_whatisthis");
      }
   }
}

