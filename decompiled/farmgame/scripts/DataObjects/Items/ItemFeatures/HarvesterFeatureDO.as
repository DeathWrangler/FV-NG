package DataObjects.Items.ItemFeatures
{
   import DataObjects.Items.ItemFriendRewardsDO;
   
   public class HarvesterFeatureDO extends ItemFeatureDO
   {
      
      public var buildingSurfacingKeyword:String;
      
      public var canHarvest:FeatureCanHarvestDO;
      
      public var chance:int;
      
      public var friendRewards:ItemFriendRewardsDO;
      
      public var growTime:Number;
      
      public var harvestArrowOffset:FeatureHarvestArrowOffsetDO;
      
      public var harvestType:String;
      
      public var harvestWindow:FeatureHarvestWindowDO;
      
      public var ignoreLevelOnVisit:Boolean;
      
      public var isClone:Boolean;
      
      public var limitedCoinCurrency:String;
      
      public var limitedCoinYield:int;
      
      public var limitedEndNeighbor:String;
      
      public var limitedEndOwn:String;
      
      public var limitedHarvestTime:Number;
      
      public var limitedStartNeighbor:String;
      
      public var limitedStartOwn:String;
      
      public var maxCountForOdds:int;
      
      public var needItemsForHarvest:Boolean;
      
      public var neighborHarvestReward:FeatureHarvestRewardDO;
      
      public var outOfDateGoldHarvest:int;
      
      public var overrideShareReward:FeatureOverrideShareRewardDO;
      
      public var postHarvestActions:FeaturePostHarvestActionsDO;
      
      public var rewardBase:int;
      
      public var rewardCanGiftboxEvict:Boolean;
      
      public var rewardHarvestDialog:String;
      
      public var rewardHarvestDialogClass:FeatureRewardHarvestDialogClassDO;
      
      public var rewardItemCommon:String;
      
      public var rewardItemNonBaby:String;
      
      public var rewardItemRare:String;
      
      public var rewardMultiplier:String;
      
      public var rewardMultiplierOverride:int;
      
      public var rewardType:String;
      
      public var rollSettingsPrefix:String;
      
      public var shareBabyBundles:FeatureShareBabyBundlesDO;
      
      public var surfaceBasket:Boolean;
      
      public var type:String;
      
      public var harvestReward:Array;
      
      public var rewards:Array;
      
      public function HarvesterFeatureDO()
      {
         super();
      }
   }
}

