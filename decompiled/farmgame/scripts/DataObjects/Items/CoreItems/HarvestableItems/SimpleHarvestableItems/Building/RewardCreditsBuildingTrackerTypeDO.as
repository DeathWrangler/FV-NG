package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class RewardCreditsBuildingTrackerTypeDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var key:String;
      
      [XmlAttribute]
      public var value:String;
      
      public function RewardCreditsBuildingTrackerTypeDO()
      {
         super();
      }
   }
}

