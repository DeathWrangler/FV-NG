package Widgets.Frames
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.DragonBreeding.MutableDragonState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.DragonBreedingFamilyTreeSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.DragonBreedingFamilyWindow;
   import Widgets.Windows.DragonBreedingSelectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DragonBreedingFamilyTreeFrame extends FarmSlotContainerFrame
   {
      
      public static const BREEDING_ANIMAL_ZOOM_LEVEL:Number = 2.5;
      
      private const PARENT_MALE:String = "parenticon_male_mc";
      
      private const PARENT_FEMALE:String = "parenticon_female_mc";
      
      private const OUTCOME_BUTTON:String = "selectoutcome_bt";
      
      private const CLOSE_BUTTON:String = "close_bt";
      
      private const OUTCOME_CASH:String = "selectcost_tf";
      
      private const CONTINUE_BUTTON:String = "continue_bt";
      
      private const OUTCOME_CASH_VALUE:String = "5";
      
      private var m_leftArrowButton1:FarmButton;
      
      private var m_rightArrowButton1:FarmButton;
      
      private var m_leftArrowButton2:FarmButton;
      
      private var m_rightArrowButton2:FarmButton;
      
      public var m_selectOutcomeButton:FarmAnimatedTextButton;
      
      private var m_closeButton:FarmAnimatedButton;
      
      private var m_outcometextfield:FarmTextField;
      
      public var m_continueButton:FarmAnimatedButton;
      
      private var arrowFrame1:ZwFrame;
      
      private var arrowFrame2:ZwFrame;
      
      private var breeding_away1:FarmTextField;
      
      private var breeding_away2:FarmTextField;
      
      private var m_left_lock:MovieClip;
      
      private var m_right_lock:MovieClip;
      
      private var m_left_timer:MovieClip;
      
      private var m_right_timer:MovieClip;
      
      private var m_left_box:MovieClip;
      
      private var m_right_box:MovieClip;
      
      protected var m_femaleCounter:int = 0;
      
      protected var m_maleCounter:int = 0;
      
      protected var m_maleCollection:Array;
      
      protected var m_femaleCollection:Array;
      
      public var m_featureName:String = "dragon_pen_finished";
      
      private var m_breedingSession:DragonBreedingSession;
      
      protected var m_breedObjs:Array = null;
      
      protected var m_resourcePreviewFrame1:ResourcePreviewFrame = null;
      
      protected var m_resourcePreviewFrame2:ResourcePreviewFrame = null;
      
      protected var m_animalName1:ZwTextField = null;
      
      protected var m_animalName2:ZwTextField = null;
      
      private var m_owner:DragonBreedingFamilyWindow;
      
      private var m_selectionWindow:DragonBreedingSelectionWindow;
      
      private var maleTextField:FarmTextField;
      
      private var femaleTextField:FarmTextField;
      
      private var m_rightTimerText:FarmTextField;
      
      private var m_leftTimerText:FarmTextField;
      
      private var m_sourceWindow:int = 0;
      
      private var maleIsBreeding:Boolean;
      
      private var femaleIsBreeding:Boolean;
      
      private var m_visitingDragonTimer:Timer;
      
      public function DragonBreedingFamilyTreeFrame(element:DisplayObject, owner:DragonBreedingFamilyWindow, fromSource:int, selectionWindow:DragonBreedingSelectionWindow)
      {
         var female:Object = null;
         var male:Object = null;
         var dragon:Object = null;
         var freeSlot:Number = NaN;
         this.m_maleCollection = [];
         this.m_femaleCollection = [];
         var i:int = 0;
         this.m_owner = owner;
         this.m_selectionWindow = selectionWindow;
         this.m_sourceWindow = fromSource;
         female = DragonBreedingManager.getInstance(this.m_featureName).getMutableFemaleData();
         male = DragonBreedingManager.getInstance(this.m_featureName).getMutableMaleData();
         if(this.m_sourceWindow == DragonBreedingManager.MAIN_WINDOW)
         {
            i = 0;
            for each(dragon in female)
            {
               this.m_femaleCollection[i] = dragon;
               i++;
            }
            i = 0;
            for each(dragon in male)
            {
               this.m_maleCollection[i] = dragon;
               i++;
            }
            this.m_maleCollection.sortOn("unlocked",Array.DESCENDING);
            this.m_femaleCollection.sortOn("unlocked",Array.DESCENDING);
         }
         else
         {
            this.m_femaleCollection[0] = female[DragonBreedingManager.getInstance(this.m_featureName).selectedFemaleDragonId];
            this.m_maleCollection[0] = male[DragonBreedingManager.getInstance(this.m_featureName).selectedMaleDragonId];
         }
         super(element);
         if(m_element.hasOwnProperty("box_mc"))
         {
            m_element.box_mc.visible = true;
         }
         if(m_element.hasOwnProperty(this.PARENT_MALE))
         {
            this.arrowFrame1 = new ZwFrame(m_element.parenticon_male_mc);
            if(this.m_maleCollection.length > 1)
            {
               if(m_element.parenticon_male_mc.leftArrow_bt)
               {
                  this.m_leftArrowButton1 = new FarmButton(m_element.parenticon_male_mc.leftArrow_bt,this.onLeftArrowPress1);
                  this.arrowFrame1.addWidget(this.m_leftArrowButton1,true);
               }
               if(m_element.parenticon_male_mc.rightArrow_bt)
               {
                  this.m_rightArrowButton1 = new FarmButton(m_element.parenticon_male_mc.rightArrow_bt,this.onRightArrowPress1);
                  this.arrowFrame1.addWidget(this.m_rightArrowButton1,true);
               }
            }
            addWidget(this.arrowFrame1,true);
            if(m_element.parenticon_male_mc.box_mc)
            {
               this.m_left_box = m_element.parenticon_male_mc.box_mc;
               this.m_left_box.visible = true;
            }
            if(m_element.parenticon_male_mc.lock_mc)
            {
               this.m_left_lock = m_element.parenticon_male_mc.lock_mc;
               this.m_left_lock.visible = false;
            }
            if(m_element.parenticon_male_mc.timer_mc)
            {
               this.m_left_timer = m_element.parenticon_male_mc.timer_mc;
               this.m_left_timer.visible = false;
               if(Boolean(this.m_left_timer) && this.m_left_timer.hasOwnProperty("timer_tf"))
               {
                  this.m_leftTimerText = new FarmTextField(this.m_left_timer.timer_tf);
                  this.m_leftTimerText.visible = false;
               }
            }
            if(m_element.parenticon_male_mc.itemTitle_tf)
            {
               this.maleTextField = new FarmTextField(m_element.parenticon_male_mc.itemTitle_tf);
            }
            if(m_element.parenticon_male_mc.breeding_tf)
            {
               this.breeding_away1 = new FarmTextField(m_element.parenticon_male_mc.breeding_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FamilyFrame_awayBreeding"));
               this.breeding_away1.visible = false;
               this.maleIsBreeding = false;
            }
         }
         if(m_element.hasOwnProperty(this.PARENT_FEMALE))
         {
            this.arrowFrame2 = new ZwFrame(m_element.parenticon_female_mc);
            if(this.m_femaleCollection.length > 1)
            {
               if(m_element.parenticon_female_mc.leftArrow_bt)
               {
                  this.m_leftArrowButton2 = new FarmButton(m_element.parenticon_female_mc.leftArrow_bt,this.onLeftArrowPress2);
                  this.arrowFrame2.addWidget(this.m_leftArrowButton2,true);
               }
               if(m_element.parenticon_female_mc.rightArrow_bt)
               {
                  this.m_rightArrowButton2 = new FarmButton(m_element.parenticon_female_mc.rightArrow_bt,this.onRightArrowPress2);
                  this.arrowFrame2.addWidget(this.m_rightArrowButton2,true);
               }
            }
            addWidget(this.arrowFrame2,true);
            if(m_element.parenticon_female_mc.box_mc)
            {
               this.m_right_box = m_element.parenticon_female_mc.box_mc;
               this.m_right_box.visible = true;
            }
            if(m_element.parenticon_female_mc.lock_mc)
            {
               this.m_right_lock = m_element.parenticon_female_mc.lock_mc;
               this.m_right_lock.visible = false;
            }
            if(m_element.parenticon_female_mc.timer_mc)
            {
               this.m_right_timer = m_element.parenticon_female_mc.timer_mc;
               this.m_right_timer.visible = false;
               if(Boolean(this.m_right_timer) && this.m_right_timer.hasOwnProperty("timer_tf"))
               {
                  this.m_rightTimerText = new FarmTextField(this.m_right_timer.timer_tf);
                  this.m_rightTimerText.visible = false;
               }
            }
            if(m_element.parenticon_female_mc.itemTitle_tf)
            {
               this.femaleTextField = new FarmTextField(m_element.parenticon_female_mc.itemTitle_tf);
            }
            if(m_element.parenticon_female_mc.breeding_tf)
            {
               this.breeding_away2 = new FarmTextField(m_element.parenticon_female_mc.breeding_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FamilyFrame_awayBreeding"));
               this.breeding_away2.visible = false;
               this.femaleIsBreeding = false;
            }
         }
         if(m_element.hasOwnProperty(this.OUTCOME_BUTTON))
         {
            this.m_selectOutcomeButton = new FarmAnimatedTextButton(m_element.selectoutcome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_selecteBtnTxtDisabled"),this.onSelectOutCome);
            freeSlot = DragonBreedingManager.getInstance(this.m_featureName).findFreeSlot();
            if(this.maleIsBreeding || this.femaleIsBreeding || freeSlot < 0)
            {
               this.m_selectOutcomeButton.enabled = false;
            }
            else
            {
               this.m_selectOutcomeButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FamilyFrame_selectBtnText");
               this.m_selectOutcomeButton.enabled = true;
               if(!DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring)
               {
                  this.m_selectOutcomeButton.enabled = false;
               }
            }
            addWidget(this.m_selectOutcomeButton,true);
         }
         if(m_element.hasOwnProperty(this.CLOSE_BUTTON))
         {
            this.m_closeButton = new FarmAnimatedButton(m_element.close_bt,this.onCloseButton);
            addWidget(this.m_closeButton,true);
         }
         if(m_element.hasOwnProperty(this.OUTCOME_CASH))
         {
            this.m_outcometextfield = new FarmTextField(m_element.selectcost_tf,this.OUTCOME_CASH_VALUE);
            addWidget(this.m_outcometextfield,true);
         }
         if(m_element.hasOwnProperty(this.CONTINUE_BUTTON))
         {
            this.m_continueButton = new FarmAnimatedButton(m_element.continue_bt,this.onContinue);
            addWidget(this.m_continueButton);
         }
         this.loadData(this.m_breedingSession,true);
      }
      
      private function onContinue(ev:MouseEvent) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring = null;
         this.openSelectionWindow();
      }
      
      private function onSelectOutCome(ev:MouseEvent) : void
      {
         this.openSelectionWindow();
      }
      
      private function openSelectionWindow() : void
      {
         var maleItemName:String = this.m_maleCollection[this.m_maleCounter].itemName;
         var femaleItemName:String = this.m_femaleCollection[this.m_femaleCounter].itemName;
         if(this.m_owner)
         {
            this.m_owner.openSelectionWindow(maleItemName,femaleItemName);
         }
      }
      
      private function onCloseButton(ev:MouseEvent) : void
      {
         m_element.visible = false;
      }
      
      private function onLeftArrowPress1(ev:MouseEvent) : void
      {
         this.m_maleCounter = this.m_maleCounter == 0 ? int(this.m_maleCollection.length - 1) : int(this.m_maleCounter - 1);
         this.loadData(this.m_breedingSession,true);
         this.deselect();
         this.refresh();
      }
      
      private function onRightArrowPress1(ev:MouseEvent) : void
      {
         this.m_maleCounter = this.m_maleCounter == this.m_maleCollection.length - 1 ? 0 : int(this.m_maleCounter + 1);
         this.loadData(this.m_breedingSession,true);
         this.deselect();
         this.refresh();
      }
      
      private function onLeftArrowPress2(ev:MouseEvent) : void
      {
         this.m_femaleCounter = this.m_femaleCounter == 0 ? int(this.m_femaleCollection.length - 1) : int(this.m_femaleCounter - 1);
         this.loadData(this.m_breedingSession,true);
         this.deselect();
         this.refresh();
      }
      
      private function onRightArrowPress2(ev:MouseEvent) : void
      {
         this.m_femaleCounter = this.m_femaleCounter == this.m_femaleCollection.length - 1 ? 0 : int(this.m_femaleCounter + 1);
         this.loadData(this.m_breedingSession,true);
         this.deselect();
         this.refresh();
      }
      
      private function deselect() : void
      {
         var slot:DragonBreedingFamilyTreeSlot = null;
         DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring = null;
         this.m_selectOutcomeButton.enabled = false;
         for each(slot in m_slots)
         {
            if(slot.m_select_mc)
            {
               slot.m_select_mc.visible = false;
            }
         }
      }
      
      public function loadData(breedingSession:DragonBreedingSession, keyPress:Boolean = false) : void
      {
         var femaleDragon:FarmItem = null;
         var vdcount:int = 0;
         var maleDragon:FarmItem = null;
         var vdcount2:int = 0;
         this.releasePreviewFrames();
         if(Boolean(this.m_maleCollection.length <= 1) && Boolean(this.m_leftArrowButton1) && Boolean(this.m_rightArrowButton1))
         {
            this.m_leftArrowButton1.enabled = false;
            this.m_rightArrowButton1.enabled = false;
         }
         else if(Boolean(this.m_leftArrowButton1) && Boolean(this.m_rightArrowButton1))
         {
            this.m_leftArrowButton1.enabled = true;
            this.m_rightArrowButton1.enabled = true;
         }
         if(Boolean(this.m_femaleCollection.length <= 1) && Boolean(this.m_leftArrowButton2) && Boolean(this.m_rightArrowButton2))
         {
            this.m_leftArrowButton2.enabled = false;
            this.m_rightArrowButton2.enabled = false;
         }
         else if(Boolean(this.m_leftArrowButton2) && Boolean(this.m_rightArrowButton2))
         {
            this.m_leftArrowButton2.enabled = true;
            this.m_rightArrowButton2.enabled = true;
         }
         if(this.m_femaleCollection.length >= 1)
         {
            femaleDragon = Global.farmGameSettingsManager.getFarmItemByName(this.m_femaleCollection[this.m_femaleCounter].itemName);
            if(Boolean(m_element) && Boolean(m_element.parenticon_female_mc) && Boolean(m_element.parenticon_female_mc.icon_mc_2) && Boolean(femaleDragon))
            {
               this.femaleTextField.text = ZLocUtils.tk_pk_asTitle(femaleDragon.friendlyName);
               this.femaleTextField.visible = true;
               this.m_resourcePreviewFrame2 = new ResourcePreviewFrame(m_element.parenticon_female_mc.icon_mc_2);
               if(femaleDragon)
               {
                  this.m_resourcePreviewFrame2.load(femaleDragon.imageRelativeUrl(Animal.STATE_FRONT_IDLE),femaleDragon.overrideExportName + "_" + Animal.STATE_FRONT_IDLE);
               }
               if(DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE) == femaleDragon.code)
               {
                  this.enableFemaleVisitingDragon();
               }
               else
               {
                  this.disableFemaleVisitingDragon();
               }
               if(Boolean(this.m_femaleCollection[this.m_femaleCounter].unlocked) || Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_femaleCollection[this.m_femaleCounter].itemName) == DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE))
               {
                  vdcount = 0;
                  if(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_femaleCollection[this.m_femaleCounter].itemName) == DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE))
                  {
                     vdcount = 1;
                  }
                  else
                  {
                     vdcount = 0;
                  }
                  this.m_right_lock.visible = false;
                  this.m_resourcePreviewFrame2.alpha = DragonBreedingManager.NORMAL;
                  if(m_element.parenticon_female_mc)
                  {
                     m_element.parenticon_female_mc.enabled = true;
                  }
                  if(this.m_femaleCollection[this.m_femaleCounter].itemCount + vdcount - DragonBreedingManager.getInstance(this.m_featureName).getBreedingDragonCount(this.m_femaleCollection[this.m_femaleCounter].itemName) > 0)
                  {
                     this.breeding_away2.visible = false;
                     this.femaleIsBreeding = false;
                  }
                  else
                  {
                     this.breeding_away2.visible = true;
                     this.femaleIsBreeding = true;
                  }
               }
               else
               {
                  this.m_right_lock.visible = true;
                  this.m_resourcePreviewFrame2.alpha = DragonBreedingManager.GRAY_OUT;
                  if(m_element.parenticon_female_mc)
                  {
                     m_element.parenticon_female_mc.enabled = false;
                  }
                  this.breeding_away2.visible = false;
                  this.femaleIsBreeding = false;
               }
               addWidget(this.m_resourcePreviewFrame2,true);
            }
         }
         if(this.m_maleCollection.length >= 1)
         {
            maleDragon = Global.farmGameSettingsManager.getFarmItemByName(this.m_maleCollection[this.m_maleCounter].itemName);
            if(Boolean(m_element) && Boolean(m_element.parenticon_male_mc) && Boolean(m_element.parenticon_male_mc.icon_mc_1) && Boolean(maleDragon))
            {
               this.maleTextField.text = ZLocUtils.tk_pk_asTitle(maleDragon.friendlyName);
               this.maleTextField.visible = true;
               this.m_resourcePreviewFrame1 = new ResourcePreviewFrame(m_element.parenticon_male_mc.icon_mc_1);
               if(maleDragon)
               {
                  this.m_resourcePreviewFrame1.load(maleDragon.imageRelativeUrl(Animal.STATE_FRONT_IDLE),maleDragon.overrideExportName + "_" + Animal.STATE_FRONT_IDLE);
               }
               if(DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_MALE) == maleDragon.code)
               {
                  this.enableMaleVisitingDragon();
               }
               else
               {
                  this.disableMaleVisitingDragon();
               }
               if(Boolean(this.m_maleCollection[this.m_maleCounter].unlocked) || Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_maleCollection[this.m_maleCounter].itemName) == DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_MALE))
               {
                  vdcount2 = 0;
                  if(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_maleCollection[this.m_maleCounter].itemName) == DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_MALE))
                  {
                     vdcount2 = 1;
                  }
                  else
                  {
                     vdcount2 = 0;
                  }
                  this.m_left_lock.visible = false;
                  this.m_resourcePreviewFrame1.alpha = DragonBreedingManager.NORMAL;
                  if(m_element.parenticon_male_mc)
                  {
                     m_element.parenticon_male_mc.enabled = true;
                  }
                  if(this.m_maleCollection[this.m_maleCounter].itemCount + vdcount2 - DragonBreedingManager.getInstance(this.m_featureName).getBreedingDragonCount(this.m_maleCollection[this.m_maleCounter].itemName) > 0)
                  {
                     this.breeding_away1.visible = false;
                     this.maleIsBreeding = false;
                  }
                  else
                  {
                     this.breeding_away1.visible = true;
                     this.maleIsBreeding = true;
                  }
               }
               else
               {
                  this.m_left_lock.visible = true;
                  this.m_resourcePreviewFrame1.alpha = DragonBreedingManager.GRAY_OUT;
                  if(m_element.parenticon_male_mc)
                  {
                     m_element.parenticon_male_mc.enabled = false;
                  }
                  this.breeding_away1.visible = false;
                  this.maleIsBreeding = false;
               }
               addWidget(this.m_resourcePreviewFrame1,true);
            }
         }
         if(this.m_sourceWindow == DragonBreedingManager.MAIN_WINDOW)
         {
            this.m_continueButton.visible = false;
         }
         else
         {
            this.m_continueButton.visible = true;
            if(this.canEnableContinueBtn())
            {
               this.m_continueButton.enabled = true;
            }
            else
            {
               this.m_continueButton.enabled = false;
            }
         }
         this.refresh();
      }
      
      private function canEnableContinueBtn() : Boolean
      {
         var result:Boolean = false;
         var maleItemName:String = this.m_maleCollection[this.m_maleCounter].itemName;
         var femaleItemName:String = this.m_femaleCollection[this.m_femaleCounter].itemName;
         var maleUnlocked:Boolean = Boolean(this.m_maleCollection[this.m_maleCounter].unlocked);
         var femaleUnlocked:Boolean = Boolean(this.m_femaleCollection[this.m_femaleCounter].unlocked);
         if(Boolean(maleItemName) && Boolean(this.isvalidVistingDragonByItemName(maleItemName)) && !this.isVisitingDragonInBreedingByItemName(maleItemName))
         {
            if(!maleUnlocked)
            {
               maleUnlocked = true;
            }
         }
         if(Boolean(femaleItemName) && Boolean(this.isvalidVistingDragonByItemName(femaleItemName)) && !this.isVisitingDragonInBreedingByItemName(femaleItemName))
         {
            if(!femaleUnlocked)
            {
               femaleUnlocked = true;
            }
         }
         return maleUnlocked && femaleUnlocked;
      }
      
      private function isvalidVistingDragonByItemName(itemName:String) : Boolean
      {
         var result:Boolean = false;
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         if(Boolean(itemCode) && itemCode != "")
         {
            result = DragonBreedingManager.getInstance(this.m_featureName).isValidVisitingDragonByItemCode(itemCode);
         }
         return result;
      }
      
      private function isVisitingDragonInBreedingByItemName(itemName:String) : Boolean
      {
         var itemCode:String = null;
         var result:Boolean = false;
         if(this.isvalidVistingDragonByItemName(itemName))
         {
            itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
            if(Boolean(itemCode) && Boolean(itemCode != "") && DragonBreedingManager.getInstance(this.m_featureName).isVisitingDragonInBreedingByItemCode(itemCode))
            {
               result = true;
            }
         }
         return result;
      }
      
      private function onFemaleVisitingDragonTimer(ev:Event) : void
      {
         this.enableFemaleVisitingDragon();
      }
      
      private function onMaleVisitingDragonTimer(ev:Event) : void
      {
         this.enableMaleVisitingDragon();
      }
      
      private function disableFemaleVisitingDragon() : void
      {
         if(this.m_right_timer)
         {
            this.m_right_timer.visible = false;
            this.m_rightTimerText.visible = false;
            this.m_rightTimerText.text = "";
         }
         if(this.m_visitingDragonTimer)
         {
            this.m_visitingDragonTimer.stop();
            this.m_visitingDragonTimer.removeEventListener(TimerEvent.TIMER,this.onFemaleVisitingDragonTimer);
            this.m_visitingDragonTimer = null;
         }
      }
      
      private function disableMaleVisitingDragon() : void
      {
         if(this.m_left_timer)
         {
            this.m_left_timer.visible = false;
            this.m_leftTimerText.visible = false;
            this.m_leftTimerText.text = "";
         }
         if(this.m_visitingDragonTimer)
         {
            this.m_visitingDragonTimer.stop();
            this.m_visitingDragonTimer.removeEventListener(TimerEvent.TIMER,this.onMaleVisitingDragonTimer);
            this.m_visitingDragonTimer = null;
         }
      }
      
      private function enableFemaleVisitingDragon() : void
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_femaleCollection[this.m_femaleCounter].itemName);
         var timeRemaining:Number = -1;
         if(Boolean(itemCode) && itemCode != "")
         {
            timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getVistingDragonTimeRemainingByItemCode(itemCode);
         }
         if(Boolean(this.m_right_timer) && Boolean(this.m_rightTimerText))
         {
            this.m_right_timer.visible = true;
            if(timeRemaining > 0)
            {
               this.m_rightTimerText.visible = true;
               this.m_rightTimerText.text = HUD.getformattedTimeLeft(timeRemaining);
               if(this.m_visitingDragonTimer != null)
               {
                  this.m_visitingDragonTimer.stop();
               }
               else
               {
                  this.m_visitingDragonTimer = new Timer(1000);
                  this.m_visitingDragonTimer.addEventListener(TimerEvent.TIMER,this.onFemaleVisitingDragonTimer,false,0,true);
               }
               if(!this.m_visitingDragonTimer.running)
               {
                  this.m_visitingDragonTimer.start();
               }
            }
            else
            {
               this.disableFemaleVisitingDragon();
            }
         }
      }
      
      private function enableMaleVisitingDragon() : void
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_maleCollection[this.m_maleCounter].itemName);
         var timeRemaining:Number = -1;
         if(Boolean(itemCode) && itemCode != "")
         {
            timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getVistingDragonTimeRemainingByItemCode(itemCode);
         }
         if(Boolean(this.m_left_timer) && Boolean(this.m_leftTimerText))
         {
            this.m_left_timer.visible = true;
            if(timeRemaining > 0)
            {
               this.m_leftTimerText.visible = true;
               this.m_leftTimerText.text = HUD.getformattedTimeLeft(timeRemaining);
               if(this.m_visitingDragonTimer != null)
               {
                  this.m_visitingDragonTimer.stop();
               }
               else
               {
                  this.m_visitingDragonTimer = new Timer(1000);
                  this.m_visitingDragonTimer.addEventListener(TimerEvent.TIMER,this.onMaleVisitingDragonTimer,false,0,true);
               }
               if(!this.m_visitingDragonTimer.running)
               {
                  this.m_visitingDragonTimer.start();
               }
            }
            else
            {
               this.disableMaleVisitingDragon();
            }
         }
      }
      
      public function updateContents() : void
      {
      }
      
      protected function setCounters(muteState1:MutableDragonState, muteState2:MutableDragonState) : void
      {
         var i:int = 0;
         var muteState:MutableDragonState = null;
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
      
      protected function releasePreviewFrames() : void
      {
         if(this.m_resourcePreviewFrame1 != null)
         {
            removeWidget(this.m_resourcePreviewFrame1);
            this.m_resourcePreviewFrame1 = null;
            if(Boolean(this.m_leftArrowButton1) && Boolean(this.m_rightArrowButton1))
            {
               this.m_leftArrowButton1.enabled = true;
               this.m_rightArrowButton1.enabled = true;
            }
         }
         if(this.m_resourcePreviewFrame2 != null)
         {
            removeWidget(this.m_resourcePreviewFrame2);
            this.m_resourcePreviewFrame2 = null;
            if(Boolean(this.m_leftArrowButton2) && Boolean(this.m_rightArrowButton2))
            {
               this.m_leftArrowButton2.enabled = true;
               this.m_rightArrowButton2.enabled = true;
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var firstSplit:String = slotElement.name.split("slot_")[1];
         var index:String = firstSplit.split("_mc")[0];
         return new DragonBreedingFamilyTreeSlot(slotElement,m_slots,index,this,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         var maleDragon:String = null;
         var femaleDragon:String = null;
         var locked:Boolean = false;
         var isBreeding:Boolean = false;
         var maleVisitingDragon:String = null;
         var femaleVisitingDragon:String = null;
         var slot:Object = null;
         var dragonData:Array = [];
         var freeSlot:Number = DragonBreedingManager.getInstance(this.m_featureName).findFreeSlot();
         isBreeding = this.maleIsBreeding || this.femaleIsBreeding;
         maleDragon = this.m_maleCollection[this.m_maleCounter].itemName;
         femaleDragon = this.m_femaleCollection[this.m_femaleCounter].itemName;
         maleVisitingDragon = Global.farmGameSettingsManager.getFarmItemNameByCode(DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_MALE));
         femaleVisitingDragon = Global.farmGameSettingsManager.getFarmItemNameByCode(DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE));
         locked = !this.m_maleCollection[this.m_maleCounter].unlocked || !this.m_femaleCollection[this.m_femaleCounter].unlocked;
         if(maleVisitingDragon == maleDragon && femaleVisitingDragon == femaleDragon)
         {
            locked = false;
         }
         else
         {
            if(maleVisitingDragon == maleDragon)
            {
               locked = !this.m_femaleCollection[this.m_femaleCounter].unlocked;
            }
            if(femaleVisitingDragon == femaleDragon)
            {
               locked = !this.m_maleCollection[this.m_maleCounter].unlocked;
            }
         }
         m_slotData = [];
         var i:int = 1;
         for each(slot in m_slots)
         {
            dragonData.push({
               "maleDragon":maleDragon,
               "femaleDragon":femaleDragon,
               "slotIndex":i,
               "slot":slot,
               "locked":locked,
               "away_breeding":isBreeding,
               "freeSlot":freeSlot
            });
            i++;
         }
         m_slotData = dragonData;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_leftArrowButton1 = null;
         this.m_rightArrowButton1 = null;
         this.m_leftArrowButton2 = null;
         this.m_rightArrowButton2 = null;
         this.m_resourcePreviewFrame1 = null;
         this.m_resourcePreviewFrame2 = null;
         this.m_selectOutcomeButton = null;
         this.m_closeButton = null;
         this.m_outcometextfield = null;
         this.m_continueButton = null;
         this.m_owner = null;
         this.m_selectionWindow = null;
      }
      
      override public function refresh() : void
      {
         this.setupData();
         this.m_owner.refreshWindow();
         super.refresh();
      }
   }
}

