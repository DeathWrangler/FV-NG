package Classes.FeatureDataObjects.AnimalBreedingHarvestReward
{
   import Classes.OrchardBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   
   public class OrchardBuildingReward implements IAnimalBreedingReward
   {
      
      private var m_rewardItem:FarmItem;
      
      private var m_rewardLink:String;
      
      private var m_owner:OrchardBuilding;
      
      private var m_coinYield:int;
      
      private var m_harvestGroups:String;
      
      private var m_bundleID:String;
      
      public function OrchardBuildingReward(rawData:Object, owner:OrchardBuilding, coinYield:int, harvestGroups:String)
      {
         super();
         this.m_rewardLink = rawData.rewardLink;
         this.m_owner = owner;
         this.m_coinYield = coinYield;
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rawData.itemCode);
         this.m_harvestGroups = harvestGroups;
         this.m_bundleID = rawData.isSeed != null && Boolean(rawData.isSeed) ? OrchardBuilding.MYSTERY_SEED_FOUND_FEED_BUNDLE_ID : OrchardBuilding.CONSOLATION_GIFT_BUNDLE_ID;
      }
      
      public function get forcePlaceGift() : Boolean
      {
         return this.m_bundleID == OrchardBuilding.MYSTERY_SEED_FOUND_FEED_BUNDLE_ID;
      }
      
      public function get rewardItem() : FarmItem
      {
         return this.m_rewardItem;
      }
      
      public function get dialogText() : String
      {
         return ZLocUtils.t("Dialogs",this.m_bundleID == OrchardBuilding.CONSOLATION_GIFT_BUNDLE_ID ? "Orchard_FoundConsolationGift" : "Orchard_FoundMysterySeed",{
            "coinQuantity":this.m_coinYield,
            "harvestYieldsGroup":this.m_harvestGroups
         });
      }
      
      public function get imageUrl() : String
      {
         return this.m_rewardItem.icon;
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      public function get giftBoxReward() : String
      {
         return this.m_rewardItem.name;
      }
      
      public function get rewardName() : String
      {
         return this.m_rewardItem.name;
      }
      
      public function get feedType() : String
      {
         return this.m_bundleID;
      }
      
      public function get feedBundleData() : Object
      {
         var bundleData:Object = new Object();
         bundleData.sendingUser = Global.player.firstName;
         bundleData.rewardLink = this.m_rewardLink;
         bundleData.images = [{
            "src":this.m_rewardItem.newsfeed,
            "href":"{SN_APP_URL}" + this.m_rewardLink
         }];
         return bundleData;
      }
   }
}

