package Widgets.Slots.Breeding
{
   import Classes.Animal;
   import Classes.Collections.AnimalBreedingCollectible;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.BreedingProjects.TPurchaseBreedingAnimal;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.BreedingCollectionFrame;
   import Widgets.Frames.Breeding.BreedingMatingFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BreedingCollectionPreviewSlot extends ZwSlotFrame
   {
      
      private var m_previewObject:ObjectPreviewFrame;
      
      private var m_animalBreedingCollectible:AnimalBreedingCollectible;
      
      private var m_collectibleCountText:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_breedingWindow:BreedingCollectionFrame;
      
      public function BreedingCollectionPreviewSlot(element:DisplayObject, breedingWindow:BreedingCollectionFrame)
      {
         this.m_breedingWindow = breedingWindow;
         super(element);
         addWidget(this.m_collectibleCountText = new ZwTextField(m_element.collectibleCount_tf));
         var animalCost:int = Global.farmGameSettingsManager.getNumber(this.m_breedingWindow.parentWindow.building.getItemName() + "CollectionItemCost",20);
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),animalCost.toString(),this.onBuyTurtle));
         addWidget(this.m_askButton = new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t("Dialogs","AskFriends"),this.onAskAnimal),false);
      }
      
      override public function populate(data:Object) : void
      {
         var featureName:String = null;
         var breedGender:String = null;
         var jsonString:String = null;
         var itemHash:String = null;
         var resultState:MutableAnimalState = null;
         var breedItem:FarmItem = null;
         this.m_animalBreedingCollectible = data as AnimalBreedingCollectible;
         if(this.m_animalBreedingCollectible != null)
         {
            featureName = this.m_breedingWindow.parentWindow.building.getItemName();
            breedGender = this.m_animalBreedingCollectible.dna[MutableAnimalState.GENDER_DATA_KEY];
            jsonString = com.adobe.serialization.json.JSON.encode(this.m_animalBreedingCollectible.dna);
            itemHash = Global.farmGameSettingsManager.getFarmItemCodeByName(Global.animalBreedingSettings.getItemNameFromGender(featureName,breedGender)) + ":";
            resultState = MutableAnimalState.createFromPhpString(itemHash,jsonString);
            if(this.m_previewObject != null)
            {
               removeWidget(this.m_previewObject);
            }
            try
            {
               breedItem = FeatureBuilding.getFarmItemForHash(resultState.hash);
               this.m_previewObject = new ObjectPreviewFrame(m_element.icon_mc,breedItem,null,[BreedingMatingFrame.PREVIEW_ZOOM_LEVEL],null,Animal.STATE_FRONT_CYCLE,resultState.jsonString);
               addWidget(this.m_previewObject);
               this.m_collectibleCountText.text = this.m_animalBreedingCollectible.numOwned + " / " + this.m_animalBreedingCollectible.numneeded;
               this.m_collectibleCountText.visible = true;
               this.m_buyButton.visible = true;
            }
            catch(exception:Error)
            {
            }
         }
      }
      
      private function onBuyTurtle(event:Event) : void
      {
         var dnaObj:Object = null;
         var baseColor:String = null;
         var patternColor:String = null;
         var patternStyle:String = null;
         var collectionItemPrice:Number = Global.farmGameSettingsManager.getNumber(this.m_breedingWindow.getFeatureName() + "CollectionItemCost",20);
         if(Global.player.cash >= collectionItemPrice)
         {
            Global.player.cash -= collectionItemPrice;
            this.m_buyButton.enabled = false;
            this.m_breedingWindow.showLoadingOverlay();
            dnaObj = this.m_animalBreedingCollectible.dna;
            baseColor = AnimalBreedingManager.getInstance().getColorName({"data":com.adobe.serialization.json.JSON.encode(dnaObj)});
            patternColor = AnimalBreedingManager.getInstance().getColorName({"data":com.adobe.serialization.json.JSON.encode(dnaObj)},MutableAnimalState.PATTERN_DATA_KEY);
            patternStyle = dnaObj[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY];
            if(baseColor != null && patternColor != null && patternStyle != null)
            {
               TransactionManager.addTransaction(new TPurchaseBreedingAnimal(this.m_breedingWindow.getFeatureName(),MutableAnimalState.GENDER_CODE_MALE,baseColor,patternColor,patternStyle,this.m_breedingWindow.parentWindow),true);
            }
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,"impulseBuy" + this.m_breedingWindow.getFeatureName());
         }
      }
      
      private function onAskAnimal(event:Event) : void
      {
      }
      
      override public function release() : void
      {
         this.m_collectibleCountText.release();
         this.m_previewObject.release();
         super.release();
      }
   }
}

