package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class UpgradeAwardDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var number:int;
      
      [XmlAttribute]
      public var dialog:String;
      
      [XmlAttribute]
      public var dialogBackground:String;
      
      [XmlAttribute]
      public var addToBuilding:Boolean;
      
      public function UpgradeAwardDO()
      {
         super();
      }
   }
}

