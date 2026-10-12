package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class VariablePricingPrereqDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var quantity:int;
      
      public function VariablePricingPrereqDO()
      {
         super();
      }
   }
}

