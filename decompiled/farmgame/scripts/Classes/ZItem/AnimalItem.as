package Classes.ZItem
{
   import Classes.Animal;
   import Classes.CashGrowableBaby;
   import Classes.DoghouseAnimal;
   import Classes.FestivalOfColorAnimal;
   import Classes.GrowableAnimal;
   import Classes.HarvestableStorageBuilding;
   import Classes.ItemGrowableBaby;
   import Classes.Mastery;
   import Classes.Pet;
   import Classes.RandomItemGrowableBaby;
   import Classes.SimpleHarvestableItem;
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import GameMode.GMAnimalPlace;
   import GameMode.GMBeehiveItemPlace;
   import GameMode.GMDucklingAnimalPlace;
   import GameMode.GMEvolutionAnimalPlace;
   import GameMode.GMFeedTroughItemPlace;
   import GameMode.GMMutableAnimalPlace;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingGiftContentDataManager;
   import Managers.PetManager;
   import Transactions.TBuyConsumables;
   
   public class AnimalItem extends SimpleHarvestableItem
   {
      
      protected var m_isRescue:int = -1;
      
      protected var m_isCustomizable:int = -1;
      
      public function AnimalItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get isRescue() : Boolean
      {
         var isRescue:Boolean = false;
         if(this.m_isRescue < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               isRescue = m_dataSource.getBoolean("rescue");
               if(isRescue)
               {
                  this.m_isRescue = 1;
               }
               else
               {
                  this.m_isRescue = 0;
               }
            }
            else if(!m_itemXML.hasOwnProperty("@rescue"))
            {
               this.m_isRescue = 0;
            }
            else
            {
               this.m_isRescue = m_itemXML.@rescue == "true" ? 1 : 0;
            }
         }
         return this.m_isRescue > 0;
      }
      
      public function get isCustomizable() : Boolean
      {
         var isCustomizable:Boolean = false;
         if(this.m_isCustomizable < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               isCustomizable = m_dataSource.getBoolean("customizable");
               if(isCustomizable)
               {
                  this.m_isCustomizable = 1;
               }
               else
               {
                  this.m_isCustomizable = 0;
               }
            }
            else if(!m_itemXML.hasOwnProperty("@customizable"))
            {
               this.m_isCustomizable = 0;
            }
            else
            {
               this.m_isCustomizable = m_itemXML.@customizable == "true" ? 1 : 0;
            }
         }
         return this.m_isCustomizable > 0;
      }
      
      override public function get isVisible() : Boolean
      {
         var rescueFlag:Boolean = true;
         if(this.isRescue)
         {
            rescueFlag = PetManager.getInstance().hasRunawayPet();
         }
         var customizableFlag:Boolean = true;
         if(className == "Pet")
         {
            customizableFlag = this.isCustomizable;
         }
         return super.isVisible && rescueFlag && customizableFlag;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var hasPet:Boolean = false;
         var metadata:String = null;
         var item:FarmItem = null;
         var currency:String = null;
         var isFromMarket:Boolean = false;
         Animal.stopAllWandering();
         if(subType == "consumable" || isConsumable)
         {
            hasPet = Global.world.getObjectsByClass(Pet).length > 0;
            if(subType == "pets" && !hasPet)
            {
               PetManager.getInstance().onBuyPetConsumableWithoutPet();
            }
            else
            {
               TransactionManager.addTransaction(new TBuyConsumables(name,false));
            }
         }
         else if(this.isRescue)
         {
            PetManager.getInstance().onRescuePet();
         }
         else if("BeehiveItem" == className)
         {
            Global.world.addGameMode(new GMBeehiveItemPlace(name,false,count),false);
         }
         else if("FeedTroughItem" == className)
         {
            Global.world.addGameMode(new GMFeedTroughItemPlace(name,false),false);
         }
         else if(className == "MutableAnimal")
         {
            metadata = Global.animalBreedingSettings.getVariantJSONByItemName(name,name);
            Global.world.addGameMode(new GMMutableAnimalPlace(metadata,name,false,0,true,true),false);
         }
         else if(className == "RandomItemGrowableBaby")
         {
            Global.world.addGameMode(new GMAnimalPlace(name,false,0,true,RandomItemGrowableBaby,extraData.currency as String));
         }
         else if(className == "FestivalOfColorAnimal")
         {
            Global.world.addGameMode(new GMAnimalPlace(name,false,0,true,FestivalOfColorAnimal,extraData.currency as String));
         }
         else
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(name);
            if(item.customizable)
            {
               if(FarmItem.getMarketContextByName(name) == FarmItem.MARKET_CONTEXT_CASH)
               {
                  PetManager.getInstance().showCustomizePetPopup(name,true);
               }
               else
               {
                  PetManager.getInstance().showPetCoinsReminder(name);
               }
            }
            else
            {
               currency = Boolean(extraData) && extraData.hasOwnProperty("currency") ? extraData.currency : "";
               isFromMarket = Boolean(extraData) && extraData.hasOwnProperty("isFromMarket") ? Boolean(extraData.isFromMarket) : false;
               Global.world.addGameMode(new GMAnimalPlace(name,false,0,true,null,currency,isFromMarket));
            }
         }
         return true;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var metadata:Object = null;
         var isGift:Boolean = true;
         var repopGift:Boolean = true;
         if(extraData)
         {
            if(extraData.isGift != null && extraData.isGift == false)
            {
               isGift = false;
            }
            if(extraData.repopGift != null && extraData.repopGift == false)
            {
               repopGift = false;
            }
         }
         if(isToolGenerated)
         {
            repopGift = false;
         }
         var itemName:String = name;
         if(Boolean(extraData) && Boolean(extraData["realItemName"]))
         {
            itemName = extraData.realItemName;
         }
         var inventoryKey:String = code;
         if(Boolean(extraData) && Boolean(extraData["inventoryKey"]))
         {
            inventoryKey = extraData.inventoryKey;
         }
         var itemCount:int = 1;
         if(Boolean(extraData) && Boolean(extraData["itemCount"]) && extraData["itemCount"] > 0)
         {
            itemCount = int(extraData["itemCount"]);
         }
         var fromMarket:Boolean = false;
         if(Boolean(extraData) && Boolean(extraData["fromMarket"]))
         {
            fromMarket = Boolean(extraData.fromMarket);
         }
         switch(className)
         {
            case "BeehiveItem":
               Global.world.addGameMode(new GMBeehiveItemPlace(itemName,isGift,itemCount),false);
               break;
            case "FeedTroughItem":
               Global.world.addGameMode(new GMFeedTroughItemPlace(itemName,isGift,itemCount),false);
               break;
            case "DucklingAnimal":
               Global.world.addGameMode(new GMDucklingAnimalPlace(null,name,isGift,buildingId,repopGift),false);
               break;
            case "DoghouseAnimal":
            case "MutableAnimal":
               metadata = null;
               if(isGift)
               {
                  metadata = Global.player.getGiftMetadata(code);
               }
               else if(buildingId < 0)
               {
                  metadata = Global.player.getInventoryItemExtraData(inventoryKey,0,buildingId);
               }
               else
               {
                  metadata = extraData.itemMetadata;
               }
               if(className == "DoghouseAnimal")
               {
                  Global.world.addGameMode(new GMMutableAnimalPlace(metadata,name,isGift,buildingId,true,fromMarket,DoghouseAnimal),false);
               }
               else
               {
                  Global.world.addGameMode(new GMMutableAnimalPlace(metadata,name,isGift,buildingId,true,fromMarket),false);
               }
               break;
            case "CashGrowableBaby":
               Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift,CashGrowableBaby));
               break;
            case "ItemGrowableBaby":
               Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift,ItemGrowableBaby));
               break;
            case "RandomItemGrowableBaby":
               Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift,RandomItemGrowableBaby));
               break;
            case "GrowableAnimal":
               Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift,GrowableAnimal));
               break;
            case "EvolutionAnimal":
               Global.world.addGameMode(new GMEvolutionAnimalPlace(itemName,isGift,buildingId,repopGift,"",extraData));
               break;
            case "FestivalOfColorAnimal":
               Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift,FestivalOfColorAnimal));
               break;
            default:
               if(customizable)
               {
                  if(FarmItem.getMarketContextByName(itemName) == FarmItem.MARKET_CONTEXT_CASH)
                  {
                     PetManager.getInstance().showCustomizePetPopup(itemName,true);
                  }
                  else
                  {
                     PetManager.getInstance().showPetCoinsReminder(itemName);
                  }
               }
               else
               {
                  Global.world.addGameMode(new GMAnimalPlace(itemName,isGift,buildingId,repopGift));
               }
         }
      }
      
      override protected function defaultPreview() : Boolean
      {
         return className != "BeehiveItem" && className != "FeedTroughItem" && !this.isRescue && !(subType == "consumable" || isConsumable);
      }
      
      override public function get hasMastery() : Boolean
      {
         var result:Boolean = super.hasMastery;
         var itemCode:String = HarvestableStorageBuilding.getItemCodeForMasteryOverrideExportName(code);
         if(itemCode != code)
         {
            result = (Global.farmGameSettingsManager.getFarmItemByCode(itemCode) as HarvestableItem).hasMastery;
         }
         return result;
      }
      
      override public function get mastery() : Mastery
      {
         var itemCode:String = null;
         if(m_mastery == null)
         {
            itemCode = code;
            itemCode = HarvestableStorageBuilding.getItemCodeForMasteryOverrideExportName(code);
            m_mastery = Global.farmGameSettingsManager.getMasteryByCode(itemCode);
         }
         return m_mastery;
      }
      
      override public function onSell(quantity:int = 1) : void
      {
         FeatureBuildingGiftContentDataManager.sellStorageItem(this.code,quantity);
      }
   }
}

