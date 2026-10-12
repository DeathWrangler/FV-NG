package DataObjects.Items.Consumable
{
   import DataObjects.BaseDataObject;
   
   public class ItemToasterOnConsumeDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var enabled:Boolean;
      
      public function ItemToasterOnConsumeDO()
      {
         super();
      }
   }
}

