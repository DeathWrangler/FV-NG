package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemHarvestYieldDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var yield:int;
      
      [XmlAttribute]
      public var unit:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var value:int;
      
      public function ItemHarvestYieldDO()
      {
         super();
      }
   }
}

