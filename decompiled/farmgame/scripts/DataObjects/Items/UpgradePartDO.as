package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class UpgradePartDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var need:int;
      
      [XmlAttribute]
      public var dontOverrideReward:Boolean;
      
      [XmlAttribute]
      public var requestType:String;
      
      public function UpgradePartDO()
      {
         super();
      }
   }
}

