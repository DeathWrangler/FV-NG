package DataObjects.Items.CoreItems.HarvestableItems.Seed
{
   import DataObjects.BaseDataObject;
   
   public class ItemOrganicCertDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var orgCount:int;
      
      [XmlAttribute]
      public var orgReward:String;
      
      public function ItemOrganicCertDO()
      {
         super();
      }
   }
}

