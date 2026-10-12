package Display
{
   import Classes.ItemImage;
   import Classes.Pet;
   import Classes.PetConfig;
   import Classes.ZItem.PetFarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class PetsLearnTricksPopup extends Dialog
   {
      
      private static const MAX_TREAT_IMAGES:int = 20;
      
      private static const DEFAULT_IMAGE:String = "frt_sit_adult";
      
      private static const NUM_LEVEL_ARROWS:int = 4;
      
      private static const NUM_LEVEL_BOXES:int = 4;
      
      private static const BUTTON_HOW_DOES_THIS_WORK:String = "howdoesthiswork";
      
      private static const BUTTON_CLOSE:String = "close";
      
      private static const BUTTON_GET_TREATS:String = "gettreats";
      
      private static const BUTTON_CANCEL:String = "cancel";
      
      private static const TREAT_FRAME_ON:int = 1;
      
      private static const TREAT_FRAME_OFF:int = 2;
      
      private static const PET_IMAGE_SCALE:Number = 0.3;
      
      private var m_buttons:Object = new Object();
      
      private var m_pet:Pet;
      
      public function PetsLearnTricksPopup(pet:Pet)
      {
         m_dialogAsset = "assets/dialogs/FV_LearnTricks.swf";
         super();
         this.m_pet = pet;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.setupDialogText();
         this.setupDialogButtons();
         this.setupTreatsFed();
         this.setupLevelBoxes();
         this.setPetImage(DEFAULT_IMAGE);
      }
      
      private function setupDialogText() : void
      {
         var trick:String = null;
         var gender:String = this.m_pet.petGender == Pet.GENDER_MALE ? "Male" : "Female";
         var nextLevel:int = this.m_pet.getNextLevel();
         var totalTreats:int = PetConfig.getTotalTreatsToLevel(nextLevel);
         var treatsRemaining:int = totalTreats - this.m_pet.kibbleFedCount;
         var trickName:String = "";
         var petItem:PetFarmItem = PetConfig.getPetItem(this.m_pet.getItem().name);
         if(petItem)
         {
            trick = petItem.getLevelTrick(nextLevel);
            trickName = PetConfig.getTrickFriendlyName(trick);
         }
         m_window.title_tf.text = ZLocUtils.t("Dialogs","PetLevelTitle");
         m_window.trickName_tf.text = ZLocUtils.t("Dialogs","PetLevelNextTrickTitle",{"trick":trickName});
         m_window.generic_tf.text = ZLocUtils.t("Dialogs","PetLevelNextTrickDesc" + gender,{
            (gender.toLowerCase() + "_name"):this.m_pet.petName,
            "quantity":totalTreats
         });
         m_window.warning_tf.text = ZLocUtils.t("Dialogs","PetLevelWarning" + gender,{"pet":ZLocUtils.tn(this.m_pet.petName,ZLocUtils.tg(gender))});
         m_window.hungry_mc.text = this.m_pet.petName;
         m_window.comingSoonWarning_mc.comingSoonWarning_tf.text = ZLocUtils.t("Dialogs","PetLevelWarningComingSoon");
         m_window.comingSoonWarning_mc.visible = false;
         if(treatsRemaining == totalTreats)
         {
            m_window.daysRemaining_tf.text = ZLocUtils.t("Dialogs","PetLevelStartTraining");
         }
         else
         {
            m_window.daysRemaining_tf.text = ZLocUtils.t("Dialogs","PetLevelDaysRemaining",{"quantity":treatsRemaining});
         }
      }
      
      private function setupDialogButtons() : void
      {
         var howDoesThisWorkButton:GenericButton = new GenericButton(m_window.whatisthis_mc,this.onHowDoesThisWorkClick);
         howDoesThisWorkButton.text = ZLocUtils.t("Dialogs","HowDoesThisWork");
         this.m_buttons[BUTTON_HOW_DOES_THIS_WORK] = howDoesThisWorkButton;
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         var treatsButton:GenericButton = new GenericButton(m_window.buy_bt,this.onGetTreats);
         treatsButton.text = ZLocUtils.t("Dialogs","PetLevelGetTreats");
         this.m_buttons[BUTTON_GET_TREATS] = treatsButton;
         var cancelButton:GenericButton = new GenericButton(m_window.cancel_bt,this.onClose);
         cancelButton.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      private function setupTreatsFed() : void
      {
         var treatClip:MovieClip = null;
         var numTreatsToNextLevel:int = PetConfig.getTotalTreatsToLevel(this.m_pet.getNextLevel());
         for(var treatIdx:int = 0; treatIdx < MAX_TREAT_IMAGES; treatIdx++)
         {
            treatClip = m_window.getChildByName("treatOn" + treatIdx + "_mc") as MovieClip;
            if(treatClip)
            {
               if(treatIdx < this.m_pet.kibbleFedCount)
               {
                  treatClip.gotoAndStop(TREAT_FRAME_ON);
               }
               else if(treatIdx < numTreatsToNextLevel)
               {
                  treatClip.gotoAndStop(TREAT_FRAME_OFF);
               }
               else
               {
                  treatClip.visible = false;
               }
            }
         }
      }
      
      private function setActiveLevelPointer(nextLevel:int) : void
      {
         var arrow:MovieClip = null;
         var index:int = nextLevel - Pet.ADULT_START_UNLOCK_LEVEL;
         for(var arrowIdx:int = 0; arrowIdx < NUM_LEVEL_ARROWS; arrowIdx++)
         {
            arrow = m_window.getChildByName("pointer" + arrowIdx + "_mc") as MovieClip;
            if(arrow)
            {
               arrow.visible = index == arrowIdx;
            }
         }
      }
      
      private function setupLevelBoxes() : void
      {
         var boxLevel:int = 0;
         var trickName:String = null;
         var trickFriendlyName:String = null;
         var activeBox:MovieClip = null;
         var learnedBox:MovieClip = null;
         var lockedBox:MovieClip = null;
         var comingSoonBox:MovieClip = null;
         var nextLevel:int = this.m_pet.getNextLevel();
         var petItem:PetFarmItem = PetConfig.getPetItem(this.m_pet.getItem().name);
         for(var boxIdx:int = 0; boxIdx < NUM_LEVEL_BOXES; boxIdx++)
         {
            boxLevel = boxIdx + Pet.ADULT_START_UNLOCK_LEVEL;
            trickName = petItem.getLevelTrick(boxLevel);
            trickFriendlyName = ZLocUtils.t("Dialogs","PetTrick_" + trickName);
            activeBox = m_window.getChildByName("activeSlot" + boxIdx + "_mc") as MovieClip;
            if(nextLevel == boxLevel)
            {
               activeBox.trickNumber_tf.text = boxLevel.toString();
               activeBox.trickName_tf.text = trickFriendlyName;
               activeBox.trickStatus_tf.text = ZLocUtils.t("Dialogs","PetLevelInProgress");
            }
            else
            {
               activeBox.visible = false;
            }
            learnedBox = m_window.getChildByName("learnedSlot" + boxIdx + "_mc") as MovieClip;
            if(nextLevel > boxLevel)
            {
               learnedBox.trickNumber_tf.text = boxLevel.toString();
               learnedBox.trickName_tf.text = trickFriendlyName;
               learnedBox.trickStatus_tf.text = ZLocUtils.t("Dialogs","PetLevelLearned");
            }
            else
            {
               learnedBox.visible = false;
            }
            lockedBox = m_window.getChildByName("lockedSlot" + boxIdx + "_mc") as MovieClip;
            if(nextLevel < boxLevel)
            {
               lockedBox.trickNumber_tf.text = boxLevel.toString();
               lockedBox.trickName_tf.text = ZLocUtils.t("Dialogs","PetLevelLocked");
            }
            else
            {
               lockedBox.visible = false;
            }
            comingSoonBox = m_window.getChildByName("comingSoonSlot" + boxIdx + "_mc") as MovieClip;
            comingSoonBox.visible = false;
         }
         this.setActiveLevelPointer(nextLevel);
      }
      
      private function setPetImage(imageName:String) : void
      {
         var dispObj:DisplayObject = null;
         var imageClass:ItemImage = this.m_pet.getItem().getCachedImage(imageName);
         if(Boolean(imageClass) && imageClass.image is MovieClip)
         {
            dispObj = imageClass.image as DisplayObject;
            dispObj.y = -10;
            dispObj.scaleX = PET_IMAGE_SCALE;
            dispObj.scaleY = PET_IMAGE_SCALE;
            m_window.userDog_mc.addChildAt(imageClass.image,0);
         }
      }
      
      private function onHowDoesThisWorkClick(event:MouseEvent) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","PetLevelHowDoesThisWork");
         var dialog:GenericPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,null,GenericPopup.GENERIC_ASSET_LRG);
         dialog.setAcceptTextName("Okay");
         UI.displayPopup(dialog,false);
      }
      
      private function onGetTreats(event:MouseEvent) : void
      {
         this.onClose(event);
         FarmStatsManager.count("fv_pets","learn_tricks_dlg_get_treats");
         UI.displayMarketDialog("PetsLearnTricksGetTreats","animal",null,"pets");
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         close();
         for(var index:uint = 0; index < this.m_buttons.length; index++)
         {
            if(this.m_buttons[index])
            {
               this.m_buttons[index].turnOff();
            }
         }
         this.removeEventListeners();
      }
      
      private function removeEventListeners() : void
      {
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
      }
   }
}

