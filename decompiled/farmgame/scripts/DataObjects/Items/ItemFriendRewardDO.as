package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemFriendRewardDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var rewardName:String;
      
      [XmlAttribute]
      public var overrideItem:String;
      
      [XmlAttribute]
      public var forceHarvestMatch:Boolean;
      
      public function ItemFriendRewardDO()
      {
         super();
      }
   }
}

