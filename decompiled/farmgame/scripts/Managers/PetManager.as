package Managers
{
   import Classes.Pet;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.CustomizePets;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericPopupTitleBig;
   import Display.PetsRanAwayDialog;
   import Display.UI;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Events.GenericPopupTitleBigEvent;
   import Widgets.Windows.GenericCustomAdToaster;
   import Widgets.Windows.Market.MarketWindow;
   
   public class PetManager
   {
      
      private static var m_instance:PetManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      public const HUD_ICON_RUNAWAY_PET:String = "PoundPuppy";
      
      public const HUD_ICON_RESET_LEVEL:String = "PetResetLevel";
      
      public const FORGOT_TRICK_POPUP_FEATURE_KEY:String = "PetForgotTrick";
      
      private var m_runawayPets:Array = new Array();
      
      private var m_petRescueReminderShown:Boolean = false;
      
      private var m_petRescueReminderClicked:Boolean = false;
      
      private var m_levelResetPets:Array = new Array();
      
      public function PetManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call PetManager constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : PetManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new PetManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function addRunawayPet(pet:Pet) : void
      {
         this.m_runawayPets.push(pet);
      }
      
      public function hasRunawayPet() : Boolean
      {
         return this.m_runawayPets.length > 0;
      }
      
      public function getRunawayPet() : Pet
      {
         var pet:Pet = null;
         if(this.m_runawayPets.length > 0)
         {
            this.m_runawayPets.sort(this.sortByKibbleFedCount);
            pet = this.m_runawayPets[0];
         }
         return pet;
      }
      
      public function removeRunawayPet() : void
      {
         var pet:Pet = this.m_runawayPets[0];
         if(this.m_runawayPets.length > 0)
         {
            this.m_runawayPets.splice(0,1);
         }
      }
      
      public function set petRescueReminderShown(value:Boolean) : void
      {
         this.m_petRescueReminderShown = value;
      }
      
      public function get petRescueReminderShown() : Boolean
      {
         return this.m_petRescueReminderShown;
      }
      
      public function set petRescueReminderClicked(value:Boolean) : void
      {
         this.m_petRescueReminderClicked = value;
      }
      
      public function get petRescueReminderClicked() : Boolean
      {
         return this.m_petRescueReminderClicked;
      }
      
      private function sortByKibbleFedCount(pet1:Pet, pet2:Pet) : Number
      {
         var kibblePet1:Number = pet1.kibbleFedCount;
         var kibblePet2:Number = pet2.kibbleFedCount;
         var result:Number = 0;
         if(kibblePet1 < kibblePet2)
         {
            result = 1;
         }
         else if(kibblePet1 > kibblePet2)
         {
            result = -1;
         }
         return result;
      }
      
      public function resetRescuePet() : void
      {
         var pet:Pet = null;
         if(PetManager.getInstance().hasRunawayPet())
         {
            pet = PetManager.getInstance().getRunawayPet();
            pet.isRescue = false;
            pet.postDisableMove();
         }
      }
      
      public function showRescuePopup() : void
      {
         var pet:Pet = null;
         if(PetManager.getInstance().hasRunawayPet())
         {
            pet = PetManager.getInstance().getRunawayPet();
            UI.displayPopup(new PetsRanAwayDialog(pet.getItem().code,pet.petName,true),true,"petsRanAwayDialog",true);
         }
      }
      
      public function onRescuePet() : void
      {
         var pet:Pet = null;
         if(PetManager.getInstance().hasRunawayPet())
         {
            pet = PetManager.getInstance().getRunawayPet();
            pet.isRescue = true;
            pet.animalState = Pet.STATE_RUNAWAY;
            pet.setVisible(true);
            pet.move();
         }
      }
      
      public function showPetRescueReminder() : void
      {
         var pet:Pet = null;
         var gender:String = null;
         var title:String = null;
         var message:String = null;
         if(!Global.worldManager.isVisiting())
         {
            if(PetManager.getInstance().hasRunawayPet())
            {
               pet = PetManager.getInstance().getRunawayPet();
               gender = pet.petGender == Pet.GENDER_MALE ? ZLocUtils.MASC : ZLocUtils.FEM;
               title = ZLocUtils.t("Dialogs","PetRescueReminderTitle",{"pet":ZLocUtils.tn(pet.petName,gender)});
               message = "";
               if(pet.isMale())
               {
                  message = ZLocUtils.t("Dialogs","PetRescueReminderMessageMale");
               }
               else
               {
                  message = ZLocUtils.t("Dialogs","PetRescueReminderMessageFemale");
               }
               ToasterManager.getInstance().add(new GenericCustomAdToaster(title,message,Pet.REMINDER_POPUP_DURATION,this.onRescueReminderClick,this.onRescueReminderClose));
            }
         }
      }
      
      public function onRescueReminderClick() : void
      {
         PetManager.getInstance().petRescueReminderClicked = true;
         this.showRescuePopup();
      }
      
      public function onRescueReminderClose() : void
      {
         if(!PetManager.getInstance().petRescueReminderClicked)
         {
            Global.hud.iconQueue.addIcon(PetManager.getInstance().HUD_ICON_RUNAWAY_PET);
         }
      }
      
      public function onBuyPetConsumableWithoutPet() : void
      {
         var popupMessage:String = ZLocUtils.t("Dialogs","PetConsumablePurchaseWithoutPet");
         UI.displayPopup(new GenericPopup(popupMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.buyPetConsumableWithoutPetCallback));
      }
      
      public function buyPetConsumableWithoutPetCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMarketDialog("unknown","animal",null,"pets");
         }
      }
      
      public function showPetCoinsReminder(itemName:String) : void
      {
         var message:String = ZLocUtils.t("Dialogs","PetCoinReminderMessage");
         var dialog:GenericPopupTitleBig = new GenericPopupTitleBig("PetCoinReminderTitle",message,GenericPopup.TYPE_ACCEPTCANCEL,this.onPetCoinsPurchaseReminder,"assets/dialogs/FV_Pets_PopUp_Feed_WideBt.swf",itemName);
         dialog.setAcceptTextName("SeeThisPuppy");
         dialog.setCancelTextName("SeeOtherPuppies");
         UI.displayPopup(dialog,true,"petCoinFeedReminder",true);
      }
      
      public function showCustomizePetPopup(itemName:String, isCash:Boolean) : void
      {
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
         var customize:CustomizePets = new CustomizePets(itemName,isCash);
         UI.displayPopup(customize);
      }
      
      public function onPetCoinsPurchaseReminder(event:GenericPopupTitleBigEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.showCustomizePetPopup(event.itemName,false);
         }
         else
         {
            MarketWindow.previousPage = 0;
            UI.displayMarketDialog("cancelCoinPurchase","animal",null,"pets");
         }
      }
      
      public function addLevelResetPet(pet:Pet) : void
      {
         if(this.m_levelResetPets.length == 0)
         {
            Global.hud.iconQueue.addIcon(this.HUD_ICON_RESET_LEVEL);
         }
         this.m_levelResetPets.push(pet);
      }
      
      public function showResetLevelMessages() : void
      {
         var pet:Pet = null;
         var dialogLastShownMS:Number = NaN;
         for each(pet in this.m_levelResetPets)
         {
            dialogLastShownMS = Global.player.getFeatureLastShown(this.FORGOT_TRICK_POPUP_FEATURE_KEY) * 1000;
            if(GlobalEngine.serverTime > dialogLastShownMS + Global.farmGameSettingsManager.getNumber("inGameDaySeconds",82800) * 1000 / 2)
            {
               pet.displayLevelProgressReset();
               Global.player.setFeatureLastShown(this.FORGOT_TRICK_POPUP_FEATURE_KEY,GlobalEngine.serverTime,true);
            }
         }
         this.m_levelResetPets = [];
      }
      
      public function onPetTrickHarvestAnimalTooSoon(pet:Pet) : void
      {
         var gender:String = pet.petGender == Pet.GENDER_MALE ? ZLocUtils.MASC : ZLocUtils.FEM;
         var failedMessage:String = ZLocUtils.t("Dialogs","PetTrick_harvest_animal_too_soon",{"pet":ZLocUtils.tn(pet.petName,gender)});
         UI.displayMessage(failedMessage,0,null,"",true);
      }
      
      public function onPetTrickFetchComplete(fetchStatus:Boolean, itemName:String, pet:Pet) : void
      {
         var item:FarmItem = null;
         var iconURL:String = null;
         var successMessage:String = null;
         var dialog:GenericIconPopup = null;
         var failedMessage:String = null;
         var gender:String = pet.petGender == Pet.GENDER_MALE ? ZLocUtils.MASC : ZLocUtils.FEM;
         if(fetchStatus)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            iconURL = item.getImageByName("icon");
            successMessage = ZLocUtils.t("Dialogs","PetTrick_fetch_success",{
               "pet":ZLocUtils.tn(pet.petName,gender),
               "item":ZLocUtils.tk_pk(item.friendlyName)
            });
            dialog = new GenericIconPopup(successMessage,GenericPopup.TYPE_OK,this.onOpenGiftBox,iconURL);
            dialog.setAcceptTextName("Okay");
            UI.displayPopup(dialog,true,"petTrickFetchPopup",true);
         }
         else
         {
            failedMessage = ZLocUtils.t("Dialogs","PetTrick_fetch_failed",{"pet":ZLocUtils.tn(pet.petName,gender)});
            UI.displayMessage(failedMessage,0,null,"",true);
         }
      }
      
      public function onOpenGiftBox(event:GenericPopupEvent) : void
      {
         UI.displayGiftBoxWindow();
      }
   }
}

