package Classes.FeatureDataObjects.AnimalBreedingHarvestReward
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.FeatureManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class BabyFoundReward implements IAnimalBreedingReward
   {
      
      private var m_rewardItem:FarmItem;
      
      private var m_rewardLink:String;
      
      private var m_owner:FeatureBuilding;
      
      private var m_coinYield:int;
      
      public function BabyFoundReward(rawData:Object, owner:FeatureBuilding, coinYield:int)
      {
         super();
         this.m_rewardLink = rawData.rewardLink;
         this.m_owner = owner;
         this.m_coinYield = coinYield;
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rawData.rewardItem);
      }
      
      public function get forcePlaceGift() : Boolean
      {
         return true;
      }
      
      public function get dialogText() : String
      {
         var bodyKey:String = ZLocUtils.getExistingLocalizationKey("Dialogs",this.m_owner.bldgName + "_BabyFound_Body","AnimalBreedingGeneric_BabyFound_Body");
         return ZLocUtils.t("Dialogs",bodyKey,{
            "buildingName":ZLocUtils.tk_pk(this.m_owner.getItemFriendlyName()),
            "coinsYield":this.m_coinYield,
            "rarity":this.getRarityString(),
            "rewardName":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName)
         });
      }
      
      public function get imageUrl() : String
      {
         return this.m_rewardItem.icon;
      }
      
      public function get rewardItem() : FarmItem
      {
         return this.m_rewardItem;
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
         return this.m_owner.bldgName + "MysteryBabyFound";
      }
      
      public function get feedBundleData() : Object
      {
         return {
            "reward_link":this.rewardLink,
            "buildingName":this.m_owner.getItemFriendlyName(),
            "rarity":this.getRarityString(),
            "item":this.m_rewardItem.friendlyTitle,
            "images":[{
               "href":"{SN_APP_URL}" + this.rewardLink,
               "src":this.imageUrl
            }]
         };
      }
      
      private function getRarityString() : String
      {
         var rareBabyName:String = null;
         var buildingHarvesterData:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            rareBabyName = this.m_owner.getItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME).getString("rewardItemRare");
         }
         else
         {
            buildingHarvesterData = this.m_owner.getItem().getFeatureXMLByName("harvester");
            rareBabyName = buildingHarvesterData.rewardItemRare;
         }
         var rarity:String = "";
         if(this.m_rewardItem.name == rareBabyName)
         {
            rarity = ZLocUtils.t("Collections","Rare") + " ";
         }
         return rarity;
      }
   }
}

