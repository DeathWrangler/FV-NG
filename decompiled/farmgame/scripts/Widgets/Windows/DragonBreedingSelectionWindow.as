package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.text.TextField;
   
   public class DragonBreedingSelectionWindow extends FarmWindow
   {
      
      private const SELECTDRAGON_MC:String = "selectdragon_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BREED_BT:String = "breed_bt";
      
      private const PARENT_MALE_ICON:String = "parenticon_male_mc";
      
      private const PARENT_FEMALE_ICON:String = "parenticon_female_mc";
      
      private const BABY_DRAGON_ICON:String = "babydragon_mc";
      
      private const POTION_COUNT_TF:String = "potioncount_tf";
      
      private const BREEDING_TIME_TF:String = "breedingtime_tf";
      
      private const SELECT_OUTCOME_TXT:String = "selectoutcome_tf";
      
      private const LP_DOWN_BTN:String = "down_bt";
      
      private const LP_UP_BTN:String = "up_bt";
      
      private const CHANGE_OFFSPRING_BTN:String = "change_bt";
      
      private const RANDOM_BABY_DRAGON_ICON:String = "randomdragon_mc";
      
      private const COUNTER_MC:String = "counter_mc";
      
      private const BREEDING_DESCRP_TF:String = "breedingdescription_tf";
      
      private const OFFSPRINGOUTCOME_DESC_TF:String = "viewoutcome_tf";
      
      private const MALE_ITEM_NAME_TF:String = "itemTitle_tf_0";
      
      private const FEMALE_ITEM_NAME_TF:String = "itemTitle_tf_1";
      
      private const PAID_OUTCOME_RADIO_BTN:String = "paidoutcome_bt";
      
      private const RANDOM_OUTCOME_RADIO_BTN:String = "randomoutcome_bt";
      
      private var m_featureName:String = "";
      
      private var m_mainMc:MovieClip;
      
      private var m_breedBtn:FarmAnimatedCashButton;
      
      private var m_parentMaleIcon:ResourcePreviewFrame;
      
      private var m_parentFemaleIcon:ResourcePreviewFrame;
      
      private var m_lovePotionCountTxt:ZwTextField;
      
      private var m_babyDragonIcon:FarmIcon;
      
      private var m_breedingTimeTxt:ZwTextField;
      
      private var m_randomDragonMc:MovieClip;
      
      private var m_changeBabyDragonBtn:FarmAnimatedButton;
      
      private var m_selectOutcomeTxt:ZwTextField;
      
      private var m_lovePotionAddBtn:FarmButton;
      
      private var m_lovePotionSubBtn:FarmButton;
      
      protected var m_numBreedPotions:Number = DragonBreedingManager.getInstance(this.m_featureName).getPotionsForSelectionPopup();
      
      protected var m_isPreselectedOffspring:Boolean = false;
      
      private var m_isBreedBtnClicked:Boolean = false;
      
      private var m_isChangeBabyBtnClicked:Boolean = false;
      
      private var m_selectedBabyDragon:Object;
      
      private var m_randomOutcomeRadioMc:ZwBaseWidget;
      
      private var m_paidOutcomeRadioMc:ZwBaseWidget;
      
      private var m_parentWindow:DragonBreedingWindow;
      
      private var m_randomOutcomeRelease:ZwBaseWidget;
      
      private var m_paidOutcomeRelease:ZwBaseWidget;
      
      private var m_clickedRandom:Boolean;
      
      private var m_clickedPaid:Boolean;
      
      public function DragonBreedingSelectionWindow(featureName:String, selectedDragon:Object = null, parentWindow:DragonBreedingWindow = null)
      {
         this.m_featureName = featureName;
         this.m_selectedBabyDragon = selectedDragon;
         this.m_parentWindow = parentWindow;
         var dialogPath:String = DragonBreedingManager.getInstance(this.m_featureName).getSelectionDialogURL();
         if(dialogPath == "" || dialogPath == null)
         {
            dialogPath = "assets/dialogs/DragonBreeding/FV_DragonBreeding_PopUps_Selection.swf";
         }
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var maleItem:FarmItem = null;
         var exportedMaleName:String = null;
         var femaleItem:FarmItem = null;
         var exportedFemaleName:String = null;
         var counterMc:MovieClip = null;
         var randomOutcomeText:String = null;
         var paidOutcomeText:String = null;
         var timeNeeded:Number = NaN;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.SELECTDRAGON_MC))
         {
            this.m_mainMc = m_window.selectdragon_mc as MovieClip;
            this.m_mainMc.visible = true;
         }
         this.m_isPreselectedOffspring = this.m_selectedBabyDragon != null ? true : false;
         if(this.m_mainMc.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(this.m_mainMc[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_title")),true);
         }
         if(this.m_mainMc.hasOwnProperty(this.BREED_BT))
         {
            this.m_breedBtn = new FarmAnimatedCashButton(this.m_mainMc[this.BREED_BT],"Breed","0",this.onBreedClickHandler,false,false,true,"",1);
         }
         if(this.m_mainMc.hasOwnProperty(this.PARENT_MALE_ICON))
         {
            this.m_parentMaleIcon = addWidget(new ResourcePreviewFrame(this.m_mainMc[this.PARENT_MALE_ICON])) as ResourcePreviewFrame;
            if(DragonBreedingManager.getInstance(this.m_featureName).selectedMaleDragonId != "")
            {
               maleItem = Global.farmGameSettingsManager.getFarmItemByCode(DragonBreedingManager.getInstance(this.m_featureName).selectedMaleDragonId);
               if(maleItem)
               {
                  exportedMaleName = maleItem.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
                  this.m_parentMaleIcon.load(maleItem.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportedMaleName);
                  this.m_parentMaleIcon.visible = true;
                  if(this.m_mainMc.hasOwnProperty(this.MALE_ITEM_NAME_TF))
                  {
                     addWidget(new ZwTextField(this.m_mainMc[this.MALE_ITEM_NAME_TF],ZLocUtils.tk_pk_asTitle(maleItem.friendlyName)),true);
                  }
               }
            }
         }
         if(this.m_mainMc.hasOwnProperty(this.PARENT_FEMALE_ICON))
         {
            this.m_parentFemaleIcon = addWidget(new ResourcePreviewFrame(this.m_mainMc[this.PARENT_FEMALE_ICON])) as ResourcePreviewFrame;
            if(DragonBreedingManager.getInstance(this.m_featureName).selectedFemaleDragonId != "")
            {
               femaleItem = Global.farmGameSettingsManager.getFarmItemByCode(DragonBreedingManager.getInstance(this.m_featureName).selectedFemaleDragonId);
               if(femaleItem)
               {
                  exportedFemaleName = femaleItem.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
                  this.m_parentFemaleIcon.load(femaleItem.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportedFemaleName);
                  this.m_parentFemaleIcon.visible = true;
                  if(this.m_mainMc.hasOwnProperty(this.FEMALE_ITEM_NAME_TF))
                  {
                     addWidget(new ZwTextField(this.m_mainMc[this.FEMALE_ITEM_NAME_TF],ZLocUtils.tk_pk_asTitle(femaleItem.friendlyName)),true);
                  }
               }
            }
         }
         if(this.m_mainMc.hasOwnProperty(this.RANDOM_BABY_DRAGON_ICON))
         {
            this.m_randomDragonMc = this.m_mainMc[this.RANDOM_BABY_DRAGON_ICON] as MovieClip;
            this.m_randomDragonMc.visible = true;
         }
         if(this.m_mainMc.hasOwnProperty(this.BABY_DRAGON_ICON))
         {
            this.m_babyDragonIcon = new FarmIcon(this.m_mainMc[this.BABY_DRAGON_ICON]);
            if(Boolean(this.m_selectedBabyDragon) && Boolean(this.m_selectedBabyDragon.male) && Boolean(this.m_selectedBabyDragon.female) && Boolean(this.m_selectedBabyDragon.index))
            {
               this.m_babyDragonIcon.loadIcon(DragonBreedingManager.getInstance(this.m_featureName).getImageForOffspring(this.m_selectedBabyDragon.male,this.m_selectedBabyDragon.female,this.m_selectedBabyDragon.index));
               this.m_babyDragonIcon.visible = true;
               if(this.m_randomDragonMc)
               {
                  this.m_randomDragonMc.visible = false;
               }
            }
            addWidget(this.m_babyDragonIcon,true);
         }
         if(this.m_mainMc.hasOwnProperty(this.BREEDING_TIME_TF))
         {
            this.m_breedingTimeTxt = addWidget(new ZwTextField(this.m_mainMc[this.BREEDING_TIME_TF]),true) as ZwTextField;
         }
         if(this.m_mainMc.hasOwnProperty(this.BREEDING_DESCRP_TF))
         {
            addWidget(new ZwTextField(this.m_mainMc[this.BREEDING_DESCRP_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_description")),true);
         }
         if(this.m_mainMc.hasOwnProperty(this.OFFSPRINGOUTCOME_DESC_TF))
         {
            addWidget(new ZwTextField(this.m_mainMc[this.OFFSPRINGOUTCOME_DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_offspring_description")),true);
         }
         if(this.m_mainMc.hasOwnProperty(this.CHANGE_OFFSPRING_BTN))
         {
            this.m_changeBabyDragonBtn = addWidget(new FarmAnimatedButton(this.m_mainMc[this.CHANGE_OFFSPRING_BTN],this.onChangeBabyClickHandler),true) as FarmAnimatedButton;
         }
         if(this.m_mainMc.hasOwnProperty(this.COUNTER_MC))
         {
            counterMc = this.m_mainMc[this.COUNTER_MC];
            if(counterMc.hasOwnProperty(this.POTION_COUNT_TF))
            {
               this.m_lovePotionCountTxt = addWidget(new ZwTextField(counterMc[this.POTION_COUNT_TF],String(this.m_numBreedPotions)),true) as ZwTextField;
            }
            if(counterMc.hasOwnProperty(this.LP_UP_BTN))
            {
               addWidget(this.m_lovePotionAddBtn = new FarmButton(counterMc[this.LP_UP_BTN],this.onPotionUpArrowPress),true);
            }
            if(counterMc.hasOwnProperty(this.LP_DOWN_BTN))
            {
               addWidget(this.m_lovePotionSubBtn = new FarmButton(counterMc[this.LP_DOWN_BTN],this.onPotionDownArrowPress),true);
            }
         }
         if(this.m_mainMc.hasOwnProperty(this.SELECT_OUTCOME_TXT))
         {
            this.m_selectOutcomeTxt = addWidget(new ZwTextField(this.m_mainMc[this.SELECT_OUTCOME_TXT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_selected_outcome")),true) as ZwTextField;
         }
         if(this.m_mainMc.hasOwnProperty(this.RANDOM_OUTCOME_RADIO_BTN))
         {
            this.m_randomOutcomeRelease = addWidget(new FarmButton(this.m_mainMc[this.RANDOM_OUTCOME_RADIO_BTN],this.toggleButtonsAndSetOffSpring),true);
            if(this.m_randomOutcomeRelease != null && Boolean(this.m_mainMc[this.RANDOM_OUTCOME_RADIO_BTN].hasOwnProperty("check1_mc")))
            {
               this.m_randomOutcomeRadioMc = addWidget(new ZwBaseWidget(this.m_mainMc[this.RANDOM_OUTCOME_RADIO_BTN].check1_mc),!this.m_isPreselectedOffspring);
            }
            if(this.m_randomOutcomeRelease != null && Boolean(this.m_mainMc[this.RANDOM_OUTCOME_RADIO_BTN].hasOwnProperty("generic1_tf")))
            {
               randomOutcomeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_random_outcome");
               addWidget(new FarmTextField(this.m_mainMc[this.RANDOM_OUTCOME_RADIO_BTN].generic1_tf,randomOutcomeText),true);
            }
         }
         if(this.m_mainMc.hasOwnProperty(this.PAID_OUTCOME_RADIO_BTN))
         {
            this.m_paidOutcomeRelease = addWidget(new FarmButton(this.m_mainMc[this.PAID_OUTCOME_RADIO_BTN],this.toggleButtonsAndSetOffSpring),true);
            if(Boolean(this.m_paidOutcomeRelease) && Boolean(this.m_mainMc[this.PAID_OUTCOME_RADIO_BTN].hasOwnProperty("check2_mc")))
            {
               this.m_paidOutcomeRadioMc = addWidget(new ZwBaseWidget(this.m_mainMc[this.PAID_OUTCOME_RADIO_BTN].check2_mc),this.m_isPreselectedOffspring);
            }
            if(Boolean(this.m_paidOutcomeRelease) && Boolean(this.m_mainMc[this.PAID_OUTCOME_RADIO_BTN].hasOwnProperty("generic2_tf")))
            {
               paidOutcomeText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"selection_" + this.m_featureName + "_selected_outcome");
               addWidget(new FarmTextField(this.m_mainMc[this.PAID_OUTCOME_RADIO_BTN].generic2_tf,paidOutcomeText),true);
            }
         }
         this.m_changeBabyDragonBtn.visible = this.m_isPreselectedOffspring;
         this.m_babyDragonIcon.visible = this.m_isPreselectedOffspring;
         this.m_randomDragonMc.visible = !this.m_isPreselectedOffspring;
         this.updateBreedRate();
         this.updateCashBtnText();
         if(Boolean(this.m_parentWindow) && this.m_parentWindow.isInTutorial())
         {
            TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x + 120,m_window.y + 250));
            this.m_numBreedPotions = 4;
            this.enableWindow(false,this.m_lovePotionAddBtn);
            this.m_lovePotionSubBtn.applyGrayOut = true;
            if(this.m_lovePotionCountTxt)
            {
               this.m_lovePotionCountTxt.text = String(this.m_numBreedPotions);
               timeNeeded = Number(DragonBreedingManager.getDefaultBreedTimes(this.m_featureName)[this.m_numBreedPotions]);
               this.m_breedingTimeTxt.text = ZLocUtils.t("Dialogs","selection_" + this.m_featureName + "_breed_Mating_breed_time",{
                  "quantity":timeNeeded,
                  "Hour_word":ZLocUtils.tk("Dialogs","Hour_word","",timeNeeded)
               });
            }
            setCloseButtonVisible(false);
         }
         else
         {
            setCloseButtonVisible(true);
         }
      }
      
      override protected function afterLoad() : void
      {
         if(Boolean(this.m_parentWindow) && this.m_parentWindow.isInTutorial())
         {
            setCloseButtonVisible(false);
         }
         else
         {
            setCloseButtonVisible(true);
         }
      }
      
      private function calculateBreedCost() : Number
      {
         var result:Number = 0;
         if(this.m_isPreselectedOffspring)
         {
            result += DragonBreedingManager.PATTERN_GUARANTEE_COST;
         }
         if(this.numPotionsToBuy > 0)
         {
            result += this.getCashForCraftItem();
         }
         return result;
      }
      
      private function enableWindow(enable:Boolean, displayObj:ZwBaseWidget = null) : void
      {
         this.m_breedBtn.enabled = enable;
         this.m_changeBabyDragonBtn.enabled = enable;
         this.m_lovePotionAddBtn.enabled = enable;
         this.m_lovePotionSubBtn.enabled = enable;
         this.m_paidOutcomeRadioMc.enabled = enable;
         this.m_randomOutcomeRadioMc.enabled = enable;
         this.m_paidOutcomeRelease.enabled = enable;
         this.m_randomOutcomeRelease.enabled = enable;
         if(displayObj)
         {
            displayObj.enabled = !enable;
         }
      }
      
      private function toggleButtonsAndSetOffSpring(e:Event) : void
      {
         if(this.m_randomOutcomeRadioMc != null && this.m_paidOutcomeRadioMc != null)
         {
            if(this.m_isPreselectedOffspring || e.currentTarget.name == this.RANDOM_OUTCOME_RADIO_BTN)
            {
               this.m_isPreselectedOffspring = false;
               this.m_paidOutcomeRadioMc.visible = false;
               this.m_changeBabyDragonBtn.visible = false;
               this.m_randomOutcomeRadioMc.visible = true;
               this.m_isChangeBabyBtnClicked = false;
               this.m_babyDragonIcon.visible = false;
               this.m_randomDragonMc.visible = true;
            }
            else
            {
               this.m_isPreselectedOffspring = true;
               this.m_paidOutcomeRadioMc.visible = true;
               this.m_randomOutcomeRadioMc.visible = false;
               this.m_changeBabyDragonBtn.visible = true;
               this.m_isChangeBabyBtnClicked = true;
               this.m_babyDragonIcon.visible = true;
               this.m_randomDragonMc.visible = false;
               this.openDragonFamilyTree();
            }
         }
         this.updateCashBtnText();
      }
      
      private function onPotionUpArrowPress(e:MouseEvent) : void
      {
         if(this.m_numBreedPotions < DragonBreedingManager.MAX_NUM_POTIONS)
         {
            ++this.m_numBreedPotions;
            this.updateBreedRate();
            this.updateCashBtnText();
            if(this.m_parentWindow.isInTutorial())
            {
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               if(this.m_parentWindow.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_4))
               {
                  this.m_parentWindow.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_5);
               }
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x + 140,m_window.y + 490));
               this.enableWindow(false,this.m_breedBtn);
            }
         }
      }
      
      private function onPotionDownArrowPress(e:MouseEvent) : void
      {
         if(this.m_numBreedPotions > 0)
         {
            --this.m_numBreedPotions;
            this.updateBreedRate();
            this.updateCashBtnText();
         }
      }
      
      private function updateBreedRate() : void
      {
         var timeNeeded:Number = Number(DragonBreedingManager.getDefaultBreedTimes(this.m_featureName)[this.m_numBreedPotions]);
         this.m_lovePotionAddBtn.enabled = true;
         this.m_lovePotionSubBtn.enabled = true;
         this.m_lovePotionAddBtn.applyGrayOut = false;
         this.m_lovePotionSubBtn.applyGrayOut = false;
         if(this.m_lovePotionCountTxt)
         {
            this.m_lovePotionCountTxt.text = String(this.m_numBreedPotions);
         }
         if(this.m_numBreedPotions == 0)
         {
            this.m_lovePotionSubBtn.enabled = false;
            this.m_lovePotionSubBtn.applyGrayOut = true;
         }
         if(timeNeeded >= 1)
         {
            this.m_breedingTimeTxt.text = ZLocUtils.t("Dialogs","selection_" + this.m_featureName + "_breed_Mating_breed_time",{
               "quantity":timeNeeded,
               "Hour_word":ZLocUtils.tk("Dialogs","Hour_word","",timeNeeded)
            });
         }
         else
         {
            this.m_lovePotionAddBtn.enabled = false;
            this.m_lovePotionAddBtn.applyGrayOut = true;
            this.m_breedingTimeTxt.text = ZLocUtils.t("Dialogs","selection_" + this.m_featureName + "_Mating_breed_time_instant");
         }
      }
      
      private function updateCashBtnText() : void
      {
         var m_breedingAmountTxt:TextField = null;
         var guaranteedOffSpring:Boolean = false;
         var extraLovePotions:Boolean = false;
         var breedCost:Number = NaN;
         var buyConfirmMsg:String = null;
         if(this.m_breedBtn.element.hasOwnProperty("amount_tf"))
         {
            m_breedingAmountTxt = this.m_breedBtn.element["amount_tf"];
            m_breedingAmountTxt.text = this.calculateBreedCost().toString();
            guaranteedOffSpring = this.m_isPreselectedOffspring;
            extraLovePotions = false;
            if(this.getCashForCraftItem() > 0)
            {
               extraLovePotions = true;
            }
            breedCost = this.calculateBreedCost();
            if(breedCost > 0)
            {
               buyConfirmMsg = "";
               if(guaranteedOffSpring && extraLovePotions)
               {
                  buyConfirmMsg = "";
               }
               else if(guaranteedOffSpring)
               {
                  buyConfirmMsg = "";
               }
               else if(extraLovePotions)
               {
                  buyConfirmMsg = ZLocUtils.t("Dialogs","sheep_pen_LovePotion_Need_More_Smart",{
                     "quantity":this.numPotionsInInventory,
                     "remainingNum":this.numPotionsToBuy,
                     "cashQuantity":this.getCashForCraftItem()
                  });
               }
               this.m_breedBtn.buyConfirmationText = buyConfirmMsg;
            }
         }
      }
      
      private function onBreedClickHandler(e:Event) : void
      {
         if(Global.player.canBuyCash(this.calculateBreedCost()))
         {
            this.beginBreed();
         }
      }
      
      private function getCashForCraftItem() : int
      {
         return int(this.numPotionsToBuy * this.getCraftItem(DragonBreedingManager.LOVE_POTION_ITEM_CODE).cash);
      }
      
      private function getCraftItem(itemCode:String) : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
      }
      
      private function get numPotionsInInventory() : Number
      {
         return DragonBreedingManager.getInstance(this.m_featureName).getCraftItemCount();
      }
      
      private function get numPotionsToBuy() : Number
      {
         return Math.max(this.m_numBreedPotions - this.numPotionsInInventory,0);
      }
      
      private function beginBreed() : void
      {
         var freeSlot:int = DragonBreedingManager.getInstance(this.m_featureName).findFreeSlot();
         if(freeSlot > -1 && DragonBreedingManager.getInstance(this.m_featureName).canBreed())
         {
            DragonBreedingManager.getInstance(this.m_featureName).beginBreed(freeSlot,this.m_isPreselectedOffspring,this.m_numBreedPotions);
            Global.player.cash -= this.calculateBreedCost();
         }
         this.m_isBreedBtnClicked = true;
         this.m_isChangeBabyBtnClicked = false;
         this.cancelBreedFlow();
      }
      
      private function cancelBreedFlow() : void
      {
         this.m_numBreedPotions = 0;
         this.updateBreedRate();
         if(this.m_parentWindow)
         {
            this.m_parentWindow.selectedFemaleDragonId = "";
            this.m_parentWindow.selectedMaleDragonId = "";
            this.m_parentWindow.switchToTab(null,DragonBreedingWindow.TAB_HATCHERY);
            this.m_parentWindow.untintWindow();
            this.m_parentWindow.enableInput = true;
            if(this.m_parentWindow.isInTutorial())
            {
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               if(this.m_parentWindow.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_5))
               {
                  this.m_parentWindow.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_6);
               }
            }
         }
         DragonBreedingManager.getInstance(this.m_featureName).resetPotionsForSelectionPopup();
         super.close();
      }
      
      private function openDragonFamilyTree() : void
      {
         if(this.m_parentWindow)
         {
            DragonBreedingManager.getInstance(this.m_featureName).savePotionsForSelectionPopup(this.m_numBreedPotions);
            UI.displayPopup(new DragonBreedingFamilyWindow(this.m_featureName,DragonBreedingManager.SELECTION_WINDOW,this,this.m_parentWindow),false);
            UI.stopPopups(false);
            this.m_parentWindow.tintWindow();
            this.m_parentWindow.enableInput = false;
         }
         super.close();
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function close() : void
      {
         if(this.m_parentWindow)
         {
            DragonBreedingManager.getInstance(this.m_featureName).resetPotionsForSelectionPopup();
            this.m_parentWindow.untintWindow();
            this.m_parentWindow.enableInput = true;
         }
         super.close();
      }
      
      private function onChangeBabyClickHandler(e:Event) : void
      {
         this.m_isChangeBabyBtnClicked = true;
         this.openDragonFamilyTree();
      }
   }
}

