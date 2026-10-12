package Classes
{
   import Classes.Constants.Experiments;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemState;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TAnimalTransform;
   import ZLocalization.LocalizationObjectToken;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class GrowableBaby extends Animal
   {
      
      protected static const TRANSFORM_OVERLAY_URL:String = "assets/overlays/effect_sapling_sparkling.swf";
      
      private const ANIMAL_GROW_UP:String = "animal_grow_up";
      
      protected var m_shouldTransform:Boolean = false;
      
      protected var m_growDialogDisplayString:String = "AnimalBreedingGeneric_GrowBaby";
      
      protected var m_growCompleteDialogString:String = "AnimalBreedingGeneric_BabyGrown";
      
      protected var m_adultItem:FarmItem;
      
      protected var m_growPrice:int;
      
      protected var m_breedingBuildingType:String;
      
      protected var m_transactionInProgress:Boolean = false;
      
      public function GrowableBaby(animalType:String = null)
      {
         var xml:XML = null;
         super(animalType);
         var curItem:FarmItem = this.getItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_adultItem = Global.farmGameSettingsManager.getFarmItemByName(curItem.getStringFromDataSource("breedingAdult"));
            this.m_growPrice = curItem.getIntFromDataSource("growPrice");
            this.m_breedingBuildingType = curItem.getStringFromDataSource("breedingBuildingType");
            if(!this.m_breedingBuildingType)
            {
               this.m_breedingBuildingType = "cowpasture";
            }
            if(curItem.hasPropertyInDataSource("growDialogDisplayString"))
            {
               this.m_growDialogDisplayString = curItem.getStringFromDataSource("growDialogDisplayString");
            }
            if(curItem.hasPropertyInDataSource("growCompleteDialogString"))
            {
               this.m_growCompleteDialogString = curItem.getStringFromDataSource("growCompleteDialogString");
            }
         }
         else
         {
            xml = curItem.xml;
            this.m_adultItem = Global.farmGameSettingsManager.getFarmItemByName(xml.breedingAdult);
            this.m_growPrice = xml.growPrice;
            this.m_breedingBuildingType = xml.breedingBuildingType;
            if(!this.m_breedingBuildingType)
            {
               this.m_breedingBuildingType = "cowpasture";
            }
            if(xml.hasOwnProperty("growDialogDisplayString"))
            {
               this.m_growDialogDisplayString = xml.growDialogDisplayString;
            }
            if(xml.hasOwnProperty("growCompleteDialogString"))
            {
               this.m_growCompleteDialogString = xml.growCompleteDialogString;
            }
         }
      }
      
      public function get breedingBuildingType() : String
      {
         return this.m_breedingBuildingType;
      }
      
      override protected function generateMenuItems() : void
      {
         super.generateMenuItems();
         if(Boolean(this.m_adultItem && this.m_adultItem.name && !isNaN(this.m_growPrice)) && Boolean(this.m_growPrice > 0) && (!(this is ItemGrowableBaby) || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DREAM_DEER_FEED) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START))
         {
            m_menuItems.unshift({
               "label":ZLocUtils.t("Dialogs","AnimalBreedingGeneric_GrowBabyContextMenu",{
                  "quantity":this.m_growPrice,
                  "paymentName":this.paymentName()
               }),
               "action":this.ANIMAL_GROW_UP
            });
         }
      }
      
      override public function onClick() : void
      {
         if(!this.m_transactionInProgress)
         {
            super.onClick();
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var itemName:String = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               switch(item.action)
               {
                  case this.ANIMAL_GROW_UP:
                     if(this.shouldConfirmGrowUp())
                     {
                        itemName = this.getItem().friendlyTitle;
                        UI.displayMessage(ZLocUtils.t("Dialogs",this.m_growDialogDisplayString,{
                           "quantity":this.m_growPrice,
                           "itemName":itemName,
                           "paymentName":this.paymentName()
                        }),GenericPopup.TYPE_ACCEPTCANCEL,this.onGrowUpConfirmationResponse);
                     }
                     else
                     {
                        this.onGrowUpConfirmationResponse();
                     }
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      public function shouldConfirmGrowUp() : Boolean
      {
         return true;
      }
      
      public function paymentName() : String
      {
         return "";
      }
      
      override public function transform() : void
      {
         var ugcItemDef:UGCItemDefinition = null;
         var ugcItemState:UGCItemState = null;
         var currentPosition:Vector3 = this.getPosition();
         var id:Number = this.getId();
         detach();
         var adult:Animal = this.getAdultInstance();
         var ugcAdult:UGCAnimal = adult as UGCAnimal;
         if(ugcAdult)
         {
            ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(ugcAdult.getItemName());
            ugcItemState = UGCItemState.createFromDefinition(ugcItemDef);
            ugcAdult.ugcDelegate.ugcItemState = ugcItemState;
         }
         adult.setMetadata(this.getMetadata());
         adult.attachToPersistentData(this.persistentDataKey);
         adult.setOuter(Global.world);
         adult.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
         adult.conditionallyReattach();
         adult.setId(id);
         adult.setState(STATE_BARE);
         adult.showAoeBonus(null,true,false);
      }
      
      protected function onTransformComplete(resultData:Object) : void
      {
         var adultObject:Animal = null;
         var itemName:LocalizationObjectToken = ZLocUtils.tk_pk(this.m_adultItem.friendlyName);
         var body:String = ZLocUtils.t("Dialogs",this.m_growCompleteDialogString,{"itemName":itemName});
         var adultPopup:GenericIconPopup = new GenericIconPopup(body,GenericPopup.TYPE_SHARE,this.onAdultDialogResponse,this.m_adultItem.iconUrl);
         this.m_transactionInProgress = false;
         adultPopup.rewardUrl = resultData.rewardLink;
         UI.displayPopup(adultPopup,false,"Breeding_BabyGrown",true);
         if(resultData.adultMetadata)
         {
            adultObject = Global.world.getObjectById(resultData.adultId) as Animal;
            if(adultObject)
            {
               adultObject.setMetadata(resultData.adultMetadata);
            }
         }
      }
      
      protected function getAdultInstance() : Animal
      {
         var tempClass:Class = null;
         var typeAsClassName:String = null;
         if(this.m_adultItem.className != "")
         {
            tempClass = getDefinitionByName("Classes." + this.m_adultItem.className) as Class;
         }
         else if(this.m_adultItem.type)
         {
            typeAsClassName = "Classes." + FarmGameUtil.toUpperCaseFirst(this.m_adultItem.type);
            tempClass = getDefinitionByName(typeAsClassName) as Class;
            if(!tempClass)
            {
               tempClass = getDefinitionByName("Classes.Animal") as Class;
            }
         }
         else
         {
            tempClass = getDefinitionByName("Classes.Animal") as Class;
         }
         return new tempClass(this.m_adultItem.name);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         super.onHarvestComplete(result);
         FarmStatsManager.count("farm_world_actions","harvest","Animal",this.getItem().name);
      }
      
      protected function onGrowUpConfirmationResponse(event:GenericPopupEvent = null) : void
      {
         if(event == null || event.button == GenericPopup.ACCEPT)
         {
            if(this.canTransform())
            {
               this.m_transactionInProgress = true;
               TransactionManager.addTransaction(new TAnimalTransform(this,this.onTransformComplete),true);
               this.m_shouldTransform = true;
               this.dispOverlay(TRANSFORM_OVERLAY_URL);
            }
            else
            {
               this.transformFailed();
            }
            FarmStatsManager.count(this.m_breedingBuildingType + "_baby","maturation","complete_now","accept",String(this.m_growPrice),Global.worldManager.currentWorldType);
         }
         else
         {
            FarmStatsManager.count(this.m_breedingBuildingType + "_baby","maturation","complete_now","cancel","",Global.worldManager.currentWorldType);
         }
      }
      
      protected function transformFailed() : void
      {
      }
      
      protected function onAdultDialogResponse(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var feedBundle:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":event.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + event.rewardLink,
                  "src":this.m_adultItem.iconUrl
               }],
               "item":this.m_adultItem.friendlyTitle
            };
            feedBundle = this.m_breedingBuildingType + "BabyGrown";
            GlobalEngine.socialNetwork.publishFeedStory(feedBundle,bundleData,[],false);
         }
      }
      
      override protected function overlayComplete() : Boolean
      {
         if(this.m_shouldTransform)
         {
            this.transform();
            this.m_shouldTransform = !this.chargeTransform();
         }
         return super.overlayComplete();
      }
      
      protected function canTransform() : Boolean
      {
         return false;
      }
      
      protected function chargeTransform() : Boolean
      {
         return false;
      }
   }
}

