package Classes.FeatureDataObjects.AnimalBreedingHarvestReward
{
   import Classes.FeatureBuilding;
   import Classes.HarvestYieldsGroup;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   
   public class BabyNotFoundReward implements IAnimalBreedingReward
   {
      
      private static const DEFAULT_REWARD:String = "coins";
      
      private var m_rewardItem:FarmItem;
      
      private var m_rewardLink:String;
      
      private var m_owner:FeatureBuilding;
      
      private var m_coinYield:int;
      
      private var m_harvestYieldsGroup:HarvestYieldsGroup;
      
      public function BabyNotFoundReward(rawData:Object, owner:FeatureBuilding, coinYield:int, harvestYieldsGroup:HarvestYieldsGroup)
      {
         super();
         this.m_rewardLink = rawData.rewardLink;
         this.m_owner = owner;
         this.m_coinYield = coinYield;
         if(rawData.rewardItem)
         {
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rawData.rewardItem);
         }
         this.m_harvestYieldsGroup = harvestYieldsGroup;
      }
      
      public function get forcePlaceGift() : Boolean
      {
         return false;
      }
      
      public function get dialogText() : String
      {
         var bodyKey:String = ZLocUtils.getExistingLocalizationKey("Dialogs",this.m_owner.bldgName + "_BabyNotFound_Body","AnimalBreedingGeneric_BabyNotFound_Body");
         var rewardItemName:String = this.giftBoxReward;
         var rewardItemFriendlyName:String = rewardItemName ? ZLocUtils.tk_pk_asTitle("Items:" + rewardItemName + "_friendlyName") : "";
         var prependedStatus:String = "";
         if(this.m_harvestYieldsGroup != null)
         {
            prependedStatus = this.m_harvestYieldsGroup.getStatus();
         }
         return ZLocUtils.t("Dialogs",bodyKey,{
            "buildingName":ZLocUtils.tk_pk(this.m_owner.getItemFriendlyName()),
            "harvestYieldsGroup":prependedStatus,
            "coinsYield":this.m_coinYield,
            "rewardItem":rewardItemFriendlyName,
            "rewardItem2":rewardItemFriendlyName
         });
      }
      
      public function get rewardItem() : FarmItem
      {
         return this.m_rewardItem;
      }
      
      public function get imageUrl() : String
      {
         return this.m_rewardItem ? this.m_rewardItem.icon : this.m_owner.getItem().icon;
      }
      
      public function get feedImageUrl() : String
      {
         return this.m_rewardItem ? this.m_rewardItem.newsfeed : this.m_owner.getItem().newsfeed;
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      public function get giftBoxReward() : String
      {
         return this.m_rewardItem ? this.m_rewardItem.name : null;
      }
      
      public function get rewardName() : String
      {
         return this.m_rewardItem ? this.m_rewardItem.name : DEFAULT_REWARD;
      }
      
      public function get feedType() : String
      {
         return this.m_owner.bldgName + "MysteryBabyNotFound";
      }
      
      public function get feedBundleData() : Object
      {
         var ownerBldgName:String = this.m_owner.getItem().friendlyTitle;
         return {
            "reward_link":this.rewardLink,
            "buildingName":ownerBldgName,
            "images":[{
               "href":"{SN_APP_URL}" + this.rewardLink,
               "src":this.feedImageUrl
            }]
         };
      }
   }
}

