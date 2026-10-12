package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class RewardCreditsBuildingCreditItemDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var code:String;
      
      [XmlAttribute]
      public var name:String;
      
      public function RewardCreditsBuildingCreditItemDO()
      {
         super();
      }
   }
}

