package GameMode
{
   import Classes.AdventurersCamp;
   import Classes.AlaskaInnovationOpenUIOnClick;
   import Classes.AnimalBreedingPenConstructionBuilding;
   import Classes.AnimalPetrunConstructionBuilding;
   import Classes.AnimalWildlifePenConstructionBuilding;
   import Classes.ArboretumBuilding;
   import Classes.AthleticContest;
   import Classes.Avatar.FarmAvatar;
   import Classes.BeehiveConstructionBuilding;
   import Classes.BotanicalGardenCashBuilding;
   import Classes.BotanicalGardenConstructionBuilding;
   import Classes.BrazilInnovationOpenUIOnClick;
   import Classes.Building;
   import Classes.CarnivalParades;
   import Classes.ChickenCoopBuilding;
   import Classes.CocowonderlandInnovationOpenUIOnClick;
   import Classes.ContingencyBuildableBuilding;
   import Classes.CraftingCottageBuilding;
   import Classes.CupidStable;
   import Classes.DairyFarmBuilding;
   import Classes.DragonBreedingFeatureBuilding;
   import Classes.DragonValleyInnovationOpenUIOnClick;
   import Classes.EasterBasket;
   import Classes.EverGrowingHarvestableBuilding;
   import Classes.FVStudio;
   import Classes.FarmVillageFactoryBuilding;
   import Classes.FatSantaBuilding;
   import Classes.FeatureBuilding;
   import Classes.FeatureBuildingOpenUIOnClick;
   import Classes.FeedTroughBuilding;
   import Classes.FishermansCoveBuilding;
   import Classes.FixedConstructionBuilding;
   import Classes.FixedFeatureBuilding;
   import Classes.FixedTreasureConstructionBuilding;
   import Classes.FlowerShackFeatureBuilding;
   import Classes.FrenchChateauBuilding;
   import Classes.FrontierPiggies;
   import Classes.FurryAndFabulous;
   import Classes.GarageConstructionBuilding;
   import Classes.HaitiBackpack;
   import Classes.HalloweenBasket;
   import Classes.HalloweenCastleDuckulaBuilding;
   import Classes.HalloweenCastleDuckulaBuildingCash;
   import Classes.HalloweenHauntedHouseBuilding;
   import Classes.HarvestStorageBuilding;
   import Classes.HolidayTreeStorage;
   import Classes.HomeGarageConstructionBuilding;
   import Classes.HorseStableBuilding;
   import Classes.HorseStableBuildingFinished;
   import Classes.InactiveFeatureBuilding;
   import Classes.InventoryCellar;
   import Classes.JapaneseBarnConstructionBuilding;
   import Classes.LandBundleUnlockFeatureTreasureConstructionBuilding;
   import Classes.LootableConsumableStorage;
   import Classes.LootableFixedFeatureBuilding;
   import Classes.MarketStallBuilding;
   import Classes.MoneyTree2017Building;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.MultiRewardTreasurePayerBundleConstructionBuilding;
   import Classes.MultiRewardTreasurePayerConstructionBuilding;
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.MysteryCrateBuilding;
   import Classes.MystreeNursery;
   import Classes.NurseryBuildingFinished;
   import Classes.NurseryConstructionBuilding;
   import Classes.NutcrackerTheater;
   import Classes.OrchardBuilding;
   import Classes.OrchardFeatureBuilding;
   import Classes.PigpenBuilding;
   import Classes.PigpenConstructionBuilding;
   import Classes.PotOfGold;
   import Classes.RewardCreditsBuilding;
   import Classes.RewardCreditsBuildingNonRedeeming;
   import Classes.RewardCreditsBuildingWithPresents;
   import Classes.RuntimeDrivenLootableFixedFeatureBuilding;
   import Classes.ScienceLab;
   import Classes.SheepPenConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.SweetValentine;
   import Classes.TheMaharajaStable;
   import Classes.TicketPartyBuilding;
   import Classes.TuscanWedding;
   import Classes.ValentinesBox;
   import Classes.WhiteWinterInnovationOpenUIOnClick;
   import Classes.WishingFountainFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class GMBuild extends GMObjectMove
   {
      
      protected var m_building:Building;
      
      protected var m_buildingType:String;
      
      protected var m_isHarvestable:Boolean = false;
      
      protected var m_storageClass:String;
      
      protected var m_className:String = null;
      
      protected var m_buildingSizeX:int = 1;
      
      protected var m_buildingSizeY:int = 1;
      
      protected var m_expansionLevel:int = 0;
      
      protected var m_buildingTypes:Array;
      
      public function GMBuild(buildingType:String, isGift:Boolean = false, buildingId:int = 0, shouldReOpenGift:Boolean = true, extraData:Object = null, currency:String = "")
      {
         var itemXML:XML = null;
         this.m_buildingTypes = [CraftingCottageBuilding,ChickenCoopBuilding,DairyFarmBuilding,HolidayTreeStorage,ValentinesBox,PotOfGold,EasterBasket,HaitiBackpack,HalloweenBasket,TuscanWedding,HorseStableBuilding,HorseStableBuildingFinished,NurseryBuildingFinished,MarketStallBuilding,FrenchChateauBuilding,NurseryConstructionBuilding,FeedTroughBuilding,BotanicalGardenCashBuilding,BotanicalGardenConstructionBuilding,BeehiveConstructionBuilding,HalloweenHauntedHouseBuilding,HalloweenCastleDuckulaBuilding,HalloweenCastleDuckulaBuildingCash,HarvestStorageBuilding,LootableConsumableStorage,StorageBuilding,Building,JapaneseBarnConstructionBuilding,GarageConstructionBuilding,HomeGarageConstructionBuilding,InventoryCellar,PigpenConstructionBuilding,PigpenBuilding,OrchardBuilding,OrchardFeatureBuilding,ArboretumBuilding,RewardCreditsBuilding,TicketPartyBuilding,RewardCreditsBuildingWithPresents,RewardCreditsBuildingNonRedeeming,FeatureBuilding,SheepPenConstructionBuilding,FixedFeatureBuilding,FarmVillageFactoryBuilding
         ,FishermansCoveBuilding,LootableFixedFeatureBuilding,RuntimeDrivenLootableFixedFeatureBuilding,AnimalWildlifePenConstructionBuilding,AnimalPetrunConstructionBuilding,AnimalBreedingPenConstructionBuilding,FixedConstructionBuilding,FixedTreasureConstructionBuilding,EverGrowingHarvestableBuilding,WishingFountainFeatureBuilding,MysteryCrateBuilding,MystreeNursery,NutcrackerTheater,MultiRewardTreasureConstructionBuilding,MultiRewardTreasurePayerConstructionBuilding,MultiRewardTreasurePayerBundleConstructionBuilding,MultiRewardTreasurePayerLandBundleConstructionBuilding,ContingencyBuildableBuilding,CupidStable,FrontierPiggies,DragonBreedingFeatureBuilding,MoneyTree2017Building,FlowerShackFeatureBuilding,InactiveFeatureBuilding,FatSantaBuilding,TheMaharajaStable,FVStudio,ScienceLab,AdventurersCamp,FeatureBuildingOpenUIOnClick,BrazilInnovationOpenUIOnClick,DragonValleyInnovationOpenUIOnClick,WhiteWinterInnovationOpenUIOnClick,FurryAndFabulous,AthleticContest,AlaskaInnovationOpenUIOnClick,CocowonderlandInnovationOpenUIOnClick
         ,SweetValentine,CarnivalParades,LandBundleUnlockFeatureTreasureConstructionBuilding];
         this.m_buildingType = buildingType;
         m_isGift = isGift;
         m_storedOrigin = buildingId;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingType);
         var result:int = 1;
         if(item)
         {
            this.m_buildingSizeX = item.sizeX;
            this.m_buildingSizeY = item.sizeY;
            this.m_isHarvestable = item.hasContentTypes;
            this.m_storageClass = item.storageClass;
            this.m_className = item.className;
         }
         m_cid = buildingId;
         if(Boolean(extraData) && Boolean(extraData.expansionLevel))
         {
            this.m_expansionLevel = extraData.expansionLevel;
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(item.hasPropertyInDataSource("initialExpansionLevel"))
            {
               this.m_expansionLevel = item.getIntFromDataSource("initialExpansionLevel");
            }
         }
         else
         {
            itemXML = item.xml;
            if(itemXML.hasOwnProperty("initialExpansionLevel"))
            {
               this.m_expansionLevel = int(itemXML.initialExpansionLevel);
            }
         }
         this.initializeSelectedObject();
         super(this.m_building,null,isGift,shouldReOpenGift,false,currency);
         m_objectStartPos = null;
      }
      
      protected function initializeSelectedObject() : void
      {
         this.m_building = this.getSelectedObjectClassInstance();
         this.m_building.gift = m_isGift;
         this.m_building.inventory = m_cid;
         if(this.m_building.hasOwnProperty("storageLevel"))
         {
            (this.m_building as StorageBuilding).storageLevel = this.m_expansionLevel;
         }
      }
      
      protected function getSelectedObjectClassInstance() : Building
      {
         var tempClass:Class = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingType);
         if(item.name != this.m_buildingType && item.getClassNameFromActiveData(this.m_buildingType) != "")
         {
            tempClass = getDefinitionByName("Classes." + item.getClassNameFromActiveData(this.m_buildingType)) as Class;
         }
         else if(item.className != "")
         {
            tempClass = getDefinitionByName("Classes." + item.className) as Class;
         }
         else
         {
            tempClass = Building;
         }
         return new tempClass(this.m_buildingType);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!this.m_building.getOuter())
         {
            m_highlightedPoint = getMouseTilePos();
            this.m_building.setOuter(Global.world);
            this.m_building.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var avatar:FarmAvatar = null;
         super.onMouseUp(event);
         if(Global.world.checkNumObjectLimit())
         {
            avatar = Global.selectedAvatar;
            if(Boolean(avatar) && Boolean(this.m_building) && m_objectPlacedSuccess)
            {
               this.m_building.build(m_currency);
               if(canMultiPlace())
               {
                  Global.world.addGameMode(this.getMultiPlaceGameMode());
               }
               else
               {
                  Global.world.addGameMode(new GMDefault());
               }
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
            Global.world.addGameMode(this);
         }
         return true;
      }
      
      override public function disableMode() : void
      {
         if(m_objectPlacedSuccess == false && m_objectStoredSuccess == false && m_objectStartPos == null)
         {
            Global.player.removeLimitedItem(this.m_buildingType);
         }
         super.disableMode();
      }
      
      public function get expansionLevel() : int
      {
         return this.m_expansionLevel;
      }
      
      public function set expansionLevel(storageLevel:int) : void
      {
         this.m_expansionLevel = this.expansionLevel;
      }
      
      protected function getMultiPlaceGameMode() : GameMode
      {
         return new GMBuild(this.m_buildingType,m_isGift,m_cid,false,{"expansionLevel":this.m_expansionLevel},m_currency);
      }
   }
}

