package Display
{
   import Classes.Pet;
   import Classes.PetConfig;
   import Classes.ZItem.PetFarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import GameMode.GMPetsPlace;
   import com.adobe.utils.StringUtil;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextFieldType;
   
   public class CustomizePets extends Dialog
   {
      
      protected const MESSAGE_BOX_CHAR_LIMIT:int = 16;
      
      protected const FRAME_NORMAL:int = 1;
      
      protected const FRAME_MOUSE_OVER:int = 2;
      
      protected const FRAME_SELECTED:int = 3;
      
      protected const TOTAL_COLORS:int = 3;
      
      protected const COLOR_SWATCH_LEFT:int = 0;
      
      protected const COLOR_SWATCH_CENTER:int = 1;
      
      protected const COLOR_SWATCH_RIGHT:int = 2;
      
      protected const TF_RESTRICT:String = "A-Z a-z.\\-";
      
      protected var m_gender:Number = 0;
      
      protected var m_color:int = 0;
      
      protected var m_colorIndex:int = 0;
      
      protected var m_pets:Array = [];
      
      protected var m_itemName:String = "";
      
      protected var m_isCash:Boolean;
      
      protected var m_customItemData:Object = null;
      
      public function CustomizePets(itemName:String, isCash:Boolean)
      {
         m_dialogAsset = "assets/dialogs/FV_pets_customize.swf";
         this.m_itemName = itemName;
         this.m_isCash = isCash;
         super();
         this.loadPets(itemName);
      }
      
      public function getCustomPetData() : Object
      {
         return this.m_customItemData;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.setupDialogText();
         this.setColorSelector();
         this.setupDialogButtons();
         this.updateDisplay();
      }
      
      protected function loadPets(name:String) : void
      {
         this.m_pets = PetConfig.getPetItemsBySet(name);
      }
      
      private function setColorSelector() : void
      {
         var pet:PetFarmItem = null;
         var colorSlotKey:String = null;
         m_window.colorSelector_mc.useHandCursor = true;
         m_window.colorSelector_mc.buttonMode = true;
         for(var petIndex:int = 0; petIndex < this.m_pets.length; petIndex++)
         {
            pet = this.m_pets[petIndex] as PetFarmItem;
            colorSlotKey = "slot_" + petIndex + "_mc";
            m_window.colorSelector_mc[colorSlotKey].colorIndex = petIndex;
            m_window.colorSelector_mc[colorSlotKey].color_tf.text = ZLocUtils.t("Dialogs",pet.name + "_color");
            m_window.colorSelector_mc[colorSlotKey].comingSoon_mc.visible = false;
            m_window.colorSelector_mc[colorSlotKey].addEventListener(MouseEvent.MOUSE_OVER,this.onColorMouseOver);
            m_window.colorSelector_mc[colorSlotKey].addEventListener(MouseEvent.MOUSE_OUT,this.onColorMouseOut);
            m_window.colorSelector_mc[colorSlotKey].addEventListener(MouseEvent.CLICK,this.onColorMouseClick);
            this.renderBoxColor(m_window.colorSelector_mc[colorSlotKey].color_mc,pet.itemColor);
         }
      }
      
      protected function setupDialogText() : void
      {
         ZLocUtils.setText(m_window,"title_tf","Dialogs","PetTitle");
         ZLocUtils.setText(m_window,"nameTitle_tf","Dialogs","NameYourPet");
         m_window.maleBtn_mc.male_tf.text = ZLocUtils.t("Dialogs","PetMale");
         m_window.femaleBtn_mc.female_tf.text = ZLocUtils.t("Dialogs","PetFemale");
         m_window.name_tf.type = TextFieldType.INPUT;
         m_window.name_tf.restrict = this.TF_RESTRICT;
         m_window.name_tf.maxChars = this.MESSAGE_BOX_CHAR_LIMIT;
         m_window.name_tf.text = ZLocUtils.t("Dialogs","PetDefaultName");
         m_window.name_tf.multiline = false;
         m_window.name_tf.addEventListener(MouseEvent.CLICK,this.onNameMouseClick);
         ZLocUtils.setText(m_window,"colorSelector_mc.farmCashOnly_mc.generic1_tf","Dialogs","PetThisColorIsFarmCashOnly");
         Global.stage.focus = m_window.name_tf;
      }
      
      protected function onNameMouseClick(event:MouseEvent) : void
      {
         m_window.error_mc.visible = false;
         m_window.error_mc.error_tf.text = "";
      }
      
      private function removeEventListners() : void
      {
         var pet:PetFarmItem = null;
         var colorSlotKey:String = null;
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         m_window.maleBtn_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
         m_window.maleBtn_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
         m_window.maleBtn_mc.removeEventListener(MouseEvent.CLICK,this.onTileMouseClick);
         m_window.femaleBtn_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
         m_window.femaleBtn_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
         m_window.femaleBtn_mc.removeEventListener(MouseEvent.CLICK,this.onTileMouseClick);
         for(var petIndex:int = 0; petIndex < this.m_pets.length; petIndex++)
         {
            pet = this.m_pets[petIndex] as PetFarmItem;
            colorSlotKey = "slot_" + petIndex + "_mc";
            m_window.colorSelector_mc[colorSlotKey].removeEventListener(MouseEvent.MOUSE_OVER,this.onColorMouseOver);
            m_window.colorSelector_mc[colorSlotKey].removeEventListener(MouseEvent.MOUSE_OUT,this.onColorMouseOut);
            m_window.colorSelector_mc[colorSlotKey].removeEventListener(MouseEvent.CLICK,this.onColorMouseClick);
         }
         m_window.name_tf.removeEventListener(MouseEvent.CLICK,this.onNameMouseClick);
      }
      
      protected function setupDialogButtons() : void
      {
         m_window.error_mc.visible = false;
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         var genericButton:GenericButton = new GenericButton(m_window.buy_bt,this.onBuy);
         genericButton.text = ZLocUtils.t("Dialogs","Buy");
         m_window.genericButton = genericButton;
         m_window.maleBtn_mc.useHandCursor = true;
         m_window.maleBtn_mc.buttonMode = true;
         m_window.maleBtn_mc.gender = Pet.GENDER_MALE;
         m_window.maleBtn_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
         m_window.maleBtn_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
         m_window.maleBtn_mc.addEventListener(MouseEvent.CLICK,this.onTileMouseClick);
         m_window.femaleBtn_mc.useHandCursor = true;
         m_window.femaleBtn_mc.buttonMode = true;
         m_window.femaleBtn_mc.gender = Pet.GENDER_FEMALE;
         m_window.femaleBtn_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
         m_window.femaleBtn_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
         m_window.femaleBtn_mc.addEventListener(MouseEvent.CLICK,this.onTileMouseClick);
         if(this.m_gender == Pet.GENDER_MALE)
         {
            m_window.femaleBtn_mc.gotoAndStop(this.FRAME_NORMAL);
            m_window.maleBtn_mc.gotoAndStop(this.FRAME_SELECTED);
            m_window.maleBtn_mc.male_tf.text = ZLocUtils.t("Dialogs","PetMale");
         }
         else if(this.m_gender == Pet.GENDER_FEMALE)
         {
            m_window.maleBtn_mc.gotoAndStop(this.FRAME_NORMAL);
            m_window.femaleBtn_mc.gotoAndStop(this.FRAME_SELECTED);
            m_window.femaleBtn_mc.female_tf.text = ZLocUtils.t("Dialogs","PetFemale");
         }
      }
      
      protected function onTileMouseOver(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         if(tile.gender != this.m_gender)
         {
            tile.gotoAndStop(this.FRAME_MOUSE_OVER);
         }
      }
      
      protected function onTileMouseOut(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         if(tile.gender != this.m_gender)
         {
            tile.gotoAndStop(this.FRAME_NORMAL);
         }
      }
      
      protected function onTileMouseClick(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         tile.gotoAndStop(this.FRAME_SELECTED);
         this.m_gender = tile.gender;
         if(tile.gender == Pet.GENDER_MALE)
         {
            m_window.femaleBtn_mc.gotoAndStop(this.FRAME_NORMAL);
         }
         else
         {
            m_window.maleBtn_mc.gotoAndStop(this.FRAME_NORMAL);
         }
         m_window.maleBtn_mc.male_tf.text = ZLocUtils.t("Dialogs","PetMale");
         m_window.femaleBtn_mc.female_tf.text = ZLocUtils.t("Dialogs","PetFemale");
      }
      
      protected function onColorMouseOver(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         if(tile.colorIndex != this.m_colorIndex)
         {
            tile.gotoAndStop(this.FRAME_MOUSE_OVER);
         }
      }
      
      protected function onColorMouseOut(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         if(tile.colorIndex != this.m_colorIndex)
         {
            tile.gotoAndStop(this.FRAME_NORMAL);
         }
      }
      
      protected function onColorMouseClick(event:MouseEvent) : void
      {
         var tile:MovieClip = event.currentTarget as MovieClip;
         tile.gotoAndStop(this.FRAME_SELECTED);
         if(tile.colorIndex != this.m_colorIndex)
         {
            this.m_colorIndex = tile.colorIndex;
            this.updateDisplay();
         }
      }
      
      protected function onBuy(event:MouseEvent) : void
      {
         var pet:PetFarmItem = null;
         var petName:String = StringUtil.trim(m_window.name_tf.text);
         var errorText:String = null;
         if(petName.length > 0 && petName != "")
         {
            if(!FarmGameUtil.hasBadWord(petName))
            {
               pet = this.m_pets[this.m_colorIndex] as PetFarmItem;
               if(this.m_isCash || pet.showCash)
               {
                  if(Global.player.cash < pet.cash)
                  {
                     UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",pet.cash,pet.type);
                  }
                  else
                  {
                     this.purchasePet(pet.cashName,pet.cashCode,petName,true);
                  }
               }
               else if(Global.player.gold < pet.cost)
               {
                  UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyPopup",0,pet.type);
               }
               else
               {
                  this.purchasePet(pet.name,pet.code,petName,false);
               }
            }
            else
            {
               errorText = "PetValidName";
            }
         }
         else
         {
            errorText = "PetInvalidName";
         }
         if(errorText)
         {
            Global.stage.focus = m_window.name_tf;
            m_window.error_mc.visible = true;
            m_window.error_mc.error_tf.text = ZLocUtils.t("Dialogs",errorText);
         }
      }
      
      protected function purchasePet(itemName:String, petType:String, petName:String, isCash:Boolean) : void
      {
         this.m_customItemData = new Object();
         this.m_customItemData.petGender = this.m_gender;
         this.m_customItemData.petType = petType;
         this.m_customItemData.petName = petName;
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         close();
         var message:String = "";
         if(isCash)
         {
            if(this.m_gender == Pet.GENDER_MALE)
            {
               message = ZLocUtils.t("Dialogs","PetPurchaseReminderMaleCash",{"male_name":petName});
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PetPurchaseReminderFemaleCash",{"female_name":petName});
            }
         }
         else if(this.m_gender == Pet.GENDER_MALE)
         {
            message = ZLocUtils.t("Dialogs","PetPurchaseReminderMaleCoins",{
               "male_name":petName,
               "male_name_same":petName,
               "male_name_again":petName
            });
         }
         else
         {
            message = ZLocUtils.t("Dialogs","PetPurchaseReminderFemaleCoins",{
               "female_name":petName,
               "female_name_same":petName,
               "female_name_again":petName
            });
         }
         var dialog:GenericPopupTitleBig = new GenericPopupTitleBig("PetPurchaseReminderTitle",message,GenericPopup.TYPE_OK);
         UI.displayPopup(dialog,true,"petFeedReminder",true);
         Global.world.addGameMode(new GMPetsPlace(itemName,petType,this.m_gender,petName,isCash));
         this.removeEventListners();
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         m_window.genericButton.turnOff();
         close();
         this.removeEventListners();
         UI.redisplayMarketDialog("CustomizePets");
      }
      
      private function setImage(url:String = "", petScale:Number = 1) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(m_window.petIcon_mc.numChildren)
            {
               m_window.petIcon_mc.removeChildAt(0);
            }
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               dispObj.scaleX = petScale;
               dispObj.scaleY = petScale;
               m_window.petIcon_mc.addChildAt(dispObj,0);
            }
         });
      }
      
      protected function updateDisplay() : void
      {
         var pet:PetFarmItem = this.m_pets[this.m_colorIndex] as PetFarmItem;
         var petName:String = this.m_isCash ? pet.cashName : pet.name;
         this.setImage(pet.getImageByName("animation"),pet.itemScale);
         m_window.breed_tf.text = ZLocUtils.t("Dialogs",pet.name + "_breed");
         m_window.description_tf.text = ZLocUtils.t("Dialogs",pet.name + "_description");
         m_window.burst_mc.generic1_tf.text = ZLocUtils.t("Dialogs","PetComesWith");
         m_window.burst_mc.generic2_tf.text = ZLocUtils.t("Dialogs",petName + "_kibble");
         m_window.colorSelector_mc.farmCashOnly_mc.visible = pet.showCash;
         if(pet.showCash)
         {
            m_window.colorSelector_mc.farmCashOnly_mc.generic2_tf.text = ZLocUtils.t("Dialogs","PetYouWillBeChargeCash",{"cashQuantity":Utilities.formatNumber(pet.cash)});
         }
         if(this.m_isCash || pet.showCash)
         {
            m_window.charged_tf.text = ZLocUtils.t("Dialogs","PetYouWillBeChargeCash",{"cashQuantity":Utilities.formatNumber(pet.cash)});
         }
         else
         {
            m_window.charged_tf.text = ZLocUtils.t("Dialogs","PetYouWillBeChargeCoins",{"coinQuantity":Utilities.formatNumber(pet.cost)});
         }
         switch(this.m_colorIndex)
         {
            case this.COLOR_SWATCH_LEFT:
               m_window.colorSelector_mc.slot_0_mc.gotoAndStop(this.FRAME_SELECTED);
               m_window.colorSelector_mc.slot_1_mc.gotoAndStop(this.FRAME_NORMAL);
               m_window.colorSelector_mc.slot_2_mc.gotoAndStop(this.FRAME_NORMAL);
               break;
            case this.COLOR_SWATCH_CENTER:
               m_window.colorSelector_mc.slot_0_mc.gotoAndStop(this.FRAME_NORMAL);
               m_window.colorSelector_mc.slot_1_mc.gotoAndStop(this.FRAME_SELECTED);
               m_window.colorSelector_mc.slot_2_mc.gotoAndStop(this.FRAME_NORMAL);
               break;
            case this.COLOR_SWATCH_RIGHT:
               m_window.colorSelector_mc.slot_0_mc.gotoAndStop(this.FRAME_NORMAL);
               m_window.colorSelector_mc.slot_1_mc.gotoAndStop(this.FRAME_NORMAL);
               m_window.colorSelector_mc.slot_2_mc.gotoAndStop(this.FRAME_SELECTED);
         }
      }
      
      private function renderBoxColor(mc:MovieClip, color:Number) : void
      {
         var colorTransform:ColorTransform = mc.transform.colorTransform;
         colorTransform.color = color;
         mc.transform.colorTransform = colorTransform;
      }
   }
}

