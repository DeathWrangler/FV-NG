package Classes.FeatureDataObjects.AnimalBreedingHarvestReward
{
   import Classes.ZItem.FarmItem;
   
   public interface IAnimalBreedingReward
   {
      
      function get forcePlaceGift() : Boolean;
      
      function get dialogText() : String;
      
      function get rewardItem() : FarmItem;
      
      function get imageUrl() : String;
      
      function get rewardLink() : String;
      
      function get giftBoxReward() : String;
      
      function get rewardName() : String;
      
      function get feedType() : String;
      
      function get feedBundleData() : Object;
   }
}

