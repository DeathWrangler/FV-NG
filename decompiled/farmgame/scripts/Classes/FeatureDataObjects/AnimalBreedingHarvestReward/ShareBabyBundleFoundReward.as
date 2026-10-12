package Classes.FeatureDataObjects.AnimalBreedingHarvestReward
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   
   public class ShareBabyBundleFoundReward implements IAnimalBreedingReward
   {
      
      private var m_rewardLink:String;
      
      private var m_owner:FeatureBuilding;
      
      private var m_lootTableName:String;
      
      private var m_bundleIndex:int;
      
      private var m_rewardName:String;
      
      private var m_rewardItem:FarmItem;
      
      public function ShareBabyBundleFoundReward(rawData:Object, owner:FeatureBuilding)
      {
         super();
         this.m_rewardLink = rawData.rewardLink;
         this.m_owner = owner;
         this.m_bundleIndex = rawData.shareBabyBundleIndex;
         this.m_lootTableName = rawData.lootTableName;
         this.m_rewardName = this.m_lootTableName.replace("_","_" + this.getBundleSizeType() + "_");
         if(rawData != null && rawData.rewardItem != null)
         {
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rawData.rewardItem);
         }
      }
      
      public function get forcePlaceGift() : Boolean
      {
         return false;
      }
      
      public function get dialogText() : String
      {
         var bodyKey:String = ZLocUtils.getExistingLocalizationKey("Dialogs",this.m_owner.bldgName + "_BabyFound_Body","AnimalBreedingGeneric_BabyFound_Body");
         return ZLocUtils.t("Dialogs",bodyKey,{
            "buildingName":ZLocUtils.tk_pk(this.m_owner.getItemFriendlyName()),
            "shareBabyBundle":this.getBabyBundleFriendlyName()
         });
      }
      
      public function get rewardItem() : FarmItem
      {
         return this.m_rewardItem;
      }
      
      public function get imageUrl() : String
      {
         return Global.getAssetURL("assets/newsfeed/" + this.rewardName + ".png");
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      public function get giftBoxReward() : String
      {
         return null;
      }
      
      public function get rewardName() : String
      {
         return this.m_rewardName;
      }
      
      public function get feedType() : String
      {
         return this.m_owner.bldgName + "ShareBabiesFound";
      }
      
      public function get feedBundleData() : Object
      {
         return {
            "genus":this.m_rewardName,
            "reward_link":this.m_rewardLink,
            "buildingName":this.m_owner.bldgName,
            "item":this.getBabyBundleFriendlyName(),
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardLink,
               "src":this.imageUrl
            }]
         };
      }
      
      private function getBundleSizeType() : String
      {
         var result:String = null;
         switch(this.m_bundleIndex)
         {
            case 0:
               result = "tinybasket";
               break;
            case 1:
               result = "smallbasket";
               break;
            case 2:
               result = "mediumbasket";
               break;
            case 3:
               result = "largebasket";
               break;
            case 4:
               result = "grandbasket";
               break;
            default:
               result = "tinybasket";
         }
         return result;
      }
      
      private function getBabyBundleFriendlyName() : String
      {
         return ZLocUtils.t("Dialogs",this.m_owner.bldgName + "_Bundle_" + this.m_bundleIndex,{"adjective":this.getAdjective()});
      }
      
      private function getAdjective() : String
      {
         return ZLocUtils.t("Dialogs",this.m_lootTableName + "_adjective");
      }
   }
}

