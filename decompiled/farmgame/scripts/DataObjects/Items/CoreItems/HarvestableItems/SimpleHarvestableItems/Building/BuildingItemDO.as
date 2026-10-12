package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.SimpleHarvestableItemDO;
   
   public class BuildingItemDO extends SimpleHarvestableItemDO
   {
      
      [XmlAttribute]
      public var bundle:Boolean;
      
      [XmlAttribute]
      public var constructionUI:String;
      
      [XmlAttribute]
      public var craftType:String;
      
      [XmlAttribute]
      public var disableBuildOnPlace:Boolean;
      
      [XmlAttribute]
      public var fv_perf_multiple_buildable_swfs:Boolean;
      
      [XmlAttribute]
      public var giftlimitcheck:Boolean;
      
      [XmlAttribute]
      public var levelUpDisplay:Boolean;
      
      [XmlAttribute]
      public var paint:Boolean;
      
      [XmlAttribute]
      public var paintable:Boolean;
      
      [XmlAttribute]
      public var showExpansionOnBuild:Boolean;
      
      [XmlAttribute]
      public var showFullOnce:Boolean;
      
      [XmlAttribute]
      public var tiered:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var totalTiers:int;
      
      [XmlAttribute]
      public var unlockTreasures:Boolean;
      
      public var allowMultipleConstructed:Boolean;
      
      public var basketClass:String;
      
      public var breedingBuilding:String;
      
      public var capacity:int;
      
      public var completeFeed:String;
      
      public var completeRewardDialog:String;
      
      public var completeRewardDialogBackground:String;
      
      public var completeRewardItem:String;
      
      public var contentItemClassName:String;
      
      public var dairyFarmType:String;
      
      public var dialogs:ItemDialogsDO;
      
      public var expansion:ItemExpansionDO;
      
      public var featureName:String;
      
      public var firstPresent:String;
      
      public var frameName:String;
      
      public var freeConsumableOnFirstPlace:String;
      
      public var freeConsumableOnFirstPlaceQty:int;
      
      public var freeGift:ItemFreeGiftDO;
      
      public var freeItemOnFirstPlace:String;
      
      public var frictionlessBuy:ItemFrictionlessBuyDO;
      
      public var friendRequestLimit:int;
      
      public var friendRewardClass:String;
      
      public var getRewardsFromLootTable:Boolean;
      
      public var giftNotice:String;
      
      public var giftpageExperiment:String;
      
      public var hoverContextMenu:ItemHoverContextMenuDO;
      
      public var imageSet:ItemImageSetDO;
      
      public var limitedEndDate:String;
      
      public var limitPrereq:String;
      
      public var lookInsideOnFinishPlace:Boolean;
      
      public var matsAllowBulkBuy:Boolean;
      
      public var neighborLookInside:ItemNeighborLookInsideDO;
      
      public var paintColor:String;
      
      public var rewardCreditsBuilding:ItemRewardCreditsBuildingDO;
      
      public var shareFeedFriendReward:String;
      
      public var shareFeedHostRewardItem:String;
      
      public var shareFeedHostRewardLootTable:String;
      
      public var shareFeedRewardItem:String;
      
      public var shareFeedRewardLootTable:String;
      
      public var shareFriendReward:String;
      
      public var smartSystemTuning:String;
      
      public var storageLimitedEnd:String;
      
      public var storageSize:int;
      
      public var stuffingPrevention:Boolean;
      
      public var stuffingPreventionPrereq:String;
      
      public var substituteItem:String;
      
      public var tiers:ItemTiersDO;
      
      public var transformByLocationTable:String;
      
      public var tutorialImagePrefix:ItemTutorialImagePrefixDO;
      
      public var partRequestType:Array;
      
      public var upgrade:Array;
      
      public function BuildingItemDO()
      {
         super();
      }
   }
}

