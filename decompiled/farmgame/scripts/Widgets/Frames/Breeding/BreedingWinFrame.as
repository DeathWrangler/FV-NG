package Widgets.Frames.Breeding
{
   import Classes.Animal;
   import Classes.MutableAnimalBaby;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import GameMode.GMMutableAnimalBabyPlace;
   import Managers.FarmStatsManager;
   import Managers.UserContentManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BreedingWinFrame extends ZwFrame
   {
      
      protected static const KEEP_BY_BUTTON:String = "button";
      
      protected static const KEEP_BY_CLOSE:String = "close";
      
      protected var m_parentWindow:BreedingWindow = null;
      
      protected var m_headerText:ZwTextField = null;
      
      protected var m_nameText:FarmTextField = null;
      
      protected var m_mutableAnimalState:MutableAnimalState = null;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_greyColor:Number = 0;
      
      protected var m_featureName:String = "";
      
      public function BreedingWinFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         this.m_headerText = new ZwTextField(m_element.header_tf);
         addWidget(this.m_headerText);
         addWidget(new ZwTextField(m_element.generic1_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_NameYourLamb")));
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_Message2")));
         addWidget(new ZwTextField(m_element.generic3_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_Message3")));
         addWidget(new ZwTextField(m_element.counter_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_Counter")));
         this.m_nameText = new FarmTextField(m_element.name_tf);
         this.m_nameText.setMultiline(false);
         addWidget(this.m_nameText);
         addWidget(new FarmAnimatedTextButton(m_element.generic1_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_Give"),this.onGiveClick));
         addWidget(new FarmAnimatedTextButton(m_element.generic2_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_Keep"),this.onKeepClick));
         this.m_greyColor = this.m_nameText.element.textColor;
         addWidget(new ZwButton(m_element.close_bt,this.onClose));
      }
      
      public function displayWindow(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_nameText.element.textColor = this.m_greyColor;
         this.m_mutableAnimalState = mutableAnimalState;
         var babyColor:Array = FarmGameUtil.hsvToRgb(this.m_mutableAnimalState.hue(),0.1,this.m_mutableAnimalState.intensity());
         var babyName:String = Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"defaultBreedItem").toString();
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(babyName);
         this.visible = true;
         if(this.m_objectPreviewFrame)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.icon_mc,farmItem,null,[4],null,Animal.STATE_FRONT_IDLE);
         (this.m_objectPreviewFrame.mapResource as MutableAnimalBaby).setMutableAnimalState(mutableAnimalState);
         if(mutableAnimalState.dna[MutableAnimalState.GENDER_DATA_KEY] == MutableAnimalState.GENDER_CODE_MALE)
         {
            this.m_headerText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_HeaderBoy");
            this.m_nameText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_DefaultBoy",{"user":ZLocUtils.tn(Global.player.firstName,ZLocUtils.tg(Global.player.snUser.gender))});
         }
         else
         {
            this.m_headerText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_HeaderGirl");
            this.m_nameText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_Congrats_DefaultGirl",{"user":ZLocUtils.tn(Global.player.firstName,ZLocUtils.tg(Global.player.snUser.gender))});
         }
         this.m_nameText.restrict("",Number(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"maximumNameLength")));
         this.addWidget(this.m_objectPreviewFrame);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
         this.m_headerText = null;
         this.m_objectPreviewFrame = null;
      }
      
      protected function onGiveClick(event:MouseEvent) : void
      {
         var babyName:String = null;
         var farmItem:FarmItem = null;
         if(!FarmGameUtil.hasBadWord(this.m_nameText.text))
         {
            AnimalBreedingManager.getInstance().createBabyImage(this.m_objectPreviewFrame.mapResource,UserContentManager.FEATURE_ANIMAL_BREEDING);
            babyName = Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"defaultBreedItem").toString();
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(babyName);
            AnimalBreedingManager.getInstance().setAnimalName(farmItem.code,this.m_mutableAnimalState.getHashKey(),this.m_nameText.text,-1);
            AnimalBreedingManager.getInstance().giveUpForAdoption(farmItem.code,this.m_mutableAnimalState.getHashKey(),this.m_parentWindow.getFeatureName(),this.m_nameText.text);
            FarmStatsManager.count(this.m_featureName,"breeding","baby_born","give",this.m_mutableAnimalState.statsHSV + ":T:" + Global.animalBreedingSettings.getPatternTrait(this.m_parentWindow.building.getItem().name,this.m_mutableAnimalState.pattern));
            this.visible = false;
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "_InvalidNameChoice"),0,null,"",true);
            FarmStatsManager.count(this.m_featureName,"breeding","baby_born","bad_word",this.m_nameText.text);
         }
      }
      
      protected function onKeepClick(event:MouseEvent) : void
      {
         this.acceptBaby(KEEP_BY_BUTTON);
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         this.acceptBaby(KEEP_BY_CLOSE);
      }
      
      protected function acceptBaby(keepByMethod:String) : void
      {
         var babyName:String = null;
         var farmItem:FarmItem = null;
         if(!FarmGameUtil.hasBadWord(this.m_nameText.text))
         {
            this.m_mutableAnimalState.name = this.m_nameText.text;
            babyName = Global.animalBreedingSettings.getFeatureConfigAttr(this.m_parentWindow.building.getItem().name,"defaultBreedItem").toString();
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(babyName);
            AnimalBreedingManager.getInstance().setAnimalName(farmItem.code,this.m_mutableAnimalState.getHashKey(),this.m_nameText.text,-1);
            FarmStatsManager.count(this.m_featureName,"breeding","baby_born","keep_by_" + keepByMethod,this.m_mutableAnimalState.statsHSV + ":T:" + Global.animalBreedingSettings.getPatternTrait(this.m_parentWindow.building.getItem().name,this.m_mutableAnimalState.pattern));
            if(keepByMethod == KEEP_BY_BUTTON)
            {
               Global.world.addGameMode(new GMMutableAnimalBabyPlace(this.m_mutableAnimalState.getPackedMutableState(),babyName,true,-1,false,-1,true),false);
               this.m_parentWindow.close();
            }
            else
            {
               this.visible = false;
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "_InvalidNameChoice"),0,null,"",true);
            FarmStatsManager.count(this.m_featureName,"breeding","baby_born","bad_word",this.m_nameText.text);
         }
      }
   }
}

