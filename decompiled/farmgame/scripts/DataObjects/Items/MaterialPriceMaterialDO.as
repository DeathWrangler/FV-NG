package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class MaterialPriceMaterialDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var quantity:int;
      
      public function MaterialPriceMaterialDO()
      {
         super();
      }
   }
}

