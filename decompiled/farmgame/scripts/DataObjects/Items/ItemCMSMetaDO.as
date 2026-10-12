package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemCMSMetaDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var objectId:Number;
      
      [XmlAttribute(§default§="-2147483648")]
      public var lastChange:Number;
      
      [XmlAttribute(§default§="-2147483648")]
      public var moduleId:int;
      
      [XmlAttribute]
      public var key:String;
      
      public function ItemCMSMetaDO()
      {
         super();
      }
   }
}

