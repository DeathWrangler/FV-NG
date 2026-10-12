package DataObjects
{
   import DataObjects.Items.*;
   import DataObjects.Items.Buff.*;
   import DataObjects.Items.Bushel.*;
   import DataObjects.Items.ChangeFarm.*;
   import DataObjects.Items.Consumable.*;
   import DataObjects.Items.CoreItems.*;
   import DataObjects.Items.CoreItems.Decoration.*;
   import DataObjects.Items.CoreItems.HarvestableItems.*;
   import DataObjects.Items.CoreItems.HarvestableItems.Seed.*;
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.*;
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Animal.*;
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Bloom.*;
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.*;
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Tree.*;
   import DataObjects.Items.Crafted.*;
   import DataObjects.Items.Fuel.*;
   import DataObjects.Items.ItemBuff.*;
   import DataObjects.Items.ItemFeatures.*;
   import DataObjects.Items.Vehicle.*;
   import flash.net.registerClassAlias;
   
   public class DataObjectsRegistrar
   {
      
      private static var itemTypesClassHash:Object = null;
      
      public function DataObjectsRegistrar()
      {
         super();
      }
      
      private static function populateTypesClassHash() : void
      {
         if(itemTypesClassHash == null)
         {
            itemTypesClassHash = new Object();
            itemTypesClassHash.animal = AnimalItemDO;
            itemTypesClassHash.bloom = BloomItemDO;
            itemTypesClassHash.buff = BuffItemDO;
            itemTypesClassHash.building = BuildingItemDO;
            itemTypesClassHash.bushel = BushelItemDO;
            itemTypesClassHash.change_farm = ChangeFarmItemDO;
            itemTypesClassHash.consumable = ConsumableItemDO;
            itemTypesClassHash.crafted = CraftedItemDO;
            itemTypesClassHash.decoration = DecorationItemDO;
            itemTypesClassHash.fuel = FuelItemDO;
            itemTypesClassHash.itembuff = ItemBuffItemDO;
            itemTypesClassHash.seed = SeedItemDO;
            itemTypesClassHash.tree = TreeItemDO;
            itemTypesClassHash.vehicle = VehicleItemDO;
         }
      }
      
      public static function getItemClassByType(param1:String) : Class
      {
         populateTypesClassHash();
         var _loc2_:Class = BaseItemDO;
         if(itemTypesClassHash.hasOwnProperty(param1))
         {
            _loc2_ = itemTypesClassHash[param1];
         }
         return _loc2_;
      }
      
      public static function registerAll() : void
      {
         registerClassAlias("DataObjects.BaseDataObject",BaseDataObject);
         registerClassAlias("DataObjects.Items.BaseItemDO",BaseItemDO);
         registerClassAlias("DataObjects.Items.ComponentBuildingTypeDO",ComponentBuildingTypeDO);
         registerClassAlias("DataObjects.Items.ItemCMSMetaDO",ItemCMSMetaDO);
         registerClassAlias("DataObjects.Items.ItemComponentDO",ItemComponentDO);
         registerClassAlias("DataObjects.Items.ItemDefaultItemDO",ItemDefaultItemDO);
         registerClassAlias("DataObjects.Items.ItemExtraMenuItemDO",ItemExtraMenuItemDO);
         registerClassAlias("DataObjects.Items.ItemFriendRewardDO",ItemFriendRewardDO);
         registerClassAlias("DataObjects.Items.ItemFriendRewardsDO",ItemFriendRewardsDO);
         registerClassAlias("DataObjects.Items.ItemImageDO",ItemImageDO);
         registerClassAlias("DataObjects.Items.ItemItemPackageDO",ItemItemPackageDO);
         registerClassAlias("DataObjects.Items.ItemKeywordDO",ItemKeywordDO);
         registerClassAlias("DataObjects.Items.ItemMarketEntriesDO",ItemMarketEntriesDO);
         registerClassAlias("DataObjects.Items.ItemMarketEntryDO",ItemMarketEntryDO);
         registerClassAlias("DataObjects.Items.ItemMaterialPriceDO",ItemMaterialPriceDO);
         registerClassAlias("DataObjects.Items.ItemPreCommitDataDO",ItemPreCommitDataDO);
         registerClassAlias("DataObjects.Items.ItemPriceTestDO",ItemPriceTestDO);
         registerClassAlias("DataObjects.Items.ItemRequirementDO",ItemRequirementDO);
         registerClassAlias("DataObjects.Items.ItemRequirementsDO",ItemRequirementsDO);
         registerClassAlias("DataObjects.Items.LandBundlesDO",LandBundlesDO);
         registerClassAlias("DataObjects.Items.LandBundleDO",LandBundleDO);
         registerClassAlias("DataObjects.Items.ItemRewardDO",ItemRewardDO);
         registerClassAlias("DataObjects.Items.ItemRewardsDO",ItemRewardsDO);
         registerClassAlias("DataObjects.Items.ItemSoxDO",ItemSoxDO);
         registerClassAlias("DataObjects.Items.ItemStorageTypeDO",ItemStorageTypeDO);
         registerClassAlias("DataObjects.Items.ItemTargetQuestDO",ItemTargetQuestDO);
         registerClassAlias("DataObjects.Items.ItemTerrainAssetsDO",ItemTerrainAssetsDO);
         registerClassAlias("DataObjects.Items.ItemTerrainDO",ItemTerrainDO);
         registerClassAlias("DataObjects.Items.ItemTerrainSetDO",ItemTerrainSetDO);
         registerClassAlias("DataObjects.Items.ItemUpgradeDO",ItemUpgradeDO);
         registerClassAlias("DataObjects.Items.ItemVariablePricingDO",ItemVariablePricingDO);
         registerClassAlias("DataObjects.Items.MaterialPriceMaterialDO",MaterialPriceMaterialDO);
         registerClassAlias("DataObjects.Items.PriceTestVariantDO",PriceTestVariantDO);
         registerClassAlias("DataObjects.Items.UpgradePartDO",UpgradePartDO);
         registerClassAlias("DataObjects.Items.UpgradeAwardDO",UpgradeAwardDO);
         registerClassAlias("DataObjects.Items.VariablePricingPrereqDO",VariablePricingPrereqDO);
         registerClassAlias("DataObjects.Items.Buff.BuffItemDO",BuffItemDO);
         registerClassAlias("DataObjects.Items.Buff.ItemMasteryTypeDO",ItemMasteryTypeDO);
         registerClassAlias("DataObjects.Items.Buff.ItemMasteryTypesDO",ItemMasteryTypesDO);
         registerClassAlias("DataObjects.Items.Buff.ItemPrereqDO",ItemPrereqDO);
         registerClassAlias("DataObjects.Items.Buff.ItemPrereqsDO",ItemPrereqsDO);
         registerClassAlias("DataObjects.Items.Bushel.BusheltemDO",BushelItemDO);
         registerClassAlias("DataObjects.Items.ChangeFarm.ChangeFarmItemDO",ChangeFarmItemDO);
         registerClassAlias("DataObjects.Items.ChangeFarm.ItemVariablePricesByLevelDO",ItemVariablePricesByLevelDO);
         registerClassAlias("DataObjects.Items.ChangeFarm.PriceSchemeLevelSchemeDO",PriceSchemeLevelSchemeDO);
         registerClassAlias("DataObjects.Items.ChangeFarm.VariablePricesByLevelPriceSchemeDO",VariablePricesByLevelPriceSchemeDO);
         registerClassAlias("DataObjects.Items.Consumable.ConsumableItemDO",ConsumableItemDO);
         registerClassAlias("DataObjects.Items.Consumable.ItemToasterOnConsumeDO",ItemToasterOnConsumeDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemAltGraphicDO",ItemAltGraphicDO);
         registerClassAlias("DataObjects.Items.CoreItems.CoreItemDO",CoreItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.GeoIPExcludeAreaDO",GeoIPExcludeAreaDO);
         registerClassAlias("DataObjects.Items.CoreItems.GeoIPIncludeAreaDO",GeoIPIncludeAreaDO);
         registerClassAlias("DataObjects.Items.CoreItems.GeoIPIncludeDataDO",GeoIPIncludeDataDO);
         registerClassAlias("DataObjects.Items.CoreItems.GiftSelectionSelectNoDO",GiftSelectionSelectNoDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemDepthOffsetDO",ItemDepthOffsetDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemGeoIPDO",ItemGeoIPDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemGiftSelectionDO",ItemGiftSelectionDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemHarvestYieldDO",ItemHarvestYieldDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemMasteryLevelDO",ItemMasteryLevelDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemRewardGiftDO",ItemRewardGiftDO);
         registerClassAlias("DataObjects.Items.CoreItems.ItemToolTipOffsetDO",ItemToolTipOffsetDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.CollisionRDO",CollisionRDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.DecorationItemDO",DecorationItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.HarvestSourcesSourceDO",HarvestSourcesSourceDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemCollisionDO",ItemCollisionDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemGemDO",ItemGemDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemHarvestSourcesDO",ItemHarvestSourcesDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemMetalDO",ItemMetalDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemPartDisplacementsDO",ItemPartDisplacementsDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemPartSizesDO",ItemPartSizesDO);
         registerClassAlias("DataObjects.Items.CoreItems.Decoration.ItemSwapCountdownDO",ItemSwapCountdownDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.HarvestableItemDO",HarvestableItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.Seed.ItemDonationDO",ItemDonationDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.Seed.ItemOrganicCertDO",ItemOrganicCertDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.Seed.SeedItemDO",SeedItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOEAreaDO",AOEAreaDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOEAreasDO",AOEAreasDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOEBonusDO",AOEBonusDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOEBonusesDO",AOEBonusesDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOETargetDO",AOETargetDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.AOETargetsDO",AOETargetsDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.ItemAOEDO",ItemAOEDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.ItemSoundDO",ItemSoundDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.ItemSoundsDO",ItemSoundsDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.ItemUGCTransformDO",ItemUGCTransformDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.ItemUGCTransformsDO",ItemUGCTransformsDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.SimpleHarvestableItemDO",SimpleHarvestableItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Animal.AnimalItemDO",AnimalItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Bloom.BloomItemDO",BloomItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.BuildingItemDO",BuildingItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemDialogDO",ItemDialogDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemDialogsDO",ItemDialogsDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemExpansionDO",ItemExpansionDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemFreeGiftDO",ItemFreeGiftDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemFrictionlessBuyDO",ItemFrictionlessBuyDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemHoverContextMenuDO",ItemHoverContextMenuDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemImageSetDO",ItemImageSetDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemNeighborLookInsideDO",ItemNeighborLookInsideDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemPartRequestTypeDO",ItemPartRequestTypeDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemRewardCreditsBuildingDO",ItemRewardCreditsBuildingDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemTierDO",ItemTierDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemTiersDO",ItemTiersDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.ItemTutorialImagePrefixDO",ItemTutorialImagePrefixDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.PartRequestTypeRequestDO",PartRequestTypeRequestDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.RewardCreditsBuildingCreditItemDO",RewardCreditsBuildingCreditItemDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.RewardCreditsBuildingCreditItemsDO",RewardCreditsBuildingCreditItemsDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.RewardCreditsBuildingTrackerTypeDO",RewardCreditsBuildingTrackerTypeDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building.RewardCreditsBuildingTrackerTypesDO",RewardCreditsBuildingTrackerTypesDO);
         registerClassAlias("DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Tree.TreeItemDO",TreeItemDO);
         registerClassAlias("DataObjects.Items.Crafted.CraftedItemDO",CraftedItemDO);
         registerClassAlias("DataObjects.Items.Fuel.FuelItemDO",FuelItemDO);
         registerClassAlias("DataObjects.Items.ItemBuff.ItemBuffItemDO",ItemBuffItemDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ArrowIndicatorFeatureDO",ArrowIndicatorFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.BuildingCompleteFeatureDO",BuildingCompleteFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.BuildingReadyFeatureDO",BuildingReadyFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ContaineeManagerFeatureDO",ContaineeManagerFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ContextMenuFeatureDO",ContextMenuFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ExpandFeatureDO",ExpandFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ExpandPriceTestVariantDO",ExpandPriceTestVariantDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ExtraDataStateFeatureDO",ExtraDataStateFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureAwardExperimentDO",FeatureAwardExperimentDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureCanHarvestDO",FeatureCanHarvestDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureContaineePartDO",FeatureContaineePartDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureDialogDO",FeatureDialogDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureExpandPriceTestDO",FeatureExpandPriceTestDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureFrequencyDO",FeatureFrequencyDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureHarvestArrowOffsetDO",FeatureHarvestArrowOffsetDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureHarvestRewardDO",FeatureHarvestRewardDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureHarvestWindowDO",FeatureHarvestWindowDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureImageProgressionObjectDO",FeatureImageProgressionObjectDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureInfiniteUpgradeDataDO",FeatureInfiniteUpgradeDataDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureLevelDO",FeatureLevelDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureLevelPricingDO",FeatureLevelPricingDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureLevelsDO",FeatureLevelsDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureMenuItemDO",FeatureMenuItemDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureOverrideShareRewardDO",FeatureOverrideShareRewardDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeaturePostHarvestActionDO",FeaturePostHarvestActionDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeaturePostHarvestActionsDO",FeaturePostHarvestActionsDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeaturePrereqDO",FeaturePrereqDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeaturePrereqsDO",FeaturePrereqsDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureRenderObjectDO",FeatureRenderObjectDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureRewardDO",FeatureRewardDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureRewardHarvestDialogClassDO",FeatureRewardHarvestDialogClassDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureRewardsDO",FeatureRewardsDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureShareBabyBundlesDO",FeatureShareBabyBundlesDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureStageDO",FeatureStageDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureStagesDO",FeatureStagesDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureStateDO",FeatureStateDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureTextRenderFieldDO",FeatureTextRenderFieldDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureTokenDO",FeatureTokenDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureTutorialDO",FeatureTutorialDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FeatureTutorialEventDO",FeatureTutorialEventDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.GrowableFeatureDO",GrowableFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.HarvesterFeatureDO",HarvesterFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ImageProgressionFeatureDO",ImageProgressionFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.InitializerFeatureDO",InitializerFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.InstantGrowFeatureDO",InstantGrowFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ItemFeatureDO",ItemFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ItemFeaturesDO",ItemFeaturesDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.LevelPricingLevelDO",LevelPricingLevelDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.MenuItemParamDO",MenuItemParamDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.NameOverrideFeatureDO",NameOverrideFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.NeighborActionFeatureDO",NeighborActionFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.TilePropPointDO",TilePropPointDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.TilePropPointsDO",TilePropPointsDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.RendererFeatureDO",RendererFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.ShareBabyBundlesBundleDO",ShareBabyBundlesBundleDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.Slotmachine2FeatureDO",Slotmachine2FeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.SlotmachineFeatureDO",SlotmachineFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.StorageFeatureDO",StorageFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.TooltipTextFeatureDO",TooltipTextFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.TutorialFeatureDO",TutorialFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.TutorialParamDO",TutorialParamDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.UpgraderFeatureDO",UpgraderFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.WithererFeatureDO",WithererFeatureDO);
         registerClassAlias("DataObjects.Items.ItemFeatures.FlowershackFeatureDO",FlowershackFeatureDO);
         registerClassAlias("DataObjects.Items.Vehicle.ItemEmbeddedImageDO",ItemEmbeddedImageDO);
         registerClassAlias("DataObjects.Items.Vehicle.ItemSimpleZAttributeTagsDO",ItemSimpleZAttributeTagsDO);
         registerClassAlias("DataObjects.Items.Vehicle.SimpleZAttributeTagsPlaneFlightGrantDO",SimpleZAttributeTagsPlaneFlightGrantDO);
         registerClassAlias("DataObjects.Items.Vehicle.VehicleItemDO",VehicleItemDO);
      }
   }
}

