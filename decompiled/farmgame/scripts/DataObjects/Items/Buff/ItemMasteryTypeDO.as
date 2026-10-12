package DataObjects.Items.Buff
{
   import DataObjects.BaseDataObject;
   
   public class ItemMasteryTypeDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      public function ItemMasteryTypeDO()
      {
         super();
      }
   }
}

