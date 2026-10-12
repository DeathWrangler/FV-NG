package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class ExpandPriceTestVariantDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var number:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var multiplier:Number;
      
      public function ExpandPriceTestVariantDO()
      {
         super();
      }
   }
}

