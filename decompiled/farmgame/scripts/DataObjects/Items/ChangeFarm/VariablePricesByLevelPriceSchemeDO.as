package DataObjects.Items.ChangeFarm
{
   import DataObjects.BaseDataObject;
   
   public class VariablePricesByLevelPriceSchemeDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var variant:int;
      
      public var levelScheme:Array;
      
      public function VariablePricesByLevelPriceSchemeDO()
      {
         super();
      }
   }
}

