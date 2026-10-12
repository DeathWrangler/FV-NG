package DataObjects.Items.CoreItems.HarvestableItems.Seed
{
   import DataObjects.Items.CoreItems.HarvestableItems.HarvestableItemDO;
   
   public class SeedItemDO extends HarvestableItemDO
   {
      
      [XmlAttribute]
      public var dynamicIcon:Boolean;
      
      [XmlAttribute]
      public var gift:String;
      
      [XmlAttribute]
      public var isHybrid:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var licenseCost:int;
      
      [XmlAttribute]
      public var pollination:Boolean;
      
      [XmlAttribute]
      public var producesItem:Boolean;
      
      [XmlAttribute]
      public var promptFeedOnPlant:Boolean;
      
      [XmlAttribute]
      public var sponsor:String;
      
      public var donationCurrency:String;
      
      public var giftableItem:String;
      
      public var largeCropChance:Number;
      
      public var largeCropXp:int;
      
      public var limitedLocale:String;
      
      public var marketInfoURL:String;
      
      public var organicBushelItemCode:String;
      
      public var organicCert:ItemOrganicCertDO;
      
      public var plantXp:int;
      
      public var sweetSeedsCost:int;
      
      public var unlockCost:int;
      
      public var xpYield:int;
      
      public var donation:Array;
      
      public function SeedItemDO()
      {
         super();
      }
   }
}

