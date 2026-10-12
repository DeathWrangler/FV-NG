package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemDialogDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var path:String;
      
      [XmlAttribute]
      public var bgPath:String;
      
      [XmlAttribute]
      public var bgImage:String;
      
      [XmlAttribute]
      public var npcUrl:String;
      
      [XmlAttribute]
      public var is4D:Boolean;
      
      [XmlAttribute]
      public var whatIsThisImagePrefix:String;
      
      [XmlAttribute]
      public var harvestLootKey:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var teaserPrizeAnimationDelaySeconds:int;
      
      public function ItemDialogDO()
      {
         super();
      }
   }
}

