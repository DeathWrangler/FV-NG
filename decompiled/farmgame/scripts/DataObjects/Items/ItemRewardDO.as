package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemRewardDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var actionType:String;
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var unit:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute]
      public var licenseType:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var quantity:int;
      
      [XmlAttribute]
      public var feature:String;
      
      [XmlAttribute]
      public var option:String;
      
      public function ItemRewardDO()
      {
         super();
      }
   }
}

