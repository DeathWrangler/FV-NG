package Widgets.Frames.Breeding
{
   import Classes.Animal;
   import Classes.Collections.AnimalBreedingCollectible;
   import Classes.Collections.AnimalBreedingCollection;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.AnimalBreedingState;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.BreedingProjects.TAnimalCollectionTradeIn;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Slots.Breeding.BreedingCollectionPreviewSlot;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class BreedingCollectionPreviewFrame extends FarmSlotContainerFrame
   {
      
      private var m_collectionName:ZwTextField;
      
      private var m_tradeIn:FarmAnimatedTextButton;
      
      private var m_rewardFrame:ZwFrame;
      
      private var m_rewardPreview:ObjectPreviewFrame;
      
      private var m_animalBreedingCollection:AnimalBreedingCollection;
      
      private var m_parentWindow:BreedingCollectionFrame;
      
      private var m_confirmPopup:GenericPopup;
      
      private var m_completeCollection:ZwBaseWidget;
      
      public function BreedingCollectionPreviewFrame(element:DisplayObject, parentWindow:BreedingCollectionFrame)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(this.m_collectionName = new ZwTextField(m_element.collectionName_tf));
         addWidget(this.m_tradeIn = new FarmAnimatedTextButton(m_element.trade_bt,ZLocUtils.t("Collections","TradeIn"),this.showTradeConfirmationDialog));
         addWidget(this.m_rewardFrame = new ZwFrame(m_element.reward_mc));
         this.m_rewardFrame.addWidget(new ZwTextField(m_element.reward_mc.title_tf,"Reward"));
         if(m_element.completeCollection_mc)
         {
            this.m_completeCollection = new ZwBaseWidget(m_element.completeCollection_mc);
            addWidget(this.m_completeCollection,false);
         }
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BreedingCollectionPreviewSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      public function set collection(collection:AnimalBreedingCollection) : void
      {
         var collectible:AnimalBreedingCollectible = null;
         this.m_animalBreedingCollection = collection;
         for each(collectible in this.m_animalBreedingCollection.collectibles)
         {
            collectible.numOwned = 0;
         }
         this.setupCollectionPreview();
         this.updateRewardFrame();
      }
      
      private function updateRewardFrame() : void
      {
         var collectible:AnimalBreedingCollectible = null;
         if(this.m_rewardPreview != null)
         {
            this.m_rewardFrame.removeWidget(this.m_rewardPreview);
         }
         var jsonString:String = com.adobe.serialization.json.JSON.encode(this.m_animalBreedingCollection.tradeInReward.dna);
         var itemHash:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_animalBreedingCollection.tradeInRewardItem) + ":";
         var resultState:MutableAnimalState = MutableAnimalState.createFromPhpString(itemHash,jsonString);
         var breedItem:FarmItem = FeatureBuilding.getFarmItemForHash(resultState.hash);
         this.m_rewardPreview = new ObjectPreviewFrame(m_element.reward_mc.icon_mc,breedItem,null,[BreedingMatingFrame.PREVIEW_ZOOM_LEVEL],null,Animal.STATE_FRONT_CYCLE,resultState.jsonString);
         this.m_rewardFrame.addWidget(this.m_rewardPreview);
         var canTrade:Boolean = true;
         for each(collectible in this.m_animalBreedingCollection.collectibles)
         {
            if(collectible.numneeded > collectible.numOwned)
            {
               canTrade = false;
               break;
            }
         }
         this.m_tradeIn.enabled = canTrade;
         if(this.m_completeCollection != null)
         {
            this.m_completeCollection.visible = canTrade;
         }
      }
      
      public function setupCollectionPreview() : void
      {
         var count:int = 0;
         var farmItem:FarmItem = null;
         var key:String = null;
         var j:int = 0;
         var baseColor:String = null;
         var patternColor:String = null;
         var patternCode:String = null;
         var patternName:String = null;
         var collectible:AnimalBreedingCollectible = null;
         this.m_collectionName.text = ZLocUtils.t("Dialogs",this.m_animalBreedingCollection.name + "_CollectionName");
         var featureBuilding:FeatureBuilding = this.m_parentWindow.parentWindow.building;
         var storageMetaData:Object = featureBuilding.storageMetaData;
         var storageDataForCode:Array = null;
         var inUseHashes:Dictionary = (featureBuilding.extraDataState as AnimalBreedingState).getInUseBreedHashes();
         var breedingSignItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("messageSign");
         var metaDataArray:Array = null;
         var metaData:Object = {};
         for(key in featureBuilding.contents)
         {
            count = int(featureBuilding.contents[key]);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
            storageDataForCode = featureBuilding.getStorageMetaDataForCode(key);
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
                  if(metaData.hasOwnProperty("data") && metaData.data != null && metaData.hasOwnProperty("key") && metaData.key != "")
                  {
                     baseColor = AnimalBreedingManager.getInstance().getColorName(metaData);
                     patternColor = AnimalBreedingManager.getInstance().getColorName(metaData,MutableAnimalState.PATTERN_DATA_KEY);
                     patternCode = AnimalBreedingManager.getInstance().getPatternCodeFromMetadata(metaData);
                     patternName = Global.animalBreedingSettings.getPatternTrait(featureBuilding.getItemName(),patternCode);
                     for each(collectible in this.m_animalBreedingCollection.collectibles)
                     {
                        if(baseColor != null && baseColor == collectible.tint && patternColor != null && patternColor == collectible.pattern && patternName != null && patternName == collectible.gene)
                        {
                           ++collectible.numOwned;
                           collectible.metaHash = metaData.key;
                        }
                     }
                  }
               }
               else
               {
                  --inUseHashes[metaData.key];
               }
            }
         }
         this.items = this.m_animalBreedingCollection.collectibles;
      }
      
      private function showTradeConfirmationDialog(event:Event) : void
      {
         var featureName:String = this.m_parentWindow.getFeatureName();
         FarmStatsManager.count(featureName,"tradeIn","tradeConfirmation","view");
         var tradeMessage:String = ZLocUtils.t("Dialogs",featureName + "_tradeConfirmation",{"collectionName":ZLocUtils.t("Dialogs",this.m_animalBreedingCollection.name + "_CollectionName")});
         this.m_confirmPopup = new GenericPopup(tradeMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onTradeIn);
         UI.displayPopup(this.m_confirmPopup,false,"Collection_TradeIn",true);
      }
      
      private function onTradeIn(event:GenericPopupEvent) : void
      {
         var animalCollectible:AnimalBreedingCollectible = null;
         var featureOption:Object = null;
         var farmItem:FarmItem = null;
         var i:int = 0;
         this.m_confirmPopup.close();
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(this.m_parentWindow.getFeatureName(),"tradeIn","tradeConfirmation","accept");
            this.m_parentWindow.showLoadingOverlay();
            for each(animalCollectible in this.m_animalBreedingCollection.collectibles)
            {
               --animalCollectible.numOwned;
               this.m_parentWindow.parentWindow.building.lastMetaHashRemoved = animalCollectible.metaHash;
               farmItem = FeatureBuilding.getFarmItemForHash(animalCollectible.metaHash);
               for(i = 0; i < animalCollectible.numneeded; i++)
               {
                  this.m_parentWindow.parentWindow.building.removeContents(farmItem.code,1);
                  this.m_parentWindow.parentWindow.building.lastMetaHashRemoved = animalCollectible.metaHash;
               }
            }
            featureOption = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.ANIMAL_BREEDING,this.m_parentWindow.getFeatureName());
            if(featureOption == null)
            {
               featureOption = {};
            }
            if(featureOption.hasOwnProperty(this.m_animalBreedingCollection.name))
            {
               ++featureOption[this.m_animalBreedingCollection.name];
            }
            else
            {
               featureOption[this.m_animalBreedingCollection.name] = 1;
            }
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.ANIMAL_BREEDING,this.m_parentWindow.getFeatureName(),featureOption);
            this.m_tradeIn.enabled = false;
            TransactionManager.addTransaction(new TAnimalCollectionTradeIn(this.m_parentWindow.parentWindow,this.m_animalBreedingCollection.name,this.m_parentWindow.parentWindow.building.getId()),true);
         }
         else
         {
            FarmStatsManager.count(this.m_parentWindow.getFeatureName(),"tradeIn","tradeConfirmation","cancel");
         }
      }
   }
}

