package DataObjects.Items.CoreItems.HarvestableItems.Seed
{
   import DataObjects.BaseDataObject;
   
   public class ItemDonationDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var value:int;
      
      [XmlAttribute]
      public var defaultButton:Boolean;
      
      public function ItemDonationDO()
      {
         super();
      }
   }
}

