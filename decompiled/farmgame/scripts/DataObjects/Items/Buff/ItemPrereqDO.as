package DataObjects.Items.Buff
{
   import DataObjects.BaseDataObject;
   
   public class ItemPrereqDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute]
      public var variant:String;
      
      public function ItemPrereqDO()
      {
         super();
      }
   }
}

