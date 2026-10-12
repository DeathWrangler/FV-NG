package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemVariablePricingDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var base:int;
      
      [XmlAttribute]
      public var variable:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var linearCoef:Number;
      
      [XmlAttribute]
      public var variableSubtype:String;
      
      public var prereq:Array;
      
      public function ItemVariablePricingDO()
      {
         super();
      }
   }
}

