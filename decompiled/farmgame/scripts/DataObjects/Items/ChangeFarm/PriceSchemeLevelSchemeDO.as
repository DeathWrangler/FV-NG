package DataObjects.Items.ChangeFarm
{
   import DataObjects.BaseDataObject;
   
   public class PriceSchemeLevelSchemeDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var topLevel:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var price:int;
      
      public function PriceSchemeLevelSchemeDO()
      {
         super();
      }
   }
}

