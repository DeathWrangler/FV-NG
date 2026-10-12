package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   import DataObjects.Items.ItemFeatures.ItemFeaturesDO;
   
   public class BaseItemDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var actionBundle:String;
      
      [XmlAttribute]
      public var buildingName:String;
      
      [XmlAttribute]
      public var buyable:Boolean;
      
      [XmlAttribute(§default§="true")]
      public var canUseFromGiftBox:Boolean;
      
      [XmlAttribute]
      public var category:String;
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var code:String;
      
      [XmlAttribute]
      public var experiment:String;
      
      [XmlAttribute]
      public var experimentVariant:String;
      
      [XmlAttribute(§default§="true")]
      public var expires:Boolean;
      
      [XmlAttribute]
      public var gateCode:String;
      
      [XmlAttribute]
      public var giftable:Boolean;
      
      [XmlAttribute]
      public var giftAcceptPermission:String;
      
      [XmlAttribute]
      public var giftIgnoreLevelSort:Boolean;
      
      [XmlAttribute]
      public var giftSendPermission:String;
      
      [XmlAttribute]
      public var iphoneonly:Boolean;
      
      [XmlAttribute]
      public var license:String;
      
      [XmlAttribute]
      public var licenseUnlock:String;
      
      [XmlAttribute]
      public var logPurchase:Boolean;
      
      [XmlAttribute]
      public var market:String;
      
      [XmlAttribute]
      public var multiplace:Boolean;
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var organic:Boolean;
      
      [XmlAttribute]
      public var placeable:Boolean;
      
      [XmlAttribute]
      public var present:Boolean;
      
      [XmlAttribute]
      public var rareItem:Boolean;
      
      [XmlAttribute]
      public var repopGift:Boolean;
      
      [XmlAttribute]
      public var requestable:Boolean;
      
      [XmlAttribute(§default§="true")]
      public var sellable:Boolean;
      
      [XmlAttribute]
      public var sendable:Boolean;
      
      [XmlAttribute]
      public var showFeed:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var sortPriority:int;
      
      [XmlAttribute]
      public var subtype:String;
      
      [XmlAttribute]
      public var superCrop:Boolean;
      
      [XmlAttribute]
      public var thankyou:Boolean;
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var unlock:String;
      
      [XmlAttribute]
      public var whatIsThis:Boolean;
      
      [XmlAttribute]
      public var whatIsThisDialog:String;
      
      public var action:String;
      
      public var allowMultipleFinished:Boolean;
      
      public var buff:String;
      
      public var buffExpires:int;
      
      public var bushelItemCode:String;
      
      public var buyXp:int;
      
      public var cash:int;
      
      public var cmsmeta:ItemCMSMetaDO;
      
      public var coinYield:int;
      
      public var component:ItemComponentDO;
      
      public var cost:int;
      
      public var count:Number;
      
      public var creationDate:String;
      
      public var experimentGate:String;
      
      public var numParts:int;
      
      public var features:ItemFeaturesDO;
      
      public var finishedName:String;
      
      public var finishedReward:String;
      
      public var growTime:Number;
      
      public var imageHorizontalOffset:int;
      
      public var imageScale:Number;
      
      public var imageVerticalOffset:int;
      
      public var limit:int;
      
      public var limitedEnd:String;
      
      public var limitedGiftEnd:String;
      
      public var limitedGiftStart:String;
      
      public var limitedIcon:String;
      
      public var limitedRareEnd:String;
      
      public var limitedShowCountdown:Boolean;
      
      public var limitedStart:String;
      
      public var lootTable:String;
      
      public var marketCardDescriptor:String;
      
      public var marketEntries:ItemMarketEntriesDO;
      
      public var marketPrereqs:String;
      
      public var materialPrice:ItemMaterialPriceDO;
      
      public var matsNeeded:int;
      
      public var minNeighbors:int;
      
      public var overrideExportName:String;
      
      public var preCommitData:ItemPreCommitDataDO;
      
      public var priceTest:ItemPriceTestDO;
      
      public var purchasePrereqs:String;
      
      public var requiredLevel:int;
      
      public var requirements:ItemRequirementsDO;
      
      public var landbundles:LandBundlesDO;
      
      public var rewards:ItemRewardsDO;
      
      public var seedpackage:String;
      
      public var sellPrice:int;
      
      public var nectarUnit:int;
      
      public var sizeX:int;
      
      public var sizeY:int;
      
      public var sox:ItemSoxDO;
      
      public var specialSortPriority:int;
      
      public var storageType:ItemStorageTypeDO;
      
      public var terrainAssets:ItemTerrainAssetsDO;
      
      public var terrainSet:ItemTerrainSetDO;
      
      public var aoeLicenseKey:String;
      
      public var XP:int;
      
      public var defaultItem:Array;
      
      public var extraMenuItem:Array;
      
      public var image:Array;
      
      public var itemPackage:Array;
      
      public var keyword:Array;
      
      public var targetQuest:Array;
      
      public var variablePricing:Array;
      
      public function BaseItemDO()
      {
         super();
      }
   }
}

