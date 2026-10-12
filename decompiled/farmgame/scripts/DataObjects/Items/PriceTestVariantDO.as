package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class PriceTestVariantDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var number:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var cash:int;
      
      public function PriceTestVariantDO()
      {
         super();
      }
   }
}

