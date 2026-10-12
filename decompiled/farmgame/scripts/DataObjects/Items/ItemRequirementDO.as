package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemRequirementDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var amount:int;
      
      [XmlAttribute]
      public var associatedBuilding:String;
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var code:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var level:int;
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var strict:Boolean;
      
      [XmlAttribute]
      public var checkWorld:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var quantity:int;
      
      public function ItemRequirementDO()
      {
         super();
      }
   }
}

