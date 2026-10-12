package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemUpgradeDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var level:int;
      
      [XmlAttribute]
      public var prereq:String;
      
      [XmlAttribute]
      public var infinite:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var capacity:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var matsNeeded:int;
      
      [XmlAttribute]
      public var runtimeGate:String;
      
      [XmlAttribute]
      public var experimentGate:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var experimentVariant:int;
      
      [XmlAttribute]
      public var rewardItem:String;
      
      public var award:UpgradeAwardDO;
      
      public var part:Array;
      
      public function ItemUpgradeDO()
      {
         super();
      }
   }
}

