package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   import DataObjects.Items.ItemFriendRewardsDO;
   
   public class ItemRewardCreditsBuildingDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      public var creditItems:RewardCreditsBuildingCreditItemsDO;
      
      public var friendRewards:ItemFriendRewardsDO;
      
      public var trackerTypes:RewardCreditsBuildingTrackerTypesDO;
      
      public function ItemRewardCreditsBuildingDO()
      {
         super();
      }
   }
}

