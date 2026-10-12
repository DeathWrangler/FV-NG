package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class RewardCreditsBuildingCreditItemsDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var checkCreditItemDates:Boolean;
      
      public var creditItem:Array;
      
      public function RewardCreditsBuildingCreditItemsDO()
      {
         super();
      }
   }
}

