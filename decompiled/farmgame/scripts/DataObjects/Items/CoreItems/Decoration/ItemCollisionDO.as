package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class ItemCollisionDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      public var r:Array;
      
      public function ItemCollisionDO()
      {
         super();
      }
   }
}

