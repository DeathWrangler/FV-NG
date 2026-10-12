package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemFrictionlessBuyDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var activevar:int;
      
      public function ItemFrictionlessBuyDO()
      {
         super();
      }
   }
}

